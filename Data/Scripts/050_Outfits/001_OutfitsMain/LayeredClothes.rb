def find_last_outfit(outfit_type_path, firstOutfit)
  for i in firstOutfit..Settings::MAX_NB_OUTFITS
    outfit_path = outfit_type_path + "/" + i.to_s #Settings::PLAYER_GRAPHICS_FOLDER + outfit_type_path + "/" + outfit_type_path + "_" + player_sprite + "_" + i.to_s
    return i - 1 if !Dir.exist?(outfit_path)
  end
  return firstOutfit
end

def list_all_numeric_folders(directory_path)
  entries = Dir.entries(directory_path)
  # Filter out only the directories whose names are numeric (excluding "." and "..")
  numeric_folders = entries.select do |entry|
    full_path = File.join(directory_path, entry)
    File.directory?(full_path) && entry != '.' && entry != '..' && entry.match?(/^\d+$/)
  end

  # Convert the folder names to integers and store in an array
  folder_integers = numeric_folders.map(&:to_i)
  folder_integers.sort!
  return folder_integers
end

def list_all_numeric_files_with_filter(directory_path, prefix)
  entries = Dir.entries(directory_path)
  prefixless = []
  for file in entries
    next if file == "." || file == ".."
    prefixless << file.gsub((prefix + "_"), "")
  end

  folder_integers = prefixless.map(&:to_i)
  folder_integers.sort!
  return folder_integers
end

#unlocked:
# -1 for all outfits unlocked
# Otherwise, an array of the ids of unlocked outfits
def list_available_outfits(directory, versions = [], unlocked = [], prefix_filter = nil)
  if prefix_filter
    outfits = list_all_numeric_files_with_filter(directory, prefix_filter)
  else
    outfits = list_all_numeric_folders(directory)
  end
  # #echoln outfits
  # return outfits  #todo: remove this return for unlockable outfits
  available_outfits = []
  for outfit in outfits
    if !unlocked || unlocked.include?(outfit)
      for version in versions
        available_outfits << outfit.to_s + version
      end
      available_outfits << outfit.to_s if versions.empty?
    end
  end
  return available_outfits
end

def get_current_outfit_position(currentOutfit_id, available_outfits)
  current_index = available_outfits.index(currentOutfit_id)
  return current_index.nil? ? 0 : current_index
end

def setHairColor(hue_shift)
  $Trainer.hair_color = hue_shift
  refreshPlayerOutfit()
end

def shiftHatColor(incr)
  $Trainer.hat_color = 0 if !$Trainer.hat_color
  $Trainer.hat_color += incr
  refreshPlayerOutfit()
end

def shiftClothesColor(incr)
  $Trainer.clothes_color = 0 if !$Trainer.clothes_color
  $Trainer.clothes_color += incr
  refreshPlayerOutfit()
end

def shiftHairColor(incr)
  $Trainer.hair_color = 0 if !$Trainer.hair_color
  $Trainer.hair_color += incr
  refreshPlayerOutfit()
end

def pbLoadOutfitBitmap(outfitFileName)
  begin
    outfitBitmap = RPG::Cache.load_bitmap("", outfitFileName)
    return outfitBitmap
  rescue
    return nil
  end
end

def setOutfit(outfit_id)
  $Trainer.clothes = outfit_id
end

def setHat(hat_id)
  $Trainer.hat = hat_id
end

