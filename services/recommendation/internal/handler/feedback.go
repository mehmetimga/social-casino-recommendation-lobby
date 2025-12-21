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

type SubmitReviewRequest struct {
	UserID     string  `json:"userId"`
	GameSlug   string  `json:"gameSlug"`
	Rating     int     `json:"rating"`
	ReviewText *string `json:"reviewText,omitempty"`
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

func (h *FeedbackHandler) SubmitReview(w http.ResponseWriter, r *http.Request) {
	var req SubmitReviewRequest
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

	// Create or update review
	review := &model.UserReview{
		UserID:     req.UserID,
		GameSlug:   req.GameSlug,
		Rating:     req.Rating,
		ReviewText: req.ReviewText,
	}

	if err := h.postgresRepo.UpsertReview(review); err != nil {
		println("Error saving review:", err.Error())
		http.Error(w, "Failed to save review", http.StatusInternalServerError)
		return
	}

	// Also update the rating table for backwards compatibility
	rating := &model.UserRating{
		UserID:   req.UserID,
		GameSlug: req.GameSlug,
		Rating:   req.Rating,
	}
	if err := h.postgresRepo.UpsertRating(rating); err != nil {
		println("Error saving rating:", err.Error())
	}

	// Update user vector asynchronously
	go h.recommendationService.UpdateUserVector(req.UserID)

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(review)
}

func (h *FeedbackHandler) GetGameReviews(w http.ResponseWriter, r *http.Request) {
	gameSlug := r.URL.Query().Get("gameSlug")
	if gameSlug == "" {
		http.Error(w, "Missing gameSlug parameter", http.StatusBadRequest)
		return
	}

	limit := 50 // Default limit
	reviews, err := h.postgresRepo.GetGameReviews(gameSlug, limit)
	if err != nil {
		http.Error(w, "Failed to fetch reviews", http.StatusInternalServerError)
		return
	}

	if reviews == nil {
		reviews = []*model.UserReview{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reviews)
}

func (h *FeedbackHandler) GetUserReview(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId")
	gameSlug := r.URL.Query().Get("gameSlug")

	if userID == "" || gameSlug == "" {
		http.Error(w, "Missing required parameters", http.StatusBadRequest)
		return
	}

	review, err := h.postgresRepo.GetUserReview(userID, gameSlug)
	if err != nil {
		http.Error(w, "Failed to fetch review", http.StatusInternalServerError)
		return
	}

	if review == nil {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{"message": "Review not found"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(review)
}
