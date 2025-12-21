import type { Payload } from 'payload'

interface PromotionSeedData {
  slug: string
  title: string
  subtitle?: string
  description?: string
  ctaText: string
  ctaLink: {
    type: 'game' | 'url' | 'category'
    url?: string
    category?: 'slot' | 'table' | 'live' | 'instant'
  }
  countdown?: {
    enabled: boolean
    label?: string
  }
  status: 'draft' | 'live'
  placement: 'hero' | 'banner' | 'featured'
  priority: number
}

const promotionsData: PromotionSeedData[] = [
  {
    slug: 'welcome-bonus',
    title: 'Welcome Bonus',
    subtitle: 'Get 100% match up to $500 + 100 Free Spins',
    description: 'Start your journey with a massive welcome package. Make your first deposit and we will double it!',
    ctaText: 'Claim Now',
    ctaLink: {
      type: 'url',
      url: '/signup',
    },
    status: 'live',
    placement: 'hero',
    priority: 100,
  },
  {
    slug: 'live-casino-promo',
    title: 'Live Casino Cashback',
    subtitle: '10% weekly cashback on Live Casino losses',
    description: 'Play your favorite live dealer games risk-free. Get 10% back on your weekly losses.',
    ctaText: 'Play Live',
    ctaLink: {
      type: 'category',
      category: 'live',
    },
    status: 'live',
    placement: 'hero',
    priority: 90,
  },
  {
    slug: 'jackpot-mania',
    title: 'Jackpot Mania',
    subtitle: 'Over $15 Million in Progressive Jackpots',
    description: 'Try your luck on our progressive jackpot slots. Life-changing wins are just a spin away!',
    ctaText: 'Spin Now',
    ctaLink: {
      type: 'category',
      category: 'slot',
    },
    countdown: {
      enabled: true,
      label: 'Jackpot drops in',
    },
    status: 'live',
    placement: 'hero',
    priority: 80,
  },
  {
    slug: 'weekend-reload',
    title: 'Weekend Reload',
    subtitle: '50% Bonus Every Weekend',
    description: 'Reload your account every weekend and get a 50% bonus up to $200.',
    ctaText: 'Reload Now',
    ctaLink: {
      type: 'url',
      url: '/deposit',
    },
    status: 'live',
    placement: 'banner',
    priority: 70,
  },
  {
    slug: 'vip-program',
    title: 'VIP Program',
    subtitle: 'Exclusive rewards for loyal players',
    description: 'Join our VIP program and enjoy exclusive bonuses, faster withdrawals, and a personal account manager.',
    ctaText: 'Learn More',
    ctaLink: {
      type: 'url',
      url: '/vip',
    },
    status: 'live',
    placement: 'banner',
    priority: 60,
  },
]

export async function seedPromotions(payload: Payload): Promise<void> {
  console.log('Seeding promotions...')

  // Get placeholder media
  let placeholderMedia
  try {
    const existingMedia = await payload.find({
      collection: 'media',
      limit: 1,
    })

    if (existingMedia.docs.length > 0) {
      placeholderMedia = existingMedia.docs[0]
    }
  } catch (error) {
    console.log('No media found for promotions')
  }

  for (const promoData of promotionsData) {
    try {
      // Check if promotion already exists
      const existing = await payload.find({
        collection: 'promotions',
        where: {
          slug: { equals: promoData.slug },
        },
      })

      if (existing.docs.length > 0) {
        console.log(`Promotion "${promoData.title}" already exists, skipping...`)
        continue
      }

      const createData: Record<string, unknown> = {
        ...promoData,
      }

      if (placeholderMedia) {
        createData.image = placeholderMedia.id
      }

      // Set countdown end time to 7 days from now if enabled
      if (promoData.countdown?.enabled) {
        const endTime = new Date()
        endTime.setDate(endTime.getDate() + 7)
        createData.countdown = {
          ...promoData.countdown,
          endTime: endTime.toISOString(),
        }
      }

      await payload.create({
        collection: 'promotions',
        data: createData as Parameters<typeof payload.create>[0]['data'],
      })

      console.log(`Created promotion: ${promoData.title}`)
    } catch (error) {
      console.error(`Failed to create promotion "${promoData.title}":`, error)
    }
  }

  console.log('Promotions seeding completed!')
}

export { promotionsData }
