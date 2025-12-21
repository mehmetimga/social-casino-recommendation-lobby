package repository

import (
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	_ "github.com/lib/pq"

	"github.com/casino/chat/internal/model"
)

type PostgresRepository struct {
	db *sql.DB
}

func NewPostgresRepository(connStr string) (*PostgresRepository, error) {
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return &PostgresRepository{db: db}, nil
}

func (r *PostgresRepository) Close() error {
	return r.db.Close()
}

// Sessions

func (r *PostgresRepository) CreateSession(session *model.ChatSession) error {
	session.ID = uuid.New()
	now := time.Now()
	session.CreatedAt = now
	session.UpdatedAt = now

	var contextJSON []byte
	if session.Context != nil {
		var err error
		contextJSON, err = json.Marshal(session.Context)
		if err != nil {
			return err
		}
	}

	query := `
		INSERT INTO chat_sessions (id, user_id, context, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err := r.db.Exec(query,
		session.ID,
		session.UserID,
		contextJSON,
		session.CreatedAt,
		session.UpdatedAt,
	)

	return err
}

func (r *PostgresRepository) GetSession(id uuid.UUID) (*model.ChatSession, error) {
	session := &model.ChatSession{}
	var contextJSON []byte

	query := `SELECT id, user_id, context, created_at, updated_at FROM chat_sessions WHERE id = $1`
	err := r.db.QueryRow(query, id).Scan(
		&session.ID,
		&session.UserID,
		&contextJSON,
		&session.CreatedAt,
		&session.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if contextJSON != nil {
		session.Context = &model.SessionContext{}
		json.Unmarshal(contextJSON, session.Context)
	}

	return session, nil
}

func (r *PostgresRepository) UpdateSessionTime(id uuid.UUID) error {
	query := `UPDATE chat_sessions SET updated_at = $1 WHERE id = $2`
	_, err := r.db.Exec(query, time.Now(), id)
	return err
}

// Messages

func (r *PostgresRepository) CreateMessage(message *model.ChatMessage) error {
	message.ID = uuid.New()
	message.CreatedAt = time.Now()

	var citationsJSON []byte
	if message.Citations != nil {
		var err error
		citationsJSON, err = json.Marshal(message.Citations)
		if err != nil {
			return err
		}
	}

	query := `
		INSERT INTO chat_messages (id, session_id, role, content, citations, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`

	_, err := r.db.Exec(query,
		message.ID,
		message.SessionID,
		message.Role,
		message.Content,
		citationsJSON,
		message.CreatedAt,
	)

	return err
}

func (r *PostgresRepository) GetSessionMessages(sessionID uuid.UUID, limit int) ([]*model.ChatMessage, error) {
	query := `
		SELECT id, session_id, role, content, citations, created_at
		FROM chat_messages
		WHERE session_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(query, sessionID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*model.ChatMessage
	for rows.Next() {
		msg := &model.ChatMessage{}
		var citationsJSON []byte
		err := rows.Scan(
			&msg.ID,
			&msg.SessionID,
			&msg.Role,
			&msg.Content,
			&citationsJSON,
			&msg.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		if citationsJSON != nil {
			json.Unmarshal(citationsJSON, &msg.Citations)
		}

		messages = append(messages, msg)
	}

	// Reverse to get chronological order
	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	return messages, nil
}
