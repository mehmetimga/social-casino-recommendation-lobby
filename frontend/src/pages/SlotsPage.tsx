import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import { cmsApi } from '../api/cms';

export default function SlotsPage() {
  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'slots'],
    queryFn: () => cmsApi.getGamesByType('slot', 50),
  });

  return (
    <>
      <CategoryTabs />
      <div className="container-casino py-6">
        <h1 className="text-3xl font-bold text-white mb-6">Slots</h1>
        <GameGrid
          title="All Slots"
          subtitle="Spin to win on our best slot games"
          games={games || []}
          columns={6}
          showMore={false}
          isLoading={isLoading}
        />
      </div>
    </>
  );
}
