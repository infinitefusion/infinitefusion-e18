# frozen_string_literal: true

class PokemonBoxIcon
  def createFusionIcon(species, spriteform_head = nil, spriteform_body = nil, bodyShiny = false, headShiny = false)
    bodyPoke_number = getBodyID(species)
    headPoke_number = getHeadID(species, bodyPoke_number)

    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    dexNum = getDexNumberForSpecies(species)
    basePath = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)

    shinySuffix = ""
    shinySuffix += "_bodyShiny" if bodyShiny
    shinySuffix += "_headShiny" if headShiny

    fusedIconFilePath = sprintf("%s%s.png", basePath, shinySuffix)

    if File.exist?(fusedIconFilePath)
      return AnimatedBitmap.new(fusedIconFilePath)
    end

    headSprite = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke, spriteform_head, nil, headShiny))
    bodySprite = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke, spriteform_body, nil, bodyShiny))

    fusedIcon = Bitmap.new(headSprite.width, headSprite.height)
    fusedIcon.blt(0, 0, headSprite.bitmap, Rect.new(0, 0, headSprite.width, headSprite.height))

    for i in 0...bodySprite.width
      for j in ((bodySprite.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)...bodySprite.height
        pixel = bodySprite.bitmap.get_pixel(i, j)
        fusedIcon.set_pixel(i, j, pixel)
      end
    end

    fusedIcon.save_to_png(fusedIconFilePath)
    return AnimatedBitmap.new(fusedIconFilePath)
  end

end