import type { Block } from 'payload'

export const BannerSection: Block = {
  slug: 'banner-section',
  labels: {
    singular: 'Banner Section',
    plural: 'Banner Sections',
  },
  fields: [
    {
      name: 'promotion',
      type: 'relationship',
      relationTo: 'promotions',
      required: true,
      admin: {
        description: 'Select a promotion to display as banner',
      },
    },
    {
      name: 'size',
      type: 'select',
      defaultValue: 'large',
      options: [
        { label: 'Small (200px)', value: 'small' },
        { label: 'Medium (300px)', value: 'medium' },
        { label: 'Large (400px)', value: 'large' },
      ],
    },
    {
      name: 'alignment',
      type: 'select',
      defaultValue: 'center',
      options: [
        { label: 'Left', value: 'left' },
        { label: 'Center', value: 'center' },
        { label: 'Right', value: 'right' },
      ],
    },
    {
      name: 'showCountdown',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show countdown timer if promotion has one',
      },
    },
    {
      name: 'rounded',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Apply rounded corners to the banner',
      },
    },
    {
      name: 'showOverlay',
      label: 'Show Text Overlay',
      type: 'checkbox',
      defaultValue: true,
      admin: {
        description: 'Show text overlay (title, subtitle, CTA) on the banner. Uncheck to show only the image.',
      },
    },
    {
      name: 'marginTop',
      type: 'number',
      defaultValue: 24,
      admin: {
        description: 'Top margin in pixels',
      },
    },
    {
      name: 'marginBottom',
      type: 'number',
      defaultValue: 24,
      admin: {
        description: 'Bottom margin in pixels',
      },
    },
  ],
}