def getEasterEggHeldItem()
  map = $game_map.map_id
  return "secrets/HOTDOG" if [141, 194].include?(map) #restaurant
  return "secrets/SNOWBALL" if [670, 693, 698, 694].include?(map)
  return "secrets/WALLET" if [432, 433, 434, 435, 436, 292].include?(map) #dept. store
  return "secrets/ALARMCLOCK" if [43, 48, 67, 68, 69, 70, 71, 73].include?(map) #Player room
  return "SAFARIBALL" if [445, 484, 485, 486, 107, 487, 488, 717, 82, 75, 74].include?(map) #Safari Zone
  return "secrets/WISP" if [401,402,403,467,468,469].include?(map) #Pokemon Tower
  return "secrets/SKULL" if [400].include?(map) #Pokemon Tower ground floor
  return "secrets/ROCK" if [349,350,800,].include?(map) #Rock Tunnel
  return "secrets/MAGIKARP" if [394,471,189,].include?(map) #Fishing huts
  return "secrets/AZUREFLUTE" if [694,].include?(map) && $PokemonBag.pbQuantity(:AZUREFLUTE)>=1 #Ice Mountain peak
  return "secrets/BIGSODA" if [436,].include?(map) && $PokemonBag.pbQuantity(:SODAPOP)>=1 #Celadon dept. store top
  return "secrets/EGG" if [13,406,214,].include?(map) #Celadon Café
  return "secrets/STICK" if [266,].include?(map) #Ilex forest
  return nil
end

def getCurrentPokeball(allowEasterEgg=true)
  otherItem = getEasterEggHeldItem() if allowEasterEgg
  return otherItem if otherItem
  firstPokemon = $Trainer.party[0]
  return firstPokemon.poke_ball if firstPokemon
  return nil
end

def generate_front_trainer_sprite_bitmap_from_appearance(trainerAppearance)
  echoln caller
  echoln trainerAppearance.hat
  return generate_front_trainer_sprite_bitmap(false,nil,trainerAppearance.clothes,trainerAppearance.hat,
                                              trainerAppearance.hair,trainerAppearance.skin_color,
                                              trainerAppearance.hair_color,trainerAppearance.hat_color,trainerAppearance.clothes_color)
end

def generate_front_trainer_sprite_bitmap(allowEasterEgg=true, pokeball = nil, clothes_id = nil, hat_id = nil, hair_id = nil,
                                         skin_tone_id = nil, hair_color = nil, hat_color = nil, clothes_color = nil)
  echoln hat_id
  clothes_id = $Trainer.clothes if !clothes_id
  hat_id = $Trainer.hat if !hat_id
  hair_id = $Trainer.hair if !hair_id
  skin_tone_id = $Trainer.skin_tone if !skin_tone_id
  hair_color = $Trainer.hair_color if !hair_color
  hat_color = $Trainer.hat_color if !hat_color
  clothes_color = $Trainer.clothes_color if !clothes_color

  hairFilename = getTrainerSpriteHairFilename(hair_id) #_INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_HAIR_FOLDER + "/hair_trainer_{1}", $Trainer.hair)
  outfitFilename = getTrainerSpriteOutfitFilename(clothes_id) #_INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_CLOTHES_FOLDER + "/clothes_trainer_{1}", $Trainer.clothes)

  hatFilename = getTrainerSpriteHatFilename(hat_id) # _INTL(Settings::PLAYER_GRAPHICS_FOLDER + Settings::PLAYER_HAT_FOLDER + "/hat_trainer_{1}", $Trainer.hat)
  pokeball = getCurrentPokeball(allowEasterEgg) if !pokeball
  ballFilename = getTrainerSpriteBallFilename(pokeball) if pokeball

  baseFilePath = getBaseTrainerSpriteFilename(skin_tone_id)

  hair_color_shift = hair_color
  hat_color_shift = hat_color
  clothes_color_shift = clothes_color

  hair_color_shift = 0 if !hair_color_shift
  hat_color_shift = 0 if !hat_color_shift
  clothes_color_shift = 0 if !clothes_color_shift

  baseBitmap = AnimatedBitmap.new(baseFilePath) if pbResolveBitmap(baseFilePath)
  ballBitmap = pbLoadOutfitBitmap(ballFilename) if pbResolveBitmap(ballFilename)

  if !pbResolveBitmap(outfitFilename)
    outfitFilename = getTrainerSpriteOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK)
  end
  if !pbResolveBitmap(outfitFilename)
    raise "No temp clothes graphics available"
  end

  outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift) if pbResolveBitmap(outfitFilename) #pb
  hairBitmapWrapper = AnimatedBitmap.new(hairFilename, hair_color_shift) if pbResolveBitmap(hairFilename)

  hatBitmap = AnimatedBitmap.new(hatFilename, hat_color_shift) if pbResolveBitmap(hatFilename) #pbLoadOutfitBitmap(hatFilename) if pbResolveBitmap(hatFilename)

  baseBitmap.bitmap = baseBitmap.bitmap.clone
  if outfitBitmap
    baseBitmap.bitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect)
  else
    outfitFilename = getTrainerSpriteOutfitFilename("temp")
    outfitBitmap = AnimatedBitmap.new(outfitFilename, 0)
    baseBitmap.bitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect)
  end
  baseBitmap.bitmap.blt(0, 0, hairBitmapWrapper.bitmap, hairBitmapWrapper.bitmap.rect) if hairBitmapWrapper
  baseBitmap.bitmap.blt(0, 0, hatBitmap.bitmap, hatBitmap.bitmap.rect) if hatBitmap
  baseBitmap.bitmap.blt(44, 42, ballBitmap, ballBitmap.rect) if ballBitmap

  return baseBitmap
