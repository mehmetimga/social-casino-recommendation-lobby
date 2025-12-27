# Casino Game Recommendation System

## Overview

The recommendation system uses a **hybrid approach** combining multiple strategies:

1. **Graph Neural Networks (GNNs)**: LightGCN, TGN, and HGT for collaborative filtering
2. **Content-based filtering**: Text embeddings for game similarity
3. **Behavioral signals**: User events, ratings, and reviews

The system uses a **cascade architecture** that tries each model in order, falling back to simpler methods when needed.

> **Detailed GNN Documentation**: See [GNN_RECOMMENDATION.md](./GNN_RECOMMENDATION.md) for in-depth coverage of LightGCN, TGN, and HGT architectures.

## Architecture

```
┌─────────────┐     ┌──────────────────────┐     ┌─────────────┐
│   Frontend  │────▶│   Recommendation     │────▶│  PostgreSQL │
│ (React/App) │     │   Service (Go)       │     │  (Events)   │
└─────────────┘     │                      │     └─────────────┘
                    │  ┌────────────────┐  │
                    │  │  GNN Cascade:  │  │     ┌─────────────┐
                    │  │  1. TGN        │  │────▶│ ML Service  │
                    │  │  2. HGT        │  │     │  (Python)   │
                    │  │  3. LightGCN   │  │     │  PyTorch    │
                    │  │  4. Content    │  │     └─────────────┘
                    │  └────────────────┘  │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼──────────┐     ┌─────────────┐
                    │       Qdrant        │◀────│   Ollama    │
                    │     (Vectors)       │     │ (Embeddings)│
                    │  • games            │     └─────────────┘
                    │  • users            │
                    │  • lightgcn_*       │
                    │  • hgt_*            │
                    └─────────────────────┘
```

## Recommendation Cascade

The system tries models in order, falling back on failure:

```
Request: GET /v1/recommendations?userId=user-123
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│ 1. TGN (Temporal Graph Networks)                              │
│    • Condition: Trained AND user has active session           │
│    • Best for: Mid-session recommendations, temporal patterns │
│    • Fallback: → HGT                                          │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ 2. HGT (Heterogeneous Graph Transformer)                      │
│    • Condition: Trained                                       │
│    • Best for: Cold-start users, provider-aware, promotions   │
│    • Fallback: → LightGCN                                     │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ 3. LightGCN (Collaborative Filtering)                         │
│    • Condition: Trained AND user has embedding                │
│    • Best for: Users with history, collaborative patterns     │
│    • Fallback: → Content-Based                                │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ 4. Content-Based (Text Embeddings)                            │
│    • Condition: User has preference vector in Qdrant          │
│    • Best for: New games without interaction data             │
│    • Fallback: → Return empty (frontend shows popular)        │
└──────────────────────────────────────────────────────────────┘
```

## Data Storage

### 1. PostgreSQL (User Behavior Data)

#### **user_events** Table
Tracks all user interactions with games:

| Column           | Type      | Description                                    |
|------------------|-----------|------------------------------------------------|
| id               | UUID      | Unique event ID                                |
| user_id          | VARCHAR   | User identifier                                |
| game_slug        | VARCHAR   | Game identifier                                |
| event_type       | VARCHAR   | Type: `impression`, `click`, `game_time`       |
| duration_seconds | INTEGER   | Play duration (for `game_time` events)         |
| metadata         | JSONB     | Additional event metadata                      |
| created_at       | TIMESTAMP | Event timestamp                                |

**Event Types:**
- `impression` - Game card was viewed (50% visible)
- `click` - Game info dialog was opened (deprecated, not used)
- `game_time` - User played the game with duration

#### **user_ratings** Table
Stores user ratings for games:

