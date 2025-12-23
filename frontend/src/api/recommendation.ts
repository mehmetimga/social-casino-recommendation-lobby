import { apiClient } from './client';
import { UserEvent, RatingInput, RecommendationParams, RecommendationResponse } from '../types/recommendation';

export interface ReviewInput {
  userId: string;
  gameSlug: string;
  rating: number;
  reviewText?: string;
}

export interface Review {
  id: string;
  userId: string;
  gameSlug: string;
  rating: number;
  reviewText?: string;
  createdAt: string;
  updatedAt: string;
}

export const recommendationApi = {
  async trackEvent(event: UserEvent): Promise<void> {
    await apiClient.recommendation.post('/v1/events', event);
  },

  async submitRating(rating: RatingInput): Promise<void> {
    await apiClient.recommendation.post('/v1/feedback/rating', rating);
  },

  async submitReview(review: ReviewInput): Promise<Review> {
    const response = await apiClient.recommendation.post<Review>('/v1/feedback/review', review);
    return response;
  },

  async getGameReviews(gameSlug: string): Promise<Review[]> {
    const response = await apiClient.recommendation.get<Review[]>(
      `/v1/feedback/reviews?gameSlug=${encodeURIComponent(gameSlug)}`
    );
    return response;
  },

  async getUserReview(userId: string, gameSlug: string): Promise<Review | null> {
    try {
      const response = await apiClient.recommendation.get<Review>(
        `/v1/feedback/review?userId=${encodeURIComponent(userId)}&gameSlug=${encodeURIComponent(gameSlug)}`
      );
      return response;
    } catch (error: any) {
      if (error.response?.status === 404) {
        return null;
      }
      throw error;
    }
  },

  async getRecommendations(params: RecommendationParams): Promise<string[]> {
    const queryParams = new URLSearchParams();
    queryParams.append('userId', params.userId);
    if (params.placement) {
      queryParams.append('placement', params.placement);
    }
    if (params.limit) {
      queryParams.append('limit', params.limit.toString());
    }
    if (params.vipLevel) {
      queryParams.append('vipLevel', params.vipLevel);
    }

    const response = await apiClient.recommendation.get<RecommendationResponse>(
      `/v1/recommendations?${queryParams.toString()}`
    );
    return response.recommendations;
  },
};
