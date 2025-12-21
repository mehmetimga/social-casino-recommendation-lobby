package handler

import (
	"encoding/json"
	"log"
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
	ID        string `json:"id"`
	UserID    string `json:"userId,omitempty"`
	CreatedAt string `json:"createdAt"`
	UpdatedAt string `json:"updatedAt"`
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
		log.Printf("Failed to create session: %v", err)
		http.Error(w, "Failed to create session", http.StatusInternalServerError)
		return
	}
	log.Printf("Created session: %s", session.ID.String())

	userID := ""
	if session.UserID != nil {
		userID = *session.UserID
	}

	response := CreateSessionResponse{
		ID:        session.ID.String(),
		UserID:    userID,
		CreatedAt: session.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt: session.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}