| Column     | Type      | Description                    |
|------------|-----------|--------------------------------|
| id         | UUID      | Unique rating ID               |
| user_id    | VARCHAR   | User identifier                |
| game_slug  | VARCHAR   | Game identifier                |
| rating     | INTEGER   | Rating value (1-5 stars)       |
| created_at | TIMESTAMP | First rating timestamp         |
| updated_at | TIMESTAMP | Last update timestamp          |

**Constraint:** One rating per user per game (UNIQUE on user_id, game_slug)

#### **user_reviews** Table
Stores user reviews with ratings and AI-generated sentiment analysis:

| Column          | Type         | Description                                      |
|-----------------|--------------|--------------------------------------------------|
| id              | UUID         | Unique review ID                                 |
| user_id         | VARCHAR      | User identifier                                  |
| game_slug       | VARCHAR      | Game identifier                                  |
| rating          | INTEGER      | Rating value (1-5 stars)                         |
| review_text     | TEXT         | Optional review text                             |
| sentiment_score | DECIMAL(3,2) | AI-analyzed sentiment: -1.0 (negative) to +1.0 (positive) |
| created_at      | TIMESTAMP    | First review timestamp                           |
| updated_at      | TIMESTAMP    | Last update timestamp                            |

**Constraint:** One review per user per game (UNIQUE on user_id, game_slug)

**Note:** When a review is submitted, it updates both `user_reviews` and `user_ratings` tables for backwards compatibility.

**Sentiment Score:**
- Automatically generated using Ollama LLM when review text is provided
- Range: -1.0 (very negative) to +1.0 (very positive)
- NULL if no review text or analysis failed
- Used to amplify or diminish the rating weight in recommendations

#### **user_preferences** Table
Tracks when user vectors were last updated:

| Column             | Type      | Description                           |
|--------------------|-----------|---------------------------------------|
| id                 | UUID      | Unique preference ID                  |
| user_id            | VARCHAR   | User identifier                       |
| vector_updated_at  | TIMESTAMP | Last time user vector was updated     |
| created_at         | TIMESTAMP | Record creation timestamp             |
| updated_at         | TIMESTAMP | Record update timestamp               |

### 2. Qdrant Vector Database

Qdrant stores **vector embeddings** for semantic similarity search.

#### **games** Collection
Stores game embeddings based on game content:

**Vector Dimension:** 768 (nomic-embed-text model)

**Payload (Metadata):**
```json
{
  "slug": "diamond-stars",
  "title": "Diamond Stars",
  "provider": "NetEnt",
  "type": "slot",
  "minVipLevel": "bronze",
  "tags": ["progressive", "high-volatility"],
  "description": "A classic slot game with..."
}
```

**VIP Level Values:** `bronze`, `silver`, `gold`, `platinum`
Games with higher `minVipLevel` are exclusive to users of that tier or above.

**How Game Vectors Are Created:**
1. Game data is fetched from CMS
2. A text description is generated combining:
   - Title
   - Provider
   - Game type
   - Tags/badges
   - Short description
   - Long description
3. Text is sent to Ollama (`nomic-embed-text` model)
4. Returns a 768-dimensional vector
5. Vector is stored in Qdrant with game metadata

**Example Text for Embedding:**
```
Title: Diamond Stars
Provider: NetEnt
Type: slot
Tags: progressive, high-volatility, jackpot
Description: A classic slot game with progressive jackpots and high volatility.
Features sparkling diamonds and exciting bonus rounds...
```

#### **users** Collection
Stores user preference vectors based on behavior:

**Vector Dimension:** 768 (same as games)

**Payload (Metadata):**
```json
{
  "user_id": "444c0b0b-7f83-4110-9a72-e8610c4fb046",
  "updated_at": "2025-12-21T08:45:58Z"
}
```

**How User Vectors Are Created:**
1. Fetch user's recent interactions (last 30 days)
2. Calculate weighted scores for each game:
   - Impressions: 0.2 weight
   - Clicks: 1.0 weight (deprecated)
   - Game time: 2.0 base weight × (duration bonus)
   - Ratings: -6 to +8 weight (1 star = -6, 5 stars = +8)
