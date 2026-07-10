def obtainNewHat(outfit_id)
  return obtainHat(outfit_id)
end

def obtainNewClothes(outfit_id)
  return obtainClothes(outfit_id)
end

def obtainHat(outfit_id,secondary=false)
  outfit = get_hat_by_id(outfit_id)
  if !outfit
    pbMessage(_INTL("The hat {1} is invalid.", outfit_id))
    return
  end
  $Trainer.unlocked_hats << outfit_id if !$Trainer.unlocked_hats.include?(outfit_id)
  obtainOutfitMessage(outfit)
  if pbConfirmMessage(_INTL("Would you like to put it on right now?"))
    putOnHat(outfit_id, false, false) if !secondary
    putOnHat(outfit_id, false, true) if secondary
    return true
  end
  return false
end

#Like obtainHat, but silent
def unlockHat(outfit_id)
  echoln "obtained new hat: " + outfit_id
  outfit = get_hat_by_id(outfit_id)
  if !outfit
    pbMessage(_INTL("The hat {1} is invalid.", outfit_id))
    return
  end
  $Trainer.unlocked_hats << outfit_id if !$Trainer.unlocked_hats.include?(outfit_id)
  return false
end

def obtainClothes(outfit_id)
  echoln "obtained new clothes: #{outfit_id}"
  outfit = get_clothes_by_id(outfit_id)
  if !outfit
    pbMessage(_INTL("The clothes {1} are invalid.", outfit_id))
    return
  end
  return if !outfit
  $Trainer.unlocked_clothes << outfit_id if !$Trainer.unlocked_clothes.include?(outfit_id)
  obtainOutfitMessage(outfit)
  if pbConfirmMessage(_INTL("Would you like to put it on right now?"))
    putOnClothes(outfit_id)
    return true
  end
  return false
end

def unlockClothes(outfit_id)
  outfit = get_clothes_by_id(outfit_id)
  if !outfit
    pbMessage(_INTL("The clothes {1} are invalid.", outfit_id))
    return
  end
  return if !outfit
  $Trainer.unlocked_clothes << outfit_id if !$Trainer.unlocked_clothes.include?(outfit_id)
  return false
end

def obtainNewHairstyle(full_outfit_id)
  split_outfit_id = getSplitHairFilenameAndVersionFromID(full_outfit_id)
  hairstyle_id = split_outfit_id[1]
  hairstyle = get_hair_by_id(hairstyle_id)
  musical_effect = "Key item get"
  pbMessage(_INTL("\\me[{1}]Your hairstyle was changed to \\c[1]{2}\\c[0] hairstyle!\\wtnp[30]", musical_effect, hairstyle.name))
  return true
end

def putOnClothes(outfit_id, silent = false)
  $Trainer.dyed_clothes= {} if ! $Trainer.dyed_clothes
  $Trainer.last_worn_outfit = $Trainer.clothes
  outfit = get_clothes_by_id(outfit_id)
  $Trainer.clothes = outfit_id

  dye_color = $Trainer.dyed_clothes[outfit_id]
  if dye_color
    $Trainer.clothes_color = dye_color
  else
    $Trainer.clothes_color = nil
  end

  $game_map.update
  refreshPlayerOutfit()
  putOnOutfitMessage(outfit) if !silent
end

def putOnHat(outfit_id, silent = false, is_secondary=false)
  $Trainer.dyed_hats= {} if ! $Trainer.dyed_hats
  $Trainer.set_last_worn_hat($Trainer.hat,is_secondary)
  outfit = get_hat_by_id(outfit_id)

  $Trainer.set_hat(outfit_id,is_secondary)

  dye_color = $Trainer.dyed_hats[outfit_id]
  if dye_color
    $Trainer.hat_color = dye_color if !is_secondary
    $Trainer.hat2_color = dye_color if is_secondary
  else
    $Trainer.hat_color = nil if !is_secondary
    $Trainer.hat2_color = nil if is_secondary
  end

  $game_map.refreshPlayerOutfit()
  putOnOutfitMessage(outfit) if !silent
