import type { CollectionConfig } from 'payload'
import { CarouselSection } from '../blocks/CarouselSection'
import { SuggestedGamesSection } from '../blocks/SuggestedGamesSection'
import { GameGridSection } from '../blocks/GameGridSection'
import { BannerSection } from '../blocks/BannerSection'

export const LobbyLayouts: CollectionConfig = {
  slug: 'lobby-layouts',
  admin: {
    useAsTitle: 'name',
    defaultColumns: ['name', 'slug', 'platform', 'isDefault', 'updatedAt'],
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
        description: 'Unique identifier (e.g., web-default, mobile-default)',
      },
    },
    {
      name: 'name',
      type: 'text',
      required: true,
      admin: {
        description: 'Display name for this layout',
      },
    },
    {
      name: 'platform',
      type: 'select',
      required: true,
      options: [
        { label: 'Web', value: 'web' },
        { label: 'Mobile', value: 'mobile' },
      ],
    },
    {
      name: 'isDefault',
      type: 'checkbox',
      defaultValue: false,
      admin: {
        description: 'Set as default layout for the selected platform',
        position: 'sidebar',
      },
    },
    {
      name: 'sections',
      type: 'blocks',
      blocks: [CarouselSection, SuggestedGamesSection, GameGridSection, BannerSection],
      admin: {
        description: 'Add and arrange lobby sections',
      },
    },
  ],
}
