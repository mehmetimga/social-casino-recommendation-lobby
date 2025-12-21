import { useQuery } from '@tanstack/react-query';
import { cmsApi } from '../../api/cms';
import { recommendationApi } from '../../api/recommendation';
import { SuggestedGamesSectionBlock } from '../../types/lobby';
import { Game } from '../../types/game';
import { useUser } from '../../context/UserContext';
import GameGrid from './GameGrid';

interface SuggestedGamesProps {
  section: SuggestedGamesSectionBlock;
}

export default function SuggestedGames({ section }: SuggestedGamesProps) {
  const { userId } = useUser();

  const fetchGames = async (): Promise<Game[]> => {
    if (section.mode === 'manual') {
      // Manual games should already be populated
      return (section.manualGames as Game[]) || [];
    }

    // Personalized mode - get recommendations from API
    try {
      const recommendedSlugs = await recommendationApi.getRecommendations({
        userId,
        placement: section.placement,
        limit: section.limit,
      });

      if (recommendedSlugs.length > 0) {
        return cmsApi.getGamesBySlugs(recommendedSlugs);
      }
    } catch (error) {
      console.error('Failed to fetch recommendations:', error);
    }

    // Fallback to popular games
    if (section.fallbackToPopular) {
      return cmsApi.getPopularGames(section.limit);
    }

    return [];
  };

  const { data: games, isLoading } = useQuery({
    queryKey: ['suggested-games', section.mode, section.placement, userId, section.limit],
    queryFn: fetchGames,
    enabled: !!userId,
  });

  return (
    <div className="container-casino">
      <GameGrid
        title={section.title}
        subtitle={section.subtitle}
        games={games || []}
        cardSize={section.cardSize}
        isHorizontal={true}
        isLoading={isLoading}
        showMore={false}
      />
    </div>
  );
}
