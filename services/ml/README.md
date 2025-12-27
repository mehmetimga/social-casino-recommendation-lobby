# Casino ML Service

LightGCN-based collaborative filtering recommendation service for the casino platform.

## Overview

This service implements **LightGCN** (Light Graph Convolutional Network) for collaborative filtering recommendations. It learns user and game embeddings from the user-game interaction graph, enabling:

- **Collaborative filtering**: "Users who played X also liked Y"
- **Better cold-start**: Graph propagation helps new users
- **Real-time updates**: Embeddings can be updated on new interactions

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │───▶│   ML Service    │───▶│     Qdrant      │
│  (Interactions) │    │   (LightGCN)    │    │   (Embeddings)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Go Recommend   │
                    │    Service      │
                    └─────────────────┘
```

## API Endpoints

### Training

**POST /v1/train**
Train or retrain the LightGCN model.

```bash
curl -X POST http://localhost:8083/v1/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 100,
    "batch_size": 1024,
    "force_rebuild": false
  }'
```

### Recommendations

**POST /v1/recommend**
Get recommendations for a user.

```bash
curl -X POST http://localhost:8083/v1/recommend \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user-123",
    "limit": 10,
    "exclude_games": ["game-already-played"]
  }'
```

### Embeddings

**GET /v1/embedding/user/{user_id}**
Get user embedding.

**GET /v1/embedding/game/{game_slug}**
Get game embedding.

### Status

**GET /v1/status**
Get service status including model state.

**GET /v1/health**
Health check endpoint.

## Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ML_POSTGRES_HOST` | `postgres` | PostgreSQL host |
| `ML_POSTGRES_PORT` | `5432` | PostgreSQL port |
| `ML_POSTGRES_USER` | `casino` | PostgreSQL user |
| `ML_POSTGRES_PASSWORD` | `secret` | PostgreSQL password |
| `ML_POSTGRES_DB` | `casino_db` | PostgreSQL database |
| `ML_QDRANT_HOST` | `qdrant` | Qdrant host |
| `ML_QDRANT_PORT` | `6333` | Qdrant port |
| `ML_EMBEDDING_DIM` | `768` | Embedding dimension |
| `ML_NUM_LAYERS` | `3` | Number of GCN layers |
| `ML_LEARNING_RATE` | `0.001` | Learning rate |
| `ML_BATCH_SIZE` | `1024` | Training batch size |
| `ML_NUM_EPOCHS` | `100` | Training epochs |

## Development

### Local Setup

1. Create virtual environment:
```bash
cd services/ml
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run locally:
```bash
python -m app.main
```

### Running with Docker

With GPU (NVIDIA):
```bash
docker-compose up ml
```

Without GPU (CPU only):
```bash
docker-compose -f docker-compose.yml -f services/ml/docker-compose.override.cpu.yml up ml
```

## Model Details

### LightGCN

LightGCN simplifies Graph Convolutional Networks for collaborative filtering by:

1. **Removing feature transformations** - No learnable weight matrices in convolution
2. **Removing nonlinear activations** - Linear aggregation only
3. **Using neighborhood aggregation** - Only propagates embeddings

The final embedding is the mean of embeddings from all layers:
```
e_final = (1/(K+1)) * Σ e^(k) for k = 0, 1, ..., K
```

### Training

Uses BPR (Bayesian Personalized Ranking) loss:
```
L_BPR = -log(σ(r_ui - r_uj))
```
Where r_ui is the predicted score for positive item i and r_uj for negative item j.

### Qdrant Collections

The service creates two collections:

- **lightgcn_users**: User embeddings (768-dimensional)
- **lightgcn_games**: Game embeddings (768-dimensional)

## Phase 2: TGN (Temporal Graph Networks)

TGN provides **session-aware recommendations** by tracking temporal patterns in user behavior.

### Key Features

- **Memory Module**: Stores evolving user state that updates with each interaction
- **Time Encoding**: Learns temporal patterns (time of day, session duration)
- **Session Tracking**: Real-time updates based on current session activity
- **Temporal Attention**: Weighs recent interactions more heavily

### TGN API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/tgn/train` | POST | Train the TGN model |
| `/v1/tgn/recommend` | POST | Get session-aware recommendations |
| `/v1/tgn/interaction` | POST | Add interaction to session (real-time) |
| `/v1/tgn/session/{user_id}` | GET | Get session information |
| `/v1/tgn/session/{user_id}` | DELETE | End user session |
| `/v1/tgn/status` | GET | Get TGN service status |

### Training TGN

```bash
curl -X POST http://localhost:8083/v1/tgn/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 50,
    "batch_size": 256
  }'
```

### Getting Session-Aware Recommendations

```bash
curl -X POST http://localhost:8083/v1/tgn/recommend \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user-123",
    "limit": 10,
    "exclude_recent": true
  }'
```

Response includes session context:
```json
{
  "user_id": "user-123",
  "recommendations": [
    {"game_slug": "diamond-stars", "score": 0.95}
  ],
  "session_context": {
    "active": true,
    "duration_seconds": 300,
    "num_interactions": 5,
    "recent_games": [
      {"game_slug": "mega-moolah", "event_type": "game_time"}
    ]
  },
  "source": "tgn"
}
```