end

def generateNPCClothedBitmapStatic(trainerAppearance,action = "walk")
  baseBitmapFilename = getBaseOverworldSpriteFilename(action, trainerAppearance.skin_color)

  baseSprite = AnimatedBitmap.new(baseBitmapFilename)

  baseBitmap = baseSprite.bitmap.clone # nekkid sprite
  outfitFilename = getOverworldOutfitFilename(trainerAppearance.clothes, action)

  hairFilename = getOverworldHairFilename(trainerAppearance.hair)


  #Clothes
  clothes_color_shift = trainerAppearance.clothes_color || 0
  clothesBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift).bitmap if pbResolveBitmap(outfitFilename)
  baseBitmap.blt(0, 0, clothesBitmap, clothesBitmap.rect)
  #clothesBitmap.dispose


  #Hair
  hair_color_shift = trainerAppearance.hair_color || 0
  hairBitmap = AnimatedBitmap.new(hairFilename, hair_color_shift).bitmap if pbResolveBitmap(hairFilename)
  baseBitmap.blt(0, 0, hairBitmap, hairBitmap.rect)
  hat_color_shift = trainerAppearance.hat_color || 0
  hatFilename = getOverworldHatFilename(trainerAppearance.hat)
  hatBitmapWrapper = AnimatedBitmap.new(hatFilename, hat_color_shift) if pbResolveBitmap(hatFilename)
  if hatBitmapWrapper
    frame_count = 4 # Assuming 4 frames for hair animation; adjust as needed
    hat_frame_bitmap = duplicateHatForFrames(hatBitmapWrapper.bitmap, frame_count)

    frame_width = baseSprite.bitmap.width / frame_count # Calculate frame width

    frame_count.times do |i|
      # Calculate offset for each frame
      frame_offset = [i * frame_width, 0]
      # Adjust Y offset if frame index is odd
      frame_offset[1] -= 2 if i.odd?
      positionHat(baseBitmap, hat_frame_bitmap, frame_offset, i, frame_width)
    end
  end
  return baseBitmap
end

