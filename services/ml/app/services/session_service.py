"""Session service for tracking user sessions and real-time TGN updates.

Manages:
- User session lifecycle
- Real-time interaction tracking
- Memory updates for TGN
- Session-aware recommendation context
"""

import time
from typing import Optional, Dict, List, Tuple
from dataclasses import dataclass, field
from datetime import datetime, timedelta
import threading
import structlog

from app.config import get_settings
from app.models.tgn import TGN, TGNInference

logger = structlog.get_logger()


@dataclass
class SessionInteraction:
    """A single interaction within a session."""
    game_slug: str
    game_idx: int
    timestamp: float
    event_type: str
    weight: float
    duration_seconds: Optional[int] = None


@dataclass
class UserSession:
    """User session with interaction history."""
    user_id: str
    user_idx: int
    start_time: float
    last_activity: float
    interactions: List[SessionInteraction] = field(default_factory=list)
    
    def is_expired(self, timeout_minutes: int = 30) -> bool:
        """Check if session has expired."""
        return time.time() - self.last_activity > timeout_minutes * 60
    
    def add_interaction(self, interaction: SessionInteraction):
        """Add an interaction to the session."""
        self.interactions.append(interaction)
        self.last_activity = interaction.timestamp
    
    def get_recent_games(self, n: int = 10) -> List[Tuple[int, float]]:
        """Get recent game indices and timestamps."""
        recent = self.interactions[-n:]
        return [(i.game_idx, i.timestamp) for i in recent]
    
    @property
    def session_duration(self) -> float:
        """Get session duration in seconds."""
        return self.last_activity - self.start_time
    
    @property
    def num_interactions(self) -> int:
        """Get number of interactions in session."""
        return len(self.interactions)


