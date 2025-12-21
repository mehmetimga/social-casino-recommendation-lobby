package handler

import (
	"encoding/json"
	"net/http"

	"github.com/casino/recommendation/internal/model"
	"github.com/casino/recommendation/internal/repository"
	"github.com/casino/recommendation/internal/service"
)

type EventsHandler struct {
	postgresRepo          *repository.PostgresRepository
	recommendationService *service.RecommendationService
}

func NewEventsHandler(
	postgresRepo *repository.PostgresRepository,
	recommendationService *service.RecommendationService,
) *EventsHandler {
	return &EventsHandler{
		postgresRepo:          postgresRepo,
		recommendationService: recommendationService,
	}
}

type TrackEventRequest struct {
	UserID          string            `json:"userId"`
	GameSlug        string            `json:"gameSlug"`
	EventType       model.EventType   `json:"eventType"`
	DurationSeconds *int              `json:"durationSeconds,omitempty"`
	Metadata        map[string]string `json:"metadata,omitempty"`
}

func (h *EventsHandler) TrackEvent(w http.ResponseWriter, r *http.Request) {
	var req TrackEventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if req.UserID == "" || req.GameSlug == "" || req.EventType == "" {
		http.Error(w, "Missing required fields", http.StatusBadRequest)
		return
	}

	// Validate event type
	validTypes := map[model.EventType]bool{
		model.EventTypeImpression: true,
		model.EventTypeClick:      true,
		model.EventTypeGameTime:   true,
		// Support deprecated event types
		model.EventTypePlayStart:  true,
		model.EventTypePlayEnd:    true,
	}
	if !validTypes[req.EventType] {
		http.Error(w, "Invalid event type", http.StatusBadRequest)
		return
	}

	// Create event
	event := &model.UserEvent{
		UserID:          req.UserID,
		GameSlug:        req.GameSlug,
		EventType:       req.EventType,
		DurationSeconds: req.DurationSeconds,
		Metadata:        req.Metadata,
	}

	if err := h.postgresRepo.CreateEvent(event); err != nil {
		// Log the actual error for debugging
		println("Error creating event:", err.Error())
		http.Error(w, "Failed to create event", http.StatusInternalServerError)
		return
	}

	// Update user vector asynchronously for certain event types
	if req.EventType == model.EventTypeGameTime || req.EventType == model.EventTypePlayEnd || req.EventType == model.EventTypeClick {
		go h.recommendationService.UpdateUserVector(req.UserID)
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
