package main

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"github.com/casino/recommendation/internal/config"
	"github.com/casino/recommendation/internal/handler"
	"github.com/casino/recommendation/internal/repository"
	"github.com/casino/recommendation/internal/service"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize repositories
	postgresRepo, err := repository.NewPostgresRepository(cfg.PostgresURL)
	if err != nil {
		log.Fatalf("Failed to connect to PostgreSQL: %v", err)
	}
	defer postgresRepo.Close()

	qdrantRepo, err := repository.NewQdrantRepository(cfg.QdrantURL)
	if err != nil {
		log.Fatalf("Failed to connect to Qdrant: %v", err)
	}

	// Initialize services
	embeddingService := service.NewEmbeddingService(cfg.OllamaURL)
	recommendationService := service.NewRecommendationService(postgresRepo, qdrantRepo, embeddingService)

	// Initialize ML client for LightGCN and TGN recommendations
	mlClient := service.NewMLClient(cfg.MLURL)
	recommendationService.SetMLClient(mlClient)
	
	// Check if ML services are available and enable them
	// This is done in background to not block startup
	go func() {
		if mlClient.IsHealthy(nil) {
			log.Println("ML service is healthy, enabling LightGCN recommendations")
			recommendationService.EnableLightGCN(true)
			
			// Also check if TGN is available
			if mlClient.IsTGNAvailable(nil) {
				log.Println("TGN is trained, enabling session-aware recommendations")
				recommendationService.EnableTGN(true)
			} else {
				log.Println("TGN not trained yet, session-aware recommendations disabled")
			}
		} else {
			log.Println("ML service not available, using content-based recommendations only")
		}
	}()

	// Initialize handlers
	eventsHandler := handler.NewEventsHandler(postgresRepo, recommendationService)
	feedbackHandler := handler.NewFeedbackHandler(postgresRepo, recommendationService, embeddingService)
	recommendationsHandler := handler.NewRecommendationsHandler(recommendationService)

	// Setup router
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RequestID)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-Request-ID"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	// Health check
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	// API routes
	r.Route("/v1", func(r chi.Router) {
		r.Post("/events", eventsHandler.TrackEvent)
		r.Post("/feedback/rating", feedbackHandler.SubmitRating)
		r.Post("/feedback/review", feedbackHandler.SubmitReview)
		r.Get("/feedback/reviews", feedbackHandler.GetGameReviews)
		r.Get("/feedback/review", feedbackHandler.GetUserReview)
		r.Get("/recommendations", recommendationsHandler.GetRecommendations)
	})

	// Start server
	port := cfg.Port
	if port == "" {
		port = "8081"
	}

	log.Printf("Recommendation service starting on port %s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
