# frozen_string_literal: true

# After each rematch, all of the trainer's Pokémon gain EXP
#
# Gained Exp is calculated from the Pokemon that is in the first slot in the player's team
# so the trainer's levels will scale with the player's.
#
# e.g. If the player uses a stronger Pokemon in the battle, the NPC will get more experience
# as a result
#
def makeRebattledTrainerTeamGainExp(trainer, playerWon = true, gained_exp = nil)
  return if !trainer
  updated_team = []

  trainer_pokemon = $Trainer.party[0]
  return if !trainer_pokemon
  for pokemon in trainer.currentTeam
    if !gained_exp # Set depending on first pokemon in party if not given a specific amount
      gained_exp = trainer_pokemon.level * trainer_pokemon.base_exp
      gained_exp /= 2 if playerWon # trainer lost so he's not getting full exp
      gained_exp /= trainer.currentTeam.length
    end
    growth_rate = pokemon.growth_rate
    new_exp = growth_rate.add_exp(pokemon.exp, gained_exp)
    pokemon.exp = new_exp
    # NPC trainers capped at level cap
    level_cap = getCurrentLevelCap
    if pokemon.level > level_cap
      pokemon.level = level_cap
    end
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  return trainer
end

def evolveRebattledTrainerPokemon(trainer)
  updated_team = []
  for pokemon in trainer.currentTeam
    evolution_species = pokemon.check_evolution_on_level_up(false)
    unless evolution_species  #Level up evolution has priority over stone evolution
      trainer.list_evolution_items.each do |evolution_item|
        evolution_species = pokemon.check_evolution_on_use_item(evolution_item)
        if evolution_species
          index = trainer.inventory.index(evolution_item)
          trainer.inventory.delete_at(index) if index
        end
      end
    end

    if evolution_species && pokemonAllowedToEvolve(pokemon, evolution_species)
      trainer.log_evolution_event(pokemon.species, evolution_species)
      trainer.set_pending_action(true)
      pokemon.species = evolution_species
      pokemon.pif_sprite = nil
    end
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  return trainer
end

def update_items(trainer)
  return unless $PokemonTemp.battle_npc_used_items
  $PokemonTemp.battle_npc_used_items.each do |item|
    if trainer.inventory.include?(item)
      index = trainer.inventory.index(item)
      trainer.inventory.delete_at(index) if index
    end
  end
  return trainer
  $PokemonTemp.battle_npc_used_items=nil
end

def pokemonAllowedToEvolve(pokemon, evolution_species=nil)
  return false if pokemon.item == :EVERSTONE
  return true
end

def healRebattledTrainerPokemon(trainer)
  for pokemon in trainer.currentTeam
    pokemon.calc_stats
    pokemon.heal
    echoln "healing #{pokemon.name}"
  end
  return trainer
end

def generateTrainerRematch(trainer, allow_double = true)
  battle_trainers = []
  battle_trainers << trainer
  partner = trainer.getLinkedTrainer
  if partner && allow_double # perma-double battles (twins, etc.)
    battle_trainers << partner
  end

  player_won = rematchable_trainer_battle(battle_trainers)
  checkTrainerRematchChallenges()
  # trainer
  updated_trainer = makeRebattledTrainerTeamGainExp(trainer, player_won)
  updated_trainer = healRebattledTrainerPokemon(updated_trainer)
  updated_trainer.set_pending_action(false)
  updated_trainer.update_items(updated_trainer)
  updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
  trainer.increase_friendship(5)
  trainer.nb_rematches +=1
  # partner
  if partner
    updated_partner_trainer = makeRebattledTrainerTeamGainExp(partner, player_won)
    updated_partner_trainer = healRebattledTrainerPokemon(updated_partner_trainer)
    updated_partner_trainer.set_pending_action(false)
    updated_partner_trainer = evolveRebattledTrainerPokemon(updated_partner_trainer)
    updateRebattledTrainerWithKey(updated_partner_trainer&.trainerKey, updated_partner_trainer)
  end

  return updated_trainer, player_won
end

def showGiftDialog(trainer=nil, event_id = nil)
  unless trainer && event_id
    event = pbMapInterpreter.get_character(0)
    map_id = $game_map.map_id if map_id.nil?
    trainer = getRebattledTrainer(event.id, map_id)
    return if trainer.nil?
  else
    event = $game_map.events[event_id]
  end
  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)
  message_text = trainer_data.preRematch_text_gift
  message_text = message_text.gsub("<PLAYER_NAME>", $Trainer.name)
  showTrainerMessage(event, trainer, message_text)
end

def showPrerematchDialog(trainer=nil, event_id = nil)
  unless trainer && event_id
    event = pbMapInterpreter.get_character(0)
    map_id = $game_map.map_id if map_id.nil?
    trainer = getRebattledTrainer(event.id, map_id)
    return "" if trainer.nil?
  else
    event = $game_map.events[event_id]
  end
  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)
  all_previous_random_events = trainer.previous_random_events

  if all_previous_random_events
    previous_random_event = getBestMatchingPreviousRandomEvent(trainer_data, trainer.previous_random_events)

    if previous_random_event
      event_message_map = {
        CATCH: trainer_data.preRematch_text_caught,
        EVOLVE: trainer_data.preRematch_text_evolved,
        FUSE: trainer_data.preRematch_text_fused,
        UNFUSE: trainer_data.preRematch_text_unfused,
        REVERSE: trainer_data.preRematch_text_reversed,
        GIFT: trainer_data.preRematch_text_gift
      }

      message_text = event_message_map[previous_random_event.eventType] || trainer_data.preRematch_text_default
    else
      message_text = trainer_data.preRematch_text_default
    end
  end
  message_text = message_text.gsub("<PLAYER_NAME>", $Trainer.name)
  if previous_random_event
    message_text = message_text.gsub("<CAUGHT_POKEMON>", getSpeciesRealName(previous_random_event.caught_pokemon).to_s)
    message_text = message_text.gsub("<UNEVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.unevolved_pokemon).to_s)
    message_text = message_text.gsub("<EVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.evolved_pokemon).to_s)
    message_text = message_text.gsub("<HEAD_POKEMON>", getSpeciesRealName(previous_random_event.fusion_head_pokemon).to_s)
    message_text = message_text.gsub("<BODY_POKEMON>", getSpeciesRealName(previous_random_event.fusion_body_pokemon).to_s)
    message_text = message_text.gsub("<FUSED_POKEMON>", getSpeciesRealName(previous_random_event.fusion_fused_pokemon).to_s)
    message_text = message_text.gsub("<UNREVERSED_POKEMON>", getSpeciesRealName(previous_random_event.unreversed_pokemon).to_s)
    message_text = message_text.gsub("<REVERSED_POKEMON>", getSpeciesRealName(previous_random_event.reversed_pokemon).to_s)
    message_text = message_text.gsub("<UNFUSED_POKEMON>", getSpeciesRealName(previous_random_event.unfused_pokemon).to_s)
  else
    message_text = trainer_data.preRematch_text_default
  end
  showTrainerMessage(event, trainer, message_text)
end

def showTrainerMessage(event, trainer, message_text)
  if message_text
    split_messages = message_text.split("<br>")
    split_messages.each do |msg|
      pbCallBub(2, event.id)
      pbCallBub(3) if isPartneredWithTrainer(trainer)
      pbMessage(msg)
    end
  end
end
