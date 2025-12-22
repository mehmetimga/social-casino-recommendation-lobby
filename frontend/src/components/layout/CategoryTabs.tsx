import { Link, useLocation } from 'react-router-dom';
import { Heart, Sparkles, Video, Dice1, Zap } from 'lucide-react';
import { cn } from '../../utils/cn';

const categories = [
  { label: 'My Casino', href: '/', icon: Heart },
  { label: 'Slots', href: '/slots', icon: Sparkles },
  { label: 'Live Casino', href: '/live-casino', icon: Video },
  { label: 'Table Games', href: '/table-games', icon: Dice1 },
  { label: 'Instant Win', href: '/instant-win', icon: Zap },
];

export default function CategoryTabs() {
  const location = useLocation();

  return (
    <div className="bg-casino-bg">
      <div className="flex items-center gap-2 py-1.5 px-3 overflow-x-auto hide-scrollbar">
        {categories.map((category) => {
          const Icon = category.icon;
          const isActive = location.pathname === category.href;

          return (
            <Link
              key={category.label}
              to={category.href}
              className={cn(
                'flex items-center gap-2 px-3.5 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all',
                isActive
                  ? 'bg-white/10 text-white border border-casino-gold/30'
                  : 'bg-white/5 text-gray-400 hover:text-white hover:bg-white/10'
              )}
            >
              <Icon className={cn('w-4 h-4', isActive && 'text-casino-gold')} />
              {category.label}
            </Link>
          );
        })}
      </div>
    </div>
  );
}
