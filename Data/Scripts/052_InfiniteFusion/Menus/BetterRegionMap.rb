#==============================================================================#
#                              Better Region Map                               #
#                       Originally by Marin, with edits by Boonzeet            #
#                       Adapted for Infinite Fusion by chardub
#==============================================================================#
#   This region map is smoother and allows you to use region maps larger than  #
#                                   480x320.                                   #
#                                                                              #
#     This resource also comes with a new townmapgen.html to support for the   #
#                                larger images.                                #
#==============================================================================#
#  This region map now supports hidden islands (e.g. Berth or Faraday).        #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#
#
# PluginManager.register({
#                          :name => "Better Region Map",
#                          :version => "1.2",
#                          :credits => ["Marin", "Boonzeet"],
#                          :dependencies => "Marin's Scripting 0_Utilities",
#                          :link => "https://reliccastle.com/resources/174/"
#                        })

def pbBetterRegionMap(region = -1, show_player = true, can_fly = false, wallmap = false, species = nil, fly_anywhere = false)
  scene = BetterRegionMap.new(-1, show_player, can_fly, wallmap, species, fly_anywhere)
  return scene.flydata
end

def pbWeatherMap()
  scene = BetterRegionMap.new(-1, true, false, true, nil, false, true)
  return scene.flydata
end

class PokemonGlobalMetadata
  attr_writer :regionMapSel
  attr_writer :region

  def regionMapSel
    @regionMapSel ||= [0, 0]
    return @regionMapSel
  end

  def region
    @region ||= 0
    return @region
  end
end

