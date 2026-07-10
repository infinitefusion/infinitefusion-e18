class PokemonTemp
  attr_accessor :pokemon_is_weather_encounter
end
module PokeBattle_BattleCommon
  def checkCatchChallenge(pokeball, battle, caught_pokemon)
    #Caught in 1 try
    if battle.balls_thrown == 0 #It's incremented after this method gets checked
      $Trainer.complete_challenge(:catch_first_try)
    end

    #Catching at full health
    if caught_pokemon.hp == caught_pokemon.totalhp
      $Trainer.complete_challenge(:catch_full_health)
    end

    #Without receiving any damage
    if battle.damage_received ==0
      $Trainer.complete_challenge(:catch_no_damage)
    end

    if pokeball == :PREMIERBALL
      $Trainer.complete_challenge(:catch_premierball)
    end

    if caught_pokemon.isFusion?
      $Trainer.complete_challenge(:catch_fused)
    end

    if $PokemonBag.pbQuantity(pokeball) == 0
      $Trainer.complete_challenge(:catch_last_pokeball)
    end

    if $PokemonTemp.pokemon_is_weather_encounter
      $Trainer.complete_challenge(:catch_weather_encounter)
    end
  end
end
