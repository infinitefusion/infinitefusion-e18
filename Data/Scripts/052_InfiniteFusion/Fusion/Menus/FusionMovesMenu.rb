class FusionMovesOptionsScene < PokemonOption_Scene

  attr_reader :all_moves
  attr_reader :selected_moves
  attr_reader :move_slots

  def initialize(poke1, poke2)
    @poke1 = poke1
    @poke2 = poke2

    @fused_pokemon = @poke1
    @head_species = @fused_pokemon.species_data.head_pokemon
    @body_species = @fused_pokemon.species_data.body_pokemon

    @selected_moves = []
    @index_vertical = 0
    @index_horizontal = 0



    @selBaseColor = Color.new(48, 96, 216)
    @selShadowColor = Color.new(32, 32, 32)

    @counterBaseColor = pbColor(:LIGHT_TEXT_MAIN_COLOR)
    @counterShadowColor = pbColor(:LIGHT_TEXT_SHADOW_COLOR)
    @counterFullBaseColor = pbColor(:GREEN)
    @counterFullShadowColor = pbColor(:DARKGREEN)

    @maxMovesNb = [listUniqueAvailableMoves.length, 4].min
  end

  def initUIElements
    Kernel.pbClearText()
    @sprites["pokeicon_fused"] = PokemonIconSprite.new(@fused_pokemon.species, @viewport)
    @sprites["pokeicon_fused"].x = 12
    @sprites["pokeicon_fused"].y = 0

    @sprites["titleMsg"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select the moves you want to keep"), 64, 0, Graphics.width, 64, @viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL(""), 0, 32, Graphics.width, 64, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    @sprites["textbox"].height = @sprites["textbox"].height + 24
    @sprites["textbox"].y = @sprites["textbox"].y - 24
    @sprites["textbox"].baseColor = Color.new(64, 64, 64) # dark gray text
    @sprites["textbox"].shadowColor = Color.new(168, 168, 168) # lighter shadow

    if isDarkMode
      @sprites["textbox"].baseColor, @sprites["textbox"].shadowColor = @sprites["textbox"].shadowColor, @sprites["textbox"].baseColor
    end

    addBackgroundPlane(@sprites, "bg_moves", "Fusion/movesOverlay", @viewport)
    addBackgroundPlane(@sprites, "bg_stats", "Fusion/statsOverlay", @viewport)
    @sprites["bg_stats"].visible = false

    @sprites["counter"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("0 / {1}", @maxMovesNb), 386, 226, Graphics.width, 84, @viewport)
    @sprites["counter"].setSkin("Graphics/Windowskins/invisible")

    showPokemonIcons
    pbSetSystemFont(@sprites["textbox"].contents)
  end

  def updateCounter
    count = @selected_moves.length
    @sprites["counter"].text = _INTL("{1} / {2}", count, @maxMovesNb)
    if count == @maxMovesNb
      @sprites["counter"].baseColor = @counterFullBaseColor
      @sprites["counter"].shadowColor = @counterFullShadowColor
    else
      @sprites["counter"].baseColor = @counterBaseColor
      @sprites["counter"].shadowColor = @counterShadowColor

    end

  end

  def getSelectedMoves
    return @selected_moves
  end

  CURSOR_X_OFFSET = 8
  CURSOR_Y_OFFSET = 16

  def showPokemonIcons

    @sprites["pokeicon_1"] = PokemonIconSprite.new(@head_species.species, @viewport)
    @sprites["pokeicon_1"].x = 264
    @sprites["pokeicon_1"].y = 50

    @sprites["pokeicon_2"] = PokemonIconSprite.new(@body_species.species, @viewport)
    @sprites["pokeicon_2"].x = 388
    @sprites["pokeicon_2"].y = 50

    @sprites["pokecursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["pokecursor"].setBitmap("Graphics/Pictures/Fusion/cursor")
    @sprites["pokecursor"].x = @sprites["pokeicon_1"].x + CURSOR_X_OFFSET
    @sprites["pokecursor"].y = @sprites["pokeicon_1"].y + CURSOR_Y_OFFSET
    @sprites["pokecursor"].visible = true
  end

  def pbStartScene(inloadscreen = false)
    super
    @typebitmap = AnimatedBitmap.new("Graphics/Pictures/types")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 9999
    pbSetSystemFont(@sprites["overlay"].bitmap)

    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL(""), 0, 66, Graphics.width, 64, @viewport)
    @sprites["title"].setSkin("Graphics/Windowskins/invisible")
    @sprites["option"].setSkin("Graphics/Windowskins/invisible")
    # echoln @sprites["option"].bitmap.text_size
    # @sprites["option"].bitmap.text_size=10
    updatePokemonCursor(0)
    updateDescription(0)
    updateCounter
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def getOptionsWidth(rect)
    width = super(rect)
    return width + 24
  end

  def draw_move_info(pokemonMove)
    @sprites["bg_stats"].visible = false
    @sprites["bg_moves"].visible = true
    move = GameData::Move.get(pokemonMove.id)
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)

    value_base_color = Color.new(248, 248, 248)
    value_shadow_color = Color.new(104, 104, 104)

    @sprites["title"].text = _INTL("{1}", move.name)

    damage = move.base_damage == 0 ? "-" : move.base_damage.to_s
    accuracy = move.accuracy == 0 ? "100" : move.accuracy.to_s
    pp = move.total_pp.to_s
    if !move
      damage = "-"
      accuracy = "-"
      pp = "-"
    end

    start_y = 110
    gap_height = 32

    textpos = [
      [_INTL("Type"), 20, start_y, 0, label_base_color, label_shadow_color],
      [_INTL("Category"), 20, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],
      [_INTL("Power"), 20, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],
      ["#{damage}", 148, start_y + (gap_height * 2), 0, value_base_color, value_shadow_color],
      [_INTL("Accuracy"), 20, start_y + (gap_height * 3), 0, label_base_color, label_shadow_color],
      ["#{accuracy}%", 148, start_y + (gap_height * 3), 0, value_base_color, value_shadow_color],
      [_INTL("PP"), 20, start_y + (gap_height * 4), 0, label_base_color, label_shadow_color],
      ["#{pp}", 148, start_y + (gap_height * 4), 0, value_base_color, value_shadow_color]
    ]

    imagepos = []
    type_number = GameData::Type.get(move.type).id_number
    category = move.category
    imagepos.push(["Graphics/Pictures/types", 140, start_y + (gap_height * 0) + 8, 0, type_number * 28, 64, 28])
    imagepos.push(["Graphics/Pictures/category", 140, start_y + (gap_height * 1) + 8, 0, category * 28, 64, 28])
    if !move
      imagepos = []
    end
    @sprites["overlay"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)

  end

  def draw_pokemon_info

    @sprites["bg_stats"].visible = true
    @sprites["bg_moves"].visible = false
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)

    value_base_color = Color.new(248, 248, 248)
    value_shadow_color = Color.new(104, 104, 104)

    @sprites["title"].text = ""

    start_y = 78
    gap_height = 32

    textpos = [
      [_INTL("HP"), 20, start_y, 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.totalhp), 158, start_y, 0, label_base_color, label_shadow_color],

      [_INTL("Attack"), 20, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.attack), 158, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],

      [_INTL("Defense"), 20, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.defense), 158, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],

      [_INTL("Sp. Attack"), 20, start_y + (gap_height * 3), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.spatk), 158, start_y + (gap_height * 3), 0, value_base_color, value_shadow_color],

      [_INTL("Sp. Defense"), 20, start_y + (gap_height * 4), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.spdef), 158, start_y + (gap_height * 4), 0, value_base_color, value_shadow_color],

      [_INTL("Speed"), 20, start_y + (gap_height * 5), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.speed), 158, start_y + (gap_height * 5), 0, value_base_color, value_shadow_color],

    ]
    @sprites["overlay"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  # def draw_pokemon_type
  #   type1_number = GameData::Type.get(@poke1.type1).id_number
  #   type2_number = GameData::Type.get(@poke1.type2).id_number
  #   type1rect = Rect.new(0, type1_number * 28, 64, 28)
  #   type2rect = Rect.new(0, type2_number * 28, 64, 28)
  #   if @poke1.type1 == @poke1.type2
  #     overlay.blt(130, 78, @typebitmap.bitmap, type1rect)
  #   else
  #     overlay.blt(96, 78, @typebitmap.bitmap, type1rect)
  #     overlay.blt(166, 78, @typebitmap.bitmap, type2rect)
  #   end
  # end

  def updatePokemonCursor(index)
    index = 0 if !index
    if @sprites["pokecursor"]
      if index == 0
        highlighted_value = @sprites["option"] ? (@sprites["option"][0] || 0) : 0
        @sprites["pokecursor"].visible = true
        @sprites["pokecursor"].x = highlighted_value == 0 ? @sprites["pokeicon_1"].x : @sprites["pokeicon_2"].x
        @sprites["pokecursor"].y = highlighted_value == 0 ? @sprites["pokeicon_1"].y : @sprites["pokeicon_2"].y
        @sprites["pokecursor"].x += CURSOR_X_OFFSET
        @sprites["pokecursor"].y += CURSOR_Y_OFFSET
      else
        @sprites["pokecursor"].visible = false
      end
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["option"].mustUpdateDescription || @sprites["option"].mustUpdateOptions
      updatePokemonCursor(@sprites["option"].index)
      updateDescription(@sprites["option"].index)
      @sprites["option"].descriptionUpdated
    end
  end

  def updateDescription(index)
    index = 0 if !index
    begin
      return if !@move_slots
      col = @sprites["option"] ? (@sprites["option"][index] || 0) : 0

      if index == 0
        # Header row — show pokemon info panel
        draw_pokemon_info
        species = col == 0 ? @head_species : @body_species
        @sprites["textbox"].text = _INTL("\nSelect all moves from {1}", GameData::Species.get(species).name)
        return
      end

      slot = @move_slots[index - 1]
      return if !slot
      move = slot[col]
      if move
        draw_move_info(move)
        @sprites["textbox"].text = _INTL(getMoveDescription(move))
      else
        @sprites["overlay"].bitmap.clear
        @sprites["textbox"].text = getDefaultDescription
      end
    rescue => e
      @sprites["textbox"].text = getDefaultDescription
    end
  end

  def getDefaultDescription
    return _INTL("No move selected")
  end

  def getMoveForIndex(index)
    # Offset by 1 to skip the all moves button
    move_index = index - 1
    return nil if move_index < 0
    highlighted_value = @sprites["option"] ? (@sprites["option"][index] || 0) : 0
    case move_index
    when 0 then highlighted_value == 0 ? @poke1.moves[0] : @poke2.moves[0]
    when 1 then highlighted_value == 0 ? @poke1.moves[1] : @poke2.moves[1]
    when 2 then highlighted_value == 0 ? @poke1.moves[2] : @poke2.moves[2]
    when 3 then highlighted_value == 0 ? @poke1.moves[3] : @poke2.moves[3]
    end
  end

  def listUniqueAvailableMoves
    moves = []
    moves += @poke1.moves
    moves += @poke2.moves
    return moves.uniq { |m| m.id }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def getMoveName(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).name
  end

  def getMoveDescription(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).description
  end

  def pbGetOptions(inloadscreen = false)
    @move_slots = (0..3).map { |i| [@poke2.moves[i], @poke1.moves[i]] }

    # Row 0: the "select all" header row
    header = EnumOption.new(
      "",
      ["", ""],
      proc { 0 },
      proc {},
      ["", ""]
    )

    move_options = @move_slots.map do |slot|
      left_name = slot[0] ? GameData::Move.get(slot[0].id).name : "-"
      right_name = slot[1] ? GameData::Move.get(slot[1].id).name : "-"
      EnumOption.new(
        "",
        [left_name, right_name],
        proc { 0 },
        proc {},
        ["", ""]
      )
    end

    return [header] + move_options
  end

  def pbOptions
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate

        if @sprites["option"].mustUpdateOptions
          for i in 0...@PokemonOptions.length
            @PokemonOptions[i].set(@sprites["option"][i])
          end
        end

        @index_vertical = @sprites["option"].index
        @index_horizontal = @sprites["option"][@index_vertical] || 0

        if Input.trigger?(Input::USE)
          # Confirm
          if @index_vertical == @PokemonOptions.length
            if @selected_moves.length > 0 && validateSelectedMoves
              echoln @maxMovesNb
              if @selected_moves.length < @maxMovesNb && listUniqueAvailableMoves.length > @selected_moves.length
                nb_more = @maxMovesNb - @selected_moves.length
                plural_s = nb_more > 1 ? "s" : ""
                if pbConfirmMessage(_INTL("You can still select \\C[1]{1}\\C[0] additional move{2}. Are you sure you want to continue?", nb_more, plural_s))
                  break
                end
              else
                break
              end
            else
              pbPlayBuzzerSE
            end
            next
          end

          # Select all
          if @index_vertical == 0
            col = @index_horizontal
            @selected_moves = @move_slots.map { |slot| slot[col] }.compact
            (0...@PokemonOptions.length).each { |i| @sprites["option"].setValueNoRefresh(i, col) }
            @sprites["option"].refresh
            pbSEPlay("GUI naming confirm")
            updateCounter
            updateDescription(@index_vertical)

            # Auto-jump to Confirm
            @sprites["option"].index = @PokemonOptions.length
            @sprites["option"].refresh
            updateCounter
            updatePokemonCursor(@PokemonOptions.length)
            next
          end

          # Individual move row (rows 1-4, slot index is vertical - 1)
          slot_index = @index_vertical - 1
          move = @move_slots[slot_index][@index_horizontal]
          next if !move

          already_selected = @selected_moves.any? { |m| m.id == move.id }
          if already_selected
            @selected_moves.reject! { |m| m.id == move.id }
          else
            if @selected_moves.length >= 4
              pbPlayBuzzerSE
            else
              @selected_moves << move
              # Auto-jump to Confirm when 4th move is selected
              if @selected_moves.length == @maxMovesNb
                pbSEPlay("GUI naming confirm")
                (0...@PokemonOptions.length).each { |i| @sprites["option"].setValueNoRefresh(i, @sprites["option"][@index_vertical] || 0) }
                @sprites["option"].index = @PokemonOptions.length
                @sprites["option"].refresh
                updatePokemonCursor(@PokemonOptions.length)
              end
            end
          end

          @sprites["option"].refresh
          updateCounter
          updateDescription(@index_vertical)
        end
      end
    }
  end

  def set_all_moves_to_index(index)
    [1, 2, 3, 4].each { |i| @sprites["option"][i] = index }
    source = index == 0 ? @poke1 : @poke2
    @move1 = source.moves[0]
    @move2 = source.moves[1]
    @move3 = source.moves[2]
    @move4 = source.moves[3]
    @sprites["option"].refresh
    updatePokemonCursor(@sprites["option"].index)
    updateCounter
    updateDescription(@sprites["option"].index)
  end

  def isConfirmedOnKeyPress
    return false
  end

  def initOptionsWindow
    x_pos = 0
    y_pos = @sprites["title"].height
    item_height = 32 # standard row height in Essentials
    num_items = @PokemonOptions.length + 1 # +1 for Confirm
    window_height = item_height * num_items + 4 # +4 for border padding

    optionsWindow = Window_PokemonOptionFusionMoves.new(@PokemonOptions, x_pos, y_pos, Graphics.width,
                                                        window_height + 32,
                                                        self)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end

  def validateSelectedMoves
    return @selected_moves.length > 0 && @selected_moves.length <= 4
  end

  #Same as Option, but without pbRefreshSceneMap
  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@PokemonOptions.length
      @PokemonOptions[i].set(@sprites["option"][i])
    end
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

