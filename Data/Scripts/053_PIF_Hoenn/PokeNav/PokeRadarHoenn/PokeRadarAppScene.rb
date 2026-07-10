# todo:
# When all pokemon in the route are seen, can "scan" for species
#  - spawns a pokemon of that species nearby with notice behavior to flee
class PokeRadarAppScene < PokeNavAppScene
  INFO_TEXT_Y = 270

  def header_name
    return _INTL("PokéRadar")
  end

  def cursor_path
    return "Graphics/Pictures/Pokeradar/icon_button"
  end

  def header_path
    return "Graphics/Pictures/Pokeradar/bg_header"
  end

  def display_mode
    return :GRID
  end

  def x_gap
    return 75;
  end

  def y_gap
    return 50;
  end

  def columns
    return 6
  end

  def visible_rows
    return 3
  end

  def start_x
    return 40;
  end

  def start_y
    return 80;
  end

  def pbStartScene(main_menu_scene)
    @unseenPokemon = [] unless @unseenPokemon
    @seenPokemon = [] unless @seenPokemon
    @pokenav_main_menu_scene = main_menu_scene
    if $PokemonTemp.pokeradar
      buttons = showCurrentScanningTarget
      super(buttons)
    else
      buttons = showWildPokemonList
      super(buttons)
      showSelectedPokemonInfo
    end
    showHeaderInfo
  end

  def showSelectedPokemonInfo
    hover(@buttons[@index]&.id)
    if @unseenPokemon.empty? && @seenPokemon.empty?
      showEmpty
    end
  end

  def showHeaderInfo
    showBattery
    showHeaderName
    showAreaName
    showWeatherIcon
  end

  def showWildPokemonList
    @encounter_type = $PokemonEncounters.encounter_type
    @weatherEncounters = $PokemonEncounters.list_weather_encounters_species(@encounter_type)

    @unseenPokemon = listPokemonInCurrentRoute(@encounter_type, false, true, true)
    @seenPokemon = listPokemonInCurrentRoute(@encounter_type, true, false, true)
    buttons = []
    @seenPokemon.each do |pokemon_species|
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path, false)
      button = PokenavButton.new(pokemon_species, bmp)
      button.crop_width = button.icon_bitmap.bitmap.width / 2
      button.refresh
      buttons << button if button
    end
    @unseenPokemon.each do |pokemon_species|
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path, true)
      button = PokenavButton.new(pokemon_species, bmp)
      button.crop_width = button.icon_bitmap.bitmap.width / 2
      button.refresh
      buttons << button
    end
    return buttons
  end

  def createCursor
    return if $PokemonTemp.pokeradar
    super
  end

  def showEmpty
    Kernel.pbDisplayText(_INTL("No wild Pokémon found nearby."), Graphics.width / 2, Graphics.height / 2, nil, @text_color_base, @text_color_shadow)
    Kernel.pbDisplayText(_INTL("Stand in tall grass to start scanning."), Graphics.width / 2,( Graphics.height / 2)+32, nil, @text_color_base, @text_color_shadow)

  end

  def showCurrentScanningTarget
    scanningPokemon = $PokemonTemp.pokeradar[0]
    icon_path = pbCheckPokemonIconFiles(scanningPokemon)
    bmp = load_bitmap(icon_path, false)
    button = PokenavButton.new(scanningPokemon, bmp)
    button.refresh
    species_name = GameData::Species.get(scanningPokemon).name
    Kernel.pbDisplayText(_INTL("Currently scanning for {1}.", species_name), Graphics.width / 2, 200, 500000, @text_color_base, @text_color_shadow)
    Kernel.pbDisplayText(_INTL("Current chain: {1}.", $PokemonTemp.pokeradar[2]), Graphics.width / 2, 230, 500000, @text_color_base, @text_color_shadow)
    return [button]
  end

  def load_bitmap(path, dark = false)
    return nil unless path && path != ""
    bmp = Bitmap.new(path)

    if dark
      darken_bitmap(bmp, 220) # strength 0–255
    end

    return AnimatedBitmap.from_bitmap(bmp)
  end

  def darken_bitmap(bmp, amount)
    for x in 0...bmp.width
      for y in 0...bmp.height
        pixel = bmp.get_pixel(x, y)
        next if pixel.alpha == 0

        factor = (255 - amount) / 255.0
        r = (pixel.red * factor).to_i
        g = (pixel.green * factor).to_i
        b = (pixel.blue * factor).to_i

        bmp.set_pixel(x, y, Color.new(r, g, b, pixel.alpha))
      end
    end
  end

  #[rareness, species, minLevel, maxLevel]
  def get_encounter(species,include_weather=true)
    for encounter in $PokemonEncounters.listPossibleEncounters(@encounter_type, include_weather)
      if encounter[1] == species
        return encounter
      end
    end
    return nil
  end

  def get_weather_encounter(species)
    for encounter in $PokemonEncounters.list_weather_encounters(@encounter_type)
      if encounter[1] == species
        return encounter
      end
    end
    return nil
  end


  def get_energy_for_scan(species)
    encounter = get_encounter(species)
    if @weatherEncounters.include?(species)
      base_rareness = encounter[0]
      rareness =calculate_weather_encounter_rareness(encounter,base_rareness)
    else
      rareness = encounter[0]
    end
    energy = (110 - rareness) * 5
    (energy / 50.0).round * 50
  end

  def get_rarity_flavor_text(species)
    encounter = get_encounter(species,false)
    weather_encounter = get_weather_encounter(species)

    return unless encounter || weather_encounter
    if (encounter && encounter[1] == species) || (weather_encounter && weather_encounter[1] == species)
      base_rareness =0
      base_rareness = encounter[0] if encounter
      base_rareness = weather_encounter[0] if weather_encounter
      if @weatherEncounters.include?(species)
        rareness = calculate_weather_encounter_rareness(weather_encounter,base_rareness)
      else
        rareness = base_rareness
      end
      if rareness < 5
        text = _INTL("Very rare")
      elsif rareness < 10
        text = _INTL("Rare")
      elsif rareness < 25
        text = _INTL("Uncommon")
      elsif rareness < 40
        text = _INTL("Common")
      else
        text = _INTL("Very Common")
      end
      return text
    end
  end

  def calculate_weather_encounter_rareness(encounter,base_rareness)
    map_weather = $game_weather.current_weather[$game_map.map_id]
    if map_weather
      weather_intensity = map_weather[1]
      weather_intensity = 0 if !weather_intensity
      chance_of_weather_encounter = $PokemonEncounters.weather_encounter_chance(weather_intensity)
      weather_rareness = encounter[0]
      return weather_rareness * (chance_of_weather_encounter.to_f / 100) * (base_rareness/100)
    end
    return 0
  end

  def click(button_id)
    species = button_id
    if $PokemonTemp.pokeradar
      click_stop_scan(species)
    else
      if @seenPokemon.include?(species)
        click_seen(species)
      else
        click_unseen
      end

    end
    super
  end

  def hover(button_id)
    return if $PokemonTemp.pokeradar
    if @seenPokemon.include?(button_id)
      hover_seen(button_id)
    else
      hover_unseen
    end
    super
  end

  def click_stop_scan(species)
    species_name = GameData::Species.get(species).name
    options = []
    cmd_stop_scan = _INTL("Stop Scanning")
    cmd_cancel = _INTL("Cancel")
    options << cmd_stop_scan
    options << cmd_cancel
    Kernel.pbClearText()
    showHeaderInfo
    chosen = pbMessage(_INTL("You are currently scanning for {1}.", species_name), options, options.length)
    case options[chosen]
    when cmd_stop_scan
      $PokemonTemp.pokeradar = nil
      pbEndScene
      pbStartScene(@pokenav_main_menu_scene)
    else
      showCurrentScanningTarget
      return
    end

  end

  def click_seen(species)
    options = []
    cmd_scan = _INTL("Scan")
    cmd_cancel = _INTL("Cancel")
    options << cmd_scan
    options << cmd_cancel
    Kernel.pbClearText()
    showHeaderInfo
    chosen = pbMessage(_INTL("What would you like to do?"), options, options.length)
    case options[chosen]
    when cmd_scan
      energy_needed = get_energy_for_scan(species)
      if Settings::POKERADAR_BATTERY_STEPS - $PokemonGlobal.pokeradarBattery >= energy_needed
        $PokemonGlobal.pokeradarBattery += energy_needed
        displayTextElements
        @exiting = true

        pbEndScene
        @pokenav_main_menu_scene.exiting = true
        @pokenav_main_menu_scene.pbEndScene

        encounter = get_encounter(species)
        min_level = encounter[2]
        max_level = encounter[3]
        level = rand(min_level..max_level)
        pbWait(16)
        pbMessage(_INTL("Scanning for {1}...\\wtnp[5]", GameData::Species.get(species).name))
        possible_tiles = getTerrainTilesNearPlayer(getTerrainType, 3)
        position = possible_tiles.sample
        if position
          set_pokeradar_data(species, level, position)
          spawn_pokeradar_pokemon(species, level)
        else
          pbPokeRadarCancel
          pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
        end
      else
        pbPokeRadarCancel
        Kernel.pbClearText()
        showHeaderInfo
        pbMessage(_INTL("The battery is not charged enough for this scan!"))
        showSelectedPokemonInfo
      end
    else
      showSelectedPokemonInfo
      return
    end
  end



  def click_unseen
    return unless @unseenPokemon.any?
    Kernel.pbClearText()
    showHeaderInfo
    pbMessage(_INTL("You need to encounter the Pokémon before you can scan for it."))
    hover_unseen
  end

  def hover_seen(species)
    displayTextElements
    pokemon_name = GameData::Species.get(species).name
    Kernel.pbDisplayText(pokemon_name, Graphics.width / 2, INFO_TEXT_Y, 99999, @text_color_base, @text_color_shadow)
    Kernel.pbDisplayText(get_rarity_flavor_text(species), Graphics.width / 2, INFO_TEXT_Y + 30, 99999, @text_color_base, @text_color_shadow)
    Kernel.pbDisplayText(_INTL("Battery for scan: {1}", get_energy_for_scan(species)), Graphics.width / 2, INFO_TEXT_Y + 60, 99999, @text_color_base, @text_color_shadow)
  end

  def hover_unseen()
    return unless @unseenPokemon.any?
    displayTextElements
    pokemon_name = _INTL("Unknown Pokémon")
    Kernel.pbDisplayText(pokemon_name, Graphics.width / 2, INFO_TEXT_Y, 999999, @text_color_base, @text_color_shadow)
  end

  def displayTextElements
    super
    showBattery
    showAreaName

  end

  def showBattery
    $PokemonGlobal.pokeradarBattery = Settings::POKERADAR_BATTERY_STEPS unless $PokemonGlobal.pokeradarBattery
    battery_power = Settings::POKERADAR_BATTERY_STEPS - $PokemonGlobal.pokeradarBattery
    Kernel.pbDisplayText(_INTL("{1}/1000", battery_power), 450, HEADER_HEIGHT,nil, @text_color_base, @text_color_shadow)
  end

  def showAreaName
    map_name = getMapName($game_map.map_id)
    text = _INTL("{1}", map_name)
    encounter_type = get_encounter_type_name
    if encounter_type && !encounter_type.empty?
      text += _INTL(" ({1})", encounter_type)
    end
    Kernel.pbDisplayText(text, Graphics.width / 2, 40,nil, @text_color_base, @text_color_shadow)
  end

  def showWeatherIcon
    icon_path = get_current_weather_icon
    return unless icon_path
    @sprites["weather"] = IconSprite.new(400, 48, @viewport)
    @sprites["weather"].setBitmap(icon_path)
    @sprites["weather"].z = 100000
  end

  def get_encounter_type_name
    encounter_type = $PokemonEncounters.encounter_type
    case encounter_type
    when :Land
      return _INTL("Grass")
    when :Land1
      return _INTL("Clovers")
    when :Land2
      return _INTL("Dry Grass")
    when :Land3
      return _INTL("Flowers")
    when :LandMorning, :LandDay, :LandNight
      return _INTL("Grass")
    when :WaterMorning, :WaterDay, :WaterNight
      return _INTL("Water")
    when :TallGrass
      return _INTL("Tall Grass")
    else
      return encounter_type.to_s
    end
  end

