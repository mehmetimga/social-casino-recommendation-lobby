import { Link, useLocation } from 'react-router-dom';
import { Heart, Sparkles, Video, Dice1, Zap, Gift } from 'lucide-react';
import { cn } from '../../utils/cn';

const categories = [
  { label: 'My Casino', href: '/', icon: Heart },
  { label: 'Slots', href: '/slots', icon: Sparkles },
  { label: 'Live Casino', href: '/live-casino', icon: Video },
  { label: 'Races', href: '/races', icon: Gift, disabled: true },
  { label: 'Table Games', href: '/table-games', icon: Dice1 },
  { label: 'Instant Win', href: '/instant-win', icon: Zap, disabled: true },
];

export default function CategoryTabs() {
  const location = useLocation();

  return (
    <div className="bg-casino-bg-secondary/50 border-b border-white/5">
      <div className="container-casino">
        <div className="flex items-center gap-1 py-2 overflow-x-auto hide-scrollbar">
          {categories.map((category) => {
            const Icon = category.icon;
            const isActive = location.pathname === category.href;

            return (
              <Link
                key={category.label}
                to={category.disabled ? '#' : category.href}
                onClick={(e) => category.disabled && e.preventDefault()}
                className={cn(
                  'flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all',
                  category.disabled && 'opacity-50 cursor-not-allowed',
                  isActive
                    ? 'bg-casino-accent text-white'
                    : 'text-gray-400 hover:text-white hover:bg-white/5'
                )}
              >
                <Icon className="w-4 h-4" />
                {category.label}
              </Link>
            );
          })}
        </div>
      </div>
    </div>
  );
}
