import { useState, useEffect, useRef } from 'react';
import { Search, X } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { cmsApi } from '../../api/cms';
import { getMediaUrl } from '../../api/client';
import { Game } from '../../types/game';

interface SearchBarProps {
  onClose?: () => void;
}

export default function SearchBar({ onClose }: SearchBarProps) {
  const [query, setQuery] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const { data: games, isLoading } = useQuery({
    queryKey: ['games', 'search', query],
    queryFn: () => cmsApi.getGames({ limit: 10 }),
    enabled: query.length > 1,
  });

  // Filter games by search query
  const filteredGames = games?.docs.filter((game) =>
    game.title.toLowerCase().includes(query.toLowerCase()) ||
    game.provider.toLowerCase().includes(query.toLowerCase())
  ) || [];

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleGameClick = (game: Game) => {
    setQuery('');
    setIsOpen(false);
    onClose?.();
    // TODO: Navigate to game or open modal
    console.log('Selected game:', game.slug);
  };

  return (
    <div ref={containerRef} className="relative">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input
          ref={inputRef}
          type="text"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setIsOpen(e.target.value.length > 1);
          }}
          placeholder="Search games..."
          className="w-full pl-10 pr-10 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:border-casino-purple"
        />
        {query && (
          <button
            onClick={() => {
              setQuery('');
              setIsOpen(false);
            }}
            className="absolute right-3 top-1/2 -translate-y-1/2"
          >
            <X className="w-5 h-5 text-gray-400 hover:text-white" />
          </button>
        )}
      </div>

      {/* Search Results Dropdown */}
      {isOpen && query.length > 1 && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-casino-bg-secondary border border-white/10 rounded-lg shadow-xl overflow-hidden z-50">
          {isLoading ? (
            <div className="p-4 text-center text-gray-400">
              Searching...
            </div>
          ) : filteredGames.length > 0 ? (
            <div className="max-h-80 overflow-y-auto">
              {filteredGames.map((game) => (
                <button
                  key={game.id}
                  onClick={() => handleGameClick(game)}
                  className="w-full flex items-center gap-3 p-3 hover:bg-white/5 transition-colors"
                >
                  <img
                    src={getMediaUrl(game.thumbnail?.sizes?.thumbnail?.url || game.thumbnail?.url)}
                    alt={game.title}
                    className="w-12 h-12 rounded object-cover"
                  />
                  <div className="text-left">
                    <div className="text-white font-medium">{game.title}</div>
                    <div className="text-sm text-gray-400">{game.provider}</div>
                  </div>
                </button>
              ))}
            </div>
          ) : (
            <div className="p-4 text-center text-gray-400">
              No games found
            </div>
          )}
        </div>
      )}
    </div>
  );
}
