-- User reviews table for storing game reviews
CREATE TABLE IF NOT EXISTS user_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(255) NOT NULL,
    game_slug VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT user_reviews_user_game_unique UNIQUE (user_id, game_slug)
);

CREATE INDEX idx_user_reviews_user_id ON user_reviews(user_id);
CREATE INDEX idx_user_reviews_game_slug ON user_reviews(game_slug);
CREATE INDEX idx_user_reviews_created_at ON user_reviews(created_at);
CREATE INDEX idx_user_reviews_rating ON user_reviews(rating);
