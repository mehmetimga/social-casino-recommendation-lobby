import { apiClient } from './client';
import { UserEvent, RatingInput, RecommendationParams, RecommendationResponse } from '../types/recommendation';

export const recommendationApi = {
  async trackEvent(event: UserEvent): Promise<void> {
    await apiClient.recommendation.post('/v1/events', event);
  },

  async submitRating(rating: RatingInput): Promise<void> {
    await apiClient.recommendation.post('/v1/feedback/rating', rating);
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

    const response = await apiClient.recommendation.get<RecommendationResponse>(
      `/v1/recommendations?${queryParams.toString()}`
    );
    return response.recommendations;
  },
};
