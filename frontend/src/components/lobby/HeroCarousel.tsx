import { useState, useEffect, useCallback } from 'react';
import useEmblaCarousel from 'embla-carousel-react';
import Autoplay from 'embla-carousel-autoplay';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Promotion } from '../../types/promotion';
import { getMediaUrl } from '../../api/client';
import { cn } from '../../utils/cn';
import CountdownTimer from './CountdownTimer';

interface HeroCarouselProps {
  promotions: Promotion[];
  autoPlay?: boolean;
  autoPlayInterval?: number;
  showDots?: boolean;
  showArrows?: boolean;
  height?: 'small' | 'medium' | 'large' | 'full';
}

const heightClasses = {
  small: 'h-[300px]',
  medium: 'h-[400px]',
  large: 'h-[500px]',
  full: 'h-[600px]',
};

export default function HeroCarousel({
  promotions,
  autoPlay = true,
  autoPlayInterval = 5000,
  showDots = true,
  showArrows = true,
  height = 'large',
}: HeroCarouselProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);

  const autoplayPlugin = Autoplay({
    delay: autoPlayInterval,
    stopOnInteraction: false,
    stopOnMouseEnter: true,
  });

  const [emblaRef, emblaApi] = useEmblaCarousel(
    { loop: true },
    autoPlay ? [autoplayPlugin] : []
  );

  const scrollPrev = useCallback(() => {
    if (emblaApi) emblaApi.scrollPrev();
  }, [emblaApi]);

  const scrollNext = useCallback(() => {
    if (emblaApi) emblaApi.scrollNext();
  }, [emblaApi]);

  const scrollTo = useCallback(
    (index: number) => {
      if (emblaApi) emblaApi.scrollTo(index);
    },
    [emblaApi]
  );

  useEffect(() => {
    if (!emblaApi) return;

    const onSelect = () => {
      setSelectedIndex(emblaApi.selectedScrollSnap());
    };

    emblaApi.on('select', onSelect);
    onSelect();

    return () => {
      emblaApi.off('select', onSelect);
    };
  }, [emblaApi]);

  if (promotions.length === 0) {
    return null;
  }

  return (
    <div className={cn('relative overflow-hidden', heightClasses[height])}>
      {/* Carousel Container */}
      <div ref={emblaRef} className="h-full">
        <div className="flex h-full">
          {promotions.map((promo) => (
            <div key={promo.id} className="flex-[0_0_100%] min-w-0 relative">
              {/* Background Image */}
              <div
                className="absolute inset-0 bg-cover bg-center"
                style={{
                  backgroundImage: `url(${getMediaUrl(
                    promo.backgroundImage?.url || promo.image?.url
                  )})`,
                }}
              >
                {/* Gradient Overlay */}
                <div className="absolute inset-0 bg-gradient-to-r from-black/80 via-black/50 to-transparent" />
              </div>

              {/* Content */}
              <div className="relative h-full container-casino flex items-center">
                <div className="max-w-xl">
                  {/* Countdown Timer */}
                  {promo.countdown?.enabled && promo.countdown.endTime && (
                    <div className="mb-4">
                      <CountdownTimer
                        endTime={promo.countdown.endTime}
                        label={promo.countdown.label}
                      />
                    </div>
                  )}

                  {/* Subtitle */}
                  {promo.subtitle && (
                    <p className="text-casino-purple font-bold text-lg mb-2">
                      {promo.subtitle}
                    </p>
                  )}

                  {/* Title */}
                  <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-4 leading-tight">
                    {promo.title}
                  </h1>

                  {/* Description */}
                  {promo.description && (
                    <p className="text-gray-300 text-lg mb-6">{promo.description}</p>
                  )}

                  {/* CTA Button */}
                  <button className="btn btn-gold text-lg px-8 py-3">
                    {promo.ctaText}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Navigation Arrows */}
      {showArrows && promotions.length > 1 && (
        <>
          <button
            onClick={scrollPrev}
            className="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center transition-colors"
          >
            <ChevronLeft className="w-6 h-6 text-white" />
          </button>
          <button
            onClick={scrollNext}
            className="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center transition-colors"
          >
            <ChevronRight className="w-6 h-6 text-white" />
          </button>
        </>
      )}

      {/* Dots Indicator */}
      {showDots && promotions.length > 1 && (
        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex gap-2">
          {promotions.map((_, index) => (
            <button
              key={index}
              onClick={() => scrollTo(index)}
              className={cn(
                'w-3 h-3 rounded-full transition-all',
                selectedIndex === index
                  ? 'bg-white w-8'
                  : 'bg-white/40 hover:bg-white/60'
              )}
            />
          ))}
        </div>
      )}
    </div>
  );
}
