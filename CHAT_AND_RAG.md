# Casino Chat & RAG System

## Overview

The chat system uses **RAG (Retrieval-Augmented Generation)** to provide accurate, context-aware responses to user questions about casino games, promotions, and general casino topics. RAG combines **vector similarity search** (retrieving relevant knowledge) with **LLM generation** (creating natural language responses).

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Frontend  │────▶│ Chat Service │────▶│  PostgreSQL │
│   (React)   │     │   (Go)       │     │  (Sessions) │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                    ┌──────┼───────┐
                    ▼              ▼
            ┌──────────────┐  ┌─────────────┐
            │    Qdrant    │  │   Ollama    │
            │  (KB Vectors)│  │  (LLM + EB) │
            └──────────────┘  └─────────────┘
```

### Components

1. **Frontend (React)**
   - Chat widget with toggle button
   - Message input and display
   - Session management
   - Context tracking (current page, game)

2. **Chat Service (Go)**
   - HTTP API for chat sessions and messages
   - RAG pipeline orchestration
   - Session/message persistence
   - Context-aware prompts

3. **PostgreSQL**
   - Chat sessions and messages
   - Knowledge base metadata (sources, documents, chunks)
   - Full text search support

4. **Qdrant Vector Database**
   - Knowledge base chunk vectors (768-dim)
   - Semantic similarity search
   - Fast approximate nearest neighbor search

5. **Ollama (Local LLM)**
   - **Text Generation**: `llama3.2:3b` model
   - **Embeddings**: `nomic-embed-text` model (768-dim)
   - Runs locally for privacy and cost savings

## Data Storage

### PostgreSQL Tables

#### **chat_sessions** Table
Tracks individual chat sessions:

| Column     | Type      | Description                           |
|------------|-----------|---------------------------------------|
| id         | UUID      | Unique session ID                     |
| user_id    | VARCHAR   | User identifier (optional)            |
| context    | JSONB     | Session context (page, game, etc.)    |
| created_at | TIMESTAMP | Session start time                    |
| updated_at | TIMESTAMP | Last message time                     |

#### **chat_messages** Table
Stores all chat messages:

| Column     | Type      | Description                           |
|------------|-----------|---------------------------------------|
| id         | UUID      | Unique message ID                     |
| session_id | UUID      | Foreign key to chat_sessions          |
| role       | VARCHAR   | 'user' or 'assistant'                 |
| content    | TEXT      | Message text                          |
| citations  | JSONB     | Array of source citations (optional)  |
| created_at | TIMESTAMP | Message timestamp                     |

**Example Citations:**
```json
[
  {
    "documentId": "doc-uuid",
    "source": "Slots Guide",
    "excerpt": "Progressive jackpots increase over time..."
  }
]
```

#### **kb_sources** Table
Tracks knowledge base sources:

| Column      | Type      | Description                          |
|-------------|-----------|--------------------------------------|
| id          | UUID      | Unique source ID                     |
| name        | VARCHAR   | Source name                          |
| source_type | VARCHAR   | Type: 'file', 'confluence', 'url'    |
| metadata    | JSONB     | Additional metadata                  |
| created_at  | TIMESTAMP | Source creation time                 |

#### **kb_documents** Table
Stores individual knowledge documents:

| Column       | Type      | Description                        |
|--------------|-----------|-------------------------------------|
| id           | UUID      | Unique document ID                  |
| source_id    | UUID      | Foreign key to kb_sources           |
| title        | VARCHAR   | Document title                      |
| content_hash | VARCHAR   | SHA-256 hash (for deduplication)    |
| metadata     | JSONB     | Document metadata                   |
| created_at   | TIMESTAMP | Ingestion time                      |
| updated_at   | TIMESTAMP | Last update time                    |

#### **kb_chunks** Table
Stores text chunks with vector IDs:

| Column      | Type      | Description                           |
|-------------|-----------|---------------------------------------|
| id          | UUID      | Unique chunk ID                       |
| document_id | UUID      | Foreign key to kb_documents           |
| chunk_index | INTEGER   | Chunk position in document            |
| content     | TEXT      | Chunk text content                    |
| token_count | INTEGER   | Approximate token count               |
| vector_id   | VARCHAR   | UUID for corresponding Qdrant vector  |
| metadata    | JSONB     | Chunk metadata (title, filename)      |
| created_at  | TIMESTAMP | Chunk creation time                   |

### Qdrant Collections

#### **kb_chunks** Collection
Stores knowledge base chunk vectors:

**Vector Dimension:** 768 (nomic-embed-text model)

**Payload (Metadata):**
```json
{
  "vector_id": "chunk-uuid",
  "content": "Progressive jackpots are special slot games...",
  "source": "Slots Guide",
  "document_id": "doc-uuid"
}
```

**How Vectors Are Created:**
1. Text file is read from `scripts/kb_wikipedia/`
2. Split into chunks (500 chars, 50 char overlap)
3. Each chunk sent to Ollama for embedding
4. 768-dimensional vector stored in Qdrant
5. Metadata stored in both PostgreSQL and Qdrant

## RAG Pipeline

### Step 1: Knowledge Base Ingestion

```bash
# Run ingestion script
cd services/chat
go run cmd/ingest/main.go [kb_directory]

