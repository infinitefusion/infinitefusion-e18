# todo: make the flower disappear from the tileset somehow?
def oricorioEventPickFlower(flower_color)
  quest_progression = pbGet(VAR_ORICORIO_FLOWERS)
  if flower_color == :PINK
    if Settings::KANTO && !$game_switches[SWITCH_ORICORIO_QUEST_PINK]
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
    end
    $game_switches[SWITCH_ORICORIO_QUEST_PINK] = true
    pbMessage(_INTL("It's a flower with pink nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the pink flowers.", $Trainer.name))
  elsif flower_color == :RED && quest_progression == 1
    $game_switches[SWITCH_ORICORIO_QUEST_RED] = true
    pbMessage(_INTL("It's a flower with red nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the red flowers.", $Trainer.name))
  elsif flower_color == :BLUE && quest_progression == 2
    $game_switches[SWITCH_ORICORIO_QUEST_BLUE] = true
    pbMessage(_INTL("It's a flower with blue nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the blue flowers.", $Trainer.name))
  end
end

def hasOricorioInParty()
  return $Trainer.has_species_or_fusion?(:ORICORIO_1) || $Trainer.has_species_or_fusion?(:ORICORIO_2) || $Trainer.has_species_or_fusion?(:ORICORIO_3) || $Trainer.has_species_or_fusion?(:ORICORIO_4)
end

def changeOricorioFlower(form = 1)
  #guaranteed encounter first time you interact with a flower
  if Settings::HOENN && !$game_switches[SWITCH_FOMANTIS_GUARANTEED_FLOWER]
    pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
    pbWildBattle(:FOMANTIS, 4)
    $game_switches[SWITCH_FOMANTIS_GUARANTEED_FLOWER] = true
    return
  end


  if $PokemonGlobal.stepcount % 25 == 0
    if !hatUnlocked?(HAT_FLOWER) && rand(2) == 0
      obtainHat(HAT_FLOWER)
      $PokemonGlobal.stepcount += 1
    else
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
      $PokemonGlobal.stepcount += 1
    end
  end
  return unless hasOricorioInParty
  message = ""
  form_name = ""
  if form == 1
    message = _INTL("It's a flower with red nectar. ")
    form_name = "Baile"
  elsif form == 2
    message = _INTL("It's a flower with yellow nectar. ")
    form_name = "Pom-pom"
  elsif form == 3
    message = _INTL("It's a flower with pink nectar. ")
    form_name = "Pa'u"
  elsif form == 4
    message = _INTL("It's a flower with blue nectar. ")
    form_name = "Sensu"
  end

  message = message + _INTL("Show it to a Pokémon?")
  if pbConfirmMessage(message)
    pbChoosePokemon(1, 2,
                    proc { |poke|
                      !poke.egg? &&
                        (Kernel.isPartPokemon(poke, :ORICORIO_1) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_2) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_3) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_4))
                    })
    if (pbGet(1) != -1)
      poke = $Trainer.party[pbGet(1)]
      if changeOricorioForm(poke, form)
        pbMessage(_INTL("{1} switched to the {2} style", poke.name, form_name))
        pbSet(1, poke.name)
      else
        pbMessage(_INTL("{1} remained the same...", poke.name, form_name))
      end
    end
  end
end

def changeOricorioForm(pokemon, form = nil)
  oricorio_forms = [:ORICORIO_1, :ORICORIO_2, :ORICORIO_3, :ORICORIO_4]
  body_id = pokemon.isFusion? ? get_body_species_from_symbol(pokemon.species) : pokemon.species
  head_id = pokemon.isFusion? ? get_head_species_from_symbol(pokemon.species) : pokemon.species

  oricorio_body = oricorio_forms.include?(body_id)
  oricorio_head = oricorio_forms.include?(head_id)

  target_form = case form
                when 1 then :ORICORIO_1
                when 2 then :ORICORIO_2
                when 3 then :ORICORIO_3
                when 4 then :ORICORIO_4
                else return false
                end
  if oricorio_body && oricorio_head && body_id == target_form && head_id == target_form
    return false
  end

  if form == 1
    body_id = :ORICORIO_1 if oricorio_body
    head_id = :ORICORIO_1 if oricorio_head
  elsif form == 2
    body_id = :ORICORIO_2 if oricorio_body
    head_id = :ORICORIO_2 if oricorio_head
  elsif form == 3
    body_id = :ORICORIO_3 if oricorio_body
    head_id = :ORICORIO_3 if oricorio_head
  elsif form == 4
    body_id = :ORICORIO_4 if oricorio_body
    head_id = :ORICORIO_4 if oricorio_head
  else
    return false
  end

  head_number = getDexNumberForSpecies(head_id)
  body_number = getDexNumberForSpecies(body_id)

  newForm = pokemon.isFusion? ? getSpeciesIdForFusion(head_number, body_number) : head_id
  $Trainer.pokedex.set_seen(newForm)
  $Trainer.pokedex.set_owned(newForm)
  pokemon.pif_sprite = nil
  pokemon.species = newForm
  return true
end

# chance: out of 100
def lilypadEncounter(pokemon, minLevel, maxLevel, chance = 10)
  minLevel, maxLevel = [minLevel, maxLevel].minmax
  level = rand(minLevel..maxLevel)

  event = $game_map.events[@event_id]
  return if !event
  if rand(0..100) <= chance
    pbWildBattle(pokemon, level)
  else
    playAnimation(Settings::GRASS_ANIMATION_ID, event.x, event.y)
  end
  event.erase
end
