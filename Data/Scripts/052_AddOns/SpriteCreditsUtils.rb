def map_sprites_by_artist
  creditsMap = Hash.new
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    spritename = row[0]
    if row[1]
      artist = row[1].chomp
      sprites = creditsMap.key?(artist) ? creditsMap[artist] : []
      sprites << spritename
      creditsMap[artist] = sprites
    end
  end
  return creditsMap
end

def get_top_artists(nb_names = 100)
  filename = Settings::CREDITS_FILE_PATH
  name_counts = Hash.new(0)

  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    name_counts[name] += 1
  end

  name_counts.sort_by { |name, count| -count }.to_h
             .first(nb_names)
             .to_h
end

def analyzeSpritesList(spritesList, mostPopularCallbackVariable = 1)
  pokemon_map = Hash.new
  for spritename in spritesList
    splitName = spritename.split(".")
    headNum = splitName[0].to_i
    bodyNum = splitName[1].to_i

    if pokemon_map.key?(headNum)
      pokemon_map[headNum] += 1
    else
      pokemon_map[headNum] = 1
    end

    if pokemon_map.key?(bodyNum)
      pokemon_map[bodyNum] += 1
    else
      pokemon_map[bodyNum] = 1
    end
  end
  most_popular = pokemon_map.max_by { |key, value| value }
  most_popular_poke = most_popular[0]
  most_popular_nb = most_popular[1]

  pbSet(mostPopularCallbackVariable, most_popular_nb)
  species = getSpecies(most_popular_poke)

  return species
end

def getPokemonSpeciesFromPifSprite(pif_sprite)
  if pif_sprite.type == :BASE
    return getSpecies(pif_sprite.head_id)
  else
    return getFusionSpecies(pif_sprite.body_id, pif_sprite.head_id)
  end
end

# def getPokemonSpeciesFromSprite(spritename)
#   return nil if !spritename
#   spritename.gsub('.png', '')
#   splitName = spritename.split(".")
#   headNum = splitName[0].to_i
#   bodyNum = splitName[1].to_i
#
#   #call this to make sure that the sprite is downloaded
#   get_fusion_sprite_path(headNum, bodyNum)
#
#   species = getFusionSpecies(bodyNum, headNum)
#   return species
# end

def doesCurrentExhibitionFeaturePokemon(displayedSprites, pokemon)
  for sprite in displayedSprites
    headNum = sprite.head_id
    bodyNum = sprite.body_id
    return true if headNum == pokemon.id_number || bodyNum == pokemon.id_number
  end
  return false
end

def select_spriter(minNbSprites = 10, save_in_var = 1)
  spriters_list = list_all_spriters_with_min_nb_of_sprites(minNbSprites)
  commands = []
  spriters_list.each do |name, i|
    if name
      commands.push([i, name, name])
    end
  end
  chosen = pbChooseList(commands, 0, nil, 1)
  return nil if !chosen
  return chosen
end

def list_all_spriters_with_min_nb_of_sprites(minNbSprites)
  return list_all_spriters() if !minNbSprites
  filename = Settings::CREDITS_FILE_PATH
  spriters_hash = Hash.new(0)

  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    if name
      spriters_hash[name] += 1
    end
  end

  spriters_list = []
  for spriter_name in spriters_hash.keys
    if spriters_hash[spriter_name] >= minNbSprites
      spriters_list << spriter_name
    end
  end
  return spriters_list
end

def list_all_spriters()
  filename = Settings::CREDITS_FILE_PATH
  names_list = []
  File.readlines(filename).each do |line|
    name = line.strip.split(',')[1]
    if !names_list.include?(name)
      names_list << name
    end
  end
  return names_list
end

def generateCurrentGalleryBattle(level = nil, number_of_pokemon = 3)
  spriter_name = pbGet(259)
  #set highest level in party if nil
  if !level
    level = $Trainer.highest_level_pokemon_in_party
  end
  possible_battlers = []
  for i in 0..5
    pif_sprite = pbGet(VAR_GALLERY_FEATURED_SPRITES)[i]
    species = getPokemonSpeciesFromPifSprite(pif_sprite)
    possible_battlers << species if species
  end

  selected_battlers_idx = possible_battlers.sample(number_of_pokemon)
  party = []
  selected_battlers_idx.each { |species| 00
  party << Pokemon.new(species, level)
  }

  custom_appearance = generate_appearance_from_name(spriter_name)
  customTrainerBattle(spriter_name,
                      :PAINTER,
                      party,
                      level,
                      pick_spriter_losing_dialog(spriter_name),
                      pick_trainer_sprite(spriter_name),
  custom_appearance

  )