# Default directory: scripts/kb_wikipedia/
```

**Ingestion Process:**

```go
// 1. Read text files from KB directory
files := os.ReadDir("scripts/kb_wikipedia/")

// 2. For each .txt file:
for file in files {
    content := readFile(file)

    // 3. Calculate content hash (for deduplication)
    hash := sha256(content)

    // 4. Check if already ingested
    if documentExists(hash) {
        skip()
    }

    // 5. Create document record
    doc := createDocument(title, hash)

    // 6. Split into chunks
    chunks := splitText(content, chunkSize=500, overlap=50)

    // 7. For each chunk:
    for i, chunk in chunks {
        // Generate embedding
        vector := ollama.embed(chunk)  // 768-dim

        // Store in PostgreSQL
        chunkRecord := createChunk(doc.ID, i, chunk, vector_id)

        // Store vector in Qdrant
        qdrant.upsert(vector_id, vector, {
            content: chunk,
            source: title,
            document_id: doc.ID
        })
    }
}
```

**Chunking Strategy:**
- **Chunk Size:** 500 characters
- **Overlap:** 50 characters
- **Why Overlap?** Ensures context continuity at chunk boundaries
- **Example:**
  ```
  Chunk 1: chars 0-500
  Chunk 2: chars 450-950 (50 char overlap with chunk 1)
  Chunk 3: chars 900-1400 (50 char overlap with chunk 2)
  ```

### Step 2: User Sends Message

```javascript
// Frontend (React)
const sendMessage = async (content: string) => {
  // 1. Create session if needed
  if (!session) {
    session = await chatApi.createSession({
      userId: userId,
      context: { currentPage: 'game', currentGame: 'diamond-stars' }
    })
  }

  // 2. Send message
  const response = await chatApi.sendMessage(session.id, content)

  // 3. Display response with citations
  displayMessage(response.content)
  displayCitations(response.citations)
}
```

### Step 3: RAG Retrieval

```go
// Backend (Go)
func (s *ChatService) ProcessMessage(sessionID, userMessage) {
    // 1. Save user message
    saveMessage(sessionID, "user", userMessage)

    // 2. Get recent chat history (last 10 messages)
    history := getSessionMessages(sessionID, limit=10)

    // 3. RETRIEVE: Search for relevant KB chunks
    chunks := ragService.RetrieveContext(userMessage, topK=5)
    //   a. Generate query embedding
    queryVector := ollama.embed(userMessage)
    //   b. Search Qdrant for similar chunks
    results := qdrant.search(queryVector, limit=5)
    //   c. Return top 5 most similar chunks

    // 4. Build prompt with context
    prompt := buildPrompt(userMessage, history, chunks)

    // 5. GENERATE: Get LLM response
    response := llm.generate(prompt)

    // 6. Extract citations (chunks with score > 0.7)
    citations := extractCitations(chunks, threshold=0.7)

    // 7. Save assistant message
    saveMessage(sessionID, "assistant", response, citations)

    // 8. Return response
    return response, citations
}
```

### Step 4: Vector Search

**Qdrant Search Query:**
```go
searchResult := qdrantClient.Search(ctx, &qdrant.SearchPoints{
    CollectionName: "kb_chunks",
    Vector:         queryVector,  // 768-dim
    Limit:          5,             // Top 5 results
    WithPayload:    true,          // Include metadata
    ScoreThreshold: 0.5,           // Minimum similarity
})
```

**Cosine Similarity:**
```
similarity = (A · B) / (||A|| × ||B||)
```
- Range: -1 to 1
- Higher = more similar
- Threshold: 0.5 (moderate similarity)

**Example Results:**
```json
[
  {
    "score": 0.92,
    "payload": {
      "content": "Progressive jackpots are special slots that increase...",
      "source": "Slots Guide",
      "document_id": "doc-123"
    }
  },
  {
    "score": 0.87,
    "payload": {
      "content": "Mega Moolah is a famous progressive jackpot slot...",
      "source": "Game Reviews",
      "document_id": "doc-456"
    }
  }
]
```

### Step 5: Prompt Construction

```go
func buildPrompt(query, history, chunks) string {
    prompt := ""

    // 1. System instructions
    prompt += "You are an expert social casino assistant..."
    prompt += "IMPORTANT GUIDELINES:\n"
    prompt += "1. Answer based PRIMARILY on the knowledge base context\n"
    prompt += "2. Cite sources when using KB info\n"
    prompt += "3. Be enthusiastic and professional\n"
    prompt += "4. Keep responses 2-4 paragraphs\n\n"

    // 2. Knowledge base context (if available)
    if len(chunks) > 0 {
        prompt += "=== KNOWLEDGE BASE CONTEXT ===\n"
        for chunk in chunks {
            prompt += "---\n"
            prompt += "Source: " + chunk.Source + "\n"
            prompt += chunk.Content + "\n"
        }
        prompt += "=== END CONTEXT ===\n\n"
    }

    // 3. Chat history (for context continuity)
    if len(history) > 1 {
        prompt += "=== RECENT CHAT HISTORY ===\n"
        for msg in history {
            prompt += msg.Role + ": " + msg.Content + "\n"
        }
        prompt += "=== END HISTORY ===\n\n"
    }

    // 4. Current query
    prompt += "User Question: " + query + "\n\n"
    prompt += "Assistant Response: "

    return prompt
}
```

**Example Full Prompt:**
```
You are an expert social casino assistant helping players with game information, strategies, and questions. You specialize in slots, table games, live casino, and all casino gaming topics.

