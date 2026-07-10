class DoublePreviewScreen
  attr_reader :sprite_left
  attr_reader :sprite_right

  SELECT_ARROW_X_LEFT= 100
  SELECT_ARROW_X_RIGHT= 350
  SELECT_ARROW_X_CANCEL= 230

  SELECT_ARROW_Y_SELECT= 0
  SELECT_ARROW_Y_CANCEL= 210
  ARROW_GRAPHICS_PATH = "Graphics/Pictures/Fusion/selHand"
  CANCEL_BUTTON_PATH = "Graphics/Pictures/Fusion/previewScreen_Cancel"
  BACKGROUND_PATH = "Graphics/Pictures/shadeFull_"
  EVO_BUTTON_PATH = "Graphics/Pictures/Fusion/previewScreen_evolution"
  EVO_BUTTON_X= 272
  EVO_BUTTON_Y= 4


  ICON_EVO_HAS_CUSTOM = "Graphics/Pictures/Fusion/evoCustom"
  ICON_EVO_HAS_NO_CUSTOM = "Graphics/Pictures/Fusion/evoNoCustom"
  ICON_EVO_FULL_CUSTOM =  "Graphics/Pictures/Fusion/evoCustom_full"
  CANCEL_BUTTON_X= 140
  CANCEL_BUTTON_Y= 260

  def initialize(species_left, species_right)
    @species_left = species_left
    @species_right = species_right

    @typewindows = []
    @picture1 = nil
    @picture2 = nil
    @draw_types = nil
    @draw_level = nil
    @draw_sprite_info = nil
    @selected = 0
    @last_post=0
    @sprites      = {}
    @sprite_right = nil
    @selected_sprite = nil
    initializeBackground
    initializeSelectArrow
    initializeCancelButton
    initializeEvolutionsButton
    hideAllEvoIcons
  end

  def getBackgroundPicture
    return BACKGROUND_PATH
  end


  def getSelection
    selected = startSelection
    @sprites["cancel"].visible=false
    #@sprites["arrow"].visible=false


    #todo: il y a un fuck en quelque part.... en attendant ca marche inversé ici
    if selected == 0
      @selected_sprite = @sprite_left
      return @species_left
    end
    if selected == 1
      @selected_sprite = @sprite_right
      return @species_right
    end
    return -1
  end

  def get_selected_sprite
    return @selected_sprite
  end

  def startSelection
    loop do
      Graphics.update
      Input.update
      updateSelection
      if Input.trigger?(Input::USE)
        return @selected
      end
      if Input.trigger?(Input::BACK)
        return -1
      end
    end
  end

  def updateSelection
    currentSelected = @selected
    updateSelectionIndex
    if @selected != currentSelected
      updateSelectionGraphics
    end
  end

  def updateSelectionIndex
    @up_hold_frames ||= 0

    if @selected == -1
      @up_hold_frames = 0
      if Input.trigger?(Input::UP)
        @selected = @last_post
      end
    else
      if Input.trigger?(Input::LEFT)
        @selected = 0
      elsif Input.trigger?(Input::RIGHT)
        @selected = 1
      elsif Input.trigger?(Input::DOWN)
        @last_post = @selected
        @selected = -1
      end

      if Input.press?(Input::UP) && @selected > -1
        @up_hold_frames += 1
        showAllEvoIcons if @up_hold_frames >= 6
      else
        @up_hold_frames = 0
        hideAllEvoIcons
      end
    end
  end

  def hideAllEvoIcons
    @sprites["evo"].visible=true
    @evo_icons_visible = false
    @sprites.each do |key, sprite|
      sprite.visible = false if key.start_with?("evo_icon_")
    end
  end


  def showAllEvoIcons
    @sprites["evo"].visible=false
    unless @evo_icons_visible
      pbSEPlay("GUI storage show party panel")
      @evo_icons_visible = true
    end
    @sprites.each do |key, sprite|
      sprite.visible = true if key.start_with?("evo_icon_")
    end
  end

  def updateSelectionGraphics
    if @selected == 0
      @sprites["arrow"].x = SELECT_ARROW_X_LEFT
      @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    elsif @selected == 1
      @sprites["arrow"].x = SELECT_ARROW_X_RIGHT
      @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    else
      @sprites["arrow"].x = SELECT_ARROW_X_CANCEL
      @sprites["arrow"].y = SELECT_ARROW_Y_CANCEL
    end
    pbUpdateSpriteHash(@sprites)
  end

  def draw_window(dexNumber, level, x, y, isShiny=false, bodyShiny = false, headShiny=false, window_position=0)
    body_pokemon = getBodyID(dexNumber)
    head_pokemon = getHeadID(dexNumber, body_pokemon)

    # picturePath = getPicturePath(head_pokemon, body_pokemon)
    # bitmap = AnimatedBitmap.new(picturePath)
    spriteLoader = BattleSpriteLoader.new

    bitmap = GameData::Species.front_sprite_bitmap(dexNumber)
    bitmap.shiftAllColors(dexNumber, bodyShiny, headShiny)

    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
    pif_sprite = spriteLoader.obtain_fusion_pif_sprite(head_pokemon,body_pokemon)

    if window_position == 0
      @sprite_left = pif_sprite
    else
      @sprite_right = pif_sprite
    end
    hasCustom = customSpriteExists(body_pokemon,head_pokemon)

    @viewport_evo = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport_evo.z = 100001
    drawEvolutionIcons(dexNumber, @viewport_evo, x+16, y + 12, window_position)

    previewwindow = PictureWindow.new(bitmap)
    previewwindow.x = x
    previewwindow.y = y
    previewwindow.z = 99999

    drawFusionInformation(dexNumber, level, x)

    if !$Trainer.seen?(dexNumber)
      if pif_sprite.local_path()
        previewwindow.picture.pbSetColor(170, 200, 250, 200)  #blue
      elsif hasCustom
        previewwindow.picture.pbSetColor(150, 255, 150, 200)  #green
      else
        previewwindow.picture.pbSetColor(255, 255, 255, 200)  #white
      end
    end
    return previewwindow
  end


  def drawEvolutionIcons(dexNumber, viewport, x, y, window_position)
    current_species = GameData::Species.get(dexNumber)
    if current_species.is_fusion
      body_num = getBodyID(current_species.id_number)
      head_num = getHeadID(current_species.id_number, body_num)
      body_chain = GameData::Species.get(body_num).get_ordered_family_species
      head_chain = GameData::Species.get(head_num).get_ordered_family_species

      ordered_species = []
      seen = {}
      body_chain.each do |body_sp|
        head_chain.each do |head_sp|
          body_dex = getDexNumberForSpecies(body_sp)
          head_dex = getDexNumberForSpecies(head_sp)
          fused_id = getFusedPokemonIdFromDexNum(body_dex, head_dex)
          next if seen[fused_id]
          next unless GameData::Species.get(fused_id)
          seen[fused_id] = true
          ordered_species << fused_id
        end
      end
    else
      ordered_species = current_species.get_ordered_family_species
    end
    current_species_index = ordered_species.index(current_species.species) || 0

    parsed_species = []
    evolution_customs = []
    ordered_species.each do |species|
      next if parsed_species.include?(species)
      parsed_species << species
      evolution_customs << customSpriteExistsSpecies(species)
    end

    return if evolution_customs.empty?

    icon_width = 16
    icon_spacing = 4
    max_per_row = 10
    row_height = icon_width + 4

    rows = evolution_customs.each_slice(max_per_row).to_a
    rows.each_with_index do |row_customs, row_index|
      start_x = x + icon_spacing
      row_y = y + (row_index * row_height)
      row_customs.each_with_index do |has_custom, col_index|
        global_index = (row_index * max_per_row) + col_index
        icon_path = has_custom ? ICON_EVO_HAS_CUSTOM : ICON_EVO_HAS_NO_CUSTOM
        icon_path += "_selected" if global_index == current_species_index
        icon_bitmap = AnimatedBitmap.new(icon_path).bitmap
        icon_sprite = Sprite.new(viewport)
        icon_sprite.bitmap = icon_bitmap
        icon_sprite.x = start_x + (col_index * (icon_width + icon_spacing))
        icon_sprite.y = row_y
        icon_sprite.z = 10000
        @sprites["evo_icon_#{window_position}_#{global_index}"] = icon_sprite
      end
    end
  end


  def drawFusionInformation(fusedDexNum, level, x = 0)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @typewindows << drawPokemonType(fusedDexNum, viewport, x + 55, 220) if @draw_types
    drawFusionPreviewText(viewport, "Lv. " + level.to_s, x + 80, 40,) if @draw_level
    drawSpriteInfoIcons(getPokemon(fusedDexNum),viewport) if @draw_sprite_info
  end


  def initializeSelectArrow
    @sprites["arrow"] = IconSprite.new(0, 0, @viewport)
    @sprites["arrow"].setBitmap(ARROW_GRAPHICS_PATH)
    @sprites["arrow"].x = SELECT_ARROW_X_LEFT
    @sprites["arrow"].y = SELECT_ARROW_Y_SELECT
    @sprites["arrow"].z = 100001
  end

  def initializeEvolutionsButton()
    @sprites["evo"] = IconSprite.new(0, 0, @viewport)
    @sprites["evo"].setBitmap(EVO_BUTTON_PATH)
    @sprites["evo"].x = EVO_BUTTON_X
    @sprites["evo"].y = EVO_BUTTON_Y
    @sprites["evo"].z = 100000
  end

  def initializeCancelButton()
    @sprites["cancel"] = IconSprite.new(0, 0, @viewport)
    @sprites["cancel"].setBitmap(CANCEL_BUTTON_PATH)
    @sprites["cancel"].x = CANCEL_BUTTON_X
    @sprites["cancel"].y = CANCEL_BUTTON_Y
    @sprites["cancel"].z = 100000
  end

  def initializeBackground()
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(getBackgroundPicture)
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99999
  end

  def drawFusionPreviewText(viewport, text, x, y)
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)
    overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap
    textpos = [[text, x, y, 0, label_base_color, label_shadow_color]]
    pbDrawTextPositions(overlay, textpos)
  end

  #todo
  # Adds the icons indicating if the fusion has alt sprites and if the final evo has a custom sprite
  # also add a second icon to indidcate if the final evolution has a custom
  def drawSpriteInfoIcons(fusedPokemon, viewport)
    #pokedexUtils = PokedexUtils.new
    #hasAltSprites = pokedexUtils.pbGetAvailableAlts(fusedPokemon).size>1
    #pokedexUtils.getFinalEvolution(fusedPokemon).real_name
    #todo
  end

  def dispose
    @picture1.dispose
    @picture2.dispose
    for typeWindow in @typewindows
      typeWindow.dispose
    end
    pbDisposeSpriteHash(@sprites)

  end

  def drawPokemonType(pokemon_id, viewport, x_pos = 192, y_pos = 264)
    width = 66
    viewport.z = 1000001
    overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap

    pokemon = GameData::Species.get(pokemon_id)
    typebitmap = AnimatedBitmap.new("Graphics/Pictures/types")
    type1_number = GameData::Type.get(pokemon.type1).id_number
    type2_number = GameData::Type.get(pokemon.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if pokemon.type1 == pokemon.type2
      overlay.blt(x_pos + (width / 2), y_pos, typebitmap.bitmap, type1rect)
    else
      overlay.blt(x_pos, y_pos, typebitmap.bitmap, type1rect)
      overlay.blt(x_pos + width, y_pos, typebitmap.bitmap, type2rect)
    end
    return viewport
  end

end
