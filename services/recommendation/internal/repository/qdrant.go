package repository

import (
	"context"
	"log"

	pb "github.com/qdrant/go-client/qdrant"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"github.com/casino/recommendation/internal/model"
)

const (
	GamesCollection = "games"
	UsersCollection = "users"
	VectorSize      = 768 // Default embedding size
)

type QdrantRepository struct {
	conn    *grpc.ClientConn
	points  pb.PointsClient
	collect pb.CollectionsClient
}

func NewQdrantRepository(url string) (*QdrantRepository, error) {
	// Parse URL to get host:port
	// Assuming format: http://host:port
	host := url
	if len(url) > 7 && url[:7] == "http://" {
		host = url[7:]
	}
	// Use gRPC port (6334)
	grpcHost := host[:len(host)-4] + "6334"

	conn, err := grpc.Dial(grpcHost, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		// Fallback: try without modifying the port
		conn, err = grpc.Dial(host, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			log.Printf("Warning: Could not connect to Qdrant: %v", err)
			// Return repository anyway - will fail gracefully on operations
			return &QdrantRepository{}, nil
		}
	}

	repo := &QdrantRepository{
		conn:    conn,
		points:  pb.NewPointsClient(conn),
		collect: pb.NewCollectionsClient(conn),
	}

	// Initialize collections
	repo.initCollections()

	return repo, nil
}

func (r *QdrantRepository) initCollections() {
	ctx := context.Background()

	// Create games collection if not exists
	r.createCollectionIfNotExists(ctx, GamesCollection)

	// Create users collection if not exists
	r.createCollectionIfNotExists(ctx, UsersCollection)
}

func (r *QdrantRepository) createCollectionIfNotExists(ctx context.Context, name string) {
	if r.collect == nil {
		return
	}

	// Check if collection exists
	_, err := r.collect.Get(ctx, &pb.GetCollectionInfoRequest{
		CollectionName: name,
	})

	if err != nil {
		// Collection doesn't exist, create it
		vectorSize := uint64(VectorSize)
		_, err := r.collect.Create(ctx, &pb.CreateCollection{
			CollectionName: name,
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
			log.Printf("Warning: Could not create collection %s: %v", name, err)
		} else {
			log.Printf("Created Qdrant collection: %s", name)
		}
	}
}

func (r *QdrantRepository) UpsertGameVector(game *model.GameVector) error {
	if r.points == nil {
		return nil
	}

	ctx := context.Background()

	point := &pb.PointStruct{
		Id: &pb.PointId{
			PointIdOptions: &pb.PointId_Uuid{Uuid: game.Slug},
		},
		Vectors: &pb.Vectors{
			VectorsOptions: &pb.Vectors_Vector{
				Vector: &pb.Vector{Data: game.Vector},
			},
		},
		Payload: map[string]*pb.Value{
			"slug": {Kind: &pb.Value_StringValue{StringValue: game.Slug}},
		},
	}

	_, err := r.points.Upsert(ctx, &pb.UpsertPoints{
		CollectionName: GamesCollection,
		Points:         []*pb.PointStruct{point},
	})

	return err
}

func (r *QdrantRepository) UpsertUserVector(user *model.UserVector) error {
	if r.points == nil {
		return nil
	}

	ctx := context.Background()

	point := &pb.PointStruct{
		Id: &pb.PointId{
			PointIdOptions: &pb.PointId_Uuid{Uuid: user.UserID},
		},
		Vectors: &pb.Vectors{
			VectorsOptions: &pb.Vectors_Vector{
				Vector: &pb.Vector{Data: user.Vector},
			},
		},
		Payload: map[string]*pb.Value{
			"user_id": {Kind: &pb.Value_StringValue{StringValue: user.UserID}},
		},
	}

	_, err := r.points.Upsert(ctx, &pb.UpsertPoints{
		CollectionName: UsersCollection,
		Points:         []*pb.PointStruct{point},
	})

	return err
}

func (r *QdrantRepository) GetUserVector(userID string) ([]float32, error) {
	if r.points == nil {
		return nil, nil
	}

	ctx := context.Background()

	result, err := r.points.Get(ctx, &pb.GetPoints{
		CollectionName: UsersCollection,
		Ids: []*pb.PointId{
			{PointIdOptions: &pb.PointId_Uuid{Uuid: userID}},
		},
		WithVectors: &pb.WithVectorsSelector{
			SelectorOptions: &pb.WithVectorsSelector_Enable{Enable: true},
		},
	})

	if err != nil {
		return nil, err
	}

	if len(result.Result) == 0 {
		return nil, nil
	}

	vectors := result.Result[0].Vectors
	if vectors == nil {
		return nil, nil
	}

	if v, ok := vectors.VectorsOptions.(*pb.Vectors_Vector); ok {
		return v.Vector.Data, nil
	}

	return nil, nil
}

func (r *QdrantRepository) SearchSimilarGames(vector []float32, limit int) ([]string, error) {
	if r.points == nil {
		return nil, nil
	}

	ctx := context.Background()

	result, err := r.points.Search(ctx, &pb.SearchPoints{
		CollectionName: GamesCollection,
		Vector:         vector,
		Limit:          uint64(limit),
		WithPayload: &pb.WithPayloadSelector{
			SelectorOptions: &pb.WithPayloadSelector_Enable{Enable: true},
		},
	})

	if err != nil {
		return nil, err
	}

	var slugs []string
	for _, point := range result.Result {
		if slug, ok := point.Payload["slug"]; ok {
			if s, ok := slug.Kind.(*pb.Value_StringValue); ok {
				slugs = append(slugs, s.StringValue)
			}
		}
	}

	return slugs, nil
}