class SessionService:
    """Service for managing user sessions and TGN integration."""
    
    EVENT_TYPE_MAP = {
        'impression': 0,
        'click': 1,
        'game_time': 2,
        'play_end': 2,
        'play_start': 2,
        'rating': 3,
        'review': 4
    }
    
    def __init__(
        self,
        tgn_inference: Optional[TGNInference] = None,
        session_timeout_minutes: int = 30
    ):
        """Initialize session service.
        
        Args:
            tgn_inference: Optional TGN inference wrapper
            session_timeout_minutes: Session timeout in minutes
        """
        self.settings = get_settings()
        self.tgn = tgn_inference
        self.session_timeout = session_timeout_minutes
        
        # Active sessions: user_id -> UserSession
        self.sessions: Dict[str, UserSession] = {}
        
        # ID mappings (populated from training data)
        self.user_id_to_idx: Dict[str, int] = {}
        self.game_slug_to_idx: Dict[str, int] = {}
        self.idx_to_game_slug: Dict[int, str] = {}
        
        # Lock for thread safety
        self._lock = threading.Lock()
        
        # Stats
        self.total_sessions = 0
        self.total_interactions = 0
    
    def set_tgn(self, tgn_inference: TGNInference):
        """Set the TGN inference wrapper."""
        self.tgn = tgn_inference
    
    def set_mappings(
        self,
        user_id_to_idx: Dict[str, int],
        game_slug_to_idx: Dict[str, int]
    ):
        """Set ID mappings from training data."""
        self.user_id_to_idx = user_id_to_idx
        self.game_slug_to_idx = game_slug_to_idx
        self.idx_to_game_slug = {v: k for k, v in game_slug_to_idx.items()}
    
    def get_or_create_session(self, user_id: str) -> UserSession:
        """Get existing session or create new one.
        
        Args:
            user_id: User ID
            
        Returns:
            UserSession object
        """
        with self._lock:
            # Check for existing active session
            if user_id in self.sessions:
                session = self.sessions[user_id]
                if not session.is_expired(self.session_timeout):
                    return session
                else:
                    # Session expired, clean up
                    del self.sessions[user_id]
            
            # Create new session
            user_idx = self.user_id_to_idx.get(user_id, -1)
            
            session = UserSession(
                user_id=user_id,
                user_idx=user_idx,
                start_time=time.time(),
                last_activity=time.time()
            )
            
            self.sessions[user_id] = session
            self.total_sessions += 1
            
            # Initialize TGN session
            if self.tgn and user_idx >= 0:
                self.tgn.start_session(user_id)
            
            logger.debug(
                "Created new session",
                user_id=user_id,
                user_idx=user_idx
            )
            
            return session
    
    def _get_event_weight(
        self,
        event_type: str,
        duration_seconds: Optional[int] = None,
        rating: Optional[int] = None
    ) -> float:
        """Calculate event weight."""
        if event_type == 'impression':
            return self.settings.impression_weight
        elif event_type == 'click':
            return self.settings.click_weight
        elif event_type in ('game_time', 'play_end', 'play_start'):
            import math
            weight = self.settings.game_time_base_weight
            if duration_seconds and duration_seconds > 0:
                weight += math.log(duration_seconds + 1)
            return weight
        elif event_type in ('rating', 'review') and rating:
            return self.settings.rating_1_weight + (
                self.settings.rating_5_weight - self.settings.rating_1_weight
            ) * (rating - 1) / 4
        return 1.0
    
    def add_interaction(
        self,
        user_id: str,
        game_slug: str,
        event_type: str,
        duration_seconds: Optional[int] = None,
        rating: Optional[int] = None,
        timestamp: Optional[float] = None
    ) -> bool:
        """Add an interaction to user's session and update TGN.
        
        Args:
            user_id: User ID
            game_slug: Game slug
            event_type: Event type
            duration_seconds: Optional duration for game_time events
            rating: Optional rating value
            timestamp: Optional timestamp (defaults to now)
            
        Returns:
            True if interaction was processed, False if game not found
        """
        if timestamp is None:
            timestamp = time.time()
        
        # Get game index
        game_idx = self.game_slug_to_idx.get(game_slug, -1)
        if game_idx < 0:
            logger.debug("Game not in training data", game_slug=game_slug)
            return False
        
        # Calculate weight
        weight = self._get_event_weight(event_type, duration_seconds, rating)
        
        # Get or create session
        session = self.get_or_create_session(user_id)
        
        # Create interaction
        interaction = SessionInteraction(
            game_slug=game_slug,
            game_idx=game_idx,
            timestamp=timestamp,
            event_type=event_type,
            weight=weight,
            duration_seconds=duration_seconds
        )
        
        # Add to session
        with self._lock:
            session.add_interaction(interaction)
            self.total_interactions += 1
        
        # Update TGN memory if available
        if self.tgn and session.user_idx >= 0:
            event_type_idx = self.EVENT_TYPE_MAP.get(event_type, 0)
            self.tgn.add_interaction(
                user_id=user_id,
                user_idx=session.user_idx,
                item_idx=game_idx,
                timestamp=timestamp,
                event_type=event_type_idx,
                weight=weight
            )
        
        logger.debug(
            "Added interaction",
            user_id=user_id,
            game_slug=game_slug,
            event_type=event_type,
            weight=weight
        )
        
        return True
    
    def get_session_recommendations(
        self,
        user_id: str,
        limit: int = 10,
        exclude_recent: bool = True
    ) -> List[Tuple[str, float]]:
        """Get session-aware recommendations using TGN.
        
        Args:
            user_id: User ID
            limit: Number of recommendations
            exclude_recent: Whether to exclude recently played games
            
        Returns:
            List of (game_slug, score) tuples
        """
        session = self.get_or_create_session(user_id)
        
        if self.tgn is None or session.user_idx < 0:
            logger.debug("TGN not available or user not in training data")
            return []
        
        # Get excluded games (recently played in this session)
        exclude_items = None
        if exclude_recent:
            exclude_items = set(i.game_idx for i in session.interactions[-5:])
        
        # Get TGN recommendations
        recommendations = self.tgn.get_recommendations(
            user_id=user_id,
            user_idx=session.user_idx,
            current_time=time.time(),
            top_k=limit,
            exclude_items=exclude_items
        )
        
        # Convert indices to slugs
        result = []
        for item_idx, score in recommendations:
            game_slug = self.idx_to_game_slug.get(item_idx)
            if game_slug:
                result.append((game_slug, score))
        
        return result
    
    def get_session_context(self, user_id: str) -> dict:
        """Get session context for debugging/logging.
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary with session information
        """
        if user_id not in self.sessions:
            return {"active": False}
        
        session = self.sessions[user_id]
        
        return {
            "active": not session.is_expired(self.session_timeout),
            "user_idx": session.user_idx,
            "start_time": datetime.fromtimestamp(session.start_time).isoformat(),
            "duration_seconds": session.session_duration,
            "num_interactions": session.num_interactions,
            "recent_games": [
                {
                    "game_slug": i.game_slug,
                    "event_type": i.event_type,
                    "weight": i.weight
                }
                for i in session.interactions[-5:]
            ]
        }
    
    def end_session(self, user_id: str):
        """End a user's session.
        
        Args:
            user_id: User ID
        """
        with self._lock:
            if user_id in self.sessions:
                if self.tgn:
                    self.tgn.clear_session(user_id)
                del self.sessions[user_id]
                logger.debug("Ended session", user_id=user_id)
    
    def cleanup_expired_sessions(self):
        """Remove expired sessions."""
        with self._lock:
            expired = [
                user_id for user_id, session in self.sessions.items()
                if session.is_expired(self.session_timeout)
            ]
            
            for user_id in expired:
                if self.tgn:
                    self.tgn.clear_session(user_id)
                del self.sessions[user_id]
            
            if expired:
                logger.info(f"Cleaned up {len(expired)} expired sessions")
    
    def get_stats(self) -> dict:
        """Get service statistics."""
        return {
            "active_sessions": len(self.sessions),
            "total_sessions": self.total_sessions,
            "total_interactions": self.total_interactions,
            "known_users": len(self.user_id_to_idx),
            "known_games": len(self.game_slug_to_idx),
            "tgn_available": self.tgn is not None
        }