IMPORTANT GUIDELINES:
1. Answer based PRIMARILY on the knowledge base context provided below
2. If the knowledge base contains relevant info, use it and cite the source
3. For general casino questions not in the knowledge base, provide helpful general information
4. Be enthusiastic, friendly, and professional
5. Use specific numbers, RTPs, and details when available in the context
6. Keep responses concise but informative (2-4 paragraphs)
7. When discussing games, mention key features like RTP, volatility, and unique mechanics
8. Always encourage responsible gaming

=== KNOWLEDGE BASE CONTEXT ===
---
Source: Slots Guide
Progressive jackpots are special slot games where the jackpot amount increases every time a player makes a bet. A small percentage of each wager contributes to the jackpot pool. These jackpots can reach life-changing amounts, sometimes millions of dollars.
---
Source: Mega Moolah Review
Mega Moolah is one of the most famous progressive jackpot slots in the world. Developed by Microgaming, it has paid out over $1 billion in jackpots since its launch. The game features an African safari theme with 5 reels and 25 paylines. Its RTP is 88.12%, and it has medium volatility.
=== END CONTEXT ===

=== RECENT CHAT HISTORY ===
User: What games do you recommend?
Assistant: I'd recommend checking out our progressive jackpot slots! They offer exciting gameplay with the chance to win huge prizes.
=== END HISTORY ===

User Question: Tell me more about Mega Moolah

Assistant Response:
```

### Step 6: LLM Generation

```go
// Send prompt to Ollama
response := ollama.generate(model="llama3.2:3b", prompt=fullPrompt)

// Example response:
"Mega Moolah is an excellent choice if you're looking for progressive jackpot excitement!
As mentioned in our game reviews, this legendary slot by Microgaming has paid out over
$1 billion in jackpots since it was released, making it one of the most rewarding slots
in casino history.

The game features a fun African safari theme with 5 reels and 25 paylines. While its
RTP of 88.12% is lower than some other slots, the medium volatility and massive jackpot
potential more than make up for it. You could be the next lucky player to hit a
life-changing win!

