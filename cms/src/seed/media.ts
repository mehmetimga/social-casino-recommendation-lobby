import type { Payload } from 'payload'
import * as fs from 'fs'
import * as path from 'path'

// Banner images for hero carousel (large format)
export const bannerImages = [
  '9caa9b77a1ed74e90f14a784bc321317a105258f.avif',
  '08e4fba3ea88d4894c062a77297572163773c329.avif',
  '26c10e48096adcfdb03ea17363df98c08e654207.avif',
  '29ac86a2ab90de027084110c593890afc7fb3116.avif',
  '30de7e76366d8cedc5273b6694ce78067ee50ecb.avif',
  'd31583c8e6fd97581a0b4be683a5b2da3612c9c9.avif',
  'e51860be282052a4e7584a78eec10bf17e49a4c6.avif',
  'fd5802cef4c8fb7902c728599617b86c8f7cdb98.avif',
]

// Game images mapping: slug -> image prefix (numeric IDs from casino-images directory - 30 games)
export const gameImageMap: Record<string, string> = {
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
}

// Additional game images for variety
export const additionalGameImages = [
  'slingo-championship',
  'slingo-fireandice',
  'slingo-honeycrew',
  'slingo-journeytoasgard',
  'slingo-luckymcgold',
  'slingo-redhot',
  'konami_chinashores',
  'konami_africandiamond',
  'konami_allaboarddynamitedash',
  'konami_bafangjinbaoabundantfortune',
  'konami_fortunemintfuxinggaozhao',
  'vs10bbfmission',
  'vs10bbbrlact',
  'vs10bbdoubled',
  'vs10booklight',
  'vs10dgold88',
  'vs10egyptcls',
  'vs10fdsnake',
  'vs10fonzofff',
  'vs10jnmntzma',
  'vs10noodles',
  'vs12bgrbspl',
  'vs15diamond',
  'vs15fghtmultlv',
  'vs1fortunetree',
  'vs20bermuda',
  'vs20chicken',
  'vs20dhcluster',
  'vs20forge',
  'vs25badge',
  'sun_of_egypt',
  'sun_of_egypt_5',
  'super_hot_teapots',
  'magic_apple',
  'magic_clovers',
  'maya_lock',
  'long_bao_bao',
  'egypt_fire',
  'capital_gains',
  'CashMachine',
  'DoubleRuby',
  'SmokinTriples',
  'TripleThreat',
  '2x_spin_cycle',
  '3x_ultra_diamond',
  'SGGeniesShowtime',
  'SGIndianaWolf',
  'SGSafariRumble',
  'SGShiveringStrings',
  'rng-roulette_rng-rt-lightning',
  'rng-roulette_rng-rt-european0',
  'rng-megaball_RngMegaBall00001',
  'rng-blackjack_rng-bj-standard0',
  'rng-craps_RngCraps00000001',
  'sicbo_SuperSicBo000001',
  'lightningdice_LightningDice001',
  'funanfunu',
  'TGBlackjackAmerican',
  'TGDragonTiger',
  'TGWar',
  'blackjack-xchange',
  'BlackJack3HDoubleExposure',
]

export interface MediaRecord {
  id: string
  filename: string
  alt: string
}

const uploadedMedia: Map<string, MediaRecord> = new Map()

export async function seedMedia(payload: Payload): Promise<Map<string, MediaRecord>> {
  console.log('Seeding media...')

  const imagesDir = path.resolve(process.cwd(), '..', 'casino-images')

  if (!fs.existsSync(imagesDir)) {
    console.log('Casino images directory not found, skipping media upload')
    return uploadedMedia
  }

  // Upload banner images
  for (const bannerFile of bannerImages) {
    const filePath = path.join(imagesDir, bannerFile)
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
            alt: `Banner ${bannerFile.replace('.avif', '')}`,
          },
          file: {
            data: fileBuffer,
            name: bannerFile,
            mimetype: 'image/avif',
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

  // Upload game images (use 268x168 size for better quality)
  const allGamePrefixes = [...Object.values(gameImageMap), ...additionalGameImages]
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

