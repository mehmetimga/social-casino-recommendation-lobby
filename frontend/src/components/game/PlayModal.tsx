import { useState, useEffect } from 'react';
import { X, ChevronLeft, ChevronRight, MessageCircle } from 'lucide-react';
import { Game } from '../../types/game';
import { getMediaUrl } from '../../api/client';
import { formatBetRange, formatRTP } from '../../utils/formatters';
import { useChat } from '../../context/ChatContext';
import { useGamePlay } from '../../context/GamePlayContext';
import ReviewForm from './ReviewForm';
import GameBadge from './GameBadge';

interface PlayModalProps {
  game: Game;
  onClose: () => void;
}

export default function PlayModal({ game, onClose }: PlayModalProps) {
  const { openWithGame } = useChat();
  const { openGameDialog } = useGamePlay();
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [showReviewForm, setShowReviewForm] = useState(false);

  // Get all images for slideshow
  const images = [
    game.heroImage?.url || game.thumbnail?.url,
    ...(game.gallery?.map((g) => g.image?.url) || []),
  ].filter(Boolean) as string[];

  // Handle keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      } else if (e.key === 'ArrowLeft') {
        prevImage();
      } else if (e.key === 'ArrowRight') {
        nextImage();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const nextImage = () => {
    setCurrentImageIndex((prev) => (prev + 1) % images.length);
  };

  const prevImage = () => {
    setCurrentImageIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  const handleOpenChat = () => {
    openWithGame(game.slug, game.title);
  };

  const handlePlayNow = () => {
    onClose(); // Close info dialog
    openGameDialog(game); // Open play dialog with tracking
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/90 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal Content */}
      <div className="relative w-full max-w-5xl mx-4 bg-casino-bg-secondary rounded-2xl overflow-hidden shadow-2xl">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 w-10 h-10 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center transition-colors"
        >
          <X className="w-5 h-5 text-white" />
        </button>

        <div className="flex flex-col lg:flex-row">
          {/* Image Slideshow */}
          <div className="relative lg:w-2/3 aspect-video lg:aspect-auto lg:min-h-[500px] bg-black">
            <img
              src={getMediaUrl(images[currentImageIndex])}
              alt={game.title}
              className="w-full h-full object-contain"
            />

            {/* Navigation Arrows */}
            {images.length > 1 && (
              <>
                <button
                  onClick={prevImage}
                  className="absolute left-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center transition-colors"
                >
                  <ChevronLeft className="w-6 h-6 text-white" />
                </button>
                <button
                  onClick={nextImage}
                  className="absolute right-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center transition-colors"
                >
                  <ChevronRight className="w-6 h-6 text-white" />
                </button>

                {/* Dots */}
                <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2">
                  {images.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => setCurrentImageIndex(index)}
                      className={`w-2 h-2 rounded-full transition-all ${
                        currentImageIndex === index
                          ? 'bg-white w-6'
                          : 'bg-white/40 hover:bg-white/60'
                      }`}
                    />
                  ))}
                </div>
              </>
            )}

            {/* Fake Play Overlay */}
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
              <div className="text-center">
                <div className="text-6xl mb-4">🎰</div>
                <p className="text-white/60 text-sm">Demo Mode</p>
              </div>
            </div>
          </div>

          {/* Game Info Panel */}
          <div className="lg:w-1/3 p-6 flex flex-col">
            {/* Badges */}
            {game.badges && game.badges.length > 0 && (
              <div className="flex flex-wrap gap-2 mb-3">
                {game.badges.map((badge) => (
                  <GameBadge key={badge} type={badge} />
                ))}
              </div>
            )}

            {/* Title & Provider */}
            <h2 className="text-2xl font-bold text-white mb-1">{game.title}</h2>
            <p className="text-casino-purple font-medium mb-4">{game.provider}</p>

            {/* Description */}
            {game.shortDescription && (
              <p className="text-gray-400 text-sm mb-4">{game.shortDescription}</p>
            )}

            {/* Game Stats */}
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-white/5 rounded-lg p-3">
                <p className="text-gray-400 text-xs mb-1">Bet Range</p>
                <p className="text-white font-semibold">
                  {formatBetRange(game.minBet, game.maxBet)}
                </p>
              </div>
              {game.rtp && (
                <div className="bg-white/5 rounded-lg p-3">
                  <p className="text-gray-400 text-xs mb-1">RTP</p>
                  <p className="text-white font-semibold">{formatRTP(game.rtp)}</p>
                </div>
              )}
              {game.volatility && (
                <div className="bg-white/5 rounded-lg p-3">
                  <p className="text-gray-400 text-xs mb-1">Volatility</p>
                  <p className="text-white font-semibold capitalize">{game.volatility}</p>
                </div>
              )}
              {game.jackpotAmount && (
                <div className="bg-white/5 rounded-lg p-3">
                  <p className="text-gray-400 text-xs mb-1">Jackpot</p>
                  <p className="text-casino-gold font-semibold">
                    ${game.jackpotAmount.toLocaleString()}
                  </p>
                </div>
              )}
            </div>

            {/* Review Button */}
            <button
              onClick={() => setShowReviewForm(!showReviewForm)}
              className="btn btn-secondary mb-4"
            >
              {showReviewForm ? 'Hide Review Form' : 'Rate & Review'}
            </button>

            {/* Review Form */}
            {showReviewForm && (
              <ReviewForm
                gameId={game.id}
                gameSlug={game.slug}
                onSuccess={() => setShowReviewForm(false)}
              />
            )}

            {/* Spacer */}
            <div className="flex-1" />

            {/* Actions */}
            <div className="space-y-3 mt-4">
              <button
                onClick={handlePlayNow}
                className="btn btn-gold w-full text-lg py-3"
              >
                Play Now
              </button>
              <button
                onClick={handleOpenChat}
                className="btn btn-secondary w-full flex items-center justify-center gap-2"
              >
                <MessageCircle className="w-4 h-4" />
                Ask about this game
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
