"""Training pipeline for HGT (Heterogeneous Graph Transformer) model."""

import os
import random
from pathlib import Path
from typing import Optional, List, Tuple, Dict

import torch
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
import structlog

from app.config import get_settings
from app.models.hgt import (
    HGT, HGTInference, HeteroGraphData,
    NodeType, EdgeType
)

logger = structlog.get_logger()


class HGTBPRDataset(Dataset):
    """Dataset for HGT training using BPR loss.
    
    Generates (user, positive_game, negative_game) triplets.
    """
    
    def __init__(
        self,
        graph_data: HeteroGraphData,
        num_negatives: int = 1
    ):
        """Initialize dataset.
        
        Args:
            graph_data: Heterogeneous graph data
            num_negatives: Negative samples per positive
        """
        self.graph_data = graph_data
        self.num_negatives = num_negatives
        
        # Build user -> positive games mapping from edges
        self.user_positive_games: Dict[int, set] = {}
        
        for edge_type in [EdgeType.PLAYED, EdgeType.RATED]:
            key = (NodeType.USER, edge_type, NodeType.GAME)
            if key in graph_data.edge_index:
                edge_index = graph_data.edge_index[key]
                for i in range(edge_index.size(1)):
                    user_idx = edge_index[0, i].item()
                    game_idx = edge_index[1, i].item()
                    
                    if user_idx not in self.user_positive_games:
                        self.user_positive_games[user_idx] = set()
                    self.user_positive_games[user_idx].add(game_idx)
        
        # Build training triplets
        self.triplets = []
        for user_idx, pos_games in self.user_positive_games.items():
            for pos_game in pos_games:
                self.triplets.append((user_idx, pos_game))
        
        self.all_games = set(range(graph_data.num_nodes.get(NodeType.GAME, 0)))
    
    def __len__(self) -> int:
        return len(self.triplets) * self.num_negatives
    
    def __getitem__(self, idx: int) -> Tuple[int, int, int]:
        """Get a training triplet."""
        triplet_idx = idx // self.num_negatives
        user_idx, pos_game_idx = self.triplets[triplet_idx]
        
        # Sample negative game
        pos_games = self.user_positive_games.get(user_idx, set())
        neg_candidates = list(self.all_games - pos_games)
        
        if not neg_candidates:
            neg_game_idx = random.randint(0, len(self.all_games) - 1)
        else:
            neg_game_idx = random.choice(neg_candidates)
        
        return user_idx, pos_game_idx, neg_game_idx


