import type { Payload } from 'payload'
import { seedMedia } from './media'
import { seedGames } from './games'
import { seedPromotions } from './promotions'
import { seedLobbyLayout } from './lobby-layout'

export async function seed(payload: Payload): Promise<void> {
  console.log('Starting database seeding...')

  try {
    // First seed media (uploads images)
    await seedMedia(payload)

    // Then seed games and promotions (which reference the media)
    await seedGames(payload)
    await seedPromotions(payload)

    // Finally seed the lobby layout (which references games and promotions)
    await seedLobbyLayout(payload)

    console.log('Database seeding completed successfully!')
  } catch (error) {
    console.error('Error during seeding:', error)
    throw error
  }
}
