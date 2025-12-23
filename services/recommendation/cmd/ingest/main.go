package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/casino/recommendation/internal/config"
	"github.com/casino/recommendation/internal/repository"
	"github.com/casino/recommendation/internal/service"
)

type Game struct {
	Slug             string   `json:"slug"`
	Title            string   `json:"title"`
	Provider         string   `json:"provider"`
	Type             string   `json:"type"`
	Tags             []Tag    `json:"tags"`
	ShortDescription string   `json:"shortDescription"`
	FullDescription  string   `json:"fullDescription"`
	Volatility       string   `json:"volatility"`
	RTP              float64  `json:"rtp"`
	MinBet           float64  `json:"minBet"`
	MaxBet           float64  `json:"maxBet"`
	MinVipLevel      string   `json:"minVipLevel"`
}

type Tag struct {
	Tag string `json:"tag"`
}

type GamesResponse struct {
	Docs []Game `json:"docs"`
}

func main() {
	log.Println("Starting game ingestion...")

	// Load configuration
	cfg := config.Load()

	// Initialize repositories
	qdrantRepo, err := repository.NewQdrantRepository(cfg.QdrantURL)
	if err != nil {
		log.Fatalf("Failed to connect to Qdrant: %v", err)
	}

	// Initialize embedding service
	embeddingService := service.NewEmbeddingService(cfg.OllamaURL)

	// Fetch all games from CMS
	cmsURL := cfg.CMSURL
	if cmsURL == "" {
		cmsURL = "http://localhost:3001"
	}

	log.Printf("Fetching games from CMS: %s", cmsURL)
	resp, err := http.Get(fmt.Sprintf("%s/api/games?limit=1000&depth=0", cmsURL))
	if err != nil {
		log.Fatalf("Failed to fetch games: %v", err)
	}
	defer resp.Body.Close()

	var gamesResp GamesResponse
	if err := json.NewDecoder(resp.Body).Decode(&gamesResp); err != nil {
		log.Fatalf("Failed to decode games response: %v", err)
	}

	log.Printf("Found %d games to ingest", len(gamesResp.Docs))

	// Process each game
	successCount := 0
	for _, game := range gamesResp.Docs {
		log.Printf("Processing game: %s", game.Slug)

		// Create text representation for embedding
		text := createGameText(game)

		// Generate embedding
		vector, err := embeddingService.GenerateEmbedding(text)
		if err != nil {
			log.Printf("  Error generating embedding for %s: %v", game.Slug, err)
			continue
		}

		// Create metadata
		minVipLevel := game.MinVipLevel
		if minVipLevel == "" {
			minVipLevel = "bronze" // Default to bronze if not set
		}
		metadata := map[string]string{
			"slug":        game.Slug,
			"title":       game.Title,
			"provider":    game.Provider,
			"type":        game.Type,
			"minVipLevel": minVipLevel,
		}

		// Upsert to Qdrant
		if err := qdrantRepo.UpsertGame(game.Slug, vector, metadata); err != nil {
			log.Printf("  Error upserting game %s: %v", game.Slug, err)
			continue
		}

		successCount++
		log.Printf("  ✓ Ingested %s", game.Slug)
	}

	log.Printf("\nIngestion complete! Successfully ingested %d/%d games", successCount, len(gamesResp.Docs))
}

func createGameText(game Game) string {
	var parts []string

	// Title and provider
	parts = append(parts, fmt.Sprintf("Title: %s", game.Title))
	parts = append(parts, fmt.Sprintf("Provider: %s", game.Provider))
	parts = append(parts, fmt.Sprintf("Type: %s", game.Type))

	// Tags
	if len(game.Tags) > 0 {
		tags := make([]string, len(game.Tags))
		for i, t := range game.Tags {
			tags[i] = t.Tag
		}
		parts = append(parts, fmt.Sprintf("Tags: %s", strings.Join(tags, ", ")))
	}

	// Descriptions
	if game.ShortDescription != "" {
		parts = append(parts, fmt.Sprintf("Description: %s", game.ShortDescription))
	}
	if game.FullDescription != "" {
		parts = append(parts, game.FullDescription)
	}

	// Game attributes
	parts = append(parts, fmt.Sprintf("Volatility: %s", game.Volatility))
	parts = append(parts, fmt.Sprintf("RTP: %.2f%%", game.RTP))
	parts = append(parts, fmt.Sprintf("Bet range: $%.2f - $%.2f", game.MinBet, game.MaxBet))

	return strings.Join(parts, "\n")
}
