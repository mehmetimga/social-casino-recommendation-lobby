"""Training pipeline for TGN (Temporal Graph Network) model."""

import os
import random
from pathlib import Path
from typing import Optional, List, Tuple
from dataclasses import dataclass
from datetime import datetime, timedelta

import torch
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
import numpy as np
import psycopg2
import structlog

from app.config import get_settings
from app.models.tgn import TGN, TGNInference, TemporalInteraction
from app.services.graph_builder import GraphData

logger = structlog.get_logger()


@dataclass
class TemporalEdge:
    """A temporal edge in the interaction graph."""
    user_idx: int
    item_idx: int
    timestamp: float
    event_type: int
    weight: float


class TemporalDataset(Dataset):
    """Dataset for temporal graph network training.
    
    Returns temporal edges in chronological order for training.
    """
    
    def __init__(
        self,
        edges: List[TemporalEdge],
        num_users: int,
        num_items: int,
        num_neighbors: int = 10
    ):
        """Initialize temporal dataset.
        
        Args:
            edges: List of temporal edges (should be sorted by timestamp)
            num_users: Number of users
            num_items: Number of items
            num_neighbors: Number of historical neighbors to sample
        """
        self.edges = edges
        self.num_users = num_users
        self.num_items = num_items
        self.num_neighbors = num_neighbors
        
        # Build user history index for fast neighbor lookup
        self.user_history: dict[int, List[Tuple[int, float]]] = {}
        for i, edge in enumerate(edges):
            if edge.user_idx not in self.user_history:
                self.user_history[edge.user_idx] = []
            self.user_history[edge.user_idx].append((edge.item_idx, edge.timestamp))
    
    def __len__(self) -> int:
        return len(self.edges)
    
    def __getitem__(self, idx: int) -> dict:
        """Get a training sample.
        
        Returns:
            Dictionary with:
            - user_idx: User index
            - pos_item_idx: Positive item index
            - neg_item_idx: Negative item index
            - timestamp: Interaction timestamp
            - event_type: Event type index
            - weight: Interaction weight
            - neighbor_items: Historical item indices
            - neighbor_times: Historical timestamps
            - neighbor_mask: Valid neighbor mask
        """
        edge = self.edges[idx]
        
        # Get historical neighbors (before this interaction)
        user_hist = self.user_history.get(edge.user_idx, [])
        
        # Filter to items before this timestamp
        past_items = [(item, t) for item, t in user_hist if t < edge.timestamp]
        
        # Take last N neighbors
        past_items = past_items[-self.num_neighbors:]
        
        # Pad to num_neighbors
        neighbor_items = [item for item, _ in past_items]
        neighbor_times = [t for _, t in past_items]
        
        n_valid = len(neighbor_items)
        neighbor_items += [0] * (self.num_neighbors - n_valid)
        neighbor_times += [0.0] * (self.num_neighbors - n_valid)
        neighbor_mask = [1] * n_valid + [0] * (self.num_neighbors - n_valid)
        
        # Sample negative item
        pos_items = set(item for item, _ in user_hist)
        neg_item = random.randint(0, self.num_items - 1)
        while neg_item in pos_items:
            neg_item = random.randint(0, self.num_items - 1)
        
        return {
            'user_idx': edge.user_idx,
            'pos_item_idx': edge.item_idx,
            'neg_item_idx': neg_item,
            'timestamp': edge.timestamp,
            'event_type': edge.event_type,
            'weight': edge.weight,
            'neighbor_items': neighbor_items,
            'neighbor_times': neighbor_times,
            'neighbor_mask': neighbor_mask
        }


def collate_temporal(batch: List[dict]) -> dict:
    """Collate function for temporal dataset."""
    return {
        'user_idx': torch.tensor([b['user_idx'] for b in batch]),
        'pos_item_idx': torch.tensor([b['pos_item_idx'] for b in batch]),
        'neg_item_idx': torch.tensor([b['neg_item_idx'] for b in batch]),
        'timestamp': torch.tensor([b['timestamp'] for b in batch], dtype=torch.float32),
        'event_type': torch.tensor([b['event_type'] for b in batch]),
        'weight': torch.tensor([b['weight'] for b in batch], dtype=torch.float32),
        'neighbor_items': torch.tensor([b['neighbor_items'] for b in batch]),
        'neighbor_times': torch.tensor([b['neighbor_times'] for b in batch], dtype=torch.float32),
        'neighbor_mask': torch.tensor([b['neighbor_mask'] for b in batch])
    }