end

def getTerrainType
  encounter_type = $PokemonEncounters.encounter_type
  case encounter_type
  when :Land, :Land1, :Land2, :Land3, :LandMorning, :LandDay, :LandNight, :TallGrass
    return :Grass
  else
    return encounter_type
  end
end

def continue_pokeradar_app_chain()
  pbWait(12)
  species = $PokemonTemp.pokeradar[0]
  level = $PokemonTemp.pokeradar[1]
  possible_tiles = getTerrainTilesNearPlayer(getTerrainType, 3)
  position = possible_tiles.sample
  if position
    set_pokeradar_data(species, level, position)
    spawn_pokeradar_pokemon(species, level)
  else
    pbPokeRadarCancel
    pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
  end
end

def update_pokeradar_overworld_ui
  if $PokemonTemp.pokeradar
    current_chain = $PokemonTemp.pokeradar[2]
    return unless current_chain >= 1
    species = $PokemonTemp.pokeradar[0]
    $PokemonTemp.pokeradar_ui.dispose if $PokemonTemp.pokeradar_ui
    $PokemonTemp.pokeradar_ui = PokeRadar_UI.new([species], [], [])
    if current_chain >= 40
      $PokemonTemp.pokeradar_ui.set_text(_INTL("PokéRadar Chain: {1}", current_chain), 72, 12, pbColor(:GREEN), pbColor(:DARKGREEN))
    else
      $PokemonTemp.pokeradar_ui.set_text(_INTL("PokéRadar Chain: {1}", current_chain), 72, 12)
    end
  else
    $PokemonTemp.pokeradar_ui.dispose if $PokemonTemp.pokeradar_ui
  end

