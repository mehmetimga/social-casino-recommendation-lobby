import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import { cmsApi } from '../api/cms';

export default function InstantWinPage() {
  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'instant'],
    queryFn: () => cmsApi.getGamesByType('instant', 50),
  });

  return (
    <>
      <CategoryTabs />
      <div className="container-casino py-6">
        <h1 className="text-3xl font-bold text-white mb-6">Instant Win</h1>
        <GameGrid
          title="All Instant Win Games"
          subtitle="Play and win instantly with Slingo and more"
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
