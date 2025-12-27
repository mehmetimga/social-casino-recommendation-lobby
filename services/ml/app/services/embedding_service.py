"""Embedding service for managing LightGCN embeddings in Qdrant."""

from typing import Optional
import structlog
from qdrant_client import QdrantClient
from qdrant_client.http import models
from qdrant_client.http.models import Distance, VectorParams, PointStruct
import torch
import numpy as np

from app.config import get_settings
from app.services.graph_builder import GraphData
from app.models.lightgcn import LightGCNInference

logger = structlog.get_logger()


class EmbeddingService:
    """Service for managing LightGCN embeddings in Qdrant."""
    
    def __init__(self):
        """Initialize embedding service."""
        self.settings = get_settings()
        self._client: Optional[QdrantClient] = None
    
    @property
    def client(self) -> QdrantClient:
        """Get or create Qdrant client."""
        if self._client is None:
            self._client = QdrantClient(
                host=self.settings.qdrant_host,
                port=self.settings.qdrant_port
            )
        return self._client
    
    def _ensure_collection(self, collection_name: str):
        """Ensure a collection exists with proper configuration."""
        collections = self.client.get_collections().collections
        collection_names = [c.name for c in collections]
        
        if collection_name not in collection_names:
            self.client.create_collection(
                collection_name=collection_name,
                vectors_config=VectorParams(
                    size=self.settings.embedding_dim,
                    distance=Distance.COSINE
                )
            )
            logger.info(f"Created collection: {collection_name}")
    
    def init_collections(self):
        """Initialize LightGCN collections in Qdrant."""
        self._ensure_collection(self.settings.lightgcn_users_collection)
        self._ensure_collection(self.settings.lightgcn_games_collection)
        logger.info("Initialized LightGCN collections")
    
    def store_user_embeddings(
        self,
        inference: LightGCNInference,
        graph_data: GraphData,
        batch_size: int = 100
    ):
        """Store all user embeddings in Qdrant.
        
        Args:
            inference: LightGCN inference with computed embeddings
            graph_data: Graph data with ID mappings
            batch_size: Batch size for upserting
        """
        self._ensure_collection(self.settings.lightgcn_users_collection)
        
        user_embeddings = inference.get_all_user_embeddings().cpu().numpy()
        
        points = []
        for idx in range(graph_data.num_users):
            user_id = graph_data.idx_to_user_id[idx]
            embedding = user_embeddings[idx].tolist()
            
            # Use hash as numeric ID for older Qdrant versions
            numeric_id = abs(hash(user_id)) % (2**63)
            points.append(PointStruct(
                id=numeric_id,
                vector=embedding,
                payload={
                    "user_id": user_id,
                    "user_idx": idx,
                    "source": "lightgcn"
                }
            ))
            
            if len(points) >= batch_size:
                self.client.upsert(
                    collection_name=self.settings.lightgcn_users_collection,
                    points=points
                )
                points = []
        
        if points:
            self.client.upsert(
                collection_name=self.settings.lightgcn_users_collection,
                points=points
            )
        
        logger.info(
            "Stored user embeddings",
            num_users=graph_data.num_users,
            collection=self.settings.lightgcn_users_collection
        )
    
    def store_game_embeddings(
        self,
        inference: LightGCNInference,
        graph_data: GraphData,
        batch_size: int = 100
    ):
        """Store all game embeddings in Qdrant.
        
        Args:
            inference: LightGCN inference with computed embeddings
            graph_data: Graph data with ID mappings
            batch_size: Batch size for upserting
        """
        self._ensure_collection(self.settings.lightgcn_games_collection)
        
        item_embeddings = inference.get_all_item_embeddings().cpu().numpy()
        
        points = []
        for idx in range(graph_data.num_games):
            game_slug = graph_data.idx_to_game_slug[idx]
            embedding = item_embeddings[idx].tolist()
            
            # Use hash as numeric ID for older Qdrant versions
            numeric_id = abs(hash(game_slug)) % (2**63)
            points.append(PointStruct(
                id=numeric_id,
                vector=embedding,
                payload={
                    "game_slug": game_slug,
                    "game_idx": idx,
                    "source": "lightgcn"
                }
            ))
            
            if len(points) >= batch_size:
                self.client.upsert(
                    collection_name=self.settings.lightgcn_games_collection,
                    points=points
                )
                points = []
        
        if points:
            self.client.upsert(
                collection_name=self.settings.lightgcn_games_collection,
                points=points
            )
        
        logger.info(
            "Stored game embeddings",
            num_games=graph_data.num_games,
            collection=self.settings.lightgcn_games_collection
        )
    
    def store_all_embeddings(
        self,
        inference: LightGCNInference,
        graph_data: GraphData
    ):
        """Store both user and game embeddings.
        
        Args:
            inference: LightGCN inference with computed embeddings
            graph_data: Graph data with ID mappings
        """
        self.store_user_embeddings(inference, graph_data)
        self.store_game_embeddings(inference, graph_data)
    
    def get_user_embedding(self, user_id: str) -> Optional[list[float]]:
        """Get user embedding from Qdrant.
        
        Args:
            user_id: User ID
            
        Returns:
            User embedding vector or None if not found
        """
        try:
            result = self.client.retrieve(
                collection_name=self.settings.lightgcn_users_collection,
                ids=[user_id],
                with_vectors=True
            )
            
            if result:
                return result[0].vector
            return None
            
        except Exception as e:
            logger.error("Failed to get user embedding", error=str(e), user_id=user_id)
            return None
    
    def get_game_embedding(self, game_slug: str) -> Optional[list[float]]:
        """Get game embedding from Qdrant.
        
        Args:
            game_slug: Game slug
            
        Returns:
            Game embedding vector or None if not found
        """
        try:
            result = self.client.retrieve(
                collection_name=self.settings.lightgcn_games_collection,
                ids=[game_slug],
                with_vectors=True
            )
            
            if result:
                return result[0].vector
            return None
            
        except Exception as e:
            logger.error("Failed to get game embedding", error=str(e), game_slug=game_slug)
            return None
    
    def search_similar_games(
        self,
        user_embedding: list[float],
        limit: int = 10,
        score_threshold: Optional[float] = None
    ) -> list[dict]:
        """Search for games similar to user preferences.
        
        Args:
            user_embedding: User embedding vector
            limit: Maximum number of results
            score_threshold: Minimum similarity score
            
        Returns:
            List of game results with scores
        """
        try:
            results = self.client.search(
                collection_name=self.settings.lightgcn_games_collection,
                query_vector=user_embedding,
                limit=limit,
                score_threshold=score_threshold
            )
            
            return [
                {
                    "game_slug": hit.payload.get("game_slug"),
                    "score": hit.score,
                    "game_idx": hit.payload.get("game_idx")
                }
                for hit in results
            ]
            
        except Exception as e:
            logger.error("Failed to search similar games", error=str(e))
            return []
    
    def update_user_embedding(
        self,
        user_id: str,
        embedding: list[float]
    ):
        """Update a single user embedding.
        
        Args:
            user_id: User ID
            embedding: New embedding vector
        """
        try:
            # Use hash as numeric ID for older Qdrant versions
            numeric_id = abs(hash(user_id)) % (2**63)
            self.client.upsert(
                collection_name=self.settings.lightgcn_users_collection,
                points=[PointStruct(
                    id=numeric_id,
                    vector=embedding,
                    payload={
                        "user_id": user_id,
                        "source": "lightgcn_realtime"
                    }
                )]
            )
            logger.debug("Updated user embedding", user_id=user_id)
            
        except Exception as e:
            logger.error("Failed to update user embedding", error=str(e), user_id=user_id)
    
    def get_recommendations(
        self,
        user_id: str,
        limit: int = 10,
        exclude_games: Optional[list[str]] = None
    ) -> list[dict]:
        """Get game recommendations for a user.
        
        Args:
            user_id: User ID
            limit: Number of recommendations
            exclude_games: Games to exclude (e.g., already played)
            
        Returns:
            List of recommended games with scores
        """
        # Get user embedding
        user_embedding = self.get_user_embedding(user_id)
        
        if user_embedding is None:
            logger.info("No embedding found for user", user_id=user_id)
            return []
        
        # Search for similar games
        # Request more results to account for exclusions
        search_limit = limit + len(exclude_games) if exclude_games else limit
        
        results = self.search_similar_games(user_embedding, search_limit)
        
        # Filter excluded games
        if exclude_games:
            exclude_set = set(exclude_games)
            results = [r for r in results if r["game_slug"] not in exclude_set]
        
        return results[:limit]
    
    def get_collection_stats(self) -> dict:
        """Get statistics about LightGCN collections.
        
        Returns:
            Dictionary with collection statistics
        """
        stats = {}
        
        for collection_name in [
            self.settings.lightgcn_users_collection,
            self.settings.lightgcn_games_collection
        ]:
            try:
                info = self.client.get_collection(collection_name)
                stats[collection_name] = {
                    "vectors_count": getattr(info, 'vectors_count', info.points_count),
                    "points_count": info.points_count,
                    "status": info.status
                }
            except Exception as e:
                stats[collection_name] = {"error": str(e)}
        
        return stats
    
    # ========================================
    # HGT Embedding Methods
    # ========================================
    
    def store_user_embedding(self, user_id: str, embedding: list[float]):
        """Store a single user embedding (for HGT sync).
        
        Args:
            user_id: User ID
            embedding: Embedding vector
        """
        self._ensure_collection(self.settings.hgt_users_collection)
        
        try:
            # Use hash of user_id as numeric ID for older Qdrant versions
            numeric_id = abs(hash(user_id)) % (2**63)
            self.client.upsert(
                collection_name=self.settings.hgt_users_collection,
                points=[PointStruct(
                    id=numeric_id,
                    vector=embedding,
                    payload={
                        "user_id": user_id,
                        "source": "hgt"
                    }
                )]
            )
        except Exception as e:
            logger.error("Failed to store HGT user embedding", error=str(e), user_id=user_id)
    
    def store_game_embedding(self, game_slug: str, embedding: list[float]):
        """Store a single game embedding (for HGT sync).
        
        Args:
            game_slug: Game slug
            embedding: Embedding vector
        """
        self._ensure_collection(self.settings.hgt_games_collection)
        
        try:
            # Use hash of game_slug as numeric ID for older Qdrant versions
            numeric_id = abs(hash(game_slug)) % (2**63)
            self.client.upsert(
                collection_name=self.settings.hgt_games_collection,
                points=[PointStruct(
                    id=numeric_id,
                    vector=embedding,
                    payload={
                        "game_slug": game_slug,
                        "source": "hgt"
                    }
                )]
            )
        except Exception as e:
            logger.error("Failed to store HGT game embedding", error=str(e), game_slug=game_slug)

