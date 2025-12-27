"""Temporal Graph Network (TGN) model for session-aware recommendations.

TGN handles dynamic graphs with temporal evolution, maintaining a memory module
that tracks evolving user states over time. This enables:
- Session-aware recommendations ("user just played 3 slots")
- Temporal pattern learning ("user prefers slots in evening")
- Real-time embedding updates

Paper: https://arxiv.org/abs/2006.10637
"""

import math
from typing import Optional, Tuple, Dict, List
from dataclasses import dataclass, field
from datetime import datetime

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np


@dataclass
class TemporalInteraction:
    """Represents a timestamped interaction."""
    user_id: str
    game_slug: str
    timestamp: float  # Unix timestamp
    event_type: str
    weight: float
    user_idx: int = 0
    game_idx: int = 0


class TimeEncoder(nn.Module):
    """Encodes time deltas using learnable Fourier features.
    
    Converts time deltas into a fixed-size embedding that captures
    temporal patterns at multiple scales (seconds, minutes, hours, days).
    """
    
    def __init__(self, time_dim: int = 64):
        """Initialize time encoder.
        
        Args:
            time_dim: Dimension of time encoding (should be even)
        """
        super().__init__()
        self.time_dim = time_dim
        
        # Learnable frequency parameters
        self.w = nn.Linear(1, time_dim)
        
        # Initialize with different frequencies for multi-scale patterns
        nn.init.xavier_uniform_(self.w.weight)
    
    def forward(self, time_deltas: torch.Tensor) -> torch.Tensor:
        """Encode time deltas.
        
        Args:
            time_deltas: Time differences in seconds [batch_size] or [batch_size, 1]
            
        Returns:
            Time encodings [batch_size, time_dim]
        """
        if time_deltas.dim() == 1:
            time_deltas = time_deltas.unsqueeze(-1)
        
        # Scale time to reasonable range (log scale for large differences)
        # Add 1 to avoid log(0)
        time_scaled = torch.log(time_deltas.abs() + 1)
        
        # Linear projection then sine/cosine
        projected = self.w(time_scaled)
        
        # Split into sin and cos components
        half_dim = self.time_dim // 2
        sin_enc = torch.sin(projected[:, :half_dim])
        cos_enc = torch.cos(projected[:, half_dim:])
        
        return torch.cat([sin_enc, cos_enc], dim=-1)


class MemoryModule(nn.Module):
    """Memory module that stores and updates user state vectors.
    
    Each user has a memory vector that evolves based on their interactions.
    The memory captures:
    - Long-term preferences
    - Recent session context
    - Temporal patterns
    """
    
    def __init__(
        self,
        num_users: int,
        memory_dim: int = 768,
        message_dim: int = 256
    ):
        """Initialize memory module.
        
        Args:
            num_users: Maximum number of users
            memory_dim: Dimension of memory vectors
            message_dim: Dimension of messages
        """
        super().__init__()
        
        self.num_users = num_users
        self.memory_dim = memory_dim
        self.message_dim = message_dim
        
        # Memory vectors (not learnable, updated via GRU)
        self.register_buffer(
            'memory',
            torch.zeros(num_users, memory_dim)
        )
        
        # Last update timestamps
        self.register_buffer(
            'last_update',
            torch.zeros(num_users)
        )
        
        # GRU for memory updates
        self.memory_updater = nn.GRUCell(message_dim, memory_dim)
        
        # Message MLP
        self.message_mlp = nn.Sequential(
            nn.Linear(memory_dim * 2 + message_dim, message_dim),
            nn.ReLU(),
            nn.Linear(message_dim, message_dim)
        )
    
    def get_memory(self, user_indices: torch.Tensor) -> torch.Tensor:
        """Get memory vectors for users.
        
        Args:
            user_indices: User indices [batch_size]
            
        Returns:
            Memory vectors [batch_size, memory_dim]
        """
        return self.memory[user_indices]
    
    def compute_message(
        self,
        user_memory: torch.Tensor,
        item_embedding: torch.Tensor,
        interaction_features: torch.Tensor
    ) -> torch.Tensor:
        """Compute message from an interaction.
        
        Args:
            user_memory: Current user memory [batch_size, memory_dim]
            item_embedding: Item (game) embedding [batch_size, memory_dim]
            interaction_features: Interaction features [batch_size, feature_dim]
            
        Returns:
            Message vectors [batch_size, message_dim]
        """
        # Concatenate all information
        combined = torch.cat([
            user_memory,
            item_embedding,
            interaction_features
        ], dim=-1)
        
        return self.message_mlp(combined)
    
    def update_memory(
        self,
        user_indices: torch.Tensor,
        messages: torch.Tensor,
        timestamps: torch.Tensor
    ):
        """Update memory vectors for users.
        
        Args:
            user_indices: User indices [batch_size]
            messages: Message vectors [batch_size, message_dim]
            timestamps: Interaction timestamps [batch_size]
        """
        # Get current memory
        current_memory = self.memory[user_indices]
        
        # Update via GRU
        new_memory = self.memory_updater(messages, current_memory)
        
        # Store updated memory
        self.memory[user_indices] = new_memory.detach()
        self.last_update[user_indices] = timestamps.detach()
    
    def reset_memory(self, user_indices: Optional[torch.Tensor] = None):
        """Reset memory for users or all users.
        
        Args:
            user_indices: Optional user indices to reset. If None, reset all.
        """
        if user_indices is None:
            self.memory.zero_()
            self.last_update.zero_()
        else:
            self.memory[user_indices] = 0
            self.last_update[user_indices] = 0
    
    def detach_memory(self):
        """Detach memory from computation graph (for TBPTT)."""
        self.memory = self.memory.detach()


