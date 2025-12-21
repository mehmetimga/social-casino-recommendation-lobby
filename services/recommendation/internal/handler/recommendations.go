package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/casino/recommendation/internal/service"
)

type RecommendationsHandler struct {
	recommendationService *service.RecommendationService
}

func NewRecommendationsHandler(recommendationService *service.RecommendationService) *RecommendationsHandler {
	return &RecommendationsHandler{
		recommendationService: recommendationService,
	}
}

type RecommendationsResponse struct {
	Recommendations []string `json:"recommendations"`
}

func (h *RecommendationsHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	userID := r.URL.Query().Get("userId")
	if userID == "" {
		http.Error(w, "userId is required", http.StatusBadRequest)
		return
	}

	placement := r.URL.Query().Get("placement")

	limit := 10
	if limitStr := r.URL.Query().Get("limit"); limitStr != "" {
		if parsed, err := strconv.Atoi(limitStr); err == nil && parsed > 0 {
			limit = parsed
		}
	}

	// Get recommendations
	recommendations, err := h.recommendationService.GetRecommendations(userID, placement, limit)
	if err != nil {
		http.Error(w, "Failed to get recommendations", http.StatusInternalServerError)
		return
	}

	// Return response
	response := RecommendationsResponse{
		Recommendations: recommendations,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
