class PokedexUtils
  # POSSIBLE_ALTS = ["", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
  #                  "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah",
  #                  "ai", "aj", "ak", "al", "am", "an", "ao", "ap", "aq", "ar", "as", "at", "au", "av", "aw", "ax",
  #                  "ay", "az"]

  def getAltLettersList()
    return ('a'..'z').to_a + ('aa'..'az').to_a
  end

  def getBaseSpritesAlts(dex_number)
    return $game_temp.base_sprites_list[dex_number]
  end

  def getLocalBaseSpriteAlts(dex_number)
    local_sprite_alts = []
    baseFilename = "#{dex_number}"
    possible_alt_letters = getAltLettersList()
    possible_alt_letters << ""
    possible_alt_letters.each { |alt_letter|
      spritename = "#{baseFilename}#{alt_letter}"
      local_path = "#{Settings::CUSTOM_BASE_SPRITES_FOLDER}/#{spritename}.png"
      if pbResolveBitmap(local_path)
        local_sprite_alts << getLocalSpriteID(local_path)
      end
    }
    return local_sprite_alts
  end

  def getLocalFusionSpriteAlts(head_id,body_id)
    local_sprite_alts = []
    baseFilename = "#{head_id}.#{body_id}"
    possible_alt_letters = getAltLettersList()
    possible_alt_letters << ""
    possible_alt_letters.each { |alt_letter|
      spritename = "#{baseFilename}#{alt_letter}"
          local_path = "#{Settings::CUSTOM_BATTLERS_FOLDER_INDEXED}/#{head_id.to_s}/#{spritename}.png"
          if pbResolveBitmap(local_path)
            local_sprite_alts << getLocalSpriteID(local_path)
          end
      }
    return local_sprite_alts
  end

  def getLocalSpriteID(sprite_path)
    return "local_#{sprite_path}"
  end

  def getFusionSpriteAlts(head_id, body_id)
    sprite_id = get_fusion_symbol(head_id,body_id)
    return $game_temp.custom_sprites_list[sprite_id]
  end

  def pbGetAvailableAlts(dex_number, includeAutogens=false)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number,body_id)
      available_alts = getFusionSpriteAlts(head_id,body_id)
      echoln available_alts
      available_alts = [] if !available_alts
      local_alts = getLocalFusionSpriteAlts(head_id,body_id)
    else
      available_alts= getBaseSpritesAlts(dex_number)
      available_alts = [] if !available_alts
      local_alts = getLocalBaseSpriteAlts(dex_number)
    end
    available_alts += local_alts if local_alts
    available_alts << "autogen" if includeAutogens
    return available_alts
  end


  #todo: return array for split evolution lines that have multiple final evos
  def getFinalEvolution(species)
    #ex: [[B3H4,Level 32],[B2H5, Level 35]]
    evolution_line = species.get_evolutions
    return species if evolution_line.empty?
    finalEvoId = evolution_line[0][0]
    return evolution_line[]
    for evolution in evolution_line
      evoSpecies = evolution[0]
      p GameData::Species.get(evoSpecies).get_evolutions
      isFinalEvo = GameData::Species.get(evoSpecies).get_evolutions.empty?
      return evoSpecies if isFinalEvo
    end
    return nil
  end

end
