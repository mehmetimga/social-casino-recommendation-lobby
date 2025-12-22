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
      name: 'displayStyle',
      label: 'Display Style',
      type: 'select',
      defaultValue: 'horizontal',
      options: [
        { label: 'Horizontal Scroll', value: 'horizontal' },
        { label: 'Grid (Multiple Rows)', value: 'grid' },
        { label: 'Single Row (No Scroll)', value: 'single-row' },
        { label: 'Featured Left (Large + Small)', value: 'featured-left' },
        { label: 'Featured Right (Small + Large)', value: 'featured-right' },
        { label: 'Featured Top (Large + Row)', value: 'featured-top' },
      ],
      admin: {
        description: 'Choose how games are displayed in this section',
      },
    },
    {
      name: 'rows',
      label: 'Number of Rows',
      type: 'number',
      defaultValue: 2,
      min: 1,
      max: 10,
      admin: {
        condition: (_, siblingData) => siblingData?.displayStyle === 'grid',
        description: 'Number of rows to display in grid mode',
      },
    },
    {
      name: 'featuredGame',
      label: 'Featured Game',
      type: 'relationship',
      relationTo: 'games',
      admin: {
        condition: (_, siblingData) =>
          ['featured-left', 'featured-right', 'featured-top'].includes(siblingData?.displayStyle),
        description: 'Select the game to display as the large featured card',
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
      admin: {
        condition: (_, siblingData) => ['grid', 'single-row'].includes(siblingData?.displayStyle),
        description: 'Number of columns for grid/row display',
      },
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