end

def spawn_pokeradar_pokemon(species, level)
  max_attempts = 50
  return unless species && level

  pbWait(20)
  playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, $game_player.x, $game_player.y)
  pbWait(10)

  spawned_events = nil
  radius = 4
  max_radius = 8
  max_attempts.times do |current_attempt|
    radius += 1 if current_attempt > 0 && current_attempt % 10 == 0
    radius += (current_attempt / 10).floor
    radius = [radius, max_radius].min
    spawned_events = spawn_ow_pokemon(species, level, 1, radius)
    break if spawned_events&.length.to_i > 0
  end

  if spawned_events&.length.to_i > 0
    event = spawned_events[0]
    grass = $PokemonTemp&.pokeradar[3]

    if grass && grass[3] == 2
      pbSEPlay("shiny", 60)
      playAnimation(Settings::SPARKLE_SHORT_ANIMATION_ID, event.x, event.y)
      event.make_shiny
    end

    #todo: MAYBE increase the move frequency past a certain chain number (50?) to make it more difficult
    event.behavior_roaming    = :look_around_player
    event.behavior_noticed    = event.pokemon.shiny? ? :curious : :flee
    event.update_movement_type
    event.turn_away_from_player
    playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, event.x, event.y)
  else
    echoln "failed to spawn after #{max_attempts} attempts"
    pbPokeRadarCancel
    pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
  end

  update_pokeradar_overworld_ui
