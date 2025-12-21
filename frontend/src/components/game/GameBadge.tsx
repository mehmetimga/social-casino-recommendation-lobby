import { BadgeType } from '../../types/game';
import { cn } from '../../utils/cn';

interface GameBadgeProps {
  type: BadgeType;
  className?: string;
}

const badgeConfig: Record<BadgeType, { label: string; className: string }> = {
  new: {
    label: 'New',
    className: 'bg-green-500 text-white',
  },
  exclusive: {
    label: 'Exclusive',
    className: 'bg-gradient-to-r from-purple-500 to-pink-500 text-white',
  },
  hot: {
    label: 'Hot',
    className: 'bg-red-500 text-white',
  },
  jackpot: {
    label: 'Jackpot',
    className: 'bg-gradient-to-r from-yellow-400 to-orange-500 text-black',
  },
  featured: {
    label: 'Featured',
    className: 'bg-blue-500 text-white',
  },
};

export default function GameBadge({ type, className }: GameBadgeProps) {
  const config = badgeConfig[type];

  return (
    <span
      className={cn(
        'inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold',
        config.className,
        className
      )}
    >
      {config.label}
    </span>
  );
}