class BetterRegionMap
  KANTO_DEFAULT_POS = [37, 7]
  HOENN_DEFAULT_POS = [0, 0]

  CursorAnimateDelay = 12.0
  CursorMoveSpeed = 2.0
  TileWidth = 16.0
  TileHeight = 16.0

  FlyPointAnimateDelay = 20.0

  attr_reader :flydata

  def initialize(region = -1, show_player = true, can_fly = false, wallmap = false, species = nil, fly_anywhere = false, show_weather = false)
    region = 0
    showBlk
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)

    # if map_metadata
    #   playerpos = $game_map ? map_metadata.town_map_position : nil # pbGetMetadata($game_map.map_id, MetadataMapPosition) : nil
    # end
    # if playerpos == nil
    #   playerpos = [0, 0]
    # end
    @fly_anywhere = fly_anywhere
    @region = 0 #(region < 0) ? playerpos[0] : region
    @species = species
    @show_player = show_player #(show_player && playerpos[0] == @region)
    @can_fly = can_fly
    @data = load_data("Data/town_map.dat")[@region]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @mapdata = pbLoadTownMapData
    @mapvp = Viewport.new(16, 32, 480, 320)
    @mapvp.z = 100000
    @mapoverlayvp = Viewport.new(16, 32, 480, 320)
    @mapoverlayvp.z = 100001
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 100001
    @sprites = SpriteHash.new
    @show_weather = show_weather
    @sprites["background"] = Sprite.new(@viewport)
    if wallmap
      @sprites["background"].bmp("Graphics/Pictures/map/bg_wall")
    else
      if isDarkMode
        @sprites["background"].bmp("Graphics/Pictures/Pokegear/bg_dark")
      else
        @sprites["background"].bmp("Graphics/Pictures/Pokegear/bg")
      end
    end

    @sprites["bg_frame"] = Sprite.new(@viewport)
    @sprites["bg_frame"].bmp("Graphics/Pictures/mapbg")
    @window = SpriteHash.new
    @window["map"] = Sprite.new(@mapvp)
    @weatherIcons = SpriteHash.new
    if Settings::GAME_ID == :IF_KANTO
      mapFilename = isPostgame?() ? "map_postgame" : "map"
    else
      if PBDayNight.isNight?
        mapFilename = "map_hoenn_night"
      else
        mapFilename = "map_hoenn"
      end
    end
    # @window["map"].bmp("Graphics/Pictures/#{@data[1]}")
    @window["map"].bmp("Graphics/Pictures/map/#{mapFilename}")

    # for hidden in REGION_MAP_EXTRAS
    #   if hidden[0] == @region && ((wallmap && hidden[5]) || # always show if looking at wall map, irrespective of switch
    #     (!wallmap && hidden[1] > 0 && $game_switches[hidden[1]]))
    #     if !@window["map2"]
    #       @window["map2"] = BitmapSprite.new(480,320,@mapoverlayvp)
    #     end
    #     pbDrawImagePositions(@window["map2"].bitmap, [
    #       ["Graphics/Pictures/#{hidden[4]}", hidden[2] * TileWidth, hidden[3] * TileHeight, 0, 0, -1, -1],
    #     ])
    #   end
    # end
    @window["player"] = Sprite.new(@mapoverlayvp)
    player_coordinates = getPlayerPosition
    if @show_player
      if map_metadata
        player = map_metadata.town_map_position
      end
      # if true # player && player[0] == @region  #only use 1 region
      $PokemonGlobal.regionMapSel = [0, 0]
      gender = $Trainer.gender.to_digits(3)
      # @window["player"].bmp("Graphics/Pictures/map/Player#{gender}")
      @window["player"].bmp("Graphics/Pictures/map/location_icon")
      @window["player"].x = TileWidth * player_coordinates[0] + (TileWidth / 2.0) if player_coordinates
      @window["player"].y = TileHeight * player_coordinates[1] + (TileHeight / 2.0) if player_coordinates
      @window["player"].center_origins
      # end
      # else
      #
      # end

    end
    @window["areahighlight"] = BitmapSprite.new(@window["map"].bitmap.width, @window["map"].bitmap.height, @mapoverlayvp)
    @window["areahighlight"].y = -8
    # pokedex highlights
    # if @species != nil
    #   @window["areahighlight"].bitmap.clear
    #   # Fill the array "points" with all squares of the region map in which the
    #   # species can be found
    #
    #   mapwidth = @window["map"].bitmap.width / BetterRegionMap::TileWidth
    #   data = calculatePointsAndCenter(mapwidth)
    #
    #   points = data[0]
    #   minxy = data[1]
    #   maxxy = data[2]
    #
    #   # Draw coloured squares on each square of the region map with a nest
    #   pointcolor = Color.new(0, 248, 248)
    #   pointcolorhl = Color.new(192, 248, 248)
    #
    #   sqwidth = TileWidth.round
    #   sqheight = TileHeight.round
    #
    #   for j in 0...points.length
    #     if points[j]
    #       x = (j % mapwidth) * sqwidth
    #       y = (j / mapwidth) * sqheight
    #       @window["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
    #       if j - mapwidth < 0 || !points[j - mapwidth]
    #         @window["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
    #       end
    #       if j + mapwidth >= points.length || !points[j + mapwidth]
    #         @window["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
    #       end
    #       if j % mapwidth == 0 || !points[j - 1]
    #         @window["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
    #       end
    #       if (j + 1) % mapwidth == 0 || !points[j + 1]
    #         @window["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
    #       end
    #     end
    #   end
    # end

    @sprites["cursor"] = Sprite.new(@viewport2)
    @sprites["cursor"].bmp("Graphics/Pictures/mapCursor")
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height

    @sprites["weather"] = Sprite.new(@viewport2)
    @sprites["weather"].bmp(get_current_map_weather_icon)

    @sprites["weather"].x = 446
    @sprites["weather"].y = 34
    @sprites["weather"].z = 5000

    if !$PokemonGlobal.regionMapSel
      $PokemonGlobal.regionMapSel = [0, 0]
    end
    # if @species != nil && minxy[0] != nil && maxxy[1] != nil
    #   $PokemonGlobal.regionMapSel[0] = ((minxy[0] + maxxy[0]) / 2).round
    #   $PokemonGlobal.regionMapSel[1] = ((minxy[1] + maxxy[1]) / 2).round
    # end

    @sprites["cursor"].z = 11

    @sprites["cursor"].ox = (@sprites["cursor"].bmp.height - TileWidth) / 2.0
    @sprites["cursor"].oy = @sprites["cursor"].ox
    @sprites["txt"] = TextSprite.new(@viewport)
    @sprites["arrowLeft"] = Sprite.new(@viewport2)
    @sprites["arrowLeft"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowLeft"].mirror = true
    @sprites["arrowLeft"].center_origins
    @sprites["arrowLeft"].xyz = 12, Graphics.height / 2
    @sprites["arrowRight"] = Sprite.new(@viewport2)
    @sprites["arrowRight"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowRight"].center_origins
    @sprites["arrowRight"].xyz = Graphics.width - 12, Graphics.height / 2
    @sprites["arrowUp"] = Sprite.new(@viewport2)
    @sprites["arrowUp"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowUp"].angle = 180
    @sprites["arrowUp"].center_origins
    @sprites["arrowUp"].xyz = Graphics.width / 2, 24
    @sprites["arrowDown"] = Sprite.new(@viewport2)
    @sprites["arrowDown"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowDown"].center_origins
    @sprites["arrowDown"].xyz = Graphics.width / 2, Graphics.height - 24
    after_init_graphics
    update_text
    @dirs = []
    @mdirs = []
    @i = 0

    add_map_icons
    initial_position = player_coordinates
    initial_position = [0,0] unless initial_position
    init_cursor_position(initial_position[0], initial_position[1])
    center_window()

    hideBlk { update(false) }
    main
  end

  def after_init_graphics

  end

  def on_hover(x, y)
  end

  def on_click(x, y)
  end

  def on_start_moving
  end

  def on_stop_moving
    return unless @can_fly
    return if @snapping
    x = $PokemonGlobal.regionMapSel[0]
    y = $PokemonGlobal.regionMapSel[1]
    nearby_fly_spot = findNearbyHealingSpot(x, y,2)
    if nearby_fly_spot
      @snapping = true
      new_x, new_y = nearby_fly_spot
      if [new_x, new_y] != @position_before_moving
        snap_to_position(new_x, new_y)
        update_text
        on_hover(new_x, new_y)
      end
      @snapping = false
    end
  end

  #Fly icons, or whatever else in override
  def add_map_icons
    if @can_fly
      @spots = {}
      n = 0
      for x in 0...(@window["map"].bmp.width / TileWidth)
        for y in 0...(@window["map"].bmp.height / TileHeight)
          healspot = pbGetHealingSpot(x, y)
          echoln healspot if healspot
          if can_fly_to_location(healspot)
            add_fly_location(healspot, [x, y], n)
            n += 1
          end
        end
      end
      if $Trainer.secretBase
        secretGameBaseMapId = $Trainer.secretBase.outside_map_id
        secretBaseCoordinates = $Trainer.secretBase.outside_entrance_position
        secret_base_town_map_coordinates = getTownMapFlyCoordinates(secretGameBaseMapId)
        secret_base_town_map_coordinates = [1, 1] if !secret_base_town_map_coordinates || secret_base_town_map_coordinates.empty?
        healspot = [secretGameBaseMapId, secretBaseCoordinates[0], secretBaseCoordinates[1]]
        add_fly_location(healspot, secret_base_town_map_coordinates, "secretBase_")
      end
    end

    draw_all_weather if @show_weather && $game_weather
  end


  def getPlayerPosition
    all_maps = @mapdata[0][2]
    return [0, 0] unless all_maps

    position = find_position_for_map(all_maps, $game_map.map_id)
    return position if position
    #If didn't find current map
    last_map_id = $Trainer.last_visited_town_map_location
    if last_map_id
      position = find_position_for_map(all_maps, last_map_id)
      return position if position
    end
    return [0, 0]
  end




  def add_fly_location(healspot, position, n)
    if n.to_s.include?("secretBase")
      icon_path ="Graphics/Pictures/map/mapFly_base"
    else
      icon_path ="Graphics/Pictures/map/mapFly"
    end
    add_map_icon_at_position(n,position,icon_path)
    @spots[position] = healspot
  end


  def add_map_icon_at_position(id, position, icon_path)
    @window["point#{id}"] = Sprite.new(@mapvp)
    @window["point#{id}"].bmp(icon_path)
    @window["point#{id}"].src_rect.width = @window["point#{id}"].bmp.height
    @window["point#{id}"].x = TileWidth * position[0] + (TileWidth / 2)
    @window["point#{id}"].y = TileHeight * position[1] + (TileHeight / 2)
    @window["point#{id}"].oy = @window["point#{id}"].bmp.height / 2.0
    @window["point#{id}"].ox = @window["point#{id}"].oy
  end

  def calculate_initial_position(player)
    if player
      x_pos = player[1] if player[1]
      y_pos = player[2] if player[2]
      return [x_pos, y_pos]
    end

    return Settings::GAME_ID == :IF_KANTO ? KANTO_DEFAULT_POS : HOENN_DEFAULT_POS
  end

  def findNearbyHealingSpot(current_x, current_y, range = 5)
    closest_spot = nil
    min_distance = Float::INFINITY

    for new_x in current_x - range..current_x + range
      for new_y in current_y - range..current_y + range
        if can_fly_to_location(pbGetHealingSpot(new_x, new_y))
          distance = Math.sqrt((new_x - current_x) ** 2 + (new_y - current_y) ** 2)
          if distance < min_distance && !(new_x == current_x && new_y == current_y)
            min_distance = distance
            closest_spot = [new_x, new_y]
          end
        end
      end
    end

    echoln "Closest spot: #{closest_spot.inspect}" if closest_spot
    return closest_spot
  end

  def synchronize_cursor
    # Sync logical position to visual cursor position
    x = (($sprites["cursor"].x - 16) / TileWidth).round
    y = (($sprites["cursor"].y - 32) / TileHeight).round

    $PokemonGlobal.regionMapSel[0] = x
    $PokemonGlobal.regionMapSel[1] = y

    # Ensure the window is in the correct position
    visual_cursor_x = 16 + TileWidth * x
    visual_cursor_y = 32 + TileHeight * y
    @sprites["cursor"].x = visual_cursor_x + @window.x
    @sprites["cursor"].y = visual_cursor_y + @window.y
  end

  def move_cursor_to(x, y)
    # Update the logical position
    $PokemonGlobal.regionMapSel[0] = x
    $PokemonGlobal.regionMapSel[1] = y

    # Calculate the visual position of the cursor based on the logical position
    visual_cursor_x = 16 + TileWidth * x
    visual_cursor_y = 32 + TileHeight * y

    # Ensure the map window scrolls to keep the cursor centered when needed
    # Calculate bounds for the map window
    window_min_x = -1 * (@window["map"].bmp.width - Settings::SCREEN_WIDTH)
    window_min_x = 0 if window_min_x > 0
    window_min_y = -1 * (@window["map"].bmp.height - Settings::SCREEN_HEIGHT)
    window_min_y = 0 if window_min_y > 0

    # Adjust the map window X-axis to center the cursor
    if visual_cursor_x < 16 # Too far left
      @window.x = [@window.x + (16 - visual_cursor_x), 0].min
    elsif visual_cursor_x > Settings::SCREEN_WIDTH - 16 # Too far right
      @window.x = [@window.x - (visual_cursor_x - (Settings::SCREEN_WIDTH - 16)), window_min_x].max
    end

    # Adjust the map window Y-axis to center the cursor
    if visual_cursor_y < 32 # Too far up
      @window.y = [@window.y + (32 - visual_cursor_y), 0].min
    elsif visual_cursor_y > Settings::SCREEN_HEIGHT - 32 # Too far down
      @window.y = [@window.y - (visual_cursor_y - (Settings::SCREEN_HEIGHT - 32)), window_min_y].max
    end

    # After adjusting the window, re-calculate the cursor position
    # Ensure it's visually accurate relative to the adjusted map window
    @sprites["cursor"].x = visual_cursor_x + @window.x
    @sprites["cursor"].y = visual_cursor_y + @window.y
    adjust_window_if_not_visited_regions
  end

  def init_cursor_position(x, y)
    $PokemonGlobal.regionMapSel[0] = x
    $PokemonGlobal.regionMapSel[1] = y

    @sprites["cursor"].x = 16 + TileWidth * $PokemonGlobal.regionMapSel[0]
    @sprites["cursor"].y = 32 + TileHeight * $PokemonGlobal.regionMapSel[1]
    # @sprites["cursor"].x = x + TileWidth * $PokemonGlobal.regionMapSel[0]
    # @sprites["cursor"].y = y + TileHeight * $PokemonGlobal.regionMapSel[1]
    #
    # @window["player"].x = TileWidth * player[1] + (TileWidth / 2.0)
    # @window["player"].y = TileHeight * player[2] + (TileHeight / 2.0)
  end

  def been_to_johto()
    first_visited_map = 248 # goldenrod train station
    return $PokemonGlobal.visitedMaps[first_visited_map]
  end

  def been_to_sevii()
    offshore_road_map = 762 # offshore road
    knot_island_map = 526
    return $PokemonGlobal.visitedMaps[offshore_road_map] || $PokemonGlobal.visitedMaps[knot_island_map]
  end

  def center_window()
    # Center the window on the cursor
    windowminx = -1 * (@window["map"].bmp.width - Settings::SCREEN_WIDTH)
    windowminx = 0 if windowminx > 0
    windowminy = -1 * (@window["map"].bmp.height - Settings::SCREEN_HEIGHT)
    windowminy = 0 if windowminy > 0

    if @sprites["cursor"].x > (Settings::SCREEN_WIDTH / 2)
      @window.x = (Settings::SCREEN_WIDTH / 2) - @sprites["cursor"].x
      if (@window.x < windowminx)
        @window.x = windowminx
      end
      @sprites["cursor"].x += @window.x
    end
    if @sprites["cursor"].y > (Settings::SCREEN_HEIGHT / 2)
      @window.y = (Settings::SCREEN_HEIGHT / 2) - @sprites["cursor"].y
      if @window.y < windowminy
        @window.y = windowminy
      end
      @sprites["cursor"].y += @window.y
    end
    adjust_window_if_not_visited_regions()
  end

  def adjust_window_if_not_visited_regions()
    if Settings::GAME_ID == :IF_KANTO
      if !been_to_johto()
        baseline = -352
        if @window.x >= baseline
          old_window_x = @window.x
          @window.x = baseline
          difference = baseline - old_window_x
          @sprites["cursor"].x += difference
        end
      end

      if !been_to_sevii()
        baseline = 0
        if @window.y < baseline
          old_window_y = @window.y
          @window.y = baseline
          difference = baseline - old_window_y
          @sprites["cursor"].y += difference
        end
      end
    else
      return
    end

  end

  def can_fly_to_location(healspot)
    return true if healspot && @fly_anywhere
    return healspot && $PokemonGlobal.visitedMaps[healspot[0]]
  end

  def getTownMapFlyCoordinates(map_id)
    return nil if !@data[2]
    for location_data in @data[2]
      map_x = location_data[0]
      map_y = location_data[1]
      location_map_id = location_data[4]
      return [map_x, map_y] if location_map_id == map_id
    end
    return nil
  end


  # Returns an array like [mapId,x,y]
  # data[2] is an array of arrays containing the lines in townmap.txt
  # ex:
  #    [[5, 13, "Littleroot Town", "Professor Birch's lab", 9, 16, 26, nil], [...]]
  # [x_on_map,y_on_map, "display name" , "point of interest", map_id, fly_x, fly_y, switch]
  def pbGetHealingSpot(x, y)
    return nil if !@data[2]
    for loc in @data[2]
      if loc[0] == x && loc[1] == y
        if !loc[4] || !loc[5] || !loc[6]
          return nil
        else
          return [loc[4], loc[5], loc[6]]
        end
      end
    end
    return nil
  end

  def main
    frame = 0
    loop do
      was_moving = moving?
      update
      if Input.press?(Input::RIGHT) && ![DIRECTION_LEFT, DIRECTION_RIGHT].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x < 480
          $PokemonGlobal.regionMapSel[0] += 1
          @sx = @sprites["cursor"].x
          @dirs << DIRECTION_RIGHT
        elsif @window.x > -1 * (@window["map"].bmp.width - 480)
          $PokemonGlobal.regionMapSel[0] += 1
          @mx = @window.x
          @mdirs << DIRECTION_RIGHT
        end
      end
      if Input.press?(Input::LEFT) && ![DIRECTION_LEFT, DIRECTION_RIGHT].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x > 16
          $PokemonGlobal.regionMapSel[0] -= 1
          @sx = @sprites["cursor"].x
          @dirs << DIRECTION_LEFT
        elsif @window.x < 0 && been_to_johto()
          $PokemonGlobal.regionMapSel[0] -= 1
          @mx = @window.x
          @mdirs << DIRECTION_LEFT
        end
      end
      if Input.press?(Input::DOWN) && ![DIRECTION_DOWN, DIRECTION_UP].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y <= 320
          $PokemonGlobal.regionMapSel[1] += 1
          @sy = @sprites["cursor"].y
          @dirs << DIRECTION_DOWN
        elsif @window.y > -1 * (@window["map"].bmp.height - 320) && been_to_sevii()
          $PokemonGlobal.regionMapSel[1] += 1
          @my = @window.y
          @mdirs << DIRECTION_DOWN
        end
      end
      if Input.press?(Input::UP) && ![DIRECTION_DOWN, DIRECTION_UP].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y > 32
          $PokemonGlobal.regionMapSel[1] -= 1
          @sy = @sprites["cursor"].y
          @dirs << DIRECTION_UP
        elsif @window.y < 0
          $PokemonGlobal.regionMapSel[1] -= 1
          @my = @window.y
          @mdirs << DIRECTION_UP
        end
      end
      if Input.repeat?(Input::X)
        print_current_position()
        new_weather_cycle if DEBUG_WEATHER && frame % 12 == 0
        frame += 1
      end

      if Input.trigger?(Input::C) && @dirs.empty?
        x, y = $PokemonGlobal.regionMapSel
        if @spots && @spots[[x, y]]
          @flydata = @spots[[x, y]]
          on_click(x, y)
          break if should_exit_confirm?
        else
          stickToPositions = findNearbyHealingSpot(x, y)  #snap in place
          if stickToPositions
            snap_to_position(stickToPositions[0], stickToPositions[1])
            update_text
            # synchronize_cursor  # Force sync
          end
        end
      end
      if !was_moving && moving?
        on_start_moving
      end
      if was_moving && !moving?
        on_stop_moving
        @position_before_moving =[$PokemonGlobal.regionMapSel[0],$PokemonGlobal.regionMapSel[1]]
      end
      break if should_exit_cancel?
    end
    on_exit_main
    dispose
  end

  def snap_to_position(x, y)
    return unless @sprites["cursor"]
    @dirs.clear
    @mdirs.clear
    @hor_count = 0
    @ver_count = 0
    @sy = @sprites["cursor"].y
    @sx = @sprites["cursor"].x
    @my = @window.y
    @mx = @window.x
    move_cursor_to(x, y)
  end

  def should_exit_confirm?
    return true
  end

  def should_exit_cancel?
    return Input.trigger?(Input::B)
  end
  def on_update
    #implemented in child classes
  end

  def on_exit_main
    #implemented in child classes
  end

  def moving?
    !@dirs.empty? || !@mdirs.empty?
  end

  def update(update_gfx = true)
    return if @sprites.disposed?
    on_update
    @sprites["arrowLeft"]&.visible = @window.x < 0 && been_to_johto()
    @sprites["arrowRight"]&.visible = @window.x > -1 * (@window["map"].bmp.width - 480)
    @sprites["arrowUp"]&.visible = @window.y < 0
    @sprites["arrowDown"]&.visible = @window.y > -1 * (@window["map"].bmp.height - 320) && been_to_sevii()

    if update_gfx
      Graphics.update
      Input.update
    end

    intensity = (Graphics.frame_count % 40) * 12
    intensity = 480 - intensity if intensity > 240
    @window["areahighlight"]&.opacity = intensity

    @i += 1
    if @i % CursorAnimateDelay == 0
      @sprites["cursor"].src_rect.x += @sprites["cursor"].src_rect.width
      @sprites["cursor"].src_rect.x = 0 if @sprites["cursor"].src_rect.x >= @sprites["cursor"].bmp.width
    end
    if @i % FlyPointAnimateDelay == 0
      @window.keys.each do |e|
        next unless e.to_s.start_with?("point")
        @window[e].src_rect.x += @window[e].src_rect.width
        @window[e].src_rect.x = 0 if @window[e].src_rect.x >= @window[e].bmp.width
      end
    end

    if @i % 2 == 0
      case @i % 32
      when 0...8
        @sprites["arrowLeft"]&.x -= 1
        @sprites["arrowRight"]&.x += 1
        @sprites["arrowUp"]&.y -= 1
        @sprites["arrowDown"]&.y += 1
      when 8...24
        @sprites["arrowLeft"]&.x += 1
        @sprites["arrowRight"]&.x -= 1
        @sprites["arrowUp"]&.y += 1
        @sprites["arrowDown"]&.y -= 1
      when 24...32
        @sprites["arrowLeft"]&.x -= 1
        @sprites["arrowRight"]&.x += 1
        @sprites["arrowUp"]&.y -= 1
        @sprites["arrowDown"]&.y += 1
      end
    end
    # Cursor movement
    if @dirs.include?(DIRECTION_RIGHT)
      move_cursor(DIRECTION_RIGHT)
    end
    if @dirs.include?(DIRECTION_LEFT)
      move_cursor(DIRECTION_LEFT)
    end
    if @dirs.include?(DIRECTION_UP)
      move_cursor(DIRECTION_UP)
    end
    if @dirs.include?(DIRECTION_DOWN)
      move_cursor(DIRECTION_DOWN)
    end

    # Map movement
    if @mdirs.include?(DIRECTION_RIGHT)
      move_map(DIRECTION_RIGHT)
    end
    if @mdirs.include?(DIRECTION_LEFT)
      move_map(DIRECTION_LEFT)
    end
    if @mdirs.include?(DIRECTION_UP)
      move_map(DIRECTION_UP)
    end
    if @mdirs.include?(DIRECTION_DOWN)
      move_map(DIRECTION_DOWN)
    end

    if @hor_count == (CursorMoveSpeed / 2.0).round || @ver_count == (CursorMoveSpeed / 2.0).round
      current_x = $PokemonGlobal.regionMapSel[0]
      current_y = $PokemonGlobal.regionMapSel[1]
      location = find_location_at_position(current_x,current_y)
      update_text_at_location(location)
      on_hover(current_x,current_y)
    end
  end

  def get_directions_offsets(direction)
    case direction
    when DIRECTION_RIGHT
      return [1,0]
    when DIRECTION_LEFT
      return [-1,0]
    end
  end

  def move_cursor(dir)
    case dir
    when DIRECTION_RIGHT, DIRECTION_LEFT
      @hor_count ||= 0
      @hor_count += 1
      @sprites["cursor"].x = @sx + (dir == DIRECTION_RIGHT ? 1 : -1) * (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(dir)
        @hor_count = nil
        @sx = nil
      end
    when DIRECTION_UP, DIRECTION_DOWN
      @ver_count ||= 0
      @ver_count += 1
      @sprites["cursor"].y = @sy + (dir == DIRECTION_DOWN ? 1 : -1) * (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(dir)
        @ver_count = nil
        @sy = nil
      end
    end
  end

  def move_map(dir)
    case dir
    when DIRECTION_RIGHT, DIRECTION_LEFT
      @hor_count ||= 0
      @hor_count += 1
      @window.x = @mx + (dir == DIRECTION_LEFT ? 1 : -1) * (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(dir)
        @hor_count = nil
        @mx = nil
      end
    when DIRECTION_UP, DIRECTION_DOWN
      @ver_count ||= 0
      @ver_count += 1
      @window.y = @my + (dir == DIRECTION_UP ? 1 : -1) * (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(dir)
        @ver_count = nil
        @my = nil
      end
    end
  end

  def find_location_at_position(x,y)
    location = @data[2].find do |e|
      e[0] == x &&
        e[1] == y
    end
    return location
  end
  def get_current_location_name
    location = @data[2].find do |e|
      e[0] == $PokemonGlobal.regionMapSel[0] &&
        e[1] == $PokemonGlobal.regionMapSel[1]
    end
    name = _INTL("Unknown Location")
    name = pbGetMessageFromHash(MessageTypes::PlaceNames, location[2]) if location
    return name
  end
  def print_current_position()
    echoln _INTL("({1}, {2})", $PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1])
  end


  def update_text
    x = $PokemonGlobal.regionMapSel[0]
    y = $PokemonGlobal.regionMapSel[1]
    location = find_location_at_position(x,y)
    update_text_at_location(location)
  end
  def update_text_at_location(location)
    text = ""
    text = pbGetMessageFromHash(MessageTypes::PlaceNames, location[2]) if location
    poi = ""
    poi = pbGetMessageFromHash(MessageTypes::PlaceDescriptions, location[3]) if location && location[3]

    update_weather_text(location) if @show_weather && $game_weather
    if $Trainer.secretBase
      secretGameBaseMapId = $Trainer.secretBase.outside_map_id
      secret_base_town_map_coordinates = getTownMapFlyCoordinates(secretGameBaseMapId)
      if location && secret_base_town_map_coordinates
        if secret_base_town_map_coordinates[0] == location[0] && secret_base_town_map_coordinates[1] == location[1]
          poi = _INTL("Secret Base")
        end
      end
    end
    @sprites["txt"].draw([
                           [pbGetMessage(MessageTypes::RegionNames, @region), 16, 0, 0,
                            Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [text, 16, 354, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [poi, 496, 354, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                         ], true)
    #on_hover($PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]) if location
  end

  def dispose
    Kernel.pbClearText
    showBlk { update(false) }
    @sprites.dispose
    @window.dispose
    @viewport.dispose
    @viewport2.dispose
    @mapvp.dispose
    hideBlk
    Input.update
  end
end

#==============================================================================#
# Overwrites some old methods to use the new region map                        #
#==============================================================================#

ItemHandlers::UseInField.add(:TOWNMAP, proc { |item|
  pbBetterRegionMap
  next 1
})

def pbShowMap(region = -1, wallmap = true)
  # pokegear
  pbBetterRegionMap(region, true, false, wallmap)
end

def find_position_for_map(all_maps, target_map_id)
  all_maps.each do |map_data|
    map_id = map_data[4]
    next unless map_id == target_map_id
    x = map_data[0]
    y = map_data[1]
    return [x, y]
  end

  return nil
end

def calculatePointsAndCenter(mapwidth)
  # Fill the array "points" with all squares of the region map in which the
  # species can be found
  points = []

  encdata = pbLoadEncountersData

  minxy = [nil, nil] # top-leftmost tile
  maxxy = [nil, nil] # bottom-rightmost tile

  for enc in encdata.keys
    enctypes = encdata[enc][1]
    if pbFindEncounter(enctypes, @species)
      mappos = GameData::MapMetadata.get(enc).town_map_position

      if true # mappos && mappos[0] == @region  #only use 1 region heheh
        showpoint = true
        for loc in @mapdata[@region][2]
          showpoint = false if loc[0] == mappos[1] && loc[1] == mappos[2] &&
            loc[7] && !$game_switches[loc[7]]
        end
        if showpoint
          # mapsize = pbGetMetadata(enc, MetadataMapSize)
          mapsize = GameData::MapMetadata.get(enc).town_map_size

          if mapsize && mapsize[0] && mapsize[0] > 0
            sqwidth = mapsize[0]
            sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
            for i in 0...sqwidth
              for j in 0...sqheight
                if mapsize[1][i + j * sqwidth, 1].to_i > 0
                  # work out the upper-leftmost and lower-rightmost tiles
                  minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1] + i) ? mappos[1] + i : minxy[0]
                  minxy[1] = (minxy[1] == nil || minxy[1] > mappos[2] + j) ? mappos[2] + j : minxy[1]
                  maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1] + i) ? mappos[1] + i : maxxy[0]
                  maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2] + j) ? mappos[2] + j : maxxy[1]
                  points[mappos[1] + i + (mappos[2] + j) * mapwidth] = true
                end
              end
            end
          else
            # work out the upper-leftmost and lower-rightmost tiles
            minxy[0] = (minxy[0] == nil || minxy[0] > mappos[1]) ? mappos[1] : minxy[0]
            minxy[1] = minxy[1] == nil || minxy[1] > mappos[2] ? mappos[2] : minxy[1]
            maxxy[0] = (maxxy[0] == nil || maxxy[0] < mappos[1]) ? mappos[1] : maxxy[0]
            maxxy[1] = (maxxy[1] == nil || maxxy[1] < mappos[2]) ? mappos[2] : maxxy[1]
            points[mappos[1] + mappos[2] * mapwidth] = true
          end
        end
      end
    end
  end
  return [points, minxy, maxxy]
end

class PokemonReadyMenu
  def pbStartReadyMenu(moves, items)
    commands = [[], []] # Moves, items
    for i in moves
      commands[0].push([i[0], GameData::Move.get(i[0]).name, true, i[1]])
    end
    commands[0].sort! { |a, b| a[1] <=> b[1] }
    for i in items
      commands[1].push([i, GameData::Item.get(i).name, false])
    end
    commands[1].sort! do |a, b|
      # Force :POKENAV to always come first
      if a[0] == :POKENAV
        -1
      elsif b[0] == :POKENAV
        1
      else
        a[1] <=> b[1]  # Alphabetical otherwise
      end
    end

    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      break if command == -1
      if command[0] == 0 # Use a move
        move = commands[0][command[1]][0]
        user = $Trainer.party[commands[0][command[1]][3]]
        if move == :FLY || move == :TELEPORT
          ###############################################
          pbHideMenu
          ret = pbBetterRegionMap(-1, true, true)
          pbShowMenu unless ret
          ###############################################
          if ret
            $PokemonTemp.flydata = ret
            $game_temp.in_menu = false
            Kernel.pbUseHiddenMove(user, move)
            break
          end
        else
          pbHideMenu
          if pbConfirmUseHiddenMove(user, move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user, move)
            break
          else
            pbShowMenu
          end
        end
      else
        # Use an item
        item = commands[1][command[1]][0]
        pbHideMenu

        if item == :POKENAV
          pbPlayDecisionSE
          pbFadeOutIn {
            @scene.pbHideMenu
            scene = PokemonPokegear_Scene.new
            screen = PokemonPokegearScreen.new(scene)
            screen.pbStartScreen
          }
          break
        end

        if ItemHandlers.triggerConfirmUseInField(item)
          $game_temp.in_menu = false
          break if pbUseKeyItemInField(item)
          $game_temp.in_menu = true
        end
      end
      pbShowMenu
    end
    @scene.pbEndScene
  end
end

#
# class PokemonPokedexInfo_Scene
#   def drawPageArea
#     @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_area")
#     overlay = @sprites["overlay"].bitmap
#     base   = Color.new(88,88,80)
#     shadow = Color.new(168,184,184)
#     @sprites["areahighlight"].bitmap.clear
#
#     mapwidth = @sprites["areamap"].bitmap.width/BetterRegionMap::TileWidth
#     data = calculatePointsAndCenter(mapwidth)
#
#     points = data[0]
#     minxy = data[1]
#     maxxy = data[2]
#
#     # Draw coloured squares on each square of the region map with a nest
#     pointcolor   = Color.new(0,248,248)
#     pointcolorhl = Color.new(192,248,248)
#     sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
#     sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
#
#
#     # Center the window on the center of visible areas
#     if minxy[0] != nil && maxxy[0] != nil
#       center_x = ((minxy[0]+maxxy[0])/2).round * sqwidth
#       center_y = ((minxy[1]+maxxy[1])/2).round * sqheight - 40
#     else
#       center_x = Settings::SCREEN_WIDTH/2
#       center_y = Settings::SCREEN_HEIGHT/2 - 40
#     end
#
#     windowminx = -1 * (@sprites["areamap"].bmp.width - Settings::SCREEN_WIDTH + 16)
#     windowminy = -1 * (@sprites["areamap"].bmp.height - Settings::SCREEN_HEIGHT + 16)
#
#     if center_x > (Settings::SCREEN_WIDTH / 2)
#       @sprites["areamap"].x = (480 / 2 ) - center_x
#       if (@sprites["areamap"].x < windowminx)
#         @sprites["areamap"].x = windowminx
#       end
#     else
#       @sprites["areamap"].x = windowminx
#     end
#     if center_y > (Settings::SCREEN_HEIGHT / 2)
#       @sprites["areamap"].y = (320 / 2 ) - center_y
#       if @sprites["areamap"].y < windowminy
#         @sprites["areamap"].y = windowminy
#       end
#     else
#       @sprites["areamap"].y = windowminy
#     end
#
#     for j in 0...points.length
#       if points[j]
#         x = (j%mapwidth)*sqwidth
#         x += @sprites["areamap"].x
#         y = (j/mapwidth)*sqheight
#         y += @sprites["areamap"].y - 8
#         @sprites["areahighlight"].bitmap.fill_rect(x,y,sqwidth,sqheight,pointcolor)
#         if j-mapwidth<0 || !points[j-mapwidth]
#           @sprites["areahighlight"].bitmap.fill_rect(x,y-2,sqwidth,2,pointcolorhl)
#         end
#         if j+mapwidth>=points.length || !points[j+mapwidth]
#           @sprites["areahighlight"].bitmap.fill_rect(x,y+sqheight,sqwidth,2,pointcolorhl)
#         end
#         if j%mapwidth==0 || !points[j-1]
#           @sprites["areahighlight"].bitmap.fill_rect(x-2,y,2,sqheight,pointcolorhl)
#         end
#         if (j+1)%mapwidth==0 || !points[j+1]
#           @sprites["areahighlight"].bitmap.fill_rect(x+sqwidth,y,2,sqheight,pointcolorhl)
#         end
#       end
#     end
#
#     # Set the text
#     textpos = []
#     if points.length==0
#       pbDrawImagePositions(overlay,[
#         [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"),108,188]
#       ])
#       textpos.push(["Area unknown"),Graphics.width/2,Graphics.height/2,2,base,shadow]
#     end
#     textpos.push([pbGetMessage(MessageTypes::RegionNames,@region),414,44,2,base,shadow])
#     textpos.push(["{1}'s area",PBSpecies.getName(@species),
#                   Graphics.width/2,352,2,base,shadow])
#
#     textpos.push(["Full view"),Graphics.width/2,306,2,base,shadow]
#     pbDrawTextPositions(overlay,textpos)
#   end
# end
#
# class PokemonPokedexInfo_Scene
#   def pbScene
#     pbPlayCrySpecies(@species,@form)
#     loop do
#       Graphics.update
#       Input.update
#       pbUpdate
#       dorefresh = false
#       if Input.trigger?(Input::A)
#         pbSEStop
#         pbPlayCrySpecies(@species,@form) if @page==1
#       elsif Input.trigger?(Input::B)
#         pbPlayCloseMenuSE
#         break
#       elsif Input.trigger?(Input::C)
#         if @page==2   # Area
#           pbBetterRegionMap(@region,false,false,false,@species)
#         elsif @page==3   # Forms
#           if @available.length>1
#             pbPlayDecisionSE
#             pbChooseForm
#             dorefresh = true
#           end
#         end
#       elsif Input.trigger?(Input::UP)
#         oldindex = @index
#         pbGoToPrevious
#         if @index!=oldindex
#           pbUpdateDummyPokemon
#           @available = pbGetAvailableForms
#           pbSEStop
#           (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::DOWN)
#         oldindex = @index
#         pbGoToNext
#         if @index!=oldindex
#           pbUpdateDummyPokemon
#           @available = pbGetAvailableForms
#           pbSEStop
#           (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::LEFT)
#         oldpage = @page
#         @page -= 1
#         @page = 1 if @page<1
#         @page = 3 if @page>3
#         if @page!=oldpage
#           pbPlayCursorSE
#           dorefresh = true
#         end
#       elsif Input.trigger?(Input::RIGHT)
#         oldpage = @page
#         @page += 1
#         @page = 1 if @page<1
#         @page = 3 if @page>3
#         if @page!=oldpage
#           pbPlayCursorSE
#           dorefresh = true
#         end
#       end
#       if dorefresh
#         drawPage(@page)
#       end
#     end
#     return @index
#   end
# end
