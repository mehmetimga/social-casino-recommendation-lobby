"""Graph builder service for constructing user-game bipartite graphs.

Builds the interaction graph from PostgreSQL user events, ratings, and reviews
with proper weighting and time decay.
"""

import math
import asyncio
from datetime import datetime, timedelta
from typing import Optional, Any
from dataclasses import dataclass, field

import numpy as np
import torch
import psycopg2
import asyncpg
import structlog

from app.config import get_settings

logger = structlog.get_logger()


@dataclass
class GraphData:
    """Container for graph data."""
    
    # Mappings
    user_id_to_idx: dict[str, int] = field(default_factory=dict)
    idx_to_user_id: dict[int, str] = field(default_factory=dict)
    game_slug_to_idx: dict[str, int] = field(default_factory=dict)
    idx_to_game_slug: dict[int, str] = field(default_factory=dict)
    
    # Graph tensors
    edge_index: Optional[torch.Tensor] = None  # [2, num_edges]
    edge_weight: Optional[torch.Tensor] = None  # [num_edges]
    
    # Counts
    num_users: int = 0
    num_games: int = 0
    num_edges: int = 0
    
    def get_user_idx(self, user_id: str) -> Optional[int]:
        """Get user index from user ID."""
        return self.user_id_to_idx.get(user_id)
    
    def get_game_idx(self, game_slug: str) -> Optional[int]:
        """Get game index from game slug."""
        return self.game_slug_to_idx.get(game_slug)


