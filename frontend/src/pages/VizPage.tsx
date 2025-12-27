import { useState, useEffect, useRef, useCallback, Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, PerspectiveCamera, Line } from '@react-three/drei';
import { 
  fetchEmbeddings, 
  fetchGraph, 
  fetchCollections, 
  fetchMLStatus,
  trainLightGCN,
  trainHGT,
  type EmbeddingsResponse, 
  type GraphResponse, 
  type CollectionInfo,
  type MLStatus,
  type EmbeddingPoint
} from '../api/ml';

// Icons for controls
const ZoomInIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/><line x1="11" y1="8" x2="11" y2="14"/><line x1="8" y1="11" x2="14" y2="11"/>
  </svg>
);

const ZoomOutIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/><line x1="8" y1="11" x2="14" y2="11"/>
  </svg>
);

const FullscreenIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/>
  </svg>
);

const ExitFullscreenIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M8 3v3a2 2 0 0 1-2 2H3m18 0h-3a2 2 0 0 1-2-2V3m0 18v-3a2 2 0 0 1 2-2h3M3 16h3a2 2 0 0 1 2 2v3"/>
  </svg>
);

const ResetIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/>
  </svg>
);

// Colors for different node types
const NODE_COLORS: Record<string, string> = {
  user: '#3b82f6',      // blue
  game: '#10b981',      // emerald
  provider: '#f59e0b',  // amber
  promotion: '#ef4444', // red
  device: '#8b5cf6',    // purple
  badge: '#ec4899',     // pink
};

// 3D Point component for Three.js scene
function Point3D({ point, scale = 1 }: { point: EmbeddingPoint; scale?: number }) {
  const color = NODE_COLORS[point.type] || '#6b7280';
  const position: [number, number, number] = [
    (point.x || 0) * scale,
    (point.y || 0) * scale,
    (point.z || 0) * scale
  ];

  return (
    <mesh position={position}>
      <sphereGeometry args={[0.03, 16, 16]} />
      <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.3} />
    </mesh>
  );
}

// 3D Embedding visualization component
function Embedding3DCanvas({ 
  data, 
  width, 
  height 
}: { 
  data: EmbeddingsResponse | null; 
  width: number; 
  height: number;
}) {
  if (!data || data.dimensions !== 3) {
    return (
      <div 
        style={{ width, height }} 
        className="bg-slate-900 flex items-center justify-center text-gray-500"
      >
        Load 3D embeddings to view
      </div>
    );
  }

  return (
    <div style={{ width, height }} className="bg-slate-900 rounded">
      <Canvas>
        <PerspectiveCamera makeDefault position={[3, 2, 3]} />
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} intensity={1} />
        <pointLight position={[-10, -10, -10]} intensity={0.5} />
        
        {/* Grid helper */}
        <gridHelper args={[4, 20, '#1f2937', '#1f2937']} />
        <axesHelper args={[2]} />
        
        {/* Points */}
        <Suspense fallback={null}>
          {data.points.map((point) => (
            <Point3D key={point.id} point={point} scale={1.5} />
          ))}
        </Suspense>
        
        {/* Orbit controls for rotation */}
        <OrbitControls 
          enableDamping 
          dampingFactor={0.05}
          enablePan
          enableZoom
          minDistance={1}
          maxDistance={10}
        />
      </Canvas>
      
      {/* Legend overlay */}
      <div className="absolute bottom-4 left-4 flex gap-4 text-sm bg-black/50 rounded px-3 py-2 backdrop-blur-sm">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-blue-500" />
          <span className="text-white">Users</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-emerald-500" />
          <span className="text-white">Games</span>
        </div>
        <span className="text-gray-400 text-xs ml-2">Drag to rotate • Scroll to zoom</span>
      </div>
    </div>
  );
}

// 3D Graph Node component
function GraphNode3D({ 
  node, 
  position 
}: { 
  node: { id: string; type: string; label: string | null }; 
  position: [number, number, number];
}) {
  const color = NODE_COLORS[node.type] || '#6b7280';
  
  return (
    <mesh position={position}>
      <sphereGeometry args={[0.05, 16, 16]} />
      <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.4} />
    </mesh>
  );
}

// 3D Edge component using Line from drei
function GraphEdge3D({ 
  start, 
  end 
}: { 
  start: [number, number, number]; 
  end: [number, number, number];
}) {
  return (
    <Line
      points={[start, end]}
      color="#4b5563"
      lineWidth={1}
      transparent
      opacity={0.3}
    />
  );
}