end

class Window_PokemonOptionFusionMoves < Window_PokemonOption
  OPTIONS_X_OFFSET = 0
  COLUMNS_GAP = 20

  def initialize(options, x, y, width, height, scene)
    @scene = scene
    super(options, x, y, width, height)
    @mustUpdateOptions = true
    @mustUpdateDescription = true
    @confirmed = false
  end

  def drawCursor(index, rect)
    if self.index == index
      unless index == 0
        optionwidth = rect.width * 9 / 20
        col = self[index] || 0

        if @options[index].is_a?(EnumOption) && @options[index].values.length > 1
          col0_x = optionwidth + rect.x + 12 + OPTIONS_X_OFFSET
          col1_x = col0_x + (rect.width - col0_x) / 2 + COLUMNS_GAP
          xpos = col == 0 ? col0_x : col1_x
          arrow_x = xpos - @selarrow.bitmap.width - 2
        else
          arrow_x = rect.x + 175
        end

        pbCopyBitmap(self.contents, @selarrow.bitmap, arrow_x, rect.y)
      end
    end
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end

  def drawItem(index, _count, rect)
    return if dont_draw_item(index)
    rect = drawCursor(index, rect)

    if index == @options.length
      optionwidth = rect.width * 9 / 20
      base_color = Color.new(
        [@nameBaseColor.red + 80, 255].min,
        [@nameBaseColor.green + 80, 255].min,
        [@nameBaseColor.blue + 80, 255].min
      )
      shadow_color = Color.new(
        [base_color.red - 60, 0].max,
        [base_color.green - 60, 0].max,
        [base_color.blue - 60, 0].max
      )
      pbDrawShadowText(self.contents, 216, rect.y, optionwidth, rect.height,
                       _INTL("     Confirm"), base_color, shadow_color)
      return
    end

    return unless @options[index].is_a?(EnumOption) && @options[index].values.length > 1

    optionwidth = rect.width * 9 / 20
    col0_x = optionwidth + rect.x + 12 + OPTIONS_X_OFFSET
    col1_x = col0_x + (rect.width - col0_x) / 2 + COLUMNS_GAP
    col_width = col1_x - col0_x - COLUMNS_GAP

    @options[index].values.each_with_index do |value, col|
      slot_index = index - 1
      move = slot_index >= 0 ? @scene.move_slots&.[](slot_index)&.[](col) : nil
      is_selected = move && @scene.selected_moves.any? { |m| m.id == move.id }

      base = is_selected ? @selBaseColor : Color.new(180, 180, 180)
      shadow = is_selected ? @selShadowColor : Color.new(80, 80, 80)

      xpos = col == 0 ? col0_x : col1_x
      pbDrawShadowText(self.contents, xpos, rect.y, col_width, rect.height, value, base, shadow)
    end
  end

  def dont_draw_item(index)
    return false
    # return index == @options.length
  end

  def update
    old_index = self.index
    super
    if self.index != old_index && self.index < @options.length
      if old_index < @options.length
        @optvalues[self.index] = @optvalues[old_index]
      else
        # Coming from confirm -> go to unselected one (makes it easier to quickly swap between the two)
        current = @optvalues[self.index] || 0
        @optvalues[self.index] = current == 0 ? 1 : 0
      end
      refresh
    end
  end
end
