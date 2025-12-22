import type { CollectionConfig } from 'payload'

export const Promotions: CollectionConfig = {
  slug: 'promotions',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'placement', 'status', 'schedule.startDate'],
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
      name: 'subtitle',
      type: 'text',
      admin: {
        description: 'Secondary text shown below the title',
      },
    },
    {
      name: 'description',
      type: 'textarea',
    },
    {
      name: 'image',
      type: 'upload',
      relationTo: 'media',
      admin: {
        description: 'Promotion image (recommended: 1920x800 for hero)',
      },
    },
    {
      name: 'backgroundImage',
      type: 'upload',
      relationTo: 'media',
      admin: {
        description: 'Optional background image for hero carousel',
      },
    },
    {
      name: 'showOverlay',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show text overlay (title, subtitle, description, CTA) on the image. Uncheck to show only the image.',
      },
    },
    {
      name: 'ctaText',
      type: 'text',
      defaultValue: 'Play Now',
      admin: {
        description: 'Call-to-action button text',
      },
    },
    {
      name: 'ctaLink',
      type: 'group',
      fields: [
        {
          name: 'type',
          type: 'select',
          defaultValue: 'game',
          options: [
            { label: 'Game', value: 'game' },
            { label: 'External URL', value: 'url' },
            { label: 'Category', value: 'category' },
          ],
        },
        {
          name: 'game',
          type: 'relationship',
          relationTo: 'games',
          admin: {
            condition: (_, siblingData) => siblingData?.type === 'game',
          },
        },
        {
          name: 'url',
          type: 'text',
          admin: {
            condition: (_, siblingData) => siblingData?.type === 'url',
          },
        },
        {
          name: 'category',
          type: 'select',
          options: [
            { label: 'Slots', value: 'slot' },
            { label: 'Table Games', value: 'table' },
            { label: 'Live Casino', value: 'live' },
            { label: 'Instant Win', value: 'instant' },
          ],
          admin: {
            condition: (_, siblingData) => siblingData?.type === 'category',
          },
        },
      ],
    },
    {
      name: 'schedule',
      type: 'group',
      fields: [
        {
          name: 'startDate',
          type: 'date',
          admin: {
            date: {
              pickerAppearance: 'dayAndTime',
            },
          },
        },
        {
          name: 'endDate',
          type: 'date',
          admin: {
            date: {
              pickerAppearance: 'dayAndTime',
            },
          },
        },
      ],
    },
    {
      name: 'countdown',
      type: 'group',
      admin: {
        description: 'Optional countdown timer settings',
      },
      fields: [
        {
          name: 'enabled',
          type: 'checkbox',
          defaultValue: false,
        },
        {
          name: 'endTime',
          type: 'date',
          admin: {
            date: {
              pickerAppearance: 'dayAndTime',
            },
            condition: (_, siblingData) => siblingData?.enabled,
          },
        },
        {
          name: 'label',
          type: 'text',
          defaultValue: 'Ends in',
          admin: {
            condition: (_, siblingData) => siblingData?.enabled,
          },
        },
      ],
    },
    {
      name: 'status',
      type: 'select',
      required: true,
      defaultValue: 'draft',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Live', value: 'live' },
      ],
      admin: {
        position: 'sidebar',
      },
    },
    {
      name: 'placement',
      type: 'select',
      required: true,
      options: [
        { label: 'Hero Carousel', value: 'hero' },
        { label: 'Banner', value: 'banner' },
        { label: 'Featured', value: 'featured' },
      ],
      admin: {
        position: 'sidebar',
      },
    },
    {
      name: 'priority',
      type: 'number',
      defaultValue: 0,
      admin: {
        description: 'Higher priority = shown first',
        position: 'sidebar',
      },
    },
  ],
}