3. Apply time decay (7-day half-life for behavior, 90-day for ratings)
4. Fetch game vectors for interacted games
5. Create weighted average of game vectors
6. Store as user's preference vector

## Recommendation Algorithm

### Step 1: Calculate Interaction Weights

Each user interaction has a weight that indicates preference strength:

```go
const (
    ImpressionWeight   = 0.2   // Saw the game card
    ClickWeight        = 1.0   // Opened game info (deprecated)
    GameTimeBaseWeight = 2.0   // Played the game
    Rating5Weight      = 8.0   // 5-star rating
    Rating1Weight      = -6.0  // 1-star rating
)
```

**Review Text Sentiment Analysis:**
When a user submits a review with text, the system:
1. Sends the review text to Ollama LLM (llama3.2:3b model)
2. Asks the LLM to analyze sentiment on a scale of -1.0 to +1.0
3. Stores the sentiment score in the database
4. Uses sentiment to adjust the rating weight in recommendations

**Game Time Weight Formula:**
```
weight = GameTimeBaseWeight × (1 + min(duration_seconds / 300, 2))
```
- 0 seconds: weight = 2.0
- 150 seconds (2.5 min): weight = 3.0
- 300 seconds (5 min): weight = 4.0
- 600+ seconds (10+ min): weight = 6.0 (capped)

**Rating Weight Formula:**
```
weight = Rating1Weight + (Rating5Weight - Rating1Weight) × (rating - 1) / 4
```
- 1 star: -6.0 (strong dislike)
- 2 stars: -2.5
- 3 stars: +1.0 (neutral)
- 4 stars: +4.5
- 5 stars: +8.0 (strong like)

**Sentiment-Adjusted Weight (when review text is provided):**
```
final_weight = rating_weight × (1 + sentiment_score × 0.5)
```
- Very positive sentiment (+1.0): increases weight by 50%
  - Example: 4-star rating (4.5) with +1.0 sentiment = 6.75
- Positive sentiment (+0.5): increases weight by 25%
  - Example: 4-star rating (4.5) with +0.5 sentiment = 5.625
- Neutral sentiment (0.0): no change to weight
  - Example: 4-star rating (4.5) with 0.0 sentiment = 4.5
- Negative sentiment (-0.5): decreases weight by 25%
  - Example: 4-star rating (4.5) with -0.5 sentiment = 3.375
- Very negative sentiment (-1.0): decreases weight by 50%
  - Example: 1-star rating (-6.0) with -1.0 sentiment = -9.0

### Step 2: Apply Time Decay

Recent interactions matter more than old ones:

```
decay_factor = 2^(-days_ago / half_life)
```

**Half-life values:**
- Behavioral events (impressions, clicks, game_time): 7 days
- Ratings: 90 days

**Example:**
- Event from 7 days ago: weight × 0.5
- Event from 14 days ago: weight × 0.25
- Rating from 90 days ago: weight × 0.5

### Step 3: Build User Vector

