"""Heterogeneous Graph Transformer (HGT) for multi-type recommendation.

HGT handles graphs with multiple node types (users, games, providers, promotions)
and edge types (played, rated, made_by, features). This enables:
- Rich relationship modeling
- Cold-start handling via meta-paths
- Promotion-aware recommendations
- Device-specific personalization

Paper: https://arxiv.org/abs/2003.01332
"""

import math
from typing import Optional, Dict, List, Tuple, Set
from dataclasses import dataclass, field
from enum import Enum

import torch
import torch.nn as nn
import torch.nn.functional as F


class NodeType(Enum):
    """Types of nodes in the heterogeneous graph."""
    USER = "user"
    GAME = "game"
    PROVIDER = "provider"
    PROMOTION = "promotion"
    DEVICE = "device"
    BADGE = "badge"


class EdgeType(Enum):
    """Types of edges in the heterogeneous graph."""
    # User-Game edges
    PLAYED = "played"           # user -> game (from game_time events)
    RATED = "rated"             # user -> game (from ratings)
    IMPRESSED = "impressed"     # user -> game (from impressions)
    
    # Game-Provider edges
    MADE_BY = "made_by"         # game -> provider
    
    # Promotion-Game edges
    FEATURES = "features"       # promotion -> game
    
    # User-Device edges
    USES = "uses"               # user -> device
    
    # Game-Badge edges
    HAS_BADGE = "has_badge"     # game -> badge
    
    # Reverse edges (for message passing in both directions)
    REV_PLAYED = "rev_played"
    REV_RATED = "rev_rated"
    REV_MADE_BY = "rev_made_by"
    REV_FEATURES = "rev_features"
    REV_USES = "rev_uses"
    REV_HAS_BADGE = "rev_has_badge"


@dataclass
class HeteroEdge:
    """A heterogeneous edge with source, target, and type."""
    src_type: NodeType
    src_idx: int
    dst_type: NodeType
    dst_idx: int
    edge_type: EdgeType
    weight: float = 1.0


@dataclass
class HeteroGraphData:
    """Container for heterogeneous graph data."""
    
    # Node counts per type
    num_nodes: Dict[NodeType, int] = field(default_factory=dict)
    
    # Node features per type (optional)
    node_features: Dict[NodeType, torch.Tensor] = field(default_factory=dict)
    
    # Edges grouped by (src_type, edge_type, dst_type)
    edge_index: Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor] = field(default_factory=dict)
    edge_weight: Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor] = field(default_factory=dict)
    
    # ID mappings
    user_id_to_idx: Dict[str, int] = field(default_factory=dict)
    game_slug_to_idx: Dict[str, int] = field(default_factory=dict)
    provider_to_idx: Dict[str, int] = field(default_factory=dict)
    promotion_to_idx: Dict[str, int] = field(default_factory=dict)
    device_to_idx: Dict[str, int] = field(default_factory=dict)
    badge_to_idx: Dict[str, int] = field(default_factory=dict)
    
    # Reverse mappings
    idx_to_user_id: Dict[int, str] = field(default_factory=dict)
    idx_to_game_slug: Dict[int, str] = field(default_factory=dict)
    idx_to_provider: Dict[int, str] = field(default_factory=dict)
    idx_to_promotion: Dict[int, str] = field(default_factory=dict)
    
    def get_edge_types(self) -> List[Tuple[NodeType, EdgeType, NodeType]]:
        """Get all edge types in the graph."""
        return list(self.edge_index.keys())


