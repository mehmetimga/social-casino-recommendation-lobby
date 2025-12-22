import { useState } from 'react';
import { ChevronRight, ChevronLeft } from 'lucide-react';
import { Game } from '../../types/game';
import { DisplayStyle } from '../../types/lobby';
import { cn } from '../../utils/cn';
import GameCard from './GameCard';
import { useGamePlay } from '../../context/GamePlayContext';

interface GameGridProps {
  title: string;
  subtitle?: string;
  games: Game[];
  columns?: number;
  rows?: number;
  displayStyle?: DisplayStyle;
  featuredGame?: Game;
  showMore?: boolean;
  moreLink?: string;
  cardSize?: 'small' | 'medium' | 'large';
  showJackpot?: boolean;
  showProvider?: boolean;
  isLoading?: boolean;
}

export default function GameGrid({
  title,
  subtitle,
  games,
  columns = 6,
  rows = 2,
  displayStyle = 'horizontal',
  featuredGame,
  showMore = true,
  moreLink,
  cardSize = 'medium',
  showJackpot = true,
  showProvider = true,
  isLoading = false,
}: GameGridProps) {
  const [scrollPosition, setScrollPosition] = useState(0);
  const { openGameInfo } = useGamePlay();

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

  const handlePlayGame = (game: Game) => {
    openGameInfo(game);
  };

  const gridCols = {
    4: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4',
    5: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5',
    6: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6',
  };

  // Get games to display based on displayStyle
  const getDisplayGames = () => {
    if (displayStyle === 'grid') {
      return games.slice(0, rows * columns);
    }
    if (displayStyle === 'single-row') {
      return games.slice(0, columns);
    }
    if (['featured-left', 'featured-right', 'featured-top'].includes(displayStyle)) {
      // Filter out featured game from the list
      if (featuredGame) {
        return games.filter((g) => g.id !== featuredGame.id);
      }
      return games.slice(1); // First game is featured if no explicit selection
    }
    return games;
  };

  const displayGames = getDisplayGames();
  const actualFeaturedGame = featuredGame || games[0];

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

  // Render horizontal scroll layout
  const renderHorizontal = () => (
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
              onPlay={handlePlayGame}
            />
          </div>
        ))}
      </div>
    </div>
  );

  // Render grid layout with configurable rows
  const renderGrid = () => (
    <div className={cn('grid gap-4 pt-4', gridCols[columns as keyof typeof gridCols])}>
      {displayGames.map((game) => (
        <GameCard
          key={game.id}
          game={game}
          size={cardSize}
          showJackpot={showJackpot}
          showProvider={showProvider}
          onPlay={handlePlayGame}
        />
      ))}
    </div>
  );

  // Render single row (no scroll)
  const renderSingleRow = () => (
    <div className={cn('grid gap-4 pt-4', gridCols[columns as keyof typeof gridCols])}>
      {displayGames.map((game) => (
        <GameCard
          key={game.id}
          game={game}
          size={cardSize}
          showJackpot={showJackpot}
          showProvider={showProvider}
          onPlay={handlePlayGame}
        />
      ))}
    </div>
  );

  // Render featured left: large card on left, small grid on right
  const renderFeaturedLeft = () => (
    <div className="flex gap-4 pt-4">
      {/* Large Featured Card */}
      <div className="flex-shrink-0">
        <GameCard
          game={actualFeaturedGame}
          size="large"
          showJackpot={showJackpot}
          showProvider={showProvider}
          onPlay={handlePlayGame}
          className="w-64 h-80 md:w-72 md:h-96"
        />
      </div>
      {/* Small Grid */}
      <div className="flex-1 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        {displayGames.slice(0, 8).map((game) => (
          <GameCard
            key={game.id}
            game={game}
            size="small"
            showJackpot={showJackpot}
            showProvider={showProvider}
            onPlay={handlePlayGame}
          />
        ))}
      </div>
    </div>
  );

  // Render featured right: small grid on left, large card on right
  const renderFeaturedRight = () => (
    <div className="flex gap-4 pt-4">
      {/* Small Grid */}
      <div className="flex-1 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        {displayGames.slice(0, 8).map((game) => (
          <GameCard
            key={game.id}
            game={game}
            size="small"
            showJackpot={showJackpot}
            showProvider={showProvider}
            onPlay={handlePlayGame}
          />
        ))}
      </div>
      {/* Large Featured Card */}
      <div className="flex-shrink-0">
        <GameCard
          game={actualFeaturedGame}
          size="large"
          showJackpot={showJackpot}
          showProvider={showProvider}
          onPlay={handlePlayGame}
          className="w-64 h-80 md:w-72 md:h-96"
        />
      </div>
    </div>
  );

  // Render featured top: large card on top, row of small below
  const renderFeaturedTop = () => (
    <div className="space-y-4 pt-4">
      {/* Large Featured Card */}
      <div className="flex justify-center">
        <GameCard
          game={actualFeaturedGame}
          size="large"
          showJackpot={showJackpot}
          showProvider={showProvider}
          onPlay={handlePlayGame}
          className="w-full max-w-2xl h-64 md:h-80"
        />
      </div>
      {/* Row of Small Cards */}
      <div className={cn('grid gap-4', gridCols[columns as keyof typeof gridCols])}>
        {displayGames.slice(0, columns).map((game) => (
          <GameCard
            key={game.id}
            game={game}
            size="small"
            showJackpot={showJackpot}
            showProvider={showProvider}
            onPlay={handlePlayGame}
          />
        ))}
      </div>
    </div>
  );

  // Select render method based on displayStyle
  const renderContent = () => {
    switch (displayStyle) {
      case 'horizontal':
        return renderHorizontal();
      case 'grid':
        return renderGrid();
      case 'single-row':
        return renderSingleRow();
      case 'featured-left':
        return renderFeaturedLeft();
      case 'featured-right':
        return renderFeaturedRight();
      case 'featured-top':
        return renderFeaturedTop();
      default:
        return renderHorizontal();
    }
  };

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

      {/* Games Content */}
      {renderContent()}
    </section>
  );
}
