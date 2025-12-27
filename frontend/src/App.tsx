import { Routes, Route, useLocation } from 'react-router-dom';
import { UserProvider } from './context/UserContext';
import { ChatProvider } from './context/ChatContext';
import { GamePlayProvider } from './context/GamePlayContext';
import Header from './components/layout/Header';
import LobbyPage from './pages/LobbyPage';
import SlotsPage from './pages/SlotsPage';
import LiveCasinoPage from './pages/LiveCasinoPage';
import TableGamesPage from './pages/TableGamesPage';
import InstantWinPage from './pages/InstantWinPage';
import VizPage from './pages/VizPage';
import ChatWidget from './components/chat/ChatWidget';

function AppContent() {
  const location = useLocation();
  const isVizPage = location.pathname === '/viz';

  return (
    <div className={`min-h-screen ${isVizPage ? '' : 'bg-gradient-casino'}`}>
      {!isVizPage && <Header />}
      <main>
        <Routes>
          <Route path="/" element={<LobbyPage />} />
          <Route path="/slots" element={<SlotsPage />} />
          <Route path="/live-casino" element={<LiveCasinoPage />} />
          <Route path="/table-games" element={<TableGamesPage />} />
          <Route path="/instant-win" element={<InstantWinPage />} />
          <Route path="/viz" element={<VizPage />} />
        </Routes>
      </main>
      {!isVizPage && <ChatWidget />}
    </div>
  );
}

function App() {
  return (
    <UserProvider>
      <ChatProvider>
        <GamePlayProvider>
          <AppContent />
        </GamePlayProvider>
      </ChatProvider>
    </UserProvider>
  );
}

export default App;