```go
func (s *RecommendationService) UpdateUserVector(userID string) error {
    // 1. Fetch user events and ratings (last 30 days)
    events := s.postgresRepo.GetUserEvents(userID, since)
    ratings := s.postgresRepo.GetUserRatings(userID)

    // 2. Calculate weighted scores per game
    gameScores := make(map[string]float64)
    for event := range events {
        weight := GetEventWeight(event.EventType)
        if event.EventType == GameTime {
            weight *= calculateDurationMultiplier(event.DurationSeconds)
        }
        decay := calculateTimeDecay(event.CreatedAt, BehaviorHalfLife)
        gameScores[event.GameSlug] += weight * decay
    }

    for rating := range ratings {
        weight := GetRatingWeight(rating.Rating)
        decay := calculateTimeDecay(rating.UpdatedAt, RatingHalfLife)
        gameScores[rating.GameSlug] += weight * decay
    }

    // 3. Fetch game vectors from Qdrant
    gameVectors := make(map[string][]float32)
    for gameSlug := range gameScores {
        vector := s.qdrantRepo.GetGameVector(gameSlug)
        gameVectors[gameSlug] = vector
    }

    // 4. Create weighted average vector
    userVector := make([]float32, 768)
    totalWeight := 0.0
    for gameSlug, score := range gameScores {
        vector := gameVectors[gameSlug]
        for i := range userVector {
            userVector[i] += vector[i] * float32(score)
        }
        totalWeight += score
    }

    // Normalize
    for i := range userVector {
        userVector[i] /= float32(totalWeight)
    }

    // 5. Store user vector in Qdrant
    s.qdrantRepo.UpsertUserVector(userID, userVector)
    s.postgresRepo.UpdateUserPreferenceVectorTime(userID)

    return nil
}
```

### Step 4: Generate Recommendations

When a user requests recommendations:

```go
func (s *RecommendationService) GetRecommendations(userID string, limit int) ([]string, error) {
    // 1. Get user's preference vector from Qdrant
    userVector := s.qdrantRepo.GetUserVector(userID)

    // If no user vector, return popular games
    if userVector == nil {
        return s.getPopularGames(limit)
    }

    // 2. Search for similar games using cosine similarity
    similarGames := s.qdrantRepo.SearchSimilarGames(userVector, limit * 2)

    // 3. Filter out already played games (optional)
    // 4. Apply diversity (avoid recommending too many similar games)
    // 5. Return top N game slugs

    return gameSlugs[:limit], nil
}
```

**Qdrant Search Query:**
```go
searchResult := qdrantClient.Search(ctx, &qdrant.SearchPoints{
    CollectionName: "games",
    Vector:         userVector,
    Limit:          limit * 2,
    WithPayload:    true,
    ScoreThreshold: 0.5, // Minimum similarity threshold
})
```

## Vector Similarity Search

**Cosine Similarity** is used to find similar games:

```
similarity = (A · B) / (||A|| × ||B||)
```

Where:
- A = User preference vector
- B = Game vector
- Range: -1 to 1 (higher = more similar)

**Example:**
- User likes: High-volatility slots, progressive jackpots, NetEnt games
- User vector: [0.2, 0.8, 0.1, ..., 0.5] (768 dimensions)
- System finds games with similar vectors
- Result: Recommends other high-volatility NetEnt slots with jackpots

## Complete User Journey

### 1. New User (Cold Start)
```
User visits lobby
  ↓
No user vector exists
  ↓
System returns popular games
  ↓
User views games → impression events tracked
  ↓
User opens game info → context set
  ↓
User clicks "Play Now" → game play dialog opens
  ↓
User plays for 3 minutes → game_time event (180 seconds)
  ↓
User vector is created in background
  ↓
Next time: Personalized recommendations!
```

### 2. Returning User
```
User visits lobby
  ↓
Fetch user vector from Qdrant
  ↓
Search similar games using cosine similarity
  ↓
Return personalized recommendations
  ↓
User plays, rates, reviews games
  ↓
User vector updates in background
  ↓
Recommendations improve over time
```

### 3. Rating & Review Flow
```
User opens game info dialog
  ↓
Clicks "Rate & Review" button
  ↓
Selects rating (1-5 stars)
  ↓
Writes review text (optional)
  ↓
Submits review
  ↓
Backend analyzes sentiment using Ollama LLM
  ↓
Sentiment score calculated (-1.0 to +1.0)
  ↓
Stored in PostgreSQL (user_reviews + user_ratings)
  ↓
User vector update triggered
  ↓
Rating weight calculated:
  - 5 stars → +8.0 base weight
  - 1 star → -6.0 base weight
  ↓
Sentiment adjusts weight:
  - Positive sentiment (+0.5 to +1.0) increases by 25-50%
  - Negative sentiment (-0.5 to -1.0) decreases by 25-50%
  ↓
Example: 4 stars (+4.5) + very positive text (+1.0) = 6.75 final weight
  ↓
Negative weights push similar games away
  ↓
Positive weights attract similar games
```