end


def putOnHairFullId(full_outfit_id)
  outfit_id = getSplitHairFilenameAndVersionFromID(full_outfit_id)[1]
  outfit = get_hair_by_id(outfit_id)
  $Trainer.hair = full_outfit_id
  $game_map.update
  refreshPlayerOutfit()
  putOnOutfitMessage(outfit)
end

def putOnHair(outfit_id, version)
  full_id = getFullHairId(outfit_id, version)
  putOnHairFullId(full_id)
  #outfit = get_hair_by_id(outfit_id)
  #$Trainer.hair =
  #putOnOutfitMessage(outfit)
end

def showOutfitPicture(outfit)
  begin
    outfitPath = outfit.trainer_sprite_path()

    viewport = Viewport.new(Graphics.width / 4, 0, Graphics.width / 2, Graphics.height)
    bg_sprite = Sprite.new(viewport)
    outfit_sprite = Sprite.new(viewport)
    outfit_bitmap = AnimatedBitmap.new(outfitPath) if pbResolveBitmap(outfitPath)
    bg_bitmap = AnimatedBitmap.new("Graphics/Pictures/Outfits/obtain_bg")

    outfit_sprite.bitmap = outfit_bitmap.bitmap
    bg_sprite.bitmap = bg_bitmap.bitmap

    # bitmap = AnimatedBitmap.new("Graphics/Pictures/Outfits/obtain_bg")
    outfit_sprite.x = -50
    outfit_sprite.y = 50
    outfit_sprite.y -= 120 if outfit.type == :CLOTHES

    # outfit_sprite.y = Graphics.height/2
    outfit_sprite.zoom_x = 2
    outfit_sprite.zoom_y = 2

    bg_sprite.x = 0

    viewport.z = 99999
    # bg_sprite.y = Graphics.height/2

    return viewport
  rescue
    #ignore
  end
end

def obtainOutfitMessage(outfit)
  pictureViewport = showOutfitPicture(outfit)
  musical_effect = "Key item get"
  pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", musical_effect, outfit.name))
  pictureViewport.dispose if pictureViewport
end

def putOnOutfitMessage(outfit)
  playOutfitChangeAnimation()
  outfitName = outfit.name == "" ? outfit.id : outfit.name
  pbMessage(_INTL("You put on the \\c[1]{1}\\c[0]!\\wtnp[30]", outfitName))
end

def refreshPlayerOutfit()
  return if !$scene.spritesetGlobal
  $scene.spritesetGlobal.playersprite.refreshOutfit()
end

def findLastHairVersion(hairId)
  possible_versions = (1..9).to_a
  last_version = 0
  possible_versions.each { |version|
    hair_id = getFullHairId(hairId, version)
    echoln hair_id
    echoln pbResolveBitmap(getOverworldHairFilename(hair_id))
    if pbResolveBitmap(getOverworldHairFilename(hair_id))
      last_version = version
    else
      return last_version
    end
  }
  return last_version
end

def isWearingClothes(outfitId)
  return false unless $Trainer
  return $Trainer.clothes == outfitId
end

def isWearingHat(outfitId)
  return false unless $Trainer
  return $Trainer.hat == outfitId || $Trainer.hat2 == outfitId
end

def isWearingHairstyle(outfitId, version = nil)
  current_hair_split_id = getSplitHairFilenameAndVersionFromID($Trainer.hair)
  current_id = current_hair_split_id.length >= 1 ? current_hair_split_id[1] : nil
  current_version = current_hair_split_id[0]
  if version
    return outfitId == current_id && version == current_version
  end
  return outfitId == current_id
end

#Some game switches need to be on/off depending on the outfit that the player is wearing,
# this is called every time you change outfit to make sure that they're always updated correctly
def updateOutfitSwitches(refresh_map = true)
  $game_switches[WEARING_ROCKET_OUTFIT] = isWearingTeamRocketOutfit()
  #$game_map.update

  #$scene.reset_map(true) if refresh_map
  #$scene.reset_map(false)
