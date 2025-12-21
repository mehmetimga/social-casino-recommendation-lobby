package service

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type LLMService struct {
	ollamaURL string
	model     string
}

type ollamaGenerateRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
	Stream bool   `json:"stream"`
}

type ollamaGenerateResponse struct {
	Response string `json:"response"`
	Done     bool   `json:"done"`
}

func NewLLMService(ollamaURL string) *LLMService {
	return &LLMService{
		ollamaURL: ollamaURL,
		model:     "llama2", // Default model, can be changed
	}
}

func (s *LLMService) Generate(prompt string) (string, error) {
	reqBody := ollamaGenerateRequest{
		Model:  s.model,
		Prompt: prompt,
		Stream: false,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	resp, err := http.Post(
		fmt.Sprintf("%s/api/generate", s.ollamaURL),
		"application/json",
		bytes.NewBuffer(jsonBody),
	)
	if err != nil {
		// Return a fallback response if LLM is not available
		return s.getFallbackResponse(prompt), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return s.getFallbackResponse(prompt), nil
	}

	var result ollamaGenerateResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return s.getFallbackResponse(prompt), nil
	}

	return result.Response, nil
}

func (s *LLMService) getFallbackResponse(prompt string) string {
	// Provide a helpful fallback when LLM is not available
	lowerPrompt := strings.ToLower(prompt)

	if strings.Contains(lowerPrompt, "slot") || strings.Contains(lowerPrompt, "game") {
		return "I'd be happy to help you with information about our casino games! We have a wide variety of slots, table games, and live casino options. You can browse our game categories or use the search feature to find specific games. Is there a particular type of game you're interested in?"
	}

	if strings.Contains(lowerPrompt, "bonus") || strings.Contains(lowerPrompt, "promotion") {
		return "We have exciting promotions available! Check out our Promotions page for current offers including welcome bonuses, free spins, and cashback rewards. Is there a specific type of bonus you're looking for?"
	}

	if strings.Contains(lowerPrompt, "rtp") {
		return "RTP stands for Return to Player, which represents the theoretical percentage of wagered money that a slot machine or game will pay back to players over time. For example, a game with 96% RTP means that for every $100 wagered, it theoretically returns $96 to players. Higher RTP generally means better odds for players."
	}

	if strings.Contains(lowerPrompt, "help") {
		return "I'm here to help! I can assist you with:\n- Finding games\n- Understanding game rules\n- Information about promotions\n- General casino questions\n\nWhat would you like to know?"
	}

	return "Thank you for your question! I'm here to help you with anything related to our casino games, promotions, and services. Could you please provide more details about what you'd like to know?"
}
