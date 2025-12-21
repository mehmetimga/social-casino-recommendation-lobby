package handler

import (
	"encoding/json"
	"net/http"

	"github.com/casino/chat/internal/model"
	"github.com/casino/chat/internal/repository"
)

type SessionsHandler struct {
	postgresRepo *repository.PostgresRepository
}

func NewSessionsHandler(postgresRepo *repository.PostgresRepository) *SessionsHandler {
	return &SessionsHandler{
		postgresRepo: postgresRepo,
	}
}

type CreateSessionRequest struct {
	UserID  *string                `json:"userId,omitempty"`
	Context *model.SessionContext `json:"context,omitempty"`
}

type CreateSessionResponse struct {
	SessionID string `json:"sessionId"`
}

func (h *SessionsHandler) CreateSession(w http.ResponseWriter, r *http.Request) {
	var req CreateSessionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		// Allow empty body
		req = CreateSessionRequest{}
	}

	session := &model.ChatSession{
		UserID:  req.UserID,
		Context: req.Context,
	}

	if err := h.postgresRepo.CreateSession(session); err != nil {
		http.Error(w, "Failed to create session", http.StatusInternalServerError)
		return
	}

	response := CreateSessionResponse{
		SessionID: session.ID.String(),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}
