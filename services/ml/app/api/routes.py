"""FastAPI routes for ML service."""

from typing import Optional, Literal
from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel, Field
import structlog
import torch
import numpy as np

from app.config import get_settings
from app.services.graph_builder import GraphBuilder, GraphData
from app.services.trainer import LightGCNTrainer
from app.services.embedding_service import EmbeddingService
from app.services.tgn_trainer import TGNTrainer, TemporalGraphBuilder
from app.services.session_service import SessionService
from app.services.hgt_builder import HeteroGraphBuilder
from app.services.hgt_trainer import HGTTrainer

logger = structlog.get_logger()
router = APIRouter()

# Global state for model and graph
_state = {
    "graph_data": None,
    "trainer": None,
    "embedding_service": None,
    "device": None,
    "is_training": False,
    # TGN-specific state
    "tgn_trainer": None,
    "session_service": None,
    "tgn_mappings": None,  # (user_id_to_idx, game_slug_to_idx)
    # HGT-specific state
    "hgt_trainer": None,
    "hgt_graph": None,
    "hgt_inference": None
}


def get_device() -> torch.device:
    """Get PyTorch device."""
    if _state["device"] is None:
        _state["device"] = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    return _state["device"]


def get_embedding_service() -> EmbeddingService:
    """Get embedding service singleton."""
    if _state["embedding_service"] is None:
        _state["embedding_service"] = EmbeddingService()
    return _state["embedding_service"]


# Request/Response Models

class TrainRequest(BaseModel):
    """Request to train the model."""
    lookback_days: int = Field(default=30, description="Days of history to include")
    num_epochs: int = Field(default=100, description="Number of training epochs")
    batch_size: int = Field(default=1024, description="Training batch size")
    force_rebuild: bool = Field(default=False, description="Force rebuild graph even if exists")


class TrainResponse(BaseModel):
    """Response from training."""
    status: str
    message: str
    stats: Optional[dict] = None


class RecommendRequest(BaseModel):
    """Request for recommendations."""
    user_id: str = Field(..., description="User ID to get recommendations for")
    limit: int = Field(default=10, description="Number of recommendations")
    exclude_games: Optional[list[str]] = Field(default=None, description="Games to exclude")


class RecommendResponse(BaseModel):
    """Recommendations response."""
    user_id: str
    recommendations: list[dict]
    source: str = "lightgcn"


class EmbeddingRequest(BaseModel):
    """Request for embedding."""
    id: str = Field(..., description="User ID or game slug")


class EmbeddingResponse(BaseModel):
    """Embedding response."""
    id: str
    embedding: Optional[list[float]]
    found: bool


class InteractionRequest(BaseModel):
    """Request to add an interaction (real-time update)."""
    user_id: str
    game_slug: str
    event_type: str = Field(..., description="Event type: impression, click, game_time")
    duration_seconds: Optional[int] = Field(default=None, description="Duration for game_time events")
    rating: Optional[int] = Field(default=None, description="Rating value (1-5)")


class InteractionResponse(BaseModel):
    """Response after processing interaction."""
    status: str
    embedding_updated: bool


class StatusResponse(BaseModel):
    """Service status response."""
    status: str
    model_loaded: bool
    graph_loaded: bool
    num_users: int
    num_games: int
    num_edges: int
    device: str
    collections: dict


# Routes

@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "casino-ml-service"}


@router.get("/status", response_model=StatusResponse)
async def get_status():
    """Get service status."""
    embedding_service = get_embedding_service()
    
    graph_loaded = _state["graph_data"] is not None
    model_loaded = _state["trainer"] is not None
    
    return StatusResponse(
        status="ready" if model_loaded else "not_trained",
        model_loaded=model_loaded,
        graph_loaded=graph_loaded,
        num_users=_state["graph_data"].num_users if graph_loaded else 0,
        num_games=_state["graph_data"].num_games if graph_loaded else 0,
        num_edges=_state["graph_data"].num_edges if graph_loaded else 0,
        device=str(get_device()),
        collections=embedding_service.get_collection_stats()
    )


@router.post("/train", response_model=TrainResponse)
async def train_model(request: TrainRequest, background_tasks: BackgroundTasks):
    """Train or retrain the LightGCN model.
    
    This endpoint:
    1. Builds the user-game interaction graph from PostgreSQL
    2. Trains the LightGCN model
    3. Stores embeddings in Qdrant
    """
    if _state["is_training"]:
        raise HTTPException(status_code=409, detail="Training already in progress")
    
    _state["is_training"] = True
    
    try:
        logger.info("Starting model training", **request.model_dump())
        
        # Build graph
        graph_builder = GraphBuilder()
        try:
            graph_data = graph_builder.build_graph(lookback_days=request.lookback_days)
        finally:
            graph_builder.close()
        
        if graph_data.num_users == 0 or graph_data.num_games == 0:
            _state["is_training"] = False
            return TrainResponse(
                status="error",
                message="No interaction data found to build graph",
                stats={"num_users": 0, "num_games": 0}
            )
        
        _state["graph_data"] = graph_data
        
        # Create and train model
        trainer = LightGCNTrainer(graph_data, device=get_device())
        
        # Try to load existing model for incremental training
        if not request.force_rebuild:
            trainer.load_model()
        
        train_stats = trainer.train(
            num_epochs=request.num_epochs,
            batch_size=request.batch_size
        )
        
        # Save model
        trainer.save_model()
        _state["trainer"] = trainer
        
        # Store embeddings in Qdrant
        embedding_service = get_embedding_service()
        embedding_service.init_collections()
        
        inference = trainer.get_inference()
        embedding_service.store_all_embeddings(inference, graph_data)
        
        logger.info("Training completed successfully")
        
        return TrainResponse(
            status="success",
            message="Model trained and embeddings stored",
            stats={
                "num_users": graph_data.num_users,
                "num_games": graph_data.num_games,
                "num_edges": graph_data.num_edges,
                "final_loss": train_stats["final_loss"],
                "num_epochs": train_stats["num_epochs"]
            }
        )
        
    except Exception as e:
        logger.error("Training failed", error=str(e))
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")
    
    finally:
        _state["is_training"] = False