end

def getDefaultClothes()
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_MALE
    return DEFAULT_OUTFIT_MALE
  end
  return DEFAULT_OUTFIT_FEMALE
end

def hasClothes?(outfit_id)
  return $Trainer.unlocked_clothes.include?(outfit_id)
end

def hasHat?(outfit_id)
  $Trainer.unlocked_hats = [] unless $Trainer.unlocked_hats
  return $Trainer.unlocked_hats.include?(outfit_id)
end

def getHatForPokemon(pokemonSpecies)
  possible_hats = []
  body_pokemon_id = get_body_species_from_symbol(pokemonSpecies).to_s.downcase
  head_pokemon_id = get_head_species_from_symbol(pokemonSpecies).to_s.downcase
  body_pokemon_tag = "pokemon-#{body_pokemon_id}"
  head_pokemon_tag = "pokemon-#{head_pokemon_id}"
  possible_hats += search_hats([body_pokemon_tag])
  possible_hats += search_hats([head_pokemon_tag])
  possible_hats = filter_hats_only_not_owned(possible_hats)
  unless possible_hats.empty?()
    return possible_hats.sample
  end
  return nil
end

def getOutfitForPokemon(pokemonSpecies)
  possible_clothes = []
  possible_hats = []

  body_pokemon_id = get_body_species_from_symbol(pokemonSpecies).to_s.downcase
  head_pokemon_id = get_head_species_from_symbol(pokemonSpecies).to_s.downcase
  body_pokemon_tag = "pokemon-#{body_pokemon_id}"
  head_pokemon_tag = "pokemon-#{head_pokemon_id}"

  possible_hats += search_hats([body_pokemon_tag])
  possible_hats += search_hats([head_pokemon_tag])
  possible_clothes += search_clothes([body_pokemon_tag])
  possible_clothes += search_clothes([head_pokemon_tag])

  if isFusion(getDexNumberForSpecies(pokemonSpecies))
    possible_hats += search_hats(["pokemon-fused"], [], false)
    possible_clothes += search_clothes(["pokemon-fused"], false)
  end

  possible_hats = filter_hats_only_not_owned(possible_hats)
  possible_clothes = filter_clothes_only_not_owned(possible_clothes)

  if !possible_hats.empty?() && !possible_clothes.empty?() #both have values, pick one at random
    return [[possible_hats.sample, :HAT], [possible_clothes.sample, :CLOTHES]].sample
  elsif !possible_hats.empty?
    return [possible_hats.sample, :HAT]
  elsif !possible_clothes.empty?
    return [possible_clothes.sample, :CLOTHES]
  end
  return []
end

def hatUnlocked?(hatId)
  return $Trainer.unlocked_hats.include?(hatId)
end

def export_current_outfit()
  skinTone = $Trainer.skin_tone ? $Trainer.skin_tone : 0
  hat = $Trainer.hat ? $Trainer.hat : "nil"
  hair_color = $Trainer.hair_color || 0
  clothes_color = $Trainer.clothes_color || 0
  hat_color = $Trainer.hat_color || 0
  exportedString = "TrainerAppearance.new(#{skinTone},\"#{hat}\",\"#{$Trainer.clothes}\",\"#{$Trainer.hair}\",#{hair_color},#{clothes_color},#{hat_color})"
  Input.clipboard = exportedString
end

def export_current_outfit_to_json
  appearance = {
    skin_color:     $Trainer.skin_tone || 0,
    hat:            $Trainer.hat || nil,
    hat2:           $Trainer.hat2 || nil,
    clothes:        $Trainer.clothes,
    hair:           $Trainer.hair,
    hair_color:     $Trainer.hair_color || 0,
    clothes_color:  $Trainer.clothes_color || 0,
    hat_color:      $Trainer.hat_color || 0,
    hat2_color:     $Trainer.hat2_color || 0
  }
  return appearance
end


