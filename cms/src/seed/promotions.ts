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
    slug: 'social-casino-welcome',
    title: 'Welcome to Social Casino',
    subtitle: 'Your Ultimate Gaming Destination',
    description: 'Experience the thrill of casino gaming with free coins daily. Play slots, table games, and more!',
    ctaText: 'Play Now',
    ctaLink: {
      type: 'url',
      url: '/games',
    },
    status: 'live',
    placement: 'hero',
    priority: 100,
    bannerIndex: 0,
  },
  {
    slug: '12-days-of-holidays',
    title: '12 Days of Holidays',
    subtitle: 'Unwrap Daily Rewards & Surprises',
    description: 'Celebrate the season with 12 days of exclusive bonuses, free spins, and special prizes!',
    ctaText: 'Claim Gift',
    ctaLink: {
      type: 'url',
      url: '/promotions/holidays',
    },
    countdown: {
      enabled: true,
      label: 'Holiday event ends in',
    },
    status: 'live',
    placement: 'hero',
    priority: 95,
    bannerIndex: 1,
  },
  {
    slug: 'mega-ball',
    title: 'Mega Ball',
    subtitle: 'Multipliers Up to 1,000,000x',
    description: 'Experience the excitement of Mega Ball - the revolutionary live game show with massive multipliers!',
    ctaText: 'Play Mega Ball',
    ctaLink: {
      type: 'category',
      category: 'live',
    },
    status: 'live',
    placement: 'hero',
    priority: 90,
    bannerIndex: 2,
  },
  {
    slug: 'rakin-jackpot',
    title: "Rakin' Jackpot",
    subtitle: 'Progressive Jackpots Growing Every Second',
    description: 'Hit the ultimate jackpot! Watch the prize pool grow and take your shot at life-changing wins.',
    ctaText: 'Chase Jackpot',
    ctaLink: {
      type: 'category',
      category: 'slot',
    },
    countdown: {
      enabled: true,
      label: 'Jackpot must drop by',
    },
    status: 'live',
    placement: 'hero',
    priority: 85,
    bannerIndex: 3,
  },
  {
    slug: 'live-dealer',
    title: 'Live Dealer Games',
    subtitle: 'Real Dealers, Real Action, Real Fun',
    description: 'Join our professional live dealers for an authentic casino experience from the comfort of your home.',
    ctaText: 'Go Live',
    ctaLink: {
      type: 'category',
      category: 'live',
    },
    status: 'live',
    placement: 'hero',
    priority: 80,
    bannerIndex: 4,
  },
  {
    slug: 'lightning-roulette',
    title: 'Lightning Roulette',
    subtitle: 'Electrifying Multipliers Every Round',
    description: 'Classic roulette with a twist! Lightning strikes random numbers for multiplied payouts up to 500x.',
    ctaText: 'Spin Now',
    ctaLink: {
      type: 'category',
      category: 'live',
    },
    status: 'live',
    placement: 'hero',
    priority: 75,
    bannerIndex: 5,
  },
  {
    slug: 'blackjack-promo',
    title: 'Blackjack',
    subtitle: 'Beat the Dealer & Win Big',
    description: 'Test your skills at the classic card game. Multiple variants available with exciting side bets!',
    ctaText: 'Deal Me In',
    ctaLink: {
      type: 'category',
      category: 'table',
    },
    status: 'live',
    placement: 'hero',
    priority: 70,
    bannerIndex: 6,
  },
  {
    slug: 'lions-wolf-bonus',
    title: "Lion's Wolf Bonus",
    subtitle: 'Wild Wins Await in the Savanna',
    description: 'Unleash the power of the wild! Trigger bonus rounds for free spins and expanding wilds.',
    ctaText: 'Play Now',
    ctaLink: {
      type: 'category',
      category: 'slot',
    },
    status: 'live',
    placement: 'hero',
    priority: 65,
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
