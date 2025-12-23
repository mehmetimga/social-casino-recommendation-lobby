package service

import (
	"fmt"
	"log"
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
	// 1. Get session to retrieve context (game info, etc.)
	session, err := s.postgresRepo.GetSession(sessionID)
	if err != nil {
		return nil, err
	}

	// Debug: Log session context
	if session != nil && session.Context != nil {
		log.Printf("Session %s context: CurrentGame=%s, CurrentPage=%s", sessionID, session.Context.CurrentGame, session.Context.CurrentPage)
	} else {
		log.Printf("Session %s has no context", sessionID)
	}

	// 2. Save user message
	userMsg := &model.ChatMessage{
		SessionID: sessionID,
		Role:      model.RoleUser,
		Content:   userMessage,
	}
	if err := s.postgresRepo.CreateMessage(userMsg); err != nil {
		return nil, err
	}

	// 3. Get recent chat history
	history, err := s.postgresRepo.GetSessionMessages(sessionID, MaxHistoryMessages)
	if err != nil {
		return nil, err
	}

	// 4. Retrieve relevant KB context
	// Include game context in RAG query for better relevance
	ragQuery := userMessage
	if session != nil && session.Context != nil && session.Context.CurrentGame != "" {
		ragQuery = fmt.Sprintf("%s %s", session.Context.CurrentGame, userMessage)
		log.Printf("RAG query enhanced with game context: %s", ragQuery)
	}
	chunks, err := s.ragService.RetrieveContext(ragQuery, MaxContextChunks)
	if err != nil {
		// Continue without RAG context if retrieval fails
		chunks = nil
	}

	// 5. Build prompt with session context
	prompt := s.buildPrompt(userMessage, history, chunks, session)

	// 6. Generate response with LLM
	response, err := s.llmService.Generate(prompt)
	if err != nil {
		return nil, err
	}

	// 7. Extract citations from chunks
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

	// 8. Save assistant message
	assistantMsg := &model.ChatMessage{
		SessionID: sessionID,
		Role:      model.RoleAssistant,
		Content:   response,
		Citations: citations,
	}
	if err := s.postgresRepo.CreateMessage(assistantMsg); err != nil {
		return nil, err
	}

	// 9. Update session timestamp
	s.postgresRepo.UpdateSessionTime(sessionID)

	return &ChatResponse{
		MessageID: assistantMsg.ID,
		Content:   response,
		Citations: citations,
	}, nil
}

func (s *ChatService) buildPrompt(query string, history []*model.ChatMessage, chunks []*model.RetrievedChunk, session *model.ChatSession) string {
	var sb strings.Builder

	// System prompt
	sb.WriteString("You are an expert social casino assistant helping players with game information, strategies, and questions. ")
	sb.WriteString("You specialize in slots, table games, live casino, and all casino gaming topics. ")
	sb.WriteString("\n\nIMPORTANT GUIDELINES:\n")
	sb.WriteString("1. Answer based PRIMARILY on the knowledge base context provided below\n")
	sb.WriteString("2. If the knowledge base contains relevant info, use it and cite the source\n")
	sb.WriteString("3. For general casino questions not in the knowledge base, provide helpful general information\n")
	sb.WriteString("4. Be enthusiastic, friendly, and professional\n")
	sb.WriteString("5. Use specific numbers, RTPs, and details when available in the context\n")
	sb.WriteString("6. Keep responses concise but informative (2-4 paragraphs)\n")
	sb.WriteString("7. When discussing games, mention key features like RTP, volatility, and unique mechanics\n")
	sb.WriteString("8. Always encourage responsible gaming\n")
	sb.WriteString("9. VIP ACCESS RULES - VERY IMPORTANT:\n")
	sb.WriteString("   - Games have VIP tier requirements: Bronze (basic), Silver, Gold, and Platinum (highest)\n")
	sb.WriteString("   - The knowledge base includes 'VIP Tier Required' for each game\n")
	sb.WriteString("   - When mentioning games above the user's tier, ALWAYS note the restriction like: '(available at Gold tier and above)'\n")
	sb.WriteString("   - DO include restricted games in your recommendations - just mark them with their tier requirement\n")
	sb.WriteString("   - Encourage users to upgrade their VIP tier to access premium games with better RTPs\n\n")

	// User VIP status context
	if session != nil && session.Context != nil {
		vipLevel := session.Context.VipLevel
		if vipLevel == "" {
			vipLevel = model.VipLevelBronze // Default to Bronze
		}
		sb.WriteString("=== USER VIP STATUS ===\n")
		sb.WriteString(fmt.Sprintf("Current VIP Tier: %s\n", strings.ToUpper(string(vipLevel))))
		sb.WriteString("User can access: Bronze tier games")
		switch vipLevel {
		case model.VipLevelSilver:
			sb.WriteString(" and Silver tier games")
		case model.VipLevelGold:
			sb.WriteString(", Silver tier games, and Gold tier games")
		case model.VipLevelPlatinum:
			sb.WriteString(", Silver tier games, Gold tier games, and Platinum tier games (full access)")
		}
		sb.WriteString("\n=== END VIP STATUS ===\n\n")
	}

	// Game context from session
	if session != nil && session.Context != nil && session.Context.CurrentGame != "" {
		sb.WriteString("=== USER SELECTED GAME ===\n")
		sb.WriteString(fmt.Sprintf("USER HAS SELECTED: %s\n", session.Context.CurrentGame))
		sb.WriteString(fmt.Sprintf("The user clicked 'Ask about this game' button while viewing %s.\n", session.Context.CurrentGame))
		sb.WriteString(fmt.Sprintf("YOU MUST answer about %s. Do NOT answer about any other game unless the user explicitly names a different game.\n", session.Context.CurrentGame))
		sb.WriteString(fmt.Sprintf("If the knowledge base doesn't have info about %s, say so - do NOT substitute with info from another game.\n", session.Context.CurrentGame))
		sb.WriteString("=== END USER SELECTED GAME ===\n\n")
	}

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