### How TGN Works

1. **Temporal Edges**: User interactions are ordered by timestamp
2. **Memory Updates**: Each interaction updates the user's memory state via GRU
3. **Time Encoding**: Time deltas are encoded using learnable Fourier features
4. **Temporal Attention**: Recent neighbors are weighted by temporal distance
5. **Session Tracking**: Current session interactions influence recommendations

### Recommendation Cascade

The Go service tries recommendations in this order:
1. **TGN** (if trained and available) - Session-aware
2. **HGT** (if trained) - Heterogeneous graph with cold-start handling
3. **LightGCN** (if trained) - Collaborative filtering
4. **Content-based** (fallback) - Text embeddings

## Phase 3: HGT (Heterogeneous Graph Transformer)

HGT handles **heterogeneous graphs** with multiple node and edge types, enabling:

- **Rich relationships**: Users, games, providers, promotions, devices, badges
- **Cold-start handling**: New users get recommendations via meta-path aggregation
- **Provider-aware**: Recommendations can be filtered/personalized by provider
- **Similar games**: Find games similar via shared attributes (provider, badges)

### Node Types

| Type | Description |
|------|-------------|
| `USER` | Platform users |
| `GAME` | Games in the catalog |
| `PROVIDER` | Game providers/studios |
| `PROMOTION` | Promotional campaigns |
| `DEVICE` | Device types (mobile, desktop) |
| `BADGE` | Game badges/labels |

### Edge Types

| Edge | Connects | Weight |
|------|----------|--------|
| `PLAYED` | User → Game | Interaction strength |
| `RATED` | User → Game | Rating value |
| `MADE_BY` | Game → Provider | - |
| `FEATURES` | Promotion → Game | - |
| `USES` | User → Device | - |
| `HAS_BADGE` | Game → Badge | - |

### HGT API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/hgt/train` | POST | Train the HGT model |
| `/v1/hgt/recommend` | POST | Get heterogeneous recommendations |
| `/v1/hgt/similar_games` | POST | Get games similar to a given game |
| `/v1/hgt/provider_games` | POST | Get games by provider |
| `/v1/hgt/status` | GET | Get HGT service status |
| `/v1/hgt/load` | POST | Load a saved HGT model |

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

### Getting Heterogeneous Recommendations

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

Response:
```json
{
  "user_id": "user-123",
  "recommendations": [
    {"game_slug": "diamond-stars", "score": 0.95}
  ],
  "source": "hgt",
  "is_cold_start": false
}
```

### Finding Similar Games

```bash
curl -X POST http://localhost:8083/v1/hgt/similar_games \
  -H "Content-Type: application/json" \
  -d '{
    "game_slug": "mega-moolah",
    "limit": 10
  }'
```

### Provider-Specific Games

```bash
curl -X POST http://localhost:8083/v1/hgt/provider_games \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "NetEnt",
    "user_id": "user-123",
    "limit": 10
  }'
```

### How HGT Works

1. **Heterogeneous Graph**: Nodes and edges of different types are loaded from CMS and PostgreSQL
2. **Type-Specific Attention**: Each edge type has its own attention mechanism
3. **Multi-hop Aggregation**: Information flows through multiple layers
4. **Meta-Path Aggregation**: For cold-start, aggregates embeddings from connected nodes
5. **Provider/Badge Enrichment**: Games inherit context from their provider and badges

### Cold-Start Handling

For new users without interaction history:
1. HGT falls back to popular games (based on embedding norms)
2. If device info is available, uses device-based similarity
3. Future: Can use demographic data for initial recommendations

## Future Improvements

### ContextGCN
Add context-aware recommendations that incorporate:
- **Time of day** (morning/afternoon/evening/night)
- **Day of week** (weekday/weekend)
- **Device type** (mobile/desktop/tablet)
- **VIP level** (bronze/silver/gold/platinum)

### PinSage-style Sampling
For large-scale graphs, implement importance sampling:
- Random walks from target nodes
- PageRank-based importance weighting
- Efficient subgraph training

### Multi-Task Learning
Joint optimization of multiple objectives:
- Click prediction
- Play duration prediction
- Rating prediction
- Shared embeddings with task-specific heads

### Knowledge Graph Enhancement
Integrate external game knowledge:
- Genre relationships (Slot → Progressive Jackpot)
- Theme relationships (Game → Ancient Egypt)
- Feature relationships (Game → Free Spins)

### Real-Time Incremental Updates
Update embeddings without full retraining:
- Localized propagation around affected nodes
- Incremental SGD updates
- Periodic full refresh for consistency

### Attention-based Fusion
Learn optimal model combination:
- Attention weights based on user context
- Dynamic model selection
- Confidence-weighted ensembling

## References

- [LightGCN Paper](https://arxiv.org/abs/2002.02126)
- [TGN Paper](https://arxiv.org/abs/2006.10637)
- [HGT Paper](https://arxiv.org/abs/2003.01332)
- [PinSage Paper](https://arxiv.org/abs/1806.01973)
- [GraphSAGE Paper](https://arxiv.org/abs/1706.02216)
- [PyTorch Geometric](https://pytorch-geometric.readthedocs.io/)
- [BPR Loss](https://arxiv.org/abs/1205.2618)