The game includes a special bonus wheel that can trigger one of four progressive jackpots:
Mini, Minor, Major, and the famous Mega jackpot. Would you like to give it a try?"
```

### Step 7: Response with Citations

```json
{
  "messageId": "msg-uuid",
  "content": "Mega Moolah is an excellent choice if you're looking for...",
  "citations": [
    {
      "documentId": "doc-123",
      "source": "Slots Guide",
      "excerpt": "Progressive jackpots are special slot games where..."
    },
    {
      "documentId": "doc-456",
      "source": "Mega Moolah Review",
      "excerpt": "Mega Moolah is one of the most famous progressive..."
    }
  ]
}
```

## Complete User Journey

### 1. User Opens Chat
```
User clicks chat widget button
  ↓
Frontend opens chat window
  ↓
If no session exists:
  ↓
Create new session with context:
  {
    userId: "user-123",
    context: {
      currentPage: "game",
      currentGame: "diamond-stars"
    }
  }
  ↓
Session stored in PostgreSQL
  ↓
Chat ready for messages
```

### 2. User Asks Question
```
User types: "What are progressive jackpots?"
  ↓
Frontend sends message to API:
  POST /v1/chat/sessions/{sessionId}/messages
  Body: { content: "What are progressive jackpots?" }
  ↓
Backend processes message:
  1. Save user message to PostgreSQL
  2. Embed query → [0.1, 0.5, ..., 0.3] (768-dim)
  3. Search Qdrant for similar chunks
  4. Get top 5 most relevant chunks
  5. Build prompt with KB context + history
  6. Send to Ollama LLM
  7. Get response
  8. Extract citations (score > 0.7)
  9. Save assistant message to PostgreSQL
  ↓
Frontend displays response with citations
  ↓
User can click citations to see sources
```

### 3. Context-Aware Follow-Up
```
User clicks on "Diamond Stars" game
  ↓
Frontend updates chat context:
  setContext({ currentGame: "diamond-stars" })
  ↓
User clicks "Ask about this game"
  ↓
Chat opens with context
  ↓
System prompt includes:
  "User is currently viewing: Diamond Stars"
  ↓
When user asks: "Tell me about this game"
  ↓
LLM knows which game user is referring to
  ↓
Retrieves Diamond Stars-specific information
  ↓
Provides targeted response
```

## Knowledge Base Sources

### Current KB Structure

```
scripts/kb_wikipedia/
├── slots.txt              # General slots information
├── progressive_jackpots.txt
├── table_games.txt
├── rtp_explained.txt
├── volatility_guide.txt
├── game_providers.txt
└── responsible_gaming.txt
```

### KB File Format

```txt
Title: Progressive Jackpots Guide

Progressive jackpots are special slot games where the jackpot amount increases every time a player makes a bet. A small percentage of each wager contributes to the jackpot pool.

Types of Progressive Jackpots:

1. Standalone Progressives
These are individual machines with their own jackpot. The jackpot only increases from bets made on that specific machine.

2. Local Area Progressives
Multiple machines in the same casino are linked together. All bets on these machines contribute to a shared jackpot pool.

3. Wide Area Progressives
Machines across multiple casinos are networked together. These offer the largest jackpots, often reaching millions of dollars.

Famous Progressive Jackpot Games:

