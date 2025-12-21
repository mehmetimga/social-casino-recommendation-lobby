-- Add game_time event type support
-- This migration adds the 'game_time' event type which replaces play_start and play_end
-- The game_time event includes the total duration the game was played in durationSeconds

-- Drop existing constraints
ALTER TABLE user_events DROP CONSTRAINT IF EXISTS user_events_event_type_check;
ALTER TABLE user_events DROP CONSTRAINT IF EXISTS valid_duration;

-- Add new constraints with game_time support
ALTER TABLE user_events ADD CONSTRAINT user_events_event_type_check
    CHECK (event_type IN ('impression', 'click', 'play_start', 'play_end', 'game_time'));

ALTER TABLE user_events ADD CONSTRAINT valid_duration
    CHECK (
        (event_type IN ('play_end', 'game_time') AND duration_seconds IS NOT NULL) OR
        (event_type NOT IN ('play_end', 'game_time'))
    );
