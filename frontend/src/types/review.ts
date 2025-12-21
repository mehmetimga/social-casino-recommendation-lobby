import { Game } from './game';

export type ReviewStatus = 'published' | 'hidden' | 'pending';

export interface GameReview {
  id: string;
  userId: string;
  game: Game | string;
  rating: number;
  reviewText?: string;
  status: ReviewStatus;
  createdAt: string;
  updatedAt: string;
}

export interface ReviewInput {
  userId: string;
  game: string;
  rating: number;
  reviewText?: string;
}
