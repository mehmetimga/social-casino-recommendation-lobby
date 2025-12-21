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

	var contextJSON interface{}
	if session.Context != nil {
		data, err := json.Marshal(session.Context)
		if err != nil {
			return err
		}
		contextJSON = data
	} else {
		contextJSON = nil
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

	var citationsJSON interface{}
	if message.Citations != nil && len(message.Citations) > 0 {
		data, err := json.Marshal(message.Citations)
		if err != nil {
			return err
		}
		citationsJSON = data
	} else {
		citationsJSON = nil
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

// KB Sources

func (r *PostgresRepository) CreateKBSource(source *model.KBSource) error {
	source.ID = uuid.New()
	source.CreatedAt = time.Now()

	metadataJSON, err := json.Marshal(source.Metadata)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO kb_sources (id, name, source_type, metadata, created_at)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err = r.db.Exec(query,
		source.ID,
		source.Name,
		source.SourceType,
		metadataJSON,
		source.CreatedAt,
	)

	return err
}

func (r *PostgresRepository) GetKBSourceByName(name string) (*model.KBSource, error) {
	source := &model.KBSource{}
	var metadataJSON []byte

	query := `SELECT id, name, source_type, metadata, created_at FROM kb_sources WHERE name = $1`
	err := r.db.QueryRow(query, name).Scan(
		&source.ID,
		&source.Name,
		&source.SourceType,
		&metadataJSON,
		&source.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if metadataJSON != nil {
		json.Unmarshal(metadataJSON, &source.Metadata)
	}

	return source, nil
}

// KB Documents

func (r *PostgresRepository) CreateKBDocument(doc *model.KBDocument) error {
	doc.ID = uuid.New()
	now := time.Now()
	doc.CreatedAt = now
	doc.UpdatedAt = now

	metadataJSON, err := json.Marshal(doc.Metadata)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO kb_documents (id, source_id, title, content_hash, metadata, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err = r.db.Exec(query,
		doc.ID,
		doc.SourceID,
		doc.Title,
		doc.ContentHash,
		metadataJSON,
		doc.CreatedAt,
		doc.UpdatedAt,
	)

	return err
}

func (r *PostgresRepository) GetKBDocumentByHash(hash string) (*model.KBDocument, error) {
	doc := &model.KBDocument{}
	var metadataJSON []byte

	query := `
		SELECT id, source_id, title, content_hash, metadata, created_at, updated_at
		FROM kb_documents
		WHERE content_hash = $1
	`
	err := r.db.QueryRow(query, hash).Scan(
		&doc.ID,
		&doc.SourceID,
		&doc.Title,
		&doc.ContentHash,
		&metadataJSON,
		&doc.CreatedAt,
		&doc.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if metadataJSON != nil {
		json.Unmarshal(metadataJSON, &doc.Metadata)
	}

	return doc, nil
}

// KB Chunks

func (r *PostgresRepository) CreateKBChunk(chunk *model.KBChunk) error {
	chunk.ID = uuid.New()
	chunk.CreatedAt = time.Now()

	metadataJSON, err := json.Marshal(chunk.Metadata)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO kb_chunks (id, document_id, chunk_index, content, token_count, vector_id, metadata, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	_, err = r.db.Exec(query,
		chunk.ID,
		chunk.DocumentID,
		chunk.ChunkIndex,
		chunk.Content,
		chunk.TokenCount,
		chunk.VectorID,
		metadataJSON,
		chunk.CreatedAt,
	)

	return err
}

func (r *PostgresRepository) GetChunksByDocumentID(documentID uuid.UUID) ([]*model.KBChunk, error) {
	query := `
		SELECT id, document_id, chunk_index, content, token_count, vector_id, metadata, created_at
		FROM kb_chunks
		WHERE document_id = $1
		ORDER BY chunk_index ASC
	`

	rows, err := r.db.Query(query, documentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var chunks []*model.KBChunk
	for rows.Next() {
		chunk := &model.KBChunk{}
		var metadataJSON []byte
		err := rows.Scan(
			&chunk.ID,
			&chunk.DocumentID,
			&chunk.ChunkIndex,
			&chunk.Content,
			&chunk.TokenCount,
			&chunk.VectorID,
			&metadataJSON,
			&chunk.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		if metadataJSON != nil {
			json.Unmarshal(metadataJSON, &chunk.Metadata)
		}

		chunks = append(chunks, chunk)
	}

	return chunks, nil
}

func (r *PostgresRepository) GetKBStats() (sources, documents, chunks int, err error) {
	err = r.db.QueryRow(`SELECT COUNT(*) FROM kb_sources`).Scan(&sources)
	if err != nil {
		return 0, 0, 0, err
	}

	err = r.db.QueryRow(`SELECT COUNT(*) FROM kb_documents`).Scan(&documents)
	if err != nil {
		return 0, 0, 0, err
	}

	err = r.db.QueryRow(`SELECT COUNT(*) FROM kb_chunks`).Scan(&chunks)
	if err != nil {
		return 0, 0, 0, err
	}

	return sources, documents, chunks, nil
}
