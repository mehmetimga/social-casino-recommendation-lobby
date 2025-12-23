export type EventType = 'impression' | 'click' | 'game_time';

export interface UserEvent {
  userId: string;
  gameSlug: string;
  eventType: EventType;
  durationSeconds?: number;
  metadata?: Record<string, unknown>;
}

export interface RatingInput {
  userId: string;
  gameSlug: string;
  rating: number;
}

export interface RecommendationParams {
  userId: string;
  placement?: string;
  limit?: number;
  vipLevel?: 'bronze' | 'silver' | 'gold' | 'platinum';
}

export interface RecommendationResponse {
  recommendations: string[];
}
