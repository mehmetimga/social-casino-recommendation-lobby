package service

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type EmbeddingService struct {
	ollamaURL string
	model     string
}

type ollamaEmbeddingRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
}

type ollamaEmbeddingResponse struct {
	Embedding []float32 `json:"embedding"`
}

func NewEmbeddingService(ollamaURL string) *EmbeddingService {
	return &EmbeddingService{
		ollamaURL: ollamaURL,
		model:     "nomic-embed-text", // Default embedding model
	}
}

func (s *EmbeddingService) GenerateEmbedding(text string) ([]float32, error) {
	reqBody := ollamaEmbeddingRequest{
		Model:  s.model,
		Prompt: text,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	resp, err := http.Post(
		fmt.Sprintf("%s/api/embeddings", s.ollamaURL),
		"application/json",
		bytes.NewBuffer(jsonBody),
	)
	if err != nil {
		// If Ollama is not available, return a dummy vector
		return s.generateDummyVector(), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		// Return dummy vector if embedding fails
		return s.generateDummyVector(), nil
	}

	var result ollamaEmbeddingResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return s.generateDummyVector(), nil
	}

	return result.Embedding, nil
}

func (s *EmbeddingService) GenerateGameEmbedding(title, provider, gameType string, tags []string) ([]float32, error) {
	// Create a text representation of the game
	text := fmt.Sprintf("Game: %s by %s. Type: %s.", title, provider, gameType)
	if len(tags) > 0 {
		text += fmt.Sprintf(" Tags: %v", tags)
	}
	return s.GenerateEmbedding(text)
}

// Generate a dummy vector for development/fallback
func (s *EmbeddingService) generateDummyVector() []float32 {
	// Return a 768-dimensional zero vector
	return make([]float32, 768)
}
