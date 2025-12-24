import type { Payload } from 'payload'
import * as fs from 'fs'
import * as path from 'path'

// Banner images for hero carousel (large format) - from casino-banners folder
export const bannerImages = [
  'social-casino-main-banner.png',
  '12-days-of-holidays.png',
  'mega-ball.png',
  'rakin-jackpot.png',
  'live-dealer.png',
  'lighting-roulette.png',
  'black-jack.png',
  'lions-wolf-bonus.png',
  'blade-runner-blackjack.png',
  'blade-runner-casino.png',
  'neon-nexus-roulette.png',
  'serengeti_spin_safari.png',
  'casino-royal-007-ana.png',
  'casino-royal-007-ana-gemini.png',
  'casino-gemini-007-roulette.png',
]

// Game images mapping: slug -> image prefix (141 games total)
export const gameImageMap: Record<string, string> = {
  // Original 30 games
  'legendary-castle': '10031',
  'divine-temple': '11042',
  'magic-fortune': '11372',
  'ruby-dynasty': '12388',
  'blazing-carnival': '13752',
  'magic-lion': '1638808',
  'ruby-olympus': '1638810',
  'crystal-vikings': '19249',
  'emerald-kingdom': '197063',
  'ancient-dynasty': '19937',
  'ancient-gems': '19972',
  'cosmic-dragons': '20132',
  'golden-festival': '20807',
  'sacred-dynasty': '22819',
  'silver-dynasty': '386',
  'royal-phoenix': '408',
  'mystic-olympus': '413',
  'bronze-sphinx': '419',
  'ancient-stars': '426',
  'emerald-riches': '446',
  'sapphire-ocean': '449',
  'crystal-pyramid': '451',
  'magic-vikings': '453',
  'legendary-empire': '465',
  'super-treasure': '474',
  'ruby-dragons': '524648',
  'diamond-stars': '65938',
  'diamond-castle': '65949',
  'platinum-dragons': '65958',
  'royal-festival': '65960',

  // Jackpot Slots (15 games)
  'mega-jackpot-wheel': 'rakin_bacon_jackpots_bonus_wheel',
  'rakin-bacon-gold': 'rakin_bacon',
  'blazin-bank-run': 'blazin_bank_run',
  'capital-gains-jackpot': 'capital_gains',
  'cash-machine-deluxe': 'CashMachine',
  'double-ruby-fortune': 'DoubleRuby',
  'smokin-triples-jackpot': 'SmokinTriples',
  'triple-threat-mega': 'TripleThreat',
  'wild-wild-7s-jackpot': 'WildWild7s',
  'spin-cycle-fortune': '2x_spin_cycle',
  'ultra-diamond-jackpot': '3x_ultra_diamond',
  'octo-jackpot': 'octogame',
  'santa-rudolf-jackpot': 'slots_santavsrudolf000',
  'triple-play-jackpot': 'trp',
  'hot-teapots-jackpot': 'super_hot_teapots',

  // Instant Win / Slingo Games (7 games)
  'slingo-championship': 'slingo-championship',
  'slingo-fire-and-ice': 'slingo-fireandice',
  'slingo-honey-crew': 'slingo-honeycrew',
  'slingo-journey-asgard': 'slingo-journeytoasgard',
  'slingo-lucky-mcgold': 'slingo-luckymcgold',
  'slingo-red-hot': 'slingo-redhot',
  'slingo-pop': 'slingo-pop',

  // Scientific Games (4 games)
  'genies-showtime': 'SGGeniesShowtime',
  'indiana-wolf': 'SGIndianaWolf',
  'safari-rumble': 'SGSafariRumble',
  'shivering-strings': 'SGShiveringStrings',

  // Konami Games (6 games)
  'china-shores': 'konami_chinashores',
  'african-diamond': 'konami_africandiamond',
  'dynamite-dash': 'konami_allaboarddynamitedash',
  'abundant-fortune': 'konami_bafangjinbaoabundantfortune',
  'fortune-mint': 'konami_fortunemintfuxinggaozhao',
  'gorilla-riches': 'konami_gorillariches',

  // Egyptian/Mystic Themed Slots (7 games)
  'sun-of-egypt': 'sun_of_egypt',
  'sun-of-egypt-5': 'sun_of_egypt_5',
  'egypt-fire': 'egypt_fire',
  'magic-apple': 'magic_apple',
  'magic-clovers': 'magic_clovers',
  'maya-lock': 'maya_lock',
  'long-bao-bao': 'long_bao_bao',

  // Table Games (12 games)
  'american-baccarat': 'AmericanBaccarat',
  'european-roulette': 'EURoulette',
  'blackjack-multi-hand': 'bjmb',
  'blackjack-classic': 'blackjack_mrfykemt5slanyi5',
  'blackjack-xchange': 'blackjack-xchange',
  'blackjack-3h': 'BlackJack3H',
  'blackjack-double-exposure': 'BlackJack3HDoubleExposure',
  'hard-hit-blackjack': 'hardhitblackjack',
  'sic-bo-classic': 'SicBo',
  'roulette-classic': 'roulette',
  'blackjack-american': 'TGBlackjackAmerican',
  'casino-war': 'TGWar',

  // Live Casino Games (14 games)
  'lightning-dice-live': 'lightningdice_LightningDice001',
  'super-sic-bo': 'sicbo_SuperSicBo000001',
  'mega-ball-live': 'megaball_MegaBall00000001',
  'dream-catcher': 'moneywheel_MOWDream00000001',
  'fun-an-fun': 'funanfunu',
  'dragon-tiger': 'TGDragonTiger',
  'rng-blackjack': 'rng-blackjack_rng-bj-standard0',
  'rng-craps': 'rng-craps_RngCraps00000001',
  'rng-mega-ball': 'rng-megaball_RngMegaBall00001',
  'rng-dream-catcher': 'rng-moneywheel_rng-dreamcatcher',
  'rng-european-roulette': 'rng-roulette_rng-rt-european0',
  'rng-lightning-roulette': 'rng-roulette_rng-rt-lightning',
  'instant-roulette': 'roulette_InstantRo0000001',
  'lightning-roulette-table': 'roulette_LightningTable01',

  // Pragmatic Play - Big Bass Series (6 games)
  'big-bass-mission': 'vs10bbfmission',
  'big-bass-brazil': 'vs10bbbrlact',
  'big-bass-doubled': 'vs10bbdoubled',
  'big-bass-lotgl': 'vs10bblotgl',
  'big-bass-3reeler': 'vs5bb3reeler',
  'big-bass-blitz': 'vswaysbblitz',

  // Pragmatic Play - Other Slots (30 games)
  'book-of-light': 'vs10booklight',
  'dragon-gold-88': 'vs10dgold88',
  'egypt-classic': 'vs10egyptcls',
  'fortune-dragon': 'vs10fdsnake',
  'floating-dragon': 'vs10floatdrg',
  'fonzo-fortune': 'vs10fonzofff',
  'giza-gods': 'vs10gizagods',
  'john-montana': 'vs10jnmntzma',
  'mayan-gods': 'vs10mayangods',
  'fortune-noodles': 'vs10noodles',
  'tutankhamun': 'vs10tut',
  'bigger-splash': 'vs12bgrbspl',
  'diamond-strike': 'vs15diamond',
  'fight-multiplier': 'vs15fghtmultlv',
  'fortune-tree': 'vs1fortunetree',
  'bermuda-riches': 'vs20bermuda',
  'big-dawgs': 'vs20bigdawgs',
  'chicken-chase': 'vs20chicken',
  'dh-cluster': 'vs20dhcluster',
  'forge-of-olympus': 'vs20forge',
  'starlight-princess': 'vs20starlight',
  'sugar-rush-x': 'vs20sugarrushx',
  'big-badge': 'vs25badge',
  'joker-king': 'vs25jokerking',
  'mustang-gold': 'vs25mustang',
  'scarab-queen': 'vs25scarabqueen',
  'mystery-4096': 'vs4096mystery',
  'cleos-eye': 'vs40cleoeye',
  'juicy-fruits': 'vs50juicyfr',
  'lions-1024': 'vs1024lionsd',

  // Pragmatic Play - Ways Slots (9 games)
  '5-lions-2': 'vsways5lions2',
  'aztec-ways': 'vswaysaztec',
  'eternity-ways': 'vswayseternity',
  'expanding-ways': 'vswaysexpandng',
  'japan-ways': 'vswaysjapan',
  'kraken-ways': 'vswayskrakenmw',
  'mighty-freya': 'vswaysmfreya',
  'modern-fruits': 'vswaysmodfr',
  'pearls-ways': 'vswayspearls',

  // Casino Royal 007 Themed Games
  'casino-royal-007-baccarat': 'casino-royal-007-baccarat',
  'casino-royal-007-gemini-blackjack': 'casino-royal-007-gemini-blackjack',
  'gemini-007-roulette': 'gemini-007-roulette',
}

