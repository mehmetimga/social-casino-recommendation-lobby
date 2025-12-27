package service

import (
	"context"
	"log"
	"math"
	"time"

	"github.com/casino/recommendation/internal/model"
	"github.com/casino/recommendation/internal/repository"
)

type RecommendationService struct {
	postgresRepo     *repository.PostgresRepository
	qdrantRepo       *repository.QdrantRepository
	embeddingService *EmbeddingService
	mlClient         *MLClient
	useLightGCN      bool // Whether to use LightGCN recommendations
	useTGN           bool // Whether to use TGN session-aware recommendations
	useHGT           bool // Whether to use HGT heterogeneous recommendations
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
		useLightGCN:      false, // Disabled by default until ML service is trained
		useTGN:           false, // Disabled by default until TGN is trained
		useHGT:           false, // Disabled by default until HGT is trained
	}
}

// SetMLClient sets the ML client for LightGCN recommendations
func (s *RecommendationService) SetMLClient(mlClient *MLClient) {
	s.mlClient = mlClient
}

// EnableLightGCN enables LightGCN-based recommendations
func (s *RecommendationService) EnableLightGCN(enable bool) {
	s.useLightGCN = enable
}

// EnableTGN enables TGN session-aware recommendations
func (s *RecommendationService) EnableTGN(enable bool) {
	s.useTGN = enable
}

// EnableHGT enables HGT heterogeneous recommendations
func (s *RecommendationService) EnableHGT(enable bool) {
	s.useHGT = enable
}

func (s *RecommendationService) GetRecommendations(userID, placement string, limit int, vipLevel string) ([]string, error) {
	// Try TGN session-aware recommendations first if enabled
	if s.useTGN && s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		tgnRecs, err := s.mlClient.GetTGNRecommendations(ctx, userID, limit, true)
		if err == nil && len(tgnRecs.Recommendations) > 0 {
			log.Printf("Got %d TGN session-aware recommendations for user %s (session active: %v)",
				len(tgnRecs.Recommendations), userID, tgnRecs.SessionContext.Active)
			
			// Extract game slugs
			slugs := make([]string, 0, len(tgnRecs.Recommendations))
			for _, rec := range tgnRecs.Recommendations {
				slugs = append(slugs, rec.GameSlug)
			}
			
			return slugs, nil
		}
		
		if err != nil {
			log.Printf("TGN recommendations failed, trying HGT/LightGCN: %v", err)
		}
	}

	// Try HGT for cold-start or general recommendations if enabled
	if s.useHGT && s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		hgtRecs, err := s.mlClient.GetHGTRecommendations(ctx, userID, limit, nil, nil)
		if err == nil && len(hgtRecs.Recommendations) > 0 {
			source := "HGT"
			if hgtRecs.IsColdStart {
				source = "HGT (cold-start)"
			}
			log.Printf("Got %d %s recommendations for user %s", len(hgtRecs.Recommendations), source, userID)
			
			slugs := make([]string, 0, len(hgtRecs.Recommendations))
			for _, rec := range hgtRecs.Recommendations {
				slugs = append(slugs, rec.GameSlug)
			}
			
			return slugs, nil
		}
		
		if err != nil {
			log.Printf("HGT recommendations failed, trying LightGCN: %v", err)
		}
	}

	// Try LightGCN recommendations if enabled
	if s.useLightGCN && s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		mlRecs, err := s.mlClient.GetRecommendations(ctx, userID, limit, nil)
		if err == nil && len(mlRecs.Recommendations) > 0 {
			log.Printf("Got %d LightGCN recommendations for user %s", len(mlRecs.Recommendations), userID)
			
			// Extract game slugs
			slugs := make([]string, 0, len(mlRecs.Recommendations))
			for _, rec := range mlRecs.Recommendations {
				slugs = append(slugs, rec.GameSlug)
			}
			
			// TODO: Apply VIP level filtering (currently done in ML service)
			return slugs, nil
		}
		
		// Fall back to content-based if LightGCN fails
		if err != nil {
			log.Printf("LightGCN recommendations failed, falling back to content-based: %v", err)
		}
	}

	// Content-based fallback: Get user vector from Qdrant
	userVector, err := s.qdrantRepo.GetUserVector(userID)
	if err != nil {
		return nil, err
	}

	// If no user vector exists, try HGT cold-start if available
	if userVector == nil || len(userVector) == 0 {
		if s.useHGT && s.mlClient != nil {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			
			hgtRecs, err := s.mlClient.GetHGTRecommendations(ctx, userID, limit, nil, nil)
			if err == nil && len(hgtRecs.Recommendations) > 0 {
				log.Printf("Got %d HGT cold-start recommendations for new user %s", len(hgtRecs.Recommendations), userID)
				
				slugs := make([]string, 0, len(hgtRecs.Recommendations))
				for _, rec := range hgtRecs.Recommendations {
					slugs = append(slugs, rec.GameSlug)
				}
				
				return slugs, nil
			}
		}
		// Return empty - frontend will fallback to popular
		return []string{}, nil
	}

	// Search for similar games in Qdrant with VIP level filter
	recommendations, err := s.qdrantRepo.SearchSimilarGames(userVector, limit, vipLevel)
	if err != nil {
		return nil, err
	}

	return recommendations, nil
}

