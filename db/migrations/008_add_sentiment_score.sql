-- Add sentiment_score column to user_reviews table
-- Sentiment score ranges from -1.0 (very negative) to +1.0 (very positive)
-- NULL means sentiment hasn't been analyzed yet (e.g., no review text)

ALTER TABLE user_reviews
ADD COLUMN IF NOT EXISTS sentiment_score DECIMAL(3,2);

-- Add check constraint to ensure sentiment score is between -1 and 1
ALTER TABLE user_reviews
ADD CONSTRAINT sentiment_score_range
CHECK (sentiment_score IS NULL OR (sentiment_score >= -1.0 AND sentiment_score <= 1.0));

-- Add index for sentiment-based queries
CREATE INDEX IF NOT EXISTS idx_user_reviews_sentiment
ON user_reviews(game_slug, sentiment_score)
WHERE sentiment_score IS NOT NULL;

COMMENT ON COLUMN user_reviews.sentiment_score IS 'AI-generated sentiment score from review text: -1.0 (very negative) to +1.0 (very positive). NULL if no review text or not yet analyzed.';