// Additional game images are now included in gameImageMap above

export interface MediaRecord {
  id: string
  filename: string
  alt: string
}

const uploadedMedia: Map<string, MediaRecord> = new Map()

export async function seedMedia(payload: Payload): Promise<Map<string, MediaRecord>> {
  console.log('Seeding media...')

  // In Docker, these are mounted at root level; locally they're relative to cms folder
  const imagesDir = fs.existsSync('/casino-images')
    ? '/casino-images'
    : path.resolve(process.cwd(), '..', 'casino-images')
  const bannersDir = fs.existsSync('/casino-banners')
    ? '/casino-banners'
    : path.resolve(process.cwd(), '..', 'casino-banners')

  if (!fs.existsSync(imagesDir)) {
    console.log('Casino images directory not found, skipping media upload')
    return uploadedMedia
  }

  // Upload banner images from casino-banners folder
  if (fs.existsSync(bannersDir)) {
    for (const bannerFile of bannerImages) {
      const filePath = path.join(bannersDir, bannerFile)
      if (fs.existsSync(filePath)) {
        try {
          const existing = await payload.find({
            collection: 'media',
            where: { filename: { equals: bannerFile } },
          })

          if (existing.docs.length > 0) {
            const doc = existing.docs[0]
            uploadedMedia.set(`banner:${bannerFile}`, {
              id: doc.id as string,
              filename: bannerFile,
              alt: doc.alt || `Banner ${bannerFile}`,
            })
            console.log(`Banner ${bannerFile} already exists, skipping...`)
            continue
          }

          const fileBuffer = fs.readFileSync(filePath)
          const media = await payload.create({
            collection: 'media',
            data: {
              alt: `Banner ${bannerFile.replace('.png', '').replace(/-/g, ' ')}`,
            },
            file: {
              data: fileBuffer,
              name: bannerFile,
              mimetype: 'image/png',
              size: fileBuffer.length,
            },
          })

          uploadedMedia.set(`banner:${bannerFile}`, {
            id: media.id as string,
            filename: bannerFile,
            alt: media.alt,
          })
          console.log(`Uploaded banner: ${bannerFile}`)
        } catch (error) {
          console.error(`Failed to upload banner ${bannerFile}:`, error)
        }
      }
    }
  } else {
    console.log('Casino banners directory not found, skipping banner upload')
  }

  // Upload game images (use 268x168 size for better quality)
  const allGamePrefixes = Object.values(gameImageMap)
  const uniquePrefixes = [...new Set(allGamePrefixes)]

  for (const prefix of uniquePrefixes) {
    const filename = `${prefix}-268x168.avif`
    const filePath = path.join(imagesDir, filename)

    if (fs.existsSync(filePath)) {
      try {
        const existing = await payload.find({
          collection: 'media',
          where: { filename: { equals: filename } },
        })

        if (existing.docs.length > 0) {
          const doc = existing.docs[0]
          uploadedMedia.set(`game:${prefix}`, {
            id: doc.id as string,
            filename: filename,
            alt: doc.alt || prefix,
          })
          console.log(`Game image ${filename} already exists, skipping...`)
          continue
        }

        const fileBuffer = fs.readFileSync(filePath)
        const media = await payload.create({
          collection: 'media',
          data: {
            alt: prefix.replace(/-/g, ' ').replace(/_/g, ' '),
          },
          file: {
            data: fileBuffer,
            name: filename,
            mimetype: 'image/avif',
            size: fileBuffer.length,
          },
        })

        uploadedMedia.set(`game:${prefix}`, {
          id: media.id as string,
          filename: filename,
          alt: media.alt,
        })
        console.log(`Uploaded game image: ${filename}`)
      } catch (error) {
        console.error(`Failed to upload game image ${filename}:`, error)
      }
    } else {
      // Try small size if medium doesn't exist
      const smallFilename = `${prefix}-201x126.avif`
      const smallFilePath = path.join(imagesDir, smallFilename)

      if (fs.existsSync(smallFilePath)) {
        try {
          const existing = await payload.find({
            collection: 'media',
            where: { filename: { equals: smallFilename } },
          })

          if (existing.docs.length > 0) {
            const doc = existing.docs[0]
            uploadedMedia.set(`game:${prefix}`, {
              id: doc.id as string,
              filename: smallFilename,
              alt: doc.alt || prefix,
            })
            console.log(`Game image ${smallFilename} already exists, skipping...`)
            continue
          }

          const fileBuffer = fs.readFileSync(smallFilePath)
          const media = await payload.create({
            collection: 'media',
            data: {
              alt: prefix.replace(/-/g, ' ').replace(/_/g, ' '),
            },
            file: {
              data: fileBuffer,
              name: smallFilename,
              mimetype: 'image/avif',
              size: fileBuffer.length,
            },
          })

          uploadedMedia.set(`game:${prefix}`, {
            id: media.id as string,
            filename: smallFilename,
            alt: media.alt,
          })
          console.log(`Uploaded game image: ${smallFilename}`)
        } catch (error) {
          console.error(`Failed to upload game image ${smallFilename}:`, error)
        }
      }
    }
  }

  console.log(`Media seeding completed! Uploaded ${uploadedMedia.size} images.`)
  return uploadedMedia
}

export function getMediaId(key: string): string | undefined {
  return uploadedMedia.get(key)?.id
}

export function getBannerMediaId(index: number): string | undefined {
  const bannerFile = bannerImages[index % bannerImages.length]
  return uploadedMedia.get(`banner:${bannerFile}`)?.id
}

export function getGameMediaId(slug: string): string | undefined {
  const imagePrefix = gameImageMap[slug]
  if (imagePrefix) {
    return uploadedMedia.get(`game:${imagePrefix}`)?.id
  }
  return undefined
}

