package model

import (
	"time"

	"github.com/google/uuid"
)

// VipLevel represents the user's VIP tier
type VipLevel string

const (
	VipLevelBronze   VipLevel = "bronze"
	VipLevelSilver   VipLevel = "silver"
	VipLevelGold     VipLevel = "gold"
	VipLevelPlatinum VipLevel = "platinum"
)

// Rank returns numeric rank for comparison (higher = more access)
func (v VipLevel) Rank() int {
	switch v {
	case VipLevelPlatinum:
		return 4
	case VipLevelGold:
		return 3
	case VipLevelSilver:
		return 2
	case VipLevelBronze:
		return 1
	default:
		return 1 // Default to Bronze
	}
}

type ChatSession struct {
	ID        uuid.UUID       `json:"id"`
	UserID    *string         `json:"userId,omitempty"`
	Context   *SessionContext `json:"context,omitempty"`
	CreatedAt time.Time       `json:"createdAt"`
	UpdatedAt time.Time       `json:"updatedAt"`
}

type SessionContext struct {
	CurrentPage string   `json:"currentPage,omitempty"`
	CurrentGame string   `json:"currentGame,omitempty"`
	VipLevel    VipLevel `json:"vipLevel,omitempty"`
}
