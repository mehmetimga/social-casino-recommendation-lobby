/**
 * ML Service API client for visualization endpoints.
 */

const ML_API_URL = import.meta.env.VITE_ML_URL || 'http://localhost:8083';

// Types
export interface EmbeddingPoint {
  id: string;
  type: 'user' | 'game' | string;
  x: number;
  y: number;
  z?: number;  // For 3D projections
  label: string | null;
  metadata?: Record<string, unknown>;
}

export interface EmbeddingsResponse {
  points: EmbeddingPoint[];
  stats: {
    total_points: number;
    num_users: number;
    num_games: number;
    embedding_dim: number;
  };
  projection_method: string;
  dimensions: number;  // 2 or 3
}

export interface GraphNode {
  id: string;
  type: string;
  label: string | null;
  size?: number;
  color?: string;
}

export interface GraphEdge {
  source: string;
  target: string;
  type: string;
  weight?: number;
}

export interface GraphResponse {
  nodes: GraphNode[];
  edges: GraphEdge[];
  stats: {
    total_nodes: number;
    total_edges: number;
    node_types: string[];
    edge_types: string[];
    graph_type: string;
  };
}

export interface CollectionInfo {
  name: string;
  vectors_count: number;
  points_count: number;
  status: string;
  vector_size: number | null;
}

export interface MLStatus {
  status: string;
  model_loaded: boolean;
  graph_loaded: boolean;
  num_users: number;
  num_games: number;
  num_edges: number;
  device: string;
  collections: Record<string, unknown>;
}

// API Functions

export async function fetchEmbeddings(
  projection: 'tsne' | 'umap' | 'pca' = 'tsne',
  dimensions: 2 | 3 = 2,
  includeUsers: boolean = true,
  includeGames: boolean = true,
  maxPoints: number = 500
): Promise<EmbeddingsResponse> {
  const response = await fetch(`${ML_API_URL}/v1/viz/embeddings`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      projection,
      dimensions,
      include_users: includeUsers,
      include_games: includeGames,
      max_points: maxPoints,
    }),
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch embeddings: ${response.statusText}`);
  }

  return response.json();
}

export async function rebuildGraph(): Promise<{ status: string; num_users: number; num_games: number; num_edges: number }> {
  const response = await fetch(`${ML_API_URL}/v1/rebuild`, {
    method: 'POST',
  });

  if (!response.ok) {
    throw new Error(`Failed to rebuild graph: ${response.statusText}`);
  }

  return response.json();
}

export async function fetchGraph(
  maxNodes: number = 200,
  maxEdges: number = 500,
  includeWeights: boolean = true,
  autoRebuild: boolean = true
): Promise<GraphResponse> {
  // First try to fetch the graph
  let response = await fetch(`${ML_API_URL}/v1/viz/graph`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      max_nodes: maxNodes,
      max_edges: maxEdges,
      include_weights: includeWeights,
    }),
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch graph: ${response.statusText}`);
  }

  let data: GraphResponse = await response.json();

  // If graph is empty and autoRebuild is enabled, try to rebuild from database
  if (autoRebuild && data.nodes.length === 0) {
    try {
      await rebuildGraph();
      
      // Retry fetching graph after rebuild
      response = await fetch(`${ML_API_URL}/v1/viz/graph`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          max_nodes: maxNodes,
          max_edges: maxEdges,
          include_weights: includeWeights,
        }),
      });

      if (response.ok) {
        data = await response.json();
      }
    } catch (e) {
      // Rebuild failed, return original empty response
      console.warn('Graph rebuild failed:', e);
    }
  }

  return data;
}

export async function fetchCollections(): Promise<{ collections: CollectionInfo[] }> {
  const response = await fetch(`${ML_API_URL}/v1/viz/collections`);

  if (!response.ok) {
    throw new Error(`Failed to fetch collections: ${response.statusText}`);
  }

  return response.json();
}

export async function fetchMLStatus(): Promise<MLStatus> {
  const response = await fetch(`${ML_API_URL}/v1/status`);

  if (!response.ok) {
    throw new Error(`Failed to fetch ML status: ${response.statusText}`);
  }

  return response.json();
}

export async function fetchSampleEmbeddings(
  collectionName: string,
  limit: number = 10
): Promise<{ collection: string; samples: unknown[] }> {
  const response = await fetch(
    `${ML_API_URL}/v1/viz/sample_embeddings/${collectionName}?limit=${limit}`
  );

  if (!response.ok) {
    throw new Error(`Failed to fetch samples: ${response.statusText}`);
  }

  return response.json();
}

export async function trainLightGCN(
  lookbackDays: number = 30,
  numEpochs: number = 100
): Promise<unknown> {
  const response = await fetch(`${ML_API_URL}/v1/train`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      lookback_days: lookbackDays,
      num_epochs: numEpochs,
    }),
  });

  if (!response.ok) {
    throw new Error(`Training failed: ${response.statusText}`);
  }

  return response.json();
}

export async function trainHGT(
  lookbackDays: number = 30,
  numEpochs: number = 100
): Promise<unknown> {
  const response = await fetch(`${ML_API_URL}/v1/hgt/train`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      lookback_days: lookbackDays,
      num_epochs: numEpochs,
    }),
  });

  if (!response.ok) {
    throw new Error(`HGT training failed: ${response.statusText}`);
  }

  return response.json();
}