// GetSimilarGames returns games similar to a given game using HGT
func (s *RecommendationService) GetSimilarGames(gameSlug string, limit int) ([]string, error) {
	if s.useHGT && s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		resp, err := s.mlClient.GetHGTSimilarGames(ctx, gameSlug, limit)
		if err == nil && len(resp.SimilarGames) > 0 {
			log.Printf("Got %d similar games for %s from HGT", len(resp.SimilarGames), gameSlug)
			
			slugs := make([]string, 0, len(resp.SimilarGames))
			for _, game := range resp.SimilarGames {
				slugs = append(slugs, game.GameSlug)
			}
			return slugs, nil
		}
		
		if err != nil {
			log.Printf("HGT similar games failed: %v", err)
		}
	}
	
	// Fallback: use content-based similarity via game embedding
	return []string{}, nil
}

// GetProviderGames returns games from a specific provider, optionally personalized for a user
func (s *RecommendationService) GetProviderGames(provider string, userID *string, limit int) ([]string, error) {
	if s.useHGT && s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		resp, err := s.mlClient.GetHGTProviderGames(ctx, provider, userID, limit)
		if err == nil && len(resp.Games) > 0 {
			personalized := ""
			if resp.Personalized {
				personalized = " (personalized)"
			}
			log.Printf("Got %d games from provider %s%s via HGT", len(resp.Games), provider, personalized)
			
			slugs := make([]string, 0, len(resp.Games))
			for _, game := range resp.Games {
				slugs = append(slugs, game.GameSlug)
			}
			return slugs, nil
		}
		
		if err != nil {
			log.Printf("HGT provider games failed: %v", err)
		}
	}
	
	// Fallback: would need CMS integration
	return []string{}, nil
}

// NotifyInteraction notifies the ML services of a new interaction
func (s *RecommendationService) NotifyInteraction(userID, gameSlug, eventType string, durationSeconds *int, rating *int) {
	if s.mlClient == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	req := &InteractionRequest{
		UserID:    userID,
		GameSlug:  gameSlug,
		EventType: eventType,
	}
	if durationSeconds != nil {
		req.DurationSeconds = durationSeconds
	}
	if rating != nil {
		req.Rating = rating
	}

	// Notify TGN for session tracking (fire and forget)
	if s.useTGN {
		go func() {
			if err := s.mlClient.NotifyTGNInteraction(ctx, req); err != nil {
				log.Printf("Failed to notify TGN of interaction: %v", err)
			}
		}()
	}

	// Notify LightGCN (for future real-time updates)
	go func() {
		if _, err := s.mlClient.NotifyInteraction(ctx, req); err != nil {
			log.Printf("Failed to notify ML service of interaction: %v", err)
		}
	}()
}

