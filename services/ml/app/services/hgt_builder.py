"""Heterogeneous graph builder for HGT.

Constructs a heterogeneous graph from multiple data sources:
- PostgreSQL: User interactions (events, ratings, reviews)
- CMS: Games, providers, badges, promotions

The graph includes:
- Node types: users, games, providers, promotions, devices, badges
- Edge types: played, rated, made_by, features, uses, has_badge
"""

import math
import json
from datetime import datetime, timedelta
from typing import Optional, Dict, List, Tuple, Any
from dataclasses import dataclass

import torch
import psycopg2
import httpx
import structlog

from app.config import get_settings
from app.models.hgt import (
    NodeType, EdgeType, HeteroEdge, HeteroGraphData
)

logger = structlog.get_logger()


class HeteroGraphBuilder:
    """Builds heterogeneous graphs from PostgreSQL and CMS data."""
    
    def __init__(self, cms_url: Optional[str] = None):
        """Initialize builder.
        
        Args:
            cms_url: CMS API URL (defaults to config)
        """
        self.settings = get_settings()
        self.cms_url = cms_url or "http://cms:3001"
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
        """Calculate event weight."""
        if event_type == 'impression':
            return self.settings.impression_weight
        elif event_type == 'click':
            return self.settings.click_weight
        elif event_type in ('game_time', 'play_end', 'play_start'):
            weight = self.settings.game_time_base_weight
            if duration_seconds and duration_seconds > 0:
                weight += math.log(duration_seconds + 1)
            return weight
        return 1.0
    
    def _get_rating_weight(self, rating: int) -> float:
        """Calculate rating weight."""
        return self.settings.rating_1_weight + (
            self.settings.rating_5_weight - self.settings.rating_1_weight
        ) * (rating - 1) / 4
    
    def _fetch_cms_data(self) -> Dict[str, Any]:
        """Fetch games, providers, badges from CMS.
        
        Returns:
            Dictionary with games, providers, badges data
        """
        try:
            with httpx.Client(timeout=30.0) as client:
                # Fetch games
                games_resp = client.get(f"{self.cms_url}/api/games?limit=1000&depth=2")
                games_data = games_resp.json() if games_resp.status_code == 200 else {"docs": []}
                
                # Fetch promotions (if available)
                try:
                    promos_resp = client.get(f"{self.cms_url}/api/promotions?limit=100")
                    promos_data = promos_resp.json() if promos_resp.status_code == 200 else {"docs": []}
                except:
                    promos_data = {"docs": []}
                
                return {
                    "games": games_data.get("docs", []),
                    "promotions": promos_data.get("docs", [])
                }
                
        except Exception as e:
            logger.warning("Failed to fetch CMS data", error=str(e))
            return {"games": [], "promotions": []}
    
    def build_graph(self, lookback_days: int = 30) -> HeteroGraphData:
        """Build heterogeneous graph from all data sources.
        
        Args:
            lookback_days: Days of interaction history to include
            
        Returns:
            HeteroGraphData with all nodes and edges
        """
        logger.info("Building heterogeneous graph", lookback_days=lookback_days)
        
        graph = HeteroGraphData()
        conn = self._get_connection()
        since = datetime.now() - timedelta(days=lookback_days)
        
        # ============================================
        # Collect nodes from CMS
        # ============================================
        cms_data = self._fetch_cms_data()
        
        # Process games
        providers = set()
        badges = set()
        game_providers: Dict[str, str] = {}  # game_slug -> provider
        game_badges: Dict[str, List[str]] = {}  # game_slug -> badges
        
        for game in cms_data["games"]:
            slug = game.get("slug")
            if not slug:
                continue
            
            if slug not in graph.game_slug_to_idx:
                idx = len(graph.game_slug_to_idx)
                graph.game_slug_to_idx[slug] = idx
                graph.idx_to_game_slug[idx] = slug
            
            # Extract provider
            provider = game.get("provider")
            if provider:
                provider_name = provider.get("name") if isinstance(provider, dict) else str(provider)
                if provider_name:
                    providers.add(provider_name)
                    game_providers[slug] = provider_name
            
            # Extract badges
            game_badge_list = game.get("badges", [])
            if game_badge_list:
                badge_names = []
                for badge in game_badge_list:
                    badge_name = badge.get("name") if isinstance(badge, dict) else str(badge)
                    if badge_name:
                        badges.add(badge_name)
                        badge_names.append(badge_name)
                if badge_names:
                    game_badges[slug] = badge_names
        
        # Create provider mappings
        for provider in sorted(providers):
            idx = len(graph.provider_to_idx)
            graph.provider_to_idx[provider] = idx
            graph.idx_to_provider[idx] = provider
        
        # Create badge mappings
        for badge in sorted(badges):
            idx = len(graph.badge_to_idx)
            graph.badge_to_idx[badge] = idx
        
        # Process promotions
        promo_games: Dict[str, List[str]] = {}  # promo_id -> games
        
        for promo in cms_data["promotions"]:
            promo_id = promo.get("id") or promo.get("slug")
            if not promo_id:
                continue
            
            if promo_id not in graph.promotion_to_idx:
                idx = len(graph.promotion_to_idx)
                graph.promotion_to_idx[promo_id] = idx
                graph.idx_to_promotion[idx] = promo_id
            
            # Extract featured games
            featured = promo.get("featuredGames", [])
            game_slugs = []
            for g in featured:
                slug = g.get("slug") if isinstance(g, dict) else str(g)
                if slug and slug in graph.game_slug_to_idx:
                    game_slugs.append(slug)
            if game_slugs:
                promo_games[promo_id] = game_slugs
        
        # ============================================
        # Collect user interactions from PostgreSQL
        # ============================================
        
        user_games_played: Dict[str, Dict[str, float]] = {}  # user -> game -> weight
        user_games_rated: Dict[str, Dict[str, float]] = {}
        user_devices: Dict[str, set] = {}  # user -> devices
        
        # Process events
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, event_type, duration_seconds, metadata
                FROM user_events
                WHERE created_at >= %s
            """, (since,))
            
            for row in cur.fetchall():
                user_id, game_slug, event_type, duration_seconds, metadata = row
                
                # Add user
                if user_id not in graph.user_id_to_idx:
                    idx = len(graph.user_id_to_idx)
                    graph.user_id_to_idx[user_id] = idx
                    graph.idx_to_user_id[idx] = user_id
                
                # Add game if not from CMS
                if game_slug not in graph.game_slug_to_idx:
                    idx = len(graph.game_slug_to_idx)
                    graph.game_slug_to_idx[game_slug] = idx
                    graph.idx_to_game_slug[idx] = game_slug
                
                # Track interaction
                weight = self._get_event_weight(event_type, duration_seconds)
                if weight > 0:
                    if user_id not in user_games_played:
                        user_games_played[user_id] = {}
                    if game_slug not in user_games_played[user_id]:
                        user_games_played[user_id][game_slug] = 0
                    user_games_played[user_id][game_slug] += weight
                
                # Extract device from metadata
                if metadata:
                    try:
                        meta_dict = json.loads(metadata) if isinstance(metadata, str) else metadata
                        device = meta_dict.get("device") or meta_dict.get("deviceType")
                        if device:
                            if user_id not in user_devices:
                                user_devices[user_id] = set()
                            user_devices[user_id].add(device)
                    except:
                        pass
        
        # Process ratings
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating
                FROM user_ratings
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating = row
                
                if user_id not in graph.user_id_to_idx:
                    idx = len(graph.user_id_to_idx)
                    graph.user_id_to_idx[user_id] = idx
                    graph.idx_to_user_id[idx] = user_id
                
                if game_slug not in graph.game_slug_to_idx:
                    idx = len(graph.game_slug_to_idx)
                    graph.game_slug_to_idx[game_slug] = idx
                    graph.idx_to_game_slug[idx] = game_slug
                
                weight = self._get_rating_weight(rating)
                if weight > 0:
                    if user_id not in user_games_rated:
                        user_games_rated[user_id] = {}
                    user_games_rated[user_id][game_slug] = weight
        
        # Process reviews
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, game_slug, rating, sentiment_score
                FROM user_reviews
            """)
            
            for row in cur.fetchall():
                user_id, game_slug, rating, sentiment_score = row
                
                if user_id not in graph.user_id_to_idx:
                    idx = len(graph.user_id_to_idx)
                    graph.user_id_to_idx[user_id] = idx
                    graph.idx_to_user_id[idx] = user_id
                
                weight = self._get_rating_weight(rating)
                if sentiment_score is not None:
                    weight *= (1.0 + float(sentiment_score) * 0.5)
                
                if weight > 0:
                    if user_id not in user_games_rated:
                        user_games_rated[user_id] = {}
                    user_games_rated[user_id][game_slug] = max(
                        user_games_rated[user_id].get(game_slug, 0),
                        weight
                    )
        
        # Create device mappings
        all_devices = set()
        for devices in user_devices.values():
            all_devices.update(devices)
        
        for device in sorted(all_devices):
            idx = len(graph.device_to_idx)
            graph.device_to_idx[device] = idx
        
        # ============================================
        # Build edge tensors
        # ============================================
        
        # User-Game: PLAYED edges
        played_src, played_dst, played_weights = [], [], []
        for user_id, games in user_games_played.items():
            user_idx = graph.user_id_to_idx[user_id]
            for game_slug, weight in games.items():
                game_idx = graph.game_slug_to_idx[game_slug]
                played_src.append(user_idx)
                played_dst.append(game_idx)
                played_weights.append(weight)
        
        if played_src:
            graph.edge_index[(NodeType.USER, EdgeType.PLAYED, NodeType.GAME)] = torch.tensor(
                [played_src, played_dst], dtype=torch.long
            )
            graph.edge_weight[(NodeType.USER, EdgeType.PLAYED, NodeType.GAME)] = torch.tensor(
                played_weights, dtype=torch.float32
            )
            # Reverse edges
            graph.edge_index[(NodeType.GAME, EdgeType.REV_PLAYED, NodeType.USER)] = torch.tensor(
                [played_dst, played_src], dtype=torch.long
            )
            graph.edge_weight[(NodeType.GAME, EdgeType.REV_PLAYED, NodeType.USER)] = torch.tensor(
                played_weights, dtype=torch.float32
            )
        
        # User-Game: RATED edges
        rated_src, rated_dst, rated_weights = [], [], []
        for user_id, games in user_games_rated.items():
            user_idx = graph.user_id_to_idx[user_id]
            for game_slug, weight in games.items():
                if game_slug in graph.game_slug_to_idx:
                    game_idx = graph.game_slug_to_idx[game_slug]
                    rated_src.append(user_idx)
                    rated_dst.append(game_idx)
                    rated_weights.append(weight)
        
        if rated_src:
            graph.edge_index[(NodeType.USER, EdgeType.RATED, NodeType.GAME)] = torch.tensor(
                [rated_src, rated_dst], dtype=torch.long
            )
            graph.edge_weight[(NodeType.USER, EdgeType.RATED, NodeType.GAME)] = torch.tensor(
                rated_weights, dtype=torch.float32
            )
            graph.edge_index[(NodeType.GAME, EdgeType.REV_RATED, NodeType.USER)] = torch.tensor(
                [rated_dst, rated_src], dtype=torch.long
            )
            graph.edge_weight[(NodeType.GAME, EdgeType.REV_RATED, NodeType.USER)] = torch.tensor(
                rated_weights, dtype=torch.float32
            )
        
        # Game-Provider: MADE_BY edges
        made_by_src, made_by_dst = [], []
        for game_slug, provider in game_providers.items():
            if game_slug in graph.game_slug_to_idx and provider in graph.provider_to_idx:
                made_by_src.append(graph.game_slug_to_idx[game_slug])
                made_by_dst.append(graph.provider_to_idx[provider])
        
        if made_by_src:
            graph.edge_index[(NodeType.GAME, EdgeType.MADE_BY, NodeType.PROVIDER)] = torch.tensor(
                [made_by_src, made_by_dst], dtype=torch.long
            )
            graph.edge_index[(NodeType.PROVIDER, EdgeType.REV_MADE_BY, NodeType.GAME)] = torch.tensor(
                [made_by_dst, made_by_src], dtype=torch.long
            )
        
        # Game-Badge: HAS_BADGE edges
        badge_src, badge_dst = [], []
        for game_slug, badge_list in game_badges.items():
            if game_slug in graph.game_slug_to_idx:
                game_idx = graph.game_slug_to_idx[game_slug]
                for badge in badge_list:
                    if badge in graph.badge_to_idx:
                        badge_src.append(game_idx)
                        badge_dst.append(graph.badge_to_idx[badge])
        
        if badge_src:
            graph.edge_index[(NodeType.GAME, EdgeType.HAS_BADGE, NodeType.BADGE)] = torch.tensor(
                [badge_src, badge_dst], dtype=torch.long
            )
            graph.edge_index[(NodeType.BADGE, EdgeType.REV_HAS_BADGE, NodeType.GAME)] = torch.tensor(
                [badge_dst, badge_src], dtype=torch.long
            )
        
        # Promotion-Game: FEATURES edges
        features_src, features_dst = [], []
        for promo_id, game_slugs in promo_games.items():
            if promo_id in graph.promotion_to_idx:
                promo_idx = graph.promotion_to_idx[promo_id]
                for game_slug in game_slugs:
                    if game_slug in graph.game_slug_to_idx:
                        features_src.append(promo_idx)
                        features_dst.append(graph.game_slug_to_idx[game_slug])
        
        if features_src:
            graph.edge_index[(NodeType.PROMOTION, EdgeType.FEATURES, NodeType.GAME)] = torch.tensor(
                [features_src, features_dst], dtype=torch.long
            )
            graph.edge_index[(NodeType.GAME, EdgeType.REV_FEATURES, NodeType.PROMOTION)] = torch.tensor(
                [features_dst, features_src], dtype=torch.long
            )
        
        # User-Device: USES edges
        uses_src, uses_dst = [], []
        for user_id, devices in user_devices.items():
            if user_id in graph.user_id_to_idx:
                user_idx = graph.user_id_to_idx[user_id]
                for device in devices:
                    if device in graph.device_to_idx:
                        uses_src.append(user_idx)
                        uses_dst.append(graph.device_to_idx[device])
        
        if uses_src:
            graph.edge_index[(NodeType.USER, EdgeType.USES, NodeType.DEVICE)] = torch.tensor(
                [uses_src, uses_dst], dtype=torch.long
            )
            graph.edge_index[(NodeType.DEVICE, EdgeType.REV_USES, NodeType.USER)] = torch.tensor(
                [uses_dst, uses_src], dtype=torch.long
            )
        
        # Set node counts
        graph.num_nodes = {
            NodeType.USER: len(graph.user_id_to_idx),
            NodeType.GAME: len(graph.game_slug_to_idx),
            NodeType.PROVIDER: len(graph.provider_to_idx),
            NodeType.PROMOTION: len(graph.promotion_to_idx),
            NodeType.DEVICE: len(graph.device_to_idx),
            NodeType.BADGE: len(graph.badge_to_idx)
        }
        
        logger.info(
            "Built heterogeneous graph",
            num_users=graph.num_nodes[NodeType.USER],
            num_games=graph.num_nodes[NodeType.GAME],
            num_providers=graph.num_nodes[NodeType.PROVIDER],
            num_promotions=graph.num_nodes[NodeType.PROMOTION],
            num_devices=graph.num_nodes[NodeType.DEVICE],
            num_badges=graph.num_nodes[NodeType.BADGE],
            num_edge_types=len(graph.edge_index)
        )
        
        return graph

