class BetterRegionMap
  DEBUG_WEATHER = $DEBUG

  def update_weather_text(location)
    return unless location
    selected_map = location[4]
    weather_at_location = $game_weather.current_weather[selected_map]
    if weather_at_location.nil?
      Kernel.pbClearText
      return
    end
    weather_type = weather_at_location[0]
    weather_intensity = weather_at_location[1]

    weather_caption = get_weather_caption(weather_type,weather_intensity)
    intensity_text = get_weather_intensity_text(weather_type,weather_intensity,selected_map)

    if weather_caption && intensity_text
      Kernel.pbClearText
      Kernel.pbDisplayText(weather_caption, 400,25,9999999, pbColor(:LIGHT_TEXT_MAIN_COLOR), pbColor(:LIGHT_TEXT_SHADOW_COLOR))
      Kernel.pbDisplayText(intensity_text, 400,50,9999999,pbColor(:LIGHT_TEXT_MAIN_COLOR), pbColor(:LIGHT_TEXT_SHADOW_COLOR))
    end
    echoln selected_map
  end


    #Captions need to be enumerated like this to allow for proper translations
  def get_weather_caption(weather_type, intensity)

    case weather_type
    when :Sandstorm
        return _INTL("Sandstorm")
    when :Snow
      case intensity
      when -1..2
        return _INTL("Light Snow")
      when 3..4
        return _INTL("Heavy Snow")
      when 7..8
        return _INTL("Snowstorm")
      else # 9–10
        return _INTL("Blizzard")
      end
    when :StrongWinds
        return _INTL("Heavy Winds")
    when :HeavyRain
      return _INTL("Heavy Rain")
    when :HarshSun
        return _INTL("Drought")
    when :Sunny
      case intensity
      when -1..2
        return _INTL("Mild sunshine")
      when 3..4
        return _INTL("Warm sunshine")
      when 5..6
        return _INTL("Bright sunshine")
      when 7..8
        return _INTL("Hot sunshine")
      else # 9–10
        return _INTL("Scorching sun")
      end
    when :Rain
      case intensity
      when -1..2
        return _INTL("Light rain")
      when 3..4
        return _INTL("Moderate rain")
      when 5..6
        return _INTL("Heavy rain")
      when 7..8
        return _INTL("Severe rain")
      else # 9–10
        return _INTL("Extreme rain")
      end
    when :Fog
      case intensity
      when -1..2
        return _INTL("Thin fog")
      when 3..4
        return _INTL("Moderate fog")
      when 5..6
        return _INTL("Thick fog")
      when 7..8
        return _INTL("Dense fog")
      else # 9–10
        return _INTL("Very dense fog")
      end
    when :Wind
      case intensity
      when -1..2
        return _INTL("Light wind")
      when 3..4
        return _INTL("Moderate wind")
      when 5..6
        return _INTL("Strong wind")
      when 7..8
        return _INTL("High wind")
      else # 9–10
        return _INTL("Extreme wind")
      end
    when :Storm
      case intensity
      when -1..2
        return _INTL("Light thunderstorm")
      when 3..4
        return _INTL("Moderate thunderstorm")
      when 5..6
        return _INTL("Heavy thunderstorm")
      when 7..8
        return _INTL("Severe thunderstorm")
      else # 9–10
        return _INTL("Extreme thunderstorm")
      end
    when :Ash
      return _INTL("Volcanic Ash")
    end
  end

  def get_weather_intensity_text(weather_type, weather_intensity,map_id)
    i   = weather_intensity.clamp(1, 10)
    case weather_type
    when :Sandstorm
      value = 8 * i + 15
      return _INTL("{1} km/h", value)

    when :Snow
      value = (0.5 * i).round(1)
      return _INTL("{1} cm/h", value)

    when :StrongWinds
      value = 10 * i + 40
      return _INTL("{1} km/h", value)

    when :HeavyRain
      value = 5 * i + 5
      return _INTL("{1} mm/h", value)

    when :HarshSun
      value = 34 + (i * 1.4).round
      value -= 10 if GameWeather::COLD_MAPS.include?(map_id)
      value -= 10 if Settings::SNOW_DAY
      return _INTL("{1} °C", value)

    when :Sunny
      value = 21 + (i * 1.4).round
      value -= 10 if GameWeather::COLD_MAPS.include?(map_id)
      value -= 10 if Settings::SNOW_DAY
      return _INTL("{1} °C", value)

    when :Rain
      value = 2 * i
      return _INTL("{1} mm/h", value)

    when :Ash
      value = (0.5 * i).round(1)
      return _INTL("{1} cm/h", value)

    when :Fog
      value = 1100 - i * 100
      return _INTL("{1} m visibility", value)

    when :Wind
      value = 7 * i + 8
      return _INTL("{1} km/h", value)

    when :Storm
      value = 2 * i
      return _INTL("{1} mm/h", value)
    else
      return ""
    end
  end


  def weather_intensity_adjective(i, weather_type)
    case i
    when -1..2
      return _INTL("Mild") if weather_type == :Sunny
      return _INTL("Thin") if weather_type == :Fog
      return _INTL("Light")
    when 3..4
      return _INTL("Warm") if weather_type == :Sunny
      return _INTL("Moderate")
    when 5..6
      return _INTL("Bright") if weather_type == :Sunny
      return _INTL("Thick") if weather_type == :Fog
      return _INTL("Heavy")
    when 7..8
      return _INTL("Hot") if weather_type == :Sunny
      return _INTL("Dense") if weather_type == :Fog
      return _INTL("Severe")
    else # 9–10
      return _INTL("Scorching") if weather_type == :Sunny
      return _INTL("Very dense") if weather_type == :Fog
      return _INTL("Extreme")
    end
  end


  def draw_all_weather
    processed_locations = []
    n = 0
    for x in 0...(@window["map"].bmp.width / TileWidth)
      for y in 0...(@window["map"].bmp.height / TileHeight)

        for location in @data[2]
          if location[0] == x && location[1] == y

            map_id = location[4]

            next if !map_id
            next if processed_locations.include?(map_id)

            weather_at_location = $game_weather.current_weather[map_id]
            next if weather_at_location.nil?

            weather_type = weather_at_location[0]
            weather_intensity = weather_at_location[1]

            weather_icon = get_full_weather_icon_name(weather_type, weather_intensity)
            next if weather_icon.nil?
            weather_icon_path = "Graphics/Pictures/Weather/" + weather_icon
            @weatherIcons["weather#{n}"] = Sprite.new(@mapvp)
            @weatherIcons["weather#{n}"].bmp(weather_icon_path)
            @weatherIcons["weather#{n}"].src_rect.width = @weatherIcons["weather#{n}"].bmp.height
            @weatherIcons["weather#{n}"].x = TileWidth * x + (TileWidth / 2)
            @weatherIcons["weather#{n}"].y = TileHeight * y + (TileHeight / 2)
            @weatherIcons["weather#{n}"].oy = @weatherIcons["weather#{n}"].bmp.height / 2.0
            @weatherIcons["weather#{n}"].ox = @weatherIcons["weather#{n}"].oy

            processed_locations << map_id
            n = n + 1
          end
        end
      end
    end
  end

  def new_weather_cycle
    return if !$game_weather
    @weatherIcons.dispose
    @weatherIcons = SpriteHash.new
    $game_weather.update_weather
    draw_all_weather
  end