class TemporalAttention(nn.Module):
    """Temporal attention layer for aggregating neighbor messages.
    
    Uses multi-head attention with temporal encoding to weight
    the importance of different historical interactions.
    """
    
    def __init__(
        self,
        embed_dim: int = 768,
        num_heads: int = 8,
        time_dim: int = 64,
        dropout: float = 0.1
    ):
        """Initialize temporal attention.
        
        Args:
            embed_dim: Embedding dimension
            num_heads: Number of attention heads
            time_dim: Time encoding dimension
            dropout: Dropout probability
        """
        super().__init__()
        
        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads
        
        assert embed_dim % num_heads == 0, "embed_dim must be divisible by num_heads"
        
        # Time encoder
        self.time_encoder = TimeEncoder(time_dim)
        
        # Query, Key, Value projections (include time encoding)
        self.q_proj = nn.Linear(embed_dim, embed_dim)
        self.k_proj = nn.Linear(embed_dim + time_dim, embed_dim)
        self.v_proj = nn.Linear(embed_dim + time_dim, embed_dim)
        self.out_proj = nn.Linear(embed_dim, embed_dim)
        
        self.dropout = nn.Dropout(dropout)
        self.scale = math.sqrt(self.head_dim)
    
    def forward(
        self,
        query: torch.Tensor,
        keys: torch.Tensor,
        values: torch.Tensor,
        time_deltas: torch.Tensor,
        mask: Optional[torch.Tensor] = None
    ) -> torch.Tensor:
        """Compute temporal attention.
        
        Args:
            query: Query vectors [batch_size, embed_dim]
            keys: Key vectors [batch_size, seq_len, embed_dim]
            values: Value vectors [batch_size, seq_len, embed_dim]
            time_deltas: Time differences [batch_size, seq_len]
            mask: Optional attention mask [batch_size, seq_len]
            
        Returns:
            Attention output [batch_size, embed_dim]
        """
        batch_size, seq_len, _ = keys.shape
        
        # Encode time deltas
        time_enc = self.time_encoder(time_deltas.view(-1)).view(batch_size, seq_len, -1)
        
        # Add time encoding to keys and values
        keys_with_time = torch.cat([keys, time_enc], dim=-1)
        values_with_time = torch.cat([values, time_enc], dim=-1)
        
        # Project query, keys, values
        q = self.q_proj(query).view(batch_size, 1, self.num_heads, self.head_dim)
        k = self.k_proj(keys_with_time).view(batch_size, seq_len, self.num_heads, self.head_dim)
        v = self.v_proj(values_with_time).view(batch_size, seq_len, self.num_heads, self.head_dim)
        
        # Transpose for attention: [batch, heads, seq, dim]
        q = q.transpose(1, 2)  # [batch, heads, 1, dim]
        k = k.transpose(1, 2)  # [batch, heads, seq, dim]
        v = v.transpose(1, 2)  # [batch, heads, seq, dim]
        
        # Compute attention scores
        attn_scores = torch.matmul(q, k.transpose(-2, -1)) / self.scale  # [batch, heads, 1, seq]
        
        # Apply mask if provided
        if mask is not None:
            attn_scores = attn_scores.masked_fill(
                mask.unsqueeze(1).unsqueeze(2) == 0,
                float('-inf')
            )
        
        # Softmax and dropout
        attn_weights = F.softmax(attn_scores, dim=-1)
        attn_weights = self.dropout(attn_weights)
        
        # Apply attention to values
        attn_output = torch.matmul(attn_weights, v)  # [batch, heads, 1, dim]
        
        # Reshape and project
        attn_output = attn_output.transpose(1, 2).contiguous().view(batch_size, -1)
        output = self.out_proj(attn_output)
        
        return output


