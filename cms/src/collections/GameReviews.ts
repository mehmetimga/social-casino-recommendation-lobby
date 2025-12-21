import type { CollectionConfig } from 'payload'

export const GameReviews: CollectionConfig = {
  slug: 'game-reviews',
  admin: {
    useAsTitle: 'id',
    defaultColumns: ['visitorId', 'game', 'rating', 'status', 'createdAt'],
  },
  access: {
    read: () => true,
    create: () => true,
    update: () => true,
  },
  fields: [
    {
      name: 'visitorId',
      type: 'text',
      required: true,
      admin: {
        description: 'Visitor identifier (from frontend session)',
      },
    },
    {
      name: 'game',
      type: 'relationship',
      relationTo: 'games',
      required: true,
    },
    {
      name: 'rating',
      type: 'number',
      required: true,
      min: 1,
      max: 5,
      admin: {
        description: 'Rating from 1 to 5 stars',
      },
    },
    {
      name: 'reviewText',
      type: 'textarea',
      admin: {
        description: 'Optional review text',
      },
    },
    {
      name: 'status',
      type: 'select',
      defaultValue: 'published',
      options: [
        { label: 'Published', value: 'published' },
        { label: 'Hidden', value: 'hidden' },
        { label: 'Pending', value: 'pending' },
      ],
      admin: {
        position: 'sidebar',
      },
    },
  ],
  hooks: {
    beforeChange: [
      async ({ data, req, operation }) => {
        // Check for existing review from same visitor for same game
        if (operation === 'create' && data?.visitorId && data?.game) {
          const existingReview = await req.payload.find({
            collection: 'game-reviews',
            where: {
              and: [
                { visitorId: { equals: data.visitorId } },
                { game: { equals: data.game } },
              ],
            },
          })

          if (existingReview.docs.length > 0) {
            throw new Error('Visitor has already reviewed this game')
          }
        }
        return data
      },
    ],
  },
}
