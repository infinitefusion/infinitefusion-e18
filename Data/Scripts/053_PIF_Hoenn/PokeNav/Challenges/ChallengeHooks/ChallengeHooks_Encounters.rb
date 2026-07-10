##
##  Hooks for challenges about encountering overworld Pokemon
##

def all_same_pokemon?(pokemon_array)
  species_array = pokemon_array.map {|pokemon| pokemon.species}
  different_species = species_array.uniq
  return different_species.length == 1
end

def all_different_pokemon?(pokemon_array)
  species_array = pokemon_array.map {|pokemon| pokemon.species}
  different_species = species_array.uniq
  return different_species.length > 1
end

def checkEncounterChallenges(encountered_pokemon)
  case encountered_pokemon.length
  when 1
  when 2
      $Trainer.complete_challenge(:encounter_2_pokemon_at_once)
      if all_different_pokemon?(encountered_pokemon)
        $Trainer.complete_challenge(:encounter_2_different_pokemon_at_once)
      elsif all_same_pokemon?(encountered_pokemon)
        $Trainer.complete_challenge(:encounter_2_same_pokemon_at_once)
      end
  when 3
    $Trainer.complete_challenge(:encounter_3_pokemon_at_once)
    if all_different_pokemon?(encountered_pokemon)
      $Trainer.complete_challenge(:encounter_3_different_pokemon_at_once)
    elsif all_same_pokemon?(encountered_pokemon)
      $Trainer.complete_challenge(:encounter_3_same_pokemon_at_once)
    end
  end
end

def checkWildFusePokemonChallenge(pokemon1,pokemon2)
  $Trainer.complete_challenge(:fuse_wild_pokemon)
  if $game_switches[SWITCH_WILD_FUSION_QUEST]
    current_nb = pbGet(VAR_NB_WILD_FUSING_SEEN)
    current_nb+=1
    pbSet(VAR_NB_WILD_FUSING_SEEN,current_nb)
    if current_nb <= 3
      pbMEPlay("Register phone")
      pbCallBub(3)
      pbMessage(_INTL("Wild Fusion Study: {1} / 3",current_nb))
    end
  end
end