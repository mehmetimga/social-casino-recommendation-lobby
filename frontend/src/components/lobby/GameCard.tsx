import { useState, useEffect, useRef } from 'react';
import { Play } from 'lucide-react';
import { Game, BadgeType } from '../../types/game';
import { getMediaUrl } from '../../api/client';
import { formatJackpot } from '../../utils/formatters';
import { cn } from '../../utils/cn';
import { useUser } from '../../context/UserContext';
import GameBadge from '../game/GameBadge';

interface GameCardProps {
  game: Game;
  size?: 'small' | 'medium' | 'large';
  showJackpot?: boolean;
  showProvider?: boolean;
  onPlay?: (game: Game) => void;
}

export default function GameCard({
  game,
  size = 'medium',
  showJackpot = true,
  showProvider = true,
  onPlay,
}: GameCardProps) {
  const { trackEvent } = useUser();
  const [isVisible, setIsVisible] = useState(false);
  const [hasTrackedImpression, setHasTrackedImpression] = useState(false);
  const cardRef = useRef<HTMLDivElement>(null);

  // Track impressions when card becomes visible
  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasTrackedImpression) {
          setIsVisible(true);
          trackEvent(game.slug, 'impression');
          setHasTrackedImpression(true);
        }
      },
      { threshold: 0.5 }
    );

    if (cardRef.current) {
      observer.observe(cardRef.current);
    }

    return () => observer.disconnect();
  }, [game.slug, trackEvent, hasTrackedImpression]);

  const handleClick = () => {
    // No event tracking here - only track when actually playing
    onPlay?.(game);
  };

  const sizeClasses = {
    small: 'w-36 h-48',
    medium: 'w-44 h-56',
    large: 'w-52 h-64',
  };

  const thumbnailUrl = getMediaUrl(
    game.thumbnail?.sizes?.card?.url || game.thumbnail?.url
  );

  return (
    <div
      ref={cardRef}
      className={cn('game-card cursor-pointer group', sizeClasses[size])}
      onClick={handleClick}
    >
      {/* Badges - Outside of image container so they can overflow */}
      {game.badges && game.badges.length > 0 && (
        <div className="absolute -top-1 -left-1 flex flex-col gap-1 z-50">
          {game.badges.slice(0, 1).map((badge) => (
            <GameBadge key={badge} type={badge} />
          ))}
        </div>
      )}

      {/* Thumbnail */}
      <div className="relative w-full h-full overflow-hidden rounded-lg">
        <img
          src={thumbnailUrl || '/placeholder-game.jpg'}
          alt={game.title}
          className="w-full h-full object-cover"
          loading="lazy"
        />

        {/* Jackpot Amount */}
        {showJackpot && game.jackpotAmount && game.jackpotAmount > 0 && (
          <div className="absolute top-2 right-2">
            <div className="jackpot-amount jackpot-pulse">
              {formatJackpot(game.jackpotAmount)}
            </div>
          </div>
        )}

        {/* Hover Overlay */}
        <div className="game-card-overlay">
          {/* Play Button */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-14 h-14 rounded-full bg-white/90 flex items-center justify-center transform scale-0 group-hover:scale-100 transition-transform duration-300">
              <Play className="w-6 h-6 text-casino-purple fill-casino-purple ml-1" />
            </div>
          </div>
        </div>

        {/* Game Info */}
        <div className="game-card-info">
          <h3 className="text-white font-semibold text-sm truncate">{game.title}</h3>
          {showProvider && (
            <p className="text-gray-400 text-xs truncate">{game.provider}</p>
          )}
        </div>

        {/* Provider Logo (bottom right) */}
        {showProvider && (
          <div className="absolute bottom-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
            <div className="bg-black/70 px-2 py-1 rounded text-xs text-gray-300">
              {game.provider}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
