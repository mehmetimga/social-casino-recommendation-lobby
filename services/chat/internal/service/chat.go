package service

import (
	"fmt"
	"strings"

	"github.com/google/uuid"

	"github.com/casino/chat/internal/model"
	"github.com/casino/chat/internal/repository"
)

const (
	MaxHistoryMessages = 10
	MaxContextChunks   = 5
)

type ChatService struct {
	postgresRepo *repository.PostgresRepository
	ragService   *RAGService
	llmService   *LLMService
}

func NewChatService(
	postgresRepo *repository.PostgresRepository,
	ragService *RAGService,
	llmService *LLMService,
) *ChatService {
	return &ChatService{
		postgresRepo: postgresRepo,
		ragService:   ragService,
		llmService:   llmService,
	}
}

type ChatResponse struct {
	MessageID uuid.UUID        `json:"messageId"`
	Content   string           `json:"content"`
	Citations []model.Citation `json:"citations,omitempty"`
}

func (s *ChatService) ProcessMessage(sessionID uuid.UUID, userMessage string) (*ChatResponse, error) {
	// 1. Save user message
	userMsg := &model.ChatMessage{
		SessionID: sessionID,
		Role:      model.RoleUser,
		Content:   userMessage,
	}
	if err := s.postgresRepo.CreateMessage(userMsg); err != nil {
		return nil, err
	}

	// 2. Get recent chat history
	history, err := s.postgresRepo.GetSessionMessages(sessionID, MaxHistoryMessages)
	if err != nil {
		return nil, err
	}

	// 3. Retrieve relevant KB context
	chunks, err := s.ragService.RetrieveContext(userMessage, MaxContextChunks)
	if err != nil {
		// Continue without RAG context if retrieval fails
		chunks = nil
	}

	// 4. Build prompt
	prompt := s.buildPrompt(userMessage, history, chunks)

	// 5. Generate response with LLM
	response, err := s.llmService.Generate(prompt)
	if err != nil {
		return nil, err
	}

	// 6. Extract citations from chunks
	var citations []model.Citation
	if chunks != nil {
		for _, chunk := range chunks {
			if chunk.Score > 0.7 { // Only include high-relevance chunks
				citations = append(citations, model.Citation{
					DocumentID: chunk.DocumentID,
					Source:     chunk.Source,
					Excerpt:    truncate(chunk.Content, 100),
				})
			}
		}
	}

	// 7. Save assistant message
	assistantMsg := &model.ChatMessage{
		SessionID: sessionID,
		Role:      model.RoleAssistant,
		Content:   response,
		Citations: citations,
	}
	if err := s.postgresRepo.CreateMessage(assistantMsg); err != nil {
		return nil, err
	}

	// 8. Update session timestamp
	s.postgresRepo.UpdateSessionTime(sessionID)

	return &ChatResponse{
		MessageID: assistantMsg.ID,
		Content:   response,
		Citations: citations,
	}, nil
}

func (s *ChatService) buildPrompt(query string, history []*model.ChatMessage, chunks []*model.RetrievedChunk) string {
	var sb strings.Builder

	// System prompt
	sb.WriteString("You are a helpful casino support assistant. ")
	sb.WriteString("Answer based ONLY on the provided knowledge base context. ")
	sb.WriteString("If the answer is not in the knowledge base, say \"I don't have specific information about that in my knowledge base, but I can help with general questions.\" ")
	sb.WriteString("Always be friendly and helpful. ")
	sb.WriteString("If citing information, mention the source.\n\n")

	// Knowledge base context
	if chunks != nil && len(chunks) > 0 {
		sb.WriteString("=== KNOWLEDGE BASE CONTEXT ===\n")
		sb.WriteString(s.ragService.FormatContextForPrompt(chunks))
		sb.WriteString("\n=== END CONTEXT ===\n\n")
	}

	// Chat history
	if len(history) > 1 { // More than just the current message
		sb.WriteString("=== RECENT CHAT HISTORY ===\n")
		for _, msg := range history[:len(history)-1] { // Exclude the current user message
			role := "User"
			if msg.Role == model.RoleAssistant {
				role = "Assistant"
			}
			sb.WriteString(fmt.Sprintf("%s: %s\n", role, msg.Content))
		}
		sb.WriteString("=== END HISTORY ===\n\n")
	}

	// Current query
	sb.WriteString(fmt.Sprintf("User Question: %s\n\n", query))
	sb.WriteString("Assistant Response: ")

	return sb.String()
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen] + "..."
}
