package config

import "os"

type Config struct {
	Port        string
	PostgresURL string
	QdrantURL   string
	OllamaURL   string
}

func Load() *Config {
	return &Config{
		Port:        getEnv("PORT", "8082"),
		PostgresURL: getEnv("POSTGRES_URL", "postgres://casino:casino_secret@localhost:5432/casino_db?sslmode=disable"),
		QdrantURL:   getEnv("QDRANT_URL", "http://localhost:6333"),
		OllamaURL:   getEnv("OLLAMA_URL", "http://localhost:11434"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
