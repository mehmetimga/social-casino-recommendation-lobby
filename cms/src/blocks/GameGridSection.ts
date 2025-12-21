import type { Block } from 'payload'

export const GameGridSection: Block = {
  slug: 'game-grid-section',
  labels: {
    singular: 'Game Grid Section',
    plural: 'Game Grid Sections',
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      required: true,
    },
    {
      name: 'subtitle',
      type: 'text',
    },
    {
      name: 'filterType',
      type: 'select',
      required: true,
      defaultValue: 'popular',
      options: [
        { label: 'Manual Selection', value: 'manual' },
        { label: 'By Game Type', value: 'type' },
        { label: 'By Tag', value: 'tag' },
        { label: 'Popular', value: 'popular' },
        { label: 'New Games', value: 'new' },
        { label: 'Jackpot Games', value: 'jackpot' },
        { label: 'Featured', value: 'featured' },
      ],
    },
    {
      name: 'manualGames',
      type: 'relationship',
      relationTo: 'games',
      hasMany: true,
      admin: {
        description: 'Select specific games to display',
        condition: (_, siblingData) => siblingData?.filterType === 'manual',
      },
    },
    {
      name: 'gameType',
      type: 'select',
      options: [
        { label: 'Slots', value: 'slot' },
        { label: 'Table Games', value: 'table' },
        { label: 'Live Casino', value: 'live' },
        { label: 'Instant Win', value: 'instant' },
      ],
      admin: {
        condition: (_, siblingData) => siblingData?.filterType === 'type',
      },
    },
    {
      name: 'tag',
      type: 'text',
      admin: {
        description: 'Filter by tag name',
        condition: (_, siblingData) => siblingData?.filterType === 'tag',
      },
    },
    {
      name: 'limit',
      type: 'number',
      defaultValue: 12,
      admin: {
        description: 'Number of games to display',
      },
    },
    {
      name: 'columns',
      type: 'select',
      defaultValue: '6',
      options: [
        { label: '4 columns', value: '4' },
        { label: '5 columns', value: '5' },
        { label: '6 columns', value: '6' },
      ],
    },
    {
      name: 'showMore',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show "More" button to load additional games',
      },
    },
    {
      name: 'moreLink',
      type: 'text',
      admin: {
        description: 'Custom link for "More" button (optional)',
        condition: (_, siblingData) => siblingData?.showMore,
      },
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
    {
      name: 'showJackpot',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Display jackpot amounts on cards',
      },
    },
    {
      name: 'showProvider',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Display provider name on cards',
      },
    },
  ],
}