def clearEventCustomAppearance(event_id)
  return if !$scene.is_a?(Scene_Map)
  event_sprite = $scene.spriteset.character_sprites[@event_id]
  for sprite in $scene.spriteset.character_sprites
    if sprite.character.id == event_id
      event_sprite = sprite
    end
  end
  return if !event_sprite
  event_sprite.clearBitmapOverride
end

def setEventAppearance(event_id, trainerAppearance)
  return if !$scene.is_a?(Scene_Map)
  event_sprite = $scene.spriteset.character_sprites[event_id]
  for sprite in $scene.spriteset.character_sprites
    if sprite.character.id == event_id
      event_sprite = sprite
    end
  end
  return if !event_sprite
  event_sprite.setSpriteToAppearance(trainerAppearance)
end

def getPlayerAppearance()
  return TrainerAppearance.new($Trainer.skin_tone,$Trainer.hat,$Trainer.clothes, $Trainer.hair,
                               $Trainer.hair_color, $Trainer.clothes_color, $Trainer.hat_color)
end

def randomizePlayerOutfitUnlocked()
  $Trainer.hat = $Trainer.unlocked_hats.sample
  $Trainer.hat2 = $Trainer.unlocked_hats.sample
  $Trainer.clothes = $Trainer.unlocked_clothes.sample

  dye_hat = rand(2)==0
  dye_hat2 = rand(2)==0
  dye_clothes = rand(2)==0
  dye_hair = rand(2)==0
  $Trainer.hat2 = nil if rand(3)==0

  $Trainer.hat_color = dye_hat ? rand(255) : 0
  $Trainer.hat2_color = dye_hat2 ? rand(255) : 0

  $Trainer.clothes_color = dye_clothes ? rand(255) : 0
  $Trainer.hair_color =  dye_hair ? rand(255) : 0

  hair_id = $PokemonGlobal.hairstyles_data.keys.sample
  hair_color = [1,2,3,4].sample
  $Trainer.hair = getFullHairId(hair_id,hair_color)

end

def convert_letter_to_number(letter, max_number = nil)
  return 0 unless letter
  base_value = (letter.ord * 31) & 0xFFFFFFFF  # Use a prime multiplier to spread values
  return base_value unless max_number
  return base_value % max_number
end


def generate_appearance_from_name(name)
  name_seed_length = 13
  max_dye_color=360

  seed = name[0, name_seed_length] # Truncate if longer than 8
  seed += seed[0, name_seed_length - seed.length] while seed.length < name_seed_length # Repeat first characters if shorter

  echoln seed

  hats_list = $PokemonGlobal.hats_data.keys
  clothes_list = $PokemonGlobal.clothes_data.keys
  hairstyles_list = $PokemonGlobal.hairstyles_data.keys

  hat = hats_list[convert_letter_to_number(seed[0],hats_list.length)]
  hat_color = convert_letter_to_number(seed[1],max_dye_color)
  hat2_color = convert_letter_to_number(seed[2],max_dye_color)
  hat_color = 0 if convert_letter_to_number(seed[2]) % 2 == 0 #1/2 chance of no dyed hat

  hat2 = hats_list[convert_letter_to_number(seed[10],hats_list.length)]
  hat2_color = 0 if convert_letter_to_number(seed[11]) % 2 == 0 #1/2 chance of no dyed ha
  hat2 = "" if convert_letter_to_number(seed[12]) % 2 == 0 #1/2 chance of no 2nd hat

  clothes = clothes_list[convert_letter_to_number(seed[3],clothes_list.length)]
  clothes_color = convert_letter_to_number(seed[4],max_dye_color)
  clothes_color = 0 if convert_letter_to_number(seed[5]) % 2 == 0 #1/2 chance of no dyed clothes

  hair_base = hairstyles_list[convert_letter_to_number(seed[6],hairstyles_list.length)]
  hair_number = [1,2,3,4][convert_letter_to_number(seed[7],3)]
  echoln "hair_number: #{hair_number}"

  hair=getFullHairId(hair_base,hair_number)
  hair_color = convert_letter_to_number(seed[8],max_dye_color)
  hair_color = 0 if convert_letter_to_number(seed[9]) % 2 == 0 #1/2 chance of no dyed hair

  skin_tone = [1,2,3,4,5,6][convert_letter_to_number(seed[10],5)]
  return TrainerAppearance.new(skin_tone,hat,clothes, hair,
                               hair_color, clothes_color, hat_color,
                               hat2,hat2_color)