class GraphBuilder:
    """Builds user-game bipartite graphs from interaction data."""
    
    def __init__(self):
        """Initialize graph builder with settings."""
        self.settings = get_settings()
        self._conn: Optional[Any] = None
    
    def _get_connection(self) -> Any:
        """Get or create database connection."""
        if self._conn is None or self._conn.closed:
            self._conn = psycopg2.connect(self.settings.postgres_url)
        return self._conn
    
    def close(self):
        """Close database connection."""
        if self._conn and not self._conn.closed:
            self._conn.close()
    
    def _calculate_event_weight(
        self,
        event_type: str,
        duration_seconds: Optional[int] = None
    ) -> float:
        """Calculate weight for an event type.
        
        Matches the Go service weighting logic.
        """
        if event_type == "impression":
            return self.settings.impression_weight
        elif event_type == "click":
            return self.settings.click_weight
        elif event_type in ("game_time", "play_end"):
            weight = self.settings.game_time_base_weight
            if duration_seconds and duration_seconds > 0:
                # Add log bonus for duration
                weight += math.log(duration_seconds + 1)
            return weight
        elif event_type == "play_start":
            return self.settings.game_time_base_weight
        return 0.0
    
    def _calculate_rating_weight(self, rating: int) -> float:
        """Calculate weight for a rating (1-5 stars).
        
        Linear interpolation from rating 1 (-6) to rating 5 (+8)
        """
        return self.settings.rating_1_weight + (
            self.settings.rating_5_weight - self.settings.rating_1_weight
        ) * (rating - 1) / 4
    
    def _calculate_time_decay(
        self,
        event_time: datetime,
        half_life_days: int
    ) -> float:
        """Calculate time decay factor.
        
        Uses exponential decay with the given half-life.
        """
        now = datetime.now(event_time.tzinfo) if event_time.tzinfo else datetime.now()
        days_since = (now - event_time).total_seconds() / 86400
        return math.pow(0.5, days_since / half_life_days)
    
    def build_graph(self, lookback_days: int = 30) -> GraphData:
        """Build bipartite graph from interaction data.
        
        Args:
            lookback_days: Number of days of history to include
            
        Returns:
            GraphData with edge index and weights
        """
        logger.info("Building interaction graph", lookback_days=lookback_days)
        
        conn = self._get_connection()
        since = datetime.now() - timedelta(days=lookback_days)
        
        # Collect all interactions with weights
        interactions: dict[tuple[str, str], float] = {}
        
        # Process events
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, event_type, duration_seconds, created_at
                FROM user_events
                WHERE created_at >= %s
            """, (since,))
            
            for row in cur.fetchall():
                user_id, game_slug, event_type, duration_seconds, created_at = row
                
                weight = self._calculate_event_weight(event_type, duration_seconds)
                decay = self._calculate_time_decay(
                    created_at, 
                    self.settings.behavior_half_life_days
                )
                
                key = (user_id, game_slug)
                if key not in interactions:
                    interactions[key] = 0.0
                interactions[key] += weight * decay
        
        # Track games with reviews (to avoid double counting)
        reviewed_games: set[tuple[str, str]] = set()
        
        # Process reviews (includes sentiment)
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating, sentiment_score, updated_at
                FROM user_reviews
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating, sentiment_score, updated_at = row
                
                weight = self._calculate_rating_weight(rating)
                
                # Apply sentiment multiplier if available
                if sentiment_score is not None:
                    sentiment_multiplier = 1.0 + (float(sentiment_score) * 0.5)
                    weight *= sentiment_multiplier
                
                decay = self._calculate_time_decay(
                    updated_at,
                    self.settings.rating_half_life_days
                )
                
                key = (user_id, game_slug)
                reviewed_games.add(key)
                
                if key not in interactions:
                    interactions[key] = 0.0
                interactions[key] += weight * decay
        
        # Process ratings (only for games without reviews)
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating, updated_at
                FROM user_ratings
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating, updated_at = row
                
                key = (user_id, game_slug)
                if key in reviewed_games:
                    continue  # Skip, already processed in reviews
                
                weight = self._calculate_rating_weight(rating)
                decay = self._calculate_time_decay(
                    updated_at,
                    self.settings.rating_half_life_days
                )
                
                if key not in interactions:
                    interactions[key] = 0.0
                interactions[key] += weight * decay
        
        # Build graph data
        graph_data = GraphData()
        
        # Filter out negative weights (disliked items shouldn't create positive edges)
        positive_interactions = {
            k: v for k, v in interactions.items() if v > 0
        }
        
        if not positive_interactions:
            logger.warning("No positive interactions found")
            return graph_data
        
        # Build ID mappings
        users = sorted(set(k[0] for k in positive_interactions.keys()))
        games = sorted(set(k[1] for k in positive_interactions.keys()))
        
        graph_data.user_id_to_idx = {uid: idx for idx, uid in enumerate(users)}
        graph_data.idx_to_user_id = {idx: uid for uid, idx in graph_data.user_id_to_idx.items()}
        graph_data.game_slug_to_idx = {slug: idx for idx, slug in enumerate(games)}
        graph_data.idx_to_game_slug = {idx: slug for slug, idx in graph_data.game_slug_to_idx.items()}
        
        graph_data.num_users = len(users)
        graph_data.num_games = len(games)
        
        # Build edge tensors
        # For bipartite graph: users are nodes 0 to num_users-1
        # items are nodes num_users to num_users+num_items-1
        src_nodes = []  # User indices
        dst_nodes = []  # Game indices (offset by num_users)
        weights = []
        
        for (user_id, game_slug), weight in positive_interactions.items():
            user_idx = graph_data.user_id_to_idx[user_id]
            game_idx = graph_data.game_slug_to_idx[game_slug]
            
            # Add edges in both directions (user->game and game->user)
            # User to game
            src_nodes.append(user_idx)
            dst_nodes.append(graph_data.num_users + game_idx)
            weights.append(weight)
            
            # Game to user (reverse edge for GCN)
            src_nodes.append(graph_data.num_users + game_idx)
            dst_nodes.append(user_idx)
            weights.append(weight)
        
        graph_data.edge_index = torch.tensor([src_nodes, dst_nodes], dtype=torch.long)
        graph_data.edge_weight = torch.tensor(weights, dtype=torch.float32)
        graph_data.num_edges = len(weights)
        
        logger.info(
            "Graph built successfully",
            num_users=graph_data.num_users,
            num_games=graph_data.num_games,
            num_edges=graph_data.num_edges
        )
        
        return graph_data
    
    def add_interaction(
        self,
        graph_data: GraphData,
        user_id: str,
        game_slug: str,
        weight: float
    ) -> GraphData:
        """Add a new interaction to an existing graph.
        
        For real-time updates. Creates new user/game nodes if needed.
        
        Args:
            graph_data: Existing graph data
            user_id: User ID
            game_slug: Game slug
            weight: Interaction weight
            
        Returns:
            Updated GraphData (may be a new object if structure changed)
        """
        if weight <= 0:
            return graph_data  # Don't add negative edges
        
        # Check if we need to add new nodes
        user_is_new = user_id not in graph_data.user_id_to_idx
        game_is_new = game_slug not in graph_data.game_slug_to_idx
        
        if user_is_new or game_is_new:
            # Need to rebuild graph with new nodes
            # For now, just log and return (full rebuild needed)
            logger.info(
                "New node detected, graph rebuild needed",
                user_is_new=user_is_new,
                game_is_new=game_is_new
            )
            return graph_data
        
        user_idx = graph_data.user_id_to_idx[user_id]
        game_idx = graph_data.game_slug_to_idx[game_slug]
        game_node_idx = graph_data.num_users + game_idx
        
        # Add new edges
        new_src = torch.tensor([user_idx, game_node_idx], dtype=torch.long)
        new_dst = torch.tensor([game_node_idx, user_idx], dtype=torch.long)
        new_weights = torch.tensor([weight, weight], dtype=torch.float32)
        
        graph_data.edge_index = torch.cat([
            graph_data.edge_index,
            torch.stack([new_src, new_dst])
        ], dim=1)
        
        graph_data.edge_weight = torch.cat([
            graph_data.edge_weight,
            new_weights
        ])
        
        graph_data.num_edges += 2
        
        return graph_data


class AsyncGraphBuilder:
    """Async version of graph builder using asyncpg."""
    
    def __init__(self):
        """Initialize async graph builder."""
        self.settings = get_settings()
        self._pool: Optional[asyncpg.Pool] = None
    
    async def _get_pool(self) -> asyncpg.Pool:
        """Get or create connection pool."""
        if self._pool is None:
            self._pool = await asyncpg.create_pool(
                self.settings.postgres_url,
                min_size=2,
                max_size=10
            )
        return self._pool
    
    async def close(self):
        """Close connection pool."""
        if self._pool:
            await self._pool.close()
    
    async def build_graph(self, lookback_days: int = 30) -> GraphData:
        """Build graph asynchronously.
        
        Uses sync version for now as asyncpg integration is more complex.
        """
        # Run sync version in executor
        loop = asyncio.get_event_loop()
        sync_builder = GraphBuilder()
        try:
            return await loop.run_in_executor(
                None,
                sync_builder.build_graph,
                lookback_days
            )
        finally:
            sync_builder.close()