@router.post("/recommend", response_model=RecommendResponse)
async def get_recommendations(request: RecommendRequest):
    """Get game recommendations for a user using LightGCN embeddings."""
    embedding_service = get_embedding_service()
    
    recommendations = embedding_service.get_recommendations(
        user_id=request.user_id,
        limit=request.limit,
        exclude_games=request.exclude_games
    )
    
    return RecommendResponse(
        user_id=request.user_id,
        recommendations=recommendations
    )


@router.get("/embedding/user/{user_id}", response_model=EmbeddingResponse)
async def get_user_embedding(user_id: str):
    """Get LightGCN embedding for a user."""
    embedding_service = get_embedding_service()
    embedding = embedding_service.get_user_embedding(user_id)
    
    return EmbeddingResponse(
        id=user_id,
        embedding=embedding,
        found=embedding is not None
    )


@router.get("/embedding/game/{game_slug}", response_model=EmbeddingResponse)
async def get_game_embedding(game_slug: str):
    """Get LightGCN embedding for a game."""
    embedding_service = get_embedding_service()
    embedding = embedding_service.get_game_embedding(game_slug)
    
    return EmbeddingResponse(
        id=game_slug,
        embedding=embedding,
        found=embedding is not None
    )


@router.post("/interaction", response_model=InteractionResponse)
async def process_interaction(request: InteractionRequest):
    """Process a new interaction and update embeddings in real-time.
    
    This is called by the Go recommendation service when new events occur.
    For now, this triggers a lightweight embedding update.
    
    Full real-time GNN updates will be implemented in Phase 2 (TGN).
    """
    logger.debug(
        "Processing interaction",
        user_id=request.user_id,
        game_slug=request.game_slug,
        event_type=request.event_type
    )
    
    # For Phase 1, we just log the interaction
    # Real-time embedding updates will use incremental graph updates
    # For now, recommend periodic retraining
    
    # Check if user exists in current embeddings
    embedding_service = get_embedding_service()
    user_embedding = embedding_service.get_user_embedding(request.user_id)
    
    if user_embedding is None:
        # New user - would need graph rebuild
        logger.info("New user detected, retraining recommended", user_id=request.user_id)
        return InteractionResponse(
            status="pending",
            embedding_updated=False
        )
    
    # For existing users, we could do incremental updates here
    # This will be improved in Phase 2 with TGN
    
    return InteractionResponse(
        status="received",
        embedding_updated=False
    )


@router.post("/rebuild")
async def rebuild_graph():
    """Rebuild the interaction graph without full retraining.
    
    Useful for adding new users/games to the graph.
    """
    try:
        graph_builder = GraphBuilder()
        try:
            graph_data = graph_builder.build_graph()
        finally:
            graph_builder.close()
        
        _state["graph_data"] = graph_data
        
        return {
            "status": "success",
            "num_users": graph_data.num_users,
            "num_games": graph_data.num_games,
            "num_edges": graph_data.num_edges
        }
        
    except Exception as e:
        logger.error("Graph rebuild failed", error=str(e))
        raise HTTPException(status_code=500, detail=f"Rebuild failed: {str(e)}")


@router.get("/graph/stats")
async def get_graph_stats():
    """Get current graph statistics."""
    if _state["graph_data"] is None:
        return {
            "loaded": False,
            "message": "No graph loaded. Call /train first."
        }
    
    graph_data = _state["graph_data"]
    return {
        "loaded": True,
        "num_users": graph_data.num_users,
        "num_games": graph_data.num_games,
        "num_edges": graph_data.num_edges,
        "density": graph_data.num_edges / (graph_data.num_users * graph_data.num_games * 2)
        if graph_data.num_users > 0 and graph_data.num_games > 0 else 0
    }


# ============================================
# TGN (Temporal Graph Network) Endpoints
# ============================================

def get_session_service() -> SessionService:
    """Get session service singleton."""
    if _state["session_service"] is None:
        _state["session_service"] = SessionService()
    return _state["session_service"]


class TGNTrainRequest(BaseModel):
    """Request to train TGN model."""
    lookback_days: int = Field(default=30, description="Days of history to include")
    num_epochs: int = Field(default=50, description="Number of training epochs")
    batch_size: int = Field(default=256, description="Training batch size")


class TGNTrainResponse(BaseModel):
    """Response from TGN training."""
    status: str
    message: str
    stats: Optional[dict] = None