end

def get_random_appearance(include_hat2=true, hat_dye_chance=30, clothes_dye_chance=30,hair_dye_chance=30)
  hat = $PokemonGlobal.hats_data.keys.sample
  if include_hat2
    hat2 = $PokemonGlobal.hats_data.keys.sample
    hat2 = nil if(rand(3)==0)
  end

  clothes = $PokemonGlobal.clothes_data.keys.sample
  if rand(100) <= hat_dye_chance
    hat_color = rand(2)==0 ? rand(255) : 0
    hat2_color = rand(2)==0 ? rand(255) : 0
  end
  if rand(100) <= clothes_dye_chance
    clothes_color = rand(2)==0 ? rand(255) : 0
  end

  if rand(100) <= hair_dye_chance
    hair_color =  rand(2)==0 ? rand(255) : 0
  end

  hair_id = $PokemonGlobal.hairstyles_data.keys.sample
  hair_color = [1,2,3,4].sample
  skin_tone = [1,2,3,4,5,6].sample
  hair = getFullHairId(hair_id,hair_color)

  return TrainerAppearance.new(skin_tone,hat,clothes, hair,
                               hair_color, clothes_color, hat_color,hat2)
end

def get_random_hat_contest(contest_condition,max_attempts=20)
  current_attempt = 0
  while current_attempt < max_attempts
    hat_id = $PokemonGlobal.hats_data.keys.sample
    hat = $PokemonGlobal.hats_data[hat_id]
    return hat.id if (hat.contest_condition.include?(contest_condition.downcase))
    current_attempt += 1
  end
  return hat.id
end

def get_random_clothes_contest(contest_condition,max_attempts=20)
  current_attempt = 0
  while current_attempt < max_attempts
    clothes_id = $PokemonGlobal.clothes_data.keys.sample
    clothes = $PokemonGlobal.clothes_data[clothes_id]
    return clothes.id if (clothes.contest_condition.include?(contest_condition.downcase))
    current_attempt += 1
  end
  return clothes.id
end

def randomizePlayerOutfit()
  $Trainer.hat = $PokemonGlobal.hats_data.keys.sample
  $Trainer.hat2 = $PokemonGlobal.hats_data.keys.sample
  $Trainer.hat2 = nil if(rand(3)==0)

  $Trainer.clothes = $PokemonGlobal.clothes_data.keys.sample
  $Trainer.hat_color = rand(2)==0 ? rand(255) : 0
  $Trainer.hat2_color = rand(2)==0 ? rand(255) : 0

  $Trainer.clothes_color = rand(2)==0 ? rand(255) : 0
  $Trainer.hair_color =  rand(2)==0 ? rand(255) : 0

  hair_id = $PokemonGlobal.hairstyles_data.keys.sample
  hair_color = [1,2,3,4].sample
  $Trainer.skin_tone = [1,2,3,4,5,6].sample
  $Trainer.hair = getFullHairId(hair_id,hair_color)
end



def select_hat()
  hats_list = $Trainer.unlocked_hats
  options = []
  hats_list.each do |hat_id|
    hat_name = get_hat_by_id(hat_id)
    options << hat_name.name
  end
  chosen_index= optionsMenu(options)
  selected_hat_id = hats_list[chosen_index]
  return selected_hat_id
end

def has_trumpet_hat?
  return $Trainer.unlocked_hats.include?(HAT_TRUMPET)
end
def canPutHatOnPokemon(pokemon)
  return !pokemon.egg? && !pokemon.isTripleFusion? && $game_switches[SWITCH_UNLOCKED_POKEMON_HATS]
end
