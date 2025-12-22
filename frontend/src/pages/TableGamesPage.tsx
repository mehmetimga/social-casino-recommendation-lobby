import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import { cmsApi } from '../api/cms';

export default function TableGamesPage() {
  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'table'],
    queryFn: () => cmsApi.getGamesByType('table', 50),
  });

  return (
    <>
      <CategoryTabs />
      <div className="container-casino py-6">
        <h1 className="text-3xl font-bold text-white mb-6">Table Games</h1>
        <GameGrid
          title="All Table Games"
          subtitle="Classic casino favorites - blackjack, roulette, and more"
          games={games || []}
          columns={6}
          rows={10}
          displayStyle="grid"
          showMore={false}
          isLoading={isLoading}
        />
      </div>
    </>
  );
}
