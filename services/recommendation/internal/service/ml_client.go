package service

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// MLClient handles communication with the Python ML service
type MLClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewMLClient creates a new ML client
func NewMLClient(baseURL string) *MLClient {
	return &MLClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// RecommendedGame represents a recommended game with score
type RecommendedGame struct {
	GameSlug string  `json:"game_slug"`
	Score    float64 `json:"score"`
}

// InteractionRequest represents an interaction event
type InteractionRequest struct {
	UserID          string `json:"user_id"`
	GameSlug        string `json:"game_slug"`
	EventType       string `json:"event_type"`
	DurationSeconds *int   `json:"duration_seconds,omitempty"`
	Rating          *int   `json:"rating,omitempty"`
}

// RecommendRequest is the request for LightGCN recommendations
type RecommendRequest struct {
	UserID       string   `json:"user_id"`
	Limit        int      `json:"limit"`
	ExcludeGames []string `json:"exclude_games,omitempty"`
}

// RecommendResponse is the response from LightGCN recommendations
type RecommendResponse struct {
	UserID          string            `json:"user_id"`
	Recommendations []RecommendedGame `json:"recommendations"`
	Source          string            `json:"source"`
}

// SessionContext represents the user's session context
type SessionContext struct {
	Active         bool     `json:"active"`
	RecentGames    []string `json:"recent_games,omitempty"`
	SessionStart   string   `json:"session_start,omitempty"`
	InteractionCnt int      `json:"interaction_count,omitempty"`
}

// TGNRecommendResponse is the response from TGN session-aware recommendations
type TGNRecommendResponse struct {
	UserID          string            `json:"user_id"`
	Recommendations []RecommendedGame `json:"recommendations"`
	SessionContext  SessionContext    `json:"session_context"`
	Source          string            `json:"source"`
}

// HGTRecommendResponse is the response from HGT recommendations
type HGTRecommendResponse struct {
	UserID          string            `json:"user_id"`
	Recommendations []RecommendedGame `json:"recommendations"`
	Source          string            `json:"source"`
	IsColdStart     bool              `json:"is_cold_start"`
}

// HGTSimilarGamesResponse is the response for similar games
type HGTSimilarGamesResponse struct {
	GameSlug     string            `json:"game_slug"`
	SimilarGames []RecommendedGame `json:"similar_games"`
}

// HGTProviderGamesResponse is the response for provider games
type HGTProviderGamesResponse struct {
	Provider     string            `json:"provider"`
	Games        []RecommendedGame `json:"games"`
	Personalized bool              `json:"personalized"`
}

// InteractionResponse is the response after processing an interaction
type InteractionResponse struct {
	Status           string `json:"status"`
	EmbeddingUpdated bool   `json:"embedding_updated"`
}

// SessionInteractionResponse is the response from TGN interaction
type SessionInteractionResponse struct {
	Status        string `json:"status"`
	SessionActive bool   `json:"session_active"`
	MemoryUpdated bool   `json:"memory_updated"`
}

// StatusResponse is the ML service status
type StatusResponse struct {
	Status      string `json:"status"`
	ModelLoaded bool   `json:"model_loaded"`
	GraphLoaded bool   `json:"graph_loaded"`
	NumUsers    int    `json:"num_users"`
	NumGames    int    `json:"num_games"`
	NumEdges    int    `json:"num_edges"`
	Device      string `json:"device"`
}

// TGNStatusResponse is the TGN status response
type TGNStatusResponse struct {
	TGNTrained     bool           `json:"tgn_trained"`
	SessionService map[string]any `json:"session_service"`
}

// IsHealthy checks if the ML service is healthy
func (c *MLClient) IsHealthy(ctx context.Context) bool {
	if ctx == nil {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
	}

	req, err := http.NewRequestWithContext(ctx, "GET", fmt.Sprintf("%s/v1/health", c.baseURL), nil)
	if err != nil {
		return false
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close()

	return resp.StatusCode == http.StatusOK
}

// IsTGNAvailable checks if TGN is trained and available
func (c *MLClient) IsTGNAvailable(ctx context.Context) bool {
	if ctx == nil {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
	}

	req, err := http.NewRequestWithContext(ctx, "GET", fmt.Sprintf("%s/v1/tgn/status", c.baseURL), nil)
	if err != nil {
		return false
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return false
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false
	}

	var status TGNStatusResponse
	if err := json.NewDecoder(resp.Body).Decode(&status); err != nil {
		return false
	}

	return status.TGNTrained
}

// GetRecommendations gets LightGCN recommendations
func (c *MLClient) GetRecommendations(ctx context.Context, userID string, limit int, excludeGames []string) (*RecommendResponse, error) {
	reqBody := RecommendRequest{
		UserID:       userID,
		Limit:        limit,
		ExcludeGames: excludeGames,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/recommend", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("ML service returned status %d", resp.StatusCode)
	}

	var result RecommendResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// GetTGNRecommendations gets session-aware TGN recommendations
func (c *MLClient) GetTGNRecommendations(ctx context.Context, userID string, limit int, excludeRecent bool) (*TGNRecommendResponse, error) {
	reqBody := map[string]any{
		"user_id":        userID,
		"limit":          limit,
		"exclude_recent": excludeRecent,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/tgn/recommend", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("TGN service returned status %d", resp.StatusCode)
	}

	var result TGNRecommendResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// GetHGTRecommendations gets HGT heterogeneous graph recommendations
func (c *MLClient) GetHGTRecommendations(ctx context.Context, userID string, limit int, excludeGames []string, providerFilter *string) (*HGTRecommendResponse, error) {
	reqBody := map[string]any{
		"user_id": userID,
		"limit":   limit,
	}
	if excludeGames != nil {
		reqBody["exclude_games"] = excludeGames
	}
	if providerFilter != nil {
		reqBody["provider_filter"] = *providerFilter
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/hgt/recommend", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HGT service returned status %d", resp.StatusCode)
	}

	var result HGTRecommendResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// GetHGTSimilarGames gets similar games using HGT
func (c *MLClient) GetHGTSimilarGames(ctx context.Context, gameSlug string, limit int) (*HGTSimilarGamesResponse, error) {
	reqBody := map[string]any{
		"game_slug": gameSlug,
		"limit":     limit,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/hgt/similar_games", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HGT service returned status %d", resp.StatusCode)
	}

	var result HGTSimilarGamesResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// GetHGTProviderGames gets games from a provider, optionally personalized
func (c *MLClient) GetHGTProviderGames(ctx context.Context, provider string, userID *string, limit int) (*HGTProviderGamesResponse, error) {
	reqBody := map[string]any{
		"provider": provider,
		"limit":    limit,
	}
	if userID != nil {
		reqBody["user_id"] = *userID
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/hgt/provider_games", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HGT service returned status %d", resp.StatusCode)
	}

	var result HGTProviderGamesResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// NotifyInteraction notifies ML service about a new interaction
func (c *MLClient) NotifyInteraction(ctx context.Context, req *InteractionRequest) (*InteractionResponse, error) {
	jsonBody, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/interaction", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("ML service returned status %d", resp.StatusCode)
	}

	var result InteractionResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}

// NotifyTGNInteraction notifies TGN about a session interaction
func (c *MLClient) NotifyTGNInteraction(ctx context.Context, req *InteractionRequest) error {
	jsonBody, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("failed to marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/v1/tgn/interaction", c.baseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("TGN service returned status %d", resp.StatusCode)
	}

	return nil
}
