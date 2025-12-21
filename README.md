# Social Casino PoC Platform

A proof-of-concept social casino platform featuring:
- CMS-driven lobby (PayloadCMS)
- AI-powered game recommendations (Go + Qdrant + Ollama)
- RAG-powered chat support (Go + Qdrant + Ollama)
- Modern React frontend (Vite + TypeScript + Tailwind)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│                   (Vite + React + Tailwind)                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  PayloadCMS   │ │ Recommendation│ │  Chat + RAG   │
│   (Node.js)   │ │   Service     │ │   Service     │
│               │ │    (Go)       │ │    (Go)       │
└───────┬───────┘ └───────┬───────┘ └───────┬───────┘
        │                 │                 │
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   MongoDB     │ │  PostgreSQL   │ │    Qdrant     │
└───────────────┘ └───────────────┘ └───────────────┘
                          │                 │
                          └────────┬────────┘
                                   ▼
                          ┌───────────────┐
                          │    Ollama     │
                          │   (Local LLM) │
                          └───────────────┘
```

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (for local development)
- Go 1.21+ (for local development)

### Running with Docker Compose

1. Copy environment file:
```bash
cp .env.example .env
```

2. Start all services:
```bash
docker-compose up -d
```

3. Access the applications:
- Frontend: http://localhost:5173
- PayloadCMS Admin: http://localhost:3001/admin
- Recommendation API: http://localhost:8081
- Chat API: http://localhost:8082

### Default Credentials
- PayloadCMS Admin: `admin@casino.com` / `admin123`

## Project Structure

```
social-casino-recommendation-lobby/
├── cms/                    # PayloadCMS application
│   ├── src/
│   │   ├── collections/    # Game, Promotion, LobbyLayout, etc.
│   │   ├── blocks/         # Carousel, GameGrid, Banner sections
│   │   └── seed/           # Sample data
│   └── Dockerfile
│
├── frontend/               # Vite + React application
│   └── src/
│       ├── components/
│       │   ├── layout/     # Header, CategoryTabs
│       │   ├── lobby/      # GameCard, GameGrid, HeroCarousel
│       │   ├── game/       # PlayModal, RatingStars
│       │   └── chat/       # ChatWidget, MessageBubble
│       ├── api/            # API clients
│       ├── context/        # User, Chat providers
│       └── types/          # TypeScript definitions
│
├── services/
│   ├── recommendation/     # Go recommendation service
│   │   └── internal/
│   │       ├── handler/    # HTTP handlers
│   │       ├── service/    # Business logic
│   │       └── repository/ # Data access
│   │
│   └── chat/               # Go chat + RAG service
│       └── internal/
│           ├── handler/
│           ├── service/
│           └── repository/
│
├── db/migrations/          # PostgreSQL schemas
└── docker-compose.yml
```

## Features

### Phase 1: CMS & Frontend
- PayloadCMS with game catalog, promotions, and lobby layouts
- Dynamic lobby rendering based on CMS configuration
- Netflix-style game cards with hover effects
- Hero carousel with countdown timers
- Play modal with image slideshow and ratings

### Phase 2: Recommendation Service
- User event tracking (impressions, clicks, play sessions)
- Rating-based feedback
- Vector-based game recommendations using Qdrant
- Weighted preference calculation with time decay

### Phase 3: Chat + RAG
- Knowledge base ingestion pipeline
- Vector search for relevant context
- LLM-powered responses with citations
- Session management and chat history

## API Endpoints

### Recommendation Service (port 8081)
- `POST /v1/events` - Track user events
- `POST /v1/feedback/rating` - Submit game rating
- `GET /v1/recommendations?userId=&limit=` - Get personalized recommendations

### Chat Service (port 8082)
- `POST /v1/chat/sessions` - Create chat session
- `POST /v1/chat/sessions/{id}/messages` - Send message

## Development

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### CMS
```bash
cd cms
npm install
npm run dev
```

### Go Services
```bash
cd services/recommendation
go run ./cmd/server

cd services/chat
go run ./cmd/server
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_URL` | PostgreSQL connection string | `postgres://casino:casino_secret@localhost:5432/casino_db` |
| `QDRANT_URL` | Qdrant server URL | `http://localhost:6333` |
| `OLLAMA_URL` | Ollama server URL | `http://localhost:11434` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://admin:admin_secret@localhost:27017` |
| `PAYLOAD_SECRET` | PayloadCMS secret key | - |

## Tech Stack

- **Frontend**: Vite, React 18, TypeScript, Tailwind CSS, TanStack Query
- **CMS**: PayloadCMS 2.x, MongoDB
- **Backend**: Go 1.21, Chi router
- **Databases**: PostgreSQL 16, MongoDB 7, Qdrant 1.7
- **AI/ML**: Ollama (local LLM)
- **Infrastructure**: Docker, Docker Compose

## License

This is a proof-of-concept project for demonstration purposes.
