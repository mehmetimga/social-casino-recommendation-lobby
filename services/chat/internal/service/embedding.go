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
		model:     "nomic-embed-text",
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
		return s.generateDummyVector(), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return s.generateDummyVector(), nil
	}

	var result ollamaEmbeddingResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return s.generateDummyVector(), nil
	}

	return result.Embedding, nil
}

func (s *EmbeddingService) generateDummyVector() []float32 {
	return make([]float32, 768)
}
