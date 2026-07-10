# frozen_string_literal: true

Events.onMapChange+= proc { |_old_map_id|
    next if !$game_weather || !$game_weather.current_weather || !$game_weather.last_update_time
    next if !$game_map
    new_map_id = $game_map.map_id
    mapMetadata = GameData::MapMetadata.try_get(new_map_id)
    if mapMetadata.nil? || !mapMetadata.outdoor_map
        next clear_current_map_weather
    end
    update_overworld_weather($game_map.map_id)
    next if  $game_weather.last_update_time.to_i + GameWeather::TIME_BETWEEN_WEATHER_UPDATES > pbGetTimeNow.to_i
    echoln "- Updating the weather -"
    new_map_id = $game_map.map_id
    mapMetadata = GameData::MapMetadata.try_get(new_map_id)
    next if mapMetadata.nil?
    $game_screen.weather(:None,0,0) if !mapMetadata.outdoor_map
    next unless mapMetadata.outdoor_map
    $game_weather.update_weather
    $game_map.refresh
  }

def clear_current_map_weather
    $game_screen.weather(:None,0,0)
end

def update_overworld_weather(current_map)
    return if current_map.nil?
    return if !$game_weather.current_weather

    current_weather_array = $game_weather.current_weather[current_map]
    return if current_weather_array.nil?
    current_weather_type = current_weather_array[0]
    current_weather_intensity = current_weather_array[1]
    current_weather_type = :None if !current_weather_type
    current_weather_intensity=0 if !current_weather_intensity
    current_weather_type = :None if PBDayNight.isNight? && current_weather_type == :Sunny

    $game_screen.weather(current_weather_type,current_weather_intensity,0)
end