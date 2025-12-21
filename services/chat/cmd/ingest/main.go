package main

import (
	"crypto/sha256"
	"encoding/hex"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"

	"github.com/casino/chat/internal/config"
	"github.com/casino/chat/internal/model"
	"github.com/casino/chat/internal/repository"
	"github.com/casino/chat/internal/service"
)

const (
	ChunkSize    = 500 // Characters per chunk
	ChunkOverlap = 50  // Overlap between chunks
)

func main() {
	log.Println("Starting KB ingestion...")

	// Load configuration
	cfg := config.Load()

	// Initialize repositories
	postgresRepo, err := repository.NewPostgresRepository(cfg.PostgresURL)
	if err != nil {
		log.Fatalf("Failed to connect to PostgreSQL: %v", err)
	}
	defer postgresRepo.Close()

	qdrantRepo, err := repository.NewQdrantRepository(cfg.QdrantURL)
	if err != nil {
		log.Fatalf("Failed to connect to Qdrant: %v", err)
	}

	// Initialize embedding service
	embeddingService := service.NewEmbeddingService(cfg.OllamaURL)

	// KB directory path - default to scripts/kb_wikipedia
	kbDir := filepath.Join("..", "..", "scripts", "kb_wikipedia")
	if len(os.Args) > 1 {
		kbDir = os.Args[1]
	}

	log.Printf("Reading KB files from: %s", kbDir)

	// Create or get KB source
	sourceName := "Casino Knowledge Base"
	source, err := postgresRepo.GetKBSourceByName(sourceName)
	if err != nil {
		log.Fatalf("Error checking source: %v", err)
	}

	if source == nil {
		source = &model.KBSource{
			Name:       sourceName,
			SourceType: "file",
			Metadata: map[string]string{
				"directory": kbDir,
			},
		}
		if err := postgresRepo.CreateKBSource(source); err != nil {
			log.Fatalf("Failed to create KB source: %v", err)
		}
		log.Printf("Created KB source: %s", source.Name)
	} else {
		log.Printf("Using existing KB source: %s", source.Name)
	}

	// Read all files in the KB directory
	files, err := os.ReadDir(kbDir)
	if err != nil {
		log.Fatalf("Failed to read KB directory: %v", err)
	}

	totalDocuments := 0
	totalChunks := 0

	for _, file := range files {
		if file.IsDir() || !strings.HasSuffix(file.Name(), ".txt") {
			continue
		}

		filePath := filepath.Join(kbDir, file.Name())
		log.Printf("Processing: %s", file.Name())

		// Read file content
		content, err := os.ReadFile(filePath)
		if err != nil {
			log.Printf("  Error reading file: %v", err)
			continue
		}

		// Calculate content hash
		hash := sha256.Sum256(content)
		contentHash := hex.EncodeToString(hash[:])

		// Check if document already exists
		existingDoc, err := postgresRepo.GetKBDocumentByHash(contentHash)
		if err != nil {
			log.Printf("  Error checking document: %v", err)
			continue
		}

		if existingDoc != nil {
			log.Printf("  Skipping (already ingested)")
			continue
		}

		// Extract title from file (first line or filename)
		lines := strings.Split(string(content), "\n")
		title := strings.TrimPrefix(lines[0], "Title: ")
		if title == "" || title == lines[0] {
			title = strings.TrimSuffix(file.Name(), ".txt")
		}

		// Create document
		doc := &model.KBDocument{
			SourceID:    source.ID,
			Title:       title,
			ContentHash: contentHash,
			Metadata: map[string]string{
				"filename": file.Name(),
			},
		}

		if err := postgresRepo.CreateKBDocument(doc); err != nil {
			log.Printf("  Error creating document: %v", err)
			continue
		}

		// Split content into chunks
		chunks := chunkText(string(content))
		log.Printf("  Created %d chunks", len(chunks))

		// Process each chunk
		for i, chunkContent := range chunks {
			// Generate embedding
			vector, err := embeddingService.GenerateEmbedding(chunkContent)
			if err != nil {
				log.Printf("    Error generating embedding for chunk %d: %v", i, err)
				continue
			}

			// Create chunk in PostgreSQL
			// Generate a unique UUID for the vector
			vectorUUID := uuid.New()
			chunk := &model.KBChunk{
				DocumentID: doc.ID,
				ChunkIndex: i,
				Content:    chunkContent,
				TokenCount: len(strings.Split(chunkContent, " ")),
				VectorID:   vectorUUID.String(),
				Metadata: map[string]string{
					"title":    title,
					"filename": file.Name(),
				},
			}

			if err := postgresRepo.CreateKBChunk(chunk); err != nil {
				log.Printf("    Error creating chunk %d: %v", i, err)
				continue
			}

			// Store vector in Qdrant
			if err := qdrantRepo.UpsertKBChunk(
				chunk.VectorID,
				vector,
				chunk.Content,
				title,
				doc.ID.String(),
			); err != nil {
				log.Printf("    Error storing vector for chunk %d: %v", i, err)
				continue
			}
		}

		totalDocuments++
		totalChunks += len(chunks)
		log.Printf("  ✓ Ingested document with %d chunks", len(chunks))
	}

	// Print stats
	sources, documents, chunks, err := postgresRepo.GetKBStats()
	if err != nil {
		log.Printf("Error getting stats: %v", err)
	} else {
		log.Println("\n=== KB Statistics ===")
		log.Printf("Total Sources: %d", sources)
		log.Printf("Total Documents: %d", documents)
		log.Printf("Total Chunks: %d", chunks)
	}

	log.Printf("\nIngestion complete! Processed %d documents with %d chunks", totalDocuments, totalChunks)
}

// chunkText splits text into overlapping chunks
func chunkText(text string) []string {
	var chunks []string
	runes := []rune(text)

	for i := 0; i < len(runes); i += ChunkSize - ChunkOverlap {
		end := i + ChunkSize
		if end > len(runes) {
			end = len(runes)
		}

		chunk := string(runes[i:end])

		// Skip very small chunks
		if len(strings.TrimSpace(chunk)) < 50 {
			continue
		}

		chunks = append(chunks, strings.TrimSpace(chunk))

		if end >= len(runes) {
			break
		}
	}

	return chunks
}