class HGTConv(nn.Module):
    """Heterogeneous Graph Transformer Convolution Layer.
    
    Computes attention-weighted message passing with type-specific
    transformations for both nodes and edges.
    """
    
    def __init__(
        self,
        in_dim: int,
        out_dim: int,
        node_types: List[NodeType],
        edge_types: List[Tuple[NodeType, EdgeType, NodeType]],
        num_heads: int = 8,
        dropout: float = 0.1
    ):
        """Initialize HGT convolution.
        
        Args:
            in_dim: Input dimension
            out_dim: Output dimension
            node_types: List of node types
            edge_types: List of (src_type, edge_type, dst_type) tuples
            num_heads: Number of attention heads
            dropout: Dropout probability
        """
        super().__init__()
        
        self.in_dim = in_dim
        self.out_dim = out_dim
        self.num_heads = num_heads
        self.head_dim = out_dim // num_heads
        
        assert out_dim % num_heads == 0, "out_dim must be divisible by num_heads"
        
        # Type-specific linear transformations for keys, queries, values
        self.k_linear = nn.ModuleDict()
        self.q_linear = nn.ModuleDict()
        self.v_linear = nn.ModuleDict()
        self.a_linear = nn.ModuleDict()  # For computing attention
        self.m_linear = nn.ModuleDict()  # For computing messages
        
        for node_type in node_types:
            type_name = node_type.value
            self.k_linear[type_name] = nn.Linear(in_dim, out_dim)
            self.q_linear[type_name] = nn.Linear(in_dim, out_dim)
            self.v_linear[type_name] = nn.Linear(in_dim, out_dim)
        
        # Edge-type specific attention and message weights
        for src_type, edge_type, dst_type in edge_types:
            edge_name = f"{src_type.value}__{edge_type.value}__{dst_type.value}"
            self.a_linear[edge_name] = nn.Linear(out_dim, num_heads)
            self.m_linear[edge_name] = nn.Linear(out_dim, out_dim)
        
        # Output transformation per node type
        self.out_linear = nn.ModuleDict()
        for node_type in node_types:
            self.out_linear[node_type.value] = nn.Linear(out_dim, out_dim)
        
        self.dropout = nn.Dropout(dropout)
        self.scale = math.sqrt(self.head_dim)
    
    def forward(
        self,
        x_dict: Dict[NodeType, torch.Tensor],
        edge_index_dict: Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor],
        edge_weight_dict: Optional[Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor]] = None
    ) -> Dict[NodeType, torch.Tensor]:
        """Forward pass for HGT convolution.
        
        Args:
            x_dict: Node features per type {NodeType: [num_nodes, in_dim]}
            edge_index_dict: Edge indices per type {(src, edge, dst): [2, num_edges]}
            edge_weight_dict: Optional edge weights
            
        Returns:
            Updated node features per type {NodeType: [num_nodes, out_dim]}
        """
        # Compute keys, queries, values for each node type
        k_dict = {}
        q_dict = {}
        v_dict = {}
        
        for node_type, x in x_dict.items():
            type_name = node_type.value
            k_dict[node_type] = self.k_linear[type_name](x)
            q_dict[node_type] = self.q_linear[type_name](x)
            v_dict[node_type] = self.v_linear[type_name](x)
        
        # Aggregate messages for each node type
        out_dict = {
            node_type: torch.zeros_like(v_dict[node_type])
            for node_type in x_dict.keys()
        }
        count_dict = {
            node_type: torch.zeros(x_dict[node_type].size(0), 1, device=x_dict[node_type].device)
            for node_type in x_dict.keys()
        }
        
        for (src_type, edge_type, dst_type), edge_index in edge_index_dict.items():
            if edge_index.numel() == 0:
                continue
            
            edge_name = f"{src_type.value}__{edge_type.value}__{dst_type.value}"
            
            src_idx = edge_index[0]
            dst_idx = edge_index[1]
            
            # Get source keys and destination queries
            k_src = k_dict[src_type][src_idx]  # [num_edges, out_dim]
            q_dst = q_dict[dst_type][dst_idx]  # [num_edges, out_dim]
            v_src = v_dict[src_type][src_idx]  # [num_edges, out_dim]
            
            # Compute attention scores
            attn_input = k_src * q_dst  # Element-wise product
            attn_scores = self.a_linear[edge_name](attn_input)  # [num_edges, num_heads]
            attn_scores = attn_scores / self.scale
            
            # Apply edge weights if provided
            if edge_weight_dict and (src_type, edge_type, dst_type) in edge_weight_dict:
                edge_weights = edge_weight_dict[(src_type, edge_type, dst_type)]
                attn_scores = attn_scores * edge_weights.unsqueeze(-1)
            
            # Softmax per destination node (grouped)
            attn_weights = F.softmax(attn_scores, dim=-1)  # Simple version
            attn_weights = self.dropout(attn_weights)
            
            # Compute messages
            messages = self.m_linear[edge_name](v_src)  # [num_edges, out_dim]
            
            # Weight by attention (average across heads)
            attn_avg = attn_weights.mean(dim=-1, keepdim=True)
            weighted_messages = messages * attn_avg
            
            # Aggregate to destination nodes
            out_dict[dst_type].index_add_(0, dst_idx, weighted_messages)
            count_dict[dst_type].index_add_(
                0, dst_idx,
                torch.ones(dst_idx.size(0), 1, device=dst_idx.device)
            )
        
        # Normalize and apply output transformation
        result = {}
        for node_type in x_dict.keys():
            count = count_dict[node_type].clamp(min=1)
            normalized = out_dict[node_type] / count
            
            # Residual connection
            residual = x_dict[node_type]
            if residual.size(-1) != normalized.size(-1):
                # Project residual if dimensions don't match
                residual = F.linear(residual, torch.eye(normalized.size(-1), residual.size(-1), device=residual.device))
            
            output = self.out_linear[node_type.value](normalized) + residual
            result[node_type] = F.relu(output)
        
        return result