class SessionRecommendRequest(BaseModel):
    """Request for session-aware recommendations."""
    user_id: str = Field(..., description="User ID")
    limit: int = Field(default=10, description="Number of recommendations")
    exclude_recent: bool = Field(default=True, description="Exclude recently played games")


class SessionRecommendResponse(BaseModel):
    """Response with session-aware recommendations."""
    user_id: str
    recommendations: list[dict]
    session_context: dict
    source: str = "tgn"


class SessionInteractionRequest(BaseModel):
    """Request to add interaction to session."""
    user_id: str
    game_slug: str
    event_type: str
    duration_seconds: Optional[int] = None
    rating: Optional[int] = None


class SessionInteractionResponse(BaseModel):
    """Response after adding session interaction."""
    status: str
    session_active: bool
    memory_updated: bool


@router.post("/tgn/train", response_model=TGNTrainResponse)
async def train_tgn_model(request: TGNTrainRequest):
    """Train the TGN (Temporal Graph Network) model.
    
    TGN provides session-aware recommendations by:
    1. Tracking temporal patterns in user behavior
    2. Maintaining memory of recent interactions
    3. Learning time-aware embeddings
    """
    if _state["is_training"]:
        raise HTTPException(status_code=409, detail="Training already in progress")
    
    _state["is_training"] = True
    
    try:
        logger.info("Starting TGN training", **request.model_dump())
        
        # Build temporal edges
        builder = TemporalGraphBuilder()
        try:
            edges, user_id_to_idx, game_slug_to_idx = builder.build_temporal_edges(
                lookback_days=request.lookback_days
            )
        finally:
            builder.close()
        
        if not edges:
            _state["is_training"] = False
            return TGNTrainResponse(
                status="error",
                message="No temporal edges found",
                stats={"num_edges": 0}
            )
        
        num_users = len(user_id_to_idx)
        num_items = len(game_slug_to_idx)
        
        # Create and train TGN
        trainer = TGNTrainer(num_users, num_items, device=get_device())
        
        train_stats = trainer.train(
            edges=edges,
            num_epochs=request.num_epochs,
            batch_size=request.batch_size
        )
        
        # Save model
        trainer.save_model()
        _state["tgn_trainer"] = trainer
        _state["tgn_mappings"] = (user_id_to_idx, game_slug_to_idx)
        
        # Initialize session service with TGN
        session_service = get_session_service()
        session_service.set_tgn(trainer.get_inference())
        session_service.set_mappings(user_id_to_idx, game_slug_to_idx)
        
        logger.info("TGN training completed")
        
        return TGNTrainResponse(
            status="success",
            message="TGN model trained and session service initialized",
            stats={
                "num_users": num_users,
                "num_games": num_items,
                "num_edges": len(edges),
                "final_loss": train_stats["final_loss"],
                "num_epochs": train_stats["num_epochs"]
            }
        )
        
    except Exception as e:
        logger.error("TGN training failed", error=str(e))
        raise HTTPException(status_code=500, detail=f"TGN training failed: {str(e)}")
    
    finally:
        _state["is_training"] = False


@router.post("/tgn/recommend", response_model=SessionRecommendResponse)
async def get_session_recommendations(request: SessionRecommendRequest):
    """Get session-aware recommendations using TGN.
    
    Uses the user's current session context (recent interactions)
    to provide more relevant recommendations.
    """
    session_service = get_session_service()
    
    if session_service.tgn is None:
        raise HTTPException(
            status_code=503,
            detail="TGN not trained. Call /v1/tgn/train first."
        )
    
    # Get recommendations
    recs = session_service.get_session_recommendations(
        user_id=request.user_id,
        limit=request.limit,
        exclude_recent=request.exclude_recent
    )
    
    # Get session context
    context = session_service.get_session_context(request.user_id)
    
    return SessionRecommendResponse(
        user_id=request.user_id,
        recommendations=[
            {"game_slug": slug, "score": score}
            for slug, score in recs
        ],
        session_context=context
    )


@router.post("/tgn/interaction", response_model=SessionInteractionResponse)
async def add_session_interaction(request: SessionInteractionRequest):
    """Add an interaction to the user's session and update TGN memory.
    
    This provides real-time updates to the recommendation model
    based on the user's current activity.
    """
    session_service = get_session_service()
    
    if session_service.tgn is None:
        # TGN not available, just track the interaction
        return SessionInteractionResponse(
            status="tgn_not_available",
            session_active=False,
            memory_updated=False
        )
    
    # Add interaction
    success = session_service.add_interaction(
        user_id=request.user_id,
        game_slug=request.game_slug,
        event_type=request.event_type,
        duration_seconds=request.duration_seconds,
        rating=request.rating
    )
    
    context = session_service.get_session_context(request.user_id)
    
    return SessionInteractionResponse(
        status="success" if success else "game_not_found",
        session_active=context.get("active", False),
        memory_updated=success
    )


@router.get("/tgn/session/{user_id}")
async def get_session_info(user_id: str):
    """Get information about a user's current session."""
    session_service = get_session_service()
    context = session_service.get_session_context(user_id)
    
    return {
        "user_id": user_id,
        "session": context
    }


@router.delete("/tgn/session/{user_id}")
async def end_session(user_id: str):
    """End a user's session."""
    session_service = get_session_service()
    session_service.end_session(user_id)
    
    return {"status": "session_ended", "user_id": user_id}


