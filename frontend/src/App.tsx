import { Routes, Route } from 'react-router-dom';
import { UserProvider } from './context/UserContext';
import { ChatProvider } from './context/ChatContext';
import Header from './components/layout/Header';
import LobbyPage from './pages/LobbyPage';
import SlotsPage from './pages/SlotsPage';
import LiveCasinoPage from './pages/LiveCasinoPage';
import TableGamesPage from './pages/TableGamesPage';
import ChatWidget from './components/chat/ChatWidget';

function App() {
  return (
    <UserProvider>
      <ChatProvider>
        <div className="min-h-screen bg-gradient-casino">
          <Header />
          <main>
            <Routes>
              <Route path="/" element={<LobbyPage />} />
              <Route path="/slots" element={<SlotsPage />} />
              <Route path="/live-casino" element={<LiveCasinoPage />} />
              <Route path="/table-games" element={<TableGamesPage />} />
            </Routes>
          </main>
          <ChatWidget />
        </div>
      </ChatProvider>
    </UserProvider>
  );
}

export default App;