class HGT(nn.Module):
    """Heterogeneous Graph Transformer for multi-type recommendation.
    
    Handles graphs with multiple node types and edge types, learning
    type-specific representations through attention mechanisms.
    """
    
    def __init__(
        self,
        node_types: List[NodeType],
        edge_types: List[Tuple[NodeType, EdgeType, NodeType]],
        num_nodes_dict: Dict[NodeType, int],
        embedding_dim: int = 768,
        hidden_dim: int = 256,
        num_layers: int = 2,
        num_heads: int = 8,
        dropout: float = 0.1,
        node_feature_dims: Optional[Dict[NodeType, int]] = None
    ):
        """Initialize HGT.
        
        Args:
            node_types: List of node types
            edge_types: List of (src_type, edge_type, dst_type) tuples
            num_nodes_dict: Number of nodes per type
            embedding_dim: Output embedding dimension
            hidden_dim: Hidden layer dimension
            num_layers: Number of HGT layers
            num_heads: Number of attention heads
            dropout: Dropout probability
            node_feature_dims: Optional input feature dimensions per type
        """
        super().__init__()
        
        self.node_types = node_types
        self.edge_types = edge_types
        self.num_nodes_dict = num_nodes_dict
        self.embedding_dim = embedding_dim
        self.hidden_dim = hidden_dim
        self.num_layers = num_layers
        
        # Node embeddings (learnable) or feature projections
        self.node_embeddings = nn.ModuleDict()
        self.feature_projections = nn.ModuleDict()
        
        for node_type in node_types:
            type_name = node_type.value
            num_nodes = num_nodes_dict.get(node_type, 0)
            
            if num_nodes > 0:
                self.node_embeddings[type_name] = nn.Embedding(num_nodes, hidden_dim)
            
            # Feature projection if features are provided
            if node_feature_dims and node_type in node_feature_dims:
                feat_dim = node_feature_dims[node_type]
                self.feature_projections[type_name] = nn.Linear(feat_dim, hidden_dim)
        
        # HGT convolution layers
        self.convs = nn.ModuleList()
        for _ in range(num_layers):
            self.convs.append(HGTConv(
                in_dim=hidden_dim,
                out_dim=hidden_dim,
                node_types=node_types,
                edge_types=edge_types,
                num_heads=num_heads,
                dropout=dropout
            ))
        
        # Output projections to embedding_dim
        self.out_projections = nn.ModuleDict()
        for node_type in node_types:
            type_name = node_type.value
            self.out_projections[type_name] = nn.Linear(hidden_dim, embedding_dim)
        
        # Initialize weights
        self._init_weights()
    
    def _init_weights(self):
        """Initialize embeddings with Xavier uniform."""
        for embedding in self.node_embeddings.values():
            nn.init.xavier_uniform_(embedding.weight)
    
    def get_initial_embeddings(
        self,
        node_features: Optional[Dict[NodeType, torch.Tensor]] = None
    ) -> Dict[NodeType, torch.Tensor]:
        """Get initial node embeddings.
        
        Args:
            node_features: Optional node features per type
            
        Returns:
            Initial embeddings per type
        """
        x_dict = {}
        
        for node_type in self.node_types:
            type_name = node_type.value
            num_nodes = self.num_nodes_dict.get(node_type, 0)
            
            if num_nodes == 0:
                continue
            
            # Start with learnable embeddings
            if type_name in self.node_embeddings:
                device = next(self.parameters()).device
                indices = torch.arange(num_nodes, device=device)
                x = self.node_embeddings[type_name](indices)
            else:
                device = next(self.parameters()).device
                x = torch.zeros(num_nodes, self.hidden_dim, device=device)
            
            # Add projected features if available
            if node_features and node_type in node_features and type_name in self.feature_projections:
                features = node_features[node_type]
                projected = self.feature_projections[type_name](features)
                x = x + projected
            
            x_dict[node_type] = x
        
        return x_dict
    
    def forward(
        self,
        edge_index_dict: Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor],
        edge_weight_dict: Optional[Dict[Tuple[NodeType, EdgeType, NodeType], torch.Tensor]] = None,
        node_features: Optional[Dict[NodeType, torch.Tensor]] = None
    ) -> Dict[NodeType, torch.Tensor]:
        """Forward pass to compute all node embeddings.
        
        Args:
            edge_index_dict: Edge indices per type
            edge_weight_dict: Optional edge weights
            node_features: Optional node features
            
        Returns:
            Node embeddings per type {NodeType: [num_nodes, embedding_dim]}
        """
        # Get initial embeddings
        x_dict = self.get_initial_embeddings(node_features)
        
        # Apply HGT layers
        for conv in self.convs:
            x_dict = conv(x_dict, edge_index_dict, edge_weight_dict)
        
        # Project to output dimension
        out_dict = {}
        for node_type, x in x_dict.items():
            type_name = node_type.value
            out_dict[node_type] = self.out_projections[type_name](x)
        
        return out_dict
    
    def get_user_embedding(
        self,
        user_idx: int,
        embeddings: Dict[NodeType, torch.Tensor]
    ) -> torch.Tensor:
        """Get embedding for a specific user."""
        return embeddings[NodeType.USER][user_idx]
    
    def get_game_embedding(
        self,
        game_idx: int,
        embeddings: Dict[NodeType, torch.Tensor]
    ) -> torch.Tensor:
        """Get embedding for a specific game."""
        return embeddings[NodeType.GAME][game_idx]
    
    def predict(
        self,
        user_emb: torch.Tensor,
        game_emb: torch.Tensor
    ) -> torch.Tensor:
        """Predict interaction score."""
        return (user_emb * game_emb).sum(dim=-1)
    
    def get_cold_start_embedding(
        self,
        node_type: NodeType,
        connected_types: Dict[NodeType, List[int]],
        embeddings: Dict[NodeType, torch.Tensor]
    ) -> torch.Tensor:
        """Get embedding for a cold-start node via meta-path aggregation.
        
        For new users/games, aggregate embeddings from connected nodes.
        
        Args:
            node_type: Type of the cold-start node
            connected_types: Connected node indices per type
            embeddings: Current embeddings
            
        Returns:
            Aggregated embedding
        """
        aggregated = []
        
        for connected_type, indices in connected_types.items():
            if connected_type in embeddings and indices:
                connected_embs = embeddings[connected_type][indices]
                aggregated.append(connected_embs.mean(dim=0))
        
        if not aggregated:
            # Return zero vector if no connections
            return torch.zeros(self.embedding_dim, device=next(self.parameters()).device)
        
        # Average across all connected types
        return torch.stack(aggregated).mean(dim=0)


