import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import { cmsApi } from '../api/cms';

export default function LiveCasinoPage() {
  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'live'],
    queryFn: () => cmsApi.getGamesByType('live', 50),
  });

  return (
    <>
      <CategoryTabs />
      <div className="container-casino py-6">
        <h1 className="text-3xl font-bold text-white mb-6">Live Casino</h1>
        <GameGrid
          title="All Live Games"
          subtitle="Real dealers, real action - play live casino games"
          games={games || []}
          columns={6}
          showMore={false}
          isLoading={isLoading}
        />
      </div>
    </>
  );
}
