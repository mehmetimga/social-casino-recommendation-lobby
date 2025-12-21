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
  // Slots
  {
    slug: 'starburst',
    title: 'Starburst',
    provider: 'NetEnt',
    type: 'slot',
    tags: [{ tag: 'classic' }, { tag: 'gems' }, { tag: 'space' }],
    shortDescription: 'A cosmic gem-filled slot with expanding wilds and win both ways.',
    popularityScore: 98,
    minBet: 0.1,
    maxBet: 100,
    rtp: 96.1,
    volatility: 'low',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'book-of-dead',
    title: 'Book of Dead',
    provider: "Play'n GO",
    type: 'slot',
    tags: [{ tag: 'egypt' }, { tag: 'adventure' }, { tag: 'book' }],
    shortDescription: 'Join Rich Wilde on an Egyptian adventure with expanding symbols.',
    popularityScore: 95,
    minBet: 0.1,
    maxBet: 100,
    rtp: 96.21,
    volatility: 'high',
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'gonzo-quest',
    title: "Gonzo's Quest",
    provider: 'NetEnt',
    type: 'slot',
    tags: [{ tag: 'adventure' }, { tag: 'avalanche' }, { tag: 'gold' }],
    shortDescription: 'Avalanche reels with increasing multipliers in the jungle.',
    popularityScore: 92,
    minBet: 0.2,
    maxBet: 50,
    rtp: 95.97,
    volatility: 'medium',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'mega-moolah',
    title: 'Mega Moolah',
    provider: 'Microgaming',
    type: 'slot',
    tags: [{ tag: 'progressive' }, { tag: 'safari' }, { tag: 'jackpot' }],
    shortDescription: 'The legendary progressive jackpot slot with life-changing wins.',
    popularityScore: 90,
    jackpotAmount: 15847293.42,
    minBet: 0.25,
    maxBet: 6.25,
    rtp: 88.12,
    volatility: 'medium',
    badges: ['jackpot', 'hot'],
    status: 'enabled',
  },
  {
    slug: 'sweet-bonanza',
    title: 'Sweet Bonanza',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'candy' }, { tag: 'cluster' }, { tag: 'multiplier' }],
    shortDescription: 'Tumbling wins with multipliers up to 100x in a candy wonderland.',
    popularityScore: 94,
    minBet: 0.2,
    maxBet: 125,
    rtp: 96.51,
    volatility: 'high',
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'gates-of-olympus',
    title: 'Gates of Olympus',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'greek' }, { tag: 'zeus' }, { tag: 'multiplier' }],
    shortDescription: 'Zeus drops multipliers from the heavens in this divine slot.',
    popularityScore: 96,
    minBet: 0.2,
    maxBet: 125,
    rtp: 96.5,
    volatility: 'high',
    badges: ['hot', 'new'],
    status: 'enabled',
  },
  {
    slug: 'wolf-gold',
    title: 'Wolf Gold',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'wildlife' }, { tag: 'jackpot' }, { tag: 'money' }],
    shortDescription: 'Wild west adventure with Money Respin and three jackpots.',
    popularityScore: 88,
    jackpotAmount: 52847.5,
    minBet: 0.25,
    maxBet: 125,
    rtp: 96.01,
    volatility: 'medium',
    badges: ['jackpot'],
    status: 'enabled',
  },
  {
    slug: 'big-bass-bonanza',
    title: 'Big Bass Bonanza',
    provider: 'Pragmatic Play',
    type: 'slot',
    tags: [{ tag: 'fishing' }, { tag: 'money' }, { tag: 'outdoor' }],
    shortDescription: 'Cast your line for big wins with the fisherman bonus.',
    popularityScore: 89,
    minBet: 0.1,
    maxBet: 250,
    rtp: 96.71,
    volatility: 'high',
    badges: ['new'],
    status: 'enabled',
  },
  {
    slug: 'reactoonz',
    title: 'Reactoonz',
    provider: "Play'n GO",
    type: 'slot',
    tags: [{ tag: 'aliens' }, { tag: 'cluster' }, { tag: 'cascade' }],
    shortDescription: 'Cascading cluster pays with quirky alien creatures.',
    popularityScore: 87,
    minBet: 0.2,
    maxBet: 100,
    rtp: 96.51,
    volatility: 'high',
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'dead-or-alive-2',
    title: 'Dead or Alive 2',
    provider: 'NetEnt',
    type: 'slot',
    tags: [{ tag: 'western' }, { tag: 'sticky' }, { tag: 'wild' }],
    shortDescription: 'High voltage Wild West action with sticky wilds.',
    popularityScore: 86,
    minBet: 0.09,
    maxBet: 18,
    rtp: 96.82,
    volatility: 'high',
    badges: ['exclusive'],
    status: 'enabled',
  },

  // Table Games
  {
    slug: 'european-roulette',
    title: 'European Roulette',
    provider: 'Evolution',
    type: 'table',
    tags: [{ tag: 'roulette' }, { tag: 'classic' }],
    shortDescription: 'Classic single-zero roulette with the best odds.',
    popularityScore: 85,
    minBet: 1,
    maxBet: 10000,
    rtp: 97.3,
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'blackjack-classic',
    title: 'Blackjack Classic',
    provider: 'Evolution',
    type: 'table',
    tags: [{ tag: 'blackjack' }, { tag: 'cards' }, { tag: 'classic' }],
    shortDescription: 'The classic 21 card game with standard rules.',
    popularityScore: 91,
    minBet: 1,
    maxBet: 5000,
    rtp: 99.5,
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'baccarat-pro',
    title: 'Baccarat Pro',
    provider: 'NetEnt',
    type: 'table',
    tags: [{ tag: 'baccarat' }, { tag: 'cards' }],
    shortDescription: 'Professional baccarat with side bets and statistics.',
    popularityScore: 78,
    minBet: 1,
    maxBet: 10000,
    rtp: 98.94,
    status: 'enabled',
  },
  {
    slug: 'casino-holdem',
    title: "Casino Hold'em",
    provider: 'Evolution',
    type: 'table',
    tags: [{ tag: 'poker' }, { tag: 'holdem' }, { tag: 'cards' }],
    shortDescription: 'Texas Holdem poker against the dealer.',
    popularityScore: 75,
    minBet: 1,
    maxBet: 1000,
    rtp: 97.84,
    status: 'enabled',
  },

  // Live Casino
  {
    slug: 'live-lightning-roulette',
    title: 'Lightning Roulette',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'roulette' }, { tag: 'lightning' }, { tag: 'multiplier' }],
    shortDescription: 'Electrifying roulette with random multipliers up to 500x.',
    popularityScore: 97,
    minBet: 0.2,
    maxBet: 10000,
    badges: ['hot', 'featured'],
    status: 'enabled',
  },
  {
    slug: 'live-crazy-time',
    title: 'Crazy Time',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'game-show' }, { tag: 'wheel' }, { tag: 'bonus' }],
    shortDescription: 'Ultimate money wheel game show with 4 exciting bonus games.',
    popularityScore: 99,
    minBet: 0.1,
    maxBet: 5000,
    badges: ['hot', 'featured', 'exclusive'],
    status: 'enabled',
  },
  {
    slug: 'live-blackjack-vip',
    title: 'VIP Blackjack',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'blackjack' }, { tag: 'vip' }, { tag: 'high-roller' }],
    shortDescription: 'Premium blackjack experience for high rollers.',
    popularityScore: 82,
    minBet: 50,
    maxBet: 10000,
    badges: ['exclusive'],
    status: 'enabled',
  },
  {
    slug: 'live-monopoly',
    title: 'Monopoly Live',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'game-show' }, { tag: 'monopoly' }, { tag: 'bonus' }],
    shortDescription: 'Money wheel meets Monopoly with 3D bonus rounds.',
    popularityScore: 93,
    minBet: 0.1,
    maxBet: 5000,
    badges: ['hot'],
    status: 'enabled',
  },
  {
    slug: 'live-dream-catcher',
    title: 'Dream Catcher',
    provider: 'Evolution',
    type: 'live',
    tags: [{ tag: 'wheel' }, { tag: 'game-show' }],
    shortDescription: 'Spin the money wheel for multiplied wins.',
    popularityScore: 84,
    minBet: 0.1,
    maxBet: 2500,
    badges: ['featured'],
    status: 'enabled',
  },

  // Instant Win
  {
    slug: 'aviator',
    title: 'Aviator',
    provider: 'Spribe',
    type: 'instant',
    tags: [{ tag: 'crash' }, { tag: 'multiplier' }, { tag: 'social' }],
    shortDescription: 'Cash out before the plane flies away in this crash game.',
    popularityScore: 95,
    minBet: 0.1,
    maxBet: 100,
    rtp: 97.0,
    badges: ['hot', 'new'],
    status: 'enabled',
  },
  {
    slug: 'plinko',
    title: 'Plinko',
    provider: 'BGaming',
    type: 'instant',
    tags: [{ tag: 'plinko' }, { tag: 'ball' }, { tag: 'instant' }],
    shortDescription: 'Drop the ball and watch it bounce to multiplied wins.',
    popularityScore: 83,
    minBet: 0.1,
    maxBet: 100,
    rtp: 99.0,
    badges: ['new'],
    status: 'enabled',
  },
  {
    slug: 'mines',
    title: 'Mines',
    provider: 'Spribe',
    type: 'instant',
    tags: [{ tag: 'mines' }, { tag: 'strategy' }, { tag: 'instant' }],
    shortDescription: 'Reveal gems and avoid mines for increasing multipliers.',
    popularityScore: 81,
    minBet: 0.1,
    maxBet: 100,
    rtp: 97.0,
    badges: ['featured'],
    status: 'enabled',
  },
  {
    slug: 'dice',
    title: 'Classic Dice',
    provider: 'BGaming',
    type: 'instant',
    tags: [{ tag: 'dice' }, { tag: 'prediction' }, { tag: 'simple' }],
    shortDescription: 'Predict the dice roll outcome with adjustable odds.',
    popularityScore: 72,
    minBet: 0.1,
    maxBet: 100,
    rtp: 99.0,
    status: 'enabled',
  },
  {
    slug: 'keno',
    title: 'Keno',
    provider: 'Microgaming',
    type: 'instant',
    tags: [{ tag: 'keno' }, { tag: 'lottery' }, { tag: 'numbers' }],
    shortDescription: 'Pick your numbers and watch the draw.',
    popularityScore: 68,
    minBet: 0.1,
    maxBet: 50,
    rtp: 94.9,
    status: 'enabled',
  },
]

export async function seedGames(payload: Payload): Promise<void> {
  console.log('Seeding games...')

  for (const gameData of gamesData) {
    try {
      // Check if game already exists
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