## Event Tracking Flow

```javascript
// Frontend (React)

// 1. Card becomes visible (50% threshold)
IntersectionObserver → trackEvent('impression')

// 2. User clicks game card
onClick → openGameInfo()
// No event tracked (just opens dialog)

// 3. User clicks "Play Now"
onClick → openGameDialog()
// Start timer: playStartTime = Date.now()

// 4. User closes game dialog
onClose → {
  duration = Date.now() - playStartTime
  trackEvent('game_time', { durationSeconds: duration })
}

// 5. User submits review
onSubmit → {
  submitReview({
    userId,
    gameSlug,
    rating,
    reviewText
  })
}
```

```go
// Backend (Go)

// Receive event
POST /v1/events
  ↓
Validate event type
  ↓
Store in PostgreSQL (user_events table)
  ↓
If event is 'game_time' or rating:
  Trigger UpdateUserVector(userID) in background goroutine
  ↓
Fetch recent events and ratings
  ↓
Calculate weighted scores
  ↓
Fetch game vectors from Qdrant
  ↓
Create weighted average user vector
  ↓
Store user vector in Qdrant
  ↓
Update vector_updated_at in user_preferences
```

## Performance Optimizations

### 1. Async User Vector Updates
User vectors are updated asynchronously to avoid blocking the API response:

```go
go recommendationService.UpdateUserVector(userID)
```

### 2. Vector Caching
- User vectors are cached in Qdrant
- Only updated when new interactions occur
- No need to recalculate on every recommendation request

### 3. Batch Processing
- Multiple events can be batched before updating user vector
- Time-based batching (e.g., update every 5 minutes)
- Event-count-based (e.g., update after 10 new events)

### 4. Index Optimization
PostgreSQL indexes:
- `user_events(user_id, created_at)` - Fast event retrieval
- `user_events(game_slug)` - Game popularity queries
- `user_ratings(user_id, game_slug)` - Rating lookups
- `user_reviews(game_slug, created_at)` - Game reviews

Qdrant indexes:
- HNSW (Hierarchical Navigable Small World) index
- Fast approximate nearest neighbor search
- Trades accuracy for speed (acceptable for recommendations)

## Configuration

### Environment Variables

```env
# PostgreSQL connection
POSTGRES_URL=postgres://casino:secret@postgres:5432/casino_db?sslmode=disable

# Qdrant connection
QDRANT_URL=http://qdrant:6333

# Ollama for embeddings
OLLAMA_URL=http://host.docker.internal:11434

# Embedding model
EMBEDDING_MODEL=nomic-embed-text
```

### Recommendation Parameters

```go
// services/recommendation/internal/model/event.go

const (
    // Event weights
    ImpressionWeight   = 0.2
    ClickWeight        = 1.0
    GameTimeBaseWeight = 2.0

    // Rating weights
    Rating5Weight = 8.0
    Rating1Weight = -6.0

    // Time decay half-lives (days)
    BehaviorHalfLife = 7
    RatingHalfLife   = 90

    // Duration multiplier cap (seconds)
    MaxDurationForBonus = 600
)
```

## Current Features

### 1. Review Text Sentiment Analysis ✅ (Implemented)
The system now analyzes review text sentiment using Ollama LLM:
- **Automatic Analysis**: When users submit review text, the system sends it to Ollama (llama3.2:3b)
- **Sentiment Score**: LLM returns a score from -1.0 (very negative) to +1.0 (very positive)
- **Weight Adjustment**: Sentiment multiplier applied to rating weight
  - Formula: `final_weight = rating_weight × (1 + sentiment_score × 0.5)`
  - Positive sentiment amplifies positive ratings
  - Negative sentiment amplifies negative ratings
