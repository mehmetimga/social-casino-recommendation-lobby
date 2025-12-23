package repository

import (
	"context"
	"log"

	pb "github.com/qdrant/go-client/qdrant"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"github.com/casino/chat/internal/model"
)

const (
	KBChunksCollection = "kb_chunks"
	VectorSize         = 768
)

type QdrantRepository struct {
	conn    *grpc.ClientConn
	points  pb.PointsClient
	collect pb.CollectionsClient
}

func NewQdrantRepository(url string) (*QdrantRepository, error) {
	// Parse URL to get host:port
	host := url
	if len(url) > 7 && url[:7] == "http://" {
		host = url[7:]
	}
	// Use gRPC port (6334)
	grpcHost := host[:len(host)-4] + "6334"

	conn, err := grpc.Dial(grpcHost, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		conn, err = grpc.Dial(host, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			log.Printf("Warning: Could not connect to Qdrant: %v", err)
			return &QdrantRepository{}, nil
		}
	}

	repo := &QdrantRepository{
		conn:    conn,
		points:  pb.NewPointsClient(conn),
		collect: pb.NewCollectionsClient(conn),
	}

	repo.initCollection()

	return repo, nil
}

func (r *QdrantRepository) initCollection() {
	if r.collect == nil {
		return
	}

	ctx := context.Background()

	// Check if collection exists
	_, err := r.collect.Get(ctx, &pb.GetCollectionInfoRequest{
		CollectionName: KBChunksCollection,
	})

	if err != nil {
		// Create collection
		vectorSize := uint64(VectorSize)
		_, err := r.collect.Create(ctx, &pb.CreateCollection{
			CollectionName: KBChunksCollection,
			VectorsConfig: &pb.VectorsConfig{
				Config: &pb.VectorsConfig_Params{
					Params: &pb.VectorParams{
						Size:     vectorSize,
						Distance: pb.Distance_Cosine,
					},
				},
			},
		})
		if err != nil {
			log.Printf("Warning: Could not create collection %s: %v", KBChunksCollection, err)
		} else {
			log.Printf("Created Qdrant collection: %s", KBChunksCollection)
		}
	}
}

func (r *QdrantRepository) SearchKBChunks(vector []float32, topK int) ([]*model.RetrievedChunk, error) {
	if r.points == nil {
		return nil, nil
	}

	ctx := context.Background()

	result, err := r.points.Search(ctx, &pb.SearchPoints{
		CollectionName: KBChunksCollection,
		Vector:         vector,
		Limit:          uint64(topK),
		WithPayload: &pb.WithPayloadSelector{
			SelectorOptions: &pb.WithPayloadSelector_Enable{Enable: true},
		},
	})

	if err != nil {
		return nil, err
	}

	var chunks []*model.RetrievedChunk
	for _, point := range result.Result {
		chunk := &model.RetrievedChunk{
			Score: point.Score,
		}

		if content, ok := point.Payload["content"]; ok {
			if s, ok := content.Kind.(*pb.Value_StringValue); ok {
				chunk.Content = s.StringValue
			}
		}
		if source, ok := point.Payload["source"]; ok {
			if s, ok := source.Kind.(*pb.Value_StringValue); ok {
				chunk.Source = s.StringValue
			}
		}
		if docID, ok := point.Payload["document_id"]; ok {
			if s, ok := docID.Kind.(*pb.Value_StringValue); ok {
				chunk.DocumentID = s.StringValue
			}
		}
		// Extract game metadata fields
		if theme, ok := point.Payload["theme"]; ok {
			if s, ok := theme.Kind.(*pb.Value_StringValue); ok {
				chunk.Theme = s.StringValue
			}
		}
		if vipLevel, ok := point.Payload["vip_level"]; ok {
			if s, ok := vipLevel.Kind.(*pb.Value_StringValue); ok {
				chunk.VipLevel = s.StringValue
			}
		}
		if rtp, ok := point.Payload["rtp"]; ok {
			if s, ok := rtp.Kind.(*pb.Value_StringValue); ok {
				chunk.RTP = s.StringValue
			}
		}
		if volatility, ok := point.Payload["volatility"]; ok {
			if s, ok := volatility.Kind.(*pb.Value_StringValue); ok {
				chunk.Volatility = s.StringValue
			}
		}
		if gameType, ok := point.Payload["game_type"]; ok {
			if s, ok := gameType.Kind.(*pb.Value_StringValue); ok {
				chunk.GameType = s.StringValue
			}
		}

		chunks = append(chunks, chunk)
	}

	return chunks, nil
}

// GameMetadata holds optional metadata for game-related KB chunks
type GameMetadata struct {
	Theme      string
	VipLevel   string
	RTP        string
	Volatility string
	GameType   string
}

func (r *QdrantRepository) UpsertKBChunk(chunkID string, vector []float32, content, source, documentID string) error {
	return r.UpsertKBChunkWithMetadata(chunkID, vector, content, source, documentID, nil)
}

func (r *QdrantRepository) UpsertKBChunkWithMetadata(chunkID string, vector []float32, content, source, documentID string, metadata *GameMetadata) error {
	if r.points == nil {
		return nil
	}

	ctx := context.Background()

	payload := map[string]*pb.Value{
		"content":     {Kind: &pb.Value_StringValue{StringValue: content}},
		"source":      {Kind: &pb.Value_StringValue{StringValue: source}},
		"document_id": {Kind: &pb.Value_StringValue{StringValue: documentID}},
	}

	// Add game metadata if provided
	if metadata != nil {
		if metadata.Theme != "" {
			payload["theme"] = &pb.Value{Kind: &pb.Value_StringValue{StringValue: metadata.Theme}}
		}
		if metadata.VipLevel != "" {
			payload["vip_level"] = &pb.Value{Kind: &pb.Value_StringValue{StringValue: metadata.VipLevel}}
		}
		if metadata.RTP != "" {
			payload["rtp"] = &pb.Value{Kind: &pb.Value_StringValue{StringValue: metadata.RTP}}
		}
		if metadata.Volatility != "" {
			payload["volatility"] = &pb.Value{Kind: &pb.Value_StringValue{StringValue: metadata.Volatility}}
		}
		if metadata.GameType != "" {
			payload["game_type"] = &pb.Value{Kind: &pb.Value_StringValue{StringValue: metadata.GameType}}
		}
	}

	point := &pb.PointStruct{
		Id: &pb.PointId{
			PointIdOptions: &pb.PointId_Uuid{Uuid: chunkID},
		},
		Vectors: &pb.Vectors{
			VectorsOptions: &pb.Vectors_Vector{
				Vector: &pb.Vector{Data: vector},
			},
		},
		Payload: payload,
	}

	_, err := r.points.Upsert(ctx, &pb.UpsertPoints{
		CollectionName: KBChunksCollection,
		Points:         []*pb.PointStruct{point},
	})

	return err
}
