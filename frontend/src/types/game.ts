export interface Media {
  id: string;
  alt: string;
  url: string;
  filename: string;
  mimeType: string;
  filesize: number;
  width?: number;
  height?: number;
  sizes?: {
    thumbnail?: { url: string; width: number; height: number };
    card?: { url: string; width: number; height: number };
    hero?: { url: string; width: number; height: number };
  };
}

export type GameType = 'slot' | 'table' | 'live' | 'instant';
export type GameStatus = 'enabled' | 'disabled';
export type BadgeType = 'new' | 'exclusive' | 'hot' | 'jackpot' | 'featured';
export type Volatility = 'low' | 'medium' | 'high';
export type VipLevel = 'bronze' | 'silver' | 'gold' | 'platinum';

export interface Game {
  id: string;
  slug: string;
  title: string;
  provider: string;
  type: GameType;
  tags?: { tag: string }[];
  thumbnail: Media;
  heroImage?: Media;
  gallery?: { image: Media }[];
  shortDescription?: string;
  fullDescription?: unknown; // Rich text
  popularityScore: number;
  jackpotAmount?: number;
  minBet: number;
  maxBet: number;
  rtp?: number;
  volatility?: Volatility;
  minVipLevel?: VipLevel;
  badges?: BadgeType[];
  status: GameStatus;
  createdAt: string;
  updatedAt: string;
}

export interface GameFilters {
  type?: GameType;
  tags?: string[];
  badges?: BadgeType[];
  minPopularity?: number;
  limit?: number;
  page?: number;
}