- **Smart Handling**:
  - If review has no text, sentiment is NULL (uses rating only)
  - If LLM analysis fails, review still saves (sentiment is optional)
  - Avoids double-counting (reviews override ratings for same game)

**Example Impact:**
- 5-star review with text "Amazing! Love it!" (sentiment: +0.9)
  - Base weight: +8.0
  - Adjusted weight: 8.0 × (1 + 0.9 × 0.5) = **11.6**
- 2-star review with text "Terrible, waste of time" (sentiment: -0.8)
  - Base weight: -2.5
  - Adjusted weight: -2.5 × (1 + (-0.8) × 0.5) = **-1.5** → Less negative than numeric rating alone

## Future Enhancements

### 1. Keyword Extraction from Reviews
- Extract game features mentioned in reviews (e.g., "graphics", "bonuses", "payouts")
- Build feature preference vectors for users
- Match users with games strong in their preferred features

### 2. Contextual Recommendations
- Time-based (morning vs evening games)
- Device-based (mobile-friendly games)
- Session-based (similar to current playing streak)

### 3. Diversity & Exploration
- Avoid filter bubbles
- Occasionally recommend different game types
- Balance exploitation (similar games) with exploration (new types)

### 4. Multi-Vector Approach
- Separate vectors for different aspects:
  - Game mechanics vector
  - Visual style vector
  - Volatility/risk preference vector
  - Provider preference vector

### 5. Social Signals
- Friend recommendations
- Trending games
- Community favorites

### 6. A/B Testing
- Test different recommendation algorithms
- Measure engagement metrics
- Optimize weights and parameters

## API Endpoints

### Events
```bash
# Track user event
POST /v1/events
Content-Type: application/json

{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "eventType": "game_time",
  "durationSeconds": 180
}
```

### Ratings
```bash
# Submit rating (deprecated - use reviews)
POST /v1/feedback/rating
Content-Type: application/json

{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "rating": 5
}
```

### Reviews
```bash
# Submit review with rating
POST /v1/feedback/review
Content-Type: application/json

{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "rating": 5,
  "reviewText": "Amazing game! Love the graphics."
}

# Get game reviews
GET /v1/feedback/reviews?gameSlug=diamond-stars

# Get user's review
GET /v1/feedback/review?userId=user-123&gameSlug=diamond-stars
```

### Recommendations
```bash
# Get personalized recommendations (with VIP level filtering)
GET /v1/recommendations?userId=user-123&placement=homepage-suggested&limit=10&vipLevel=gold

Response:
{
  "recommendations": [
    "diamond-stars",
    "mega-moolah",
    "starburst",
    ...
  ]
}
```

**VIP Level Parameter:**
- `bronze` (default): Only bronze-tier games
- `silver`: Bronze + silver games
- `gold`: Bronze + silver + gold games
- `platinum`: All games including platinum exclusives

Games have a `minVipLevel` metadata field. The recommendation service filters results to only include games the user's VIP tier can access.

## Monitoring & Metrics

### Key Metrics to Track

1. **Recommendation Quality**
   - Click-through rate (CTR)
   - Conversion rate (play rate)
   - Average play duration after recommendation

2. **Diversity**
   - Number of unique games recommended
   - Distribution across game types/providers

3. **Coverage**
   - % of catalog being recommended
   - Long-tail vs popular game balance

4. **User Engagement**
   - Return user rate
   - Session length
   - Games per session

5. **System Performance**
   - Vector update time
   - Recommendation latency
   - Qdrant query performance

## Troubleshooting

### User Not Getting Recommendations
1. Check if user vector exists in Qdrant
2. Verify user has enough interactions (>3 events)
3. Check vector_updated_at timestamp
4. Review event tracking in browser console