// GetHybridRecommendations gets recommendations using both content-based and collaborative filtering
func (s *RecommendationService) GetHybridRecommendations(userID, placement string, limit int, vipLevel string) ([]string, error) {
	contentWeight := 0.4  // Weight for content-based scores
	collabWeight := 0.6   // Weight for collaborative filtering scores

	// Get content-based recommendations
	contentRecs, err := s.qdrantRepo.GetUserVector(userID)
	if err != nil {
		return nil, err
	}

	var contentSlugs []string
	if contentRecs != nil && len(contentRecs) > 0 {
		contentSlugs, _ = s.qdrantRepo.SearchSimilarGames(contentRecs, limit*2, vipLevel)
	}

	// Get collaborative filtering recommendations
	var collabRecs []RecommendedGame
	if s.mlClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		mlResp, err := s.mlClient.GetRecommendations(ctx, userID, limit*2, nil)
		if err == nil && mlResp != nil {
			collabRecs = mlResp.Recommendations
		}
	}

	// If only content-based available
	if len(collabRecs) == 0 {
		if len(contentSlugs) > limit {
			return contentSlugs[:limit], nil
		}
		return contentSlugs, nil
	}

	// If only collaborative available
	if len(contentSlugs) == 0 {
		slugs := make([]string, 0, len(collabRecs))
		for _, rec := range collabRecs {
			slugs = append(slugs, rec.GameSlug)
		}
		if len(slugs) > limit {
			return slugs[:limit], nil
		}
		return slugs, nil
	}

	// Combine scores
	scores := make(map[string]float64)

	// Add content-based scores (position-based)
	for i, slug := range contentSlugs {
		scores[slug] += contentWeight * float64(len(contentSlugs)-i) / float64(len(contentSlugs))
	}

	// Add collaborative scores
	maxCollabScore := 1.0
	if len(collabRecs) > 0 {
		maxCollabScore = collabRecs[0].Score
	}
	for _, rec := range collabRecs {
		normalizedScore := rec.Score / maxCollabScore
		scores[rec.GameSlug] += collabWeight * normalizedScore
	}

	// Sort by combined score
	type scoredGame struct {
		Slug  string
		Score float64
	}
	ranked := make([]scoredGame, 0, len(scores))
	for slug, score := range scores {
		ranked = append(ranked, scoredGame{Slug: slug, Score: score})
	}

	// Sort descending
	for i := 0; i < len(ranked)-1; i++ {
		for j := i + 1; j < len(ranked); j++ {
			if ranked[j].Score > ranked[i].Score {
				ranked[i], ranked[j] = ranked[j], ranked[i]
			}
		}
	}

	// Return top N
	result := make([]string, 0, limit)
	for i := 0; i < len(ranked) && i < limit; i++ {
		result = append(result, ranked[i].Slug)
	}

	return result, nil
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

	// Get user reviews (which include sentiment scores)
	reviews, err := s.postgresRepo.GetUserReviews(userID)
	if err != nil {
		return err
	}

	if len(events) == 0 && len(ratings) == 0 && len(reviews) == 0 {
		return nil // No data to create vector from
	}

	// Calculate weighted game preferences
	gameWeights := s.calculateGameWeights(events, ratings, reviews)

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

func (s *RecommendationService) calculateGameWeights(events []*model.UserEvent, ratings []*model.UserRating, reviews []*model.UserReview) map[string]float64 {
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

	// Create a map of games with reviews (to avoid double-counting)
	reviewedGames := make(map[string]bool)
	for _, review := range reviews {
		reviewedGames[review.GameSlug] = true
	}

	// Process ratings with time decay (only for games without reviews)
	for _, rating := range ratings {
		// Skip if this game has a review (we'll use the review instead)
		if reviewedGames[rating.GameSlug] {
			continue
		}

		weight := model.GetRatingWeight(rating.Rating)

		// Apply time decay (half-life = 90 days)
		daysSince := now.Sub(rating.UpdatedAt).Hours() / 24
		decayFactor := math.Pow(0.5, daysSince/float64(model.RatingHalfLife))
		weight *= decayFactor

		weights[rating.GameSlug] += weight
	}

	// Process reviews with sentiment-adjusted weights
	for _, review := range reviews {
		weight := model.GetRatingWeight(review.Rating)

		// Apply sentiment multiplier if available
		if review.SentimentScore != nil {
			// Sentiment score ranges from -1 to +1
			// We use it as a multiplier:
			// - Positive sentiment (0.5 to 1.0) increases weight by 10-50%
			// - Negative sentiment (-1.0 to -0.5) decreases weight by 10-50%
			// - Neutral sentiment (around 0) has minimal effect
			sentimentMultiplier := 1.0 + (*review.SentimentScore * 0.5)
			weight *= sentimentMultiplier
		}

		// Apply time decay (half-life = 90 days)
		daysSince := now.Sub(review.UpdatedAt).Hours() / 24
		decayFactor := math.Pow(0.5, daysSince/float64(model.RatingHalfLife))
		weight *= decayFactor

		weights[review.GameSlug] += weight
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
