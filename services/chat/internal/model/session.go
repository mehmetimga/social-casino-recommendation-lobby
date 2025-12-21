package model

import (
	"time"

	"github.com/google/uuid"
)

type ChatSession struct {
	ID        uuid.UUID      `json:"id"`
	UserID    *string        `json:"userId,omitempty"`
	Context   *SessionContext `json:"context,omitempty"`
	CreatedAt time.Time      `json:"createdAt"`
	UpdatedAt time.Time      `json:"updatedAt"`
}

type SessionContext struct {
	CurrentPage string `json:"currentPage,omitempty"`
	CurrentGame string `json:"currentGame,omitempty"`
}
