# frozen_string_literal: true

class PokemonEncounters
  WEATHER_ENCOUNTER_BASE_CHANCE = 8 #/100 (for weather intensity of 0)
  alias pokemonEssentials_PokemonEncounter_choose_wild_pokemon choose_wild_pokemon
  ANIMATION_WEATHER_ENCOUNTER = 3

  def choose_wild_pokemon(enc_type, *args)
    return pokemonEssentials_PokemonEncounter_choose_wild_pokemon(enc_type, *args) if !$game_weather
    current_weather_type = $game_weather.get_map_weather_type($game_map.map_id)
    current_weather_intensity = $game_weather.get_map_weather_intensity($game_map.map_id)
    if can_substitute_for_weather_encounter(enc_type, current_weather_type)
      # Chance to replace the chosen by one in from the weather pool
      if roll_for_weather_encounter(current_weather_intensity)
        weather_encounter_type = get_weather_encounter_type(enc_type, current_weather_type)
        echoln "weather encounter!"
        $PokemonTemp.pokemon_is_weather_encounter = true
        return pokemonEssentials_PokemonEncounter_choose_wild_pokemon(weather_encounter_type) if (weather_encounter_type)
      end
    end
    return pokemonEssentials_PokemonEncounter_choose_wild_pokemon(enc_type, *args)
  end

  SUBSTITUTABLE_ENCOUNTER_TYPES = [:LandDay, :LandNight, :LandMorning, :Land, :Land1, :Land2, :Land3, :TallGrass, :Water]

  def can_substitute_for_weather_encounter(encounter_type, current_weather)
    return false if Settings::GAME_ID != :IF_HOENN
    return false if !SUBSTITUTABLE_ENCOUNTER_TYPES.include?(encounter_type)
    return false if current_weather.nil? || current_weather == :None
    return true
  end

  def get_weather_encounter_type(normal_encounter_type, current_weather_type)
    surf_encounters = [:Water, :WaterNight, :WaterMorning, :WaterDay]

    base_encounter_type = surf_encounters.include?(normal_encounter_type) ? :Water : :Land
    weather_encounter_type = "#{base_encounter_type}#{current_weather_type}".to_sym
    return weather_encounter_type if GameData::EncounterType.exists?(weather_encounter_type)
    return nil
  end

  #out of 100
  def weather_encounter_chance(weather_intensity)
    return (WEATHER_ENCOUNTER_BASE_CHANCE * weather_intensity) + WEATHER_ENCOUNTER_BASE_CHANCE
  end

  def roll_for_weather_encounter(weather_intensity)
    weather_encounter_chance = weather_encounter_chance(weather_intensity)
    return rand(100) < weather_encounter_chance
  end

end