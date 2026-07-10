def pbUnfuse(pokemon, scene, partyPosition=nil, pcPosition = nil)
  if pokemon.original_body && pokemon.original_head
    if pcPosition
      result = unfusePokemonFromPC(pokemon, scene, pcPosition)
    else
      result = unfusePokemonFromParty(pokemon, scene, partyPosition)
    end
  else
    result =unfusePokemonLegacy(pokemon, scene, false, pcPosition)  #still used for wild Fusions
  end
  $PokemonTemp.unfuse_count_today = 0 unless $PokemonTemp.unfuse_count_today
  $PokemonTemp.unfuse_count_today += 1
  checkUnfuseChallenges(pokemon)
  return result
end

def unfusePokemonFromPC(fused_pokemon, scene, pcPosition)
  return unless pokemonCanBeUnfused(fused_pokemon, scene)
  if pbConfirmMessage(_INTL("Should {1} be unfused?", fused_pokemon.name))
    head_pokemon,body_pokemon = unfuseCore(fused_pokemon)
    obtainUnfusedPokemonPC(head_pokemon, body_pokemon, pcPosition)
    pbSEPlay("Minimize")
    pbMessage(_INTL("Unfusing...\\....\\....\\....\\wtnp[5]"))
    pbSEPlay("Voltorb Flip Point")
    pbMessage(_INTL("Your Pokémon were successfully unfused!"))
    return true
  else
    return false
  end
end

def unfusePokemonFromParty(fused_pokemon, scene, partyPosition)
  return unless pokemonCanBeUnfused(fused_pokemon, scene)
  if pbConfirmMessage(_INTL("Should {1} be unfused?", fused_pokemon.name))

    head_pokemon,body_pokemon = unfuseCore(fused_pokemon)
    obtainUnfusedPokemonParty(head_pokemon, body_pokemon, partyPosition)
    pbSEPlay("Minimize")
    pbMessage(_INTL("Unfusing...\\....\\....\\....\\wtnp[5]"))
    pbSEPlay("Voltorb Flip Point")
    scene.pbHardRefresh
    pbMessage(_INTL("Your Pokémon were successfully unfused!"))
    return true
  else
    return false
  end
end


def unfuseCore(fused_pokemon)
  head_pokemon = fused_pokemon.original_head
  body_pokemon = fused_pokemon.original_body

  fused_head_species = fused_pokemon.species_data.head_pokemon.species
  fused_body_species = fused_pokemon.species_data.body_pokemon.species

  #If the Pokemon evolved while fused
  if fused_head_species != head_pokemon.species
    head_pokemon.species = fused_head_species
    head_pokemon.pif_sprite = nil
  end
  if fused_body_species != body_pokemon.species
    body_pokemon.species = fused_body_species
    body_pokemon.pif_sprite = nil
  end

  #Items
  $PokemonBag.pbStoreItem(fused_pokemon.item, 1) if fused_pokemon.item

  fused_pokemon.exp_gained_since_fused =0 unless fused_pokemon.exp_gained_since_fused
  # Exp
  head_pokemon.exp_gained_with_player = 0 unless head_pokemon.exp_gained_with_player
  head_pokemon.exp_gained_with_player += fused_pokemon.exp_gained_since_fused
  head_pokemon.exp += fused_pokemon.exp_gained_since_fused

  body_pokemon.exp_gained_with_player = 0 unless body_pokemon.exp_gained_with_player
  body_pokemon.exp_gained_with_player += fused_pokemon.exp_gained_since_fused
  body_pokemon.exp +=fused_pokemon.exp_gained_since_fused

  head_pokemon.calc_stats
  body_pokemon.calc_stats
  # Moves
  fused_pokemon_learned_moved = fused_pokemon.learned_moves
  fused_pokemon_learned_moved = [] unless fused_pokemon_learned_moved
  fused_pokemon_learned_moved.each do |move|
    fused_pokemon_learned_moved << move unless fused_pokemon_learned_moved.include?(move)
  end
  fused_pokemon_learned_moved.each do |move|
    head_pokemon.add_learned_move(move)
    body_pokemon.add_learned_move(move)
  end

  head_pokemon.evolve_from_party = false
  body_pokemon.evolve_from_party = false

  # Pokedex
  $Trainer.pokedex.set_seen(head_pokemon.species)
  $Trainer.pokedex.set_owned(head_pokemon.species)
  $Trainer.pokedex.set_seen(body_pokemon.species)
  $Trainer.pokedex.set_owned(body_pokemon.species)
  return [head_pokemon,body_pokemon]
