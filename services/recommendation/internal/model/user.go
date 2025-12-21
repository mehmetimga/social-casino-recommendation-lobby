package model

import "time"

type UserPreference struct {
	UserID          string    `json:"userId"`
	VectorUpdatedAt *time.Time `json:"vectorUpdatedAt,omitempty"`
	CreatedAt       time.Time `json:"createdAt"`
	UpdatedAt       time.Time `json:"updatedAt"`
}

type UserVector struct {
	UserID    string    `json:"userId"`
	Vector    []float32 `json:"vector"`
	UpdatedAt time.Time `json:"updatedAt"`
}
