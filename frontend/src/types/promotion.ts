import { Media, Game } from './game';

export type PromotionStatus = 'draft' | 'live';
export type PromotionPlacement = 'hero' | 'banner' | 'featured';

export interface Promotion {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  description?: string;
  image: Media;
  backgroundImage?: Media;
  showOverlay?: boolean;
  ctaText: string;
  ctaLink: {
    type: 'game' | 'url' | 'category';
    game?: Game | string;
    url?: string;
    category?: string;
  };
  schedule?: {
    startDate?: string;
    endDate?: string;
  };
  countdown?: {
    enabled: boolean;
    endTime?: string;
    label?: string;
  };
  status: PromotionStatus;
  placement: PromotionPlacement;
  priority: number;
  createdAt: string;
  updatedAt: string;
}
