import type { Payload } from 'payload'
import { seedGames } from './games'
import { seedPromotions } from './promotions'
import { seedLobbyLayout } from './lobby-layout'

export async function seed(payload: Payload): Promise<void> {
  console.log('Starting database seeding...')

  try {
    await seedGames(payload)
    await seedPromotions(payload)
    await seedLobbyLayout(payload)

    console.log('Database seeding completed successfully!')
  } catch (error) {
    console.error('Error during seeding:', error)
    throw error
  }
}
