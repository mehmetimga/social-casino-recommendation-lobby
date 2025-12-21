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

		chunks = append(chunks, chunk)
	}

	return chunks, nil
}

func (r *QdrantRepository) UpsertKBChunk(chunkID string, vector []float32, content, source, documentID string) error {
	if r.points == nil {
		return nil
	}

	ctx := context.Background()

	point := &pb.PointStruct{
		Id: &pb.PointId{
			PointIdOptions: &pb.PointId_Uuid{Uuid: chunkID},
		},
		Vectors: &pb.Vectors{
			VectorsOptions: &pb.Vectors_Vector{
				Vector: &pb.Vector{Data: vector},
			},
		},
		Payload: map[string]*pb.Value{
			"content":     {Kind: &pb.Value_StringValue{StringValue: content}},
			"source":      {Kind: &pb.Value_StringValue{StringValue: source}},
			"document_id": {Kind: &pb.Value_StringValue{StringValue: documentID}},
		},
	}

	_, err := r.points.Upsert(ctx, &pb.UpsertPoints{
		CollectionName: KBChunksCollection,
		Points:         []*pb.PointStruct{point},
	})

	return err
}
