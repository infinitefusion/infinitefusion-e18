#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage
  attr_accessor :heldpkmn
  attr_accessor :fusionMode
  attr_accessor :filterProc

  def initialize(scene, storage)
    @scene = scene
    @storage = storage
    @pbHeldPokemon = nil
    @command = 0
    @filterProc = nil
    @saveWhenPlaceDown = false
  end

  def setFilter(filterProc)
    @filterProc = filterProc
  end

  def pbStartScreen(command, animate = true)
    @heldpkmn = nil
    @command = command
    if command == 0 # Organise
      @scene.pbStartBox(self, command, animate)
      pcOrganizeCommand
    elsif command == 1 # Withdraw
      @scene.pbStartBox(self, command, animate)
      pcWithdrawCommand
    elsif command == 2 # Deposit
      @scene.pbStartBox(self, command, animate)
      pcDepositCommand
    else
      @scene.pbStartBox(self, command, animate)
      @scene.pbCloseBox
    end
  end

  # TODO: Open party screen by default.
  # Handle when player chooses a Pokemon from their party instead of a box
  def choosePokemon
    command = COMMAND_SELECT_POKEMON
    @scene.pbStartBox(self, command, true)
    return pcSelectCommand
  end

  def pcOrganizeCommand()
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected == nil
        if pbHeldPokemon
          pbDisplay(_INTL("You're holding a Pokémon!"))
          next
        end
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == -3 # Close box
        if pbHeldPokemon
          pbDisplay(_INTL("You're holding a Pokémon!"))
          next
        end
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      elsif selected[0] == -4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        heldpoke = pbHeldPokemon
        next if !pokemon && !heldpoke
        if @scene.quickswap
          quickSwap(selected, pokemon)
        else
          if @fusionMode
            pbFusionCommands(selected)
          else
            organizeActions(selected, pokemon, heldpoke, @scene.inTransferBox)
          end
        end
      end
    end
    @scene.pbCloseBox
  end

  def organizeActions(selected, pokemon, heldpoke, isTransferBox)
    commands = []
    cmdMove = -1
    cmdSummary = -1
    cmdWithdraw = -1
    cmdItem = -1
    cmdFuse = -1
    cmdUnfuse = -1
    cmdReverse = -1
    cmdRelease = -1
    cmdDebug = -1
    cmdCancel = -1
    cmdNickname = -1

    if heldpoke
      helptext = _INTL("{1} is selected.", heldpoke.name)
      commands[cmdMove = commands.length] = (pokemon) ? _INTL("Shift") : _INTL("Place")
    elsif pokemon
      helptext = _INTL("{1} is selected.", pokemon.name)
      commands[cmdMove = commands.length] = _INTL("Move")
    end
    commands[cmdSummary = commands.length] = _INTL("Summary")
    if pokemon != nil && !isTransferBox
      if dexNum(pokemon.species) > NB_POKEMON
        commands[cmdUnfuse = commands.length] = _INTL("Unfuse")
        commands[cmdReverse = commands.length] = _INTL("Reverse") if $PokemonBag.pbQuantity(:DNAREVERSER) > 0 || $PokemonBag.pbQuantity(:INFINITEREVERSERS) > 0
      else
        commands[cmdFuse = commands.length] = _INTL("Fuse") if !@heldpkmn
      end
    end
    commands[cmdNickname = commands.length] = _INTL("Nickname") if !@heldpkmn && !isTransferBox
    commands[cmdWithdraw = commands.length] = (selected[0] == -1) ? _INTL("Store") : _INTL("Withdraw")
    commands[cmdItem = commands.length] = _INTL("Item") if !isTransferBox

    commands[cmdRelease = commands.length] = _INTL("Release")
    commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG
    commands[cmdCancel = commands.length] = _INTL("Cancel")
    command = pbShowCommands(helptext, commands)
    if cmdMove >= 0 && command == cmdMove # Move/Shift/Place
      #@scene.pbSetCursorMode("default")
      if @heldpkmn
        (pokemon) ? pbSwap(selected) : pbPlace(selected)
      else
        if @scene.cursormode == "multiselect"
          pbHoldMulti(selected[0], selected[1])
        else
          pbHold(selected)
        end
      end
    elsif cmdSummary >= 0 && command == cmdSummary # Summary
      pbSummary(selected, @heldpkmn)
    elsif cmdNickname >= 0 && command == cmdNickname # Summary
      renamePokemon(selected)
    elsif cmdWithdraw >= 0 && command == cmdWithdraw # Store/Withdraw
      (selected[0] == -1) ? pbStore(selected, @heldpkmn) : pbWithdraw(selected, @heldpkmn)
    elsif cmdItem >= 0 && command == cmdItem # Item
      pbItem(selected, @heldpkmn)
    elsif cmdFuse >= 0 && command == cmdFuse # fuse
      pbFuseFromPC(selected, @heldpkmn)
    elsif cmdUnfuse >= 0 && command == cmdUnfuse # unfuse
      pbUnfuseFromPC(selected)
    elsif cmdReverse >= 0 && command == cmdReverse # unfuse
      reverseFromPC(selected)
    elsif cmdRelease >= 0 && command == cmdRelease # Release
      pbRelease(selected, @heldpkmn)
    elsif cmdDebug >= 0 && command == cmdDebug # Debug
      pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon, selected, heldpoke)
    end
  end

  def quickSwap(selected, pokemon)
    if @heldpkmn
      (pokemon) ? pbSwap(selected) : pbPlace(selected)
    else
      pbHold(selected)
    end
  end

  def pcSelectCommand
    @scene.choseFromParty = true
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected == nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      else
        case selected[0]
        when -2 # Party Pokémon
          pbDisplay(_INTL("Which one will you choose?"))
          next
        when -3 # Close box
          if pbConfirm(_INTL("Cancel choosing a Pokémon?"))
            pbSEPlay("PC close")
            break
          end
          return nil
        when -4 # Box name
          pbBoxCommands
          next
        end
        pokemon = @storage[selected[0], selected[1]]
        next if !pokemon
        if @filterProc.call(pokemon)
          command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
            _INTL("Choose"),
            _INTL("Summary"),
            _INTL("Cancel")
          ])
          case command
          when 0 then
            return selected
          when 1 then
            pbSummary(selected, nil)
          end
        else
          pbDisplay(_INTL("This Pokémon cannot be chosen..."))
          next
        end
      end
    end
    @scene.pbCloseBox
  end

  def pcWithdrawCommand
    isTransferBox = @storage[@storage.currentBox].is_a?(StorageTransferBox)
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected == nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      else
        case selected[0]
        when -2 # Party Pokémon
          pbDisplay(_INTL("Which one will you take?"))
          next
        when -3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        when -4 # Box name
          pbBoxCommands
          next
        end
        if @fusionMode
          pbFusionCommands(selected)
        else
          pokemon = @storage[selected[0], selected[1]]
          next if !pokemon
          command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
            _INTL("Withdraw"),
            _INTL("Summary"),
            _INTL("Release"),
            _INTL("Cancel")
          ])
          case command
          when 0 then
            pbWithdraw(selected, nil)
          when 1 then
            pbSummary(selected, nil)
            # when 2 then pbMark(selected, nil)
          when 2 then
            pbRelease(selected, nil)
          end

        end
      end
    end
    @scene.pbCloseBox
  end

  def pcDepositCommand
    isTransferBox = @storage[@storage.currentBox].is_a?(StorageTransferBox)
    loop do
      selected = @scene.pbSelectParty(@storage.party)
      if selected == -3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      elsif selected < 0
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      else
        pokemon = @storage[-1, selected]
        next if !pokemon
        command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
          _INTL("Store"),
          _INTL("Summary"),
          _INTL("Mark"),
          _INTL("Release"),
          _INTL("Cancel")
        ])
        case command
        when 0 then
          pbStore([-1, selected], nil)
        when 1 then
          pbSummary([-1, selected], nil)
        when 2 then
          pbMark([-1, selected], nil)
        when 3 then
          pbRelease([-1, selected], nil)
        end
      end
    end
    @scene.pbCloseBox
  end

  def renamePokemon(selected)
    box = selected[0]
    index = selected[1]
    pokemon = @storage[box, index]

    if pokemon.egg?
      pbDisplay(_INTL("You cannot rename an egg!"))
      return
    end

    speciesname = PBSpecies.getName(pokemon.species)
    hasNickname = speciesname == pokemon.name
    if hasNickname
      pbDisplay(_INTL("{1} has no nickname.", speciesname))
    else
      pbDisplay(_INTL("{1} has the nickname {2}.", speciesname, pokemon.name))
    end
    commands = [
      _INTL("Rename"),
      _INTL("Quit")
    ]
    command = pbShowCommands(
      _INTL("What do you want to do?"), commands)
    case command
    when 0
      newname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname), 0, Pokemon::MAX_NAME_SIZE, "", pokemon)
      pokemon.name = (newname == "") ? speciesname : newname
      pbDisplay(_INTL("{1} is now named {2}!", speciesname, pokemon.name))
    when 1
      return
    end
  end

  def pbUpdate # For debug
    @scene.update
  end

  def pbHardRefresh # For debug
    @scene.pbHardRefresh
  end

  def pbRefreshSingle(i)
    # For debug
    @scene.pbUpdateOverlay(i[1], (i[0] == -1) ? @storage.party : nil)
    @scene.pbHardRefresh
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbConfirm(str)
    return pbShowCommands(str, [_INTL("Yes"), _INTL("No")]) == 0
  end

  def pbShowCommands(msg, commands, index = 0)
    return @scene.pbShowCommands(msg, commands, index)
  end

  def pbAble?(pokemon)
    pokemon && !pokemon.egg? && pokemon.hp > 0
  end

  def pbAbleCount
    count = 0
    for p in @storage.party
      count += 1 if pbAble?(p)
    end
    return count
  end

  def pbHeldPokemon
    return @heldpkmn
  end

  def pbWithdraw(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box == -1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage.party_full?
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    if @scene.inTransferBox && @storage[box].can_use_transfer_box?
      pokemon = $PokemonStorage[*selected]
      return if @storage[box].check_is_duplicate(pokemon)
      unless verifyTransferBoxAutosave
        return
      end
    end

    @scene.pbWithdraw(selected, heldpoke, @storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn = nil
    else
      @storage.pbMove(-1, -1, box, index)
    end
    @scene.pbRefresh
    return true
  end

  def pbStore(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if box != -1
      raise _INTL("Can't deposit from box...")
    end
    if pbAbleCount <= 1 && pbAble?(@storage[box, index]) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif heldpoke && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !heldpoke && @storage[box, index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox >= 0
          firstfree = @storage.pbFirstFreePos(destbox)
          if firstfree < 0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          if heldpoke || selected[0] == -1
            p = (heldpoke) ? heldpoke : @storage[-1, index]
            p.time_form_set = nil
            # p.form = 0 if p.isSpecies?(:SHAYMIN)
            # p.heal
          end
          @scene.pbStore(selected, heldpoke, destbox, firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke, destbox)
            @heldpkmn = nil
          else
            @storage.pbMove(destbox, -1, -1, index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbHold(selected)
    box = selected[0]
    index = selected[1]
    if @scene.inTransferBox && box != -1
      pokemon = $PokemonStorage[*selected]
      return if @storage[box].check_is_duplicate(pokemon)
      unless verifyTransferBoxAutosave
        return
      end
    end
    if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn = @storage[box, index]
    @storage.pbDelete(box, index)
    @scene.pbRefresh
    if @scene.inTransferBox && box != -1
      @saveWhenPlaceDown = true
    end
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @scene.inTransferBox && box != -1
      if @heldpkmn.owner.name == "RENTAL"
        pbMessage(_INTL("This Pokémon cannot be transferred."))
        return
      end
      return if @storage[box].check_is_duplicate(@heldpkmn)
      unless verifyTransferBoxAutosave  #Warning on the first time
        return
      end
    end

    if @storage[box, index]
      pbDisplay(_INTL("Can't place that there."))
      return
      echoln _INTL("Position {1},{2} is not empty...", box, index)
    end
    if box != -1 && index >= @storage.maxPokemon(box)
      pbDisplay(_INTL("Can't place that there."))
      return
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if box >= 0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      #@heldpkmn.heal
    end
    @scene.pbPlace(selected, @heldpkmn)
    @storage[box, index] = @heldpkmn
    if box == -1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
    if @saveWhenPlaceDown
      @saveWhenPlaceDown = false
      Game.save()
    end
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]

    if !@storage[box, index]
      raise _INTL("Position {1},{2} is empty...", box, index)
    end

    if @scene.inTransferBox && box != -1
      if @heldpkmn.owner.name == "RENTAL"
        pbMessage(_INTL("This Pokémon cannot be transferred."))
        return
      end
      pokemon = $PokemonStorage[*selected]
      return if @storage[box].check_is_duplicate(pokemon)

      unless verifyTransferBoxAutosave
        return
      end
    end

    if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1 && !pbAble?(@heldpkmn)
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box != -1 && @heldpkmn.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box >= 0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      #@heldpkmn.heal
    end
    @scene.pbSwap(selected, @heldpkmn)
    tmp = @storage[box, index]
    @storage[box, index] = @heldpkmn
    @heldpkmn = tmp
    if @saveWhenPlaceDown
      @saveWhenPlaceDown = false
      Game.save()
    end
    @scene.pbRefresh
    return true
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box, index]
    return if !pokemon
    if pokemon.egg?
      pbDisplay(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box == -1 && pbAbleCount <= 1 && pbAble?(pokemon) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release this Pokémon?"), [_INTL("No"), _INTL("Yes")])
    if command == 1
      if pokemon.owner.name == "RENTAL"
        pbDisplay(_INTL("This Pokémon cannot be released"))
        return
      end

      pkmnname = pokemon.name
      @scene.pbRelease(selected, heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box, index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.", pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!", pkmnname))
      @scene.pbRefresh
    end
    return
  end

  def pbChooseMove(pkmn, helptext, index = 0)
    movenames = []
    for i in pkmn.moves
      if i.total_pp <= 0
        movenames.push(_INTL("{1} (PP: ---)", i.name))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
      end
    end
    return @scene.pbShowCommands(helptext, movenames, index)
  end

  def pbSummary(selected, heldpoke)
    @scene.pbSummary(selected, heldpoke)
  end

  def pbMark(selected, heldpoke)
    @scene.pbMark(selected, heldpoke)
  end

  def pbItem(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box, index]
    if pokemon.egg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if pokemon.item
      itemname = pokemon.item.name
      if pbConfirm(_INTL("Take this {1}?", itemname))
        if !$PokemonBag.pbStoreItem(pokemon.item)
          pbDisplay(_INTL("Can't store the {1}.", itemname))
        else
          pbDisplay(_INTL("Took the {1}.", itemname))
          pokemon.item = nil
          @scene.pbHardRefresh
        end
      end
    else
      item = scene.pbChooseItem($PokemonBag)
      if item
        itemname = GameData::Item.get(item).name
        pokemon.item = item
        $PokemonBag.pbDeleteItem(item)
        pbDisplay(_INTL("{1} is now being held.", itemname))
        @scene.pbHardRefresh
      end
    end
  end

  def pbBoxCommands
    cmd_jump = _INTL("Jump")
    cmd_wallpaper = _INTL("Wallpaper")
    cmd_name = _INTL("Name")
    cmd_info = _INTL("Info")
    cmd_cancel = _INTL("Cancel")

    commands = []
    commands << cmd_jump
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
    end
  end

  def boxCommandName
    @scene.pbBoxName(_INTL("Box name?"), 0, 20)
  end

  def boxCommandJump
    destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
    if destbox >= 0
      @scene.pbJumpToBox(destbox)
    end
  end

  def boxCommandSetWallpaper
    papers = @storage.availableWallpapers
    index = 0
    for i in 0...papers[1].length
      if papers[1][i] == @storage[@storage.currentBox].background
        index = i; break
      end
    end
    wpaper = pbShowCommands(_INTL("Pick the wallpaper."), papers[0], index)
    if wpaper >= 0
      @scene.pbChangeBackground(papers[1][wpaper])
    end
  end

  def pbChoosePokemon(_party = nil)
    @heldpkmn = nil
    @scene.pbStartBox(self, 1)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0] == -3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      end
      if selected == nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == -4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        next if !pokemon
        commands = [
          _INTL("Select"),
          _INTL("Summary"),
          _INTL("Withdraw"),
          _INTL("Item"),
          _INTL("Mark")
        ]
        commands.push(_INTL("Cancel"))
        commands[2] = _INTL("Store") if selected[0] == -1
        helptext = _INTL("{1} is selected.", pokemon.name)
        command = pbShowCommands(helptext, commands)
        case command
        when 0 # Select
          if pokemon
            retval = selected
            break
          end
        when 1
          pbSummary(selected, nil)
        when 2 # Store/Withdraw
          if selected[0] == -1
            pbStore(selected, nil)
          else
            pbWithdraw(selected, nil)
          end
        when 3
          pbItem(selected, nil)
        when 4
          pbMark(selected, nil)
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end

  #
  # Fusion stuff
  #

  def pbFuseFromPC(selected, heldpoke)
    @scene.pbSetCursorMode("default")
    box = selected[0]
    index = selected[1]
    poke_body = @storage[box, index]
    poke_head = heldpoke
    if heldpoke
      if dexNum(heldpoke.species) > NB_POKEMON
        pbDisplay(_INTL("{1} is already fused!", heldpoke.name))
        return
      end
      if (heldpoke.egg?)
        pbDisplay(_INTL("It's impossible to fuse an egg!"))
        return
      end
    end

    splicerItem = selectSplicer()
    if splicerItem == nil
      cancelFusion()
      return
    end

    if !heldpoke
      @fusionMode = true
      @fusionItem = splicerItem
      @scene.setFusing(true, @fusionItem)
      pbHold(selected)
      pbDisplay(_INTL("Select a Pokémon to fuse it with"))
      @scene.sprites["box"].disableFusions()
      return
    end
    if !poke_body
      pbDisplay(_INTL("Select a Pokémon to fuse it with"))
      @fusionMode = true
      @fusionItem = splicerItem
      @scene.setFusing(true, @fusionItem)
      return
    end
  end

  def deleteHeldPokemon(heldpoke, selected)
    @scene.pbReleaseInstant(selected, heldpoke)
    @heldpkmn = nil
  end

  def deleteSelectedPokemon(heldpoke, selected)
    pbSwap(selected)
    deleteHeldPokemon(heldpoke, selected)
  end

  def cancelFusion
    @splicerItem = nil
    @scene.setFusing(false)
    @fusionMode = false
    @scene.sprites["box"].enableFusions()
  end

  def canDeleteItem(item)
    return item == :SUPERSPLICERS || item == :DNASPLICERS
  end

  def isSuperSplicer?(item)
    return item == :SUPERSPLICERS || item == :INFINITESPLICERS2
  end

  def pbFusionCommands(selected)
    heldpoke = pbHeldPokemon
    pokemon = @storage[selected[0], selected[1]]

    if !pokemon
      command = pbShowCommands(_INTL("Select an action"), [_INTL("Continue fusing"), _INTL("Stop fusing")])
      case command
      when 1 # stop
        cancelFusion()
      end
    else
      commands = [
        _INTL("Fuse"),
        _INTL("Swap")
      ]
      commands.push(_INTL("Stop fusing"))
      commands.push(_INTL("Continue fusing"))

      if !heldpoke
        pbPlace(selected)
        @fusionMode = false
        @scene.setFusing(false)
        return
      end
      command = pbShowCommands(_INTL("Select an action"), commands)
      case command
      when 0 # Fuse
        if !pokemon
          pbDisplay(_INTL("No Pokémon selected!"))
          return
        else
          if dexNum(pokemon.species) > NB_POKEMON
            pbDisplay(_INTL("This Pokémon is already fused!"))
            return
          end
        end
        isSuperSplicer = isSuperSplicer?(@fusionItem)

        selectedHead, selected_sprite = selectFusion(pokemon, heldpoke, isSuperSplicer)
        if selectedHead == nil
          pbDisplay(_INTL("It won't have any effect."))
          return false
        end
        if selectedHead == -1 # cancelled out
          return false
        end

        selectedBase = selectedHead == pokemon ? heldpoke : pokemon
        firstOptionSelected = selectedBase == pokemon

        if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?")))
          playingBGM = $game_system.getPlayingBGM
          pbFuse(selectedHead, selectedBase, @fusionItem, selected_sprite)
          if canDeleteItem(@fusionItem)
            $PokemonBag.pbDeleteItem(@fusionItem)
          end
          if firstOptionSelected
            deleteSelectedPokemon(heldpoke, selected)
          else
            deleteHeldPokemon(heldpoke, selected)
          end

          @scene.setFusing(false)
          @fusionMode = false
          @scene.sprites["box"].enableFusions()
          pbBGMPlay(playingBGM)
          return
        else
          # print "fusion cancelled"
          # @fusionMode = false
        end
      when 1 # swap
        if pokemon
          if dexNum(pokemon.species) <= NB_POKEMON
            pbSwap(selected)
          else
            pbDisplay(_INTL("This Pokémon is already fused!"))
          end
        else
          pbDisplay(_INTL("Select a Pokémon!"))
        end
      when 2 # cancel
        cancelFusion()
        return
      end
    end
  end

  def reverseFromPC(selected)
    box = selected[0]
    index = selected[1]
    pokemon = @storage[box, index]

    if !pokemon.isFusion?
      scene.pbDisplay(_INTL("It won't have any effect."))
      return
    end
    if Kernel.pbConfirmMessage(_INTL("Should {1} be reversed?", pokemon.name))
      reverseFusion(pokemon)
      $PokemonBag.pbDeleteItem(:DNAREVERSER) if $PokemonBag.pbQuantity(:INFINITEREVERSERS) <= 0
    end
    @scene.pbHardRefresh
  end

  def pbUnfuseFromPC(selected)
    box = selected[0]
    index = selected[1]
    pokemon = @storage[box, index]

    if pbConfirm(_INTL("Unfuse {1}?", pokemon.name))
      item = selectSplicer()
      return if item == nil
      isSuperSplicer = isSuperSplicer?(item)
      if pbUnfuse(pokemon, @scene, nil, selected)
        if canDeleteItem(item)
          $PokemonBag.pbDeleteItem(item)
        end
      end
      @scene.pbHardRefresh
    end
  end

end