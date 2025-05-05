class PokemonPokedexInfo_Scene
  #todo add indicator to show which one is the main sprite -
  # also maybe add an indicator in main list for when a sprite has available alts

  Y_POSITION_SMALL = 40 #90
  Y_POSITION_BIG = 60
  X_POSITION_PREVIOUS = -30 #20
  X_POSITION_SELECTED = 105
  X_POSITION_NEXT = 340 #380

  Y_POSITION_BG_SMALL = 70
  Y_POSITION_BG_BIG = 93
  X_POSITION_BG_PREVIOUS = -1
  X_POSITION_BG_SELECTED = 145
  X_POSITION_BG_NEXT = 363

  def drawPageForms()
    #@selected_index=0
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    #alts_list= pbGetAvailableAlts
    @selected_index = 0 if !@selected_index
    update_displayed
  end

  def init_selected_bg
    @sprites["bgSelected_previous"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_previous"].x = X_POSITION_BG_PREVIOUS
    @sprites["bgSelected_previous"].y = Y_POSITION_BG_SMALL
    @sprites["bgSelected_previous"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms_selected_small"))
    @sprites["bgSelected_previous"].visible = false

    @sprites["bgSelected_center"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_center"].x = X_POSITION_BG_SELECTED
    @sprites["bgSelected_center"].y = Y_POSITION_BG_BIG
    @sprites["bgSelected_center"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms_selected_large"))
    @sprites["bgSelected_center"].visible = false

    @sprites["bgSelected_next"] = IconSprite.new(0, 0, @viewport)
    @sprites["bgSelected_next"].x = X_POSITION_BG_NEXT
    @sprites["bgSelected_next"].y = Y_POSITION_BG_SMALL
    @sprites["bgSelected_next"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms_selected_small"))
    @sprites["bgSelected_next"].visible = false

    @creditsOverlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap

  end

  def initializeSpritesPage(altsList)
    @forms_list = list_pokemon_forms()
    @formIndex = 0

    init_selected_bg
    @speciesData = getSpecies(@species)

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

    @selected_pif_sprite = get_pif_sprite(@available[@selected_index])
    @previous_pif_sprite = get_pif_sprite(@available[@selected_index - 1])
    @next_pif_sprite = get_pif_sprite(@available[@selected_index + 1])

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

  end

  def load_pif_sprite(pif_sprite)
    animated_bitmap = @spritesLoader.load_pif_sprite_directly(pif_sprite)
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
    dex_number = getDexNumberForSpecies(@species)
    species_id = get_substitution_id(dex_number)
    initialize_alt_sprite_substitutions()
    return if !$PokemonGlobal.alt_sprite_substitutions[species_id]

    current_sprite = $PokemonGlobal.alt_sprite_substitutions[species_id]

    index = @selected_index
    for alt in altsList
      if alt == current_sprite.alt_letter
        @selected_index = index
        return
      end
      index += 1
    end
  end

  def pbGetAvailableForms(species = nil)
    chosen_species = species != nil ? species : @species
    dex_num = getDexNumberForSpecies(chosen_species)
    includeAutogens = isFusion(dex_num)
    return PokedexUtils.new.pbGetAvailableAlts(chosen_species, includeAutogens)
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

    get_pif_sprite(@available[@selected_index])
    @sprites["bgSelected_previous"].visible = true if is_main_sprite(previous_index) && @available.size > 2
    @sprites["bgSelected_center"].visible = true if is_main_sprite(@selected_index)
    @sprites["bgSelected_next"].visible = true if is_main_sprite(next_index) && @available.size > 1
  end

  def get_pif_sprite(alt_letter)
    dex_number = getDexNumberForSpecies(@species) #@species is a symbol when called from the summary screen and an int from the pokedex... Would be nice to refactor
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)

      #Autogen sprite
      if alt_letter == "autogen"
        pif_sprite = PIFSprite.new(:AUTOGEN, head_id, body_id)
        #Imported custom sprite
      else
        #Spritesheet custom sprite
        pif_sprite = PIFSprite.new(:CUSTOM, head_id, body_id, alt_letter)
      end
    else
      pif_sprite = PIFSprite.new(:BASE, dex_number, nil, alt_letter)
    end
    #use local sprites instead if they exist
    if alt_letter && isLocalSprite(alt_letter)
      sprite_path = alt_letter.split("_", 2)[1]
      pif_sprite.local_path = sprite_path
    end
    #pif_sprite.dump_info
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
    @selected_pif_sprite = get_pif_sprite(@available[@selected_index])


    @previous_pif_sprite = get_pif_sprite(@available[previousIndex])
    @next_pif_sprite = get_pif_sprite(@available[nextIndex])

    @sprites["previousSprite"].bitmap = load_pif_sprite(@previous_pif_sprite) if previousIndex != nextIndex
    @sprites["selectedSprite"].bitmap = load_pif_sprite(@selected_pif_sprite)
    @sprites["nextSprite"].bitmap = load_pif_sprite(@next_pif_sprite)

    #selected_bitmap = @sprites["selectedSprite"].getBitmap
    # sprite_path = selected_bitmap.path
    #isBaseSprite = isBaseSpritePath(@available[@selected_index])
    is_generated = @selected_pif_sprite.type == :AUTOGEN
    spritename = @selected_pif_sprite.to_filename()
    showSpriteCredits(spritename, is_generated)

    update_selected
  end

  def showSpriteCredits(filename, generated_sprite = false)
    @creditsOverlay.dispose

    spritename = File.basename(filename, '.*')

    if !generated_sprite
      discord_name = getSpriteCredits(spritename)
      discord_name = "Unknown artist" if !discord_name
    else
      #todo give credits to Japeal - need to differenciate unfused sprites
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
    loop do
      @sprites["rightarrow"].visible = true
      @sprites["leftarrow"].visible = true
      if @forms_list.length >= 1
        @sprites["uparrow"].visible = true
        @sprites["downarrow"].visible = true
      end
      multiple_forms = @forms_list.length > 0
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @selected_index -= 1 #(index+@available.length-1)%@available.length
        if @selected_index < 0
          @selected_index = @available.size - 1
        end
        update_displayed
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @selected_index += 1
        if @selected_index > @available.size - 1
          @selected_index = 0
        end
        update_displayed
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if select_sprite(brief)
          @endscene = true
          break
        end
      end
    end
    @sprites["uparrow"].visible = false
    @sprites["downarrow"].visible = false
  end

  def is_main_sprite(index = nil)
    dex_number = getDexNumberForSpecies(@species)
    if !index
      index = @selected_index
    end
    species_id = get_substitution_id(dex_number)

    current_pif_sprite = $PokemonGlobal.alt_sprite_substitutions[species_id]
    selected_pif_sprite = get_pif_sprite(@available[index])

    if current_pif_sprite
      return current_pif_sprite.equals(selected_pif_sprite)
    end
    return false
  end

  def sprite_is_alt(sprite_path)
    spritename = File.basename(sprite_path, '.*')
    return spritename.match?(/[a-zA-Z]/)
  end

  def select_sprite(brief = false)
    if @available.length > 1
      if is_main_sprite()
        if brief
          pbMessage("This sprite will remain the displayed sprite")
          return true
        else
          pbMessage("This sprite is already the displayed sprite")
        end
      else
        message = 'Would you like to use this sprite instead of the current sprite?'
        if pbConfirmMessage(_INTL(message))
          swap_main_sprite()
          return true
        end
      end
    else
      pbMessage("This is the only sprite available for this Pokémon!")
    end
    return false
  end

  def swap_main_sprite
    species_number = dexNum(@species)
    substitution_id = get_substitution_id(species_number)
    $PokemonGlobal.alt_sprite_substitutions[substitution_id] = @selected_pif_sprite
  end
end

class PokemonGlobalMetadata
  attr_accessor :alt_sprite_substitutions
end
