"""FastAPI routes for ML service."""

from typing import Optional
from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel, Field
import structlog
import torch

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

