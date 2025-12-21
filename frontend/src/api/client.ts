const CMS_URL = import.meta.env.VITE_CMS_URL || 'http://localhost:3001';
const RECOMMENDATION_URL = import.meta.env.VITE_RECOMMENDATION_URL || 'http://localhost:8081';
const CHAT_URL = import.meta.env.VITE_CHAT_URL || 'http://localhost:8082';

export const apiClient = {
  cms: {
    baseUrl: CMS_URL,
    async get<T>(endpoint: string): Promise<T> {
      const response = await fetch(`${CMS_URL}/api${endpoint}`);
      if (!response.ok) {
        throw new Error(`CMS API error: ${response.statusText}`);
      }
      return response.json();
    },
    async post<T>(endpoint: string, data: unknown): Promise<T> {
      const response = await fetch(`${CMS_URL}/api${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) {
        throw new Error(`CMS API error: ${response.statusText}`);
      }
      return response.json();
    },
  },
  recommendation: {
    baseUrl: RECOMMENDATION_URL,
    async get<T>(endpoint: string): Promise<T> {
      const response = await fetch(`${RECOMMENDATION_URL}${endpoint}`);
      if (!response.ok) {
        throw new Error(`Recommendation API error: ${response.statusText}`);
      }
      return response.json();
    },
    async post<T>(endpoint: string, data: unknown): Promise<T> {
      const response = await fetch(`${RECOMMENDATION_URL}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) {
        throw new Error(`Recommendation API error: ${response.statusText}`);
      }
      return response.json();
    },
  },
  chat: {
    baseUrl: CHAT_URL,
    async get<T>(endpoint: string): Promise<T> {
      const response = await fetch(`${CHAT_URL}${endpoint}`);
      if (!response.ok) {
        throw new Error(`Chat API error: ${response.statusText}`);
      }
      return response.json();
    },
    async post<T>(endpoint: string, data: unknown): Promise<T> {
      const response = await fetch(`${CHAT_URL}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) {
        throw new Error(`Chat API error: ${response.statusText}`);
      }
      return response.json();
    },
    async put<T>(endpoint: string, data: unknown): Promise<T> {
      const response = await fetch(`${CHAT_URL}${endpoint}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) {
        throw new Error(`Chat API error: ${response.statusText}`);
      }
      return response.json();
    },
  },
};

export function getMediaUrl(path: string | undefined): string {
  if (!path) return '';
  if (path.startsWith('http')) return path;
  return `${CMS_URL}${path}`;
}
