import { useState } from 'react';
import { Star } from 'lucide-react';
import { useUser } from '../../context/UserContext';
import { cn } from '../../utils/cn';

interface RatingStarsProps {
  gameSlug: string;
  initialRating?: number;
  size?: 'small' | 'medium' | 'large';
  readOnly?: boolean;
  onRate?: (rating: number) => void;
}

const sizeClasses = {
  small: 'w-4 h-4',
  medium: 'w-5 h-5',
  large: 'w-7 h-7',
};

export default function RatingStars({
  gameSlug,
  initialRating = 0,
  size = 'medium',
  readOnly = false,
  onRate,
}: RatingStarsProps) {
  const { trackRating } = useUser();
  const [rating, setRating] = useState(initialRating);
  const [hoverRating, setHoverRating] = useState(0);
  const [hasRated, setHasRated] = useState(false);

  const handleClick = async (selectedRating: number) => {
    if (readOnly || hasRated) return;

    setRating(selectedRating);
    setHasRated(true);

    // Track rating
    await trackRating(gameSlug, selectedRating);
    onRate?.(selectedRating);
  };

  const displayRating = hoverRating || rating;

  return (
    <div className="flex items-center gap-1">
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          type="button"
          disabled={readOnly || hasRated}
          onClick={() => handleClick(star)}
          onMouseEnter={() => !readOnly && !hasRated && setHoverRating(star)}
          onMouseLeave={() => setHoverRating(0)}
          className={cn(
            'transition-transform',
            !readOnly && !hasRated && 'hover:scale-110 cursor-pointer',
            (readOnly || hasRated) && 'cursor-default'
          )}
        >
          <Star
            className={cn(
              sizeClasses[size],
              'transition-colors',
              star <= displayRating
                ? 'fill-casino-gold text-casino-gold'
                : 'fill-transparent text-gray-500'
            )}
          />
        </button>
      ))}
      {hasRated && (
        <span className="ml-2 text-sm text-casino-gold">Thanks for rating!</span>
      )}
    </div>
  );
}
