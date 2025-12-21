import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { recommendationApi } from '../../api/recommendation';
import { useUser } from '../../context/UserContext';
import RatingStars from './RatingStars';

interface ReviewFormProps {
  gameId: string;
  gameSlug: string;
  onSuccess?: () => void;
}

export default function ReviewForm({ gameId, gameSlug, onSuccess }: ReviewFormProps) {
  const { userId } = useUser();
  const queryClient = useQueryClient();
  const [rating, setRating] = useState(0);
  const [reviewText, setReviewText] = useState('');
  const [error, setError] = useState('');

  const submitReview = useMutation({
    mutationFn: () =>
      recommendationApi.submitReview({
        userId,
        gameSlug,
        rating,
        reviewText: reviewText.trim() || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['game-reviews', gameSlug] });
      queryClient.invalidateQueries({ queryKey: ['user-review', userId, gameSlug] });
      setReviewText('');
      setRating(0);
      onSuccess?.();
    },
    onError: (err: Error) => {
      setError(err.message || 'Failed to submit review');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (rating === 0) {
      setError('Please select a rating');
      return;
    }

    submitReview.mutate();
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Rating */}
      <div>
        <label className="block text-sm text-gray-400 mb-2">Your Rating</label>
        <RatingStars
          gameSlug={gameSlug}
          initialRating={rating}
          size="large"
          onRate={setRating}
        />
      </div>

      {/* Review Text */}
      <div>
        <label className="block text-sm text-gray-400 mb-2">
          Review (optional)
        </label>
        <textarea
          value={reviewText}
          onChange={(e) => setReviewText(e.target.value)}
          placeholder="Share your experience with this game..."
          rows={3}
          className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:border-casino-purple resize-none"
        />
      </div>

      {/* Error Message */}
      {error && (
        <p className="text-red-400 text-sm">{error}</p>
      )}

      {/* Submit Button */}
      <button
        type="submit"
        disabled={submitReview.isPending}
        className="btn btn-primary w-full"
      >
        {submitReview.isPending ? 'Submitting...' : 'Submit Review'}
      </button>
    </form>
  );
}
