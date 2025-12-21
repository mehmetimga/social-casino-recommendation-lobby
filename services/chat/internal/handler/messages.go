package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/casino/chat/internal/service"
)

type MessagesHandler struct {
	chatService *service.ChatService
}

func NewMessagesHandler(chatService *service.ChatService) *MessagesHandler {
	return &MessagesHandler{
		chatService: chatService,
	}
}

type SendMessageRequest struct {
	Content string `json:"content"`
}

func (h *MessagesHandler) SendMessage(w http.ResponseWriter, r *http.Request) {
	// Parse session ID from URL
	sessionIDStr := chi.URLParam(r, "sessionId")
	sessionID, err := uuid.Parse(sessionIDStr)
	if err != nil {
		log.Printf("ERROR: Invalid session ID: %v", err)
		http.Error(w, "Invalid session ID", http.StatusBadRequest)
		return
	}

	// Parse request body
	var req SendMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Printf("ERROR: Invalid request body: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.Content == "" {
		log.Printf("ERROR: Empty message content")
		http.Error(w, "Message content is required", http.StatusBadRequest)
		return
	}

	log.Printf("About to process message for session %s", sessionID)

	// Process message
	response, err := h.chatService.ProcessMessage(sessionID, req.Content)
	if err != nil {
		errMsg := fmt.Sprintf("Failed to process message for session %s: %v", sessionID, err)
		log.Printf("ERROR: %s", errMsg)
		http.Error(w, errMsg, http.StatusInternalServerError)
		return
	}

	log.Printf("Successfully processed message for session %s", sessionID)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