@router.get("/tgn/status")
async def get_tgn_status():
    """Get TGN service status."""
    session_service = get_session_service()
    stats = session_service.get_stats()
    
    return {
        "tgn_trained": _state["tgn_trainer"] is not None,
        "session_service": stats
    }


@router.post("/tgn/cleanup")
async def cleanup_sessions():
    """Clean up expired sessions."""
    session_service = get_session_service()
    session_service.cleanup_expired_sessions()
    
    return {"status": "cleanup_complete"}


# ========================================
# HGT (Heterogeneous Graph Transformer)
# ========================================

class HGTTrainRequest(BaseModel):
    """Request to train HGT model."""
    num_epochs: Optional[int] = Field(default=100, ge=1, le=1000)
    batch_size: Optional[int] = Field(default=256, ge=16, le=2048)
    lookback_days: Optional[int] = Field(default=30, ge=1, le=365)
    cms_url: Optional[str] = Field(default=None)


class HGTTrainResponse(BaseModel):
    """Response from HGT training."""
    status: str
    final_loss: float
    best_loss: float
    num_epochs: int
    num_users: int
    num_games: int
    num_providers: int
    num_promotions: int
    num_edge_types: int


class HGTRecommendRequest(BaseModel):
    """Request for HGT recommendations."""
    user_id: str
    limit: int = Field(default=10, ge=1, le=100)
    exclude_games: Optional[list[str]] = Field(default=None)
    provider_filter: Optional[str] = Field(default=None)


class HGTRecommendResponse(BaseModel):
    """Response with HGT recommendations."""
    user_id: str
    recommendations: list[dict]  # [{game_slug, score}]
    source: str
    is_cold_start: bool


class HGTSimilarGamesRequest(BaseModel):
    """Request for similar games."""
    game_slug: str
    limit: int = Field(default=10, ge=1, le=100)


class HGTSimilarGamesResponse(BaseModel):
    """Response with similar games."""
    game_slug: str
    similar_games: list[dict]  # [{game_slug, score}]


class HGTProviderGamesRequest(BaseModel):
    """Request for games by provider."""
    provider: str
    user_id: Optional[str] = Field(default=None)
    limit: int = Field(default=10, ge=1, le=100)


class HGTProviderGamesResponse(BaseModel):
    """Response with provider games."""
    provider: str
    games: list[dict]  # [{game_slug, score}]
    personalized: bool


