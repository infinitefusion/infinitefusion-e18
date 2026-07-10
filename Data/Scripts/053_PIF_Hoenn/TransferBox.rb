
class PokemonGlobalMetadata
  attr_accessor :seen_transfer_box_tutorial
end

def transferBoxTutorial
  pbMessage(_INTL("This is the \\C[1]Transfer Box\\C[0]."))
  pbMessage(_INTL("This box can be used to transfer Pokémon between \\C[1]Pokémon Infinite Fusion\\C[0] and \\C[1]Pokémon Infinite Fusion: Hoenn\\C[0] or between savefiles."))
  pbMessage(_INTL("Any Pokémon that is placed in this box will be accessible from every savefile of either game. You can deposit or withdraw Pokémon just like you would for any other box."))
end

class StorageTransferBox < PokemonBox
  TRANSFER_BOX_NAME = _INTL("Transfer Box")
  TRANSFER_BOX_NAME_DISABLED = _INTL("Transfer Box (Off)")

  def initialize()
    super(TRANSFER_BOX_NAME,PokemonBox::BOX_SIZE)
    @pokemon = []
    @background = "transfer"
    @disabled= false
    for i in 0...PokemonBox::BOX_SIZE
      @pokemon[i] = nil
    end
    if can_use_transfer_box?
      loadTransferBoxPokemon
    else
      pbMessage(_INTL("The Transfer Box is disabled because your savefile is flagged as randomized. You can still use it as a normal PC box, but the Pokémon you put in it won't be available in your other savefiles"))
    end
  end

  def can_use_transfer_box?
    return !$game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] && !@disabled
  end

  def setDisabled
    unless @disabled
      @name = TRANSFER_BOX_NAME_DISABLED
      pbMessage(_INTL("\\C[2]The Transfer Box is disabled because your savefile is flagged as randomized. You can still use it as a normal PC box, but the Pokémon you put in it won't be available in your other savefiles"))
    end
    @disabled= true
  end

  def loadTransferBoxPokemon
    echoln "Loading transfer box"
    path = transferBoxSavePath
    if File.exist?(path)
      File.open(path, "rb") do |f|
        @pokemon = Marshal.load(f)
      end
    end
  rescue => e
    echoln "Failed to load transfer box: #{e}"
    @pokemon = Array.new(PokemonBox::BOX_SIZE, nil)
  end

  def []=(i,value)
    return unless value.nil? || value.is_a?(Pokemon)
    return if check_is_duplicate(value)
    @pokemon[i] = value
    if can_use_transfer_box?
      saveTransferBox()
      Game.save()
    end
  end


  # If you have a pokemon has the same id as the one you're trying to deposit /withdraw, then
  # blocked
  def check_is_duplicate(box_pokemon)
    return false unless box_pokemon.is_a?(Pokemon)
    used_ids = []
    $Trainer.party.each { |pokemon|
      used_ids << pokemon.personalID
    }
    $PokemonStorage.boxes.each { |box|
      box.pokemon.each { |pokemon|
        used_ids << pokemon.personalID if pokemon.is_a?(Pokemon)
      }
    }
    $PokemonGlobal.daycare.each { |daycare_data|
      pokemon = daycare_data[0]
      used_ids << pokemon.personalID if pokemon
    }

    if used_ids.count(box_pokemon.personalID) > 1
      pbPlayBuzzerSE
      pbMessage(_INTL("This Pokémon cannot be transferred."))
      return true
    end
    return false
  end

  def saveTransferBox
    return unless can_use_transfer_box?
    path = transferBoxSavePath
    dir = File.dirname(path)
    Dir.mkdir(dir) unless Dir.exist?(dir)
    File.open(path, "wb") do |f|
      Marshal.dump(@pokemon, f)
    end
    echoln "Transfer box saved to #{path}"
    Game.save
  rescue => e
    echoln "Failed to save transfer box: #{e}"
  end


  private

  def transferBoxSavePath
    save_dir = System.data_directory  # e.g., %appdata%/infinitefusion
    parent_dir = File.expand_path("..", save_dir)
    File.join(parent_dir, "infinitefusion_common", "transfer_pokemon_storage")
  end

  def isAvailableWallpaper?
    return true
  end

end

#Never add more than 1, it would just be a copy
def addPokemonStorageTransferBox()
  already_has = false
  $PokemonStorage.boxes.each do|box|
    already_has = true if box.is_a?(StorageTransferBox)
  end

  unless already_has
    $PokemonStorage.boxes << StorageTransferBox.new
  else
    echoln "Player already has transfer box - not adding"
  end
end

def verifyTransferBoxAutosave()
  if !$game_temp.transfer_box_autosave
    confirmed = pbConfirmMessage(_INTL("Moving Pokémon in and out of the transfer box will save the game automatically. Is this okay?"))
    $game_temp.transfer_box_autosave=true if confirmed
    return confirmed
  end
  return true
end



# class PokemonStorageScreen
#   alias pokemonStorageScreen_pbWithdraw pbWithdraw
#   def pbWithdraw(pokemon,heldpkmn)
#     box = @storage[@storage.currentBox]
#     if box.is_a?(StorageTransferBox) && box.can_use_transfer_box?
#       return unless check_withdrawable(pokemon)
#     end
#     pokemonStorageScreen_pbWithdraw(pokemon,heldpkmn)
#   end
# end

