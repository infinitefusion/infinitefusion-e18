#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class SafariReleaseStorageScreen < PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage
  attr_accessor :heldpkmn
  attr_accessor :fusionMode
  attr_accessor :filterProc

  def initialize(scene, storage)
    super(scene, storage)
    @release_pokemon = []
  end

  def pbStartScreen(command, animate = true)
    super
    return @release_pokemon
  end

  def pcOrganizeCommand
    @scene.pbSetCursorMode("multiselect")
    super
  end

  def singlePokemonCommands(selected)
    return multipleSelectedPokemonCommands([selected],1)
  end

  #differences from normal: release is in first position
  def multipleSelectedPokemonCommands(selected, pokemonCount)
    commands = []
    cmdRelease = _INTL("Release")
    cmdMove = _INTL("Move")
    cmdCancel = _INTL("Cancel")
    cmdSort = _INTL("Sort")

    helptext = _INTL("Selected {1} Pokémon.", pokemonCount)

    commands << cmdRelease
    commands << cmdMove
    commands << cmdSort
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

  def releasable?(pokemon)
    return false if !pokemon
    return true if @filterProc.nil?
    return @filterProc.call(pokemon)
  end

  #differences from normal: release is in first position
  def pbReleaseMulti(box)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    able_count = 0
    final_released = []
    released_mons = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      next if !releasable?(pokemon) # ignore Pokémon that fail the filter
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
      released_mons << pokemon
    end

    if final_released.empty?
      pbPlayBuzzerSE
      pbDisplay(_INTL("None of the selected Pokémon can be released."))
      return
    end

    if box == BOX_NAME && pbAbleCount == able_count
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release {1} Pokémon?", final_released.length), [_INTL("Yes"), _INTL("No")])
    if command == 0
      command_confirm = pbShowCommands(_INTL("The {1} Pokémon will be lost forever. Release them?", final_released.length), [_INTL("Yes"), _INTL("No")])
      if command_confirm == 0
        @multiSelectRange = nil
        @scene.pbUpdateSelectionRect(0, 0)
        @scene.animate_release_multi(box, final_released)
        @storage.pbDeleteMulti(box, final_released)
        @scene.pbRefresh
        pbDisplay(_INTL("The Pokémon were released."))
        pbDisplay(_INTL("Bye-bye!"))
        @scene.pbRefresh

        @release_pokemon.concat(released_mons)
      end
    end
    return
  end

  # def setFilter(filterProc)
  #   @filterProc = filterProc
  # end

  # TODO: Open party screen by default.
  # Handle when player chooses a Pokemon from their party instead of a box
  # def choosePokemon
  #   super
  # end

  #
  # def organizeActions(selected, pokemon, heldpoke, isTransferBox)
  #   commands = []
  #   cmdMove = -1
  #   cmdSummary = -1
  #   cmdWithdraw = -1
  #   cmdItem = -1
  #   cmdFuse = -1
  #   cmdUnfuse = -1
  #   cmdReverse = -1
  #   cmdRelease = -1
  #   cmdDebug = -1
  #   cmdCancel = -1
  #   cmdNickname = -1
  #
  #   if heldpoke
  #     helptext = _INTL("{1} is selected.", heldpoke.name)
  #     commands[cmdMove = commands.length] = (pokemon) ? _INTL("Shift") : _INTL("Place")
  #   elsif pokemon
  #     helptext = _INTL("{1} is selected.", pokemon.name)
  #     commands[cmdMove = commands.length] = _INTL("Move")
  #   end
  #   commands[cmdSummary = commands.length] = _INTL("Summary")
  #   # if pokemon != nil && !isTransferBox
  #   #   if dexNum(pokemon.species) > NB_POKEMON
  #   #     commands[cmdUnfuse = commands.length] = _INTL("Unfuse")
  #   #     commands[cmdReverse = commands.length] = _INTL("Reverse") if $PokemonBag.pbQuantity(:DNAREVERSER) > 0 || $PokemonBag.pbQuantity(:INFINITEREVERSERS) > 0
  #   #   else
  #   #     commands[cmdFuse = commands.length] = _INTL("Fuse") if !@heldpkmn
  #   #   end
  #   # end
  #   # commands[cmdNickname = commands.length] = _INTL("Nickname") if !@heldpkmn && !isTransferBox
  #   # commands[cmdWithdraw = commands.length] = (selected[0] == -1) ? _INTL("Store") : _INTL("Withdraw")
  #   # commands[cmdItem = commands.length] = _INTL("Item") if !isTransferBox
  #
  #   commands[cmdRelease = commands.length] = _INTL("Release")
  #   commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG
  #   commands[cmdCancel = commands.length] = _INTL("Cancel")
  #   command = pbShowCommands(helptext, commands)
  #   if cmdMove >= 0 && command == cmdMove # Move/Shift/Place
  #     #@scene.pbSetCursorMode("default")
  #     if @heldpkmn
  #       (pokemon) ? pbSwap(selected) : pbPlace(selected)
  #     else
  #       if @scene.cursormode == "multiselect"
  #         pbHoldMulti(selected[0], selected[1])
  #       else
  #         pbHold(selected)
  #       end
  #     end
  #   elsif cmdSummary >= 0 && command == cmdSummary # Summary
  #     pbSummary(selected, @heldpkmn)
  #   elsif cmdNickname >= 0 && command == cmdNickname # Summary
  #     renamePokemon(selected)
  #   elsif cmdWithdraw >= 0 && command == cmdWithdraw # Store/Withdraw
  #     (selected[0] == -1) ? pbStore(selected, @heldpkmn) : pbWithdraw(selected, @heldpkmn)
  #   elsif cmdItem >= 0 && command == cmdItem # Item
  #     pbItem(selected, @heldpkmn)
  #   elsif cmdFuse >= 0 && command == cmdFuse # fuse
  #     pbFuseFromPC(selected, @heldpkmn)
  #   elsif cmdUnfuse >= 0 && command == cmdUnfuse # unfuse
  #     pbUnfuseFromPC(selected)
  #   elsif cmdReverse >= 0 && command == cmdReverse # unfuse
  #     reverseFromPC(selected)
  #   elsif cmdRelease >= 0 && command == cmdRelease # Release
  #     pbRelease(selected, @heldpkmn)
  #   elsif cmdDebug >= 0 && command == cmdDebug # Debug
  #     pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon, selected, heldpoke)
  #   end
  # end

  # def quickSwap(selected, pokemon)
  #   if @heldpkmn
  #     (pokemon) ? pbSwap(selected) : pbPlace(selected)
  #   else
  #     pbHold(selected)
  #   end
  # end

  # def pcSelectCommand
  #   @scene.choseFromParty = true
  #   loop do
  #     selected = @scene.pbSelectBox(@storage.party)
  #     if selected == nil
  #       next if pbConfirm(_INTL("Continue Box operations?"))
  #       break
  #     else
  #       case selected[0]
  #       when -2 # Party Pokémon
  #         pbDisplay(_INTL("Which one will you choose?"))
  #         next
  #       when -3 # Close box
  #         if pbConfirm(_INTL("Cancel choosing a Pokémon?"))
  #           pbSEPlay("PC close")
  #           break
  #         end
  #         return nil
  #       when -4 # Box name
  #         pbBoxCommands
  #         next
  #       end
  #       pokemon = @storage[selected[0], selected[1]]
  #       next if !pokemon
  #       if @filterProc.call(pokemon)
  #         command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), [
  #           _INTL("Choose"),
  #           _INTL("Summary"),
  #           _INTL("Cancel")
  #         ])
  #         case command
  #         when 0 then
  #           return selected
  #         when 1 then
  #           pbSummary(selected, nil)
  #         end
  #       else
  #         pbDisplay(_INTL("This Pokémon cannot be chosen..."))
  #         next
  #       end
  #     end
  #   end
  #   @scene.pbCloseBox
  # end

  def pbHold(selected)
    super
  end

  def pbPlace(selected)
    super
  end

  def pbSwap(selected)
    super
  end

  def pbSummary(selected, heldpoke)
    @scene.pbSummary(selected, heldpoke)
  end

  # def pbChoosePokemon(_party = nil)
  #   @heldpkmn = nil
  #   @scene.pbStartBox(self, 1)
  #   retval = nil
  #   loop do
  #     selected = @scene.pbSelectBox(@storage.party)
  #     if selected && selected[0] == -3 # Close box
  #       if pbConfirm(_INTL("Exit from the Box?"))
  #         pbSEPlay("PC close")
  #         break
  #       end
  #       next
  #     end
  #     if selected == nil
  #       next if pbConfirm(_INTL("Continue Box operations?"))
  #       break
  #     elsif selected[0] == -4 # Box name
  #       pbBoxCommands
  #     else
  #       pokemon = @storage[selected[0], selected[1]]
  #       next if !pokemon
  #       commands = [
  #         _INTL("Select"),
  #         _INTL("Summary"),
  #         _INTL("Withdraw"),
  #         _INTL("Item"),
  #         _INTL("Mark")
  #       ]
  #       commands.push(_INTL("Cancel"))
  #       commands[2] = _INTL("Store") if selected[0] == -1
  #       helptext = _INTL("{1} is selected.", pokemon.name)
  #       command = pbShowCommands(helptext, commands)
  #       case command
  #       when 0 # Select
  #         if pokemon
  #           retval = selected
  #           break
  #         end
  #       when 1
  #         pbSummary(selected, nil)
  #       when 2 # Store/Withdraw
  #         if selected[0] == -1
  #           pbStore(selected, nil)
  #         else
  #           pbWithdraw(selected, nil)
  #         end
  #       when 3
  #         pbItem(selected, nil)
  #       when 4
  #         pbMark(selected, nil)
  #       end
  #     end
  #   end
  #   @scene.pbCloseBox
  #   return retval
  # end

  def deleteHeldPokemon(heldpoke, selected)
    @scene.pbReleaseInstant(selected, heldpoke)
    @heldpkmn = nil
  end

  def deleteSelectedPokemon(heldpoke, selected)
    pbSwap(selected)
    deleteHeldPokemon(heldpoke, selected)
  end
end

class SafariReleaseStorageScene < PokemonStorageScene
  def transfer_box?(box_index)
    box_index >= 0 && @storage[box_index].is_a?(StorageTransferBox)
  end

  def next_valid_box(from, step)
    total = @storage.maxBoxes
    box = from
    total.times do
      box = (box + step) % total
      return box unless transfer_box?(box)
    end
    from
  end

  def pbNextCursorMode()
    return
  end

end