class TGN(nn.Module):
    """Temporal Graph Network for session-aware recommendations.
    
    Combines:
    - Memory module for user state
    - Time encoding for temporal patterns
    - Temporal attention for aggregating history
    - Graph neural network for structure
    """
    
    def __init__(
        self,
        num_users: int,
        num_items: int,
        embedding_dim: int = 768,
        memory_dim: int = 768,
        time_dim: int = 64,
        message_dim: int = 256,
        num_heads: int = 8,
        num_neighbors: int = 10,
        dropout: float = 0.1
    ):
        """Initialize TGN.
        
        Args:
            num_users: Number of users
            num_items: Number of items (games)
            embedding_dim: Dimension of embeddings
            memory_dim: Dimension of memory vectors
            time_dim: Dimension of time encoding
            message_dim: Dimension of messages
            num_heads: Number of attention heads
            num_neighbors: Number of neighbors to sample
            dropout: Dropout probability
        """
        super().__init__()
        
        self.num_users = num_users
        self.num_items = num_items
        self.embedding_dim = embedding_dim
        self.num_neighbors = num_neighbors
        
        # Base embeddings
        self.user_embedding = nn.Embedding(num_users, embedding_dim)
        self.item_embedding = nn.Embedding(num_items, embedding_dim)
        
        # Event type embedding
        self.event_embedding = nn.Embedding(5, message_dim // 4)  # impression, click, game_time, rating, review
        
        # Memory module
        self.memory = MemoryModule(num_users, memory_dim, message_dim)
        
        # Time encoder
        self.time_encoder = TimeEncoder(time_dim)
        
        # Temporal attention
        self.temporal_attention = TemporalAttention(
            embedding_dim, num_heads, time_dim, dropout
        )
        
        # Interaction feature encoder
        self.interaction_encoder = nn.Sequential(
            nn.Linear(message_dim // 4 + 1 + time_dim, message_dim),  # event_type + weight + time
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(message_dim, message_dim)
        )
        
        # Embedding combiner
        self.embedding_combiner = nn.Sequential(
            nn.Linear(embedding_dim + memory_dim, embedding_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(embedding_dim, embedding_dim)
        )
        
        # Initialize
        self._init_weights()
    
    def _init_weights(self):
        """Initialize embeddings."""
        nn.init.xavier_uniform_(self.user_embedding.weight)
        nn.init.xavier_uniform_(self.item_embedding.weight)
    
    def encode_interaction(
        self,
        event_types: torch.Tensor,
        weights: torch.Tensor,
        time_deltas: torch.Tensor
    ) -> torch.Tensor:
        """Encode interaction features.
        
        Args:
            event_types: Event type indices [batch_size]
            weights: Interaction weights [batch_size]
            time_deltas: Time since last interaction [batch_size]
            
        Returns:
            Interaction features [batch_size, message_dim]
        """
        # Get event embeddings
        event_emb = self.event_embedding(event_types)
        
        # Get time encoding
        time_enc = self.time_encoder(time_deltas)
        
        # Combine all features
        features = torch.cat([
            event_emb,
            weights.unsqueeze(-1),
            time_enc
        ], dim=-1)
        
        return self.interaction_encoder(features)
    
    def compute_temporal_embedding(
        self,
        user_indices: torch.Tensor,
        neighbor_items: torch.Tensor,
        neighbor_times: torch.Tensor,
        current_time: torch.Tensor,
        neighbor_mask: Optional[torch.Tensor] = None
    ) -> torch.Tensor:
        """Compute time-aware user embedding using temporal attention.
        
        Args:
            user_indices: User indices [batch_size]
            neighbor_items: Historical item indices [batch_size, num_neighbors]
            neighbor_times: Historical timestamps [batch_size, num_neighbors]
            current_time: Current timestamp [batch_size]
            neighbor_mask: Mask for valid neighbors [batch_size, num_neighbors]
            
        Returns:
            Temporal user embeddings [batch_size, embedding_dim]
        """
        batch_size = user_indices.shape[0]
        
        # Get base embeddings
        user_emb = self.user_embedding(user_indices)  # [batch, embed_dim]
        neighbor_emb = self.item_embedding(neighbor_items)  # [batch, neighbors, embed_dim]
        
        # Compute time deltas
        time_deltas = current_time.unsqueeze(-1) - neighbor_times  # [batch, neighbors]
        
        # Get memory
        memory = self.memory.get_memory(user_indices)  # [batch, memory_dim]
        
        # Apply temporal attention over neighbors
        context = self.temporal_attention(
            user_emb,
            neighbor_emb,
            neighbor_emb,
            time_deltas,
            neighbor_mask
        )
        
        # Combine base embedding with memory and context
        combined = torch.cat([context, memory], dim=-1)
        temporal_emb = self.embedding_combiner(combined)
        
        return temporal_emb
    
    def forward(
        self,
        user_indices: torch.Tensor,
        item_indices: torch.Tensor,
        timestamps: torch.Tensor,
        event_types: torch.Tensor,
        weights: torch.Tensor,
        neighbor_items: Optional[torch.Tensor] = None,
        neighbor_times: Optional[torch.Tensor] = None,
        neighbor_mask: Optional[torch.Tensor] = None,
        update_memory: bool = True
    ) -> Tuple[torch.Tensor, torch.Tensor]:
        """Forward pass for training.
        
        Args:
            user_indices: User indices [batch_size]
            item_indices: Item indices [batch_size]
            timestamps: Interaction timestamps [batch_size]
            event_types: Event type indices [batch_size]
            weights: Interaction weights [batch_size]
            neighbor_items: Historical items [batch_size, num_neighbors]
            neighbor_times: Historical timestamps [batch_size, num_neighbors]
            neighbor_mask: Valid neighbor mask [batch_size, num_neighbors]
            update_memory: Whether to update memory after forward
            
        Returns:
            Tuple of (user_embeddings, item_embeddings)
        """
        # Get base embeddings
        item_emb = self.item_embedding(item_indices)
        
        # Compute temporal user embedding if neighbors provided
        if neighbor_items is not None:
            user_emb = self.compute_temporal_embedding(
                user_indices,
                neighbor_items,
                neighbor_times,
                timestamps,
                neighbor_mask
            )
        else:
            # Fall back to memory-augmented embedding
            base_emb = self.user_embedding(user_indices)
            memory = self.memory.get_memory(user_indices)
            combined = torch.cat([base_emb, memory], dim=-1)
            user_emb = self.embedding_combiner(combined)
        
        # Update memory if training
        if update_memory:
            # Compute time deltas from last update
            last_update = self.memory.last_update[user_indices]
            time_deltas = timestamps - last_update
            
            # Encode interaction features
            interaction_features = self.encode_interaction(
                event_types, weights, time_deltas
            )
            
            # Compute message
            messages = self.memory.compute_message(
                self.memory.get_memory(user_indices),
                item_emb,
                interaction_features
            )
            
            # Update memory
            self.memory.update_memory(user_indices, messages, timestamps)
        
        return user_emb, item_emb
    
    def predict(
        self,
        user_emb: torch.Tensor,
        item_emb: torch.Tensor
    ) -> torch.Tensor:
        """Predict interaction scores.
        
        Args:
            user_emb: User embeddings [batch_size, embed_dim]
            item_emb: Item embeddings [batch_size, embed_dim] or [num_items, embed_dim]
            
        Returns:
            Scores [batch_size] or [batch_size, num_items]
        """
        if item_emb.dim() == 2 and item_emb.shape[0] == self.num_items:
            # Score against all items
            return torch.matmul(user_emb, item_emb.t())
        else:
            # Score specific items
            return (user_emb * item_emb).sum(dim=-1)
    
    def get_user_embedding(
        self,
        user_idx: int,
        current_time: float,
        recent_items: Optional[List[int]] = None,
        recent_times: Optional[List[float]] = None
    ) -> torch.Tensor:
        """Get embedding for a single user at a specific time.
        
        Args:
            user_idx: User index
            current_time: Current timestamp
            recent_items: List of recent item indices
            recent_times: List of recent timestamps
            
        Returns:
            User embedding [embedding_dim]
        """
        device = self.user_embedding.weight.device
        
        user_indices = torch.tensor([user_idx], device=device)
        timestamps = torch.tensor([current_time], device=device)
        
        if recent_items and recent_times:
            # Pad or truncate to num_neighbors
            n = min(len(recent_items), self.num_neighbors)
            padded_items = recent_items[-n:] + [0] * (self.num_neighbors - n)
            padded_times = recent_times[-n:] + [0.0] * (self.num_neighbors - n)
            
            neighbor_items = torch.tensor([padded_items], device=device)
            neighbor_times = torch.tensor([padded_times], device=device)
            neighbor_mask = torch.tensor([[1] * n + [0] * (self.num_neighbors - n)], device=device)
            
            emb = self.compute_temporal_embedding(
                user_indices,
                neighbor_items,
                neighbor_times,
                timestamps,
                neighbor_mask
            )
        else:
            # Use memory-augmented embedding
            base_emb = self.user_embedding(user_indices)
            memory = self.memory.get_memory(user_indices)
            combined = torch.cat([base_emb, memory], dim=-1)
            emb = self.embedding_combiner(combined)
        
        return emb.squeeze(0)
    
    def get_all_item_embeddings(self) -> torch.Tensor:
        """Get all item embeddings.
        
        Returns:
            Item embeddings [num_items, embedding_dim]
        """
        return self.item_embedding.weight


class TGNInference:
    """Inference wrapper for TGN with session tracking."""
    
    def __init__(self, model: TGN, device: torch.device):
        """Initialize inference wrapper.
        
        Args:
            model: Trained TGN model
            device: PyTorch device
        """
        self.model = model
        self.device = device
        self.model.eval()
        
        # Session tracking: user_id -> list of (item_idx, timestamp, weight)
        self.sessions: Dict[str, List[Tuple[int, float, float]]] = {}
    
    def start_session(self, user_id: str):
        """Start a new session for a user."""
        self.sessions[user_id] = []
    
    def add_interaction(
        self,
        user_id: str,
        user_idx: int,
        item_idx: int,
        timestamp: float,
        event_type: int,
        weight: float
    ):
        """Add an interaction to the session.
        
        Args:
            user_id: User ID string
            user_idx: User index
            item_idx: Item index
            timestamp: Unix timestamp
            event_type: Event type index
            weight: Interaction weight
        """
        if user_id not in self.sessions:
            self.sessions[user_id] = []
        
        self.sessions[user_id].append((item_idx, timestamp, weight))
        
        # Keep only last N interactions
        max_history = self.model.num_neighbors * 2
        if len(self.sessions[user_id]) > max_history:
            self.sessions[user_id] = self.sessions[user_id][-max_history:]
        
        # Update memory
        with torch.no_grad():
            user_indices = torch.tensor([user_idx], device=self.device)
            item_indices = torch.tensor([item_idx], device=self.device)
            timestamps_t = torch.tensor([timestamp], device=self.device)
            event_types_t = torch.tensor([event_type], device=self.device)
            weights_t = torch.tensor([weight], device=self.device)
            
            self.model(
                user_indices,
                item_indices,
                timestamps_t,
                event_types_t,
                weights_t,
                update_memory=True
            )
    
    def get_recommendations(
        self,
        user_id: str,
        user_idx: int,
        current_time: float,
        top_k: int = 10,
        exclude_items: Optional[set] = None
    ) -> List[Tuple[int, float]]:
        """Get session-aware recommendations.
        
        Args:
            user_id: User ID string
            user_idx: User index
            current_time: Current timestamp
            top_k: Number of recommendations
            exclude_items: Items to exclude
            
        Returns:
            List of (item_idx, score) tuples
        """
        with torch.no_grad():
            # Get session history
            session = self.sessions.get(user_id, [])
            
            if session:
                recent_items = [s[0] for s in session]
                recent_times = [s[1] for s in session]
            else:
                recent_items = None
                recent_times = None
            
            # Get user embedding
            user_emb = self.model.get_user_embedding(
                user_idx,
                current_time,
                recent_items,
                recent_times
            )
            
            # Get all item embeddings
            item_embs = self.model.get_all_item_embeddings()
            
            # Compute scores
            scores = torch.matmul(user_emb, item_embs.t())
            
            # Mask excluded items
            if exclude_items:
                for idx in exclude_items:
                    if idx < len(scores):
                        scores[idx] = float('-inf')
            
            # Get top-K
            top_scores, top_indices = torch.topk(scores, min(top_k, len(scores)))
            
            return [
                (idx.item(), score.item())
                for idx, score in zip(top_indices, top_scores)
            ]
    
    def clear_session(self, user_id: str):
        """Clear session for a user."""
        if user_id in self.sessions:
            del self.sessions[user_id]

