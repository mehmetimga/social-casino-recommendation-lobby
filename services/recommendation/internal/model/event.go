package model

import (
	"time"

	"github.com/google/uuid"
)

type EventType string

const (
	EventTypeImpression EventType = "impression"
	EventTypeClick      EventType = "click"
	EventTypePlayStart  EventType = "play_start"
	EventTypePlayEnd    EventType = "play_end"
)

type UserEvent struct {
	ID              uuid.UUID         `json:"id"`
	UserID          string            `json:"userId"`
	GameSlug        string            `json:"gameSlug"`
	EventType       EventType         `json:"eventType"`
	DurationSeconds *int              `json:"durationSeconds,omitempty"`
	Metadata        map[string]string `json:"metadata,omitempty"`
	CreatedAt       time.Time         `json:"createdAt"`
}

type UserRating struct {
	ID        uuid.UUID `json:"id"`
	UserID    string    `json:"userId"`
	GameSlug  string    `json:"gameSlug"`
	Rating    int       `json:"rating"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

// Weighting constants for recommendation algorithm
const (
	ImpressionWeight = 0.2
	ClickWeight      = 1.0
	PlayStartWeight  = 2.0
	PlayEndBaseWeight = 2.0
	Rating5Weight    = 8.0
	Rating1Weight    = -6.0

	// Time decay half-life in days
	BehaviorHalfLife = 7
	RatingHalfLife   = 90
)

func GetEventWeight(eventType EventType) float64 {
	switch eventType {
	case EventTypeImpression:
		return ImpressionWeight
	case EventTypeClick:
		return ClickWeight
	case EventTypePlayStart:
		return PlayStartWeight
	case EventTypePlayEnd:
		return PlayEndBaseWeight
	default:
		return 0
	}
}

func GetRatingWeight(rating int) float64 {
	// Linear interpolation from rating 1 (-6) to rating 5 (+8)
	// rating 1 = -6, rating 2 = -2.5, rating 3 = +1, rating 4 = +4.5, rating 5 = +8
	return Rating1Weight + (Rating5Weight-Rating1Weight)*float64(rating-1)/4
}