// 3D Graph visualization component
function Graph3DCanvas({ 
  data, 
  width, 
  height 
}: { 
  data: GraphResponse | null; 
  width: number; 
  height: number;
}) {
  if (!data || data.nodes.length === 0) {
    return (
      <div 
        style={{ width, height }} 
        className="bg-slate-900 flex items-center justify-center text-gray-500"
      >
        Load graph to view 3D visualization
      </div>
    );
  }

  // Create a simple force-directed layout in 3D
  // Use a deterministic layout based on node index
  const nodePositions: Map<string, [number, number, number]> = new Map();
  const scale = 2;
  
  data.nodes.forEach((node, i) => {
    // Distribute nodes in a 3D sphere using golden ratio
    const phi = Math.acos(1 - 2 * (i + 0.5) / data.nodes.length);
    const theta = Math.PI * (1 + Math.sqrt(5)) * i;
    const r = scale * Math.cbrt((i + 1) / data.nodes.length);
    
    const x = r * Math.sin(phi) * Math.cos(theta);
    const y = r * Math.sin(phi) * Math.sin(theta);
    const z = r * Math.cos(phi);
    
    nodePositions.set(node.id, [x, y, z]);
  });

  return (
    <div style={{ width, height }} className="bg-slate-900 rounded relative">
      <Canvas>
        <PerspectiveCamera makeDefault position={[4, 3, 4]} />
        <ambientLight intensity={0.6} />
        <pointLight position={[10, 10, 10]} intensity={1} />
        <pointLight position={[-10, -10, -10]} intensity={0.5} />
        
        {/* Grid helper */}
        <gridHelper args={[6, 20, '#1f2937', '#1f2937']} />
        <axesHelper args={[3]} />
        
        {/* Edges */}
        <Suspense fallback={null}>
          {data.edges.slice(0, 500).map((edge, i) => {
            const startPos = nodePositions.get(edge.source);
            const endPos = nodePositions.get(edge.target);
            if (!startPos || !endPos) return null;
            return (
              <GraphEdge3D 
                key={`edge-${i}`} 
                start={startPos} 
                end={endPos} 
              />
            );
          })}
        </Suspense>
        
        {/* Nodes */}
        <Suspense fallback={null}>
          {data.nodes.map((node) => {
            const pos = nodePositions.get(node.id);
            if (!pos) return null;
            return (
              <GraphNode3D 
                key={node.id} 
                node={node} 
                position={pos} 
              />
            );
          })}
        </Suspense>
        
        {/* Orbit controls for rotation */}
        <OrbitControls 
          enableDamping 
          dampingFactor={0.05}
          enablePan
          enableZoom
          minDistance={2}
          maxDistance={15}
        />
      </Canvas>
      
      {/* Legend overlay */}
      <div className="absolute bottom-4 left-4 flex flex-wrap gap-3 text-sm bg-black/50 rounded px-3 py-2 backdrop-blur-sm">
        {data.stats.node_types?.map((type) => (
          <div key={type} className="flex items-center gap-2">
            <div 
              className="w-3 h-3 rounded-full" 
              style={{ backgroundColor: NODE_COLORS[type] || '#6b7280' }}
            />
            <span className="text-white capitalize">{type}</span>
          </div>
        ))}
        <span className="text-gray-400 text-xs ml-2">Drag to rotate • Scroll to zoom</span>
      </div>
    </div>
  );
}

// Canvas controls component
function CanvasControls({ 
  zoom, 
  onZoomIn, 
  onZoomOut, 
  onReset, 
  onFullscreen, 
  isFullscreen 
}: {
  zoom: number;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onReset: () => void;
  onFullscreen: () => void;
  isFullscreen: boolean;
}) {
  return (
    <div className="absolute top-2 right-2 flex flex-col gap-1 bg-white/90 rounded-lg p-1 backdrop-blur-sm border border-gray-200 shadow-sm">
      <button
        onClick={onZoomIn}
        className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
        title="Zoom In (+)"
      >
        <ZoomInIcon />
      </button>
      <button
        onClick={onZoomOut}
        className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
        title="Zoom Out (-)"
      >
        <ZoomOutIcon />
      </button>
      <button
        onClick={onReset}
        className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
        title="Reset View (R)"
      >
        <ResetIcon />
      </button>
      <div className="border-t border-gray-200 my-1" />
      <button
        onClick={onFullscreen}
        className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
        title={isFullscreen ? "Exit Fullscreen (Esc)" : "Fullscreen (F)"}
      >
        {isFullscreen ? <ExitFullscreenIcon /> : <FullscreenIcon />}
      </button>
      <div className="text-xs text-center text-gray-500 px-1">
        {Math.round(zoom * 100)}%
      </div>
    </div>
  );
}