- Mega Moolah: Known for record-breaking payouts
- Mega Fortune: Another huge jackpot game
- Hall of Gods: Nordic-themed progressive slot
```

### Adding New KB Content

1. **Create text file** in `scripts/kb_wikipedia/`
2. **Format:** Plain text, well-structured
3. **Run ingestion:**
   ```bash
   cd services/chat
   go run cmd/ingest/main.go
   ```
4. **Verify:**
   ```bash
   # Check PostgreSQL
   docker exec casino-postgres psql -U casino -d casino_db \
     -c "SELECT COUNT(*) FROM kb_chunks"

   # Check Qdrant
   curl http://localhost:6333/collections/kb_chunks
   ```

## Performance Optimizations

### 1. Vector Search Optimization

**HNSW Index** (Hierarchical Navigable Small World):
- Approximate nearest neighbor search
- Trade accuracy for speed
- Typical latency: 10-50ms for 100K vectors

**Parameters:**
```json
{
  "hnsw_config": {
    "m": 16,              // Links per node
    "ef_construct": 100   // Construction quality
  }
}
```

### 2. Chunk Size Tuning

**Current:** 500 chars, 50 char overlap

**Trade-offs:**
- **Smaller chunks:** More precise matches, but less context
- **Larger chunks:** More context, but less precise
- **More overlap:** Better context continuity, but more storage

**Optimal for casino content:** 500 chars captures complete concepts (game features, RTP, strategies) without being too broad.

### 3. Top-K Selection

**Current:** Top 5 chunks retrieved

**Considerations:**
- More chunks = more context but longer prompts
- Fewer chunks = faster but might miss relevant info
- 5 chunks ≈ 2500 chars ≈ good balance

### 4. Caching

**Embedding Cache:**
- Cache common queries
- Avoid re-embedding frequently asked questions
- Implementation: Redis or in-memory cache

**Session Cache:**
- Keep recent sessions in memory
- Faster message history retrieval

### 5. Async Processing

```go
// Process message async
go func() {
    response := processMessage(sessionID, message)
    sendToWebSocket(sessionID, response)
}()
```

## Configuration

### Environment Variables

```env
# PostgreSQL connection
POSTGRES_URL=postgres://casino:secret@postgres:5432/casino_db?sslmode=disable

# Qdrant connection
QDRANT_URL=http://qdrant:6333

# Ollama for LLM and embeddings
OLLAMA_URL=http://host.docker.internal:11434

# Models
LLM_MODEL=llama3.2:3b           # Text generation
EMBEDDING_MODEL=nomic-embed-text # Embeddings (768-dim)

# Chat service port
PORT=8082
```

### RAG Parameters

```go
// services/chat/internal/service/rag.go

const (
    DefaultTopK = 5           // Top K chunks to retrieve
)

// services/chat/internal/service/chat.go

const (
    MaxHistoryMessages = 10   // Max messages in context
    MaxContextChunks   = 5    // Max KB chunks in prompt
)

// services/chat/cmd/ingest/main.go

const (
    ChunkSize    = 500        // Characters per chunk
    ChunkOverlap = 50         // Overlap between chunks
)
```

## API Endpoints

### Sessions

```bash
# Create new chat session
POST /v1/chat/sessions
Content-Type: application/json

{
  "userId": "user-123",
  "context": {
    "currentPage": "game",
    "currentGame": "diamond-stars"
  }
}

Response:
{
  "id": "session-uuid",
  "userId": "user-123",
  "context": { ... },
  "createdAt": "2025-12-21T10:00:00Z"
}
```

### Messages

```bash
# Send message
POST /v1/chat/sessions/{sessionId}/messages
Content-Type: application/json

{
  "content": "What are progressive jackpots?"
}

Response:
{
  "messageId": "msg-uuid",
  "content": "Progressive jackpots are special slot games...",
  "citations": [
    {
      "documentId": "doc-uuid",
      "source": "Slots Guide",
      "excerpt": "Progressive jackpots are special slot games..."
    }
  ]
}
```

## Frontend Integration

### ChatContext

```typescript
// Context provides chat functionality
const { sendMessage, messages, isLoading } = useChat()

// Set context when user navigates
setContext({
  currentPage: 'game',
  currentGame: gameSlug
})

// Send message
await sendMessage('Tell me about this game')

// Display messages
messages.map(msg => (
  <MessageBubble
    content={msg.content}
    role={msg.role}
    citations={msg.citations}
  />
))
```

### Context Usage

```javascript
// Game page
useEffect(() => {
  setContext({
    currentPage: 'game',
    currentGame: game.slug
  })
}, [game.slug])

// Chat button in game info dialog
<button onClick={openChat}>
  Ask about this game