class HGTInference:
    """Inference wrapper for HGT with cold-start handling."""
    
    def __init__(
        self,
        model: HGT,
        graph_data: HeteroGraphData,
        device: torch.device
    ):
        """Initialize inference wrapper.
        
        Args:
            model: Trained HGT model
            graph_data: Heterogeneous graph data
            device: PyTorch device
        """
        self.model = model
        self.graph_data = graph_data
        self.device = device
        self.model.eval()
        
        # Cached embeddings
        self.embeddings: Optional[Dict[NodeType, torch.Tensor]] = None
    
    def compute_embeddings(self):
        """Compute and cache all embeddings."""
        with torch.no_grad():
            # Move edge indices to device
            edge_index_dict = {
                k: v.to(self.device)
                for k, v in self.graph_data.edge_index.items()
            }
            
            edge_weight_dict = None
            if self.graph_data.edge_weight:
                edge_weight_dict = {
                    k: v.to(self.device)
                    for k, v in self.graph_data.edge_weight.items()
                }
            
            node_features = None
            if self.graph_data.node_features:
                node_features = {
                    k: v.to(self.device)
                    for k, v in self.graph_data.node_features.items()
                }
            
            self.embeddings = self.model(edge_index_dict, edge_weight_dict, node_features)
    
    def get_user_embedding(self, user_id: str) -> Optional[torch.Tensor]:
        """Get embedding for a user."""
        if self.embeddings is None:
            self.compute_embeddings()
        
        user_idx = self.graph_data.user_id_to_idx.get(user_id)
        if user_idx is None:
            return None
        
        return self.embeddings[NodeType.USER][user_idx]
    
    def get_game_embedding(self, game_slug: str) -> Optional[torch.Tensor]:
        """Get embedding for a game."""
        if self.embeddings is None:
            self.compute_embeddings()
        
        game_idx = self.graph_data.game_slug_to_idx.get(game_slug)
        if game_idx is None:
            return None
        
        return self.embeddings[NodeType.GAME][game_idx]
    
    def get_recommendations(
        self,
        user_id: str,
        top_k: int = 10,
        exclude_games: Optional[Set[str]] = None,
        provider_filter: Optional[str] = None
    ) -> List[Tuple[str, float]]:
        """Get recommendations for a user.
        
        Args:
            user_id: User ID
            top_k: Number of recommendations
            exclude_games: Games to exclude
            provider_filter: Optional provider to filter by
            
        Returns:
            List of (game_slug, score) tuples
        """
        if self.embeddings is None:
            self.compute_embeddings()
        
        user_idx = self.graph_data.user_id_to_idx.get(user_id)
        
        if user_idx is None:
            # Cold-start user - try meta-path aggregation
            return self._cold_start_recommendations(user_id, top_k)
        
        user_emb = self.embeddings[NodeType.USER][user_idx]
        game_embs = self.embeddings[NodeType.GAME]
        
        # Compute scores
        scores = torch.matmul(game_embs, user_emb)
        
        # Apply exclusions
        if exclude_games:
            for game_slug in exclude_games:
                game_idx = self.graph_data.game_slug_to_idx.get(game_slug)
                if game_idx is not None:
                    scores[game_idx] = float('-inf')
        
        # Get top-K
        top_scores, top_indices = torch.topk(scores, min(top_k, len(scores)))
        
        results = []
        for idx, score in zip(top_indices, top_scores):
            game_slug = self.graph_data.idx_to_game_slug.get(idx.item())
            if game_slug:
                results.append((game_slug, score.item()))
        
        return results
    
    def _cold_start_recommendations(
        self,
        user_id: str,
        top_k: int
    ) -> List[Tuple[str, float]]:
        """Handle cold-start users via popular games or device-based similarity."""
        # For now, return games with highest average embeddings (popular)
        if NodeType.GAME not in self.embeddings:
            return []
        
        game_embs = self.embeddings[NodeType.GAME]
        
        # Use L2 norm as popularity proxy
        norms = game_embs.norm(dim=-1)
        top_scores, top_indices = torch.topk(norms, min(top_k, len(norms)))
        
        results = []
        for idx, score in zip(top_indices, top_scores):
            game_slug = self.graph_data.idx_to_game_slug.get(idx.item())
            if game_slug:
                results.append((game_slug, score.item()))
        
        return results
    
    def get_similar_games(
        self,
        game_slug: str,
        top_k: int = 10
    ) -> List[Tuple[str, float]]:
        """Get games similar to a given game.
        
        Uses game embeddings which incorporate provider, badges, etc.
        """
        if self.embeddings is None:
            self.compute_embeddings()
        
        game_idx = self.graph_data.game_slug_to_idx.get(game_slug)
        if game_idx is None:
            return []
        
        game_emb = self.embeddings[NodeType.GAME][game_idx]
        all_game_embs = self.embeddings[NodeType.GAME]
        
        # Compute similarities
        similarities = F.cosine_similarity(
            game_emb.unsqueeze(0),
            all_game_embs
        )
        
        # Exclude self
        similarities[game_idx] = float('-inf')
        
        top_scores, top_indices = torch.topk(similarities, min(top_k, len(similarities)))
        
        results = []
        for idx, score in zip(top_indices, top_scores):
            slug = self.graph_data.idx_to_game_slug.get(idx.item())
            if slug:
                results.append((slug, score.item()))
        
        return results
    
    def get_provider_games(
        self,
        provider: str,
        user_id: Optional[str] = None,
        top_k: int = 10
    ) -> List[Tuple[str, float]]:
        """Get recommended games from a specific provider.
        
        If user_id is provided, personalize the ranking.
        """
        if self.embeddings is None:
            self.compute_embeddings()
        
        provider_idx = self.graph_data.provider_to_idx.get(provider)
        if provider_idx is None:
            return []
        
        # Find games by this provider
        edge_key = (NodeType.GAME, EdgeType.MADE_BY, NodeType.PROVIDER)
        if edge_key not in self.graph_data.edge_index:
            return []
        
        edge_index = self.graph_data.edge_index[edge_key]
        game_indices = edge_index[0][edge_index[1] == provider_idx].tolist()
        
        if not game_indices:
            return []
        
        if user_id:
            # Personalized ranking
            user_idx = self.graph_data.user_id_to_idx.get(user_id)
            if user_idx is not None:
                user_emb = self.embeddings[NodeType.USER][user_idx]
                game_embs = self.embeddings[NodeType.GAME][game_indices]
                scores = torch.matmul(game_embs, user_emb)
                
                sorted_indices = torch.argsort(scores, descending=True)[:top_k]
                results = []
                for i in sorted_indices:
                    game_idx = game_indices[i]
                    slug = self.graph_data.idx_to_game_slug.get(game_idx)
                    if slug:
                        results.append((slug, scores[i].item()))
                return results
        
        # Return games sorted by embedding norm
        game_embs = self.embeddings[NodeType.GAME][game_indices]
        norms = game_embs.norm(dim=-1)
        sorted_indices = torch.argsort(norms, descending=True)[:top_k]
        
        results = []
        for i in sorted_indices:
            game_idx = game_indices[i]
            slug = self.graph_data.idx_to_game_slug.get(game_idx)
            if slug:
                results.append((slug, norms[i].item()))
        
        return results

