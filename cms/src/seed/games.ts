import type { Payload } from 'payload'
import { getGameMediaId, gameImageMap } from './media'

interface GameSeedData {
  slug: string
  title: string
  provider: string
  type: 'slot' | 'table' | 'live' | 'instant'
  tags: { tag: string }[]
  shortDescription: string
  popularityScore: number
  jackpotAmount?: number
  minBet: number
  maxBet: number
  rtp?: number
  volatility?: 'low' | 'medium' | 'high'
  badges?: ('new' | 'exclusive' | 'hot' | 'jackpot' | 'featured')[]
  status: 'enabled' | 'disabled'
}

const gamesData: GameSeedData[] = [
  // AUTO-GENERATED GAMES FROM AVAILABLE IMAGES (30 games)
  {
    slug: 'legendary-castle',
    title: 'Legendary Castle',
    provider: 'Push Gaming',
    type: 'live',
    tags: [{ tag: 'classic' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Legendary Castle.',
    popularityScore: 87,
    minBet: 0.2,
    maxBet: 200,
    rtp: 96.25,
    volatility: 'medium',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'divine-temple',
    title: 'Divine Temple',
    provider: 'Push Gaming',
    type: 'slot',
    tags: [{ tag: 'jackpot' }, { tag: 'multiplier' }],
    shortDescription: 'Experience thrilling gameplay with Divine Temple.',
    popularityScore: 71,
    minBet: 0.2,
    maxBet: 1000,
    rtp: 97.16,
    volatility: 'low',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'magic-fortune',
    title: 'Magic Fortune',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'classic' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Magic Fortune.',
    popularityScore: 96,
    minBet: 1.0,
    maxBet: 500,
    rtp: 94.76,
    volatility: 'high',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'ruby-dynasty',
    title: 'Ruby Dynasty',
    provider: 'Red Tiger',
    type: 'live',
    tags: [{ tag: 'adventure' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Ruby Dynasty.',
    popularityScore: 92,
    minBet: 0.1,
    maxBet: 500,
    rtp: 97.17,
    volatility: 'low',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'blazing-carnival',
    title: 'Blazing Carnival',
    provider: 'Microgaming',
    type: 'slot',
    tags: [{ tag: 'classic' }, { tag: 'multiplier' }],
    shortDescription: 'Experience thrilling gameplay with Blazing Carnival.',
    popularityScore: 95,
    minBet: 0.2,
    maxBet: 100,
    rtp: 97.61,
    volatility: 'high',
    badges: ['exclusive'],
    status: 'enabled',
  },
  {
    slug: 'magic-lion',
    title: 'Magic Lion',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'free-spins' }, { tag: 'classic' }],
    shortDescription: 'Experience thrilling gameplay with Magic Lion.',
    popularityScore: 85,
    minBet: 0.5,
    maxBet: 100,
    rtp: 95.3,
    volatility: 'high',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'ruby-olympus',
    title: 'Ruby Olympus',
    provider: 'Microgaming',
    type: 'live',
    tags: [{ tag: 'classic' }, { tag: 'multiplier' }],
    shortDescription: 'Experience thrilling gameplay with Ruby Olympus.',
    popularityScore: 72,
    minBet: 1.0,
    maxBet: 200,
    rtp: 94.57,
    volatility: 'low',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'crystal-vikings',
    title: 'Crystal Vikings',
    provider: 'Red Tiger',
    type: 'table',
    tags: [{ tag: 'bonus' }, { tag: 'free-spins' }],
    shortDescription: 'Experience thrilling gameplay with Crystal Vikings.',
    popularityScore: 89,
    minBet: 1.0,
    maxBet: 1000,
    rtp: 99.33,
    volatility: 'high',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'emerald-kingdom',
    title: 'Emerald Kingdom',
    provider: 'Pragmatic Play',
    type: 'live',
    tags: [{ tag: 'classic' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Emerald Kingdom.',
    popularityScore: 89,
    minBet: 0.5,
    maxBet: 500,
    rtp: 97.31,
    volatility: 'high',
    badges: ['new'],
    status: 'enabled',
  },
  {
    slug: 'ancient-dynasty',
    title: 'Ancient Dynasty',
    provider: 'Evolution',
    type: 'slot',
    tags: [{ tag: 'adventure' }, { tag: 'multiplier' }],
    shortDescription: 'Experience thrilling gameplay with Ancient Dynasty.',
    popularityScore: 79,
    minBet: 0.2,
    maxBet: 200,
    rtp: 95.39,
    volatility: 'high',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'ancient-gems',
    title: 'Ancient Gems',
    provider: 'Push Gaming',
    type: 'slot',
    tags: [{ tag: 'jackpot' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Ancient Gems.',
    popularityScore: 88,
    minBet: 0.1,
    maxBet: 200,
    rtp: 96.75,
    volatility: 'high',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'cosmic-dragons',
    title: 'Cosmic Dragons',
    provider: 'Microgaming',
    type: 'slot',
    tags: [{ tag: 'jackpot' }, { tag: 'classic' }],
    shortDescription: 'Experience thrilling gameplay with Cosmic Dragons.',
    popularityScore: 78,
    minBet: 0.5,
    maxBet: 100,
    rtp: 94.56,
    volatility: 'high',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'golden-festival',
    title: 'Golden Festival',
    provider: 'Microgaming',
    type: 'table',
    tags: [{ tag: 'bonus' }, { tag: 'adventure' }],
    shortDescription: 'Experience thrilling gameplay with Golden Festival.',
    popularityScore: 72,
    minBet: 0.2,
    maxBet: 100,
    rtp: 97.45,
    volatility: 'high',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'sacred-dynasty',
    title: 'Sacred Dynasty',
    provider: 'Microgaming',
    type: 'slot',
    tags: [{ tag: 'jackpot' }, { tag: 'adventure' }],
    shortDescription: 'Experience thrilling gameplay with Sacred Dynasty.',
    popularityScore: 99,
    minBet: 0.2,
    maxBet: 200,
    rtp: 97.97,
    volatility: 'high',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'silver-dynasty',
    title: 'Silver Dynasty',
    provider: 'Evolution',
    type: 'slot',
    tags: [{ tag: 'classic' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Silver Dynasty.',
    popularityScore: 82,
    minBet: 0.5,
    maxBet: 1000,
    rtp: 97.25,
    volatility: 'low',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'royal-phoenix',
    title: 'Royal Phoenix',
    provider: 'Push Gaming',
    type: 'table',
    tags: [{ tag: 'free-spins' }, { tag: 'multiplier' }],
    shortDescription: 'Experience thrilling gameplay with Royal Phoenix.',
    popularityScore: 84,
    minBet: 0.5,
    maxBet: 200,
    rtp: 98.41,
    volatility: 'low',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'mystic-olympus',
    title: 'Mystic Olympus',
    provider: 'Microgaming',
    type: 'slot',
    tags: [{ tag: 'classic' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Mystic Olympus.',
    popularityScore: 78,
    minBet: 0.2,
    maxBet: 500,
    rtp: 97.23,
    volatility: 'high',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'bronze-sphinx',
    title: 'Bronze Sphinx',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'free-spins' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Bronze Sphinx.',
    popularityScore: 70,
    minBet: 0.2,
    maxBet: 1000,
    rtp: 97.05,
    volatility: 'low',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'ancient-stars',
    title: 'Ancient Stars',
    provider: 'Red Tiger',
    type: 'slot',
    tags: [{ tag: 'jackpot' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Ancient Stars.',
    popularityScore: 78,
    minBet: 1.0,
    maxBet: 1000,
    rtp: 95.12,
    volatility: 'medium',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'emerald-riches',
    title: 'Emerald Riches',
    provider: 'Push Gaming',
    type: 'table',
    tags: [{ tag: 'jackpot' }, { tag: 'classic' }],
    shortDescription: 'Experience thrilling gameplay with Emerald Riches.',
    popularityScore: 87,
    minBet: 0.2,
    maxBet: 200,
    rtp: 97.55,
    volatility: 'medium',
    badges: ['exclusive'],
    status: 'enabled',
  },
  {
    slug: 'sapphire-ocean',
    title: 'Sapphire Ocean',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'multiplier' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Sapphire Ocean.',
    popularityScore: 88,
    minBet: 1.0,
    maxBet: 500,
    rtp: 94.74,
    volatility: 'high',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'crystal-pyramid',
    title: 'Crystal Pyramid',
    provider: 'NetEnt',
    type: 'live',
    tags: [{ tag: 'adventure' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Crystal Pyramid.',
    popularityScore: 99,
    minBet: 0.2,
    maxBet: 100,
    rtp: 96.37,
    volatility: 'medium',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'magic-vikings',
    title: 'Magic Vikings',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'multiplier' }, { tag: 'jackpot' }],
    shortDescription: 'Experience thrilling gameplay with Magic Vikings.',
    popularityScore: 81,
    minBet: 1.0,
    maxBet: 100,
    rtp: 96.0,
    volatility: 'low',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'legendary-empire',
    title: 'Legendary Empire',
    provider: 'Red Tiger',
    type: 'slot',
    tags: [{ tag: 'free-spins' }, { tag: 'adventure' }],
    shortDescription: 'Experience thrilling gameplay with Legendary Empire.',
    popularityScore: 77,
    minBet: 0.2,
    maxBet: 100,
    rtp: 95.82,
    volatility: 'high',
    badges: ['exclusive'],
    status: 'enabled',
  },
  {
    slug: 'super-treasure',
    title: 'Super Treasure',
    provider: 'Red Tiger',
    type: 'live',
    tags: [{ tag: 'jackpot' }, { tag: 'adventure' }],
    shortDescription: 'Experience thrilling gameplay with Super Treasure.',
    popularityScore: 94,
    minBet: 0.5,
    maxBet: 100,
    rtp: 97.55,
    volatility: 'high',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'ruby-dragons',
    title: 'Ruby Dragons',
    provider: 'Red Tiger',
    type: 'live',
    tags: [{ tag: 'free-spins' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Ruby Dragons.',
    popularityScore: 87,
    minBet: 0.1,
    maxBet: 500,
    rtp: 95.42,
    volatility: 'medium',
    badges: ['new'],
    status: 'enabled',
  },
  {
    slug: 'diamond-stars',
    title: 'Diamond Stars',
    provider: 'NetEnt',
    type: 'slot',
    tags: [{ tag: 'multiplier' }, { tag: 'classic' }],
    shortDescription: 'Experience thrilling gameplay with Diamond Stars.',
    popularityScore: 84,
    minBet: 0.5,
    maxBet: 1000,
    rtp: 97.21,
    volatility: 'low',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'diamond-castle',
    title: 'Diamond Castle',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'free-spins' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Diamond Castle.',
    popularityScore: 78,
    minBet: 0.5,
    maxBet: 500,
    rtp: 97.12,
    volatility: 'low',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'platinum-dragons',
    title: 'Platinum Dragons',
    provider: 'Red Tiger',
    type: 'live',
    tags: [{ tag: 'multiplier' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Platinum Dragons.',
    popularityScore: 87,
    minBet: 0.5,
    maxBet: 500,
    rtp: 95.03,
    volatility: 'high',
    badges: [],
    status: 'enabled',
  },
  {
    slug: 'royal-festival',
    title: 'Royal Festival',
    provider: 'Play\'n GO',
    type: 'table',
    tags: [{ tag: 'classic' }, { tag: 'bonus' }],
    shortDescription: 'Experience thrilling gameplay with Royal Festival.',
    popularityScore: 99,
    minBet: 0.1,
    maxBet: 100,
    rtp: 97.52,
    volatility: 'high',
    badges: [],
    status: 'enabled',
  },
]

export async function seedGames(payload: Payload, reset = false): Promise<void> {
  console.log('Seeding games...')

  // Delete all existing games if reset is true
  if (reset) {
    console.log('Resetting games collection...')
    const allGames = await payload.find({
      collection: 'games',
      limit: 1000,
    })

    for (const game of allGames.docs) {
      await payload.delete({
        collection: 'games',
        id: game.id,
      })
    }
    console.log(`Deleted ${allGames.docs.length} existing games`)
  }

  for (const gameData of gamesData) {
    try {
      // Check if game already exists (skip check if reset is true)
      if (!reset) {
        const existing = await payload.find({
          collection: 'games',
          where: {
            slug: { equals: gameData.slug },
          },
        })

        if (existing.docs.length > 0) {
          console.log(`Game "${gameData.title}" already exists, skipping...`)
          continue
        }
      }

      // Get thumbnail from uploaded media
      const thumbnailId = getGameMediaId(gameData.slug)

      // Create game
      const createData: Record<string, unknown> = {
        ...gameData,
      }

      if (thumbnailId) {
        createData.thumbnail = thumbnailId
      }

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await payload.create({
        collection: 'games',
        data: createData as any,
      })

      console.log(`Created game: ${gameData.title}${thumbnailId ? ' (with image)' : ''}`)
    } catch (error) {
      console.error(`Failed to create game "${gameData.title}":`, error)
    }
  }

  console.log('Games seeding completed!')
}

export { gamesData, gameImageMap }
