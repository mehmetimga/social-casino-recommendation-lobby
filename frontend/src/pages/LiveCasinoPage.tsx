import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import PlayModal from '../components/game/PlayModal';
import { cmsApi } from '../api/cms';
import { Game } from '../types/game';

export default function LiveCasinoPage() {
  const [selectedGame, setSelectedGame] = useState<Game | null>(null);

  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'live'],
    queryFn: () => cmsApi.getGamesByType('live', 50),
  });

  const handlePlayGame = (game: Game) => {
    setSelectedGame(game);
  };

  const handleCloseModal = () => {
    setSelectedGame(null);
  };

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
          onPlay={handlePlayGame}
          isLoading={isLoading}
        />
      </div>
      {selectedGame && (
        <PlayModal game={selectedGame} onClose={handleCloseModal} />
      )}
    </>
  );
}