class TemporalGraphBuilder:
    """Builds temporal edges from interaction data."""
    
    EVENT_TYPE_MAP = {
        'impression': 0,
        'click': 1,
        'game_time': 2,
        'play_end': 2,
        'play_start': 2,
        'rating': 3,
        'review': 4
    }
    
    def __init__(self):
        """Initialize builder."""
        self.settings = get_settings()
        self._conn = None
    
    def _get_connection(self):
        """Get database connection."""
        if self._conn is None or self._conn.closed:
            self._conn = psycopg2.connect(self.settings.postgres_url)
        return self._conn
    
    def close(self):
        """Close database connection."""
        if self._conn and not self._conn.closed:
            self._conn.close()
    
    def _get_event_weight(self, event_type: str, duration_seconds: Optional[int] = None) -> float:
        """Get weight for an event."""
        if event_type == 'impression':
            return self.settings.impression_weight
        elif event_type == 'click':
            return self.settings.click_weight
        elif event_type in ('game_time', 'play_end', 'play_start'):
            weight = self.settings.game_time_base_weight
            if duration_seconds and duration_seconds > 0:
                import math
                weight += math.log(duration_seconds + 1)
            return weight
        return 1.0
    
    def _get_rating_weight(self, rating: int) -> float:
        """Get weight for a rating."""
        return self.settings.rating_1_weight + (
            self.settings.rating_5_weight - self.settings.rating_1_weight
        ) * (rating - 1) / 4
    
    def build_temporal_edges(
        self,
        lookback_days: int = 30
    ) -> Tuple[List[TemporalEdge], dict, dict]:
        """Build temporal edges from database.
        
        Args:
            lookback_days: Days of history to include
            
        Returns:
            Tuple of (edges, user_id_to_idx, game_slug_to_idx)
        """
        logger.info("Building temporal edges", lookback_days=lookback_days)
        
        conn = self._get_connection()
        since = datetime.now() - timedelta(days=lookback_days)
        
        # Collect all interactions
        interactions: List[Tuple[str, str, float, str, float]] = []  # user, game, timestamp, type, weight
        
        # Process events
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, event_type, duration_seconds, 
                       EXTRACT(EPOCH FROM created_at) as timestamp
                FROM user_events
                WHERE created_at >= %s
                ORDER BY created_at
            """, (since,))
            
            for row in cur.fetchall():
                user_id, game_slug, event_type, duration_seconds, timestamp = row
                weight = self._get_event_weight(event_type, duration_seconds)
                interactions.append((user_id, game_slug, timestamp, event_type, weight))
        
        # Process ratings
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating, 
                       EXTRACT(EPOCH FROM updated_at) as timestamp
                FROM user_ratings
                ORDER BY updated_at
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating, timestamp = row
                weight = self._get_rating_weight(rating)
                if weight > 0:  # Only include positive ratings as edges
                    interactions.append((user_id, game_slug, timestamp, 'rating', weight))
        
        # Process reviews
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating, sentiment_score,
                       EXTRACT(EPOCH FROM updated_at) as timestamp
                FROM user_reviews
                ORDER BY updated_at
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating, sentiment_score, timestamp = row
                weight = self._get_rating_weight(rating)
                if sentiment_score is not None:
                    weight *= (1.0 + float(sentiment_score) * 0.5)
                if weight > 0:
                    interactions.append((user_id, game_slug, timestamp, 'review', weight))
        
        # Sort by timestamp
        interactions.sort(key=lambda x: x[2])
        
        # Build ID mappings
        users = sorted(set(i[0] for i in interactions))
        games = sorted(set(i[1] for i in interactions))
        
        user_id_to_idx = {uid: idx for idx, uid in enumerate(users)}
        game_slug_to_idx = {slug: idx for idx, slug in enumerate(games)}
        
        # Build edges
        edges = []
        for user_id, game_slug, timestamp, event_type, weight in interactions:
            edges.append(TemporalEdge(
                user_idx=user_id_to_idx[user_id],
                item_idx=game_slug_to_idx[game_slug],
                timestamp=timestamp,
                event_type=self.EVENT_TYPE_MAP.get(event_type, 0),
                weight=weight
            ))
        
        logger.info(
            "Built temporal edges",
            num_edges=len(edges),
            num_users=len(users),
            num_games=len(games)
        )
        
        return edges, user_id_to_idx, game_slug_to_idx


class TGNTrainer:
    """Trainer for TGN model."""
    
    def __init__(
        self,
        num_users: int,
        num_items: int,
        device: Optional[torch.device] = None
    ):
        """Initialize trainer.
        
        Args:
            num_users: Number of users
            num_items: Number of items
            device: PyTorch device
        """
        self.settings = get_settings()
        self.num_users = num_users
        self.num_items = num_items
        
        if device is None:
            device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.device = device
        
        logger.info(f"TGN Trainer using device: {self.device}")
        
        # Initialize model
        self.model = TGN(
            num_users=num_users,
            num_items=num_items,
            embedding_dim=self.settings.embedding_dim,
            memory_dim=self.settings.embedding_dim,
            time_dim=64,
            message_dim=256,
            num_heads=8,
            num_neighbors=10,
            dropout=0.1
        ).to(self.device)
        
        # Optimizer
        self.optimizer = optim.Adam(
            self.model.parameters(),
            lr=self.settings.learning_rate
        )
        
        # Training history
        self.train_losses: List[float] = []
    
    def train(
        self,
        edges: List[TemporalEdge],
        num_epochs: Optional[int] = None,
        batch_size: Optional[int] = None
    ) -> dict:
        """Train the TGN model.
        
        Args:
            edges: List of temporal edges (sorted by timestamp)
            num_epochs: Number of training epochs
            batch_size: Batch size
            
        Returns:
            Training statistics
        """
        num_epochs = num_epochs or self.settings.num_epochs
        batch_size = batch_size or min(self.settings.batch_size, 256)  # Smaller batches for TGN
        
        logger.info(
            "Starting TGN training",
            num_epochs=num_epochs,
            batch_size=batch_size,
            num_edges=len(edges)
        )
        
        # Create dataset and dataloader
        dataset = TemporalDataset(
            edges,
            self.num_users,
            self.num_items,
            num_neighbors=10
        )
        
        # Don't shuffle - maintain temporal order for memory updates
        dataloader = DataLoader(
            dataset,
            batch_size=batch_size,
            shuffle=False,  # Important for temporal order
            collate_fn=collate_temporal,
            num_workers=0
        )
        
        best_loss = float('inf')
        
        for epoch in range(num_epochs):
            self.model.train()
            
            # Reset memory at start of each epoch
            self.model.memory.reset_memory()
            
            total_loss = 0.0
            num_batches = 0
            
            for batch in dataloader:
                # Move to device
                user_idx = batch['user_idx'].to(self.device)
                pos_item_idx = batch['pos_item_idx'].to(self.device)
                neg_item_idx = batch['neg_item_idx'].to(self.device)
                timestamps = batch['timestamp'].to(self.device)
                event_types = batch['event_type'].to(self.device)
                weights = batch['weight'].to(self.device)
                neighbor_items = batch['neighbor_items'].to(self.device)
                neighbor_times = batch['neighbor_times'].to(self.device)
                neighbor_mask = batch['neighbor_mask'].to(self.device)
                
                # Forward pass for positive items
                self.optimizer.zero_grad()
                
                user_emb_pos, pos_emb = self.model(
                    user_idx,
                    pos_item_idx,
                    timestamps,
                    event_types,
                    weights,
                    neighbor_items,
                    neighbor_times,
                    neighbor_mask,
                    update_memory=True
                )
                
                # Get negative embeddings (no memory update)
                neg_emb = self.model.item_embedding(neg_item_idx)
                
                # Compute BPR loss
                pos_scores = self.model.predict(user_emb_pos, pos_emb)
                neg_scores = self.model.predict(user_emb_pos, neg_emb)
                
                loss = -F.logsigmoid(pos_scores - neg_scores).mean()
                
                # Backward
                loss.backward()
                
                # Gradient clipping
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), 1.0)
                
                self.optimizer.step()
                
                # Detach memory for TBPTT
                self.model.memory.detach_memory()
                
                total_loss += loss.item()
                num_batches += 1
            
            avg_loss = total_loss / max(num_batches, 1)
            self.train_losses.append(avg_loss)
            
            if avg_loss < best_loss:
                best_loss = avg_loss
            
            if (epoch + 1) % 10 == 0:
                logger.info(
                    f"TGN Epoch {epoch + 1}/{num_epochs}",
                    loss=f"{avg_loss:.4f}",
                    best_loss=f"{best_loss:.4f}"
                )
        
        logger.info("TGN training completed", final_loss=f"{self.train_losses[-1]:.4f}")
        
        return {
            "final_loss": self.train_losses[-1],
            "best_loss": best_loss,
            "num_epochs": num_epochs,
            "train_losses": self.train_losses
        }
    
    def save_model(self, path: Optional[str] = None):
        """Save model checkpoint."""
        if path is None:
            path = self.settings.model_path.replace('lightgcn', 'tgn')
        
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        
        checkpoint = {
            "model_state_dict": self.model.state_dict(),
            "optimizer_state_dict": self.optimizer.state_dict(),
            "train_losses": self.train_losses,
            "num_users": self.num_users,
            "num_items": self.num_items,
            "embedding_dim": self.settings.embedding_dim
        }
        
        torch.save(checkpoint, path)
        logger.info("TGN model saved", path=path)
    
    def load_model(self, path: Optional[str] = None) -> bool:
        """Load model checkpoint."""
        if path is None:
            path = self.settings.model_path.replace('lightgcn', 'tgn')
        
        if not os.path.exists(path):
            return False
        
        try:
            checkpoint = torch.load(path, map_location=self.device)
            
            if (checkpoint["num_users"] != self.num_users or
                checkpoint["num_items"] != self.num_items):
                logger.warning("Model dimensions don't match, cannot load")
                return False
            
            self.model.load_state_dict(checkpoint["model_state_dict"])
            self.optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            self.train_losses = checkpoint.get("train_losses", [])
            
            logger.info("TGN model loaded", path=path)
            return True
            
        except Exception as e:
            logger.error("Failed to load TGN model", error=str(e))
            return False
    
    def get_inference(self) -> TGNInference:
        """Get inference wrapper."""
        return TGNInference(self.model, self.device)

