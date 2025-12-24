import { apiClient } from './client';
import { Game, GameFilters, GameType } from '../types/game';
import { Promotion } from '../types/promotion';
import { LobbyLayout } from '../types/lobby';
import { GameReview, ReviewInput } from '../types/review';

interface PaginatedResponse<T> {
  docs: T[];
  totalDocs: number;
  limit: number;
  page: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export const cmsApi = {
  // Games
  async getGames(filters?: GameFilters): Promise<PaginatedResponse<Game>> {
    const params = new URLSearchParams();

    if (filters?.type) {
      params.append('where[type][equals]', filters.type);
    }
    if (filters?.limit) {
      params.append('limit', filters.limit.toString());
    }
    if (filters?.page) {
      params.append('page', filters.page.toString());
    }

    // Always filter enabled games
    params.append('where[status][equals]', 'enabled');

    const query = params.toString() ? `?${params.toString()}` : '';
    return apiClient.cms.get<PaginatedResponse<Game>>(`/games${query}`);
  },

  async getGame(slug: string): Promise<Game> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[slug][equals]=${slug}&limit=1`
    );
    if (response.docs.length === 0) {
      throw new Error('Game not found');
    }
    return response.docs[0];
  },

  async getGamesByType(type: GameType, limit = 12): Promise<Game[]> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[type][equals]=${type}&where[status][equals]=enabled&limit=${limit}&sort=-popularityScore`
    );
    return response.docs;
  },

  async getGamesByBadge(badge: string, limit = 12): Promise<Game[]> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[badges][contains]=${badge}&where[status][equals]=enabled&limit=${limit}&sort=-popularityScore`
    );
    return response.docs;
  },

  async getPopularGames(limit = 12): Promise<Game[]> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[status][equals]=enabled&limit=${limit}&sort=-popularityScore`
    );
    return response.docs;
  },

  async getNewGames(limit = 12): Promise<Game[]> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[badges][contains]=new&where[status][equals]=enabled&limit=${limit}&sort=-createdAt`
    );
    return response.docs;
  },

  async getJackpotGames(limit = 12): Promise<Game[]> {
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?where[jackpotAmount][greater_than]=0&where[status][equals]=enabled&limit=${limit}&sort=-jackpotAmount`
    );
    return response.docs;
  },

  async getGamesBySlugs(slugs: string[]): Promise<Game[]> {
    if (slugs.length === 0) return [];
    const slugQuery = slugs.map(s => `where[slug][in]=${s}`).join('&');
    const response = await apiClient.cms.get<PaginatedResponse<Game>>(
      `/games?${slugQuery}&where[status][equals]=enabled&limit=${slugs.length}`
    );
    // Sort by original order
    return slugs
      .map(slug => response.docs.find(g => g.slug === slug))
      .filter((g): g is Game => g !== undefined);
  },

  async searchGames(query: string, type?: GameType, limit = 20): Promise<Game[]> {
    let url = `/games?where[status][equals]=enabled&limit=${limit}&sort=-popularityScore`;

    // Filter by type if specified
    if (type) {
      url += `&where[type][equals]=${type}`;
    }

    // Server-side search by title using PayloadCMS 'like' operator (case-insensitive partial match)
    if (query) {
      url += `&where[title][like]=${encodeURIComponent(query)}`;
    }

    const response = await apiClient.cms.get<PaginatedResponse<Game>>(url);
    return response.docs;
  },

  // Promotions
  async getPromotions(placement?: string): Promise<Promotion[]> {
    let query = '/promotions?where[status][equals]=live&sort=-priority';
    if (placement) {
      query += `&where[placement][equals]=${placement}`;
    }
    const response = await apiClient.cms.get<PaginatedResponse<Promotion>>(query);
    return response.docs;
  },

  async getPromotion(slug: string): Promise<Promotion> {
    const response = await apiClient.cms.get<PaginatedResponse<Promotion>>(
      `/promotions?where[slug][equals]=${slug}&limit=1`
    );
    if (response.docs.length === 0) {
      throw new Error('Promotion not found');
    }
    return response.docs[0];
  },

  // Lobby Layouts
  async getLobbyLayout(slug = 'web-default'): Promise<LobbyLayout> {
    const response = await apiClient.cms.get<PaginatedResponse<LobbyLayout>>(
      `/lobby-layouts?where[slug][equals]=${slug}&limit=1&depth=2`
    );
    if (response.docs.length === 0) {
      throw new Error('Lobby layout not found');
    }
    return response.docs[0];
  },

  async getDefaultLobbyLayout(platform = 'web'): Promise<LobbyLayout> {
    const response = await apiClient.cms.get<PaginatedResponse<LobbyLayout>>(
      `/lobby-layouts?where[platform][equals]=${platform}&where[isDefault][equals]=true&limit=1&depth=2`
    );
    if (response.docs.length === 0) {
      // Fallback to any layout for the platform
      const fallback = await apiClient.cms.get<PaginatedResponse<LobbyLayout>>(
        `/lobby-layouts?where[platform][equals]=${platform}&limit=1&depth=2`
      );
      if (fallback.docs.length === 0) {
        throw new Error('No lobby layout found');
      }
      return fallback.docs[0];
    }
    return response.docs[0];
  },

  // Reviews
  async getGameReviews(gameId: string): Promise<GameReview[]> {
    const response = await apiClient.cms.get<PaginatedResponse<GameReview>>(
      `/game-reviews?where[game][equals]=${gameId}&where[status][equals]=published&sort=-createdAt`
    );
    return response.docs;
  },

  async submitReview(review: ReviewInput): Promise<GameReview> {
    return apiClient.cms.post<GameReview>('/game-reviews', review);
  },

  async getUserReview(userId: string, gameId: string): Promise<GameReview | null> {
    const response = await apiClient.cms.get<PaginatedResponse<GameReview>>(
      `/game-reviews?where[userId][equals]=${userId}&where[game][equals]=${gameId}&limit=1`
    );
    return response.docs[0] || null;
  },
};
