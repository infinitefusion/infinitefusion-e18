class StartersSelectionScene
  POKEBALL_LEFT_X = -20; POKEBALL_LEFT_Y = 70
  POKEBALL_MIDDLE_X = 125; POKEBALL_MIDDLE_Y = 100
  POKEBALL_RIGHT_X = 275; POKEBALL_RIGHT_Y = 70

  TEXT_POSITION_X = 100
  TEXT_POSITION_Y = 10

  def initialize(starters = [])
    @starters_species = starters
    @starter_pokemon = []
    @starters_species.each do |species|
      @starter_pokemon.push(Pokemon.new(species, 5)) if species
    end

    @spritesLoader = BattleSpriteLoader.new
    @shown_starter_species = nil
  end

  def initializeGraphics()
    @background = displayPicture("Graphics/Pictures/StarterSelection/hoenn_starter_bag_bg.png", -16, -16)
    @background.z = 0

    @foreground = displayPicture("Graphics/Pictures/StarterSelection/hoenn_starter_bag_foreground.png", -16, -16)
    @foreground.z = 999

    @pokeball_closed_left = displayPicture("Graphics/Pictures/StarterSelection/trade_pokeball_closed_1.png", POKEBALL_LEFT_X, POKEBALL_LEFT_Y)
    @pokeball_closed_left.z = 2

    @pokeball_closed_middle = displayPicture("Graphics/Pictures/StarterSelection/trade_pokeball_closed_2.png", POKEBALL_MIDDLE_X, POKEBALL_MIDDLE_Y)
    @pokeball_closed_middle.z = 100

    @pokeball_closed_right = displayPicture("Graphics/Pictures/StarterSelection/trade_pokeball_closed_3.png", POKEBALL_RIGHT_X, POKEBALL_RIGHT_Y)
    @pokeball_closed_right.z = 2

  end

  def updateOpenPokeballPosition
    case @index
    when 0
      @shown_pokemon_x = POKEBALL_LEFT_X
      @shown_pokemon_y = POKEBALL_LEFT_Y
    when 1
      @shown_pokemon_x = POKEBALL_MIDDLE_X
      @shown_pokemon_y = POKEBALL_MIDDLE_Y
    when 2
      @shown_pokemon_x = POKEBALL_RIGHT_X
      @shown_pokemon_y = POKEBALL_RIGHT_Y
    end
  end

  def startScene
    initializeGraphics
    @index = nil
    previous_index = nil
    loop do
      if @index
        if Input.trigger?(Input::RIGHT)
          previous_index = @index
          @index += 1
          @index = 0 if @index == @starters_species.length
        end
        if Input.trigger?(Input::LEFT)
          previous_index = @index
          @index -= 1
          @index = @starters_species.length - 1 if @index < 0
        end
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          updateOpenPokeballPosition
          updateStarterSelectionGraphics
        end
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          disposeGraphics
          return nil
        end
        if Input.trigger?(Input::USE)
          if pbConfirmMessage(_INTL("Do you choose this Pokémon?"))
            chosenPokemon = @starter_pokemon[@index]
            @spritesLoader.registerSpriteSubstitution(@pif_sprite)
            disposeGraphics
            pbSet(VAR_HOENN_CHOSEN_STARTER_INDEX, @index)
            chosenPokemon.pif_sprite = @pif_sprite
            return chosenPokemon
          end
        end
      else
        @index = 0 if Input.trigger?(Input::LEFT)
        @index = 1 if Input.trigger?(Input::DOWN)
        @index = 2 if Input.trigger?(Input::RIGHT)
      end

      if previous_index != @index
        updateOpenPokeballPosition
        updateStarterSelectionGraphics
        previous_index = @index
      end
      Input.update
      Graphics.update
    end
  end

  def disposeGraphics()
    @pokeball_closed_left.dispose
    @pokeball_closed_middle.dispose
    @pokeball_closed_right.dispose
    @pokeball_open_back.dispose
    @pokeball_open_front.dispose
    @background.dispose
    @foreground.dispose
    @pokemon_name_overlay.dispose
    @pokemon_category_overlay.dispose
    @pokemonSpriteWindow.dispose
  end

  def updateClosedBallGraphicsVisibility
    case @index
    when 0
      @pokeball_closed_left.visible = false
      @pokeball_closed_middle.visible = true
      @pokeball_closed_right.visible = true
    when 1
      @pokeball_closed_left.visible = true
      @pokeball_closed_middle.visible = false
      @pokeball_closed_right.visible = true
    when 2
      @pokeball_closed_left.visible = true
      @pokeball_closed_middle.visible = true
      @pokeball_closed_right.visible = false
    else
      @pokeball_closed_left.visible = true
      @pokeball_closed_middle.visible = true
      @pokeball_closed_right.visible = true
    end

  end

  def updateStarterSelectionGraphics()
    pbSEPlay("GUI storage pick up", 80, 100)
    updateClosedBallGraphicsVisibility
    @pokeball_open_back.dispose if @pokeball_open_back
    @pokeball_open_front.dispose if @pokeball_open_front

    @shown_starter_species = @starters_species[@index]

    updateOpenPokeballPosition

    case @index
    when 0
      picture_back_path = "Graphics/Pictures/StarterSelection/BACKleftball"
      picture_front_path = "Graphics/Pictures/StarterSelection/FRONTleftball"
    when 1
      picture_back_path = "Graphics/Pictures/StarterSelection/BACKcenterball"
      picture_front_path = "Graphics/Pictures/StarterSelection/FRONTcenterball"
    when 2
      picture_back_path = "Graphics/Pictures/StarterSelection/BACKrightball"
      picture_front_path = "Graphics/Pictures/StarterSelection/FRONTrightball"
    end

    @pokeball_open_back = displayPicture(picture_back_path, @shown_pokemon_x, @shown_pokemon_y, 2)
    @pokeball_open_front = displayPicture(picture_front_path, @shown_pokemon_x, @shown_pokemon_y, 50)

    updatePokemonSprite
  end

  def updatePokemonSprite()
    @pif_sprite = @spritesLoader.get_pif_sprite_from_species(@shown_starter_species.species)
    sprite_bitmap = @spritesLoader.load_pif_sprite_directly(@pif_sprite)
    pokemon = @starter_pokemon[@index]
    if pokemon.shiny?
      sprite_bitmap.bitmap.update_shiny_cache(pokemon.id_number, "")
      sprite_bitmap.shiftAllColors(pokemon.id_number, pokemon.bodyShiny?, pokemon.headShiny?)
    end

    @pokemonSpriteWindow.dispose if @pokemonSpriteWindow
    @pokemonSpriteWindow = PictureWindow.new(sprite_bitmap.bitmap)

    @pokemonSpriteWindow.opacity = 0
    @pokemonSpriteWindow.z = 2
    @pokemonSpriteWindow.x = @shown_pokemon_x
    @pokemonSpriteWindow.y = @shown_pokemon_y - 10
    updateText
  end

  def updateText
    is_chinese = (getCurrentLanguage == :CHINESE)
    @pokemon_name_overlay.dispose if @pokemon_name_overlay
    @pokemon_category_overlay.dispose if @pokemon_category_overlay

    pokemon_name = "#{@shown_starter_species.name}"
    pokemon_category = _INTL("{1} Pokémon", @shown_starter_species.category)

    title_position_y = TEXT_POSITION_Y
    subtitle_position_y = TEXT_POSITION_Y + 30

    text_x_offset = -100

    label_base_color = Color.new(88, 88, 80)
    label_shadow_color = Color.new(168, 184, 184)

    title_base_color = Color.new(248, 248, 248)
    title_shadow_color = Color.new(104, 104, 104)

    @pokemon_name_overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap
    @pokemon_category_overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap

    if is_chinese
      @pokemon_name_overlay.font.name = MessageConfig::SMALL_FONT_NAME_CHINESE
      @pokemon_name_overlay.font.size = 37
    else
      @pokemon_name_overlay.font.name = MessageConfig.pbGetSmallFontName
      @pokemon_name_overlay.font.size = 50
    end

    if is_chinese
      @pokemon_category_overlay.font.name = MessageConfig::SMALL_FONT_NAME_CHINESE
      @pokemon_category_overlay.font.size = 25
    else
      @pokemon_category_overlay.font.name = MessageConfig.pbGetSmallFontName
      @pokemon_category_overlay.font.size = 36
    end

    pbDrawTextPositions(@pokemon_name_overlay, [[pokemon_name, (Graphics.width / 2) + text_x_offset, title_position_y, 2, title_base_color, title_shadow_color]])
    pbDrawTextPositions(@pokemon_category_overlay, [[pokemon_category, (Graphics.width / 2) + text_x_offset, subtitle_position_y, 2, label_base_color, label_shadow_color]])

  end

end
