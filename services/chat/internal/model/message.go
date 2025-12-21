package model

import (
	"time"

	"github.com/google/uuid"
)

type MessageRole string

const (
	RoleUser      MessageRole = "user"
	RoleAssistant MessageRole = "assistant"
)

type ChatMessage struct {
	ID        uuid.UUID   `json:"id"`
	SessionID uuid.UUID   `json:"sessionId"`
	Role      MessageRole `json:"role"`
	Content   string      `json:"content"`
	Citations []Citation  `json:"citations,omitempty"`
	CreatedAt time.Time   `json:"createdAt"`
}

type Citation struct {
	DocumentID string `json:"documentId"`
	Source     string `json:"source"`
	Excerpt    string `json:"excerpt"`
}
