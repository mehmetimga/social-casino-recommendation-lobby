import { getPayload } from 'payload'
import config from './src/payload.config'
import { seed } from './src/seed'

async function runSeed() {
  try {
    console.log('Initializing Payload...')
    const payload = await getPayload({ config })

    console.log('Running seed...')
    await seed(payload)

    console.log('Seed completed successfully!')
    process.exit(0)
  } catch (error) {
    console.error('Error running seed:', error)
    process.exit(1)
  }
}

runSeed()
