package repository

import (
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	_ "github.com/lib/pq"

	"github.com/casino/recommendation/internal/model"
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

// Events

func (r *PostgresRepository) CreateEvent(event *model.UserEvent) error {
	event.ID = uuid.New()
	event.CreatedAt = time.Now()

	var metadataJSON interface{}
	if event.Metadata != nil && len(event.Metadata) > 0 {
		var err error
		metadataJSON, err = json.Marshal(event.Metadata)
		if err != nil {
			return err
		}
	}

	query := `
		INSERT INTO user_events (id, user_id, game_slug, event_type, duration_seconds, metadata, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err := r.db.Exec(query,
		event.ID,
		event.UserID,
		event.GameSlug,
		event.EventType,
		event.DurationSeconds,
		metadataJSON,
		event.CreatedAt,
	)

	return err
}

func (r *PostgresRepository) GetUserEvents(userID string, since time.Time) ([]*model.UserEvent, error) {
	query := `
		SELECT id, user_id, game_slug, event_type, duration_seconds, metadata, created_at
		FROM user_events
		WHERE user_id = $1 AND created_at >= $2
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(query, userID, since)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var events []*model.UserEvent
	for rows.Next() {
		event := &model.UserEvent{}
		var metadataJSON []byte
		err := rows.Scan(
			&event.ID,
			&event.UserID,
			&event.GameSlug,
			&event.EventType,
			&event.DurationSeconds,
			&metadataJSON,
			&event.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		if metadataJSON != nil {
			json.Unmarshal(metadataJSON, &event.Metadata)
		}

		events = append(events, event)
	}

	return events, nil
}

// Ratings

func (r *PostgresRepository) UpsertRating(rating *model.UserRating) error {
	rating.ID = uuid.New()
	now := time.Now()
	rating.CreatedAt = now
	rating.UpdatedAt = now

	query := `
		INSERT INTO user_ratings (id, user_id, game_slug, rating, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (user_id, game_slug)
		DO UPDATE SET rating = $4, updated_at = $6
	`

	_, err := r.db.Exec(query,
		rating.ID,
		rating.UserID,
		rating.GameSlug,
		rating.Rating,
		rating.CreatedAt,
		rating.UpdatedAt,
	)

	return err
}

func (r *PostgresRepository) GetUserRatings(userID string) ([]*model.UserRating, error) {
	query := `
		SELECT id, user_id, game_slug, rating, created_at, updated_at
		FROM user_ratings
		WHERE user_id = $1
		ORDER BY updated_at DESC
	`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ratings []*model.UserRating
	for rows.Next() {
		rating := &model.UserRating{}
		err := rows.Scan(
			&rating.ID,
			&rating.UserID,
			&rating.GameSlug,
			&rating.Rating,
			&rating.CreatedAt,
			&rating.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		ratings = append(ratings, rating)
	}

	return ratings, nil
}

// Reviews

func (r *PostgresRepository) UpsertReview(review *model.UserReview) error {
	review.ID = uuid.New()
	now := time.Now()
	review.CreatedAt = now
	review.UpdatedAt = now

	query := `
		INSERT INTO user_reviews (id, user_id, game_slug, rating, review_text, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, game_slug)
		DO UPDATE SET rating = $4, review_text = $5, updated_at = $7
		RETURNING id, created_at, updated_at
	`

	err := r.db.QueryRow(query,
		review.ID,
		review.UserID,
		review.GameSlug,
		review.Rating,
		review.ReviewText,
		review.CreatedAt,
		review.UpdatedAt,
	).Scan(&review.ID, &review.CreatedAt, &review.UpdatedAt)

	return err
}

func (r *PostgresRepository) GetGameReviews(gameSlug string, limit int) ([]*model.UserReview, error) {
	query := `
		SELECT id, user_id, game_slug, rating, review_text, created_at, updated_at
		FROM user_reviews
		WHERE game_slug = $1
		ORDER BY created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(query, gameSlug, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reviews []*model.UserReview
	for rows.Next() {
		review := &model.UserReview{}
		err := rows.Scan(
			&review.ID,
			&review.UserID,
			&review.GameSlug,
			&review.Rating,
			&review.ReviewText,
			&review.CreatedAt,
			&review.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		reviews = append(reviews, review)
	}

	return reviews, nil
}

func (r *PostgresRepository) GetUserReview(userID, gameSlug string) (*model.UserReview, error) {
	query := `
		SELECT id, user_id, game_slug, rating, review_text, created_at, updated_at
		FROM user_reviews
		WHERE user_id = $1 AND game_slug = $2
	`

	review := &model.UserReview{}
	err := r.db.QueryRow(query, userID, gameSlug).Scan(
		&review.ID,
		&review.UserID,
		&review.GameSlug,
		&review.Rating,
		&review.ReviewText,
		&review.CreatedAt,
		&review.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	return review, err
}

// User Preferences

func (r *PostgresRepository) GetOrCreateUserPreference(userID string) (*model.UserPreference, error) {
	pref := &model.UserPreference{}

	query := `SELECT user_id, vector_updated_at, created_at, updated_at FROM user_preferences WHERE user_id = $1`
	err := r.db.QueryRow(query, userID).Scan(&pref.UserID, &pref.VectorUpdatedAt, &pref.CreatedAt, &pref.UpdatedAt)

	if err == sql.ErrNoRows {
		// Create new preference
		pref.UserID = userID
		now := time.Now()
		pref.CreatedAt = now
		pref.UpdatedAt = now

		insertQuery := `
			INSERT INTO user_preferences (id, user_id, created_at, updated_at)
			VALUES ($1, $2, $3, $4)
		`
		_, err = r.db.Exec(insertQuery, uuid.New(), userID, pref.CreatedAt, pref.UpdatedAt)
		if err != nil {
			return nil, err
		}
		return pref, nil
	}

	return pref, err
}

func (r *PostgresRepository) UpdateUserPreferenceVectorTime(userID string) error {
	query := `UPDATE user_preferences SET vector_updated_at = $1, updated_at = $1 WHERE user_id = $2`
	_, err := r.db.Exec(query, time.Now(), userID)
	return err
}
