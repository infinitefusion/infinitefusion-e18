# frozen_string_literal: true

def printNPCTrainerCurrentTeam(trainer)
  team_string = "["
  trainer.currentTeam.each do |pokemon|
    name= get_pokemon_readable_internal_name(pokemon)
    level = pokemon.level
    formatted_info = "#{name} (lv.#{level}), "
    team_string += formatted_info
  end
  team_string += "]"
  echoln "Trainer's current team is: #{team_string}"
end

def applyTrainerRandomEvents(trainer,event_type=nil)
  if trainer.has_pending_action
    echoln "Trainer has pending action"
  end

  return trainer if trainer.has_pending_action
  trainer.clear_previous_random_events

  #time_passed = trainer.getTimeSinceLastAction
  #return trainer if time_passed < TIME_FOR_RANDOM_EVENTS
  catch_chance_for_number_in_team = [100,40,30,20,10,5,0]
  unfuse_chance_for_number_in_team = [0,10,10,5,5,0,0]
  fuse_chance_for_number_in_team = [0,0,40,60,65,75,85]

  #Odds of certain events depends on nb. of pokemon in current party
  catch_chance = catch_chance_for_number_in_team[trainer.currentTeam.length]
  unfuse_chance = unfuse_chance_for_number_in_team[trainer.currentTeam.length]
  fuse_chance = fuse_chance_for_number_in_team[trainer.currentTeam.length]

  # Chances out of 100
  weighted_events = [
    [:CATCH,   catch_chance],     #Depends on nb of pokemon in team. 40% if only 1, then DECREASES with the nb.
    [:FUSE,    fuse_chance],      #Depends on nb of pokemon in team. 40% if 2, then INCREASES with the nb.
    [:REVERSE, 10],
    [:UNFUSE,  unfuse_chance]   #Depends on nb of pokemon in team. 10% if 1 or 2, 5% if 3 or 4. .
  ]
  event_pool = weighted_events.flat_map { |event, weight| [event] * weight }
  selected_event = event_pool.sample
  selected_event = event_type if event_type
  #Random event guaranteed after 1st rematch only (can still fail if they don't have the requirements tho)
  if selected_event.nil? && trainer.nb_rematches == 1
    selected_event = event_pool.sample until selected_event
  end
  if selected_event
    echoln "Trying to do random event: #{selected_event}"
  end
  return trainer if selected_event.nil?
  original_team = trainer.currentTeam.clone

  case selected_event
  when :CATCH
    trainer = catch_new_team_pokemon(trainer)
  when :FUSE
    trainer = fuse_random_team_pokemon(trainer)
  when :UNFUSE
    trainer = unfuse_random_team_pokemon(trainer)
  when :REVERSE
    trainer = reverse_random_team_pokemon(trainer)
  end
  new_team = trainer.currentTeam
  team_changed = original_team != new_team
  trainer.set_pending_action(team_changed)
  printNPCTrainerCurrentTeam(trainer)
  return trainer
end



def chooseEncounterType(trainerClass)
  water_trainer_classes = [:SWIMMER_F, :SWIMMER_M,:SWIMMER2_M,:SWIMMER2_F, :FISHERMAN, :SURFER, :DIVER_M, :DIVER_F]
  hybrid_trainer_classes = [:COOLTRAINER_M, :COOLTRAINER_F, :TRIATHLETE_SWIM_M, :TRIATHLETE_SWIM_F,
                            :TRIATHLETE_RUN_M, :TRIATHLETE_RUN_F, :SAILOR, :TUBER_M, :TUBER_F]
  if water_trainer_classes.include?(trainerClass )
    chance_of_land_encounter = 0
    chance_of_surf_encounter= 5
    chance_of_cave_encounter = 0
    chance_of_fishing_encounter = 5
  elsif hybrid_trainer_classes.include?(trainerClass )
    chance_of_land_encounter = 5
    chance_of_surf_encounter= 2
    chance_of_cave_encounter = 5
    chance_of_fishing_encounter = 2
  else
    chance_of_land_encounter = 5
    chance_of_surf_encounter= 0
    chance_of_cave_encounter = 5
    chance_of_fishing_encounter = 0
  end
  $PokemonEncounters.has_water_encounters?
  possible_encounter_types = []
  if $PokemonEncounters.has_land_encounters?
    possible_encounter_types += [:Land] * chance_of_land_encounter
  end
  if $PokemonEncounters.has_cave_encounters?
    possible_encounter_types += [:Cave] * chance_of_cave_encounter
  end
  if $PokemonEncounters.has_water_encounters?
    possible_encounter_types += [:GoodRod] * chance_of_fishing_encounter
    possible_encounter_types += [:Water] * chance_of_surf_encounter
  end
  return getTimeBasedEncounter(possible_encounter_types.sample)
