import type { CollectionConfig } from 'payload'

export const Games: CollectionConfig = {
  slug: 'games',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'provider', 'type', 'status', 'popularityScore'],
  },
  access: {
    read: () => true,
  },
  fields: [
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      admin: {
        position: 'sidebar',
      },
    },
    {
      name: 'title',
      type: 'text',
      required: true,
    },
    {
      name: 'provider',
      type: 'text',
      required: true,
      admin: {
        description: 'Game provider (e.g., NetEnt, Pragmatic Play, Evolution)',
      },
    },
    {
      name: 'type',
      type: 'select',
      required: true,
      options: [
        { label: 'Slot', value: 'slot' },
        { label: 'Table Game', value: 'table' },
        { label: 'Live Casino', value: 'live' },
        { label: 'Instant Win', value: 'instant' },
      ],
    },
    {
      name: 'tags',
      type: 'array',
      admin: {
        description: 'Tags for filtering and categorization',
      },
      fields: [
        {
          name: 'tag',
          type: 'text',
          required: true,
        },
      ],
    },
    {
      name: 'thumbnail',
      type: 'upload',
      relationTo: 'media',
      admin: {
        description: 'Game thumbnail image (recommended: 600x400)',
      },
    },
    {
      name: 'heroImage',
      type: 'upload',
      relationTo: 'media',
      admin: {
        description: 'Large banner image for featured display',
      },
    },
    {
      name: 'gallery',
      type: 'array',
      admin: {
        description: 'Gallery images for the game modal slideshow',
      },
      fields: [
        {
          name: 'image',
          type: 'upload',
          relationTo: 'media',
          required: true,
        },
      ],
    },
    {
      name: 'shortDescription',
      type: 'textarea',
      admin: {
        description: 'Brief description shown in game cards',
      },
    },
    {
      name: 'fullDescription',
      type: 'richText',
      admin: {
        description: 'Full game description for modal view',
      },
    },
    {
      name: 'popularityScore',
      type: 'number',
      defaultValue: 0,
      admin: {
        description: 'Higher score = more popular. Used for sorting.',
        position: 'sidebar',
      },
    },
    {
      name: 'jackpotAmount',
      type: 'number',
      admin: {
        description: 'Current jackpot amount (if applicable)',
      },
    },
    {
      name: 'minBet',
      type: 'number',
      defaultValue: 0.1,
      admin: {
        description: 'Minimum bet amount',
      },
    },
    {
      name: 'maxBet',
      type: 'number',
      defaultValue: 100,
      admin: {
        description: 'Maximum bet amount',
      },
    },
    {
      name: 'rtp',
      type: 'number',
      admin: {
        description: 'Return to Player percentage (e.g., 96.5)',
      },
    },
    {
      name: 'volatility',
      type: 'select',
      options: [
        { label: 'Low', value: 'low' },
        { label: 'Medium', value: 'medium' },
        { label: 'High', value: 'high' },
      ],
    },
    {
      name: 'minVipLevel',
      type: 'select',
      defaultValue: 'bronze',
      options: [
        { label: 'Bronze', value: 'bronze' },
        { label: 'Silver', value: 'silver' },
        { label: 'Gold', value: 'gold' },
        { label: 'Platinum', value: 'platinum' },
      ],
      admin: {
        description: 'Minimum VIP tier required to see this game in recommendations',
        position: 'sidebar',
      },
    },
    {
      name: 'badges',
      type: 'select',
      hasMany: true,
      options: [
        { label: 'New', value: 'new' },
        { label: 'Exclusive', value: 'exclusive' },
        { label: 'Hot', value: 'hot' },
        { label: 'Jackpot', value: 'jackpot' },
        { label: 'Featured', value: 'featured' },
      ],
    },
    {
      name: 'status',
      type: 'select',
      required: true,
      defaultValue: 'enabled',
      options: [
        { label: 'Enabled', value: 'enabled' },
        { label: 'Disabled', value: 'disabled' },
      ],
      admin: {
        position: 'sidebar',
      },
    },
  ],
}
