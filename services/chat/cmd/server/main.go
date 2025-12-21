package main

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"github.com/casino/chat/internal/config"
	"github.com/casino/chat/internal/handler"
	"github.com/casino/chat/internal/repository"
	"github.com/casino/chat/internal/service"
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
	llmService := service.NewLLMService(cfg.OllamaURL)
	ragService := service.NewRAGService(qdrantRepo, embeddingService)
	chatService := service.NewChatService(postgresRepo, ragService, llmService)

	// Initialize handlers
	sessionsHandler := handler.NewSessionsHandler(postgresRepo)
	messagesHandler := handler.NewMessagesHandler(chatService)

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
	r.Route("/v1/chat", func(r chi.Router) {
		r.Post("/sessions", sessionsHandler.CreateSession)
		r.Route("/sessions/{sessionId}", func(r chi.Router) {
			r.Post("/messages", messagesHandler.SendMessage)
		})
	})

	// Start server
	port := cfg.Port
	if port == "" {
		port = "8082"
	}

	log.Printf("Chat service starting on port %s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
