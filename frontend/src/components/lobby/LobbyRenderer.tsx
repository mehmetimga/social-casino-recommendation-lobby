import { useQuery } from '@tanstack/react-query';
import { cmsApi } from '../../api/cms';
import { LobbyLayout, LobbySectionBlock } from '../../types/lobby';
import { Game } from '../../types/game';
import { Promotion } from '../../types/promotion';
import HeroCarousel from './HeroCarousel';
import GameGrid from './GameGrid';
import PromotionBanner from './PromotionBanner';
import SuggestedGames from './SuggestedGames';

interface LobbyRendererProps {
  layoutSlug?: string;
}

export default function LobbyRenderer({ layoutSlug = 'web-default' }: LobbyRendererProps) {
  const { data: layout, isLoading, error } = useQuery({
    queryKey: ['lobby-layout', layoutSlug],
    queryFn: () => cmsApi.getLobbyLayout(layoutSlug),
  });

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="h-[500px] bg-white/5 rounded-lg mb-8" />
        <div className="container-casino">
          <div className="h-8 w-40 bg-white/10 rounded mb-4" />
          <div className="grid grid-cols-6 gap-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="aspect-[4/5] bg-white/10 rounded-lg" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (error || !layout) {
    return (
      <div className="container-casino py-12 text-center">
        <p className="text-gray-400">Failed to load lobby layout</p>
      </div>
    );
  }

  return (
    <div>
      {layout.sections.map((section, index) => (
        <SectionRenderer
          key={`${section.blockType}-${index}`}
          section={section}
        />
      ))}
    </div>
  );
}

interface SectionRendererProps {
  section: LobbySectionBlock;
}

function SectionRenderer({ section }: SectionRendererProps) {
  switch (section.blockType) {
    case 'carousel-section':
      return <CarouselSectionRenderer section={section} />;
    case 'suggested-games-section':
      return <SuggestedGames section={section} />;
    case 'game-grid-section':
      return <GameGridSectionRenderer section={section} />;
    case 'banner-section':
      return <BannerSectionRenderer section={section} />;
    default:
      return null;
  }
}

function CarouselSectionRenderer({ section }: { section: LobbySectionBlock & { blockType: 'carousel-section' } }) {
  const { data: promotions, isLoading } = useQuery({
    queryKey: ['promotions', 'hero'],
    queryFn: () => cmsApi.getPromotions('hero'),
  });

  if (isLoading || !promotions) {
    return <div className="h-[500px] bg-white/5 animate-pulse" />;
  }

  // Use promotions from section if available, otherwise fetch from API
  const promoList = (section.promotions as Promotion[]) || promotions;

  return (
    <HeroCarousel
      promotions={promoList}
      autoPlay={section.autoPlay}
      autoPlayInterval={section.autoPlayInterval}
      showDots={section.showDots}
      showArrows={section.showArrows}
      height={section.height}
    />
  );
}

function GameGridSectionRenderer({
  section,
}: {
  section: LobbySectionBlock & { blockType: 'game-grid-section' };
}) {
  const fetchGames = async () => {
    switch (section.filterType) {
      case 'manual':
        // Manual games should already be populated
        return (section.manualGames as Game[]) || [];
      case 'type':
        return section.gameType ? cmsApi.getGamesByType(section.gameType as any, section.limit) : [];
      case 'tag':
        return section.tag ? cmsApi.getGamesByBadge(section.tag, section.limit) : [];
      case 'popular':
        return cmsApi.getPopularGames(section.limit);
      case 'new':
        return cmsApi.getNewGames(section.limit);
      case 'jackpot':
        return cmsApi.getJackpotGames(section.limit);
      case 'featured':
        return cmsApi.getGamesByBadge('featured', section.limit);
      default:
        return cmsApi.getPopularGames(section.limit);
    }
  };

  const { data: games, isLoading } = useQuery({
    queryKey: ['games', section.filterType, section.gameType, section.tag, section.limit],
    queryFn: fetchGames,
  });

  return (
    <div className="container-casino">
      <GameGrid
        title={section.title}
        subtitle={section.subtitle}
        games={games || []}
        columns={parseInt(section.columns)}
        showMore={section.showMore}
        moreLink={section.moreLink}
        cardSize={section.cardSize}
        showJackpot={section.showJackpot}
        showProvider={section.showProvider}
        isLoading={isLoading}
      />
    </div>
  );
}

function BannerSectionRenderer({ section }: { section: LobbySectionBlock & { blockType: 'banner-section' } }) {
  const { data: promotions } = useQuery({
    queryKey: ['promotions', 'banner'],
    queryFn: () => cmsApi.getPromotions('banner'),
  });

  // Use section promotion if populated, otherwise use first banner promotion
  const promotion = (section.promotion as Promotion) || promotions?.[0];

  if (!promotion) {
    return null;
  }

  return (
    <div className="container-casino">
      <PromotionBanner
        promotion={promotion}
        size={section.size}
        alignment={section.alignment}
        showCountdown={section.showCountdown}
        rounded={section.rounded}
        marginTop={section.marginTop}
        marginBottom={section.marginBottom}
      />
    </div>
  );
}