end

def get_current_map_weather_icon
  return if !$game_weather
  current_weather = $game_weather.current_weather[$game_map.map_id]
  return if !current_weather
  weather_type = current_weather[0]
  weather_intensity = current_weather[1]
  icon = get_full_weather_icon_name(weather_type, weather_intensity)
  return "Graphics/Pictures/Weather/" + icon if icon
  return nil
end

def get_weather_icon(weather_type, intensity)
  case weather_type
  when :Sunny #&& !PBDayNight.isNight?
    icon_name = "mapSun"
  when :Rain
    icon_name = "mapRain"
  when :Fog
    icon_name = "mapFog"
  when :Wind
    icon_name = "mapWind"
  when :Storm
    icon_name = "mapStorm"
  when :Sandstorm
    icon_name = "mapSand"
  when :Snow
    icon_name = "mapSnow"
  when :HeavyRain
    icon_name = "mapHeavyRain"
  when :StrongWinds
    icon_name = "mapStrongWinds"
  when :HarshSun
    icon_name = "mapHarshSun"
  when :Ash
    icon_name = "mapAsh"
  else
    icon_name = nil
  end
  return icon_name
end

def get_full_weather_icon_name(weather_type, intensity)
  return nil if !weather_type
  return nil if !intensity
  same_intensity_weather_types = [:Sandstorm, :Snow, :StrongWinds, :HeavyRain, :HarshSun, :Ash]

  base_weather_icon_name = get_weather_icon(weather_type, intensity)
  icon_name = base_weather_icon_name
  return nil if !icon_name
  return icon_name if same_intensity_weather_types.include?(weather_type)
  if intensity <= 2
    icon_name += "_light"
  elsif intensity <= 4
    icon_name += "_medium"
  else
    icon_name += "_heavy"
  end
  return icon_name
end