</button>
```

## Monitoring & Metrics

### Key Metrics

1. **Response Quality**
   - User satisfaction (thumbs up/down)
   - Message length
   - Citation usage rate

2. **Performance**
   - Message latency (target: <3s)
   - Vector search time
   - LLM generation time

3. **Knowledge Coverage**
   - Questions answered from KB vs fallback
   - Most common unanswered questions
   - Citation diversity

4. **Usage**
   - Messages per session
   - Session duration
   - Most common questions

### Logging

```go
// Log each stage of RAG pipeline
log.Printf("Query: %s", query)
log.Printf("Retrieved %d chunks in %dms", len(chunks), retrievalTime)
log.Printf("LLM generated response in %dms", generationTime)
log.Printf("Total latency: %dms", totalTime)
```

## Troubleshooting

### Issue: Chat Not Responding

**Checklist:**
1. Check Ollama is running:
   ```bash
   curl http://localhost:11434/api/tags
   ```

2. Verify models are downloaded:
   ```bash
   ollama list
   # Should show: llama3.2:3b and nomic-embed-text
   ```

3. Check chat service logs:
   ```bash
   docker logs casino-chat --tail 50
   ```

4. Test embedding service:
   ```bash
   curl http://localhost:11434/api/embeddings \
     -d '{"model":"nomic-embed-text","prompt":"test"}'
   ```

### Issue: No Relevant Context Retrieved

**Checklist:**
1. Verify KB is ingested:
   ```bash
   docker exec casino-postgres psql -U casino -d casino_db \
     -c "SELECT COUNT(*) FROM kb_chunks"
   ```

2. Check Qdrant collection:
   ```bash
   curl http://localhost:6333/collections/kb_chunks
   ```

3. Test vector search:
   ```bash
   # Generate test embedding
   # Search Qdrant manually
   ```

4. Review chunk content in PostgreSQL:
   ```sql
   SELECT content, metadata FROM kb_chunks LIMIT 5;
   ```

### Issue: Slow Response Times

**Optimization Steps:**
1. Reduce MaxContextChunks (5 → 3)
2. Reduce MaxHistoryMessages (10 → 5)
3. Use faster LLM model
4. Cache common queries
5. Add Qdrant index optimization

### Issue: Inaccurate Responses

**Improvements:**
1. Add more KB content
2. Improve chunking strategy
3. Increase chunk overlap (50 → 100)
4. Adjust similarity threshold (0.5 → 0.6)
5. Refine system prompt
6. Use better LLM model

## Future Enhancements

### 1. Streaming Responses

```go
// Stream LLM output token by token
for token := range llm.streamGenerate(prompt) {
    websocket.send(token)
}
```

**Benefits:**
- Perceived faster response time
- Better UX for long responses
- Ability to stop generation early

### 2. Multi-Modal RAG

```
Text Query → Search Text + Images
           ↓
     Retrieve relevant:
     - Text chunks
     - Game screenshots
     - Chart/diagrams
           ↓
     Generate response with visual context
```

### 3. Query Classification

```go
// Classify query type
type := classifyQuery(query)

switch type {
case "game_specific":
    // Search game-specific KB
case "promotion":
    // Search promotions KB
case "general":
    // Search general KB
}
```

### 4. Feedback Loop

```
User rates response (👍/👎)
  ↓
Log: query + chunks + rating
  ↓
Analyze low-rated responses
  ↓
Improve:
  - KB content
  - Chunking strategy
  - Prompt engineering
  - Model selection
```

### 5. Personalized Responses

```go
// Include user preferences in context
prompt += "User preferences:\n"
prompt += "- Favorite game type: " + user.favoriteType + "\n"
prompt += "- Preferred volatility: " + user.volatility + "\n"
prompt += "- Play style: " + user.playStyle + "\n"
```

### 6. Multi-Language Support

```
Detect user language
  ↓
Translate query to English
  ↓
Retrieve English KB chunks
  ↓
Generate English response
  ↓
Translate response to user language
```

### 7. Advanced RAG Techniques

**Hypothetical Document Embeddings (HyDE):**
```
User Query → LLM generates hypothetical answer
           → Embed hypothetical answer
           → Search with hypothetical embedding
           → Retrieve better-matching chunks
```

**Re-ranking:**
```
Retrieve top 20 chunks (fast, approximate)
  ↓
Re-rank with cross-encoder (slow, accurate)
  ↓
Take top 5 re-ranked chunks
```

## Conclusion

The Chat & RAG system provides:

- **Accurate Responses:** Grounded in knowledge base content
- **Fast Performance:** Vector search + local LLM
- **Context-Aware:** Considers chat history and page context
- **Scalable:** Can handle 1000s of documents
- **Privacy-Friendly:** All processing local (Ollama)
- **Cost-Effective:** No API costs

The system learns and improves as you add more content to the knowledge base, making it a powerful tool for customer support and engagement.
