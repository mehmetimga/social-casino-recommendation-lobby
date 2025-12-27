"""FastAPI application for Casino ML Service.

Provides LightGCN-based collaborative filtering recommendations.
"""

import structlog
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

from app.config import get_settings
from app.api.routes import router
from app.services.embedding_service import EmbeddingService

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    settings = get_settings()
    logger.info(
        "Starting Casino ML Service",
        service=settings.service_name,
        debug=settings.debug
    )
    
    # Initialize embedding service and collections
    try:
        embedding_service = EmbeddingService()
        embedding_service.init_collections()
        logger.info("Initialized Qdrant collections")
    except Exception as e:
        logger.warning("Failed to initialize Qdrant collections", error=str(e))
    
    yield
    
    logger.info("Shutting down Casino ML Service")


# Create FastAPI app
app = FastAPI(
    title="Casino ML Service",
    description="LightGCN-based collaborative filtering for game recommendations",
    version="1.0.0",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,  # Don't use credentials with wildcard origins
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Add Prometheus metrics
Instrumentator().instrument(app).expose(app)

# Include API routes
app.include_router(router, prefix="/v1", tags=["ml"])


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "service": "Casino ML Service",
        "version": "1.0.0",
        "docs": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8083,
        reload=settings.debug
    )

