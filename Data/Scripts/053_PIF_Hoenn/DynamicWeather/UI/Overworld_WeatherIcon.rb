class WeatherIcon
  def initialize
    @icon_path = get_current_weather_icon
    return if !@icon_path || !pbResolveBitmap(@icon_path)

    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new(@icon_path)
    @sprite.x = Graphics.width - @sprite.bitmap.width - 12   # Right side of screen
    @sprite.y = -@sprite.bitmap.height                       # Start off-screen above
    @sprite.z = 99999
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def disposed?
    @sprite.nil? || @sprite.disposed?
  end

  def dispose
    @sprite&.dispose
  end

  def update
    return if disposed?
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      dispose
      return
    end

    # Slide down for 2 seconds, then slide back up
    if @frames > Graphics.frame_rate * 2
      @sprite.y -= 4
      dispose if @sprite.y + @sprite.bitmap.height < 0
    else
      @sprite.y += 4 if @sprite.y < 0
      @frames += 1
    end
  end
end

def get_current_weather_icon
  return if !$game_weather
  current_weather = $game_weather.current_weather[$game_map.map_id]
  return if !current_weather
  weather_type     = current_weather[0]
  weather_intensity = current_weather[1]
  icon = get_full_weather_icon_name(weather_type, weather_intensity)
  return nil if !icon
  return "Graphics/Pictures/Weather/" + icon
end