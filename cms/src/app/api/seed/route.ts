import { getPayload } from 'payload'
import config from '@payload-config'
import { seed } from '../../../seed'

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => ({}))
    const reset = body?.reset === true

    const payload = await getPayload({ config })
    await seed(payload, reset)

    return Response.json({
      success: true,
      message: `Database seeded successfully${reset ? ' (with reset)' : ''}`
    })
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
