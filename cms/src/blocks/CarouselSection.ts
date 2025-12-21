import type { Block } from 'payload'

export const CarouselSection: Block = {
  slug: 'carousel-section',
  labels: {
    singular: 'Carousel Section',
    plural: 'Carousel Sections',
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      admin: {
        description: 'Optional section title (usually hidden for hero carousel)',
      },
    },
    {
      name: 'promotions',
      type: 'relationship',
      relationTo: 'promotions',
      hasMany: true,
      admin: {
        description: 'Select promotions to display in the carousel',
      },
    },
    {
      name: 'autoPlay',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Automatically cycle through slides',
      },
    },
    {
      name: 'autoPlayInterval',
      type: 'number',
      defaultValue: 5000,
      admin: {
        description: 'Time between slides in milliseconds',
        condition: (_, siblingData) => siblingData?.autoPlay,
      },
    },
    {
      name: 'showDots',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show navigation dots',
      },
    },
    {
      name: 'showArrows',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show prev/next arrows',
      },
    },
    {
      name: 'height',
      type: 'select',
      defaultValue: 'large',
      options: [
        { label: 'Small (300px)', value: 'small' },
        { label: 'Medium (400px)', value: 'medium' },
        { label: 'Large (500px)', value: 'large' },
        { label: 'Full (600px)', value: 'full' },
      ],
    },
  ],
}
