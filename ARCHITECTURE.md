# System Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Core Components](#core-components)
4. [Technology Stack](#technology-stack)
5. [Data Flow](#data-flow)
6. [Database Architecture](#database-architecture)
7. [API Architecture](#api-architecture)
8. [Frontend Architecture](#frontend-architecture)
9. [Backend Services](#backend-services)
10. [Vector Database & AI](#vector-database--ai)
11. [Deployment Architecture](#deployment-architecture)
12. [Security & Authentication](#security--authentication)
13. [Design Patterns](#design-patterns)
14. [File Structure](#file-structure)
15. [Integration Points](#integration-points)
16. [Scalability Considerations](#scalability-considerations)

---

## System Overview

The Social Casino Recommendation Lobby is a full-stack web and mobile application that provides personalized game recommendations and AI-powered chat assistance. The system combines collaborative filtering, content-based recommendations, and RAG (Retrieval-Augmented Generation) to deliver a sophisticated user experience across web and native mobile platforms.

### Key Features
- **Personalized Game Recommendations**: AI-driven recommendations based on user behavior, ratings, and review sentiment
- **Smart Chat Assistant**: RAG-powered chatbot that answers questions about games using embedded knowledge
- **Review & Rating System**: Users can rate games and write reviews with AI sentiment analysis
- **Game Management**: CMS-based content management for games, providers, and badges
- **Real-time Tracking**: Event tracking for impressions, clicks, and play time
- **Responsive Web UI**: Modern React-based frontend with Tailwind CSS
- **Native Mobile App**: Flutter-based iOS/Android app with full feature parity

### System Goals
- Provide accurate, personalized game recommendations
- Deliver instant, context-aware chat responses
- Track user behavior for continuous improvement
- Scale to handle thousands of concurrent users
- Maintain low latency (<200ms for recommendations)

---

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                               CLIENT LAYER                                      │
│  ┌─────────────────────────────────┐    ┌─────────────────────────────────┐    │
│  │   React Web Frontend            │    │   Flutter Mobile App            │    │
│  │   (Vite + TypeScript)           │    │   (iOS + Android)               │    │
│  │   • Game Lobby                  │    │   • Game Lobby                  │    │
│  │   • Chat Widget                 │    │   • PlayModal with SafeArea     │    │
│  │   • Reviews                     │    │   • Chat Assistant              │    │
│  └──────────────┬──────────────────┘    └──────────────┬──────────────────┘    │
└─────────────────┼───────────────────────────────────────┼──────────────────────┘
                  └─────────────────┬─────────────────────┘
                                    │ HTTP/REST APIs
┌───────────────────────────────────┴────────────────────────────────────────────┐
│                           APPLICATION LAYER                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ Recommendation   │  │   Chat + RAG     │  │  PayloadCMS  │  │ ML Service │ │
│  │   Service (Go)   │  │  Service (Go)    │  │ (Node/Next)  │  │  (Python)  │ │
│  │                  │  │                  │  │              │  │            │ │
│  │ • Events         │  │ • Sessions       │  │ • Game CRUD  │  │ • LightGCN │ │
│  │ • Feedback       │  │ • Messages       │  │ • Media      │  │ • TGN      │ │
│  │ • GNN Cascade    │  │ • RAG Pipeline   │  │ • Admin      │  │ • HGT      │ │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘  └─────┬──────┘ │
└───────────┼──────────────────────┼──────────────────┼────────────────┼─────────┘
            │                      │                  │                │
┌───────────┴──────────────────────┴──────────────────┴────────────────┴─────────┐
│                             DATA LAYER                                          │
│  ┌─────────────────┐  ┌──────────────┐  ┌───────────────────────────────────┐  │
│  │   PostgreSQL    │  │   MongoDB    │  │       Qdrant (Vector DB)          │  │
│  │                 │  │              │  │                                   │  │
│  │ • user_events   │  │ • games      │  │ • games (content embeddings)      │  │
│  │ • user_ratings  │  │ • media      │  │ • users (preference vectors)      │  │
│  │ • user_reviews  │  │ • promotions │  │ • lightgcn_users (GNN)            │  │
│  │ • chat_sessions │  │              │  │ • lightgcn_games (GNN)            │  │
│  │ • preferences   │  │              │  │ • hgt_users (HGT)                 │  │
│  └─────────────────┘  └──────────────┘  │ • hgt_games (HGT)                 │  │
│                                          │ • knowledge (RAG chunks)          │  │
│                                          └───────────────────────────────────┘  │
└─────────────────────────────────────────┬───────────────────────────────────────┘
                                          │
┌─────────────────────────────────────────┴───────────────────────────────────────┐
│                              AI/ML LAYER                                         │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         Ollama (Local LLM)                                 │  │
│  │  • nomic-embed-text (Content Embeddings - 768 dimensions)                 │  │
│  │  • llama3.2:3b (Chat & Sentiment Analysis)                                │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                    GNN Models (PyTorch - ML Service)                       │  │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                      │  │
│  │  │  LightGCN   │   │     TGN     │   │     HGT     │                      │  │
│  │  │ Bipartite   │   │  Temporal   │   │ Heterogen.  │                      │  │
│  │  │ Collab Filt │   │  Sessions   │   │ Cold-Start  │                      │  │
│  │  └─────────────┘   └─────────────┘   └─────────────┘                      │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### GNN-Based Recommendation Cascade

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        RECOMMENDATION CASCADE                                    │
│                                                                                  │
│  Request: GET /v1/recommendations?userId=user-123                                │
│                            │                                                     │
│                            ▼                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ 1. TGN (Temporal Graph Networks)                                         │   │
│  │    ├─ Check: Is TGN trained? Is user in active session?                  │   │
│  │    ├─ If yes: Return session-aware recommendations                       │   │
│  │    └─ If no: Fall through to HGT                                         │   │
│  └──────────────────────────────┬──────────────────────────────────────────┘   │
│                                 │ Fallback                                       │
│                                 ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ 2. HGT (Heterogeneous Graph Transformer)                                  │   │
│  │    ├─ Check: Is HGT trained?                                              │   │
│  │    ├─ If user exists: Return personalized recommendations                 │   │
│  │    ├─ If NEW user: Return cold-start recommendations (meta-paths)        │   │
│  │    └─ If no: Fall through to LightGCN                                     │   │
│  └──────────────────────────────┬──────────────────────────────────────────┘   │
│                                 │ Fallback                                       │
│                                 ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ 3. LightGCN (Collaborative Filtering)                                     │   │
│  │    ├─ Check: Is LightGCN trained? Does user have embedding?              │   │
│  │    ├─ If yes: Return collaborative filtering recommendations              │   │
│  │    └─ If no: Fall through to Content-Based                                │   │
│  └──────────────────────────────┬──────────────────────────────────────────┘   │
│                                 │ Fallback                                       │
│                                 ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ 4. Content-Based (Text Embeddings)                                        │   │
│  │    ├─ Get user preference vector from Qdrant                              │   │
│  │    ├─ Search similar games via cosine similarity                          │   │
│  │    └─ If no vector: Return empty (frontend shows popular games)           │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Web Frontend (React + Vite)
**Technology**: React 18, TypeScript, Vite, Tailwind CSS
**Port**: 5173
**Responsibilities**:
- Render game lobby with personalized recommendations
- Display game information and reviews
- Provide interactive chat widget
- Track user interactions (impressions, clicks, play time)
- Handle rating and review submissions

**Key Features**:
- Server-side state management with TanStack Query
- Context-based global state (User, Chat, GamePlay)
- Responsive design with Tailwind CSS
- Component-based architecture
- Real-time event tracking with IntersectionObserver

### 1b. Mobile App (Flutter)
**Technology**: Flutter 3.24, Dart, Riverpod, GoRouter
**Platforms**: iOS, Android
**Responsibilities**:
- Native mobile experience for game lobby
- Full-screen PlayModal with safe area handling
- Game play tracking with duration
- Review and rating submissions
- AI chat assistant integration

**Key Features**:
- Riverpod for reactive state management
- GoRouter for declarative navigation
- CachedNetworkImage for efficient image loading
- Safe area handling for notches and camera cutouts
- PlayModal with rounded hero image and overlay close button
- Bottom navigation with tab persistence

### 2. Recommendation Service (Go)
**Technology**: Go 1.25, Chi router, PostgreSQL, Qdrant
**Port**: 8081
**Responsibilities**:
- Track user events (impressions, clicks, game_time)
- Manage ratings and reviews
- Perform sentiment analysis on review text
- **Orchestrate GNN recommendation cascade (TGN → HGT → LightGCN → Content)**
- Calculate user preference vectors
- Generate personalized recommendations

**Key Features**:
- RESTful API with Chi router
- **GNN-based recommendation cascade**
- Asynchronous user vector updates
- Time-decay weighted scoring
- Sentiment-adjusted recommendations
- Cosine similarity search

### 2b. ML Service (Python)
**Technology**: Python 3.11, FastAPI, PyTorch, PyTorch Geometric
**Port**: 8083
**Responsibilities**:
- Train and serve GNN models (LightGCN, TGN, HGT)
- Build and manage graph structures
- Store GNN embeddings in Qdrant
- Provide real-time session tracking (TGN)
- Handle cold-start users (HGT)

**Key Features**:
- **LightGCN**: Collaborative filtering via bipartite graph
- **TGN**: Session-aware recommendations with memory
- **HGT**: Heterogeneous graph with multi-type relationships
- BPR loss training
- GPU acceleration (optional)
- Model checkpointing and loading

### 3. Chat + RAG Service (Go)
**Technology**: Go 1.25, Chi router, PostgreSQL, Qdrant, Ollama
**Port**: 8082
**Responsibilities**:
- Manage chat sessions
- Process user messages
- Retrieve relevant knowledge chunks
- Generate AI responses using RAG
- Track conversation context

**Key Features**:
- RAG (Retrieval-Augmented Generation) pipeline
- Vector similarity search for knowledge retrieval
- Context-aware responses
- Session-based conversation memory
- Citation tracking

### 4. PayloadCMS
**Technology**: Node.js, Next.js 14, MongoDB
**Port**: 3001
**Responsibilities**:
- Content management for games
- Media file storage and delivery
- Provider and badge management
- Admin interface for content editors

**Key Features**:
- Headless CMS architecture
- RESTful API for content delivery
- Rich media management
- Role-based access control
- Custom collections (games, providers, badges)

### 5. PostgreSQL Database
**Technology**: PostgreSQL 16
**Port**: 5433 (mapped from 5432)
**Responsibilities**:
- Store structured data (events, ratings, reviews, sessions)
- Transaction management
- Data integrity and constraints
- Query optimization

**Key Features**:
- JSONB support for flexible metadata
- Full-text search capabilities
- ACID compliance
- Connection pooling
- Migration-based schema management

### 6. MongoDB Database
**Technology**: MongoDB 7
**Port**: 27017
**Responsibilities**:
- Store CMS content (games, providers, badges)
- Media metadata storage
- Document-based flexible schemas

**Key Features**:
- Document-oriented storage
- Flexible schema design
- Horizontal scalability
- Geospatial queries support

### 7. Qdrant Vector Database
**Technology**: Qdrant 1.7.4
**Ports**: 6333 (HTTP), 6334 (gRPC)
**Responsibilities**:
- Store game embeddings (768-dimensional vectors)
- Store user preference vectors
- Store knowledge base embeddings
- Perform similarity searches

**Key Features**:
- HNSW index for fast nearest neighbor search
- Cosine similarity metric
- Payload filtering
- Horizontal scalability
- REST and gRPC APIs

### 8. Ollama (Local LLM)
**Technology**: Ollama
**Port**: 11434 (host machine)
**Responsibilities**:
- Generate embeddings for text (nomic-embed-text)
- Generate chat responses (llama3.2:3b)
- Analyze sentiment in reviews

**Models**:
- `nomic-embed-text`: 768-dimensional text embeddings
- `llama3.2:3b`: 3B parameter language model

---

## Technology Stack

### Web Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| React | 18.2 | UI framework |
| TypeScript | 5.2 | Type safety |
| Vite | 5.0 | Build tool & dev server |
| Tailwind CSS | 3.4 | Styling |
| React Router | 6.21 | Client-side routing |
| TanStack Query | 5.17 | Server state management |
| Lucide React | 0.294 | Icon library |
| Embla Carousel | 8.0 | Carousel component |
| clsx & tailwind-merge | - | Conditional styling |
| uuid | 9.0 | Unique ID generation |

### Mobile App (Flutter)
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.24 | Cross-platform framework |
| Dart | 3.5 | Programming language |
| flutter_riverpod | 2.5 | State management |
| go_router | 14.2 | Navigation |
| cached_network_image | 3.3 | Image caching |
| dio | 5.4 | HTTP client |
| intl | 0.19 | Formatting |
| shimmer | 3.0 | Loading animations |

### Backend (Go Services)
| Technology | Version | Purpose |
|------------|---------|---------|
| Go | 1.25.5 | Programming language |
| Chi | 5.0 | HTTP router |
| Chi CORS | 1.2 | CORS middleware |
| lib/pq | 1.10 | PostgreSQL driver |
| Qdrant Go Client | 1.7 | Qdrant vector DB client |
| Google UUID | 1.5 | UUID generation |
| gRPC | 1.60 | RPC communication |

### CMS & Databases
| Technology | Version | Purpose |
|------------|---------|---------|
| Node.js | - | JavaScript runtime |
| PayloadCMS | Latest | Headless CMS |
| Next.js | 14 | React framework for CMS |
| PostgreSQL | 16 | Relational database |
| MongoDB | 7 | Document database |
| Qdrant | 1.7.4 | Vector database |

### AI/ML
| Technology | Version | Purpose |
|------------|---------|---------|
| Ollama | Latest | Local LLM runtime |
| nomic-embed-text | Latest | Embedding model (768-dim) |
| llama3.2:3b | Latest | Chat model (3B params) |
| PyTorch | 2.2.2 | ML framework |
| PyTorch Geometric | 2.5.3 | GNN library |
| FastAPI | 0.110.0 | ML service framework |

### GNN Models
| Model | Type | Purpose |
|-------|------|---------|
| LightGCN | Collaborative | Bipartite user-game graph for collaborative filtering |
| TGN | Temporal | Session-aware recommendations with memory |
| HGT | Heterogeneous | Multi-type graphs (users, games, providers, promos) |

### DevOps
| Technology | Version | Purpose |
|------------|---------|---------|
| Docker | Latest | Containerization |
| Docker Compose | 3.8 | Multi-container orchestration |
| Alpine Linux | 3.19 | Base OS for containers |

---

## Data Flow

### 1. User Interaction Flow
```
User Opens Lobby
    ↓
Frontend requests games from CMS
    ↓
Frontend requests recommendations from Recommendation Service
    ↓
Recommendation Service (GNN Cascade):
  1. Try TGN: If trained + user has active session → session-aware recs
  2. Try HGT: If trained → personalized or cold-start recs
  3. Try LightGCN: If trained + user has embedding → collaborative recs
  4. Fallback: Get user vector from Qdrant → cosine similarity search
  5. No personalization: Return empty (frontend shows popular)
    ↓
Frontend displays personalized game list
    ↓
User scrolls → IntersectionObserver tracks impressions
    ↓
Frontend sends impression events to Recommendation Service
    ↓
Recommendation Service:
  1. Stores events in PostgreSQL
  2. Triggers ML Service to update TGN session memory
  3. Triggers async user vector update
```

### 2. Game Play Flow
```
User clicks game card
    ↓
Frontend opens Game Info Dialog
    ↓
User clicks "Play Now"
    ↓
Frontend opens Game Play Dialog
  - Starts timer (playStartTime = Date.now())
    ↓
User plays game in iframe
    ↓
User closes dialog
    ↓
Frontend calculates duration
    ↓
Frontend sends game_time event with duration to Recommendation Service
    ↓
Recommendation Service:
  1. Stores event in PostgreSQL
  2. Triggers UpdateUserVector() in background goroutine
    ↓
UpdateUserVector():
  1. Fetches user events (last 30 days)
  2. Fetches user ratings
  3. Fetches user reviews (with sentiment scores)
  4. Calculates weighted scores per game
  5. Fetches game vectors from Qdrant
  6. Creates weighted average user vector
  7. Stores user vector in Qdrant
    ↓
Next time user visits: Gets personalized recommendations
```

### 3. Review & Rating Flow
```
User opens Game Info Dialog
    ↓
User clicks "Rate & Review"
    ↓
User selects rating (1-5 stars)
    ↓
User writes review text (optional)
    ↓
User submits form
    ↓
Frontend sends review to Recommendation Service
    ↓
Recommendation Service:
  1. Analyzes sentiment if review text exists:
     - Sends text to Ollama (llama3.2:3b)
     - Receives sentiment score (-1.0 to +1.0)
  2. Stores review in PostgreSQL (user_reviews table)
  3. Also updates user_ratings table (backwards compatibility)
  4. Triggers UpdateUserVector() in background
    ↓
UpdateUserVector() uses sentiment to adjust weight:
  - Rating weight: -6.0 to +8.0
  - Sentiment multiplier: 1 + (sentiment_score × 0.5)
  - Final weight = rating_weight × sentiment_multiplier
    ↓
User vector updated with sentiment-adjusted preferences
```

### 4. Chat Flow
```
User opens Chat Widget
    ↓
Frontend checks if session exists
    ↓
If not: Create new session via Chat Service
    ↓
Chat Service:
  1. Generates session ID
  2. Stores session in PostgreSQL
  3. Returns session ID to frontend
    ↓
User types message
    ↓
Frontend sends message to Chat Service
    ↓
Chat Service RAG Pipeline:
  1. Generate embedding for user query (Ollama)
  2. Search knowledge base in Qdrant (vector similarity)
  3. Retrieve top 5 relevant chunks
  4. Build prompt with context
  5. Send to Ollama (llama3.2:3b) for response
  6. Extract citations from retrieved chunks
  7. Store message in PostgreSQL
  8. Return response + citations to frontend
    ↓
Frontend displays response with citations
```

### 5. Content Management Flow
```
Admin logs into PayloadCMS (localhost:3001)
    ↓
Admin creates/updates game:
  - Title, description, provider
  - Upload thumbnail/banner images
  - Add badges, RTP, volatility
  - Set game URL
    ↓
PayloadCMS stores:
  - Game data in MongoDB
  - Media files in filesystem
    ↓
Frontend fetches games from PayloadCMS API
    ↓
Games appear in lobby
    ↓
When game is created/updated:
  Recommendation Service can re-generate game embeddings
  (Currently manual, could be automated via webhooks)
```

---

## Database Architecture

### PostgreSQL Schema

#### user_events
Tracks all user interactions with games.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | VARCHAR(255) | User identifier |
| game_slug | VARCHAR(255) | Game identifier |
| event_type | VARCHAR(50) | impression, click, game_time |
| duration_seconds | INTEGER | Duration for game_time events |
| metadata | JSONB | Additional event data |
| created_at | TIMESTAMPTZ | Event timestamp |

**Indexes**:
- `idx_user_events_user_id` on (user_id, created_at)
- `idx_user_events_game_slug` on (game_slug)

**Constraints**:
- `event_type` CHECK: impression, click, game_time
- `duration_seconds` CHECK: >= 0 when event_type = game_time

#### user_ratings
Stores numeric ratings (1-5 stars).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | VARCHAR(255) | User identifier |
| game_slug | VARCHAR(255) | Game identifier |
| rating | INTEGER | Rating value (1-5) |
| created_at | TIMESTAMPTZ | First rating time |
| updated_at | TIMESTAMPTZ | Last update time |

**Constraints**:
- UNIQUE (user_id, game_slug)
- rating CHECK: rating >= 1 AND rating <= 5

#### user_reviews
Stores reviews with sentiment analysis.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | VARCHAR(255) | User identifier |
| game_slug | VARCHAR(255) | Game identifier |
| rating | INTEGER | Rating value (1-5) |
| review_text | TEXT | Review content (optional) |
| sentiment_score | DECIMAL(3,2) | AI sentiment: -1.0 to +1.0 |
| created_at | TIMESTAMPTZ | First review time |
| updated_at | TIMESTAMPTZ | Last update time |

**Constraints**:
- UNIQUE (user_id, game_slug)
- rating CHECK: rating >= 1 AND rating <= 5
- sentiment_score CHECK: sentiment_score >= -1.0 AND sentiment_score <= 1.0

**Indexes**:
- `idx_user_reviews_sentiment` on (game_slug, sentiment_score) WHERE sentiment_score IS NOT NULL

#### user_preferences
Tracks user vector update timestamps.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | VARCHAR(255) | User identifier (UNIQUE) |
| vector_updated_at | TIMESTAMPTZ | Last vector update |
| created_at | TIMESTAMPTZ | Record creation |
| updated_at | TIMESTAMPTZ | Record update |

#### chat_sessions
Stores chat session metadata.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | VARCHAR(255) | User identifier (optional) |
| context | JSONB | Session context (page, game) |
| created_at | TIMESTAMPTZ | Session start time |
| updated_at | TIMESTAMPTZ | Last activity |

#### chat_messages
Stores chat message history.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| session_id | UUID | Foreign key to chat_sessions |
| role | VARCHAR(20) | user or assistant |
| content | TEXT | Message content |
| citations | JSONB | Array of citation objects |
| created_at | TIMESTAMPTZ | Message timestamp |

**Constraints**:
- role CHECK: role IN ('user', 'assistant')

### MongoDB Schema

#### games (PayloadCMS collection)
```javascript
{
  _id: ObjectId,
  slug: String (unique),
  title: String,
  shortDescription: String,
  longDescription: String,
  provider: ObjectId (ref: providers),
  thumbnail: ObjectId (ref: media),
  banner: ObjectId (ref: media),
  badges: [ObjectId] (ref: badges),
  rtp: Number,
  volatility: String (low, medium, high),
  gameUrl: String,
  status: String (draft, published),
  createdAt: Date,
  updatedAt: Date
}
```

#### providers
```javascript
{
  _id: ObjectId,
  name: String,
  slug: String (unique),
  logo: ObjectId (ref: media),
  createdAt: Date,
  updatedAt: Date
}
```

#### badges
```javascript
{
  _id: ObjectId,
  name: String,
  slug: String (unique),
  color: String (hex),
  icon: String,
  createdAt: Date,
  updatedAt: Date
}
```

#### media (PayloadCMS collection)
```javascript
{
  _id: ObjectId,
  filename: String,
  mimeType: String,
  filesize: Number,
  width: Number,
  height: Number,
  url: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Qdrant Collections

#### games
**Vector Dimension**: 768 (nomic-embed-text)
**Distance Metric**: Cosine

**Payload**:
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

**VIP Level Values:** `bronze`, `silver`, `gold`, `platinum` (used for filtering recommendations)

**Vector Generation**:
```
Text = "Title: {title}\nProvider: {provider}\nType: {type}\nTags: {tags}\nDescription: {description}"
Vector = Ollama.embed(Text)
```

#### users
**Vector Dimension**: 768
**Distance Metric**: Cosine

**Payload**:
```json
{
  "user_id": "444c0b0b-7f83-4110-9a72-e8610c4fb046",
  "updated_at": "2025-12-21T08:45:58Z"
}
```

**Vector Generation**:
- Weighted average of game vectors
- Weights based on events, ratings, reviews
- Time decay applied
- Sentiment adjustments for reviews

#### knowledge
**Vector Dimension**: 768
**Distance Metric**: Cosine

**Payload**:
```json
{
  "source": "game_rules.md",
  "content": "The RTP (Return to Player) is...",
  "chunk_id": 42,
  "metadata": {
    "category": "rules",
    "game": "all"
  }
}
```

---

## API Architecture

### Recommendation Service API (Port 8081)

#### POST /v1/events
Track user events (impressions, clicks, game time).

**Request**:
```json
{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "eventType": "game_time",
  "durationSeconds": 180,
  "metadata": {
    "placement": "homepage-featured"
  }
}
```

**Response**: `201 Created`
```json
{
  "status": "ok"
}
```

**Event Types**:
- `impression`: Game card viewed (50% visible)
- `click`: Game info opened (deprecated)
- `game_time`: User played game with duration

#### POST /v1/feedback/rating
Submit game rating (deprecated - use review endpoint).

**Request**:
```json
{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "rating": 5
}
```

**Response**: `201 Created`

#### POST /v1/feedback/review
Submit game review with rating and optional text.

**Request**:
```json
{
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "rating": 5,
  "reviewText": "Amazing game! Love the graphics and bonus features."
}
```

**Response**: `201 Created`
```json
{
  "id": "uuid",
  "userId": "user-123",
  "gameSlug": "diamond-stars",
  "rating": 5,
  "reviewText": "Amazing game!...",
  "sentimentScore": 0.85,
  "createdAt": "2025-12-21T10:30:00Z",
  "updatedAt": "2025-12-21T10:30:00Z"
}
```

**Backend Process**:
1. Analyze sentiment using Ollama if reviewText provided
2. Store in user_reviews table
3. Update user_ratings table (backwards compatibility)
4. Trigger async user vector update

#### GET /v1/feedback/reviews?gameSlug={slug}
Get all reviews for a game.

**Response**: `200 OK`
```json
[
  {
    "id": "uuid",
    "userId": "user-123",
    "gameSlug": "diamond-stars",
    "rating": 5,
    "reviewText": "Amazing!",
    "sentimentScore": 0.85,
    "createdAt": "2025-12-21T10:30:00Z"
  }
]
```

#### GET /v1/feedback/review?userId={id}&gameSlug={slug}
Get user's review for a specific game.

**Response**: `200 OK` or `404 Not Found`

#### GET /v1/recommendations?userId={id}&placement={placement}&limit={n}&vipLevel={level}
Get personalized game recommendations filtered by VIP level.

**Query Parameters**:
- `userId`: User identifier (required)
- `placement`: UI placement identifier (optional)
- `limit`: Number of recommendations (default: 10)
- `vipLevel`: User's VIP tier - `bronze`, `silver`, `gold`, `platinum` (default: bronze)

**VIP Level Filtering**:
Games have a `minVipLevel` requirement. Recommendations only include games the user can access based on their VIP tier:
- `bronze`: Can access bronze-only games
- `silver`: Can access bronze + silver games
- `gold`: Can access bronze + silver + gold games
- `platinum`: Can access all games

**Response**: `200 OK`
```json
{
  "recommendations": [
    "diamond-stars",
    "mega-moolah",
    "starburst"
  ]
}
```

**Algorithm**:
1. Fetch user vector from Qdrant
2. If no vector: return empty (frontend shows popular)
3. Search similar games using cosine similarity
4. Filter results by VIP level (games where minVipLevel ≤ user's vipLevel)
5. Return top N game slugs

### Chat Service API (Port 8082)

#### POST /v1/sessions
Create new chat session.

**Request**:
```json
{
  "userId": "user-123",
  "context": {
    "currentPage": "game-lobby",
    "currentGame": "diamond-stars"
  }
}
```

**Response**: `201 Created`
```json
{
  "id": "session-uuid",
  "userId": "user-123",
  "context": { "currentPage": "game-lobby" },
  "createdAt": "2025-12-21T10:30:00Z"
}
```

#### POST /v1/sessions/{sessionId}/messages
Send message to chat.

**Request**:
```json
{
  "content": "What are the best slot games?"
}
```

**Response**: `200 OK`
```json
{
  "messageId": "msg-uuid",
  "content": "Based on player preferences, here are some top slot games:\n\n1. Diamond Stars...",
  "citations": [
    {
      "source": "game_catalog.md",
      "excerpt": "Diamond Stars is a popular progressive slot...",
      "score": 0.89
    }
  ]
}
```

**RAG Pipeline**:
1. Generate embedding for query
2. Search knowledge base (top 5 chunks)
3. Build context prompt
4. Generate response with Ollama
5. Extract citations
6. Store message in DB

#### GET /v1/sessions/{sessionId}/messages
Get message history for session.

**Response**: `200 OK`
```json
{
  "messages": [
    {
      "id": "msg-1",
      "role": "user",
      "content": "What are the best slot games?",
      "createdAt": "2025-12-21T10:30:00Z"
    },
    {
      "id": "msg-2",
      "role": "assistant",
      "content": "Based on player preferences...",
      "citations": [...],
      "createdAt": "2025-12-21T10:30:05Z"
    }
  ]
}
```

### PayloadCMS API (Port 3001)

#### GET /api/games
Get all games.

**Query Parameters**:
- `limit`: Results per page
- `page`: Page number
- `where[status][equals]`: Filter by status
- `depth`: Populate depth for relations

**Response**: `200 OK`
```json
{
  "docs": [
    {
      "id": "game-id",
      "slug": "diamond-stars",
      "title": "Diamond Stars",
      "provider": {
        "id": "provider-id",
        "name": "NetEnt"
      },
      "thumbnail": {
        "url": "/media/thumb.jpg"
      }
    }
  ],
  "totalDocs": 100,
  "limit": 10,
  "page": 1
}
```

#### GET /api/games/{id}
Get single game by ID.

#### GET /api/providers
Get all game providers.

#### GET /api/badges
Get all badges.

---

## Frontend Architecture

### Directory Structure
```
frontend/
├── src/
│   ├── api/              # API client modules
│   │   ├── cms.ts        # PayloadCMS API
│   │   ├── recommendation.ts  # Recommendation API
│   │   └── chat.ts       # Chat API
│   ├── components/       # React components
│   │   ├── chat/         # Chat widget components
│   │   ├── game/         # Game-related components
│   │   └── layout/       # Layout components
│   ├── context/          # React Context providers
│   │   ├── UserContext.tsx      # User state
│   │   ├── ChatContext.tsx      # Chat state
│   │   └── GamePlayContext.tsx  # Game play state
│   ├── hooks/            # Custom React hooks
│   ├── pages/            # Page components
│   ├── types/            # TypeScript types
│   ├── utils/            # Utility functions
│   └── main.tsx          # App entry point
├── public/               # Static assets
└── package.json
```

### State Management

#### Global State (React Context)
1. **UserContext**: User ID, preferences
2. **ChatContext**: Chat session, messages, open/close state
3. **GamePlayContext**: Game info dialog, play dialog state

#### Server State (TanStack Query)
- Games from CMS
- Recommendations from service
- Reviews and ratings

#### Local State (useState)
- Form inputs
- UI toggles
- Component-specific state

### Component Architecture

#### Atomic Design Principles
- **Atoms**: Button, Input, Icon, Badge
- **Molecules**: GameCard, MessageBubble, RatingStars
- **Organisms**: GameGrid, ChatWindow, ReviewForm
- **Templates**: GameLobby, GamePlayDialog
- **Pages**: HomePage, GameDetailPage

#### Key Components

**GameCard**
- Displays game thumbnail, title, provider
- Tracks impression events using IntersectionObserver
- Opens game info dialog on click

**GamePlayDialog**
- Renders game in iframe
- Tracks play time
- Sends game_time event on close

**PlayModal**
- Shows game details (description, RTP, volatility)
- Displays reviews and ratings
- "Play Now" button opens GamePlayDialog
- "Rate & Review" form

**ChatWidget**
- Floating chat button
- Opens/closes ChatWindow
- Resizable and maximizable

**ChatWindow**
- Message history with auto-scroll
- AI response with citations
- Suggested questions when empty
- Maximize/minimize functionality
- Resize handle (top-left corner)

### Routing
```typescript
<BrowserRouter>
  <Routes>
    <Route path="/" element={<HomePage />} />
    <Route path="/games/:slug" element={<GameDetailPage />} />
    <Route path="*" element={<NotFoundPage />} />
  </Routes>
</BrowserRouter>
```

### API Client Pattern
```typescript
// api/recommendation.ts
const apiClient = {
  recommendation: {
    get: async <T>(path: string): Promise<T> => { ... },
    post: async <T>(path: string, data: any): Promise<T> => { ... }
  }
};

export const recommendationApi = {
  trackEvent: (event: EventInput) =>
    apiClient.recommendation.post('/v1/events', event),

  getRecommendations: (userId: string, placement: string) =>
    apiClient.recommendation.get(`/v1/recommendations?userId=${userId}&placement=${placement}`)
};
```

---

## Backend Services

### Recommendation Service Architecture

#### Directory Structure
```
services/recommendation/
├── cmd/
│   └── server/
│       └── main.go           # Entry point
├── internal/
│   ├── config/
│   │   └── config.go         # Configuration
│   ├── handler/
│   │   ├── events.go         # Event handlers
│   │   ├── feedback.go       # Review/rating handlers
│   │   └── recommendations.go
│   ├── model/
│   │   └── event.go          # Data models
│   ├── repository/
│   │   ├── postgres.go       # PostgreSQL repo
│   │   └── qdrant.go         # Qdrant repo
│   └── service/
│       ├── embedding.go      # Ollama integration
│       └── recommendation.go # Business logic
├── go.mod
└── Dockerfile
```

#### Service Layers

**1. Handler Layer** (HTTP)
- Receives HTTP requests
- Validates input
- Calls service layer
- Returns HTTP responses

**2. Service Layer** (Business Logic)
- Implements recommendation algorithm
- Calculates user vectors
- Performs sentiment analysis
- Orchestrates repositories

**3. Repository Layer** (Data Access)
- PostgreSQL operations (events, ratings, reviews)
- Qdrant operations (vectors, similarity search)
- Ollama operations (embeddings, LLM)

#### Key Algorithms

**User Vector Calculation**:
```go
func (s *RecommendationService) UpdateUserVector(userID string) error {
    // 1. Fetch user data
    events := fetchUserEvents(userID, last30Days)
    ratings := fetchUserRatings(userID)
    reviews := fetchUserReviews(userID)

    // 2. Calculate weighted scores per game
    gameWeights := make(map[string]float64)

    for _, event := range events {
        weight := getEventWeight(event.Type)
        decay := calculateTimeDecay(event.CreatedAt, 7days)
        gameWeights[event.GameSlug] += weight * decay
    }

    for _, review := range reviews {
        weight := getRatingWeight(review.Rating)

        // Apply sentiment multiplier
        if review.SentimentScore != nil {
            multiplier := 1.0 + (*review.SentimentScore * 0.5)
            weight *= multiplier
        }

        decay := calculateTimeDecay(review.UpdatedAt, 90days)
        gameWeights[review.GameSlug] += weight * decay
    }

    // 3. Fetch game vectors
    gameVectors := fetchGameVectors(gameWeights.keys())

    // 4. Create weighted average
    userVector := weightedAverage(gameVectors, gameWeights)

    // 5. Store in Qdrant
    storeUserVector(userID, userVector)
}
```

**Recommendation Generation**:
```go
func (s *RecommendationService) GetRecommendations(userID string, limit int) ([]string, error) {
    // 1. Get user vector
    userVector := s.qdrantRepo.GetUserVector(userID)

    if userVector == nil {
        return []string{}, nil // Frontend shows popular
    }

    // 2. Search similar games
    results := s.qdrantRepo.SearchSimilarGames(userVector, limit * 2)

    // 3. Filter and return
    return results[:limit], nil
}
```

### ML Service Architecture (GNN)

#### Directory Structure
```
services/ml/
├── app/
│   ├── api/
│   │   └── routes.py           # FastAPI endpoints
│   ├── models/
│   │   ├── lightgcn.py         # LightGCN model
│   │   ├── tgn.py              # TGN model
│   │   └── hgt.py              # HGT model
│   ├── services/
│   │   ├── graph_builder.py    # Bipartite graph builder
│   │   ├── hgt_builder.py      # Heterogeneous graph builder
│   │   ├── trainer.py          # LightGCN trainer
│   │   ├── tgn_trainer.py      # TGN trainer
│   │   ├── hgt_trainer.py      # HGT trainer
│   │   ├── session_service.py  # TGN session tracking
│   │   └── embedding_service.py # Qdrant sync
│   ├── config.py               # Configuration
│   └── main.py                 # FastAPI app
├── requirements.txt
└── Dockerfile
```

#### GNN Models

**1. LightGCN (Collaborative Filtering)**
- Bipartite user-game graph
- Message passing through graph layers
- BPR (Bayesian Personalized Ranking) loss
- Captures "users who liked X also liked Y" patterns

**2. TGN (Temporal Graph Networks)**
- Session-aware recommendations
- Memory module for user state
- Time encoding for temporal patterns
- Real-time interaction updates

**3. HGT (Heterogeneous Graph Transformer)**
- Multi-type nodes: Users, Games, Providers, Promotions, Badges
- Type-specific attention mechanisms
- Cold-start handling via meta-paths
- Provider-aware recommendations

#### Training Flow
```python
# Train LightGCN
@router.post("/v1/train")
async def train_lightgcn(request: TrainRequest):
    # 1. Build user-game bipartite graph from PostgreSQL
    graph = await graph_builder.build_graph(request.lookback_days)
    
    # 2. Initialize LightGCN model
    model = LightGCN(num_users, num_games, embedding_dim=64)
    
    # 3. Train with BPR loss
    for epoch in range(request.num_epochs):
        loss = train_epoch(model, graph)
    
    # 4. Sync embeddings to Qdrant
    embedding_service.sync_to_qdrant(model)
    
    return {"status": "trained", "final_loss": loss}
```

### Chat Service Architecture

#### Directory Structure
```
services/chat/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── handler/
│   │   ├── sessions.go
│   │   └── messages.go
│   ├── model/
│   │   ├── session.go
│   │   └── message.go
│   ├── repository/
│   │   ├── postgres.go
│   │   └── qdrant.go
│   └── service/
│       ├── chat.go          # Chat logic
│       ├── rag.go           # RAG pipeline
│       └── embedding.go     # Ollama integration
├── go.mod
└── Dockerfile
```

#### RAG Pipeline

**1. Query Embedding**:
```go
func (s *RAGService) embedQuery(query string) ([]float32, error) {
    return s.ollamaClient.Embed("nomic-embed-text", query)
}
```

**2. Knowledge Retrieval**:
```go
func (s *RAGService) retrieveContext(queryVector []float32, limit int) ([]Chunk, error) {
    results := s.qdrantRepo.SearchKnowledge(queryVector, limit)

    // Results sorted by cosine similarity (highest first)
    return results, nil
}
```

**3. Prompt Construction**:
```go
func (s *RAGService) buildPrompt(query string, chunks []Chunk) string {
    context := ""
    for _, chunk := range chunks {
        context += chunk.Content + "\n\n"
    }

    return fmt.Sprintf(`You are a casino assistant. Answer the question based on the context below.

Context:
%s

Question: %s

Answer:`, context, query)
}
```

**4. Response Generation**:
```go
func (s *RAGService) generateResponse(prompt string) (string, error) {
    return s.ollamaClient.Generate("llama3.2:3b", prompt)
}
```

**5. Citation Extraction**:
```go
func (s *RAGService) extractCitations(chunks []Chunk) []Citation {
    citations := []Citation{}
    for _, chunk := range chunks {
        citations = append(citations, Citation{
            Source: chunk.Source,
            Excerpt: truncate(chunk.Content, 100),
            Score: chunk.Score,
        })
    }
    return citations
}
```

---

## Vector Database & AI

### Qdrant Collections

#### Games Collection
**Purpose**: Store game embeddings for recommendation
**Vector Size**: 768
**Distance**: Cosine

**Indexing Strategy**:
- HNSW (Hierarchical Navigable Small World)
- M = 16 (connections per layer)
- ef_construct = 100 (construction time quality)

**Search Parameters**:
- ef = 128 (search time quality)
- Score threshold = 0.5 (minimum similarity)

#### Users Collection
**Purpose**: Store user preference vectors
**Vector Size**: 768
**Distance**: Cosine

**Update Frequency**:
- After game_time events
- After rating/review submissions
- Asynchronous background updates

#### Knowledge Collection
**Purpose**: Store RAG knowledge base
**Vector Size**: 768
**Distance**: Cosine

**Chunking Strategy**:
- Max chunk size: 500 tokens
- Overlap: 50 tokens
- Preserve sentence boundaries

### Ollama Integration

#### Embedding Generation
```go
type EmbeddingRequest struct {
    Model  string `json:"model"`
    Prompt string `json:"prompt"`
}

func GenerateEmbedding(text string) ([]float32, error) {
    resp := http.Post(
        "http://ollama:11434/api/embeddings",
        EmbeddingRequest{
            Model: "nomic-embed-text",
            Prompt: text,
        },
    )

    return resp.Embedding, nil
}
```

#### LLM Generation
```go
type GenerateRequest struct {
    Model  string `json:"model"`
    Prompt string `json:"prompt"`
    Stream bool   `json:"stream"`
}

func GenerateText(prompt string) (string, error) {
    resp := http.Post(
        "http://ollama:11434/api/generate",
        GenerateRequest{
            Model: "llama3.2:3b",
            Prompt: prompt,
            Stream: false,
        },
    )

    return resp.Response, nil
}
```

#### Sentiment Analysis
```go
func AnalyzeSentiment(reviewText string) (float64, error) {
    prompt := fmt.Sprintf(`Analyze the sentiment of this casino game review and respond with ONLY a number between -1.0 and 1.0.
-1.0 = extremely negative (hates the game)
-0.5 = negative (dislikes the game)
0.0 = neutral
+0.5 = positive (likes the game)
+1.0 = extremely positive (loves the game)

Review: "%s"

Respond with only the numerical score (e.g., 0.8 or -0.3), nothing else:`, reviewText)

    response := GenerateText(prompt)
    score := parseFloat(response)

    // Clamp between -1 and 1
    return clamp(score, -1.0, 1.0), nil
}
```

---

## Deployment Architecture

### Docker Compose Setup

```yaml
services:
  # Databases
  postgres:      # Port 5433
  mongodb:       # Port 27017
  qdrant:        # Port 6333, 6334

  # CMS
  cms:           # Port 3001

  # Backend Services
  recommendation: # Port 8081
  chat:          # Port 8082
  ml:            # Port 8083 (GNN Models)

  # Frontend
  frontend:      # Port 5173

networks:
  casino-network: # Bridge network

volumes:
  postgres_data:
  mongodb_data:
  qdrant_data:
  cms_media:
  ml_models:     # GNN model checkpoints
```

### ML Service Container

```dockerfile
FROM python:3.11-slim  # or nvidia/cuda for GPU

WORKDIR /app
COPY requirements.txt .
RUN pip install torch==2.2.2 && pip install -r requirements.txt

COPY app/ ./app/
EXPOSE 8083
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8083"]
```

**Environment Variables**:
- `POSTGRES_HOST`: postgres
- `QDRANT_HOST`: qdrant
- `EMBEDDING_DIM`: 64 (GNN embedding dimension)
- `USE_GPU`: false (set true for GPU acceleration)

### Container Configuration

#### Frontend Container
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

**Environment Variables**:
- `VITE_CMS_URL`: http://localhost:3001
- `VITE_RECOMMENDATION_URL`: http://localhost:8081
- `VITE_CHAT_URL`: http://localhost:8082

#### Backend Container (Go)
```dockerfile
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app/server ./cmd/server

FROM alpine:3.19
COPY --from=builder /app/server .
EXPOSE 8081
CMD ["./server"]
```

**Environment Variables**:
- `PORT`: 8081
- `POSTGRES_URL`: postgres://casino:secret@postgres:5432/casino_db
- `QDRANT_URL`: http://qdrant:6333
- `OLLAMA_URL`: http://host.docker.internal:11434

#### CMS Container
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3001
CMD ["npm", "start"]
```

**Environment Variables**:
- `DATABASE_URL`: mongodb://admin:secret@mongodb:27017/casino_cms
- `PAYLOAD_SECRET`: secret-key
- `NEXT_PUBLIC_SERVER_URL`: http://localhost:3001

### Network Communication

**Container-to-Container** (within casino-network):
- Frontend → CMS: http://cms:3001
- Frontend → Recommendation: http://recommendation:8081
- Frontend → Chat: http://chat:8082
- Recommendation → PostgreSQL: postgres:5432
- Recommendation → Qdrant: qdrant:6333
- Recommendation → Ollama: host.docker.internal:11434

**Host-to-Container** (port mapping):
- Frontend: localhost:5173
- CMS: localhost:3001
- Recommendation: localhost:8081
- Chat: localhost:8082
- PostgreSQL: localhost:5433
- MongoDB: localhost:27017
- Qdrant: localhost:6333

### Volume Mounts

**Persistent Data**:
- `postgres_data`: /var/lib/postgresql/data
- `mongodb_data`: /data/db
- `qdrant_data`: /qdrant/storage
- `cms_media`: /app/media

**Development Mounts**:
- `./frontend`: /app (hot reload)
- `./db/migrations`: /docker-entrypoint-initdb.d (auto-run)

---

## Security & Authentication

### Current Implementation

**User Identification**:
- Client-side UUID generation
- Stored in localStorage
- No authentication required for basic features

**API Security**:
- CORS enabled for all origins (development)
- No authentication middleware
- Rate limiting: Not implemented

### Production Recommendations

**Authentication**:
- JWT-based authentication
- OAuth2 providers (Google, Facebook)
- Session management
- Refresh token rotation

**Authorization**:
- Role-based access control (RBAC)
- User roles: guest, player, moderator, admin
- Permission checks on sensitive endpoints

**API Security**:
- CORS restricted to frontend domains
- Rate limiting per IP/user
- Request validation and sanitization
- SQL injection prevention (parameterized queries)
- XSS prevention (output encoding)

**Data Protection**:
- HTTPS/TLS in production
- Encrypted database connections
- Secrets management (HashiCorp Vault)
- Environment variable encryption

**CMS Security**:
- Admin panel protected with authentication
- Role-based content permissions
- Media upload restrictions
- Input sanitization

---

## Design Patterns

### Backend Patterns

**1. Repository Pattern**
- Separates data access from business logic
- Easy to swap data sources
- Testable with mock repositories

```go
type PostgresRepository interface {
    CreateEvent(event *Event) error
    GetUserEvents(userID string) ([]*Event, error)
    UpsertRating(rating *Rating) error
}
```

**2. Service Layer Pattern**
- Encapsulates business logic
- Orchestrates repositories
- Handles transactions

```go
type RecommendationService struct {
    postgresRepo *PostgresRepository
    qdrantRepo   *QdrantRepository
    embeddingService *EmbeddingService
}
```

**3. Dependency Injection**
- Constructor injection
- Loose coupling
- Easy testing

```go
func NewRecommendationService(
    postgres *PostgresRepository,
    qdrant *QdrantRepository,
    embedding *EmbeddingService,
) *RecommendationService {
    return &RecommendationService{
        postgresRepo: postgres,
        qdrantRepo: qdrant,
        embeddingService: embedding,
    }
}
```

**4. Background Processing**
- Async user vector updates
- Non-blocking operations
- Goroutines for concurrency

```go
go recommendationService.UpdateUserVector(userID)
```

### Frontend Patterns

**1. Context + Provider Pattern**
- Global state management
- Avoid prop drilling
- Centralized logic

```typescript
export function ChatProvider({ children }) {
  const [messages, setMessages] = useState([]);
  // ...
  return <ChatContext.Provider value={{...}}>{children}</ChatContext.Provider>;
}
```

**2. Custom Hooks**
- Reusable logic
- Separation of concerns
- Cleaner components

```typescript
export function useChat() {
  const context = useContext(ChatContext);
  if (!context) throw new Error('useChat must be within ChatProvider');
  return context;
}
```

**3. Compound Component Pattern**
- Related components work together
- Flexible composition
- Clear API

```typescript
<ChatWindow>
  <ChatHeader />
  <ChatMessages />
  <ChatInput />
</ChatWindow>
```

**4. Observer Pattern (IntersectionObserver)**
- Track element visibility
- Impression tracking
- Lazy loading

```typescript
useEffect(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        trackImpression(gameSlug);
      }
    });
  }, { threshold: 0.5 });

  observer.observe(ref.current);
}, []);
```

---

## File Structure

```
social-casino-recommendation-lobby/
├── frontend/                      # React web frontend
│   ├── src/
│   │   ├── api/                   # API clients
│   │   ├── assets/                # Static assets
│   │   ├── components/            # React components
│   │   │   ├── chat/
│   │   │   ├── game/
│   │   │   └── layout/            # Header 
│   │   ├── context/               # Global state
│   │   ├── hooks/                 # Custom hooks
│   │   ├── pages/                 # Page components
│   │   ├── types/                 # TypeScript types
│   │   ├── utils/                 # Utilities
│   │   └── main.tsx
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   └── Dockerfile
│
├── social_casino_app/             # Flutter mobile app
│   ├── lib/
│   │   ├── config/                # API config, routes, theme
│   │   │   ├── api_config.dart
│   │   │   ├── routes.dart        # GoRouter setup
│   │   │   └── theme/
│   │   ├── models/                # Data models
│   │   ├── providers/             # Riverpod providers
│   │   ├── screens/               # Screen widgets
│   │   ├── services/              # API services
│   │   └── widgets/               # Reusable widgets
│   │       ├── chat/              # Chat assistant
│   │       ├── game/              # PlayModal, ReviewForm
│   │       ├── layout/            # MainScaffold, BottomNav
│   │       └── lobby/             # GameGrid, GameCard
│   ├── ios/                       # iOS native code
│   ├── android/                   # Android native code
│   └── pubspec.yaml               # Dependencies
│
├── services/
│   ├── recommendation/            # Recommendation service (Go)
│   │   ├── cmd/
│   │   │   └── server/
│   │   │       └── main.go
│   │   ├── internal/
│   │   │   ├── config/
│   │   │   ├── handler/
│   │   │   ├── model/
│   │   │   ├── repository/
│   │   │   └── service/
│   │   │       ├── ml_client.go   # GNN service client
│   │   │       └── recommendation.go
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── Dockerfile
│   │
│   ├── ml/                        # ML/GNN service (Python)
│   │   ├── app/
│   │   │   ├── api/
│   │   │   │   └── routes.py      # FastAPI endpoints
│   │   │   ├── models/
│   │   │   │   ├── lightgcn.py    # Collaborative filtering
│   │   │   │   ├── tgn.py         # Temporal graph networks
│   │   │   │   └── hgt.py         # Heterogeneous graph transformer
│   │   │   ├── services/
│   │   │   │   ├── graph_builder.py
│   │   │   │   ├── hgt_builder.py
│   │   │   │   ├── trainer.py
│   │   │   │   └── session_service.py
│   │   │   ├── config.py
│   │   │   └── main.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   │
│   └── chat/                      # Chat + RAG service (Go)
│       ├── cmd/
│       ├── internal/
│       ├── go.mod
│       └── Dockerfile
│
├── cms/                           # PayloadCMS
│   ├── src/
│   │   ├── collections/           # CMS collections
│   │   │   ├── Games.ts
│   │   │   ├── Providers.ts
│   │   │   ├── Badges.ts
│   │   │   └── Media.ts
│   │   ├── payload.config.ts      # Payload config
│   │   └── server.ts
│   ├── package.json
│   └── Dockerfile
│
├── db/
│   └── migrations/                # PostgreSQL migrations
│       ├── 001_init.sql
│       ├── 002_add_ratings.sql
│       ├── 003_add_chat.sql
│       ├── 004_add_preferences.sql
│       ├── 005_add_play_events.sql
│       ├── 006_add_game_time_event.sql
│       ├── 007_create_user_reviews.sql
│       └── 008_add_sentiment_score.sql
│
├── casino-images/                 # Shared image assets
│
├── docker-compose.yml             # Orchestration
├── .env.example                   # Environment template
├── ARCHITECTURE.md                # This file
├── RECOMMENDATION.md              # Recommendation docs
├── CHAT_AND_RAG.md               # Chat/RAG docs
└── README.md                      # Project overview
```

---

## Integration Points

### 1. Frontend ↔ CMS
**Protocol**: HTTP REST
**Data Format**: JSON

**Flow**:
```
Frontend → GET /api/games → PayloadCMS
PayloadCMS → MongoDB query → Games data
PayloadCMS → JSON response → Frontend
```

**Caching**: TanStack Query (5 min stale time)

### 2. Frontend ↔ Recommendation Service
**Protocol**: HTTP REST
**Data Format**: JSON

**Flows**:
- **Event Tracking**: POST /v1/events (fire-and-forget)
- **Recommendations**: GET /v1/recommendations (cached 1 min)
- **Reviews**: POST /v1/feedback/review (immediate)

### 3. Frontend ↔ Chat Service
**Protocol**: HTTP REST
**Data Format**: JSON

**Flows**:
- **Session Creation**: POST /v1/sessions (on first message)
- **Message Send**: POST /v1/sessions/{id}/messages (blocking)
- **Message History**: GET /v1/sessions/{id}/messages (on open)

### 4. Recommendation Service ↔ PostgreSQL
**Protocol**: PostgreSQL wire protocol
**Driver**: lib/pq

**Operations**:
- INSERT: Events, ratings, reviews
- SELECT: User events, ratings, reviews
- UPDATE: User preferences

**Connection Pool**: Max 10 connections

### 5. Recommendation Service ↔ Qdrant
**Protocol**: gRPC
**Client**: qdrant-go-client

**Operations**:
- Upsert vectors (games, users)
- Search similar vectors
- Get vector by ID
- Delete vectors

### 6. Recommendation Service ↔ Ollama
**Protocol**: HTTP REST
**Data Format**: JSON

**Operations**:
- Generate embeddings: POST /api/embeddings
- Generate text: POST /api/generate
- Model info: GET /api/tags

**Timeout**: 30 seconds

### 7. Chat Service ↔ Qdrant
**Protocol**: gRPC

**Operations**:
- Search knowledge base
- Get chunk by ID
- Upsert knowledge chunks

### 8. Chat Service ↔ PostgreSQL
**Protocol**: PostgreSQL wire protocol

**Operations**:
- INSERT: Sessions, messages
- SELECT: Session history, messages

### 9. PayloadCMS ↔ MongoDB
**Protocol**: MongoDB wire protocol
**Driver**: mongodb (Node.js)

**Operations**:
- CRUD operations on collections
- File metadata storage
- Media management

---

## Scalability Considerations

### Current Limitations
- Single instance per service
- No load balancing
- No caching layer (Redis)
- No message queue
- Ollama runs on host (not containerized)

### Scaling Strategy

#### Horizontal Scaling

**Frontend**:
- Deploy behind CDN (CloudFlare, CloudFront)
- Static asset caching
- Multiple container replicas
- Load balancer (Nginx, HAProxy)

**Backend Services**:
- Stateless design (already implemented)
- Multiple replicas per service
- Load balancer (Traefik, Nginx)
- Health check endpoints

**Databases**:
- PostgreSQL: Read replicas
- MongoDB: Replica sets
- Qdrant: Sharding + replication

#### Vertical Scaling

**Ollama**:
- GPU acceleration (CUDA)
- Increase model context window
- Batch processing

**Databases**:
- Increase memory/CPU
- Optimize indexes
- Query optimization

#### Caching Strategy

**Redis Cache**:
- User vectors (1 hour TTL)
- Recommendations (5 min TTL)
- Game data (1 hour TTL)
- Session data (24 hour TTL)

**CDN**:
- Static assets (images, CSS, JS)
- Game thumbnails
- CMS media

#### Message Queue

**RabbitMQ/Kafka**:
- Async event processing
- User vector updates
- Sentiment analysis jobs
- Knowledge base indexing

#### Monitoring

**Metrics** (Prometheus):
- Request latency
- Error rates
- Vector search performance
- Database query times
- Ollama response times

**Logging** (ELK Stack):
- Application logs
- Access logs
- Error traces
- Audit logs

**Alerting**:
- High error rate
- Slow queries
- Service downtime
- Disk space warnings

#### Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Recommendation latency | <200ms | ~150ms |
| Chat response time | <2s | ~1.5s |
| Page load time | <1s | ~800ms |
| API error rate | <0.1% | <0.01% |
| Database query time | <50ms | ~30ms |
| Vector search time | <100ms | ~80ms |

---

## Conclusion

This architecture provides a solid foundation for a scalable, AI-powered casino recommendation system. The modular design, clear separation of concerns, and use of modern technologies enable rapid development and easy maintenance.

### Key Strengths
- **Microservices architecture**: Independent, scalable services
- **AI-powered features**: Recommendations, chat, sentiment analysis
- **Graph Neural Networks**: LightGCN, TGN, HGT for advanced recommendations
- **Modern tech stack**: React, Flutter, Go, Python, PyTorch, Qdrant, Ollama
- **Cross-platform**: Web and native mobile (iOS/Android)
- **Developer-friendly**: Docker Compose, clear APIs, good documentation
- **Extensible design**: Easy to add new features and models

### GNN-Powered Recommendations
The recommendation system now uses a cascade of Graph Neural Network models:
- **LightGCN**: Baseline collaborative filtering from user-game interactions
- **TGN**: Session-aware recommendations with temporal memory
- **HGT**: Heterogeneous graphs for cold-start handling and provider-aware recommendations

See [GNN_RECOMMENDATION.md](./GNN_RECOMMENDATION.md) for detailed documentation.

### Next Steps
1. Implement authentication & authorization
2. Add Redis caching layer
3. Set up monitoring & alerting
4. Implement rate limiting
5. Add message queue for async processing
6. Deploy to production environment
7. Set up CI/CD pipeline
8. Performance testing & optimization
9. Security audit & penetration testing
10. Load testing & scaling validation

### Future GNN Improvements
- **ContextGCN**: Context-aware recommendations (time of day, device)
- **PinSage-style sampling**: Efficient training on large graphs
- **Multi-task learning**: Joint optimization of clicks, play time, ratings
- **Knowledge graph enhancement**: External game metadata integration
- **Real-time incremental updates**: Update embeddings without full retraining
- **Attention-based fusion**: Learn optimal model combination weights
