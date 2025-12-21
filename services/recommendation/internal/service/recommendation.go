package service

import (
	"math"
	"time"

	"github.com/casino/recommendation/internal/model"
	"github.com/casino/recommendation/internal/repository"
)

type RecommendationService struct {
	postgresRepo     *repository.PostgresRepository
	qdrantRepo       *repository.QdrantRepository
	embeddingService *EmbeddingService
}

func NewRecommendationService(
	postgresRepo *repository.PostgresRepository,
	qdrantRepo *repository.QdrantRepository,
	embeddingService *EmbeddingService,
) *RecommendationService {
	return &RecommendationService{
		postgresRepo:     postgresRepo,
		qdrantRepo:       qdrantRepo,
		embeddingService: embeddingService,
	}
}

func (s *RecommendationService) GetRecommendations(userID, placement string, limit int) ([]string, error) {
	// Get user vector from Qdrant
	userVector, err := s.qdrantRepo.GetUserVector(userID)
	if err != nil {
		return nil, err
	}

	// If no user vector exists, return popular games (would need CMS integration)
	if userVector == nil || len(userVector) == 0 {
		// Return empty - frontend will fallback to popular
		return []string{}, nil
	}

	// Search for similar games in Qdrant
	recommendations, err := s.qdrantRepo.SearchSimilarGames(userVector, limit)
	if err != nil {
		return nil, err
	}

	return recommendations, nil
}

func (s *RecommendationService) UpdateUserVector(userID string) error {
	// Get user events from the last 30 days
	since := time.Now().AddDate(0, 0, -30)
	events, err := s.postgresRepo.GetUserEvents(userID, since)
	if err != nil {
		return err
	}

	// Get user ratings
	ratings, err := s.postgresRepo.GetUserRatings(userID)
	if err != nil {
		return err
	}

	if len(events) == 0 && len(ratings) == 0 {
		return nil // No data to create vector from
	}

	// Calculate weighted game preferences
	gameWeights := s.calculateGameWeights(events, ratings)

	if len(gameWeights) == 0 {
		return nil
	}

	// Calculate user vector as weighted average of game vectors
	userVector, err := s.calculateUserVector(gameWeights)
	if err != nil {
		return err
	}

	if userVector == nil {
		return nil
	}

	// Store user vector in Qdrant
	err = s.qdrantRepo.UpsertUserVector(&model.UserVector{
		UserID:    userID,
		Vector:    userVector,
		UpdatedAt: time.Now(),
	})
	if err != nil {
		return err
	}

	// Update preference timestamp
	return s.postgresRepo.UpdateUserPreferenceVectorTime(userID)
}

func (s *RecommendationService) calculateGameWeights(events []*model.UserEvent, ratings []*model.UserRating) map[string]float64 {
	weights := make(map[string]float64)
	now := time.Now()

	// Process events with time decay
	for _, event := range events {
		weight := model.GetEventWeight(event.EventType)

		// Add bonus for play duration
		if event.EventType == model.EventTypePlayEnd && event.DurationSeconds != nil {
			weight += math.Log(float64(*event.DurationSeconds + 1))
		}

		// Apply time decay (half-life = 7 days)
		daysSince := now.Sub(event.CreatedAt).Hours() / 24
		decayFactor := math.Pow(0.5, daysSince/float64(model.BehaviorHalfLife))
		weight *= decayFactor

		weights[event.GameSlug] += weight
	}

	// Process ratings with time decay
	for _, rating := range ratings {
		weight := model.GetRatingWeight(rating.Rating)

		// Apply time decay (half-life = 90 days)
		daysSince := now.Sub(rating.UpdatedAt).Hours() / 24
		decayFactor := math.Pow(0.5, daysSince/float64(model.RatingHalfLife))
		weight *= decayFactor

		weights[rating.GameSlug] += weight
	}

	return weights
}

func (s *RecommendationService) calculateUserVector(gameWeights map[string]float64) ([]float32, error) {
	// For PoC, we generate embeddings for each game slug
	// In production, we'd fetch pre-computed game vectors from Qdrant

	var totalWeight float64
	var weightedSum []float64

	for gameSlug, weight := range gameWeights {
		// Skip negative weights (disliked games)
		if weight <= 0 {
			continue
		}

		// Generate embedding for game (in production, fetch from Qdrant)
		embedding, err := s.embeddingService.GenerateEmbedding(gameSlug)
		if err != nil {
			continue
		}

		if weightedSum == nil {
			weightedSum = make([]float64, len(embedding))
		}

		for i, val := range embedding {
			weightedSum[i] += float64(val) * weight
		}
		totalWeight += weight
	}

	if totalWeight == 0 || weightedSum == nil {
		return nil, nil
	}

	// Normalize
	result := make([]float32, len(weightedSum))
	for i, val := range weightedSum {
		result[i] = float32(val / totalWeight)
	}

	return result, nil
}
