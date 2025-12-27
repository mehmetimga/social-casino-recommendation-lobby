"""Training pipeline for LightGCN model."""

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
from app.models.lightgcn import LightGCN, LightGCNInference
from app.services.graph_builder import GraphData

logger = structlog.get_logger()


class BPRDataset(Dataset):
    """Dataset for LightGCN training using BPR loss.
    
    Generates (user, positive_game, negative_game) triplets.
    """
    
    def __init__(
        self,
        graph_data: GraphData,
        num_negatives: int = 1
    ):
        """Initialize dataset.
        
        Args:
            graph_data: User-game graph data
            num_negatives: Negative samples per positive
        """
        self.graph_data = graph_data
        self.num_negatives = num_negatives
        
        # Build user -> positive games mapping from edges
        self.user_positive_games: Dict[int, set] = {}
        
        edge_index = graph_data.edge_index
        for i in range(edge_index.shape[1]):
            src = edge_index[0, i].item()
            dst = edge_index[1, i].item()
            
            # src is user (0 to num_users-1)
            # dst is game (num_users to num_users+num_games-1)
            if src < graph_data.num_users:
                user_idx = src
                game_idx = dst - graph_data.num_users
                
                if user_idx not in self.user_positive_games:
                    self.user_positive_games[user_idx] = set()
                self.user_positive_games[user_idx].add(game_idx)
        
        # Build training triplets
        self.triplets = []
        for user_idx, pos_games in self.user_positive_games.items():
            for pos_game in pos_games:
                self.triplets.append((user_idx, pos_game))
        
        self.all_games = set(range(graph_data.num_games))
    
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
            neg_game_idx = random.randint(0, self.graph_data.num_games - 1)
        else:
            neg_game_idx = random.choice(neg_candidates)
        
        return user_idx, pos_game_idx, neg_game_idx


class LightGCNTrainer:
    """Trainer for LightGCN model."""
    
    def __init__(
        self,
        graph_data: GraphData,
        device: Optional[torch.device] = None
    ):
        """Initialize trainer.
        
        Args:
            graph_data: User-game graph data
            device: PyTorch device
        """
        self.settings = get_settings()
        self.graph_data = graph_data
        
        if device is None:
            device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.device = device
        
        logger.info(f"LightGCN Trainer using device: {self.device}")
        
        # Initialize model
        self.model = LightGCN(
            num_users=graph_data.num_users,
            num_items=graph_data.num_games,
            embedding_dim=self.settings.embedding_dim,
            num_layers=self.settings.num_layers
        ).to(self.device)
        
        # Move edge data to device
        self.edge_index = graph_data.edge_index.to(self.device)
        self.edge_weight = None
        if graph_data.edge_weight is not None:
            self.edge_weight = graph_data.edge_weight.to(self.device)
        
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
        """Train the LightGCN model.
        
        Args:
            num_epochs: Number of training epochs
            batch_size: Batch size
            
        Returns:
            Training statistics
        """
        num_epochs = num_epochs or self.settings.num_epochs
        batch_size = batch_size or self.settings.batch_size
        
        logger.info(
            "Starting LightGCN training",
            num_epochs=num_epochs,
            batch_size=batch_size,
            num_users=self.graph_data.num_users,
            num_games=self.graph_data.num_games,
            num_edges=self.graph_data.num_edges
        )
        
        # Create dataset
        dataset = BPRDataset(self.graph_data)
        
        if len(dataset) == 0:
            logger.warning("No training data for LightGCN")
            return {
                "final_loss": 0.0,
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
                user_emb, item_emb = self.model(self.edge_index, self.edge_weight)
                
                # Compute BPR loss
                loss = self.model.bpr_loss(
                    user_idx, pos_game_idx, neg_game_idx,
                    user_emb, item_emb
                )
                
                # Backward
                loss.backward()
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
                    f"LightGCN Epoch {epoch + 1}/{num_epochs}",
                    loss=f"{avg_loss:.4f}",
                    best_loss=f"{best_loss:.4f}"
                )
        
        logger.info("LightGCN training completed", final_loss=f"{self.train_losses[-1]:.4f}")
        
        return {
            "final_loss": self.train_losses[-1] if self.train_losses else 0.0,
            "num_epochs": num_epochs,
            "train_losses": self.train_losses
        }
    
    def save_model(self, path: Optional[str] = None):
        """Save model checkpoint."""
        if path is None:
            path = self.settings.model_path
        
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        
        checkpoint = {
            "model_state_dict": self.model.state_dict(),
            "optimizer_state_dict": self.optimizer.state_dict(),
            "train_losses": self.train_losses,
            "num_users": self.graph_data.num_users,
            "num_games": self.graph_data.num_games,
            "embedding_dim": self.settings.embedding_dim,
            "num_layers": self.settings.num_layers,
            "user_id_to_idx": self.graph_data.user_id_to_idx,
            "game_slug_to_idx": self.graph_data.game_slug_to_idx,
        }
        
        torch.save(checkpoint, path)
        logger.info("LightGCN model saved", path=path)
    
    def load_model(self, path: Optional[str] = None) -> bool:
        """Load model checkpoint."""
        if path is None:
            path = self.settings.model_path
        
        if not os.path.exists(path):
            return False
        
        try:
            checkpoint = torch.load(path, map_location=self.device)
            self.model.load_state_dict(checkpoint["model_state_dict"])
            self.optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            self.train_losses = checkpoint.get("train_losses", [])
            
            logger.info("LightGCN model loaded", path=path)
            return True
            
        except Exception as e:
            logger.error("Failed to load LightGCN model", error=str(e))
            return False
    
    def get_inference(self) -> LightGCNInference:
        """Get inference wrapper."""
        inference = LightGCNInference(self.model, self.device)
        inference.compute_embeddings(self.edge_index, self.edge_weight)
        return inference