end

def generateArtGallery(nbSpritesDisplayed = 6, saveArtistNameInVariable = 1, saveSpritesInVariable = 2, saveAllArtistSpritesInVariable = 3, artistName = nil)
  artistName = nil if artistName == 0
  creditsMap = map_sprites_by_artist
  select_daily_team_flags()
  featuredArtist = artistName ? artistName : getRandomSpriteArtist(creditsMap, nbSpritesDisplayed)
  if featuredArtist
    if !creditsMap[featuredArtist] #try again if issue
      artistName = getRandomSpriteArtist(creditsMap, nbSpritesDisplayed)
      return generateArtGallery(nbSpritesDisplayed, saveSpritesInVariable, saveSpritesInVariable, saveSpritesInVariable, artistName)
    end
    featuredSprites_files = creditsMap[featuredArtist].shuffle.take(nbSpritesDisplayed)
    echoln featuredSprites_files
    featuredSprites = []
    for sprite_name in featuredSprites_files
      featuredSprites << pif_sprite_from_spritename(sprite_name)
    end
    echoln featuredSprites
    pbSet(saveArtistNameInVariable, File.basename(featuredArtist, '#*'))
    pbSet(saveSpritesInVariable, featuredSprites)
    pbSet(saveAllArtistSpritesInVariable, creditsMap[featuredArtist])
    return featuredSprites
  end
  return nil
end

FLAGS_PATH = "Graphics/Pictures/Trainer Card/backgrounds/flags/"

def select_daily_team_flags()
  eligible_flags = []
  all_flags = Dir.entries(FLAGS_PATH)
                 .select { |file| file.end_with?('_FLAG.png') }
                 .map { |file| file.sub('_FLAG.png', '') }
  for flag in all_flags
    if GameData::Species.get(flag.to_sym)
      eligible_flags << flag
    end
  end
  selectedFlags = eligible_flags.sample(4)
  echoln selectedFlags
  pbSet(VAR_GALLERY_TEAM_FLAGS, selectedFlags)
end

def displayTeamFlag(frame)
  selected_flags = pbGet(VAR_GALLERY_TEAM_FLAGS)
  flag_image_id = 10
  frame_image_id = 9
  flag = selected_flags[frame]
  species = GameData::Species.get(flag.to_sym)

  flag_path = "Trainer Card/backgrounds/flags/#{flag}_FLAG"

  x_position = 150
  y_position = 50
  $game_screen.pictures[flag_image_id].show(flag_path, 0, x_position, y_position, 50, 50)
  $game_screen.pictures[frame_image_id].show("teamFlagFrame", 0, x_position, y_position, 50, 50)
  name = species.real_name
  pbMessage("\"Team #{name} Flag\"")

  display_team_flag_statistics(species)

  # species_sprites = list_all_sprite_credits_for_pokemon(species)
  # unique_sprites = species_sprites.reject { |sprite_name, _| sprite_name.match(/[a-zA-Z]$/) }
  # percent = (unique_sprites.keys.length.to_f / (NB_POKEMON * 2)) * 100
  # pbMessage("Team #{name} completion: \\C[1]#{sprintf('%.2f', percent)}%")
  #
  # top_contributors = get_top_contributors_for_pokemon(species_sprites, 5)
  # echoln top_contributors
  #
  #
  # contributors_string = ""
  # top_contributors.keys.each_with_index do |spriter, index|
  #   contributors_string += "\\C[1]#{spriter}\\C[0]"
  #   contributors_string += " (#{top_contributors[spriter]} sprites)"
  #   contributors_string += "<br>" unless index == top_contributors.length - 1
  # end
  # pbMessage("Top contributors:<br>#{contributors_string}")

  flag_id = "flags/#{species.id.to_s}_FLAG"
  flag_name = "Team #{species.real_name}"
  prompt_flag_purchase(flag_id, flag_name, 5000)

  $game_screen.pictures[flag_image_id].erase
  $game_screen.pictures[frame_image_id].erase
end

def display_specific_pokemon_statistics()
  species_id = select_any_pokemon()
  return if !species_id
  species = GameData::Species.get(species_id)
  species_sprites = list_all_sprite_credits_for_pokemon(species)
  unique_sprites = filter_unique_sprites_nb_for_pokemon(species_sprites)
  percent = (unique_sprites.length.to_f / (NB_POKEMON * 2)) * 100
  pbMessage "#{species.real_name} completion: \\C[1]#{sprintf('%.2f', percent)}%\\C[0]"

  contributors_string = ""
  top_contributors = get_top_contributors_for_pokemon(species_sprites, 5)
  top_contributors.keys.each_with_index do |spriter, index|
    contributors_string += "\\C[1]#{spriter}\\C[0]"
    contributors_string += " (#{top_contributors[spriter]} sprites)"
    contributors_string += "<br>" unless index == top_contributors.length - 1
  end
  pbMessage("#{species.real_name} top contributors:<br>#{contributors_string}")
