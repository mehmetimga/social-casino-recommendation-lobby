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

type ollamaChatRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
	Stream bool   `json:"stream"`
}

type ollamaChatResponse struct {
	Response string `json:"response"`
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

// AnalyzeSentiment analyzes the sentiment of review text using Ollama LLM
// Returns a sentiment score from -1.0 (very negative) to +1.0 (very positive)
func (s *EmbeddingService) AnalyzeSentiment(reviewText string) (float64, error) {
	if reviewText == "" {
		return 0.0, fmt.Errorf("review text is empty")
	}

	prompt := fmt.Sprintf(`Analyze the sentiment of this casino game review and respond with ONLY a number between -1.0 and 1.0.
-1.0 = extremely negative (hates the game)
-0.5 = negative (dislikes the game)
0.0 = neutral
+0.5 = positive (likes the game)
+1.0 = extremely positive (loves the game)

Review: "%s"

Respond with only the numerical score (e.g., 0.8 or -0.3), nothing else:`, reviewText)

	reqBody := ollamaChatRequest{
		Model:  "llama3.2:3b",
		Prompt: prompt,
		Stream: false,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return 0.0, fmt.Errorf("failed to marshal request: %w", err)
	}

	resp, err := http.Post(
		fmt.Sprintf("%s/api/generate", s.ollamaURL),
		"application/json",
		bytes.NewBuffer(jsonBody),
	)
	if err != nil {
		// If Ollama is not available, return neutral sentiment
		return 0.0, fmt.Errorf("ollama not available: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return 0.0, fmt.Errorf("ollama returned status %d", resp.StatusCode)
	}

	var result ollamaChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return 0.0, fmt.Errorf("failed to decode response: %w", err)
	}

	// Parse the sentiment score from the response
	var score float64
	_, err = fmt.Sscanf(result.Response, "%f", &score)
	if err != nil {
		// Try to extract number from response text
		// Sometimes LLM includes extra text, try to find the number
		var found bool
		for _, word := range []string{result.Response, ""} {
			if _, err := fmt.Sscanf(word, "%f", &score); err == nil {
				found = true
				break
			}
		}
		if !found {
			return 0.0, fmt.Errorf("failed to parse sentiment score from: %s", result.Response)
		}
	}

	// Clamp score between -1.0 and 1.0
	if score < -1.0 {
		score = -1.0
	} else if score > 1.0 {
		score = 1.0
	}

	return score, nil
}
