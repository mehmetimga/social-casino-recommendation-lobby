-- User events table for tracking behavior
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS user_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(255) NOT NULL,
    game_slug VARCHAR(255) NOT NULL,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('impression', 'click', 'play_start', 'play_end')),
    duration_seconds INTEGER,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT valid_duration CHECK (
        (event_type = 'play_end' AND duration_seconds IS NOT NULL) OR
        (event_type != 'play_end')
    )
);

CREATE INDEX idx_user_events_user_id ON user_events(user_id);
CREATE INDEX idx_user_events_game_slug ON user_events(game_slug);
CREATE INDEX idx_user_events_created_at ON user_events(created_at);
CREATE INDEX idx_user_events_type ON user_events(event_type);
