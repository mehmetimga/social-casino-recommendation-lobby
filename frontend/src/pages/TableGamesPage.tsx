import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import CategoryTabs from '../components/layout/CategoryTabs';
import GameGrid from '../components/lobby/GameGrid';
import PlayModal from '../components/game/PlayModal';
import { cmsApi } from '../api/cms';
import { Game } from '../types/game';

export default function TableGamesPage() {
  const [selectedGame, setSelectedGame] = useState<Game | null>(null);

  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'table'],
    queryFn: () => cmsApi.getGamesByType('table', 50),
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
        <h1 className="text-3xl font-bold text-white mb-6">Table Games</h1>
        <GameGrid
          title="All Table Games"
          subtitle="Classic casino favorites - blackjack, roulette, and more"
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