end


def getTimeBasedEncounter(encounter_type)
  time = pbGetTimeNow
  return $PokemonEncounters.find_valid_encounter_type_for_time(encounter_type, time)
end

def catch_new_team_pokemon(trainer)
  return trainer if trainer.currentTeam.length >= 6
  encounter_type = chooseEncounterType(trainer.trainerType)
  return trainer if !encounter_type

  echoln "Catching a pokemon via encounter_type #{encounter_type}"

  # 3 rolls for favorite type, then normal roll
  wild_pokemon = select_npc_new_pokemon(encounter_type, trainer.favorite_type)
  if wild_pokemon
    trainer_highest_level = get_trainer_highest_level(trainer)
    species = wild_pokemon[0]
    level = [wild_pokemon[1], trainer_highest_level].min

    original_trainer =pbLoadTrainer(trainer.trainerType,trainer.trainerName,0)
    trainer.currentTeam << Pokemon.new(species,level,original_trainer)
    trainer.log_catch_event(wild_pokemon[0])
  end
  return trainer
end

# 3 rolls for favorite type, then normal roll
def select_npc_new_pokemon(encounter_type, favorite_type)
  (1..3).each { |i|
    wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
    next unless wild_pokemon
    species = wild_pokemon[0]
    if GameData::Species.get(species)&.hasType?(favorite_type)
      return wild_pokemon
    end
  }
  return $PokemonEncounters.choose_wild_pokemon(encounter_type)
end

def get_trainer_highest_level(trainer)
  highest_level = 1
  trainer.currentTeam.each do |pokemon|
    highest_level = pokemon.level if pokemon.level > highest_level
  end
  return highest_level
end


def reverse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_reverse = eligible_pokemon.sample
  old_species = pokemon_to_reverse.species
  trainer.currentTeam.delete(pokemon_to_reverse)

  body_pokemon = get_body_species_from_symbol(pokemon_to_reverse.species)
  head_pokemon = get_head_species_from_symbol(pokemon_to_reverse.species)

  pokemon_to_reverse.species = getFusedPokemonIdFromSymbols(head_pokemon,body_pokemon)
  pokemon_to_reverse.pif_sprite=nil
  trainer.currentTeam.push(pokemon_to_reverse)
  trainer.log_reverse_event(old_species,pokemon_to_reverse.species)
  return trainer
end


def unfuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_unfuse = eligible_pokemon.sample

  return trainer if pokemon_to_unfuse.owner.name != trainer.trainerName

  body_pokemon = get_body_id_from_symbol(pokemon_to_unfuse.species)
  head_pokemon = get_head_id_from_symbol(pokemon_to_unfuse.species)

  level = calculateUnfuseLevelOldMethod(pokemon_to_unfuse,false)
  if pokemon_to_unfuse.item
    trainer.inventory << pokemon_to_unfuse.item.id
  end
  trainer.currentTeam.delete(pokemon_to_unfuse)
  original_trainer =pbLoadTrainer(trainer.trainerType,trainer.trainerName,0)
  trainer.currentTeam.push(Pokemon.new(body_pokemon,level,original_trainer))
  trainer.currentTeam.push(Pokemon.new(head_pokemon,level,original_trainer))
  trainer.log_unfusion_event(pokemon_to_unfuse.species, body_pokemon, head_pokemon)
  return trainer
end

def fuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_unfused_pokemon
  return trainer if eligible_pokemon.length < 2

  pokemon_to_fuse = eligible_pokemon.sample(2)
  body_pokemon = pokemon_to_fuse[0]
  head_pokemon = pokemon_to_fuse[1]
  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species,head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level)/2
  original_trainer =pbLoadTrainer(trainer.trainerType,trainer.trainerName,0)
  fused_pokemon = Pokemon.new(fusion_species,level,original_trainer)

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)
  trainer.log_fusion_event(body_pokemon.species,head_pokemon.species,fusion_species)
  return trainer
end

def getBestMatchingPreviousRandomEvent(trainer_data, previous_events)
  return nil if trainer_data.nil? || previous_events.nil?

  priority = [:CATCH, :EVOLVE, :FUSE, :UNFUSE, :REVERSE]
  event_message_map = {
    CATCH:   trainer_data.preRematchText_caught,
    EVOLVE:  trainer_data.preRematchText_evolved,
    FUSE:    trainer_data.preRematchText_fused,
    UNFUSE:  trainer_data.preRematchText_unfused,
    REVERSE: trainer_data.preRematchText_reversed
  }
  sorted_events = previous_events.sort_by do |event|
    priority.index(event.eventType) || Float::INFINITY
  end

  sorted_events.find { |event| event_message_map[event.eventType] }
end