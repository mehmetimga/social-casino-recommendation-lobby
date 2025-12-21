package model

import (
	"time"

	"github.com/google/uuid"
)

type KBSource struct {
	ID         uuid.UUID         `json:"id"`
	Name       string            `json:"name"`
	SourceType string            `json:"sourceType"` // file, confluence, url
	Metadata   map[string]string `json:"metadata,omitempty"`
	CreatedAt  time.Time         `json:"createdAt"`
}

type KBDocument struct {
	ID          uuid.UUID         `json:"id"`
	SourceID    uuid.UUID         `json:"sourceId"`
	Title       string            `json:"title"`
	ContentHash string            `json:"contentHash"`
	Metadata    map[string]string `json:"metadata,omitempty"`
	CreatedAt   time.Time         `json:"createdAt"`
	UpdatedAt   time.Time         `json:"updatedAt"`
}

type KBChunk struct {
	ID         uuid.UUID         `json:"id"`
	DocumentID uuid.UUID         `json:"documentId"`
	ChunkIndex int               `json:"chunkIndex"`
	Content    string            `json:"content"`
	TokenCount int               `json:"tokenCount"`
	VectorID   string            `json:"vectorId"`
	Metadata   map[string]string `json:"metadata,omitempty"`
	CreatedAt  time.Time         `json:"createdAt"`
}

// RetrievedChunk represents a chunk returned from vector search
type RetrievedChunk struct {
	Content    string  `json:"content"`
	Source     string  `json:"source"`
	DocumentID string  `json:"documentId"`
	Score      float32 `json:"score"`
}
