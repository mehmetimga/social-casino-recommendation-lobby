import type { Block } from 'payload'

export const SuggestedGamesSection: Block = {
  slug: 'suggested-games-section',
  labels: {
    singular: 'Suggested Games Section',
    plural: 'Suggested Games Sections',
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      defaultValue: 'Recommended for You',
      required: true,
    },
    {
      name: 'subtitle',
      type: 'text',
      admin: {
        description: 'Optional subtitle text',
      },
    },
    {
      name: 'mode',
      type: 'select',
      required: true,
      defaultValue: 'personalized',
      options: [
        { label: 'Manual Selection', value: 'manual' },
        { label: 'Personalized (AI)', value: 'personalized' },
      ],
    },
    {
      name: 'manualGames',
      type: 'relationship',
      relationTo: 'games',
      hasMany: true,
      admin: {
        description: 'Manually select games to display',
        condition: (_, siblingData) => siblingData?.mode === 'manual',
      },
    },
    {
      name: 'placement',
      type: 'text',
      defaultValue: 'suggested',
      admin: {
        description: 'Placement identifier for recommendation API',
        condition: (_, siblingData) => siblingData?.mode === 'personalized',
      },
    },
    {
      name: 'limit',
      type: 'number',
      defaultValue: 10,
      admin: {
        description: 'Maximum number of games to display',
      },
    },
    {
      name: 'fallbackToPopular',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show popular games if no personalized recommendations available',
        condition: (_, siblingData) => siblingData?.mode === 'personalized',
      },
    },
    {
      name: 'showScrollButtons',
      type: 'checkbox',
      defaultValue: true,
    },
    {
      name: 'cardSize',
      type: 'select',
      defaultValue: 'medium',
      options: [
        { label: 'Small', value: 'small' },
        { label: 'Medium', value: 'medium' },
        { label: 'Large', value: 'large' },
      ],
    },
  ],
}