end

def display_team_flag_statistics(species)
  evolution_line = species.get_related_species
  flag_pokemon_name = species.name
  echoln evolution_line
  if evolution_line.length > 1
    pbMessage("This flag stands as a tribute to the artists who have devoted their talents to portraying \\C[1]#{flag_pokemon_name}\\C[0] and its evolution line in all its forms.")
  else
    pbMessage("This flag stands as a tribute to the artists who have devoted their talents to portraying \\C[1]#{flag_pokemon_name}\\C[0] in all its forms.")
  end
  all_sprites = []
  family_unique_sprites_nb = []
  for pokemon_id in evolution_line
    species = GameData::Species.get(pokemon_id)
    species_sprites = list_all_sprite_credits_for_pokemon(species)
    unique_sprites = filter_unique_sprites_nb_for_pokemon(species_sprites)
    all_sprites << species_sprites
    unique_sprites_nb = unique_sprites.length.to_f
    family_unique_sprites_nb << unique_sprites_nb
    percent = (unique_sprites.length.to_f / (NB_POKEMON * 2)) * 100
    pbMessage "#{species.real_name} completion: \\C[1]#{sprintf('%.2f', percent)}%\\C[0]" if evolution_line.length > 1
  end
  overall_total = 0
  family_unique_sprites_nb.each { |nb|
    overall_total += nb
  }
  overall_percent = (overall_total / ((NB_POKEMON * 2)*family_unique_sprites_nb.length))*100
  pbMessage "Team #{flag_pokemon_name} overall completion: \\C[3]#{sprintf('%.2f', overall_percent)}%\\C[0]"

  family_line_sprites = {}
  for pokemon_sprites in all_sprites
    family_line_sprites = family_line_sprites.merge(pokemon_sprites)
  end

  contributors_string = ""
  top_contributors = get_top_contributors_for_pokemon(family_line_sprites, 5)
  top_contributors.keys.each_with_index do |spriter, index|
    contributors_string += "\\C[1]#{spriter}\\C[0]"
    contributors_string += " (#{top_contributors[spriter]} sprites)"
    contributors_string += "<br>" unless index == top_contributors.length - 1
  end
  pbMessage("Team #{flag_pokemon_name} top contributors:<br>#{contributors_string}")

end

def filter_unique_sprites_nb_for_pokemon(species_sprites)
  unique_sprites = species_sprites.reject { |sprite_name, _| sprite_name.match(/[a-zA-Z]$/) }
  return unique_sprites
end

def display_special_banner()
  flag_id = "500000"
  flag_name = "Team 500,000"
  price = 10000

  banner_title = "Half-million Milestone Banner"
  flag_path = "Trainer Card/backgrounds/#{flag_id}"

  flag_image_id = 10
  frame_image_id = 9

  x_position = 150
  y_position = 50
  $game_screen.pictures[flag_image_id].show(flag_path, 0, x_position, y_position, 50, 50)
  $game_screen.pictures[frame_image_id].show("teamFlagFrame", 0, x_position, y_position, 50, 50)

  pbMessage("\"#{banner_title}\"")
  pbMessage("A banner honoring the 500,000 members of the community who have come together to inspire countless others.")
  pbWait(10)
  percent = get_total_completion_percent()
  pbMessage("All Pokémon completion: \\C[1]#{sprintf('%.2f', percent)}%")

  prompt_flag_purchase(flag_id, flag_name, price)
  $game_screen.pictures[flag_image_id].erase
  $game_screen.pictures[frame_image_id].erase
end

def prompt_flag_purchase(flag_id, flag_name, price)
  $Trainer.unlocked_card_backgrounds = [] if ! $Trainer.unlocked_card_backgrounds
  if !$Trainer.unlocked_card_backgrounds.include?(flag_id) && $Trainer.money >= price
    pbWait(20)
    if pbConfirmMessage("\\GWould you to purchase the \\C[1]#{flag_name}\\C[0] flag as a background for your \\C[1]Trainer Card\\C[0] for $#{price}?")
      pbSEPlay("Mart buy item")
      $Trainer.money -= price
      unlock_card_background(flag_id)
      pbMessage("\\GYou purchased the \\C[1]#{flag_name}\\C[0] Trainer Card background!")
      if pbConfirmMessage("Swap your current Trainer Card for the newly purchased one?")
        pbSEPlay("GUI trainer card open")
        $Trainer.card_background = flag_id
      else
        pbMessage("You can swap the background at anytime when viewing your Trainer Card.")
      end
    end
  end
