"""LightGCN model implementation using PyTorch Geometric.

LightGCN simplifies GCN for collaborative filtering by:
1. Removing feature transformations
2. Removing nonlinear activations
3. Only using neighborhood aggregation

Paper: https://arxiv.org/abs/2002.02126
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn.conv import MessagePassing
from torch_geometric.utils import degree
from typing import Optional, Tuple


class LightGCNConv(MessagePassing):
    """Light Graph Convolution layer.
    
    Performs neighborhood aggregation without feature transformation:
    e_i^(k+1) = Σ (1/√|N_i|√|N_j|) * e_j^(k)
    """
    
    def __init__(self):
        super().__init__(aggr='add')
    
    def forward(
        self,
        x: torch.Tensor,
        edge_index: torch.Tensor,
        edge_weight: Optional[torch.Tensor] = None
    ) -> torch.Tensor:
        """Forward pass for LightGCN convolution.
        
        Args:
            x: Node embeddings [num_nodes, embedding_dim]
            edge_index: Edge indices [2, num_edges]
            edge_weight: Optional edge weights [num_edges]
            
        Returns:
            Updated node embeddings [num_nodes, embedding_dim]
        """
        # Compute normalization coefficients
        row, col = edge_index
        deg = degree(col, x.size(0), dtype=x.dtype)
        deg_inv_sqrt = deg.pow(-0.5)
        deg_inv_sqrt[deg_inv_sqrt == float('inf')] = 0
        norm = deg_inv_sqrt[row] * deg_inv_sqrt[col]
        
        if edge_weight is not None:
            norm = norm * edge_weight
        
        return self.propagate(edge_index, x=x, norm=norm)
    
    def message(self, x_j: torch.Tensor, norm: torch.Tensor) -> torch.Tensor:
        """Message function: apply normalization to neighbor embeddings."""
        return norm.view(-1, 1) * x_j


class LightGCN(nn.Module):
    """LightGCN model for collaborative filtering.
    
    Learns user and item embeddings through graph convolution on
    the user-item bipartite interaction graph.
    
    The final embedding is the mean of embeddings from all layers:
    e_final = (1/(K+1)) * Σ e^(k) for k = 0, 1, ..., K
    """
    
    def __init__(
        self,
        num_users: int,
        num_items: int,
        embedding_dim: int = 768,
        num_layers: int = 3
    ):
        """Initialize LightGCN model.
        
        Args:
            num_users: Number of users in the graph
            num_items: Number of items (games) in the graph
            embedding_dim: Dimension of embeddings
            num_layers: Number of GCN layers (K)
        """
        super().__init__()
        
        self.num_users = num_users
        self.num_items = num_items
        self.embedding_dim = embedding_dim
        self.num_layers = num_layers
        
        # Learnable embeddings for users and items
        self.user_embedding = nn.Embedding(num_users, embedding_dim)
        self.item_embedding = nn.Embedding(num_items, embedding_dim)
        
        # LightGCN convolution layers (shared across layers)
        self.conv = LightGCNConv()
        
        # Initialize embeddings
        self._init_weights()
    
    def _init_weights(self):
        """Initialize embeddings with Xavier uniform."""
        nn.init.xavier_uniform_(self.user_embedding.weight)
        nn.init.xavier_uniform_(self.item_embedding.weight)
    
    def forward(
        self,
        edge_index: torch.Tensor,
        edge_weight: Optional[torch.Tensor] = None
    ) -> Tuple[torch.Tensor, torch.Tensor]:
        """Forward pass to compute all user and item embeddings.
        
        Args:
            edge_index: Bipartite edge indices [2, num_edges]
                        Row 0: user indices (0 to num_users-1)
                        Row 1: item indices (num_users to num_users+num_items-1)
            edge_weight: Optional edge weights [num_edges]
            
        Returns:
            Tuple of (user_embeddings, item_embeddings)
        """
        # Concatenate user and item embeddings
        x = torch.cat([
            self.user_embedding.weight,
            self.item_embedding.weight
        ], dim=0)
        
        # Store embeddings from each layer
        all_embeddings = [x]
        
        # Apply K layers of LightGCN convolution
        for _ in range(self.num_layers):
            x = self.conv(x, edge_index, edge_weight)
            all_embeddings.append(x)
        
        # Average embeddings across all layers
        all_embeddings = torch.stack(all_embeddings, dim=0)
        final_embeddings = all_embeddings.mean(dim=0)
        
        # Split into user and item embeddings
        user_embeddings = final_embeddings[:self.num_users]
        item_embeddings = final_embeddings[self.num_users:]
        
        return user_embeddings, item_embeddings
    
    def get_user_embedding(
        self,
        user_idx: int,
        edge_index: torch.Tensor,
        edge_weight: Optional[torch.Tensor] = None
    ) -> torch.Tensor:
        """Get embedding for a specific user.
        
        Args:
            user_idx: User index
            edge_index: Bipartite edge indices
            edge_weight: Optional edge weights
            
        Returns:
            User embedding [embedding_dim]
        """
        user_embeddings, _ = self.forward(edge_index, edge_weight)
        return user_embeddings[user_idx]
    
    def get_item_embedding(
        self,
        item_idx: int,
        edge_index: torch.Tensor,
        edge_weight: Optional[torch.Tensor] = None
    ) -> torch.Tensor:
        """Get embedding for a specific item.
        
        Args:
            item_idx: Item index (0-indexed, not offset by num_users)
            edge_index: Bipartite edge indices
            edge_weight: Optional edge weights
            
        Returns:
            Item embedding [embedding_dim]
        """
        _, item_embeddings = self.forward(edge_index, edge_weight)
        return item_embeddings[item_idx]
    
    def predict(
        self,
        user_idx: torch.Tensor,
        item_idx: torch.Tensor,
        user_embeddings: torch.Tensor,
        item_embeddings: torch.Tensor
    ) -> torch.Tensor:
        """Predict interaction scores between users and items.
        
        Args:
            user_idx: User indices [batch_size]
            item_idx: Item indices [batch_size]
            user_embeddings: All user embeddings [num_users, embedding_dim]
            item_embeddings: All item embeddings [num_items, embedding_dim]
            
        Returns:
            Predicted scores [batch_size]
        """
        user_emb = user_embeddings[user_idx]
        item_emb = item_embeddings[item_idx]
        
        # Inner product for prediction
        return (user_emb * item_emb).sum(dim=-1)
    
    def bpr_loss(
        self,
        user_idx: torch.Tensor,
        pos_item_idx: torch.Tensor,
        neg_item_idx: torch.Tensor,
        user_embeddings: torch.Tensor,
        item_embeddings: torch.Tensor,
        lambda_reg: float = 1e-4
    ) -> torch.Tensor:
        """Compute BPR (Bayesian Personalized Ranking) loss.
        
        BPR loss encourages positive items to be ranked higher than
        negative items for each user.
        
        Args:
            user_idx: User indices [batch_size]
            pos_item_idx: Positive item indices [batch_size]
            neg_item_idx: Negative item indices [batch_size]
            user_embeddings: All user embeddings [num_users, embedding_dim]
            item_embeddings: All item embeddings [num_items, embedding_dim]
            lambda_reg: L2 regularization coefficient
            
        Returns:
            BPR loss scalar
        """
        # Get embeddings
        user_emb = user_embeddings[user_idx]
        pos_item_emb = item_embeddings[pos_item_idx]
        neg_item_emb = item_embeddings[neg_item_idx]
        
        # Compute scores
        pos_scores = (user_emb * pos_item_emb).sum(dim=-1)
        neg_scores = (user_emb * neg_item_emb).sum(dim=-1)
        
        # BPR loss: -log(sigmoid(pos - neg))
        bpr_loss = -F.logsigmoid(pos_scores - neg_scores).mean()
        
        # L2 regularization on initial embeddings
        reg_loss = lambda_reg * (
            self.user_embedding.weight[user_idx].pow(2).sum() +
            self.item_embedding.weight[pos_item_idx].pow(2).sum() +
            self.item_embedding.weight[neg_item_idx].pow(2).sum()
        ) / user_idx.size(0)
        
        return bpr_loss + reg_loss


class LightGCNInference:
    """Inference wrapper for LightGCN with cached embeddings."""
    
    def __init__(self, model: LightGCN, device: torch.device):
        """Initialize inference wrapper.
        
        Args:
            model: Trained LightGCN model
            device: PyTorch device
        """
        self.model = model
        self.device = device
        self.user_embeddings: Optional[torch.Tensor] = None
        self.item_embeddings: Optional[torch.Tensor] = None
    
    def compute_embeddings(
        self,
        edge_index: torch.Tensor,
        edge_weight: Optional[torch.Tensor] = None
    ):
        """Compute and cache all embeddings.
        
        Args:
            edge_index: Bipartite edge indices
            edge_weight: Optional edge weights
        """
        self.model.eval()
        with torch.no_grad():
            edge_index = edge_index.to(self.device)
            if edge_weight is not None:
                edge_weight = edge_weight.to(self.device)
            
            self.user_embeddings, self.item_embeddings = self.model(
                edge_index, edge_weight
            )
    
    def get_user_embedding(self, user_idx: int) -> torch.Tensor:
        """Get cached user embedding."""
        if self.user_embeddings is None:
            raise RuntimeError("Call compute_embeddings first")
        return self.user_embeddings[user_idx]
    
    def get_item_embedding(self, item_idx: int) -> torch.Tensor:
        """Get cached item embedding."""
        if self.item_embeddings is None:
            raise RuntimeError("Call compute_embeddings first")
        return self.item_embeddings[item_idx]
    
    def get_all_user_embeddings(self) -> torch.Tensor:
        """Get all cached user embeddings."""
        if self.user_embeddings is None:
            raise RuntimeError("Call compute_embeddings first")
        return self.user_embeddings
    
    def get_all_item_embeddings(self) -> torch.Tensor:
        """Get all cached item embeddings."""
        if self.item_embeddings is None:
            raise RuntimeError("Call compute_embeddings first")
        return self.item_embeddings
    
    def recommend(
        self,
        user_idx: int,
        exclude_items: Optional[set] = None,
        top_k: int = 10
    ) -> list[Tuple[int, float]]:
        """Generate top-K recommendations for a user.
        
        Args:
            user_idx: User index
            exclude_items: Set of item indices to exclude (e.g., already interacted)
            top_k: Number of recommendations to return
            
        Returns:
            List of (item_idx, score) tuples, sorted by score descending
        """
        if self.user_embeddings is None or self.item_embeddings is None:
            raise RuntimeError("Call compute_embeddings first")
        
        user_emb = self.user_embeddings[user_idx]
        
        # Compute scores for all items
        scores = torch.matmul(self.item_embeddings, user_emb)
        
        # Mask excluded items
        if exclude_items:
            for item_idx in exclude_items:
                scores[item_idx] = float('-inf')
        
        # Get top-K
        top_scores, top_indices = torch.topk(scores, min(top_k, len(scores)))
        
        return [
            (idx.item(), score.item())
            for idx, score in zip(top_indices, top_scores)
        ]