end

# Reusing the old pokeradar mechanics for chaining
def set_pokeradar_data(species, level, position)
  x = position[0]
  y = position[1]

  existing_chain = ($PokemonTemp.pokeradar && $PokemonTemp.pokeradar[2]) ? $PokemonTemp.pokeradar[2] : 0

  $PokemonTemp.pokeradar = [0, 0, 0, []] unless $PokemonTemp.pokeradar
  $PokemonTemp.pokeradar[0] = species
  $PokemonTemp.pokeradar[1] = level
  $PokemonTemp.pokeradar[2] = existing_chain
  $PokemonTemp.pokeradar[3] = [x, y, 0, determine_shininess]
end

def determine_shininess
  chain_length = ($PokemonTemp.pokeradar && $PokemonTemp.pokeradar[2]) ? $PokemonTemp.pokeradar[2] : 0
  rarity = (rand(100) < 25) ? 1 : 0
  if chain_length > 0
    capped_chain = [chain_length, 40].min
    shiny_threshold = [(65536 / Settings::SHINY_POKEMON_CHANCE) - capped_chain * 200, 200].max
    shiny_divisor = 0xFFFF / shiny_threshold
    shiny_roll = rand(65536) / shiny_divisor
    rarity = 2 if shiny_roll == 0
  end
  return rarity
end


Events.onMapChange += proc { |_sender, e|
  pbPokeRadarCancel
}


