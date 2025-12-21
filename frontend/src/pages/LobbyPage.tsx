import { useState } from 'react';
import CategoryTabs from '../components/layout/CategoryTabs';
import LobbyRenderer from '../components/lobby/LobbyRenderer';
import PlayModal from '../components/game/PlayModal';
import { Game } from '../types/game';

export default function LobbyPage() {
  const [selectedGame, setSelectedGame] = useState<Game | null>(null);

  const handlePlayGame = (game: Game) => {
    setSelectedGame(game);
  };

  const handleCloseModal = () => {
    setSelectedGame(null);
  };

  return (
    <>
      <CategoryTabs />
      <LobbyRenderer onPlayGame={handlePlayGame} />
      {selectedGame && (
        <PlayModal game={selectedGame} onClose={handleCloseModal} />
      )}
    </>
  );
}
