"""Configuration for the ML service."""

import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Service settings
    service_name: str = "casino-ml-service"
    debug: bool = False
    
    # PostgreSQL connection
    postgres_host: str = "postgres"
    postgres_port: int = 5432
    postgres_user: str = "casino"
    postgres_password: str = "secret"
    postgres_db: str = "casino_db"
    
    @property
    def postgres_url(self) -> str:
        return f"postgresql://{self.postgres_user}:{self.postgres_password}@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
    
    @property
    def postgres_async_url(self) -> str:
        return f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
    
    # Qdrant connection
    qdrant_host: str = "qdrant"
    qdrant_port: int = 6333
    
    @property
    def qdrant_url(self) -> str:
        return f"http://{self.qdrant_host}:{self.qdrant_port}"
    
    # LightGCN model settings
    embedding_dim: int = 768  # Match existing Qdrant vector size
    num_layers: int = 3
    learning_rate: float = 0.001
    batch_size: int = 1024
    num_epochs: int = 100
    
    # Collections
    lightgcn_users_collection: str = "lightgcn_users"
    lightgcn_games_collection: str = "lightgcn_games"
    hgt_users_collection: str = "hgt_users"
    hgt_games_collection: str = "hgt_games"
    
    # Model storage
    model_path: str = "/app/models/lightgcn_model.pt"
    hgt_model_path: str = "/app/models/hgt_model.pt"
    tgn_model_path: str = "/app/models/tgn_model.pt"
    
    # Event weights (match Go service)
    impression_weight: float = 0.2
    click_weight: float = 1.0
    game_time_base_weight: float = 2.0
    rating_5_weight: float = 8.0
    rating_1_weight: float = -6.0
    
    # Time decay
    behavior_half_life_days: int = 7
    rating_half_life_days: int = 90
    
    # HGT specific settings
    hgt_hidden_dim: int = 256
    hgt_num_layers: int = 2
    hgt_num_heads: int = 8
    hgt_dropout: float = 0.1
    
    # CMS URL for fetching game metadata
    cms_url: str = "http://cms:3001"
    
    class Config:
        env_prefix = "ML_"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()

