class PokemonStorageScreen
  include SelectionConstants

  attr_accessor :multiheldpkmn
  attr_accessor :multiSelectRange

  alias _storageMultiSelect_initialize initialize

  def initialize(*args)
    _storageMultiSelect_initialize(*args)
    @multiheldpkmn = []
    @multiSelectRange = nil
  end

  # Top-level loop: delegates move and release actions to screen-level methods.
  def pcOrganizeCommand()
    isTransferBox = @storage[@storage.currentBox].is_a?(StorageTransferBox)
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected == nil
        if pbHolding?
          if @fusionMode
            cancelFusion
          else
            pbDisplay(_INTL("You're holding a Pokémon!"))
          end
          next
        end
        if @multiSelectRange
          pbPlayCancelSE
          @multiSelectRange = nil
          @scene.pbUpdateSelectionRect(0, 0)
          next
        end
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == SelectionConstants::CLOSE
        if pbHolding?
          if @multiSelectRange
            pbPlayCancelSE
            @multiSelectRange = nil
            @scene.pbUpdateSelectionRect(0, 0)
            next
          else
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
        end
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      elsif selected[0] == SelectionConstants::PREV_BOX
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        heldpoke = pbHeldPokemon
        next if !heldpoke && !pokemon && @scene.cursormode != "multiselect"
        if @scene.cursormode == "multiselect"
          multiSelectAction(selected)
        elsif @scene.cursormode == "quickswap"
          quickSwap(selected, pokemon)
        elsif @fusionMode
          pbFusionCommands(selected)
        else
          organizeActions(selected, pokemon, heldpoke, isTransferBox)
        end
      end
    end
    @scene.pbCloseBox
  end

  def selectAllBox
    @scene.pbSetCursorMode("multiselect")
    selected_index = PokemonBox::BOX_SIZE - 1
    @multiSelectRange = [0, nil]
    box = @storage.currentBox
    @scene.pbUpdateSelectionRect(box, selected_index,)
    @scene.selection = selected_index
  end

  def pbBoxCommands
    is_holding_pokemon = pbHolding?
    if @scene.cursormode == "multiselect"
      if is_holding_pokemon
        return dropAllHeldPokemon
      else
        return selectAllBox
      end

    end
    cmd_jump = _INTL("Jump")
    cmd_select = _INTL("Select all")
    cmd_wallpaper = _INTL("Wallpaper")
    cmd_name = _INTL("Name")
    cmd_info = _INTL("Info")
    cmd_cancel = _INTL("Cancel")

    commands = []
    commands << cmd_jump
    commands << cmd_select unless is_holding_pokemon
    commands << cmd_wallpaper unless @storage[@storage.currentBox].is_a?(StorageTransferBox)
    commands << cmd_name unless @storage[@storage.currentBox].is_a?(StorageTransferBox)
    commands << cmd_info if @storage[@storage.currentBox].is_a?(StorageTransferBox)
    commands << cmd_cancel

    command = pbShowCommands(
      _INTL("What do you want to do?"), commands)
    case commands[command]
    when cmd_jump
      boxCommandJump
    when cmd_wallpaper
      boxCommandSetWallpaper
    when cmd_name
      boxCommandName
    when cmd_info
      transferBoxTutorial
    when cmd_select
      selectAllBox
    end
  end

  def singlePokemonCommands(selected)
    #@multiSelectRange = nil
    #@scene.pbUpdateSelectionRect(selected[0], selected[1])
    isTransferBox = @storage[@storage.currentBox].is_a?(StorageTransferBox)
    pokemon = @storage[selected[0], selected[1]]
    heldpoke = pbHeldPokemon
    return organizeActions(selected, pokemon, heldpoke, isTransferBox)
  end

  def multipleSelectedPokemonCommands(selected, pokemonCount)
    commands = []
    cmdMove = _INTL("Move")
    cmdRelease = _INTL("Release")
    cmdCancel = _INTL("Cancel")
    cmdSort = _INTL("Sort")

    helptext = _INTL("Selected {1} Pokémon.", pokemonCount)

    commands << cmdMove
    commands << cmdSort
    commands << cmdRelease if $DEBUG
    commands << cmdCancel

    chosen = pbShowCommands(helptext, commands)

    case commands[chosen]
    when cmdMove
      pbHoldMulti(selected[0], selected[1])
    when cmdSort
      pbSortMulti(selected[0])
    when cmdRelease
      pbReleaseMulti(selected[0])
    end
  end

  def dropAllHeldPokemon
    multiSelectAction([@storage.currentBox, 0])
  end

  # Multi-select flow: validates and delegates animations to scene.
  def multiSelectAction(selected)
    return unless @scene.cursormode == "multiselect"
    if pbMultiHeldPokemon.length > 0
      # placing multi-held from screen's held list
      place_result = pbPlaceMulti(selected[0], selected[1])
      if place_result == :PLACED_OCCUPIED
        pbSEPlay("GUI party switch")
      end

    elsif !@multiSelectRange
      pbPlayDecisionSE
      @multiSelectRange = [selected[1], nil]
      @scene.pbUpdateSelectionRect(selected[0], selected[1])
      return
    elsif !@multiSelectRange[1]
      @multiSelectRange[1] = selected[1]
      pokemonCount = 0
      noneggCount = 0
      for index in getMultiSelection(selected[0], nil)
        pokemonCount += 1 if @storage[selected[0], index]
        if @storage[selected[0], index]
          noneggCount += 1 unless @storage[selected[0], index].egg?
        end
      end
      if pokemonCount == 0
        pbPlayCancelSE
        @multiSelectRange = nil
        @scene.pbUpdateSelectionRect(selected[0], selected[1])
        return
      elsif pokemonCount == 1 && @storage[selected[0], selected[1]]
        singlePokemonCommands(selected)
      else
        multipleSelectedPokemonCommands(selected, pokemonCount)
      end
      @multiSelectRange = nil
      @scene.pbUpdateSelectionRect(selected[0], selected[1])
    end
  end

  # --- Screen-side game-rule methods (validate, commit, then animate) ---
  # Validate & pick up a selection of multiple Pokémon (logical)
  def pbHoldMulti(box, selected_index)
    if @scene.inTransferBox && box != -1
      pbPlayBuzzerSE
      return
    end
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    selected_pos = getBoxPosition(box, selected_index)
    able_count = 0
    new_held = []
    final_selected = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      able_count += 1 if pbAble?(pokemon)
      pos = getBoxPosition(box, index)
      new_held << [pokemon, pos[0] - selected_pos[0], pos[1] - selected_pos[1]]
      final_selected << index
    end

    # Prevent taking last pokemon out of party
    if box == BOX_NAME && pbAbleCount == able_count
      if new_held.length > 1
        # deselect first able pokemon for convenience
        for i in 0...new_held.length
          if pbAble?(new_held[i][0])
            new_held.delete_at(i)
            final_selected.delete_at(i)
            break
          end
        end
      else
        pbPlayBuzzerSE
        pbDisplay(_INTL("That's your last Pokémon!"))
        return
      end
    end

    # Clear selection, animate pickup, update logical state
    @multiSelectRange = nil
    @scene.pbUpdateSelectionRect(0, 0)
    @scene.animate_hold_multi(box, final_selected, selected_index) # animation
    @multiheldpkmn = new_held
    @storage.pbDeleteMulti(box, final_selected)
    if @storage[box].is_a?(StorageTransferBox)
      @saveWhenPlaceDown = true
    end
    @scene.pbRefresh
  end

  # Check if all held pokémon can strictly fit at the target positions (no overlap, no OOB).
  # Commit them to storage and animate the placement.
  def pbPlaceMulti(box, selected_index)
    return if @multiheldpkmn.nil? || @multiheldpkmn.empty?
    if @scene.inTransferBox && box != -1
      pbPlayBuzzerSE
      return
    end
    selected_pos = getBoxPosition(box, selected_index)
    if box >= 0
      # Validate every target slot is in-bounds and unoccupied
      need_fill = false
      for held in @multiheldpkmn
        held_x = held[1] + selected_pos[0]
        held_y = held[2] + selected_pos[1]
        if out_of_bounds?(box, held_x, held_y) || occupied?(box, held_x, held_y)
          need_fill = true
        end
      end
      if need_fill
        store_result = @storage.pbStoreBatch(@multiheldpkmn, box, selected_pos[0], selected_pos[1])
        if store_result == :CANT_PLACE || !store_result
          pbDisplay(_INTL("There's not enough room!"))
          return
        end
        @scene.animate_place_multi(box, selected_index)
        @multiheldpkmn = []
        @scene.pbHardRefresh

        @scene.restartBox(self, @command, false)
        @storage = $PokemonStorage
        @scene.pbRefresh
        @multiheldpkmn = []
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selected_index
        return store_result
      end

      # All validated: animate then commit
      @scene.animate_place_multi(box, selected_index)
      for held in @multiheldpkmn
        pokemon = held[0]
        held_x = held[1] + selected_pos[0]
        held_y = held[2] + selected_pos[1]
        idx = held_x + held_y * PokemonBox::BOX_WIDTH
        @storage[box, idx] = pokemon
      end
    else
      # Party placement: validate space
      party_count = @storage.party.length
      if party_count + @multiheldpkmn.length > Settings::MAX_PARTY_SIZE
        pbDisplay(_INTL("There's not enough room!"))
        return
      end

      @scene.animate_place_multi(box, selected_index)
      for held in @multiheldpkmn
        pokemon = held[0]
        @storage.party.push(pokemon)
      end
    end
    if @saveWhenPlaceDown
      @saveWhenPlaceDown = false
      Game.save()
    end

    @scene.pbRefresh
    @multiheldpkmn = []
  end

  # Validate release rules, animate release, then delete from storage
  def pbReleaseMulti(box)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    able_count = 0
    final_released = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      if pokemon.owner.name == "RENTAL"
        pbDisplay(_INTL("This Pokémon cannot be released"))
        return
      elsif pokemon.egg?
        pbDisplay(_INTL("You can't release an Egg."))
        return false
      elsif pokemon.mail
        pbDisplay(_INTL("Please remove the mail."))
        return false
      end
      able_count += 1 if pbAble?(pokemon)
      final_released << index
    end

    if box == BOX_NAME && pbAbleCount == able_count
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release {1} Pokémon?", final_released.length), [_INTL("No"), _INTL("Yes")])
    if command == 1
      command_confirm = pbShowCommands(_INTL("The {1} Pokémon will be lost forever. Release them?", final_released.length), [_INTL("No"), _INTL("Yes")])
      if command_confirm == 1
        @multiSelectRange = nil
        @scene.pbUpdateSelectionRect(0, 0)
        @scene.animate_release_multi(box, final_released)
        @storage.pbDeleteMulti(box, final_released)
        @scene.pbRefresh
        pbDisplay(_INTL("The Pokémon were released."))
        pbDisplay(_INTL("Bye-bye!"))
        @scene.pbRefresh
      end
    end
    return
  end

  def out_of_bounds?(box, x, y)
    width = (box == BOX_NAME ? 2 : PokemonBox::BOX_WIDTH)
    height = (box == BOX_NAME ? (Settings::MAX_PARTY_SIZE / 2.0).ceil : PokemonBox::BOX_HEIGHT)
    x < 0 || y < 0 || x >= width || y >= height
  end

  def occupied?(box, x, y)
    idx = x + y * PokemonBox::BOX_WIDTH
    !!@storage[box, idx]
  end

  def pbMultiHeldPokemon
    @multiheldpkmn
  end

  def pbHolding?
    return @heldpkmn != nil || (@multiheldpkmn && @multiheldpkmn.length > 0)
  end

  def getSelectionRect(box, currentSelected)
    range_end = (currentSelected != nil ? currentSelected : @multiSelectRange && @multiSelectRange[1])
    return nil unless @multiSelectRange && @multiSelectRange[0] && range_end

    box_width = box == BOX_NAME ? 2 : PokemonBox::BOX_WIDTH

    ax = @multiSelectRange[0] % box_width
    ay = (@multiSelectRange[0].to_f / box_width).floor
    bx = range_end % box_width
    by = (range_end.to_f / box_width).floor

    minx = [ax, bx].min
    miny = [ay, by].min
    maxx = [ax, bx].max
    maxy = [ay, by].max

    Rect.new(minx, miny, maxx - minx + 1, maxy - miny + 1)
  end

  def getMultiSelection(box, currentSelected)
    rect = getSelectionRect(box, currentSelected)
    return [] if rect.nil?

    ret = []
    for j in (rect.y)..(rect.y + rect.height - 1)
      for i in (rect.x)..(rect.x + rect.width - 1)
        ret << getBoxIndex(box, i, j)
      end
    end
    ret
  end

  def getBoxIndex(box, x, y)
    box_width = box == BOX_NAME ? 2 : PokemonBox::BOX_WIDTH
    x + y * box_width
  end

  def getBoxPosition(box, index)
    box_width = box == BOX_NAME ? 2 : PokemonBox::BOX_WIDTH
    [index % box_width, (index.to_f / box_width).floor]
  end
end
