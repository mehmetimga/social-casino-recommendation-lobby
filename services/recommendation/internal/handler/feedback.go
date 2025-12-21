package handler

import (
	"encoding/json"
	"net/http"

	"github.com/casino/recommendation/internal/model"
	"github.com/casino/recommendation/internal/repository"
	"github.com/casino/recommendation/internal/service"
)

type FeedbackHandler struct {
	postgresRepo          *repository.PostgresRepository
	recommendationService *service.RecommendationService
}

func NewFeedbackHandler(
	postgresRepo *repository.PostgresRepository,
	recommendationService *service.RecommendationService,
) *FeedbackHandler {
	return &FeedbackHandler{
		postgresRepo:          postgresRepo,
		recommendationService: recommendationService,
	}
}

type SubmitRatingRequest struct {
	UserID   string `json:"userId"`
	GameSlug string `json:"gameSlug"`
	Rating   int    `json:"rating"`
}

func (h *FeedbackHandler) SubmitRating(w http.ResponseWriter, r *http.Request) {
	var req SubmitRatingRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if req.UserID == "" || req.GameSlug == "" {
		http.Error(w, "Missing required fields", http.StatusBadRequest)
		return
	}

	// Validate rating range
	if req.Rating < 1 || req.Rating > 5 {
		http.Error(w, "Rating must be between 1 and 5", http.StatusBadRequest)
		return
	}

	// Create or update rating
	rating := &model.UserRating{
		UserID:   req.UserID,
		GameSlug: req.GameSlug,
		Rating:   req.Rating,
	}

	if err := h.postgresRepo.UpsertRating(rating); err != nil {
		http.Error(w, "Failed to save rating", http.StatusInternalServerError)
		return
	}

	// Update user vector asynchronously
	go h.recommendationService.UpdateUserVector(req.UserID)

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
