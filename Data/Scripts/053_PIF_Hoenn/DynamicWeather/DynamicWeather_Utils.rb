# frozen_string_literal: true


def isRaining?(map_id=$game_map.map_id)
  return isWeatherRain?(map_id) || isWeatherStorm?(map_id)
end

def isWeatherRain?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Rain
  return $game_weather.get_map_weather_type(map_id) == :Rain || $game_weather.get_map_weather_type($game_map.map_id) == :HeavyRain
end

def isWeatherSunny?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Sunny
  return $game_weather.get_map_weather_type(map_id) == :Sunny || $game_weather.get_map_weather_type(map_id) == :HarshSun
end

def isWeatherStorm?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Storm
  return $game_weather.get_map_weather_type(map_id) == :Storm
end

def isWeatherWind?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Wind
  return $game_weather.get_map_weather_type(map_id) == :Wind || $game_weather.get_map_weather_type(map_id) == :StrongWinds
end

def isWeatherFog?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Fog
  return $game_weather.get_map_weather_type(map_id) == :Fog
end

def isWeatherAsh?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Ash
  return $game_weather.get_map_weather_type(map_id) == :Ash
end

def isWeatherSnow?(map_id=$game_map.map_id)
  return true if GameData::Weather.get($game_screen.weather_type).category == :Snow
  return $game_weather.get_map_weather_type(map_id) == :Snow
end


def changeCurrentWeather(weatherType,intensity,force=false)
  new_map_id = $game_map.map_id
  mapMetadata = GameData::MapMetadata.try_get(new_map_id)
  return nil if mapMetadata.nil?
  return nil if !mapMetadata.outdoor_map && !force
  if $game_weather
    $game_weather.set_map_weather($game_map.map_id,weatherType,intensity)
    $game_weather.update_overworld_weather($game_map.map_id)
  else
    $game_screen.weather(weatherType,intensity,5)
  end
end