// Embedding scatter plot component using Canvas
function EmbeddingCanvas({ 
  data, 
  width, 
  height,
  zoom,
  pan,
  onHover 
}: { 
  data: EmbeddingsResponse | null; 
  width: number; 
  height: number;
  zoom: number;
  pan: { x: number; y: number };
  onHover: (point: { id: string; type: string; label: string | null; x: number; y: number } | null) => void;
}) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [hoveredPoint, setHoveredPoint] = useState<string | null>(null);

  const draw = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas || !data) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Clear
    ctx.fillStyle = '#0a0a0f';
    ctx.fillRect(0, 0, width, height);

    // Apply zoom and pan transform
    ctx.save();
    ctx.translate(width / 2 + pan.x, height / 2 + pan.y);
    ctx.scale(zoom, zoom);
    ctx.translate(-width / 2, -height / 2);

    // Draw grid lines
    ctx.strokeStyle = '#1f2937';
    ctx.lineWidth = 0.5 / zoom;
    for (let i = 0; i <= 10; i++) {
      const x = (width / 10) * i;
      const y = (height / 10) * i;
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, height);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(width, y);
      ctx.stroke();
    }

    // Transform coordinates from [-1, 1] to canvas space with padding
    const padding = 40;
    const scaleX = (width - 2 * padding) / 2;
    const scaleY = (height - 2 * padding) / 2;
    const centerX = width / 2;
    const centerY = height / 2;

    // Draw points
    data.points.forEach((point) => {
      const x = centerX + point.x * scaleX;
      const y = centerY - point.y * scaleY; // Flip Y axis

      const color = NODE_COLORS[point.type] || '#6b7280';
      const isHovered = hoveredPoint === point.id;
      const radius = (isHovered ? 8 : 4) / zoom;

      // Glow effect for hovered
      if (isHovered) {
        ctx.shadowColor = color;
        ctx.shadowBlur = 15 / zoom;
      }

      ctx.beginPath();
      ctx.arc(x, y, radius, 0, 2 * Math.PI);
      ctx.fillStyle = color;
      ctx.fill();

      ctx.shadowBlur = 0;

      // Draw label for hovered point
      if (isHovered && point.label) {
        ctx.fillStyle = '#ffffff';
        ctx.font = `${12 / zoom}px Inter, sans-serif`;
        ctx.textAlign = 'center';
        ctx.fillText(point.label, x, y - 12 / zoom);
      }
    });

    ctx.restore();
  }, [data, width, height, hoveredPoint, zoom, pan]);

  useEffect(() => {
    draw();
  }, [draw]);

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!data) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    // Adjust mouse coordinates for zoom and pan
    const rawMouseX = e.clientX - rect.left;
    const rawMouseY = e.clientY - rect.top;
    const mouseX = (rawMouseX - width / 2 - pan.x) / zoom + width / 2;
    const mouseY = (rawMouseY - height / 2 - pan.y) / zoom + height / 2;

    const padding = 40;
    const scaleX = (width - 2 * padding) / 2;
    const scaleY = (height - 2 * padding) / 2;
    const centerX = width / 2;
    const centerY = height / 2;

    // Find closest point
    let closestPoint: EmbeddingPoint | null = null;
    let closestDist = 20 / zoom; // Max distance threshold

    for (const point of data.points) {
      const x = centerX + point.x * scaleX;
      const y = centerY - point.y * scaleY;
      const dist = Math.sqrt((mouseX - x) ** 2 + (mouseY - y) ** 2);
      if (dist < closestDist) {
        closestDist = dist;
        closestPoint = point;
      }
    }

    if (closestPoint) {
      setHoveredPoint(closestPoint.id);
      onHover({
        id: closestPoint.id,
        type: closestPoint.type,
        label: closestPoint.label,
        x: closestPoint.x,
        y: closestPoint.y
      });
    } else {
      setHoveredPoint(null);
      onHover(null);
    }
  };

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      onMouseMove={handleMouseMove}
      onMouseLeave={() => {
        setHoveredPoint(null);
        onHover(null);
      }}
      className="rounded-lg cursor-crosshair"
    />
  );
}

// Graph visualization using Canvas
function GraphCanvas({ 
  data, 
  width, 
  height,
  zoom,
  pan
}: { 
  data: GraphResponse | null; 
  width: number; 
  height: number;
  zoom: number;
  pan: { x: number; y: number };
}) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [nodePositions, setNodePositions] = useState<Map<string, { x: number; y: number }>>(new Map());
  const [hoveredNode, setHoveredNode] = useState<string | null>(null);

  // Simple force-directed layout
  useEffect(() => {
    if (!data || data.nodes.length === 0) return;

    const positions = new Map<string, { x: number; y: number }>();
    
    // Initialize with random positions
    data.nodes.forEach((node) => {
      positions.set(node.id, {
        x: Math.random() * (width - 100) + 50,
        y: Math.random() * (height - 100) + 50,
      });
    });

    // Simple force simulation (reduced iterations for performance)
    for (let iter = 0; iter < 50; iter++) {
      // Repulsion between all nodes
      data.nodes.forEach((nodeA) => {
        data.nodes.forEach((nodeB) => {
          if (nodeA.id === nodeB.id) return;
          const posA = positions.get(nodeA.id)!;
          const posB = positions.get(nodeB.id)!;
          const dx = posA.x - posB.x;
          const dy = posA.y - posB.y;
          const dist = Math.sqrt(dx * dx + dy * dy) + 1;
          const force = 500 / (dist * dist);
          posA.x += (dx / dist) * force;
          posA.y += (dy / dist) * force;
        });
      });

      // Attraction along edges
      data.edges.forEach((edge) => {
        const posA = positions.get(edge.source);
        const posB = positions.get(edge.target);
        if (!posA || !posB) return;
        const dx = posB.x - posA.x;
        const dy = posB.y - posA.y;
        const dist = Math.sqrt(dx * dx + dy * dy) + 1;
        const force = dist * 0.01;
        posA.x += (dx / dist) * force;
        posA.y += (dy / dist) * force;
        posB.x -= (dx / dist) * force;
        posB.y -= (dy / dist) * force;
      });

      // Keep nodes in bounds
      data.nodes.forEach((node) => {
        const pos = positions.get(node.id)!;
        pos.x = Math.max(30, Math.min(width - 30, pos.x));
        pos.y = Math.max(30, Math.min(height - 30, pos.y));
      });
    }

    setNodePositions(positions);
  }, [data, width, height]);

  // Draw
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !data || nodePositions.size === 0) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Clear
    ctx.fillStyle = '#0a0a0f';
    ctx.fillRect(0, 0, width, height);

    // Apply zoom and pan transform
    ctx.save();
    ctx.translate(width / 2 + pan.x, height / 2 + pan.y);
    ctx.scale(zoom, zoom);
    ctx.translate(-width / 2, -height / 2);

    // Draw edges
    data.edges.forEach((edge) => {
      const posA = nodePositions.get(edge.source);
      const posB = nodePositions.get(edge.target);
      if (!posA || !posB) return;

      ctx.beginPath();
      ctx.moveTo(posA.x, posA.y);
      ctx.lineTo(posB.x, posB.y);
      ctx.strokeStyle = edge.weight ? `rgba(100, 116, 139, ${Math.min(edge.weight * 0.3, 0.6)})` : 'rgba(100, 116, 139, 0.3)';
      ctx.lineWidth = 1 / zoom;
      ctx.stroke();
    });

    // Draw nodes
    data.nodes.forEach((node) => {
      const pos = nodePositions.get(node.id);
      if (!pos) return;

      const isHovered = hoveredNode === node.id;
      const color = node.color || NODE_COLORS[node.type] || '#6b7280';
      const radius = (isHovered ? 10 : 6) / zoom;

      if (isHovered) {
        ctx.shadowColor = color;
        ctx.shadowBlur = 15 / zoom;
      }

      ctx.beginPath();
      ctx.arc(pos.x, pos.y, radius, 0, 2 * Math.PI);
      ctx.fillStyle = color;
      ctx.fill();

      ctx.shadowBlur = 0;

      // Label for hovered
      if (isHovered && node.label) {
        ctx.fillStyle = '#ffffff';
        ctx.font = `${11 / zoom}px Inter, sans-serif`;
        ctx.textAlign = 'center';
        ctx.fillText(node.label, pos.x, pos.y - 14 / zoom);
      }
    });

    ctx.restore();
  }, [data, nodePositions, hoveredNode, width, height, zoom, pan]);

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!data) return;
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    // Adjust mouse coordinates for zoom and pan
    const rawMouseX = e.clientX - rect.left;
    const rawMouseY = e.clientY - rect.top;
    const mouseX = (rawMouseX - width / 2 - pan.x) / zoom + width / 2;
    const mouseY = (rawMouseY - height / 2 - pan.y) / zoom + height / 2;

    let closest: string | null = null;
    let closestDist = 15 / zoom;

    data.nodes.forEach((node) => {
      const pos = nodePositions.get(node.id);
      if (!pos) return;
      const dist = Math.sqrt((mouseX - pos.x) ** 2 + (mouseY - pos.y) ** 2);
      if (dist < closestDist) {
        closestDist = dist;
        closest = node.id;
      }
    });

    setHoveredNode(closest);
  };

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      onMouseMove={handleMouseMove}
      onMouseLeave={() => setHoveredNode(null)}
      className="rounded-lg cursor-crosshair"
    />
  );
}

