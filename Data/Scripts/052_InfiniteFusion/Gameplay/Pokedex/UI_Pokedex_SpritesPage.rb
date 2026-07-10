# Todo: There are 2 modes in here:
# - Selecting a specific sprite
# - Selecting which sprites are available for that species (blacklist stuff)
# _
# It would be good to separate the logic into 2 different pages based on the same one instead of doing everything
# in this one

class PokemonGlobalMetadata
  attr_accessor :seen_sprites_tutorial
end

class PokemonPokedexInfo_Scene
  Y_POSITION_SMALL = 40 # 90
  Y_POSITION_BIG = 60
  X_POSITION_PREVIOUS = -30 # 20
  X_POSITION_SELECTED = 105
  X_POSITION_NEXT = 340 # 380

  Y_POSITION_BG_SMALL = 70
  Y_POSITION_BG_BIG = 93
  X_POSITION_BG_PREVIOUS = -1
  X_POSITION_BG_SELECTED = 145
  X_POSITION_BG_NEXT = 363

  def drawPageForms()
    #@selected_index=0
    @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_forms")
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    # alts_list= pbGetAvailableAlts
    @selected_index = 0 if !@selected_index
    update_displayed
  end

  def checkSpritesPageTutorial
    return unless $PokemonSystem.random_sprites
    return unless @selecting_blacklist
    return if $PokemonGlobal.seen_sprites_tutorial
    pbMessage(_INTL("Pokémon are assigned a random sprite when you encounter them in the wild."))
    pbMessage(_INTL("This page allows you to select the sprites that can appear for each Pokémon."))
    unless @pokemon
      pbMessage(_INTL("To change one of your caught Pokémon's sprite, you need to open its Pokédex entry from the the Pokémon's Summary page."))
    end
    $PokemonGlobal.seen_sprites_tutorial = true
  end

  def init_selected_bg
    @sprites["bgSelected_previous"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_previous"].x = X_POSITION_BG_PREVIOUS
    @sprites["bgSelected_previous"].y = Y_POSITION_BG_SMALL
    @sprites["bgSelected_previous"].setBitmap("Graphics/Pictures/Pokedex/bg_forms_selected_small")
    @sprites["bgSelected_previous"].visible = false

    @sprites["bgSelected_center"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_center"].x = X_POSITION_BG_SELECTED
    @sprites["bgSelected_center"].y = Y_POSITION_BG_BIG
    @sprites["bgSelected_center"].setBitmap("Graphics/Pictures/Pokedex/bg_forms_selected_large")
    @sprites["bgSelected_center"].visible = false

    @sprites["bgSelected_next"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_next"].x = X_POSITION_BG_NEXT
    @sprites["bgSelected_next"].y = Y_POSITION_BG_SMALL
    @sprites["bgSelected_next"].setBitmap("Graphics/Pictures/Pokedex/bg_forms_selected_small")
    @sprites["bgSelected_next"].visible = false

    @creditsOverlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap

  end

  def initializeSpritesPage(altsList)
    @forms_list = list_pokemon_forms()
    @formIndex = 0

    init_selected_bg
    @speciesData = getSpecies(@species)
    @species_id = @speciesData.species
    @selected_index = 0

    set_displayed_to_current_alt(altsList)

    @sprites["selectedSprite"] = IconSprite.new(0, 0, @viewport)
    @sprites["selectedSprite"].x = X_POSITION_SELECTED
    @sprites["selectedSprite"].y = Y_POSITION_BIG
    @sprites["selectedSprite"].z = 999999
    @sprites["selectedSprite"].visible = false
    @sprites["selectedSprite"].zoom_x = 1
    @sprites["selectedSprite"].zoom_y = 1

    @sprites["previousSprite"] = IconSprite.new(0, 0, @viewport)
    @sprites["previousSprite"].x = X_POSITION_PREVIOUS
    @sprites["previousSprite"].y = Y_POSITION_SMALL
    @sprites["previousSprite"].visible = false
    @sprites["previousSprite"].zoom_x = Settings::FRONTSPRITE_SCALE #/2
    @sprites["previousSprite"].zoom_y = Settings::FRONTSPRITE_SCALE #/2

    @sprites["nextSprite"] = IconSprite.new(0, 0, @viewport)
    @sprites["nextSprite"].x = X_POSITION_NEXT
    @sprites["nextSprite"].y = Y_POSITION_SMALL
    @sprites["nextSprite"].visible = false
    @sprites["nextSprite"].zoom_x = Settings::FRONTSPRITE_SCALE #/2
    @sprites["nextSprite"].zoom_y = Settings::FRONTSPRITE_SCALE #/2

    @sprites["selectedSprite"].z = 9999999
    @sprites["previousSprite"].z = 9999999
    @sprites["nextSprite"].z = 9999999

    @selected_pif_sprite = @available[@selected_index]
    @previous_pif_sprite = @available[@selected_index - 1]
    @next_pif_sprite = @available[@selected_index + 1]

    @sprites["selectedSprite"].bitmap = load_pif_sprite(@selected_pif_sprite)
    if altsList.size >= 2
      @sprites["nextSprite"].bitmap = load_pif_sprite(@next_pif_sprite)
      @sprites["nextSprite"].visible = true
    end

    if altsList.size >= 3
      animated_bitmap =
        @sprites["previousSprite"].bitmap = load_pif_sprite(@previous_pif_sprite)
      @sprites["previousSprite"].visible = true
    end

    @selecting_blacklist = $PokemonSystem.random_sprites && !@pokemon
    init_blacklist_icons
  end

  def init_blacklist_icons
    blacklist_icons_x_offset_big = 130
    blacklist_icons_y_offset_big = 235

    blacklist_icons_x_offset_small = 80
    blacklist_icons_y_offset_small = 140

    @sprites["selectedSprite_blacklistEnabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["selectedSprite_blacklistEnabled"].setBitmap("Graphics/Pictures/Pokedex/enabled_icon")
    @sprites["selectedSprite_blacklistEnabled"].x = X_POSITION_SELECTED + blacklist_icons_x_offset_big
    @sprites["selectedSprite_blacklistEnabled"].y = Y_POSITION_BIG + blacklist_icons_y_offset_big
    @sprites["selectedSprite_blacklistEnabled"].z = 9999999
    @sprites["selectedSprite_blacklistEnabled"].visible = false

    @sprites["selectedSprite_blacklistDisabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["selectedSprite_blacklistDisabled"].setBitmap("Graphics/Pictures/Pokedex/disabled_icon")
    @sprites["selectedSprite_blacklistDisabled"].x = X_POSITION_SELECTED + blacklist_icons_x_offset_big
    @sprites["selectedSprite_blacklistDisabled"].y = Y_POSITION_BIG + blacklist_icons_y_offset_big
    @sprites["selectedSprite_blacklistDisabled"].z = 9999999
    @sprites["selectedSprite_blacklistDisabled"].visible = false

    @sprites["selectedSprite_blacklistAutogen"] = IconSprite.new(0, 0, @viewport)
    @sprites["selectedSprite_blacklistAutogen"].setBitmap("Graphics/Pictures/Pokedex/autogen_icon")
    @sprites["selectedSprite_blacklistAutogen"].x = X_POSITION_SELECTED + blacklist_icons_x_offset_big
    @sprites["selectedSprite_blacklistAutogen"].y = Y_POSITION_BIG + blacklist_icons_y_offset_big
    @sprites["selectedSprite_blacklistAutogen"].z = 9999999
    @sprites["selectedSprite_blacklistAutogen"].visible = false
    ##############

    @sprites["previousSprite_blacklistEnabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["previousSprite_blacklistEnabled"].setBitmap("Graphics/Pictures/Pokedex/enabled_icon")
    @sprites["previousSprite_blacklistEnabled"].x = X_POSITION_PREVIOUS + blacklist_icons_x_offset_small
    @sprites["previousSprite_blacklistEnabled"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["previousSprite_blacklistEnabled"].z = 9999999
    @sprites["previousSprite_blacklistEnabled"].visible = false

    @sprites["previousSprite_blacklistDisabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["previousSprite_blacklistDisabled"].setBitmap("Graphics/Pictures/Pokedex/disabled_icon")
    @sprites["previousSprite_blacklistDisabled"].x = X_POSITION_PREVIOUS + blacklist_icons_x_offset_small
    @sprites["previousSprite_blacklistDisabled"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["previousSprite_blacklistDisabled"].z = 9999999
    @sprites["previousSprite_blacklistDisabled"].visible = false

    @sprites["previousSprite_blacklistAutogen"] = IconSprite.new(0, 0, @viewport)
    @sprites["previousSprite_blacklistAutogen"].setBitmap("Graphics/Pictures/Pokedex/autogen_icon")
    @sprites["previousSprite_blacklistAutogen"].x = X_POSITION_PREVIOUS + blacklist_icons_x_offset_small
    @sprites["previousSprite_blacklistAutogen"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["previousSprite_blacklistAutogen"].z = 9999999
    @sprites["previousSprite_blacklistAutogen"].visible = false

    ###################

    @sprites["nextSprite_blacklistEnabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["nextSprite_blacklistEnabled"].setBitmap("Graphics/Pictures/Pokedex/enabled_icon")
    @sprites["nextSprite_blacklistEnabled"].x = X_POSITION_NEXT + blacklist_icons_x_offset_small
    @sprites["nextSprite_blacklistEnabled"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["nextSprite_blacklistEnabled"].z = 9999999
    @sprites["nextSprite_blacklistEnabled"].visible = false

    @sprites["nextSprite_blacklistDisabled"] = IconSprite.new(0, 0, @viewport)
    @sprites["nextSprite_blacklistDisabled"].setBitmap("Graphics/Pictures/Pokedex/disabled_icon")
    @sprites["nextSprite_blacklistDisabled"].x = X_POSITION_NEXT + blacklist_icons_x_offset_small
    @sprites["nextSprite_blacklistDisabled"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["nextSprite_blacklistDisabled"].z = 9999999
    @sprites["nextSprite_blacklistDisabled"].visible = false

    @sprites["nextSprite_blacklistAutogen"] = IconSprite.new(0, 0, @viewport)
    @sprites["nextSprite_blacklistAutogen"].setBitmap("Graphics/Pictures/Pokedex/autogen_icon")
    @sprites["nextSprite_blacklistAutogen"].x = X_POSITION_NEXT + blacklist_icons_x_offset_small
    @sprites["nextSprite_blacklistAutogen"].y = Y_POSITION_SMALL + blacklist_icons_y_offset_small
    @sprites["nextSprite_blacklistAutogen"].z = 9999999
    @sprites["nextSprite_blacklistAutogen"].visible = false
  end

  def setBlacklistIconDisabled(spritename)
    @sprites["#{spritename}_blacklistEnabled"].visible = false
    @sprites["#{spritename}_blacklistDisabled"].visible = true
  end

  def setBlacklistIconEnabled(spritename)
    @sprites["#{spritename}_blacklistEnabled"].visible = true
    @sprites["#{spritename}_blacklistDisabled"].visible = false
  end

  def hide_blacklist_icons
    @sprites["nextSprite_blacklistDisabled"].visible = false
    @sprites["nextSprite_blacklistEnabled"].visible = false
    @sprites["nextSprite_blacklistAutogen"].visible = false

    @sprites["selectedSprite_blacklistDisabled"].visible = false
    @sprites["selectedSprite_blacklistEnabled"].visible = false
    @sprites["selectedSprite_blacklistAutogen"].visible = false

    @sprites["previousSprite_blacklistDisabled"].visible = false
    @sprites["previousSprite_blacklistEnabled"].visible = false
    @sprites["previousSprite_blacklistAutogen"].visible = false
  end

  def update_blacklist_icons
    $PokemonSystem.sprites_blacklist = {} unless $PokemonSystem.sprites_blacklist
    species_blacklist = $PokemonSystem.sprites_blacklist[@species_id]
    species_blacklist = initialize_species_blacklist(@species_id) unless species_blacklist

    # previous sprite
    previous_position = @selected_index - 1 < 0 ? @available.length - 1 : @selected_index - 1
    current_position = @selected_index
    next_position = @selected_index + 1 > @available.length - 1 ? 0 : @selected_index + 1

    setIconStatus("previousSprite", previous_position, species_blacklist)
    setIconStatus("selectedSprite", current_position, species_blacklist)
    setIconStatus("nextSprite", next_position, species_blacklist)
  end

  def setIconStatus(iconName, position, species_blacklist)
    sprite = @available[position]
    if sprite.type == :AUTOGEN && @available.length == 1
      if @available.length > 1
        setBlacklistIconDisabled(iconName)
      else
        setBlacklistIconEnabled(iconName)
      end
    else
      if species_blacklist.include?(sprite.alt_letter)
        setBlacklistIconDisabled(iconName)
      else
        setBlacklistIconEnabled(iconName)
      end
    end

  end

  def load_pif_sprite(pif_sprite)
    animated_bitmap = @spritesLoader.load_pif_sprite_directly(pif_sprite) if pif_sprite
    return animated_bitmap.bitmap if animated_bitmap
    return nil
  end

  def get_substitution_id(dex_number)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      species_id = [head_id, body_id]
    else
      species_id = dex_number
    end
    return species_id
  end

  def set_displayed_to_current_alt(altsList)
    if @pokemon && @pokemon.pif_sprite
      current_sprite = @pokemon.pif_sprite
    else
      dex_number = getDexNumberForSpecies(@species)
      species_id = get_substitution_id(dex_number)
      initialize_alt_sprite_substitutions()
      return if !$PokemonSystem.alt_sprite_substitutions[species_id]
      current_sprite = $PokemonSystem.alt_sprite_substitutions[species_id]
    end
    index = @selected_index
    for alt in altsList
      if alt.alt_letter == current_sprite.alt_letter
        @selected_index = index
        return
      end
      index += 1
    end
  end

  SHARED_BODIES = {}
  SHARED_HEADS = {}
  def get_shared_bodies
    #return SHARED_BODIES
    return {
      GameData::Species.get(NB_POKEMON-3).species => GameData::Species.get(NB_POKEMON-1).species,
      GameData::Species.get(NB_POKEMON-1).species => GameData::Species.get(NB_POKEMON-3).species,
      GameData::Species.get(NB_POKEMON-2).species => GameData::Species.get(NB_POKEMON).species,
      GameData::Species.get(NB_POKEMON).species => GameData::Species.get(NB_POKEMON-2).species,
    }
  end

  def get_shared_heads
    return SHARED_HEADS
  end

  def list_shared_sprites(species_id)
    pokedexUtils = PokedexUtils.new
    shared_alts = []

    body_num, head_num = splitHeadBody(species_id)
    if body_num && head_num # fusion
      body_species = GameData::Species.get(body_num)&.species
      head_species = GameData::Species.get(head_num)&.species

      shared_bodies = get_shared_bodies
      shared_heads = get_shared_heads
      if shared_bodies[body_species]
        shared_dex_num = GameData::Species.get(shared_bodies[body_species]).id_number
        fusion_species = getFusedPokemonIdFromDexNum(shared_dex_num, head_num)
        fusion_number = GameData::Species.get(fusion_species).id_number
        shared_body_alts = pokedexUtils.pbGetAvailableAlts(fusion_number, false)
        shared_body_sprites = []
        shared_body_alts.each do |alt|
          shared_body_sprites << get_pif_sprite(alt, fusion_species)
        end
        shared_alts += shared_body_sprites
      end

      if shared_heads[head_species]
        shared_dex_num = GameData::Species.get(shared_heads[head_species]).id_number
        fusion_species = getFusedPokemonIdFromDexNum(body_num, shared_dex_num)
        fusion_number = GameData::Species.get(fusion_species).id_number
        shared_head_alts = pokedexUtils.pbGetAvailableAlts(fusion_number, false)
        shared_head_sprites = []
        shared_head_alts.each do |alt|
          shared_head_sprites << get_pif_sprite(alt, fusion_species)
        end
        shared_alts += shared_head_sprites
      end
    end

    return shared_alts
  end

  def pbGetAvailableForms(species = nil)
    pokedexUtils = PokedexUtils.new

    chosen_species = species != nil ? species : @species

    species_data = GameData::Species.get(chosen_species)
    dex_num = species_data.id_number
    includeAutogens = isFusion(dex_num)
    available_alt_letters = pokedexUtils.pbGetAvailableAlts(dex_num, includeAutogens)

    available_sprites = []
    available_alt_letters.each do |alt|
      available_sprites << get_pif_sprite(alt,chosen_species)
    end

    available_sprites += list_shared_sprites(species_data.species)
    return available_sprites
  end

  def hide_all_selected_windows
    @sprites["bgSelected_previous"].visible = false if @sprites["bgSelected_previous"]
    @sprites["bgSelected_center"].visible = false if @sprites["bgSelected_center"]
    @sprites["bgSelected_next"].visible = false if @sprites["bgSelected_next"]
  end

  def update_selected
    hide_all_selected_windows
    previous_index = @selected_index == 0 ? @available.size - 1 : @selected_index - 1
    next_index = @selected_index == @available.size - 1 ? 0 : @selected_index + 1

    @available[@selected_index]
    @sprites["bgSelected_previous"].visible = true if is_main_sprite(previous_index) && @available.size > 2
    @sprites["bgSelected_center"].visible = true if is_main_sprite(@selected_index)
    @sprites["bgSelected_next"].visible = true if is_main_sprite(next_index) && @available.size > 1
  end

  def get_pif_sprite(alt_letter, species = nil)
    species = @species unless species
    dex_number = getDexNumberForSpecies(species) #@species is a symbol when called from the summary screen and an int from the pokedex... Would be nice to refactor
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)

      # Autogen sprite
      if alt_letter == "autogen"
        pif_sprite = PIFSprite.new(:AUTOGEN, head_id, body_id, "autogen")
        # Imported custom sprite
      else
        # Spritesheet custom sprite
        pif_sprite = PIFSprite.new(:CUSTOM, head_id, body_id, alt_letter)
      end
    else
      pif_sprite = PIFSprite.new(:BASE, dex_number, nil, alt_letter)
    end
    # use local sprites instead if they exist
    if alt_letter && isLocalSprite(alt_letter)
      sprite_path = alt_letter.split("_", 2)[1]
      pif_sprite.local_path = sprite_path
    end
    # pif_sprite.dump_info
    return pif_sprite
  end

  def isLocalSprite(alt_letter)
    return alt_letter.start_with?("local_")
  end

  def isBaseSpritePath(path)
    filename = File.basename(path).downcase
    return filename.match?(/\A\d+\.png\Z/)
  end

  def update_displayed
    nextIndex = @selected_index + 1
    previousIndex = @selected_index - 1
    if nextIndex > @available.size - 1
      nextIndex = 0
    end
    if previousIndex < 0
      previousIndex = @available.size - 1
    end
    @selected_pif_sprite = @available[@selected_index]

    @previous_pif_sprite = @available[previousIndex]
    @next_pif_sprite = @available[nextIndex]

    @sprites["previousSprite"].bitmap = load_pif_sprite(@previous_pif_sprite) if previousIndex != nextIndex
    @sprites["selectedSprite"].bitmap = load_pif_sprite(@selected_pif_sprite)
    @sprites["nextSprite"].bitmap = load_pif_sprite(@next_pif_sprite)

    # selected_bitmap = @sprites["selectedSprite"].getBitmap
    # sprite_path = selected_bitmap.path
    # isBaseSprite = isBaseSpritePath(@available[@selected_index])
    @displayed_pif_sprite=  @selected_pif_sprite
    is_generated = @selected_pif_sprite&.type == :AUTOGEN
    spritename = @selected_pif_sprite&.to_filename()
    showSpriteCredits(spritename, is_generated)
    update_selected
  end

  def showSpriteCredits(filename, generated_sprite = false)
    return unless filename
    @creditsOverlay.dispose

    spritename = File.basename(filename, '.*')

    if !generated_sprite
      discord_name = getSpriteCredits(spritename)
      discord_name = "Unknown artist" if !discord_name
    else
      # todo give credits to Japeal - need to differenciate unfused sprites
      discord_name = "" #"Japeal\n(Generated)"
    end
    discord_name = "Imported sprite" if @selected_pif_sprite.local_path
    author_name = File.basename(discord_name, '#*')

    x = Graphics.width / 2
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)
    @creditsOverlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap
    split_name = splitSpriteCredits(author_name, @creditsOverlay, @creditsOverlay.width - 20)
    line_height = @creditsOverlay.text_size(author_name).height
    textpos = split_name.each_with_index.map { |name, index|
      y = (Graphics.height - 60) + (line_height * ((index + 1) - ((split_name.length.to_f + 1) / 2)))
      [name, x, y, 2, label_base_color, label_shadow_color]
    }
    pbDrawTextPositions(@creditsOverlay, textpos)
  end

  def list_pokemon_forms
    dexNum = dexNum(@species)
    if dexNum > NB_POKEMON
      body_id = getBodyID(dexNum)
    else
      if @species.is_a?(Symbol)
        body_id = get_body_number_from_symbol(@species)
      else
        body_id = dexNum
      end
    end
    forms_list = []
    found_last_form = false
    form_index = 0
    while !found_last_form
      form_index += 1
      form_path = Settings::BATTLERS_FOLDER + body_id.to_s + "_" + form_index.to_s
      if File.directory?(form_path)
        forms_list << form_index
      else
        found_last_form = true
      end
    end
    return forms_list
  end

  def pbChooseAlt(brief = false)
    checkSpritesPageTutorial
    @selecting_sprites = true
    updateBlackListInstructionIcons
    update_blacklist_icons if @selecting_blacklist
    if @available.size <= 0
      pbPlayBuzzerSE
      return
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate

      @sprites["leftarrow"].visible = true
      @sprites["rightarrow"].visible = true
      @sprites["uparrow"].visible = @forms_list.length > 0
      @sprites["downarrow"].visible = @forms_list.length > 0

      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @selected_index = (@selected_index - 1) % @available.size
        update_displayed
        update_blacklist_icons if @selecting_blacklist
        updateBlacklistIconVisibility
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @selected_index = (@selected_index + 1) % @available.size
        update_displayed
        update_blacklist_icons if @selecting_blacklist
        updateBlacklistIconVisibility
      elsif Input.trigger?(Input::USE)
        if @selecting_blacklist
          toggle_sprite_blacklist
          update_blacklist_icons
          updateBlacklistIconVisibility
        else
          pbPlayDecisionSE
          if select_species_sprite(brief)
            @endscene = true
            break
          end
        end

      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        @sprites["leftarrow"].visible = false
        @sprites["rightarrow"].visible = false
        break

      elsif Input.trigger?(Input::UP) && @selecting_blacklist
        pbPlayCancelSE
        @sprites["leftarrow"].visible = false
        @sprites["rightarrow"].visible = false
        @selecting_blacklist = false
      end
    end
    @selecting_blacklist = false
    @selecting_sprites = false
    hide_blacklist_icons
    @sprites["uparrow"].visible = false
    @sprites["downarrow"].visible = false
    updateBlackListInstructionIcons
  end

  def is_main_sprite(index = nil)
    if !index
      index = @selected_index
    end
    if @pokemon && @pokemon.pif_sprite && $PokemonSystem.random_sprites
      selected_pif_sprite = @available[index]
      return false unless selected_pif_sprite
      same_alt = selected_pif_sprite.alt_letter == @pokemon.pif_sprite.alt_letter
      same_species = selected_pif_sprite.species == @pokemon.pif_sprite.species
      return same_alt && same_species
    else
      dex_number = getDexNumberForSpecies(@species)
      species_id = get_substitution_id(dex_number)
      current_pif_sprite = $PokemonSystem.alt_sprite_substitutions[species_id]
      selected_pif_sprite = @available[index]

      if current_pif_sprite
        return current_pif_sprite.equals(selected_pif_sprite)
      end
      return false
    end
  end

  def sprite_is_alt(sprite_path)
    spritename = File.basename(sprite_path, '.*')
    return spritename.match?(/[a-zA-Z]/)
  end

  def toggle_sprite_blacklist
    $PokemonSystem.sprites_blacklist ||= {}
    species_blacklist = $PokemonSystem.sprites_blacklist[@species_id]
    species_blacklist ||= initialize_species_blacklist(@species_id)

    selected_letter = @available[@selected_index].alt_letter

    total = @available.length
    blacklisted = species_blacklist.length
    allowed = total - blacklisted

    if species_blacklist.include?(selected_letter)
      pbSEPlay("GUI storage put down")
      species_blacklist.delete(selected_letter)
    else
      if allowed <= 1
        pbPlayBuzzerSE()
        pbMessage(_INTL("You need to allow at least one sprite!"))
        return
      end
      pbSEPlay("GUI storage pick up")
      species_blacklist << selected_letter
    end

    $PokemonSystem.sprites_blacklist[@species_id] = species_blacklist
  end

  def select_species_sprite(brief = false)
    if @available.length > 1
      if is_main_sprite()
        if brief
          pbMessage(_INTL("This sprite will remain the displayed sprite"))
          return true
        else
          pbMessage(_INTL("This sprite is already the displayed sprite"))
        end
      else
        message = _INTL("Would you like to use this sprite instead of the current sprite?")
        message = _INTL("Would you like to use this sprite instead of the current sprite for the entire species?") unless @pokemon
        if pbConfirmMessage(message)
          swap_main_sprite()
          return true
        end
      end
    else
      pbMessage(_INTL("This is the only sprite available for this Pokémon!"))
    end
    return false
  end

  def swap_main_sprite
    species_number = dexNum(@species)
    substitution_id = get_substitution_id(species_number)
    $PokemonSystem.alt_sprite_substitutions[substitution_id] = @selected_pif_sprite
    if @pokemon
      @pokemon.pif_sprite = @selected_pif_sprite
    end
  end
end

class PokemonSystem
  attr_accessor :alt_sprite_substitutions
  attr_accessor :sprites_blacklist

end
