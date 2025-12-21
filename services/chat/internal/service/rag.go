package service

import (
	"github.com/casino/chat/internal/model"
	"github.com/casino/chat/internal/repository"
)

const DefaultTopK = 5

type RAGService struct {
	qdrantRepo       *repository.QdrantRepository
	embeddingService *EmbeddingService
}

func NewRAGService(qdrantRepo *repository.QdrantRepository, embeddingService *EmbeddingService) *RAGService {
	return &RAGService{
		qdrantRepo:       qdrantRepo,
		embeddingService: embeddingService,
	}
}

func (s *RAGService) RetrieveContext(query string, topK int) ([]*model.RetrievedChunk, error) {
	if topK <= 0 {
		topK = DefaultTopK
	}

	// Generate embedding for the query
	queryVector, err := s.embeddingService.GenerateEmbedding(query)
	if err != nil {
		return nil, err
	}

	// Search for similar chunks in Qdrant
	chunks, err := s.qdrantRepo.SearchKBChunks(queryVector, topK)
	if err != nil {
		return nil, err
	}

	return chunks, nil
}

func (s *RAGService) FormatContextForPrompt(chunks []*model.RetrievedChunk) string {
	if len(chunks) == 0 {
		return "No relevant information found in the knowledge base."
	}

	var context string
	for i, chunk := range chunks {
		context += "---\n"
		context += "Source: " + chunk.Source + "\n"
		context += chunk.Content + "\n"
		if i < len(chunks)-1 {
			context += "\n"
		}
	}
	return context
}
