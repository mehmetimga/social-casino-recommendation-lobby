export type EventType = 'impression' | 'click' | 'play_start' | 'play_end';

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
}

export interface RecommendationResponse {
  recommendations: string[];
}