end

def get_total_completion_percent()
  customSpritesList = $game_temp.custom_sprites_list.keys
  total_nb_pokemon = (NB_POKEMON * NB_POKEMON) + NB_POKEMON
  sprited_pokemon = customSpritesList.length
  return (sprited_pokemon.to_f / total_nb_pokemon) * 100
end

def get_top_contributors_for_pokemon(species_sprites, top_x)
  frequency = Hash.new(0)
  species_sprites.values.each { |str| frequency[str] += 1 }
  frequency.sort_by { |_, count| -count }.first(top_x).to_h
end

def list_all_sprite_credits_for_pokemon(species)
  dex_num = species.id_number
  sprites = {}
  filename = Settings::CREDITS_FILE_PATH
  File.readlines(filename).each do |line|
    split_line = line.strip.split(',')
    sprite = split_line[0]
    match = sprite.match(/(\d+)\.(\d+)/)
    next unless match # Skip if no match is found
    head_id = match[1].to_i
    tail_id = match[2].to_i

    artist = split_line[1]
    sprites[sprite] = artist if head_id == dex_num || tail_id == dex_num
  end
  return sprites
end

def displayGalleryFrame(frame)
  frame_image_id = 10
  bg_image_id = 9

  pif_sprite = pbGet(VAR_GALLERY_FEATURED_SPRITES)[frame]
  if !pif_sprite.is_a?(PIFSprite)
    pbMessage("The frame is empty...")
    return
  end
  species = getPokemonSpeciesFromPifSprite(pif_sprite)
  $game_screen.pictures[frame_image_id].show("pictureFrame_bg", 0, 0, 0)
  $game_screen.pictures[bg_image_id].show("pictureFrame", 0, 0, 0)
  name = species.real_name
  author = pbGet(259)
  message = "\"#{name}\"\nBy #{author}"
  displaySpriteWindowWithMessage(pif_sprite, message, 90, -10, 201)
  $game_screen.pictures[frame_image_id].erase
  $game_screen.pictures[bg_image_id].erase

end

def format_artist_name(full_name)
  return File.basename(full_name, '#*')
end

def getRandomSpriteArtist(creditsMap = nil, minimumNumberOfSprites = 10, giveUpAfterX = 50)
  creditsMap = map_sprites_by_artist if !creditsMap
  i = 0
  while i < giveUpAfterX
    artist = creditsMap.keys.sample
    return artist if creditsMap[artist].length >= minimumNumberOfSprites
  end
  return nil
end

def getSpriteCredits(spriteName)
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    if row[0] == (spriteName)
      return row[1]
    end
  end
  return nil
end

def formatList(list, separator)
  formatted = ""
  i = 0
  for element in list
    formatted << element
    formatted << separator if i < list.length
    i += 1
  end
end

def format_names_for_game_credits()
  spriters_map = get_top_artists(100)
  formatted = ""
  i = 1
  for spriter in spriters_map.keys
    formatted << spriter
    if i % 2 == 0
      formatted << "\n"
    else
      formatted << "<s>"
    end
    i += 1
  end
  return formatted
end


def get_spritename_from_path(file_path, includeExtension = false)
  filename_with_extension = File.basename(file_path)
  filename_without_extension = File.basename(filename_with_extension, ".*")
  return filename_with_extension if includeExtension
  return filename_without_extension
end

def getSpriterCreditForDexNumber(species_sym)
  #download sprite to make sure it's in the substitutions map
  body_id = getBodyID(species_sym)
  head_id = getHeadID(species_sym, body_id)
  spritename = "#{head_id}.#{body_id}"
  return getSpriteCredits(spritename)
end

#
# def getSpriterCreditForPokemon(species_sym)
#   p species_sym
#   #download sprite to make sure it's in the substitutions map
#   head_id = get_head_id_from_symbol(species_sym)
#   body_id = get_body_id_from_symbol(species_sym)
#
#   echoln head_id
#   echoln body_id
#   spritename = get_fusion_sprite_path(head_id,body_id)
#   p spritename
#   p getSpriteCredits(spritename)
#   return getSpriteCredits(spritename)
# end