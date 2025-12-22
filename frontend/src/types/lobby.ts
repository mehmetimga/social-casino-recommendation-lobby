import { Game } from './game';
import { Promotion } from './promotion';

export type Platform = 'web' | 'mobile';
export type CardSize = 'small' | 'medium' | 'large';
export type CarouselHeight = 'small' | 'medium' | 'large' | 'full';
export type BannerSize = 'small' | 'medium' | 'large';
export type FilterType = 'manual' | 'type' | 'tag' | 'popular' | 'new' | 'jackpot' | 'featured';
export type SuggestedMode = 'manual' | 'personalized';
export type DisplayStyle =
  | 'horizontal'
  | 'grid'
  | 'carousel-rows'
  | 'single-row'
  | 'featured-left'
  | 'featured-right'
  | 'featured-top';

export interface CarouselSectionBlock {
  blockType: 'carousel-section';
  title?: string;
  promotions?: (Promotion | string)[];
  autoPlay: boolean;
  autoPlayInterval: number;
  showDots: boolean;
  showArrows: boolean;
  height: CarouselHeight;
}

export interface SuggestedGamesSectionBlock {
  blockType: 'suggested-games-section';
  title: string;
  subtitle?: string;
  mode: SuggestedMode;
  manualGames?: (Game | string)[];
  placement: string;
  limit: number;
  fallbackToPopular: boolean;
  showScrollButtons: boolean;
  cardSize: CardSize;
}

export interface GameGridSectionBlock {
  blockType: 'game-grid-section';
  title: string;
  subtitle?: string;
  filterType: FilterType;
  manualGames?: (Game | string)[];
  gameType?: string;
  tag?: string;
  displayStyle: DisplayStyle;
  rows?: number;
  featuredGame?: Game | string;
  limit: number;
  columns: string;
  showMore: boolean;
  moreLink?: string;
  cardSize: CardSize;
  showJackpot: boolean;
  showProvider: boolean;
}

export interface BannerSectionBlock {
  blockType: 'banner-section';
  promotion?: Promotion | string;
  size: BannerSize;
  alignment: 'left' | 'center' | 'right';
  showCountdown: boolean;
  rounded: boolean;
  showOverlay: boolean;
  marginTop: number;
  marginBottom: number;
}

export type LobbySectionBlock =
  | CarouselSectionBlock
  | SuggestedGamesSectionBlock
  | GameGridSectionBlock
  | BannerSectionBlock;

export interface LobbyLayout {
  id: string;
  slug: string;
  name: string;
  platform: Platform;
  isDefault: boolean;
  sections: LobbySectionBlock[];
  createdAt: string;
  updatedAt: string;
}