end

def obtainUnfusedPokemonPC(head_pokemon, body_pokemon, pcPosition)
  box = pcPosition[0]
  index = pcPosition[1]
  # todo: store at next available position from current position
  $PokemonStorage.pbDelete(box,index)
  if box == -1 #Player party
    pbAddPokemonSilent(head_pokemon)
    pbAddPokemonSilent(body_pokemon)
  else
    $PokemonStorage.pbStoreCaught(head_pokemon)
    $PokemonStorage.pbStoreCaught(body_pokemon)
  end
end

def obtainUnfusedPokemonParty(head_pokemon, body_pokemon, partyPosition)
  if $Trainer.party.length >= 6
    message = _INTL("Your party is full! Keep which Pokémon in party?")
    message = _INTL("Your party is full! Keep which Pokémon in party? The other will be released.") if isOnPinkanIsland()
    pbMessage(message)
    selectPokemonMessage = _INTL("Select a Pokémon to keep in your party.")
    selectPokemonMessage = _INTL("Select a Pokémon to keep in your party. The other will be released") if isOnPinkanIsland()
    choice = Kernel.pbMessage(selectPokemonMessage, ["#{head_pokemon.name}", "#{body_pokemon.name}", _INTL("Cancel")], 2)
    #Removes the fusion, then store in an order that depends on which one is sent to PC
    if choice == 0 # Head
      if isOnPinkanIsland()
        $Trainer.party.delete_at(partyPosition)
        pbAddPokemon(head_pokemon)
      else
        $Trainer.party[partyPosition] = head_pokemon
        $PokemonStorage.pbStoreCaught(body_pokemon)
      end
    elsif choice == 1 #body
      if isOnPinkanIsland()
        $Trainer.party.delete_at(partyPosition)
        pbAddPokemon(body_pokemon)
      else
        $Trainer.party[partyPosition] = body_pokemon
        $PokemonStorage.pbStoreCaught(head_pokemon)
      end
    else
      return false
    end
  else
    storeUnfusedPokemonInPlace(partyPosition,head_pokemon,body_pokemon)
  end
  return true
end

def storeUnfusedPokemonInPlace(fusedPokemonPartyPosition, pokemonKeptInParty, pokemonSentToPC)
  $Trainer.party[fusedPokemonPartyPosition] = pokemonKeptInParty
  pbAddPokemonSilent(pokemonSentToPC)
end

def storeUnfusedPokemon(fusedPokemonPartyPosition, pokemonKeptInParty,pokemonSentToPC)
  $Trainer.party.delete_at(fusedPokemonPartyPosition)
  pbAddPokemonSilent(pokemonKeptInParty)
  pbAddPokemonSilent(pokemonSentToPC)
end

def pokemonCanBeUnfused(pokemon, scene)
  if pokemon.species_data.id_number > (NB_POKEMON * NB_POKEMON) + NB_POKEMON # triple fusion
    scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
    return false
  end

  if pokemon.egg?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end

  if pokemon.owner.name == "RENTAL"
    scene.pbDisplay(_INTL("You cannot unfuse a rental pokémon!"))
    return false
  end

  if (pokemon.foreign?($Trainer)) # && !canunfuse
    scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
    return false
  end
  return true
end