// Main Visualization Page
export default function VizPage() {
  const [embeddings, setEmbeddings] = useState<EmbeddingsResponse | null>(null);
  const [graph, setGraph] = useState<GraphResponse | null>(null);
  const [collections, setCollections] = useState<CollectionInfo[]>([]);
  const [mlStatus, setMLStatus] = useState<MLStatus | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [projection, setProjection] = useState<'tsne' | 'umap' | 'pca'>('tsne');
  const [dimensions, setDimensions] = useState<2 | 3>(2);
  const [graphDimensions, setGraphDimensions] = useState<2 | 3>(2);
  const [hoveredPoint, setHoveredPoint] = useState<{
    id: string;
    type: string;
    label: string | null;
    x: number;
    y: number;
  } | null>(null);
  const [activeTab, setActiveTab] = useState<'embeddings' | 'graph' | 'collections'>('embeddings');
  const [isTraining, setIsTraining] = useState(false);
  
  // Zoom and pan state for embeddings
  const [embeddingZoom, setEmbeddingZoom] = useState(1);
  const [embeddingPan, setEmbeddingPan] = useState({ x: 0, y: 0 });
  const [isEmbeddingFullscreen, setIsEmbeddingFullscreen] = useState(false);
  
  // Zoom and pan state for graph
  const [graphZoom, setGraphZoom] = useState(1);
  const [graphPan, setGraphPan] = useState({ x: 0, y: 0 });
  const [isGraphFullscreen, setIsGraphFullscreen] = useState(false);
  
  // Refs for fullscreen
  const embeddingContainerRef = useRef<HTMLDivElement>(null);
  const graphContainerRef = useRef<HTMLDivElement>(null);
  
  // Panning state
  const [isPanning, setIsPanning] = useState(false);
  const [panStart, setPanStart] = useState({ x: 0, y: 0 });
  
  // Window dimensions for fullscreen
  const [windowSize, setWindowSize] = useState({ width: window.innerWidth, height: window.innerHeight });
  
  // Zoom handlers for embeddings
  const handleEmbeddingZoomIn = () => setEmbeddingZoom(z => Math.min(z * 1.2, 5));
  const handleEmbeddingZoomOut = () => setEmbeddingZoom(z => Math.max(z / 1.2, 0.2));
  const handleEmbeddingReset = () => { setEmbeddingZoom(1); setEmbeddingPan({ x: 0, y: 0 }); };
  
  // Zoom handlers for graph
  const handleGraphZoomIn = () => setGraphZoom(z => Math.min(z * 1.2, 5));
  const handleGraphZoomOut = () => setGraphZoom(z => Math.max(z / 1.2, 0.2));
  const handleGraphReset = () => { setGraphZoom(1); setGraphPan({ x: 0, y: 0 }); };
  
  // Fullscreen handlers
  const toggleEmbeddingFullscreen = () => {
    if (!document.fullscreenElement && embeddingContainerRef.current) {
      embeddingContainerRef.current.requestFullscreen();
      setIsEmbeddingFullscreen(true);
      // Update dimensions after fullscreen transition
      setTimeout(() => setWindowSize({ width: window.innerWidth, height: window.innerHeight }), 100);
    } else if (document.fullscreenElement) {
      document.exitFullscreen();
      setIsEmbeddingFullscreen(false);
    }
  };
  
  const toggleGraphFullscreen = () => {
    if (!document.fullscreenElement && graphContainerRef.current) {
      graphContainerRef.current.requestFullscreen();
      setIsGraphFullscreen(true);
      // Update dimensions after fullscreen transition
      setTimeout(() => setWindowSize({ width: window.innerWidth, height: window.innerHeight }), 100);
    } else if (document.fullscreenElement) {
      document.exitFullscreen();
      setIsGraphFullscreen(false);
    }
  };
  
  // Handle fullscreen change events and window resize
  useEffect(() => {
    const updateWindowSize = () => {
      setWindowSize({ width: window.innerWidth, height: window.innerHeight });
    };
    
    const handleFullscreenChange = () => {
      if (!document.fullscreenElement) {
        setIsEmbeddingFullscreen(false);
        setIsGraphFullscreen(false);
      }
      // Update dimensions after a small delay to ensure fullscreen transition is complete
      setTimeout(updateWindowSize, 50);
    };
    
    window.addEventListener('resize', updateWindowSize);
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => {
      window.removeEventListener('resize', updateWindowSize);
      document.removeEventListener('fullscreenchange', handleFullscreenChange);
    };
  }, []);
  
  // Handle wheel zoom for embeddings
  const handleEmbeddingWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? 0.9 : 1.1;
    setEmbeddingZoom(z => Math.min(Math.max(z * delta, 0.2), 5));
  };
  
  // Handle wheel zoom for graph
  const handleGraphWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? 0.9 : 1.1;
    setGraphZoom(z => Math.min(Math.max(z * delta, 0.2), 5));
  };
  
  // Track which canvas is being panned
  const [panningType, setPanningType] = useState<'embedding' | 'graph' | null>(null);
  
  // Handle pan mouse events - works with left mouse button drag
  const handlePanStart = (e: React.MouseEvent, type: 'embedding' | 'graph') => {
    if (e.button === 0) { // Left click
      e.preventDefault();
      setIsPanning(true);
      setPanningType(type);
      setPanStart({ x: e.clientX, y: e.clientY });
    }
  };
  
  const handlePanMove = (e: React.MouseEvent) => {
    if (!isPanning || !panningType) return;
    const dx = e.clientX - panStart.x;
    const dy = e.clientY - panStart.y;
    setPanStart({ x: e.clientX, y: e.clientY });
    if (panningType === 'embedding') {
      setEmbeddingPan(p => ({ x: p.x + dx, y: p.y + dy }));
    } else {
      setGraphPan(p => ({ x: p.x + dx, y: p.y + dy }));
    }
  };
  
  const handlePanEnd = () => {
    setIsPanning(false);
    setPanningType(null);
  };
  
  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
      
      if (activeTab === 'embeddings') {
        if (e.key === '+' || e.key === '=') handleEmbeddingZoomIn();
        else if (e.key === '-') handleEmbeddingZoomOut();
        else if (e.key === 'r' || e.key === 'R') handleEmbeddingReset();
        else if (e.key === 'f' || e.key === 'F') toggleEmbeddingFullscreen();
      } else if (activeTab === 'graph') {
        if (e.key === '+' || e.key === '=') handleGraphZoomIn();
        else if (e.key === '-') handleGraphZoomOut();
        else if (e.key === 'r' || e.key === 'R') handleGraphReset();
        else if (e.key === 'f' || e.key === 'F') toggleGraphFullscreen();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [activeTab]);

  // Load initial data
  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [statusRes, collectionsRes] = await Promise.all([
        fetchMLStatus().catch(() => null),
        fetchCollections().catch(() => ({ collections: [] })),
      ]);
      
      setMLStatus(statusRes);
      setCollections(collectionsRes.collections);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const loadEmbeddings = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchEmbeddings(projection, dimensions, true, true, 500);
      setEmbeddings(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load embeddings');
    } finally {
      setLoading(false);
    }
  };

  const loadGraph = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchGraph(200, 500, true);
      setGraph(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load graph');
    } finally {
      setLoading(false);
    }
  };

  const handleTrain = async (model: 'lightgcn' | 'hgt') => {
    setIsTraining(true);
    setError(null);
    try {
      if (model === 'lightgcn') {
        await trainLightGCN(30, 50);
      } else {
        await trainHGT(30, 50);
      }
      // Reload data after training
      await loadData();
      if (activeTab === 'embeddings') await loadEmbeddings();
      if (activeTab === 'graph') await loadGraph();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Training failed');
    } finally {
      setIsTraining(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 text-gray-800 p-6">
      {/* Header */}
      <div className="max-w-7xl mx-auto mb-8">
        <h1 className="text-3xl font-semibold text-gray-800 mb-2">
          Graph & Vector DB Visualization
        </h1>
        <p className="text-gray-500">
          Explore embeddings and graph relationships in the recommendation system
        </p>
      </div>

      {/* Status Bar */}
      {mlStatus && (
        <div className="max-w-7xl mx-auto mb-6 grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Status</div>
            <div className={`text-lg font-semibold ${mlStatus.model_loaded ? 'text-emerald-600' : 'text-amber-600'}`}>
              {mlStatus.model_loaded ? 'Ready' : 'Not Trained'}
            </div>
          </div>
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Users</div>
            <div className="text-lg font-semibold text-blue-600">{mlStatus.num_users.toLocaleString()}</div>
          </div>
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Games</div>
            <div className="text-lg font-semibold text-emerald-600">{mlStatus.num_games.toLocaleString()}</div>
          </div>
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Edges</div>
            <div className="text-lg font-semibold text-violet-600">{mlStatus.num_edges.toLocaleString()}</div>
          </div>
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Device</div>
            <div className="text-lg font-semibold text-gray-700">{mlStatus.device}</div>
          </div>
          <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
            <div className="text-sm text-gray-500">Collections</div>
            <div className="text-lg font-semibold text-teal-600">{collections.length}</div>
          </div>
        </div>
      )}

      {/* Training Buttons */}
      <div className="max-w-7xl mx-auto mb-6 flex gap-3">
        <button
          onClick={() => handleTrain('lightgcn')}
          disabled={isTraining}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white disabled:bg-gray-400 disabled:cursor-not-allowed rounded-lg transition-colors text-sm font-medium"
        >
          {isTraining ? 'Training...' : 'Train LightGCN'}
        </button>
        <button
          onClick={() => handleTrain('hgt')}
          disabled={isTraining}
          className="px-4 py-2 bg-violet-600 hover:bg-violet-700 text-white disabled:bg-gray-400 disabled:cursor-not-allowed rounded-lg transition-colors text-sm font-medium"
        >
          {isTraining ? 'Training...' : 'Train HGT'}
        </button>
        <button
          onClick={loadData}
          disabled={loading}
          className="px-4 py-2 bg-white hover:bg-gray-100 text-gray-700 border border-gray-300 rounded-lg transition-colors text-sm font-medium"
        >
          Refresh Status
        </button>
      </div>

      {/* Error Display */}
      {error && (
        <div className="max-w-7xl mx-auto mb-6 bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">
          {error}
        </div>
      )}

      {/* Tabs */}
      <div className="max-w-7xl mx-auto mb-6">
        <div className="flex gap-1 border-b border-gray-200">
          {(['embeddings', 'graph', 'collections'] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => {
                setActiveTab(tab);
                if (tab === 'embeddings' && !embeddings) loadEmbeddings();
                if (tab === 'graph' && !graph) loadGraph();
              }}
              className={`px-4 py-2 capitalize transition-colors text-sm font-medium ${
                activeTab === tab
                  ? 'border-b-2 border-blue-600 text-blue-600'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto">
        {/* Embeddings Tab */}
        {activeTab === 'embeddings' && (
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
            <div 
              ref={embeddingContainerRef}
              className={`lg:col-span-3 bg-white rounded-xl border border-gray-200 shadow-sm ${isEmbeddingFullscreen ? 'fixed inset-0 z-50 rounded-none bg-slate-900 border-none p-0' : 'p-4'}`}
            >
              {!isEmbeddingFullscreen && (
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-lg font-semibold text-gray-800">
                    Embedding Space ({dimensions}D Projection)
                  </h2>
                  <div className="flex gap-2 items-center">
                    {/* 2D/3D Toggle */}
                    <div className="flex bg-gray-100 rounded p-0.5">
                      <button
                        onClick={() => setDimensions(2)}
                        className={`px-3 py-1 text-sm rounded transition-colors ${
                          dimensions === 2 
                            ? 'bg-white text-gray-800 shadow-sm' 
                            : 'text-gray-500 hover:text-gray-700'
                        }`}
                      >
                        2D
                      </button>
                      <button
                        onClick={() => setDimensions(3)}
                        className={`px-3 py-1 text-sm rounded transition-colors ${
                          dimensions === 3 
                            ? 'bg-white text-gray-800 shadow-sm' 
                            : 'text-gray-500 hover:text-gray-700'
                        }`}
                      >
                        3D
                      </button>
                    </div>
                    <select
                      value={projection}
                      onChange={(e) => setProjection(e.target.value as 'tsne' | 'umap' | 'pca')}
                      className="bg-gray-100 border border-gray-200 rounded px-3 py-1 text-sm text-gray-700"
                    >
                      <option value="tsne">t-SNE</option>
                      <option value="umap">UMAP</option>
                      <option value="pca">PCA</option>
                    </select>
                    <button
                      onClick={loadEmbeddings}
                      disabled={loading}
                      className="bg-emerald-600 hover:bg-emerald-700 text-white px-3 py-1 rounded text-sm font-medium"
                    >
                      {loading ? 'Loading...' : 'Load'}
                    </button>
                  </div>
                </div>
              )}
              <div className="relative">
                {dimensions === 2 ? (
                  <div 
                    className="cursor-grab active:cursor-grabbing"
                    onWheel={handleEmbeddingWheel}
                    onMouseDown={(e) => handlePanStart(e, 'embedding')}
                    onMouseMove={handlePanMove}
                    onMouseUp={handlePanEnd}
                    onMouseLeave={handlePanEnd}
                  >
                    <EmbeddingCanvas 
                      data={embeddings} 
                      width={isEmbeddingFullscreen ? windowSize.width : 800} 
                      height={isEmbeddingFullscreen ? windowSize.height : 500}
                      zoom={embeddingZoom}
                      pan={embeddingPan}
                      onHover={setHoveredPoint}
                    />
                  </div>
                ) : (
                  <Embedding3DCanvas 
                    data={embeddings}
                    width={isEmbeddingFullscreen ? windowSize.width : 800}
                    height={isEmbeddingFullscreen ? windowSize.height : 500}
                  />
                )}
                {dimensions === 2 ? (
                  <CanvasControls
                    zoom={embeddingZoom}
                    onZoomIn={handleEmbeddingZoomIn}
                    onZoomOut={handleEmbeddingZoomOut}
                    onReset={handleEmbeddingReset}
                    onFullscreen={toggleEmbeddingFullscreen}
                    isFullscreen={isEmbeddingFullscreen}
                  />
                ) : (
                  /* Fullscreen button for 3D mode */
                  <div className="absolute top-2 right-2 bg-white/90 rounded-lg p-1 backdrop-blur-sm border border-gray-200 shadow-sm">
                    <button
                      onClick={toggleEmbeddingFullscreen}
                      className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
                      title={isEmbeddingFullscreen ? "Exit Fullscreen (Esc)" : "Fullscreen (F)"}
                    >
                      {isEmbeddingFullscreen ? <ExitFullscreenIcon /> : <FullscreenIcon />}
                    </button>
                  </div>
                )}
                {/* Fullscreen legend overlay */}
                {isEmbeddingFullscreen && (
                  <div className="absolute bottom-4 left-4 flex gap-4 text-sm bg-black/50 rounded px-3 py-2 backdrop-blur-sm">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-blue-500" />
                      <span className="text-white">Users</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-emerald-500" />
                      <span className="text-white">Games</span>
                    </div>
                  </div>
                )}
              </div>
              {/* Legend - only show when not fullscreen */}
              {!isEmbeddingFullscreen && (
                <div className="mt-4 flex flex-wrap gap-4 text-sm">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full bg-blue-500" />
                    <span className="text-gray-600">Users</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full bg-emerald-500" />
                    <span className="text-gray-600">Games</span>
                  </div>
                  <div className="text-gray-400 ml-auto text-xs">
                    Scroll to zoom • Drag to pan • R to reset • F for fullscreen
                  </div>
                </div>
              )}
            </div>

            {/* Info Panel */}
            <div className="space-y-4">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
                <h3 className="font-semibold mb-3 text-gray-800">Embedding Stats</h3>
                {embeddings ? (
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-500">Total Points</span>
                      <span className="text-gray-700">{embeddings.stats.total_points}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Users</span>
                      <span className="text-gray-700">{embeddings.stats.num_users}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Games</span>
                      <span className="text-gray-700">{embeddings.stats.num_games}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Embedding Dim</span>
                      <span className="text-gray-700">{embeddings.stats.embedding_dim}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Projection</span>
                      <span className="text-gray-700 uppercase">{embeddings.projection_method}</span>
                    </div>
                  </div>
                ) : (
                  <p className="text-gray-400 text-sm">Click Load to view embeddings</p>
                )}
              </div>

              {hoveredPoint && (
                <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
                  <h3 className="font-semibold mb-3 text-gray-800">Hovered Point</h3>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-500">ID</span>
                      <span className="truncate max-w-[150px] text-gray-700">{hoveredPoint.id}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Type</span>
                      <span className="text-gray-700">{hoveredPoint.type}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Label</span>
                      <span className="text-gray-700">{hoveredPoint.label || '-'}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">X</span>
                      <span className="text-gray-700">{hoveredPoint.x.toFixed(3)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Y</span>
                      <span className="text-gray-700">{hoveredPoint.y.toFixed(3)}</span>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Graph Tab */}
        {activeTab === 'graph' && (
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
            <div 
              ref={graphContainerRef}
              className={`lg:col-span-3 bg-white rounded-xl border border-gray-200 shadow-sm ${isGraphFullscreen ? 'fixed inset-0 z-50 rounded-none bg-slate-900 border-none p-0' : 'p-4'}`}
            >
              {!isGraphFullscreen && (
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-lg font-semibold text-gray-800">
                    Graph Structure ({graphDimensions}D)
                  </h2>
                  <div className="flex gap-2 items-center">
                    {/* 2D/3D Toggle */}
                    <div className="flex bg-gray-100 rounded p-0.5">
                      <button
                        onClick={() => setGraphDimensions(2)}
                        className={`px-3 py-1 text-sm rounded transition-colors ${
                          graphDimensions === 2 
                            ? 'bg-white text-gray-800 shadow-sm' 
                            : 'text-gray-500 hover:text-gray-700'
                        }`}
                      >
                        2D
                      </button>
                      <button
                        onClick={() => setGraphDimensions(3)}
                        className={`px-3 py-1 text-sm rounded transition-colors ${
                          graphDimensions === 3 
                            ? 'bg-white text-gray-800 shadow-sm' 
                            : 'text-gray-500 hover:text-gray-700'
                        }`}
                      >
                        3D
                      </button>
                    </div>
                    <button
                      onClick={loadGraph}
                      disabled={loading}
                      className="bg-violet-600 hover:bg-violet-700 text-white px-3 py-1 rounded text-sm font-medium"
                    >
                      {loading ? 'Loading...' : 'Load Graph'}
                    </button>
                  </div>
                </div>
              )}
              <div className="relative">
                {graphDimensions === 2 ? (
                  <div 
                    className="cursor-grab active:cursor-grabbing"
                    onWheel={handleGraphWheel}
                    onMouseDown={(e) => handlePanStart(e, 'graph')}
                    onMouseMove={handlePanMove}
                    onMouseUp={handlePanEnd}
                    onMouseLeave={handlePanEnd}
                  >
                    <GraphCanvas 
                      data={graph} 
                      width={isGraphFullscreen ? windowSize.width : 800} 
                      height={isGraphFullscreen ? windowSize.height : 500}
                      zoom={graphZoom}
                      pan={graphPan}
                    />
                  </div>
                ) : (
                  <Graph3DCanvas 
                    data={graph}
                    width={isGraphFullscreen ? windowSize.width : 800}
                    height={isGraphFullscreen ? windowSize.height : 500}
                  />
                )}
                {graphDimensions === 2 ? (
                  <CanvasControls
                    zoom={graphZoom}
                    onZoomIn={handleGraphZoomIn}
                    onZoomOut={handleGraphZoomOut}
                    onReset={handleGraphReset}
                    onFullscreen={toggleGraphFullscreen}
                    isFullscreen={isGraphFullscreen}
                  />
                ) : (
                  /* Fullscreen button for 3D mode */
                  <div className="absolute top-2 right-2 bg-white/90 rounded-lg p-1 backdrop-blur-sm border border-gray-200 shadow-sm">
                    <button
                      onClick={toggleGraphFullscreen}
                      className="p-2 hover:bg-gray-100 rounded transition-colors text-gray-600 hover:text-gray-800"
                      title={isGraphFullscreen ? "Exit Fullscreen (Esc)" : "Fullscreen (F)"}
                    >
                      {isGraphFullscreen ? <ExitFullscreenIcon /> : <FullscreenIcon />}
                    </button>
                  </div>
                )}
                {/* Fullscreen legend overlay for 2D */}
                {isGraphFullscreen && graphDimensions === 2 && graph && (
                  <div className="absolute bottom-4 left-4 flex gap-4 text-sm bg-black/50 rounded px-3 py-2 backdrop-blur-sm">
                    {graph.stats.node_types?.map((type) => (
                      <div key={type} className="flex items-center gap-2">
                        <div 
                          className="w-3 h-3 rounded-full" 
                          style={{ backgroundColor: NODE_COLORS[type] || '#6b7280' }}
                        />
                        <span className="text-white capitalize">{type}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              {/* Legend - only show when not fullscreen */}
              {!isGraphFullscreen && (
                <div className="mt-4 flex flex-wrap gap-4 text-sm">
                  {graph && graph.stats.node_types?.map((type) => (
                    <div key={type} className="flex items-center gap-2">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: NODE_COLORS[type] || '#6b7280' }}
                      />
                      <span className="text-gray-600 capitalize">{type}</span>
                    </div>
                  ))}
                  <div className="text-gray-400 ml-auto text-xs">
                    Scroll to zoom • Drag to pan • R to reset • F for fullscreen
                  </div>
                </div>
              )}
            </div>

            {/* Info Panel */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
              <h3 className="font-semibold mb-3 text-gray-800">Graph Stats</h3>
              {graph ? (
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-500">Nodes</span>
                    <span className="text-gray-700">{graph.stats.total_nodes}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Edges</span>
                    <span className="text-gray-700">{graph.stats.total_edges}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Type</span>
                    <span className="text-gray-700 capitalize">{graph.stats.graph_type}</span>
                  </div>
                  <div className="pt-2 border-t border-gray-100">
                    <div className="text-gray-500 mb-1">Node Types</div>
                    <div className="flex flex-wrap gap-1">
                      {graph.stats.node_types?.map((t) => (
                        <span key={t} className="px-2 py-0.5 bg-gray-100 rounded text-xs capitalize text-gray-600">
                          {t}
                        </span>
                      ))}
                    </div>
                  </div>
                  <div className="pt-2 border-t border-gray-100">
                    <div className="text-gray-500 mb-1">Edge Types</div>
                    <div className="flex flex-wrap gap-1">
                      {graph.stats.edge_types?.map((t) => (
                        <span key={t} className="px-2 py-0.5 bg-gray-100 rounded text-xs text-gray-600">
                          {t}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <p className="text-gray-400 text-sm">Click Load Graph to view structure</p>
              )}
            </div>
          </div>
        )}

        {/* Collections Tab */}
        {activeTab === 'collections' && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-800">Qdrant Vector Collections</h2>
            {collections.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {collections.map((coll) => (
                  <div
                    key={coll.name}
                    className="bg-white rounded-xl border border-gray-200 shadow-sm p-4 hover:border-gray-300 transition-colors"
                  >
                    <h3 className="font-semibold text-gray-800 mb-3">{coll.name}</h3>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-500">Vectors</span>
                        <span className="text-gray-700">{coll.vectors_count?.toLocaleString() || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Points</span>
                        <span className="text-gray-700">{coll.points_count?.toLocaleString() || 0}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Dimensions</span>
                        <span className="text-gray-700">{coll.vector_size || '-'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Status</span>
                        <span className={coll.status === 'green' ? 'text-green-600' : 'text-amber-600'}>
                          {coll.status}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-8 text-center">
                <p className="text-gray-400">No vector collections found. Train a model first.</p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Footer info */}
      <div className="max-w-7xl mx-auto mt-12 pt-8 border-t border-gray-200">
        <div className="text-center text-gray-400 text-sm">
          <p>Graph Neural Network Visualization</p>
          <p className="mt-1">LightGCN • TGN • HGT | PyTorch Geometric + Qdrant</p>
        </div>
      </div>
    </div>
  );
}

