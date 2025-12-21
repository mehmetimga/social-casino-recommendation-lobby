import type { Payload } from 'payload'

export async function seedLobbyLayout(payload: Payload): Promise<void> {
  console.log('Seeding lobby layout...')

  try {
    // Check if default layout already exists
    const existing = await payload.find({
      collection: 'lobby-layouts',
      where: {
        slug: { equals: 'web-default' },
      },
    })

    if (existing.docs.length > 0) {
      console.log('Default lobby layout already exists, skipping...')
      return
    }

    // Get hero promotions for carousel
    const heroPromotions = await payload.find({
      collection: 'promotions',
      where: {
        placement: { equals: 'hero' },
        status: { equals: 'live' },
      },
      sort: '-priority',
    })

    // Get banner promotion
    const bannerPromotions = await payload.find({
      collection: 'promotions',
      where: {
        placement: { equals: 'banner' },
        status: { equals: 'live' },
      },
      sort: '-priority',
      limit: 1,
    })

    // Build sections
    const sections: Record<string, unknown>[] = []

    // Hero Carousel Section
    if (heroPromotions.docs.length > 0) {
      sections.push({
        blockType: 'carousel-section',
        promotions: heroPromotions.docs.map((p) => p.id),
        autoPlay: true,
        autoPlayInterval: 5000,
        showDots: true,
        showArrows: true,
        height: 'large',
      })
    }

    // Suggested Games Section (Personalized)
    sections.push({
      blockType: 'suggested-games-section',
      title: 'Recommended for You',
      subtitle: 'Games picked just for you',
      mode: 'personalized',
      placement: 'homepage-suggested',
      limit: 10,
      fallbackToPopular: true,
      showScrollButtons: true,
      cardSize: 'medium',
    })

    // Popular Slots Grid
    sections.push({
      blockType: 'game-grid-section',
      title: 'Popular Slots',
      subtitle: 'Top rated by our players',
      filterType: 'type',
      gameType: 'slot',
      limit: 12,
      columns: '6',
      showMore: true,
      cardSize: 'medium',
      showJackpot: true,
      showProvider: true,
    })

    // Banner Section
    if (bannerPromotions.docs.length > 0) {
      sections.push({
        blockType: 'banner-section',
        promotion: bannerPromotions.docs[0].id,
        size: 'large',
        alignment: 'center',
        showCountdown: true,
        rounded: true,
        marginTop: 32,
        marginBottom: 32,
      })
    }

    // Live Casino Grid
    sections.push({
      blockType: 'game-grid-section',
      title: 'Live Casino',
      subtitle: 'Real dealers, real action',
      filterType: 'type',
      gameType: 'live',
      limit: 6,
      columns: '6',
      showMore: true,
      cardSize: 'medium',
      showJackpot: false,
      showProvider: true,
    })

    // Jackpot Games
    sections.push({
      blockType: 'game-grid-section',
      title: 'Jackpot Games',
      subtitle: 'Win big today',
      filterType: 'jackpot',
      limit: 6,
      columns: '6',
      showMore: true,
      cardSize: 'medium',
      showJackpot: true,
      showProvider: true,
    })

    // New Games Section
    sections.push({
      blockType: 'suggested-games-section',
      title: 'New Arrivals',
      subtitle: 'Fresh games added this week',
      mode: 'manual',
      limit: 8,
      showScrollButtons: true,
      cardSize: 'medium',
    })

    // Table Games Grid
    sections.push({
      blockType: 'game-grid-section',
      title: 'Table Games',
      subtitle: 'Classic casino favorites',
      filterType: 'type',
      gameType: 'table',
      limit: 6,
      columns: '6',
      showMore: true,
      cardSize: 'medium',
      showJackpot: false,
      showProvider: true,
    })

    // Instant Win Games
    sections.push({
      blockType: 'game-grid-section',
      title: 'Instant Win',
      subtitle: 'Quick games, instant fun',
      filterType: 'type',
      gameType: 'instant',
      limit: 6,
      columns: '6',
      showMore: true,
      cardSize: 'medium',
      showJackpot: false,
      showProvider: true,
    })

    // Create the layout
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await payload.create({
      collection: 'lobby-layouts',
      data: {
        slug: 'web-default',
        name: 'Web Default Layout',
        platform: 'web',
        isDefault: true,
        sections,
      } as any,
    })

    console.log('Created default lobby layout')
  } catch (error) {
    console.error('Failed to create lobby layout:', error)
  }

  console.log('Lobby layout seeding completed!')
}