class HGTTrainer:
    """Trainer for HGT model."""
    
    def __init__(
        self,
        graph_data: HeteroGraphData,
        device: Optional[torch.device] = None
    ):
        """Initialize trainer.
        
        Args:
            graph_data: Heterogeneous graph data
            device: PyTorch device
        """
        self.settings = get_settings()
        self.graph_data = graph_data
        
        if device is None:
            device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.device = device
        
        logger.info(f"HGT Trainer using device: {self.device}")
        
        # Determine node types and edge types from graph
        node_types = [nt for nt, count in graph_data.num_nodes.items() if count > 0]
        edge_types = list(graph_data.edge_index.keys())
        
        # Initialize model
        self.model = HGT(
            node_types=node_types,
            edge_types=edge_types,
            num_nodes_dict=graph_data.num_nodes,
            embedding_dim=self.settings.embedding_dim,
            hidden_dim=256,
            num_layers=2,
            num_heads=8,
            dropout=0.1
        ).to(self.device)
        
        # Move edge data to device
        self.edge_index_dict = {
            k: v.to(self.device)
            for k, v in graph_data.edge_index.items()
        }
        
        self.edge_weight_dict = None
        if graph_data.edge_weight:
            self.edge_weight_dict = {
                k: v.to(self.device)
                for k, v in graph_data.edge_weight.items()
            }
        
        # Optimizer
        self.optimizer = optim.Adam(
            self.model.parameters(),
            lr=self.settings.learning_rate
        )
        
        # Training history
        self.train_losses: List[float] = []
    
    def train(
        self,
        num_epochs: Optional[int] = None,
        batch_size: Optional[int] = None
    ) -> dict:
        """Train the HGT model.
        
        Args:
            num_epochs: Number of training epochs
            batch_size: Batch size
            
        Returns:
            Training statistics
        """
        num_epochs = num_epochs or self.settings.num_epochs
        batch_size = batch_size or min(self.settings.batch_size, 512)
        
        logger.info(
            "Starting HGT training",
            num_epochs=num_epochs,
            batch_size=batch_size,
            num_node_types=len(self.graph_data.num_nodes),
            num_edge_types=len(self.graph_data.edge_index)
        )
        
        # Create dataset
        dataset = HGTBPRDataset(self.graph_data)
        
        if len(dataset) == 0:
            logger.warning("No training data for HGT")
            return {
                "final_loss": 0.0,
                "best_loss": 0.0,
                "num_epochs": 0,
                "train_losses": []
            }
        
        dataloader = DataLoader(
            dataset,
            batch_size=batch_size,
            shuffle=True,
            num_workers=0
        )
        
        best_loss = float('inf')
        
        for epoch in range(num_epochs):
            self.model.train()
            total_loss = 0.0
            num_batches = 0
            
            for batch in dataloader:
                user_idx, pos_game_idx, neg_game_idx = batch
                user_idx = user_idx.to(self.device)
                pos_game_idx = pos_game_idx.to(self.device)
                neg_game_idx = neg_game_idx.to(self.device)
                
                self.optimizer.zero_grad()
                
                # Forward pass
                embeddings = self.model(
                    self.edge_index_dict,
                    self.edge_weight_dict
                )
                
                # Get embeddings
                user_emb = embeddings[NodeType.USER][user_idx]
                pos_game_emb = embeddings[NodeType.GAME][pos_game_idx]
                neg_game_emb = embeddings[NodeType.GAME][neg_game_idx]
                
                # Compute BPR loss
                pos_scores = (user_emb * pos_game_emb).sum(dim=-1)
                neg_scores = (user_emb * neg_game_emb).sum(dim=-1)
                
                loss = -F.logsigmoid(pos_scores - neg_scores).mean()
                
                # L2 regularization
                reg_loss = 0.0001 * (
                    user_emb.pow(2).sum() +
                    pos_game_emb.pow(2).sum() +
                    neg_game_emb.pow(2).sum()
                ) / user_idx.size(0)
                
                total_batch_loss = loss + reg_loss
                
                # Backward
                total_batch_loss.backward()
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), 1.0)
                self.optimizer.step()
                
                total_loss += loss.item()
                num_batches += 1
            
            avg_loss = total_loss / max(num_batches, 1)
            self.train_losses.append(avg_loss)
            
            if avg_loss < best_loss:
                best_loss = avg_loss
            
            if (epoch + 1) % 10 == 0:
                logger.info(
                    f"HGT Epoch {epoch + 1}/{num_epochs}",
                    loss=f"{avg_loss:.4f}",
                    best_loss=f"{best_loss:.4f}"
                )
        
        logger.info("HGT training completed", final_loss=f"{self.train_losses[-1]:.4f}")
        
        return {
            "final_loss": self.train_losses[-1] if self.train_losses else 0.0,
            "best_loss": best_loss,
            "num_epochs": num_epochs,
            "train_losses": self.train_losses
        }
    
    def save_model(self, path: Optional[str] = None):
        """Save model checkpoint."""
        if path is None:
            path = self.settings.model_path.replace('lightgcn', 'hgt')
        
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        
        # Serialize num_nodes with string keys
        num_nodes_serializable = {
            k.value: v for k, v in self.graph_data.num_nodes.items()
        }
        
        checkpoint = {
            "model_state_dict": self.model.state_dict(),
            "optimizer_state_dict": self.optimizer.state_dict(),
            "train_losses": self.train_losses,
            "num_nodes": num_nodes_serializable,
            "embedding_dim": self.settings.embedding_dim,
            "user_id_to_idx": self.graph_data.user_id_to_idx,
            "game_slug_to_idx": self.graph_data.game_slug_to_idx,
            "provider_to_idx": self.graph_data.provider_to_idx,
            "promotion_to_idx": self.graph_data.promotion_to_idx,
        }
        
        torch.save(checkpoint, path)
        logger.info("HGT model saved", path=path)
    
    def load_model(self, path: Optional[str] = None) -> bool:
        """Load model checkpoint."""
        if path is None:
            path = self.settings.model_path.replace('lightgcn', 'hgt')
        
        if not os.path.exists(path):
            return False
        
        try:
            checkpoint = torch.load(path, map_location=self.device)
            self.model.load_state_dict(checkpoint["model_state_dict"])
            self.optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            self.train_losses = checkpoint.get("train_losses", [])
            
            logger.info("HGT model loaded", path=path)
            return True
            
        except Exception as e:
            logger.error("Failed to load HGT model", error=str(e))
            return False
    
    def get_inference(self) -> HGTInference:
        """Get inference wrapper."""
        return HGTInference(self.model, self.graph_data, self.device)