### Recommendations Not Updating
1. Verify events are being stored in PostgreSQL
2. Check if UpdateUserVector is being triggered
3. Review Qdrant connection
4. Check vector_updated_at timestamp

### Poor Recommendation Quality
1. Adjust event weights
2. Increase/decrease time decay rate
3. Review game vector quality (re-ingest games)
4. Add more interaction data

## LightGCN Collaborative Filtering (Phase 1)

In addition to the content-based approach, the system now includes **LightGCN** (Light Graph Convolutional Network) for collaborative filtering.

### Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │───▶│   ML Service    │───▶│     Qdrant      │
│  (Interactions) │    │   (LightGCN)    │    │   (Embeddings)  │
└─────────────────┘    └────────┬────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────────┐
                    │  Go Recommendation  │
                    │      Service        │
                    └─────────────────────┘
```

### How It Works

LightGCN builds a **user-game bipartite graph** from interaction data and learns embeddings through graph convolution:

1. **Graph Construction**: User events, ratings, and reviews become weighted edges
2. **Embedding Learning**: LightGCN propagates embeddings through the graph
3. **Recommendation**: Find games with similar embeddings to user's preference

### Key Benefits

- **Collaborative filtering**: Captures "users who played X also liked Y" patterns
- **Better cold-start**: Graph propagation helps new users with limited interactions
- **Complementary**: Works alongside content-based recommendations

### ML Service Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/train` | POST | Train/retrain the LightGCN model |
| `/v1/recommend` | POST | Get recommendations for a user |
| `/v1/embedding/user/{id}` | GET | Get user embedding |
| `/v1/embedding/game/{slug}` | GET | Get game embedding |
| `/v1/status` | GET | Get service status |

### Training the Model

```bash
curl -X POST http://localhost:8083/v1/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 100,
    "batch_size": 1024
  }'
```

### Hybrid Recommendations

The system can combine both approaches:

```go
// Content-based: 40% weight
// Collaborative (LightGCN): 60% weight
recommendations = GetHybridRecommendations(userID, placement, limit, vipLevel)
```

### Qdrant Collections

New collections for LightGCN embeddings:
- `lightgcn_users`: User embeddings (768-dim)
- `lightgcn_games`: Game embeddings (768-dim)

## TGN Session-Aware Recommendations (Phase 2)

TGN (Temporal Graph Networks) adds **session-aware recommendations** by tracking temporal patterns.

### How TGN Works

1. **Memory Module**: Each user has a memory vector that evolves with interactions
2. **Time Encoding**: Captures temporal patterns (time since last play, session duration)
3. **Temporal Attention**: Weighs recent session interactions more heavily
4. **Real-time Updates**: Memory updates as user plays games

### TGN API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/tgn/train` | POST | Train the TGN model |
| `/v1/tgn/recommend` | POST | Get session-aware recommendations |
| `/v1/tgn/interaction` | POST | Add interaction to session |
| `/v1/tgn/session/{user_id}` | GET | Get session information |

### Training TGN

```bash
curl -X POST http://localhost:8083/v1/tgn/train \
  -H "Content-Type: application/json" \
  -d '{"lookback_days": 30, "num_epochs": 50}'
```

### Recommendation Cascade

The system tries recommendations in this order:
1. **TGN** (session-aware) - Uses current session context
2. **HGT** (heterogeneous) - Uses multi-type graph with cold-start handling
3. **LightGCN** (collaborative) - Uses learned embeddings
4. **Content-based** (fallback) - Uses text embeddings

## HGT Heterogeneous Recommendations (Phase 3)

HGT (Heterogeneous Graph Transformer) handles **multiple node and edge types** for rich relationship modeling.

### Node Types

