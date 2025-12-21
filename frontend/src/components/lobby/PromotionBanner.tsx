import { Promotion } from '../../types/promotion';
import { getMediaUrl } from '../../api/client';
import { cn } from '../../utils/cn';
import CountdownTimer from './CountdownTimer';

interface PromotionBannerProps {
  promotion: Promotion;
  size?: 'small' | 'medium' | 'large';
  alignment?: 'left' | 'center' | 'right';
  showCountdown?: boolean;
  rounded?: boolean;
  marginTop?: number;
  marginBottom?: number;
}

const sizeClasses = {
  small: 'h-[200px]',
  medium: 'h-[300px]',
  large: 'h-[400px]',
};

export default function PromotionBanner({
  promotion,
  size = 'large',
  alignment = 'center',
  showCountdown = true,
  rounded = true,
  marginTop = 24,
  marginBottom = 24,
}: PromotionBannerProps) {
  const alignmentClasses = {
    left: 'items-start text-left',
    center: 'items-center text-center',
    right: 'items-end text-right',
  };

  return (
    <section
      style={{ marginTop, marginBottom }}
      className={cn(
        'relative overflow-hidden bg-cover bg-center',
        sizeClasses[size],
        rounded && 'rounded-2xl'
      )}
    >
      {/* Background Image */}
      <div
        className="absolute inset-0 bg-cover bg-center"
        style={{
          backgroundImage: `url(${getMediaUrl(
            promotion.backgroundImage?.url || promotion.image?.url
          )})`,
        }}
      >
        {/* Overlay */}
        <div className="absolute inset-0 bg-gradient-to-r from-black/70 via-black/50 to-black/30" />
      </div>

      {/* Content */}
      <div
        className={cn(
          'relative h-full container-casino flex flex-col justify-center',
          alignmentClasses[alignment]
        )}
      >
        {/* Countdown Timer */}
        {showCountdown && promotion.countdown?.enabled && promotion.countdown.endTime && (
          <div className="mb-4">
            <CountdownTimer
              endTime={promotion.countdown.endTime}
              label={promotion.countdown.label}
            />
          </div>
        )}

        {/* Subtitle */}
        {promotion.subtitle && (
          <p className="text-casino-gold font-semibold text-sm md:text-base mb-2">
            {promotion.subtitle}
          </p>
        )}

        {/* Title */}
        <h2 className="text-2xl md:text-4xl lg:text-5xl font-bold text-white mb-4 max-w-2xl">
          {promotion.title}
        </h2>

        {/* Description */}
        {promotion.description && (
          <p className="text-gray-300 mb-6 max-w-xl">{promotion.description}</p>
        )}

        {/* CTA Button */}
        <button className="btn btn-gold text-lg px-8 py-3">
          {promotion.ctaText}
        </button>
      </div>
    </section>
  );
}
