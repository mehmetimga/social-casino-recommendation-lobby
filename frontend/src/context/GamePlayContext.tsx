import { createContext, useContext, useState, ReactNode } from 'react';
import { Game } from '../types/game';
import { GamePlayDialog } from '../components/game/GamePlayDialog';
import PlayModal from '../components/game/PlayModal';

interface GamePlayContextType {
  openGameInfo: (game: Game) => void;
  openGameDialog: (game: Game) => void;
  closeGameInfo: () => void;
  closeGameDialog: () => void;
}

const GamePlayContext = createContext<GamePlayContextType | undefined>(undefined);

export function GamePlayProvider({ children }: { children: ReactNode }) {
  const [infoGame, setInfoGame] = useState<Game | null>(null);
  const [playGame, setPlayGame] = useState<Game | null>(null);
  const [isPlayOpen, setIsPlayOpen] = useState(false);

  const openGameInfo = (game: Game) => {
    setInfoGame(game);
  };

  const closeGameInfo = () => {
    setInfoGame(null);
  };

  const openGameDialog = (game: Game) => {
    setPlayGame(game);
    setIsPlayOpen(true);
  };

  const closeGameDialog = () => {
    setIsPlayOpen(false);
    // Small delay to allow dialog animation to complete
    setTimeout(() => setPlayGame(null), 300);
  };

  return (
    <GamePlayContext.Provider value={{ openGameInfo, openGameDialog, closeGameInfo, closeGameDialog }}>
      {children}
      {/* Game Info Dialog */}
      {infoGame && (
        <PlayModal
          game={infoGame}
          onClose={closeGameInfo}
        />
      )}
      {/* Game Play Dialog */}
      {playGame && (
        <GamePlayDialog
          game={playGame}
          isOpen={isPlayOpen}
          onClose={closeGameDialog}
        />
      )}
    </GamePlayContext.Provider>
  );
}

export function useGamePlay() {
  const context = useContext(GamePlayContext);
  if (context === undefined) {
    throw new Error('useGamePlay must be used within a GamePlayProvider');
  }
  return context;
}