| Type | Description |
|------|-------------|
| `USER` | Platform users |
| `GAME` | Games in the catalog |
| `PROVIDER` | Game providers/studios (e.g., NetEnt, Pragmatic) |
| `PROMOTION` | Promotional campaigns |
| `DEVICE` | Device types (mobile, desktop, tablet) |
| `BADGE` | Game badges/labels (e.g., "new", "hot", "jackpot") |

### Edge Types

| Edge | Connects | Description |
|------|----------|-------------|
| `PLAYED` | User → Game | Weighted by interaction strength |
| `RATED` | User → Game | Weighted by rating value |
| `MADE_BY` | Game → Provider | Links game to its provider |
| `FEATURES` | Promotion → Game | Games featured in promotions |
| `USES` | User → Device | Tracks user's devices |
| `HAS_BADGE` | Game → Badge | Game's badges/labels |

### HGT API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/hgt/train` | POST | Train the HGT model |
| `/v1/hgt/recommend` | POST | Get heterogeneous recommendations |
| `/v1/hgt/similar_games` | POST | Get games similar to a given game |
| `/v1/hgt/provider_games` | POST | Get games by provider |
| `/v1/hgt/status` | GET | Get HGT service status |

### Training HGT

```bash
curl -X POST http://localhost:8083/v1/hgt/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 100,
    "batch_size": 256,
    "cms_url": "http://cms:3001"
  }'
```

### Getting HGT Recommendations

```bash
curl -X POST http://localhost:8083/v1/hgt/recommend \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user-123",
    "limit": 10,
    "exclude_games": [],
    "provider_filter": null
  }'
```

### Finding Similar Games

Uses HGT embeddings that incorporate provider, badges, and user interactions:

```bash
curl -X POST http://localhost:8083/v1/hgt/similar_games \
  -H "Content-Type: application/json" \
  -d '{
    "game_slug": "mega-moolah",
    "limit": 10
  }'
```

### Provider-Specific Recommendations

Get games from a specific provider, optionally personalized:

```bash
curl -X POST http://localhost:8083/v1/hgt/provider_games \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "NetEnt",
    "user_id": "user-123",
    "limit": 10
  }'
```

### Cold-Start Handling

HGT provides special handling for new users without interaction history:

1. **Meta-path aggregation**: New users get embeddings from connected nodes (device, similar users)
2. **Popular games fallback**: Uses game embedding norms as popularity proxy
3. **Device-based similarity**: Users with same device get similar recommendations

### How HGT Differs from LightGCN

| Aspect | LightGCN | HGT |
|--------|----------|-----|
| Node types | Users, Games only | Users, Games, Providers, Promotions, Devices, Badges |
| Edge types | Single (interaction) | Multiple (played, rated, made_by, features, etc.) |
| Attention | No attention | Type-specific attention |
| Cold-start | Limited | Better via meta-paths |
| Provider-aware | No | Yes (games share provider info) |

### HGT Graph Construction

The HGT graph is built from two sources:

1. **CMS (PayloadCMS)**: Games, providers, badges, promotions
2. **PostgreSQL**: User interactions (events, ratings, reviews)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│     CMS      │     │    HGT       │     │   Qdrant     │
│  (metadata)  │────▶│   Builder    │────▶│ (embeddings) │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
┌──────────────┐            │
│  PostgreSQL  │────────────┘
│ (interactions)│
└──────────────┘
```

## Conclusion

The recommendation system combines:
- **User behavior tracking** (PostgreSQL)
- **Semantic similarity** (Qdrant + embeddings)
- **Weighted scoring** (events, ratings, reviews)
- **Time decay** (recent > old)
- **Real-time updates** (async vector updates)
- **Collaborative filtering** (LightGCN graph neural network)
- **Session-aware recommendations** (TGN temporal patterns)
- **Heterogeneous graph modeling** (HGT multi-type relationships)

This creates a powerful, personalized recommendation engine that:
- Learns from user behavior over time
- Adapts to current session context
- Handles cold-start users gracefully
- Incorporates rich game metadata (providers, badges, promotions)
