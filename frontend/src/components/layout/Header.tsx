import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Search, Menu, X, User, LogIn } from 'lucide-react';
import { cn } from '../../utils/cn';
import SearchBar from './SearchBar';
import betriversBanner from '../../assets/betrivers_banner.png';

const mainNavItems = [
  { label: 'Poker', href: '/poker', disabled: true },
  { label: 'Casino', href: '/', active: true, isGold: true },
  { label: 'Sports', href: '/sports', disabled: true },
];

const userNavItems = [
  { label: 'Rewards', href: '/rewards' },
  { label: 'Promotions', href: '/promotions' },
  { label: 'Challenges', href: '/challenges' },
  { label: 'Store', href: '/store' },
];

export default function Header() {
  const location = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isSearchOpen, setIsSearchOpen] = useState(false);

  return (
    <header className="sticky top-0 z-[999] bg-black/95 backdrop-blur-md border-b border-white/10 isolate">
      <div className="container-casino">
        {/* Main Header */}
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <img src={betriversBanner} alt="Betrivers" className="h-8 w-auto" />
            <span className="text-white font-bold text-xl hidden sm:block">Social Casino</span>
          </Link>

          {/* Main Navigation */}
          <nav className="hidden md:flex items-center gap-1">
            {mainNavItems.map((item) => (
              <Link
                key={item.label}
                to={item.disabled ? '#' : item.href}
                className={cn(
                  'px-4 py-2 rounded-lg text-sm font-medium transition-colors',
                  item.disabled && 'opacity-50 cursor-not-allowed',
                  location.pathname === item.href || (item.href === '/' && location.pathname === '/')
                    ? item.isGold
                      ? 'bg-casino-gold text-black'
                      : 'bg-casino-accent text-white'
                    : 'text-gray-300 hover:text-white hover:bg-white/10'
                )}
                onClick={(e) => item.disabled && e.preventDefault()}
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* Secondary Navigation */}
          <nav className="hidden lg:flex items-center gap-4 text-sm text-gray-400">
            {userNavItems.map((item) => (
              <Link
                key={item.label}
                to={item.href}
                className="hover:text-white transition-colors"
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* Actions */}
          <div className="flex items-center gap-2">
            {/* Search Toggle */}
            <button
              onClick={() => setIsSearchOpen(!isSearchOpen)}
              className="p-2 rounded-lg hover:bg-white/10 transition-colors"
            >
              <Search className="w-5 h-5 text-gray-400" />
            </button>

            {/* Login / Join Buttons */}
            <button className="btn btn-secondary text-sm hidden sm:flex items-center gap-2">
              <LogIn className="w-4 h-4" />
              Login
            </button>
            <button className="btn btn-gold text-sm">
              Join
            </button>

            {/* Mobile Menu Toggle */}
            <button
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              className="p-2 rounded-lg hover:bg-white/10 transition-colors md:hidden"
            >
              {isMobileMenuOpen ? (
                <X className="w-5 h-5 text-gray-400" />
              ) : (
                <Menu className="w-5 h-5 text-gray-400" />
              )}
            </button>
          </div>
        </div>

        {/* Search Bar (expandable) */}
        {isSearchOpen && (
          <div className="py-3 border-t border-white/10 relative z-[200]">
            <SearchBar onClose={() => setIsSearchOpen(false)} />
          </div>
        )}

        {/* Mobile Menu */}
        {isMobileMenuOpen && (
          <div className="md:hidden py-4 border-t border-white/10">
            <nav className="flex flex-col gap-2">
              {mainNavItems.map((item) => (
                <Link
                  key={item.label}
                  to={item.disabled ? '#' : item.href}
                  className={cn(
                    'px-4 py-2 rounded-lg text-sm font-medium',
                    item.disabled && 'opacity-50',
                    location.pathname === item.href
                      ? item.isGold
                        ? 'bg-casino-gold text-black'
                        : 'bg-casino-accent text-white'
                      : 'text-gray-300'
                  )}
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.label}
                </Link>
              ))}
            </nav>
          </div>
        )}
      </div>
    </header>
  );
}
