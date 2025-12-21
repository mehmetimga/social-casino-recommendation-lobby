import type { Payload } from 'payload'
import { getBannerMediaId } from './media'

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
  bannerIndex: number // Index for banner image
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
    bannerIndex: 0,
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
    bannerIndex: 1,
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
    bannerIndex: 2,
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
    bannerIndex: 3,
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
    bannerIndex: 4,
  },
  {
    slug: 'slots-tournament',
    title: 'Slots Tournament',
    subtitle: '$50,000 Prize Pool Weekly',
    description: 'Compete against other players in our weekly slots tournament. Top 100 players win!',
    ctaText: 'Join Tournament',
    ctaLink: {
      type: 'category',
      category: 'slot',
    },
    countdown: {
      enabled: true,
      label: 'Tournament ends in',
    },
    status: 'live',
    placement: 'featured',
    priority: 75,
    bannerIndex: 5,
  },
  {
    slug: 'table-games-bonus',
    title: 'Table Games Special',
    subtitle: 'Double your wins on Blackjack & Roulette',
    description: 'Play table games this weekend and get 2x points on every win.',
    ctaText: 'Play Now',
    ctaLink: {
      type: 'category',
      category: 'table',
    },
    status: 'live',
    placement: 'featured',
    priority: 65,
    bannerIndex: 6,
  },
  {
    slug: 'instant-wins-promo',
    title: 'Instant Wins Frenzy',
    subtitle: 'Crash games with boosted multipliers',
    description: 'All instant win games have boosted multipliers this week. Higher max wins!',
    ctaText: 'Play Instant',
    ctaLink: {
      type: 'category',
      category: 'instant',
    },
    status: 'live',
    placement: 'featured',
    priority: 55,
    bannerIndex: 7,
  },
]

export async function seedPromotions(payload: Payload): Promise<void> {
  console.log('Seeding promotions...')

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

      // Get banner image from uploaded media
      const imageId = getBannerMediaId(promoData.bannerIndex)

      const createData: Record<string, unknown> = {
        slug: promoData.slug,
        title: promoData.title,
        subtitle: promoData.subtitle,
        description: promoData.description,
        ctaText: promoData.ctaText,
        ctaLink: promoData.ctaLink,
        status: promoData.status,
        placement: promoData.placement,
        priority: promoData.priority,
      }

      if (imageId) {
        createData.image = imageId
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

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await payload.create({
        collection: 'promotions',
        data: createData as any,
      })

      console.log(`Created promotion: ${promoData.title}${imageId ? ' (with banner)' : ''}`)
    } catch (error) {
      console.error(`Failed to create promotion "${promoData.title}":`, error)
    }
  }

  console.log('Promotions seeding completed!')
}

export { promotionsData }
