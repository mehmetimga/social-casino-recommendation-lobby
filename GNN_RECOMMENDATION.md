# Graph Neural Networks for Game Recommendations

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [GNN Models](#gnn-models)
   - [LightGCN](#lightgcn)
   - [TGN](#tgn-temporal-graph-networks)
   - [HGT](#hgt-heterogeneous-graph-transformer)
4. [Recommendation Cascade](#recommendation-cascade)
5. [Training Pipeline](#training-pipeline)
6. [API Reference](#api-reference)
7. [Performance Comparison](#performance-comparison)
8. [Future Improvements](#future-improvements)
9. [References](#references)

---

## Overview

Our recommendation system uses **Graph Neural Networks (GNNs)** to learn user and game representations from interaction data. Unlike traditional content-based methods that rely on text embeddings, GNNs capture **collaborative signals** - patterns in how users interact with games.

### Why Graph Neural Networks?

| Approach | Method | Captures |
|----------|--------|----------|
| **Content-Based** | Text embeddings (nomic-embed-text) | Game attributes (description, tags) |
| **Collaborative Filtering** | Matrix factorization | "Users like you also played..." |
| **Graph Neural Networks** | Message passing on graphs | Both collaborative + structural patterns |

### GNN Advantages

1. **Collaborative Filtering**: Learn from user behavior patterns
2. **Higher-Order Relationships**: Capture multi-hop connections (user→game→other users→other games)
3. **Cold-Start Handling**: New users/games can leverage graph structure
4. **Rich Relationships**: Handle multiple entity types (users, games, providers, promotions)
5. **Temporal Awareness**: Learn from time-based patterns (session context)

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          RECOMMENDATION CASCADE                               │
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │     TGN     │───▶│     HGT     │───▶│  LightGCN   │───▶│  Content    │   │
│  │  (Session)  │    │ (Hetero)    │    │  (Collab)   │    │   Based     │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│        │                  │                  │                  │            │
│        ▼                  ▼                  ▼                  ▼            │
│  Session-aware      Cold-start        Collaborative       Text embeddings   │
│  recommendations    handling          patterns            (fallback)        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                              ML SERVICE (Python)                             │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         GNN Models (PyTorch)                            │ │
│  │  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                │ │
│  │  │   LightGCN   │   │     TGN      │   │     HGT      │                │ │
│  │  │              │   │              │   │              │                │ │
│  │  │ • Bipartite  │   │ • Temporal   │   │ • Multi-type │                │ │
│  │  │ • BPR Loss   │   │ • Memory     │   │ • Attention  │                │ │
│  │  │ • 3 Layers   │   │ • Session    │   │ • Meta-paths │                │ │
│  │  └──────────────┘   └──────────────┘   └──────────────┘                │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         Graph Builders                                  │ │
│  │  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                │ │
│  │  │ GraphBuilder │   │ Temporal     │   │ Hetero       │                │ │
│  │  │ (Bipartite)  │   │ GraphBuilder │   │ GraphBuilder │                │ │
│  │  └──────────────┘   └──────────────┘   └──────────────┘                │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
└────────────────────────────────────┼─────────────────────────────────────────┘
                                     │
                          ┌──────────┼──────────┐
                          ▼          ▼          ▼
                    ┌──────────┐ ┌──────────┐ ┌──────────┐
                    │PostgreSQL│ │  Qdrant  │ │   CMS    │
                    │(Events)  │ │(Vectors) │ │(Games)   │
                    └──────────┘ └──────────┘ └──────────┘
```

---

## GNN Models

### LightGCN

**Paper**: [LightGCN: Simplifying and Powering Graph Convolution Network for Recommendation](https://arxiv.org/abs/2002.02126)

LightGCN is our **baseline collaborative filtering** model. It learns user and game embeddings by propagating signals through a user-game bipartite graph.

#### Graph Structure

```
User Nodes: [U₀, U₁, U₂, ...]
Game Nodes: [G₀, G₁, G₂, ...]

Edges: User → Game (weighted by interaction strength)
       Game → User (reverse edges for message passing)

Example:
  U₁ ──(3.5)──▶ G_mega-moolah
  U₁ ──(2.0)──▶ G_starburst
  U₂ ──(4.0)──▶ G_mega-moolah
```

#### Key Simplifications

LightGCN removes complex components from traditional GCNs:

| Component | Standard GCN | LightGCN |
|-----------|--------------|----------|
| Feature transformation | ✅ Weight matrices | ❌ Removed |
| Nonlinear activation | ✅ ReLU, etc. | ❌ Removed |
| Self-connection | ✅ Identity | ❌ Removed |
| Aggregation | Sum/Mean | **Weighted Mean** |

#### Architecture

```python
class LightGCN(nn.Module):
    """
    LightGCN for collaborative filtering.
    
    Forward pass:
    1. Initialize user/game embeddings
    2. For each layer k:
       - Propagate embeddings through graph
       - No transformation or activation
    3. Final embedding = mean of all layers
    """
    
    def __init__(self, num_users, num_items, embedding_dim=768, num_layers=3):
        self.user_embedding = nn.Embedding(num_users, embedding_dim)
        self.item_embedding = nn.Embedding(num_items, embedding_dim)
        self.num_layers = num_layers
    
    def forward(self, edge_index, edge_weight):
        # Get initial embeddings
        user_emb = self.user_embedding.weight
        item_emb = self.item_embedding.weight
        all_emb = torch.cat([user_emb, item_emb])
        
        # Layer-wise propagation
        emb_layers = [all_emb]
        for _ in range(self.num_layers):
            all_emb = propagate(all_emb, edge_index, edge_weight)
            emb_layers.append(all_emb)
        
        # Mean of all layers
        final_emb = torch.stack(emb_layers).mean(dim=0)
        
        return final_emb[:num_users], final_emb[num_users:]
```

#### Training (BPR Loss)

We use **Bayesian Personalized Ranking (BPR)** loss:

```
L_BPR = -Σ log σ(r_ui - r_uj)

Where:
- r_ui = user u's score for positive item i
- r_uj = user u's score for negative item j
- σ = sigmoid function
```

**Training triplets**: (user, positive_game, negative_game)
- Positive: game the user interacted with
- Negative: random game not interacted with

#### Edge Weight Calculation

Edges are weighted based on interaction strength:

```python
def calculate_edge_weight(event_type, duration_seconds, rating, sentiment):
    if event_type == 'impression':
        return 0.2
    elif event_type == 'click':
        return 1.0
    elif event_type == 'game_time':
        return 2.0 + log(duration_seconds + 1)
    elif event_type == 'rating':
        # Rating 1→-6, Rating 5→+8
        return -6.0 + 14.0 * (rating - 1) / 4
    
    # Time decay: 7-day half-life
    decay = 0.5 ** (days_ago / 7)
    return weight * decay
```

---

### TGN (Temporal Graph Networks)

**Paper**: [Temporal Graph Networks for Deep Learning on Dynamic Graphs](https://arxiv.org/abs/2006.10637)

TGN adds **temporal awareness** for session-based recommendations. It tracks user state over time and adapts to current session context.

#### Key Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    TGN Architecture                              │
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐         │
│  │ Time Encoder │   │   Memory     │   │  Temporal    │         │
│  │              │   │   Module     │   │  Attention   │         │
│  │ t → Fourier  │   │ GRU update   │   │  Recent >    │         │
│  │   features   │   │ per user     │   │  older       │         │
│  └──────────────┘   └──────────────┘   └──────────────┘         │
│         │                  │                  │                  │
│         └─────────────────┼──────────────────┘                  │
│                           ▼                                      │
│                  ┌──────────────┐                                │
│                  │    Output    │                                │
│                  │  Embeddings  │                                │
│                  └──────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

#### 1. Time Encoding

Converts timestamps to learnable features:

```python
class TimeEncoder(nn.Module):
    """
    Encodes time delta using Fourier features.
    
    Time(Δt) = [cos(w₁Δt), sin(w₁Δt), cos(w₂Δt), sin(w₂Δt), ...]
    """
    def __init__(self, dim):
        self.basis = nn.Parameter(torch.randn(dim // 2) * 10)
    
    def forward(self, delta_t):
        scaled = delta_t.unsqueeze(-1) * self.basis
        return torch.cat([torch.cos(scaled), torch.sin(scaled)], dim=-1)
```

#### 2. Memory Module

Each user has a **memory vector** that updates with interactions:

```python
class MemoryModule(nn.Module):
    """
    Maintains per-user memory that evolves over time.
    
    Memory update: m_t = GRU(m_{t-1}, [message, time_encoding])
    """
    def __init__(self, memory_dim, message_dim):
        self.gru = nn.GRUCell(message_dim + time_dim, memory_dim)
        self.memory = {}  # user_id → memory_vector
    
    def update(self, user_id, message, time_encoding):
        if user_id not in self.memory:
            self.memory[user_id] = torch.zeros(self.memory_dim)
        
        input = torch.cat([message, time_encoding])
        self.memory[user_id] = self.gru(input, self.memory[user_id])
```

#### 3. Temporal Attention

Weighs recent neighbors more heavily:

```python
class TemporalAttention(nn.Module):
    """
    Attends to neighbors with time-aware weighting.
    
    Attention = softmax(Q·K / √d · time_weight)
    time_weight = exp(-λ·Δt)  # Recent interactions have higher weight
    """
    def forward(self, query, neighbors, timestamps):
        # Time decay
        time_weights = torch.exp(-self.decay * time_deltas)
        
        # Attention scores
        scores = torch.matmul(query, neighbors.T) / sqrt(d)
        scores = scores * time_weights
        
        return softmax(scores) @ neighbors
```

#### Session Tracking

TGN tracks current session state for real-time recommendations:

```python
class SessionService:
    """
    Tracks user sessions for real-time TGN updates.
    
    Session = {
        start_time: timestamp,
        interactions: [(game_slug, event_type, timestamp), ...],
        memory: TGN memory state
    }
    """
    def __init__(self, session_timeout=30*60):  # 30 minutes
        self.sessions = {}
        self.timeout = session_timeout
    
    def add_interaction(self, user_id, game_slug, event_type, timestamp):
        session = self.get_or_create_session(user_id)
        session.interactions.append((game_slug, event_type, timestamp))
        
        # Update TGN memory
        self.update_memory(user_id, game_slug, timestamp)
        
    def get_session_context(self, user_id):
        session = self.sessions.get(user_id)
        if not session or session.is_expired():
            return None
        return {
            "recent_games": [i[0] for i in session.interactions[-10:]],
            "duration": time.now() - session.start_time,
            "memory": session.memory
        }
```

---

### HGT (Heterogeneous Graph Transformer)

**Paper**: [Heterogeneous Graph Transformer](https://arxiv.org/abs/2003.01332)

HGT handles **multiple node and edge types** for rich relationship modeling and cold-start handling.

#### Heterogeneous Graph Structure

```
Node Types:
  • USER      - Platform users
  • GAME      - Games in catalog
  • PROVIDER  - Game studios (NetEnt, Pragmatic, etc.)
  • PROMOTION - Promotional campaigns
  • DEVICE    - Device types (mobile, desktop)
  • BADGE     - Game badges (new, hot, jackpot)

Edge Types:
  • PLAYED     - User → Game (interaction strength)
  • RATED      - User → Game (rating value)
  • MADE_BY    - Game → Provider
  • FEATURES   - Promotion → Game
  • USES       - User → Device
  • HAS_BADGE  - Game → Badge
```

```
               ┌──────────┐
               │ Provider │
               │ (NetEnt) │
               └────┬─────┘
                    │ MADE_BY
                    ▼
┌──────┐  PLAYED  ┌──────┐  HAS_BADGE  ┌───────┐
│ User │─────────▶│ Game │◀────────────│ Badge │
└──────┘          └──────┘             │ (Hot) │
    │                 ▲                └───────┘
    │ USES            │ FEATURES
    ▼                 │
┌────────┐      ┌──────────┐
│ Device │      │ Promotion│
│(Mobile)│      │          │
└────────┘      └──────────┘
```

#### Type-Specific Attention

HGT uses **different attention mechanisms for each edge type**:

```python
class HGTConv(nn.Module):
    """
    Heterogeneous Graph Transformer Convolution.
    
    For each edge type (src_type, edge_type, dst_type):
    1. Compute type-specific Q, K, V
    2. Multi-head attention with edge-type weights
    3. Aggregate messages to destination nodes
    """
    def __init__(self, in_dim, out_dim, node_types, edge_types, num_heads=8):
        # Type-specific transformations
        self.k_linear = nn.ModuleDict()  # Keys per node type
        self.q_linear = nn.ModuleDict()  # Queries per node type
        self.v_linear = nn.ModuleDict()  # Values per node type
        
        for node_type in node_types:
            self.k_linear[node_type] = nn.Linear(in_dim, out_dim)
            self.q_linear[node_type] = nn.Linear(in_dim, out_dim)
            self.v_linear[node_type] = nn.Linear(in_dim, out_dim)
        
        # Edge-type specific attention
        self.a_linear = nn.ModuleDict()  # Attention per edge type
        self.m_linear = nn.ModuleDict()  # Message per edge type
        
        for edge_type in edge_types:
            edge_name = f"{src}__{edge}__{dst}"
            self.a_linear[edge_name] = nn.Linear(out_dim, num_heads)
            self.m_linear[edge_name] = nn.Linear(out_dim, out_dim)
    
    def forward(self, x_dict, edge_index_dict):
        # Compute K, Q, V for each node type
        k_dict = {t: self.k_linear[t](x) for t, x in x_dict.items()}
        q_dict = {t: self.q_linear[t](x) for t, x in x_dict.items()}
        v_dict = {t: self.v_linear[t](x) for t, x in x_dict.items()}
        
        # Aggregate messages per edge type
        out_dict = {t: torch.zeros_like(x) for t, x in x_dict.items()}
        
        for (src_type, edge_type, dst_type), edges in edge_index_dict.items():
            # Type-specific attention
            k_src = k_dict[src_type][edges[0]]
            q_dst = q_dict[dst_type][edges[1]]
            v_src = v_dict[src_type][edges[0]]
            
            attn = self.compute_attention(k_src, q_dst, edge_type)
            messages = self.m_linear[edge_type](v_src) * attn
            
            out_dict[dst_type].index_add_(0, edges[1], messages)
        
        return out_dict
```

#### Cold-Start Handling

For new users without interaction history, HGT uses **meta-path aggregation**:

```python
def get_cold_start_embedding(self, new_user_id, device_type=None):
    """
    Generate embedding for new user via meta-paths.
    
    Meta-paths:
    1. Device → Other Users → Games (device-based similarity)
    2. Popular Games (fallback)
    
    Example: Mobile user gets recommendations based on what 
    other mobile users like.
    """
    if device_type:
        # Find users with same device
        device_idx = self.device_to_idx[device_type]
        similar_users = self.get_users_by_device(device_idx)
        
        # Aggregate their embeddings
        user_embs = self.embeddings[NodeType.USER][similar_users]
        return user_embs.mean(dim=0)
    
    # Fallback: use popular games
    game_embs = self.embeddings[NodeType.GAME]
    popular_mask = game_embs.norm(dim=-1).topk(50).indices
    return game_embs[popular_mask].mean(dim=0)
```

#### Provider-Aware Recommendations

Games inherit context from their providers:

```python
def get_provider_games(self, provider, user_id=None, limit=10):
    """
    Get games from a specific provider, optionally personalized.
    
    Flow:
    1. Find all games connected to provider via MADE_BY edge
    2. If user_id provided: rank by user preference
    3. Otherwise: rank by game popularity (embedding norm)
    """
    # Find games by provider
    game_indices = self.edge_index[MADE_BY][provider_idx]
    
    if user_id:
        # Personalize ranking
        user_emb = self.get_user_embedding(user_id)
        game_embs = self.embeddings[NodeType.GAME][game_indices]
        scores = torch.matmul(game_embs, user_emb)
        return sorted by scores
    
    # Popularity ranking
    return sorted by embedding norms
```

---

## Recommendation Cascade

The system tries models in order, falling back on failure:

```python
def get_recommendations(user_id, limit=10):
    """
    Recommendation cascade:
    
    1. TGN (if trained + active session)
       - Uses current session context
       - Best for: returning users mid-session
    
    2. HGT (if trained)
       - Uses heterogeneous graph
       - Best for: cold-start, provider-aware
    
    3. LightGCN (if trained)
       - Uses bipartite graph
       - Best for: collaborative patterns
    
    4. Content-based (fallback)
       - Uses text embeddings
       - Best for: new games without interactions
    """
    
    # 1. Try TGN for session-aware recommendations
    if tgn_available and has_active_session(user_id):
        recs = tgn_recommend(user_id, limit)
        if recs:
            return recs, source="tgn"
    
    # 2. Try HGT for heterogeneous recommendations
    if hgt_available:
        recs = hgt_recommend(user_id, limit)
        if recs:
            source = "hgt_cold_start" if is_cold_start else "hgt"
            return recs, source
    
    # 3. Try LightGCN for collaborative filtering
    if lightgcn_available:
        recs = lightgcn_recommend(user_id, limit)
        if recs:
            return recs, source="lightgcn"
    
    # 4. Fallback to content-based
    user_vector = get_user_vector_from_qdrant(user_id)
    if user_vector:
        return search_similar_games(user_vector), source="content"
    
    # 5. No personalization available
    return [], source="popular"
```

### When to Use Each Model

| Scenario | Best Model | Why |
|----------|------------|-----|
| New user, no history | HGT | Cold-start via meta-paths |
| User mid-session | TGN | Session context matters |
| User with history | LightGCN/HGT | Collaborative patterns |
| New game | Content-based | No interaction data yet |
| Provider-specific | HGT | Multi-type relationships |
| Similar games | HGT | Shared provider/badges |

---

## Training Pipeline

### Data Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                         Training Flow                             │
│                                                                   │
│  1. Data Collection                                               │
│     ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│     │PostgreSQL  │  │    CMS     │  │   Qdrant   │               │
│     │ • Events   │  │ • Games    │  │ • Vectors  │               │
│     │ • Ratings  │  │ • Providers│  │            │               │
│     │ • Reviews  │  │ • Badges   │  │            │               │
│     └─────┬──────┘  └─────┬──────┘  └─────┬──────┘               │
│           └───────────────┼───────────────┘                       │
│                           ▼                                       │
│  2. Graph Construction                                            │
│     ┌────────────────────────────────────────────┐               │
│     │ GraphBuilder / HeteroGraphBuilder           │               │
│     │  • Build node indices                       │               │
│     │  • Create edge tensors                      │               │
│     │  • Calculate edge weights                   │               │
│     └─────────────────────┬──────────────────────┘               │
│                           ▼                                       │
│  3. Model Training                                                │
│     ┌────────────────────────────────────────────┐               │
│     │ Trainer (LightGCN/TGN/HGT)                  │               │
│     │  • Initialize embeddings                    │               │
│     │  • BPR loss optimization                    │               │
│     │  • Adam optimizer                           │               │
│     │  • Save model checkpoint                    │               │
│     └─────────────────────┬──────────────────────┘               │
│                           ▼                                       │
│  4. Embedding Sync                                                │
│     ┌────────────────────────────────────────────┐               │
│     │ Sync to Qdrant                              │               │
│     │  • Store user embeddings                    │               │
│     │  • Store game embeddings                    │               │
│     │  • Enable vector search                     │               │
│     └────────────────────────────────────────────┘               │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### Training Commands

```bash
# Train LightGCN
curl -X POST http://localhost:8083/v1/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 100,
    "batch_size": 1024
  }'

# Train TGN
curl -X POST http://localhost:8083/v1/tgn/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 50,
    "batch_size": 256
  }'

# Train HGT
curl -X POST http://localhost:8083/v1/hgt/train \
  -H "Content-Type: application/json" \
  -d '{
    "lookback_days": 30,
    "num_epochs": 100,
    "batch_size": 256,
    "cms_url": "http://cms:3001"
  }'
```

---

## API Reference

### LightGCN Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/train` | POST | Train LightGCN model |
| `/v1/recommend` | POST | Get LightGCN recommendations |
| `/v1/embedding/user/{id}` | GET | Get user embedding |
| `/v1/embedding/game/{slug}` | GET | Get game embedding |
| `/v1/status` | GET | Get model status |

### TGN Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/tgn/train` | POST | Train TGN model |
| `/v1/tgn/recommend` | POST | Get session-aware recommendations |
| `/v1/tgn/interaction` | POST | Add interaction to session |
| `/v1/tgn/session/{user_id}` | GET | Get session info |
| `/v1/tgn/session/{user_id}` | DELETE | End session |
| `/v1/tgn/status` | GET | Get TGN status |

### HGT Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/hgt/train` | POST | Train HGT model |
| `/v1/hgt/recommend` | POST | Get HGT recommendations |
| `/v1/hgt/similar_games` | POST | Find similar games |
| `/v1/hgt/provider_games` | POST | Get games by provider |
| `/v1/hgt/status` | GET | Get HGT status |
| `/v1/hgt/load` | POST | Load saved model |

---

## Performance Comparison

### Model Characteristics

| Model | Parameters | Training Time | Inference Time | Cold-Start |
|-------|------------|---------------|----------------|------------|
| **LightGCN** | ~500K | ~5 min | ~10ms | ❌ Poor |
| **TGN** | ~1M | ~10 min | ~20ms | ❌ Poor |
| **HGT** | ~2M | ~15 min | ~30ms | ✅ Good |
| **Content** | N/A | N/A | ~50ms | ✅ Good |

### Recommendation Quality

| Scenario | LightGCN | TGN | HGT | Content |
|----------|----------|-----|-----|---------|
| Heavy user | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| New user | ⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Session context | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| Provider-aware | ⭐ | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Similar games | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## Future Improvements

### 1. ContextGCN (Planned)

**Context-aware GNN** that incorporates user context (time of day, device, location):

```python
class ContextGCN(nn.Module):
    """
    Extends LightGCN with contextual features.
    
    Context includes:
    - Time of day (morning/afternoon/evening/night)
    - Day of week (weekday/weekend)
    - Device type (mobile/desktop/tablet)
    - VIP level (bronze/silver/gold/platinum)
    """
    def forward(self, edge_index, context):
        # Base embeddings from LightGCN
        user_emb, game_emb = self.lightgcn(edge_index)
        
        # Context encoding
        context_emb = self.context_encoder(context)
        
        # Context-modulated embeddings
        user_emb = user_emb * self.context_gate(context_emb)
        
        return user_emb, game_emb
```

**Expected improvement**: +10-15% in session-specific recommendations

### 2. PinSage-style Sampling

**Efficient training on large graphs** using importance sampling:

```python
class PinSageSampler:
    """
    Sample subgraphs for efficient training.
    
    Instead of training on entire graph:
    1. Sample random walks from target nodes
    2. Use importance sampling for negative samples
    3. Train on subgraph
    """
    def sample(self, target_nodes, walk_length=3):
        walks = random_walk(self.graph, target_nodes, walk_length)
        importance = PageRank(walks)
        return sample_by_importance(importance)
```

**Expected improvement**: 10x faster training on large graphs

### 3. Multi-Task Learning

**Joint optimization** of multiple objectives:

```python
class MultiTaskGNN(nn.Module):
    """
    Optimize for multiple tasks:
    1. Click prediction
    2. Play duration prediction
    3. Rating prediction
    
    Shared embeddings, task-specific heads.
    """
    def forward(self, user_emb, game_emb):
        shared = self.shared_layer(torch.cat([user_emb, game_emb]))
        
        click_prob = self.click_head(shared)
        play_duration = self.duration_head(shared)
        rating = self.rating_head(shared)
        
        return click_prob, play_duration, rating
```

**Expected improvement**: Better embedding quality from multi-signal learning

### 4. Knowledge Graph Enhancement

**Integrate external knowledge** about games:

```
Game → hasGenre → Slot
Game → hasTheme → Ancient Egypt
Game → hasFeature → Free Spins
Game → similarTo → Other Game
```

```python
class KGEnhancedGNN(nn.Module):
    """
    Incorporate knowledge graph triples.
    
    Triple: (head, relation, tail)
    Example: (mega-moolah, hasTheme, Safari)
    
    Learn relation-specific transformations.
    """
    def forward(self, entity_emb, triples):
        for head, rel, tail in triples:
            # TransE-style scoring
            transformed = entity_emb[head] + self.relation_emb[rel]
            score = -distance(transformed, entity_emb[tail])
```

**Expected improvement**: Better content understanding + explainability

### 5. Real-Time Incremental Updates

**Update embeddings without full retraining**:

```python
class IncrementalGNN:
    """
    Update embeddings when new interactions arrive.
    
    Instead of full retraining:
    1. Localized propagation around affected nodes
    2. Incremental SGD updates
    3. Periodic full refresh
    """
    def update_on_interaction(self, user_id, game_slug):
        # Localized update
        affected_nodes = get_neighbors(user_id, game_slug, k=2)
        
        # Mini-batch SGD
        loss = self.compute_local_loss(affected_nodes)
        loss.backward()
        self.optimizer.step()
```

**Expected improvement**: Fresher recommendations without training latency

### 6. Attention-based Fusion

**Learn optimal combination** of different models:

```python
class AttentionFusion(nn.Module):
    """
    Learn to combine recommendations from different models.
    
    Input: recommendations from LightGCN, TGN, HGT, Content
    Output: optimal combined ranking
    
    Attention weights based on:
    - User history
    - Context
    - Model confidence
    """
    def forward(self, recs_dict, user_context):
        weights = self.attention(user_context)  # [4]
        
        combined = sum(
            w * recs for w, recs in zip(weights, recs_dict.values())
        )
        return combined
```

**Expected improvement**: 5-10% across all user segments

---

## References

### Papers

1. **LightGCN** - He et al., 2020
   - [Paper](https://arxiv.org/abs/2002.02126)
   - Simplified GCN for collaborative filtering

2. **TGN** - Rossi et al., 2020
   - [Paper](https://arxiv.org/abs/2006.10637)
   - Temporal graph networks for dynamic graphs

3. **HGT** - Hu et al., 2020
   - [Paper](https://arxiv.org/abs/2003.01332)
   - Heterogeneous graph transformer

4. **GraphSAGE** - Hamilton et al., 2017
   - [Paper](https://arxiv.org/abs/1706.02216)
   - Inductive representation learning on graphs

5. **PinSage** - Ying et al., 2018
   - [Paper](https://arxiv.org/abs/1806.01973)
   - Graph neural networks for web-scale recommendations

6. **BPR** - Rendle et al., 2009
   - [Paper](https://arxiv.org/abs/1205.2618)
   - Bayesian personalized ranking

### Libraries

- [PyTorch Geometric](https://pytorch-geometric.readthedocs.io/) - GNN library
- [Qdrant](https://qdrant.tech/) - Vector database
- [FastAPI](https://fastapi.tiangolo.com/) - ML service framework

---

*Last updated: December 2024*