def generateClothedBitmapStatic(trainer, action = "walk")
  baseBitmapFilename = getBaseOverworldSpriteFilename(action, trainer.skin_tone)
  if !pbResolveBitmap(baseBitmapFilename)
    baseBitmapFilename = Settings::PLAYER_GRAPHICS_FOLDER + action
  end
  baseSprite = AnimatedBitmap.new(baseBitmapFilename)

  # Clone the base sprite bitmap to create the base for the player's sprite
  baseBitmap = baseSprite.bitmap.clone # nekkid sprite
  outfitFilename = getOverworldOutfitFilename(trainer.clothes, action)
  outfitFilename = getOverworldOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK) if !pbResolveBitmap(outfitFilename)
  hairFilename = getOverworldHairFilename(trainer.hair)
  hatFilename = getOverworldHatFilename(trainer.hat)

  # Use default values if color shifts are not set
  hair_color_shift = trainer.hair_color || 0
  hat_color_shift = trainer.hat_color || 0
  clothes_color_shift = trainer.clothes_color || 0

  # Use fallback outfit if the specified outfit cannot be resolved
  if !pbResolveBitmap(outfitFilename)
    outfitFilename = Settings::PLAYER_TEMP_OUTFIT_FALLBACK
  end

  # Load the outfit and hair bitmaps
  outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift)
  hairBitmapWrapper = AnimatedBitmap.new(hairFilename, hair_color_shift) if pbResolveBitmap(hairFilename)
  hatBitmapWrapper = AnimatedBitmap.new(hatFilename, hat_color_shift) if pbResolveBitmap(hatFilename)

  # Blit the outfit onto the base sprite
  baseBitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect) if outfitBitmap

  current_offset = [0, 0] # Replace this with getCurrentSpriteOffset() if needed
  positionHair(baseBitmap, hairBitmapWrapper.bitmap, current_offset) if hairBitmapWrapper

  # Handle the hat - duplicate it for each frame if necessary
  if hatBitmapWrapper
    frame_count = 4 # Assuming 4 frames for hair animation; adjust as needed
    hat_frame_bitmap = duplicateHatForFrames(hatBitmapWrapper.bitmap, frame_count)

    frame_width = baseSprite.bitmap.width / frame_count # Calculate frame width

    frame_count.times do |i|
      # Calculate offset for each frame
      frame_offset = [i * frame_width, 0]
      # Adjust Y offset if frame index is odd
      frame_offset[1] -= 2 if i.odd?
      positionHat(baseBitmap, hat_frame_bitmap, frame_offset, i, frame_width)
    end
  end

  return baseBitmap
end

def positionHair(baseBitmap, hairBitmap, offset)
  baseBitmap.blt(offset[0], offset[1], hairBitmap, hairBitmap.rect)
end

def positionHat(baseBitmap, hatBitmap, offset, frame_index, frame_width)
  # Define a rect for each frame
  frame_rect = Rect.new(frame_index * frame_width, 0, frame_width, hatBitmap.height)

  # Blit only the part of the hat corresponding to the current frame
  baseBitmap.blt(offset[0], offset[1], hatBitmap, frame_rect)
end

def duplicateHatForFrames(hatBitmap, frame_count)
  # Create a new bitmap for the duplicated hat frames
  frame_width = hatBitmap.width
  total_width = frame_width * frame_count
  duplicatedBitmap = Bitmap.new(total_width, hatBitmap.height)

  # Copy the single hat frame across each required frame
  frame_count.times do |i|
    duplicatedBitmap.blt(i * frame_width, 0, hatBitmap, hatBitmap.rect)
  end

  return duplicatedBitmap
end

def add_hat_to_bitmap(bitmap, hat_id, x_pos, y_pos, scale = 1, mirrored = false)
  base_scale = 1.5 #coz hat & poke sprites aren't the same size
  adjusted_scale = base_scale * scale
  hat_filename = getTrainerSpriteHatFilename(hat_id)
  hatBitmapWrapper = AnimatedBitmap.new(hat_filename, 0) if pbResolveBitmap(hat_filename)
  hatBitmapWrapper.scale_bitmap(adjusted_scale) if hatBitmapWrapper
  hatBitmapWrapper.mirror if hatBitmapWrapper && mirrored
  bitmap.blt(x_pos * adjusted_scale, y_pos * adjusted_scale, hatBitmapWrapper.bitmap, hatBitmapWrapper.bitmap.rect) if hatBitmapWrapper
end

class PokemonTemp
  attr_accessor :trainer_preview
end

def display_outfit_preview(x = 320, y = 0, withBorder = true)
  hide_outfit_preview() if $PokemonTemp.trainer_preview
  $PokemonTemp.trainer_preview = TrainerClothesPreview.new(x, y, withBorder)
  $PokemonTemp.trainer_preview.show()
end

def hide_outfit_preview()
  $game_screen.pictures[20].erase
  $PokemonTemp.trainer_preview.erase() if $PokemonTemp.trainer_preview
  $PokemonTemp.trainer_preview = nil
end







