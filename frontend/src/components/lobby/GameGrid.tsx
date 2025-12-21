import { useState } from 'react';
import { ChevronRight, ChevronLeft } from 'lucide-react';
import { Game } from '../../types/game';
import { cn } from '../../utils/cn';
import GameCard from './GameCard';

interface GameGridProps {
  title: string;
  subtitle?: string;
  games: Game[];
  columns?: number;
  showMore?: boolean;
  moreLink?: string;
  cardSize?: 'small' | 'medium' | 'large';
  showJackpot?: boolean;
  showProvider?: boolean;
  isHorizontal?: boolean;
  onPlay?: (game: Game) => void;
  isLoading?: boolean;
}

export default function GameGrid({
  title,
  subtitle,
  games,
  columns = 6,
  showMore = true,
  moreLink,
  cardSize = 'medium',
  showJackpot = true,
  showProvider = true,
  isHorizontal = false,
  onPlay,
  isLoading = false,
}: GameGridProps) {
  const [scrollPosition, setScrollPosition] = useState(0);

  const handleScrollLeft = () => {
    const container = document.getElementById(`grid-${title}`);
    if (container) {
      container.scrollBy({ left: -300, behavior: 'smooth' });
      setScrollPosition(container.scrollLeft - 300);
    }
  };

  const handleScrollRight = () => {
    const container = document.getElementById(`grid-${title}`);
    if (container) {
      container.scrollBy({ left: 300, behavior: 'smooth' });
      setScrollPosition(container.scrollLeft + 300);
    }
  };

  const gridCols = {
    4: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4',
    5: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5',
    6: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6',
  };

  if (isLoading) {
    return (
      <section className="py-8 mt-4">
        <div className="section-header">
          <div>
            <div className="h-6 w-40 bg-white/10 rounded animate-pulse" />
            {subtitle && <div className="h-4 w-60 bg-white/10 rounded animate-pulse mt-2" />}
          </div>
        </div>
        <div className={cn('grid gap-4', gridCols[columns as keyof typeof gridCols])}>
          {Array.from({ length: columns }).map((_, i) => (
            <div
              key={i}
              className="aspect-[4/5] bg-white/10 rounded-lg animate-pulse"
            />
          ))}
        </div>
      </section>
    );
  }

  if (games.length === 0) {
    return null;
  }

  return (
    <section className="py-8 mt-4">
      {/* Header */}
      <div className="section-header">
        <div>
          <h2 className="section-title">{title}</h2>
          {subtitle && <p className="section-subtitle">{subtitle}</p>}
        </div>
        {showMore && (
          <button className="flex items-center gap-1 text-sm text-gray-400 hover:text-white transition-colors">
            More <ChevronRight className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* Games */}
      {isHorizontal ? (
        <div className="relative group">
          {/* Scroll Buttons */}
          <button
            onClick={handleScrollLeft}
            className="absolute left-0 top-1/2 -translate-y-1/2 z-10 w-10 h-10 bg-black/80 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-black"
          >
            <ChevronLeft className="w-6 h-6 text-white" />
          </button>
          <button
            onClick={handleScrollRight}
            className="absolute right-0 top-1/2 -translate-y-1/2 z-10 w-10 h-10 bg-black/80 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-black"
          >
            <ChevronRight className="w-6 h-6 text-white" />
          </button>

          {/* Scrollable Container */}
          <div
            id={`grid-${title}`}
            className="flex gap-4 overflow-x-auto overflow-y-visible hide-scrollbar pb-4 pt-4"
          >
            {games.map((game) => (
              <div key={game.id} className="flex-shrink-0">
                <GameCard
                  game={game}
                  size={cardSize}
                  showJackpot={showJackpot}
                  showProvider={showProvider}
                  onPlay={onPlay}
                />
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className={cn('grid gap-4 pt-4', gridCols[columns as keyof typeof gridCols])}>
          {games.map((game) => (
            <GameCard
              key={game.id}
              game={game}
              size={cardSize}
              showJackpot={showJackpot}
              showProvider={showProvider}
              onPlay={onPlay}
            />
          ))}
        </div>
      )}
    </section>
  );
}
