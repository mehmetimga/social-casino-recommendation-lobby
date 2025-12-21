import { useEffect, useState, useRef } from 'react';
import { X } from 'lucide-react';
import type { Game } from '../../types/game';
import { useUser } from '../../context/UserContext';
import { recommendationApi } from '../../api/recommendation';
import { getMediaUrl } from '../../api/client';

interface GamePlayDialogProps {
  game: Game;
  isOpen: boolean;
  onClose: () => void;
}

export function GamePlayDialog({ game, isOpen, onClose }: GamePlayDialogProps) {
  const { userId } = useUser();
  const [playStartTime, setPlayStartTime] = useState<number | null>(null);
  const hasTrackedStart = useRef(false);

  useEffect(() => {
    if (isOpen && !hasTrackedStart.current) {
      // Start tracking time when dialog opens
      const startTime = Date.now();
      setPlayStartTime(startTime);
      hasTrackedStart.current = true;

      console.log('Started tracking play time for:', game.slug);
    }

    // Reset when dialog closes
    if (!isOpen) {
      hasTrackedStart.current = false;
      setPlayStartTime(null);
    }
  }, [isOpen, game.slug]);

  const handleClose = (e?: React.MouseEvent) => {
    // Stop event propagation to prevent card click from re-opening
    if (e) {
      e.stopPropagation();
      e.preventDefault();
    }

    if (playStartTime) {
      // Calculate play duration in seconds
      const duration = Math.floor((Date.now() - playStartTime) / 1000);

      console.log('Tracking game_time for:', game.slug, 'duration:', duration);

      // Track game_time event with duration
      recommendationApi.trackEvent({
        userId,
        gameSlug: game.slug,
        eventType: 'game_time',
        durationSeconds: duration,
      }).catch((error) => {
        console.error('Failed to track game_time:', error);
      });
    }

    // Reset state
    setPlayStartTime(null);
    hasTrackedStart.current = false;
    onClose();
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    // Only close if clicking the backdrop itself, not the content
    if (e.target === e.currentTarget) {
      handleClose(e);
    }
  };

  const handleContentClick = (e: React.MouseEvent) => {
    // Stop propagation from content to prevent closing on content clicks
    e.stopPropagation();
  };

  if (!isOpen) return null;

  // Get hero image or thumbnail with proper URL
  const imageUrl = getMediaUrl(
    game.heroImage?.url ||
    game.thumbnail?.sizes?.hero?.url ||
    game.thumbnail?.sizes?.card?.url ||
    game.thumbnail?.url
  );
  const imageAlt = game.heroImage?.alt || game.thumbnail?.alt || game.title;

  console.log('GamePlayDialog opened:', {
    title: game.title,
    imageUrl,
    heroImage: game.heroImage?.url,
    thumbnail: game.thumbnail?.url
  });

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4"
      onClick={handleBackdropClick}
    >
      <div
        className="relative max-w-5xl w-full bg-black rounded-lg overflow-hidden shadow-2xl"
        onClick={handleContentClick}
      >
        {/* Close Button */}
        <button
          onClick={handleClose}
          className="absolute top-4 right-4 z-10 p-3 bg-black/70 hover:bg-red-600/80 rounded-full transition-all duration-200 hover:scale-110"
          aria-label="Close"
        >
          <X className="w-6 h-6 text-white" />
        </button>

        {/* Game Image - Full Screen Display */}
        <div className="relative w-full aspect-video bg-black">
          {imageUrl ? (
            <img
              src={imageUrl}
              alt={imageAlt}
              className="w-full h-full object-contain"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-gray-500">
              <div className="text-center">
                <p className="text-xl mb-2">🎰</p>
                <p>No image available</p>
              </div>
            </div>
          )}

          {/* Simple Game Title Overlay */}
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black via-black/60 to-transparent p-6">
            <h2 className="text-3xl font-bold text-white mb-1">{game.title}</h2>
            <p className="text-gray-300 text-sm">{game.provider}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