@router.post("/hgt/train", response_model=HGTTrainResponse)
async def train_hgt(request: HGTTrainRequest, background_tasks: BackgroundTasks):
    """Train HGT model on heterogeneous graph."""
    if _state["is_training"]:
        raise HTTPException(status_code=409, detail="Training already in progress")
    
    _state["is_training"] = True
    
    try:
        logger.info("Building heterogeneous graph for HGT")
        
        # Build graph
        builder = HeteroGraphBuilder(cms_url=request.cms_url)
        try:
            graph = builder.build_graph(lookback_days=request.lookback_days)
        finally:
            builder.close()
        
        _state["hgt_graph"] = graph
        
        # Check for minimum data
        from app.models.hgt import NodeType
        num_users = graph.num_nodes.get(NodeType.USER, 0)
        num_games = graph.num_nodes.get(NodeType.GAME, 0)
        
        if num_users == 0 or num_games == 0:
            _state["is_training"] = False
            return HGTTrainResponse(
                status="insufficient_data",
                final_loss=0.0,
                best_loss=0.0,
                num_epochs=0,
                num_users=num_users,
                num_games=num_games,
                num_providers=graph.num_nodes.get(NodeType.PROVIDER, 0),
                num_promotions=graph.num_nodes.get(NodeType.PROMOTION, 0),
                num_edge_types=len(graph.edge_index)
            )
        
        # Train model
        trainer = HGTTrainer(graph, device=get_device())
        stats = trainer.train(
            num_epochs=request.num_epochs,
            batch_size=request.batch_size
        )
        
        # Save model
        trainer.save_model()
        
        # Update state
        _state["hgt_trainer"] = trainer
        _state["hgt_inference"] = trainer.get_inference()
        _state["is_training"] = False
        
        # Sync to Qdrant in background
        background_tasks.add_task(_sync_hgt_to_qdrant)
        
        return HGTTrainResponse(
            status="success",
            final_loss=stats["final_loss"],
            best_loss=stats["best_loss"],
            num_epochs=stats["num_epochs"],
            num_users=num_users,
            num_games=num_games,
            num_providers=graph.num_nodes.get(NodeType.PROVIDER, 0),
            num_promotions=graph.num_nodes.get(NodeType.PROMOTION, 0),
            num_edge_types=len(graph.edge_index)
        )
        
    except Exception as e:
        _state["is_training"] = False
        logger.error("HGT training failed", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


async def _sync_hgt_to_qdrant():
    """Sync HGT embeddings to Qdrant."""
    inference = _state.get("hgt_inference")
    if inference is None:
        return
    
    try:
        logger.info("Syncing HGT embeddings to Qdrant")
        
        embedding_service = get_embedding_service()
        inference.compute_embeddings()
        
        from app.models.hgt import NodeType
        
        # Sync user embeddings
        if NodeType.USER in inference.embeddings:
            user_embs = inference.embeddings[NodeType.USER].cpu().numpy()
            for user_id, idx in inference.graph_data.user_id_to_idx.items():
                embedding_service.store_user_embedding(user_id, user_embs[idx].tolist())
        
        # Sync game embeddings
        if NodeType.GAME in inference.embeddings:
            game_embs = inference.embeddings[NodeType.GAME].cpu().numpy()
            for game_slug, idx in inference.graph_data.game_slug_to_idx.items():
                embedding_service.store_game_embedding(game_slug, game_embs[idx].tolist())
        
        logger.info("HGT embeddings synced to Qdrant")
        
    except Exception as e:
        logger.error("Failed to sync HGT embeddings", error=str(e))


@router.post("/hgt/recommend", response_model=HGTRecommendResponse)
async def hgt_recommend(request: HGTRecommendRequest):
    """Get HGT-based recommendations."""
    inference = _state.get("hgt_inference")
    
    if inference is None:
        raise HTTPException(status_code=503, detail="HGT model not trained")
    
    try:
        exclude = set(request.exclude_games) if request.exclude_games else None
        
        recommendations = inference.get_recommendations(
            user_id=request.user_id,
            top_k=request.limit,
            exclude_games=exclude,
            provider_filter=request.provider_filter
        )
        
        # Check if cold-start
        is_cold_start = request.user_id not in inference.graph_data.user_id_to_idx
        
        return HGTRecommendResponse(
            user_id=request.user_id,
            recommendations=[
                {"game_slug": slug, "score": score}
                for slug, score in recommendations
            ],
            source="hgt_cold_start" if is_cold_start else "hgt",
            is_cold_start=is_cold_start
        )
        
    except Exception as e:
        logger.error("HGT recommendation failed", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hgt/similar_games", response_model=HGTSimilarGamesResponse)
async def hgt_similar_games(request: HGTSimilarGamesRequest):
    """Get games similar to a given game."""
    inference = _state.get("hgt_inference")
    
    if inference is None:
        raise HTTPException(status_code=503, detail="HGT model not trained")
    
    try:
        similar = inference.get_similar_games(
            game_slug=request.game_slug,
            top_k=request.limit
        )
        
        return HGTSimilarGamesResponse(
            game_slug=request.game_slug,
            similar_games=[
                {"game_slug": slug, "score": score}
                for slug, score in similar
            ]
        )
        
    except Exception as e:
        logger.error("HGT similar games failed", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hgt/provider_games", response_model=HGTProviderGamesResponse)
async def hgt_provider_games(request: HGTProviderGamesRequest):
    """Get games by a specific provider, optionally personalized."""
    inference = _state.get("hgt_inference")
    
    if inference is None:
        raise HTTPException(status_code=503, detail="HGT model not trained")
    
    try:
        games = inference.get_provider_games(
            provider=request.provider,
            user_id=request.user_id,
            top_k=request.limit
        )
        
        return HGTProviderGamesResponse(
            provider=request.provider,
            games=[
                {"game_slug": slug, "score": score}
                for slug, score in games
            ],
            personalized=request.user_id is not None
        )
        
    except Exception as e:
        logger.error("HGT provider games failed", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hgt/status")
async def get_hgt_status():
    """Get HGT service status."""
    inference = _state.get("hgt_inference")
    graph = _state.get("hgt_graph")
    
    from app.models.hgt import NodeType
    
    status = {
        "hgt_trained": inference is not None,
        "graph": None
    }
    
    if graph:
        status["graph"] = {
            "num_users": graph.num_nodes.get(NodeType.USER, 0),
            "num_games": graph.num_nodes.get(NodeType.GAME, 0),
            "num_providers": graph.num_nodes.get(NodeType.PROVIDER, 0),
            "num_promotions": graph.num_nodes.get(NodeType.PROMOTION, 0),
            "num_devices": graph.num_nodes.get(NodeType.DEVICE, 0),
            "num_badges": graph.num_nodes.get(NodeType.BADGE, 0),
            "num_edge_types": len(graph.edge_index)
        }
    
    return status


@router.post("/hgt/load")
async def load_hgt_model():
    """Load a previously saved HGT model."""
    if _state.get("hgt_trainer") is not None:
        return {"status": "already_loaded"}
    
    try:
        # Need to rebuild graph first
        builder = HeteroGraphBuilder()
        try:
            graph = builder.build_graph(lookback_days=30)
        finally:
            builder.close()
        
        _state["hgt_graph"] = graph
        
        # Try to load model
        trainer = HGTTrainer(graph, device=get_device())
        if trainer.load_model():
            _state["hgt_trainer"] = trainer
            _state["hgt_inference"] = trainer.get_inference()
            return {"status": "loaded"}
        else:
            return {"status": "no_saved_model"}
            
    except Exception as e:
        logger.error("Failed to load HGT model", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ========================================
# VISUALIZATION ENDPOINTS
# ========================================

def _compute_projection(embeddings: np.ndarray, method: str = "tsne", n_components: int = 2) -> np.ndarray:
    """Compute N-dimensional projection of high-dimensional embeddings."""
    if embeddings.shape[0] < 2:
        return np.zeros((embeddings.shape[0], n_components))
    
    if method == "tsne":
        from sklearn.manifold import TSNE
        perplexity = min(30, embeddings.shape[0] - 1)
        tsne = TSNE(n_components=n_components, perplexity=perplexity, random_state=42, max_iter=500)
        return tsne.fit_transform(embeddings)
    elif method == "umap":
        try:
            import umap
            n_neighbors = min(15, embeddings.shape[0] - 1)
            reducer = umap.UMAP(n_components=n_components, n_neighbors=n_neighbors, random_state=42)
            return reducer.fit_transform(embeddings)
        except ImportError:
            # Fallback to PCA if UMAP not installed
            from sklearn.decomposition import PCA
            pca = PCA(n_components=n_components)
            return pca.fit_transform(embeddings)
    else:  # PCA
        from sklearn.decomposition import PCA
        pca = PCA(n_components=n_components)
        return pca.fit_transform(embeddings)


class VizEmbeddingsRequest(BaseModel):
    """Request for embedding visualization."""
    projection: Literal["tsne", "umap", "pca"] = Field(default="tsne")
    dimensions: Literal[2, 3] = Field(default=2, description="2D or 3D projection")
    include_users: bool = Field(default=True)
    include_games: bool = Field(default=True)
    max_points: int = Field(default=500, ge=10, le=5000)


class VizEmbeddingPoint(BaseModel):
    """Single point in the embedding visualization."""
    id: str
    type: str  # "user" or "game"
    x: float
    y: float
    z: Optional[float] = None  # For 3D projections
    label: Optional[str] = None
    metadata: Optional[dict] = None


class VizEmbeddingsResponse(BaseModel):
    """Response with embedding visualization data."""
    points: list[VizEmbeddingPoint]
    stats: dict
    projection_method: str
    dimensions: int = 2  # 2 or 3


class VizGraphRequest(BaseModel):
    """Request for graph visualization."""
    max_nodes: int = Field(default=200, ge=10, le=1000)
    max_edges: int = Field(default=500, ge=10, le=5000)
    include_weights: bool = Field(default=True)


class VizGraphNode(BaseModel):
    """Node in graph visualization."""
    id: str
    type: str  # "user", "game", "provider", etc.
    label: Optional[str] = None
    size: Optional[float] = None  # Node importance/degree
    color: Optional[str] = None


class VizGraphEdge(BaseModel):
    """Edge in graph visualization."""
    source: str
    target: str
    type: str  # Edge type
    weight: Optional[float] = None


class VizGraphResponse(BaseModel):
    """Response with graph visualization data."""
    nodes: list[VizGraphNode]
    edges: list[VizGraphEdge]
    stats: dict


@router.post("/viz/embeddings", response_model=VizEmbeddingsResponse)
async def get_embedding_visualization(request: VizEmbeddingsRequest):
    """Get 2D projection of embeddings for visualization.
    
    Returns user and game embeddings projected to 2D using t-SNE, UMAP, or PCA.
    Like the Reddit embedding visualization from Jure Leskovec's demo.
    """
    embedding_service = get_embedding_service()
    
    points = []
    all_embeddings = []
    all_ids = []
    all_types = []
    all_labels = []
    
    # Collect embeddings from Qdrant
    try:
        from qdrant_client import QdrantClient
        from qdrant_client.http.models import ScrollRequest
        
        settings = get_settings()
        client = QdrantClient(host=settings.qdrant_host, port=settings.qdrant_port)
        
        # Get user embeddings
        if request.include_users:
            try:
                user_points, _ = client.scroll(
                    collection_name="lightgcn_users",
                    limit=request.max_points // 2 if request.include_games else request.max_points,
                    with_vectors=True,
                    with_payload=True
                )
                for point in user_points:
                    all_embeddings.append(point.vector)
                    user_id = point.payload.get("user_id", str(point.id))
                    all_ids.append(f"user:{user_id}")
                    all_types.append("user")
                    all_labels.append(user_id[:8] + "..." if len(user_id) > 8 else user_id)
            except Exception as e:
                logger.warning(f"Could not load user embeddings: {e}")
        
        # Get game embeddings
        if request.include_games:
            try:
                game_points, _ = client.scroll(
                    collection_name="lightgcn_games",
                    limit=request.max_points // 2 if request.include_users else request.max_points,
                    with_vectors=True,
                    with_payload=True
                )
                for point in game_points:
                    all_embeddings.append(point.vector)
                    game_slug = point.payload.get("game_slug", str(point.id))
                    all_ids.append(f"game:{game_slug}")
                    all_types.append("game")
                    all_labels.append(game_slug)
            except Exception as e:
                logger.warning(f"Could not load game embeddings: {e}")
        
    except Exception as e:
        logger.error(f"Failed to connect to Qdrant: {e}")
        raise HTTPException(status_code=503, detail="Could not connect to vector database")
    
    if not all_embeddings:
        return VizEmbeddingsResponse(
            points=[],
            stats={"total_points": 0, "num_users": 0, "num_games": 0},
            projection_method=request.projection,
            dimensions=request.dimensions
        )
    
    # Compute N-dimensional projection (2D or 3D)
    embeddings_array = np.array(all_embeddings)
    projected = _compute_projection(embeddings_array, method=request.projection, n_components=request.dimensions)
    
    # Normalize to [-1, 1] range for easier frontend rendering
    projected = (projected - projected.min(axis=0)) / (projected.max(axis=0) - projected.min(axis=0) + 1e-10)
    projected = projected * 2 - 1  # Scale to [-1, 1]
    
    # Build response
    for i in range(len(all_ids)):
        point_data = {
            "id": all_ids[i],
            "type": all_types[i],
            "x": float(projected[i, 0]),
            "y": float(projected[i, 1]),
            "label": all_labels[i]
        }
        if request.dimensions == 3:
            point_data["z"] = float(projected[i, 2])
        points.append(VizEmbeddingPoint(**point_data))
    
    num_users = sum(1 for t in all_types if t == "user")
    num_games = sum(1 for t in all_types if t == "game")
    
    return VizEmbeddingsResponse(
        points=points,
        stats={
            "total_points": len(points),
            "num_users": num_users,
            "num_games": num_games,
            "embedding_dim": embeddings_array.shape[1] if embeddings_array.shape[0] > 0 else 0
        },
        projection_method=request.projection,
        dimensions=request.dimensions
    )


@router.post("/viz/graph", response_model=VizGraphResponse)
async def get_graph_visualization(request: VizGraphRequest):
    """Get graph structure for visualization.
    
    Returns nodes and edges from the LightGCN bipartite graph or HGT heterogeneous graph.
    """
    nodes = []
    edges = []
    
    # Try HGT graph first (richer structure)
    if _state.get("hgt_graph") is not None:
        graph = _state["hgt_graph"]
        from app.models.hgt import NodeType, EdgeType
        
        node_colors = {
            NodeType.USER: "#3b82f6",      # blue
            NodeType.GAME: "#10b981",      # green
            NodeType.PROVIDER: "#f59e0b",  # amber
            NodeType.PROMOTION: "#ef4444", # red
            NodeType.DEVICE: "#8b5cf6",    # purple
            NodeType.BADGE: "#ec4899"      # pink
        }
        
        node_count = 0
        for node_type in NodeType:
            type_nodes = graph.num_nodes.get(node_type, 0)
            if type_nodes == 0:
                continue
            
            # Get mapping for this type
            if node_type == NodeType.USER:
                mapping = graph.user_id_to_idx
            elif node_type == NodeType.GAME:
                mapping = graph.game_slug_to_idx
            elif node_type == NodeType.PROVIDER:
                mapping = graph.provider_to_idx
            elif node_type == NodeType.PROMOTION:
                mapping = graph.promotion_to_idx
            elif node_type == NodeType.DEVICE:
                mapping = graph.device_to_idx
            elif node_type == NodeType.BADGE:
                mapping = graph.badge_to_idx
            else:
                continue
            
            # Add nodes (limit per type)
            limit_per_type = request.max_nodes // len([n for n in NodeType if graph.num_nodes.get(n, 0) > 0])
            for name, idx in list(mapping.items())[:limit_per_type]:
                nodes.append(VizGraphNode(
                    id=f"{node_type.value}:{name}",
                    type=node_type.value,
                    label=name[:20] if len(name) > 20 else name,
                    color=node_colors.get(node_type, "#6b7280")
                ))
                node_count += 1
                if node_count >= request.max_nodes:
                    break
            
            if node_count >= request.max_nodes:
                break
        
        # Add edges
        node_ids = {n.id for n in nodes}
        edge_count = 0
        
        for edge_type, edge_index in graph.edge_index.items():
            src_type, _, dst_type = edge_type
            
            src_mapping = _get_mapping_for_type(graph, src_type)
            dst_mapping = _get_mapping_for_type(graph, dst_type)
            
            if src_mapping is None or dst_mapping is None:
                continue
            
            src_idx_to_id = {v: k for k, v in src_mapping.items()}
            dst_idx_to_id = {v: k for k, v in dst_mapping.items()}
            
            # Get weights if available
            weights = graph.edge_weight.get(edge_type)
            
            for i in range(edge_index.shape[1]):
                src_idx = edge_index[0, i].item()
                dst_idx = edge_index[1, i].item()
                
                src_name = src_idx_to_id.get(src_idx)
                dst_name = dst_idx_to_id.get(dst_idx)
                
                if src_name is None or dst_name is None:
                    continue
                
                src_id = f"{src_type.value}:{src_name}"
                dst_id = f"{dst_type.value}:{dst_name}"
                
                if src_id in node_ids and dst_id in node_ids:
                    weight = weights[i].item() if weights is not None else None
                    edges.append(VizGraphEdge(
                        source=src_id,
                        target=dst_id,
                        type=edge_type[1].value if hasattr(edge_type[1], 'value') else str(edge_type[1]),
                        weight=weight if request.include_weights else None
                    ))
                    edge_count += 1
                    if edge_count >= request.max_edges:
                        break
            
            if edge_count >= request.max_edges:
                break
        
        return VizGraphResponse(
            nodes=nodes,
            edges=edges,
            stats={
                "total_nodes": len(nodes),
                "total_edges": len(edges),
                "node_types": list({n.type for n in nodes}),
                "edge_types": list({e.type for e in edges}),
                "graph_type": "heterogeneous"
            }
        )
    
    # Fallback to LightGCN bipartite graph
    elif _state.get("graph_data") is not None:
        graph_data = _state["graph_data"]
        
        # Add user nodes
        user_limit = min(request.max_nodes // 2, graph_data.num_users)
        for user_id, idx in list(graph_data.user_id_to_idx.items())[:user_limit]:
            nodes.append(VizGraphNode(
                id=f"user:{user_id}",
                type="user",
                label=user_id[:8] + "..." if len(user_id) > 8 else user_id,
                color="#3b82f6"
            ))
        
        # Add game nodes
        game_limit = min(request.max_nodes // 2, graph_data.num_games)
        for game_slug, idx in list(graph_data.game_slug_to_idx.items())[:game_limit]:
            nodes.append(VizGraphNode(
                id=f"game:{game_slug}",
                type="game",
                label=game_slug,
                color="#10b981"
            ))
        
        # Add edges
        node_ids = {n.id for n in nodes}
        idx_to_user = {v: k for k, v in graph_data.user_id_to_idx.items()}
        idx_to_game = {v: k for k, v in graph_data.game_slug_to_idx.items()}
        
        edge_index = graph_data.edge_index
        edge_weight = graph_data.edge_weight
        
        edge_count = 0
        for i in range(edge_index.shape[1]):
            src_idx = edge_index[0, i].item()
            dst_idx = edge_index[1, i].item() - graph_data.num_users  # Adjust for bipartite indexing
            
            if src_idx < graph_data.num_users:
                # User -> Game edge
                user_id = idx_to_user.get(src_idx)
                game_slug = idx_to_game.get(dst_idx)
                
                if user_id and game_slug:
                    src_id = f"user:{user_id}"
                    dst_id = f"game:{game_slug}"
                    
                    if src_id in node_ids and dst_id in node_ids:
                        weight = edge_weight[i].item() if edge_weight is not None else None
                        edges.append(VizGraphEdge(
                            source=src_id,
                            target=dst_id,
                            type="interaction",
                            weight=weight if request.include_weights else None
                        ))
                        edge_count += 1
                        if edge_count >= request.max_edges:
                            break
        
        return VizGraphResponse(
            nodes=nodes,
            edges=edges,
            stats={
                "total_nodes": len(nodes),
                "total_edges": len(edges),
                "node_types": ["user", "game"],
                "edge_types": ["interaction"],
                "graph_type": "bipartite"
            }
        )
    
    else:
        return VizGraphResponse(
            nodes=[],
            edges=[],
            stats={
                "total_nodes": 0,
                "total_edges": 0,
                "message": "No graph data loaded. Train a model first."
            }
        )


def _get_mapping_for_type(graph, node_type):
    """Get the ID mapping for a node type."""
    from app.models.hgt import NodeType
    
    if node_type == NodeType.USER:
        return graph.user_id_to_idx
    elif node_type == NodeType.GAME:
        return graph.game_slug_to_idx
    elif node_type == NodeType.PROVIDER:
        return graph.provider_to_idx
    elif node_type == NodeType.PROMOTION:
        return graph.promotion_to_idx
    elif node_type == NodeType.DEVICE:
        return graph.device_to_idx
    elif node_type == NodeType.BADGE:
        return graph.badge_to_idx
    return None


@router.get("/viz/collections")
async def get_vector_collections():
    """Get information about all vector collections in Qdrant."""
    try:
        from qdrant_client import QdrantClient
        
        settings = get_settings()
        client = QdrantClient(host=settings.qdrant_host, port=settings.qdrant_port)
        
        collections = client.get_collections().collections
        
        result = []
        for coll in collections:
            info = client.get_collection(coll.name)
            
            # Handle different qdrant-client versions
            points_count = getattr(info, 'points_count', 0)
            vectors_count = getattr(info, 'vectors_count', points_count)
            
            # Get vector size from config
            vector_size = None
            try:
                if hasattr(info.config, 'params') and hasattr(info.config.params, 'vectors'):
                    vectors = info.config.params.vectors
                    if hasattr(vectors, 'size'):
                        vector_size = vectors.size
                    elif isinstance(vectors, dict) and '' in vectors:
                        vector_size = vectors[''].size
            except Exception:
                pass
            
            result.append({
                "name": coll.name,
                "vectors_count": vectors_count,
                "points_count": points_count,
                "status": info.status.value if hasattr(info.status, 'value') else str(info.status),
                "vector_size": vector_size
            })
        
        return {"collections": result}
        
    except Exception as e:
        logger.error(f"Failed to get collections: {e}")
        raise HTTPException(status_code=503, detail=str(e))


@router.get("/viz/sample_embeddings/{collection_name}")
async def get_sample_embeddings(collection_name: str, limit: int = 10):
    """Get sample embeddings from a collection."""
    try:
        from qdrant_client import QdrantClient
        
        settings = get_settings()
        client = QdrantClient(host=settings.qdrant_host, port=settings.qdrant_port)
        
        points, _ = client.scroll(
            collection_name=collection_name,
            limit=limit,
            with_vectors=True,
            with_payload=True
        )
        
        result = []
        for point in points:
            result.append({
                "id": str(point.id),
                "payload": point.payload,
                "vector_preview": point.vector[:5] if point.vector else None,  # First 5 dims
                "vector_dim": len(point.vector) if point.vector else 0
            })
        
        return {"collection": collection_name, "samples": result}
        
    except Exception as e:
        logger.error(f"Failed to get samples: {e}")
        raise HTTPException(status_code=500, detail=str(e))

