import { getPayload } from 'payload'
import config from '@payload-config'
import { seed } from '../../../seed'

export async function POST() {
  try {
    const payload = await getPayload({ config })
    await seed(payload)

    return Response.json({ success: true, message: 'Database seeded successfully' })
  } catch (error) {
    console.error('Seed error:', error)
    return Response.json(
      { success: false, message: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    )
  }
}

export async function GET() {
  return Response.json({
    message: 'Use POST to seed the database',
    endpoints: {
      seed: 'POST /api/seed',
    },
  })
}
