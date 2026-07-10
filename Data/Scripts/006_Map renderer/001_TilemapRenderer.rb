#===============================================================================
#
#===============================================================================
class TilemapRenderer
  attr_reader :tilesets
  attr_reader :autotiles
  attr_reader :custom_autotile_ids
  attr_accessor :tone
  attr_accessor :color
  attr_reader :viewport
  attr_accessor :ox # Does nothing
  attr_accessor :oy # Does nothing
  attr_accessor :visible # Does nothing

  DISPLAY_TILE_WIDTH = Game_Map::TILE_WIDTH rescue 32
  DISPLAY_TILE_HEIGHT = Game_Map::TILE_HEIGHT rescue 32
  SOURCE_TILE_WIDTH = 32
  SOURCE_TILE_HEIGHT = 32
  ZOOM_X = DISPLAY_TILE_WIDTH / SOURCE_TILE_WIDTH
  ZOOM_Y = DISPLAY_TILE_HEIGHT / SOURCE_TILE_HEIGHT
  TILESET_TILES_PER_ROW = 8
  AUTOTILES_COUNT = 8 # Counting the blank tile as an autotile
  TILES_PER_AUTOTILE = 48
  TILESET_START_ID = AUTOTILES_COUNT * TILES_PER_AUTOTILE
  # If an autotile's filename ends with "[x]", its frame duration will be x/20
  # seconds instead.
  AUTOTILE_FRAME_DURATION = 5 # In 1/20ths of a second

  # Filenames of extra autotiles for each tileset. Each tileset's entry is an
  # array containing two other arrays (you can leave either of those empty, but
  # they must be defined):
  #   - The first sub-array is for large autotiles, i.e. ones with 48 different
  #     tile layouts. For example, "Brick path" and "Sea".
  #   - The second is for single tile autotiles. For example, "Flowers1" and
  #     "Waterfall"
  # The top tiles of the tileset will instead use these autotiles. Large
  # autotiles come first, in the same 8x6 layout as you see when you double-
  # click on a real autotile in RMXP. After that are the single tile autotiles.
  # Extra autotiles are only useful if the tiles are animated, because otherwise
  # you just have some tiles which belong in the tileset instead.

  #   Examples:
  #    1 => [["Sand shore"], ["Flowers2"]],
  #    2 => [[], ["Flowers2", "Waterfall", "Waterfall crest", "Waterfall bottom"]],
  #    6 => [["Water rock", "Sea deep"], []]

  EXTRA_AUTOTILES = {
    1 => { # route-field
           996 => "flowers_orange[10]",
           991 => "flowers_pink[10]",
           999 => "flowers_yellow[10]",
           1007 => "flowers_blue[10]",
           1015 => "flowers_purple[10]",
           1023 => "flowers_red[10]",
           1031 => "flowers_grey[10]",
           1039 => "flowers_white[10]",
           # water rocks
           1162 => "water_rock_large01[5]", 1163 => "water_rock_large02[5]",
           1170 => "water_rock_large03[5]", 1171 => "water_rock_large04[5]",
           1173 => "water_rock_medium[10]",
           # water cliffs
           1363 => "water_rock10", 1364 => "water_rock11",
           1389 => "water_rock01", 1391 => "water_rock09",
           1381 => "water_rock_shore08", 1382 => "water_rock_shore09",

           1377 => "water_rock08", 1379 => "water_rock07",
           1384 => "water_rock_shore01", 1385 => "water_rock02", 1387 => "water_rock06", 1397 => "water_rock_shore07",
           1392 => "water_rock_shore02", 1393 => "water_rock03", 1394 => "water_rock04", 1395 => "water_rock05", 1396 => "water_rock_shore06",
           1401 => "water_rock_shore03", 1402 => "water_rock_shore04", 1403 => "water_rock_shore05",

    },

    8 => { # route-cycling
           996 => "flowers_orange[10]",
           991 => "flowers_pink[10]",
           999 => "flowers_yellow[10]",
           1007 => "flowers_blue[10]",
           1015 => "flowers_purple[10]",
           1023 => "flowers_red[10]",
           1031 => "flowers_grey[10]",
           1039 => "flowers_white[10]",
           # water rocks
           1162 => "water_rock_large01[5]", 1163 => "water_rock_large02[5]",
           1170 => "water_rock_large03[5]", 1171 => "water_rock_large04[5]",
           1173 => "water_rock_medium[10]",
           # water cliffs
           1363 => "water_rock10", 1364 => "water_rock11",
           1389 => "water_rock01", 1391 => "water_rock09",
           1381 => "water_rock_shore08", 1382 => "water_rock_shore09",

           1377 => "water_rock08", 1379 => "water_rock07",
           1384 => "water_rock_shore01", 1385 => "water_rock02", 1387 => "water_rock06", 1397 => "water_rock_shore07",
           1392 => "water_rock_shore02", 1393 => "water_rock03", 1394 => "water_rock04", 1395 => "water_rock05", 1396 => "water_rock_shore06",
           1401 => "water_rock_shore03", 1402 => "water_rock_shore04", 1403 => "water_rock_shore05",
    },

    2 => { # small-town
           996 => "flowers_orange[10]",
           991 => "flowers_pink[10]",
           999 => "flowers_yellow[10]",
           1007 => "flowers_blue[10]",
           1015 => "flowers_purple[10]",
           1023 => "flowers_red[10]",
           1031 => "flowers_grey[10]",
           1039 => "flowers_white[10]",

    },

    5 => { # Rustboro
           996 => "flowers_orange[10]",
           991 => "flowers_pink[10]",
           999 => "flowers_yellow[10]",
           1007 => "flowers_blue[10]",
           1015 => "flowers_purple[10]",
           1023 => "flowers_red[10]",
           1031 => "flowers_grey[10]",
           1039 => "flowers_white[10]",

    },

    6 => { # Dewford Town
           # water rocks
           1162 => "water_rock_large01[5]", 1163 => "water_rock_large02[5]",
           1170 => "water_rock_large03[5]", 1171 => "water_rock_large04[5]",
           1173 => "water_rock_medium[10]",
           # water cliffs
           1363 => "water_rock10", 1364 => "water_rock11",
           1389 => "water_rock01", 1391 => "water_rock09",
           1381 => "water_rock_shore08", 1382 => "water_rock_shore09",

           1377 => "water_rock08", 1379 => "water_rock07",
           1384 => "water_rock_shore01", 1385 => "water_rock02", 1387 => "water_rock06", 1397 => "water_rock_shore07",
           1392 => "water_rock_shore02", 1393 => "water_rock03", 1394 => "water_rock04", 1395 => "water_rock05", 1396 => "water_rock_shore06",
           1401 => "water_rock_shore03", 1402 => "water_rock_shore04", 1403 => "water_rock_shore05",
    },

    7 => { # Sea Route
           # Mangroves
           1062 => "mangrove_small_2[15]", 1063 => "mangrove_small_1[15]",
           1088 => "mangrove_1_left[15]", 1089 => "mangrove_1_right[15]", 1090 => "mangrove_2_left[15]", 1091 => "mangrove_2_right[15]",
           1092 => "mangrove_3_left[15]", 1093 => "mangrove_3_center_left[15]", 1094 => "mangrove_3_center_right[15]", 1095 => "mangrove_3_right[15]",

           # water rocks
           1162 => "water_rock_large01[5]", 1163 => "water_rock_large02[5]",
           1170 => "water_rock_large03[5]", 1171 => "water_rock_large04[5]",
           1173 => "water_rock_medium[10]",
           # water cliffs
           1363 => "water_rock10", 1364 => "water_rock11",
           1389 => "water_rock01", 1391 => "water_rock09",
           1381 => "water_rock_shore08", 1382 => "water_rock_shore09",

           1377 => "water_rock08", 1379 => "water_rock07",
           1384 => "water_rock_shore01", 1385 => "water_rock02", 1387 => "water_rock06", 1397 => "water_rock_shore07",
           1392 => "water_rock_shore02", 1393 => "water_rock03", 1394 => "water_rock04", 1395 => "water_rock05", 1396 => "water_rock_shore06",
           1401 => "water_rock_shore03", 1402 => "water_rock_shore04", 1403 => "water_rock_shore05",
    },

    12 => { # Slateport
            # water rocks
            1162 => "water_rock_large01[5]", 1163 => "water_rock_large02[5]",
            1170 => "water_rock_large03[5]", 1171 => "water_rock_large04[5]",
            1173 => "water_rock_medium[10]",
            #
            996 => "flowers_orange[10]",
            991 => "flowers_pink[10]",
            999 => "flowers_yellow[10]",
            1007 => "flowers_blue[10]",
            1015 => "flowers_purple[10]",
            1023 => "flowers_red[10]",
            1031 => "flowers_grey[10]",
            1039 => "flowers_white[10]",

    },

    23 => { # outdoor
            1232 => "flowers_orange[10]",
            1240 => "flowers_pink[10]",
            1248 => "flowers_yellow[10]",
            1256 => "flowers_blue[10]",
            1264 => "flowers_purple[10]",
            1272 => "flowers_red[10]",
            1280 => "flowers_grey[10]",
            1288 => "flowers_white[10]",

    },
    30 => {
      2620 => "flowers_orange[10]",
      2628 => "flowers_pink[10]",
      2636 => "flowers_yellow[10]",
      2644 => "flowers_blue[10]",
      2652 => "flowers_purple[10]",
      2660 => "flowers_red[10]",
      2668 => "flowers_grey[10]",
      2676 => "flowers_white[10]",
    },
    31 => { #Underwater
            1096 => "kelp_top[20]",
            1104 => "kelp_middle[20]",
            1112 => "kelp_bottom[20]",

    }
  }

  WIND_TREE_AUTOTILES = {
    1 => { # Route-field
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",
    },
    7 => { # Route-sea
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",

           1055 => "mangrove_small_1_wind_1",
           1063 => "mangrove_small_1_wind_2",

           1066 => "mangrove_2_wind_1",
           1067 => "mangrove_2_wind_2",
           1074 => "mangrove_2_wind_3",
           1075 => "mangrove_2_wind_4",
           1082 => "mangrove_2_wind_5",
           1083 => "mangrove_2_wind_6",

    },

    8 => { # Route-cycling
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",
    },

    2 => { # small-town
           # trees
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",
    },

    5 => { # Rustboro
           # trees
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",
    },

    9 => { # Route Forest
           # trees
           864 => "tree_sway_single_1",
           865 => "tree_sway_single_2",
           872 => "tree_sway_single_3",
           873 => "tree_sway_single_4",
           880 => "tree_sway_single_5",
           881 => "tree_sway_single_6",

           866 => "tree_sway_group_1",
           867 => "tree_sway_group_2",
           874 => "tree_sway_group_3",
           875 => "tree_sway_group_4",
    },

    12 => { # Slateport
            864 => "tree_sway_single_1",
            865 => "tree_sway_single_2",
            872 => "tree_sway_single_3",
            873 => "tree_sway_single_4",
            880 => "tree_sway_single_5",
            881 => "tree_sway_single_6",

            866 => "tree_sway_group_1",
            867 => "tree_sway_group_2",
            874 => "tree_sway_group_3",
            875 => "tree_sway_group_4",
    },

    13 => { # Mauville
            864 => "tree_sway_single_1",
            865 => "tree_sway_single_2",
            872 => "tree_sway_single_3",
            873 => "tree_sway_single_4",
            880 => "tree_sway_single_5",
            881 => "tree_sway_single_6",

            866 => "tree_sway_group_1",
            867 => "tree_sway_group_2",
            874 => "tree_sway_group_3",
            875 => "tree_sway_group_4",
    },

  }

  #=============================================================================
  #
  #=============================================================================
  class TilesetBitmaps
    attr_accessor :changed
    attr_accessor :bitmaps

    def initialize
      @bitmaps = {}
      @bitmap_wraps = {} # Whether each tileset is a mega texture and has multiple columns
      @load_counts = {}
      @bridge = 0
      @changed = true
      @last_weather_type = nil
    end

    def [](filename)
      return @bitmaps[filename]
    end

    def []=(filename, bitmap)
      return if nil_or_empty?(filename)
      @bitmaps[filename] = bitmap
      @bitmap_wraps[filename] = false
      @changed = true
    end

    def add(filename)
      return if nil_or_empty?(filename)
      if @bitmaps[filename]
        @load_counts[filename] += 1
        return
      end
      bitmap = pbGetTileset(filename)
      @bitmap_wraps[filename] = false
      if bitmap.mega?
        self[filename] = TilemapRenderer::TilesetWrapper.wrapTileset(bitmap)
        @bitmap_wraps[filename] = true
        bitmap.dispose
      else
        self[filename] = bitmap
      end
      @load_counts[filename] = 1
    end

    def remove(filename)
      return if nil_or_empty?(filename) || !@bitmaps[filename]
      if @load_counts[filename] > 1
        @load_counts[filename] -= 1
        return
      end
      @bitmaps[filename].dispose
      @bitmaps.delete(filename)
      @bitmap_wraps.delete(filename)
      @load_counts.delete(filename)
    end

    def set_src_rect(tile, tile_id)
      return if nil_or_empty?(tile.filename)
      return if !@bitmaps[tile.filename]
      tile.src_rect.x = ((tile_id - TILESET_START_ID) % TILESET_TILES_PER_ROW) * SOURCE_TILE_WIDTH
      tile.src_rect.y = ((tile_id - TILESET_START_ID) / TILESET_TILES_PER_ROW) * SOURCE_TILE_HEIGHT
      if @bitmap_wraps[tile.filename]
        height = @bitmaps[tile.filename].height
        col = (tile_id - TILESET_START_ID) * SOURCE_TILE_HEIGHT / (TILESET_TILES_PER_ROW * height)
        tile.src_rect.x += col * TILESET_TILES_PER_ROW * SOURCE_TILE_WIDTH
        tile.src_rect.y -= col * height
      end
    end

    def update; end
  end

  #=============================================================================
  #
  #=============================================================================
  class AutotileBitmaps < TilesetBitmaps
    attr_reader :current_frames

    def initialize
      super
      @frame_counts = {} # Number of frames in each autotile
      @frame_durations = {} # How long each frame lasts per autotile
      @current_frames = {} # Which frame each autotile is currently showing
      @timer = 0.0 # System.uptime
    end

    def []=(filename, value)
      super
      return if nil_or_empty?(filename)
      frame_count(filename, true)
      set_current_frame(filename)
    end

    EXPANDED_AUTOTILES_FOLDER = "Graphics/Autotiles/ExpandedAutotiles/"

    def add(filename)
      return if nil_or_empty?(filename)
      if @bitmaps[filename]
        @load_counts[filename] += 1
        return
      end

      # Try to load expanded autotile from cache first
      cached_path = File.join("Graphics", "Autotiles/ExpandedAutotiles", "#{filename}.png")
      if safeExists?(cached_path)
        # echoln "Loading cached expanded autotile for #{filename}"
        bitmap = RPG::Cache.load_bitmap(EXPANDED_AUTOTILES_FOLDER, filename)

        duration = AUTOTILE_FRAME_DURATION
        if filename[/\[\s*(\d+?)\s*\]\s*$/]
          duration = $~[1].to_i
        end
        @frame_durations[filename] = duration.to_f / 20

      else
        orig_bitmap = pbGetAutotile(filename)
        @bitmap_wraps[filename] = false
        duration = AUTOTILE_FRAME_DURATION
        if filename[/\[\s*(\d+?)\s*\]\s*$/]
          duration = $~[1].to_i
        end
        @frame_durations[filename] = duration.to_f / 20
        expanded_bitmap = AutotileExpander.expand(orig_bitmap)

        # Save expanded bitmap to cache for next time
        Dir.mkdir(EXPANDED_AUTOTILES_FOLDER) unless Dir.exist?(EXPANDED_AUTOTILES_FOLDER)
        expanded_bitmap.save_to_png(cached_path)

        bitmap = expanded_bitmap
        orig_bitmap.dispose if orig_bitmap != expanded_bitmap
      end

      self[filename] = bitmap
      if bitmap.height > SOURCE_TILE_HEIGHT && bitmap.height < TILES_PER_AUTOTILE * SOURCE_TILE_HEIGHT
        @bitmap_wraps[filename] = true
      end
      @load_counts[filename] = 1
    end

    def remove(filename)
      super
      return if @load_counts[filename] && @load_counts[filename] > 0
      @frame_counts.delete(filename)
      @current_frames.delete(filename)
      @frame_durations.delete(filename)
    end

    def frame_count(filename, force_recalc = false)
      if !@frame_counts[filename] || force_recalc
        return 0 if !@bitmaps[filename]
        bitmap = @bitmaps[filename]
        @frame_counts[filename] = [bitmap.width / SOURCE_TILE_WIDTH, 1].max
        if bitmap.height > SOURCE_TILE_HEIGHT && @bitmap_wraps[filename]
          @frame_counts[filename] /= 2
        end
      end
      return @frame_counts[filename]
    end

    def animated?(filename)
      return frame_count(filename) > 1
    end

    def current_frame(filename)
      set_current_frame(filename) if !@current_frames[filename]
      return @current_frames[filename]
    end

    def set_current_frame(filename)
      frames = frame_count(filename)
      if frames < 2
        @current_frames[filename] = 0
      else
        @current_frames[filename] = (@timer / @frame_durations[filename]).floor % frames
      end
    end

    def set_src_rect(tile, tile_id)
      filename = tile.filename

      # Check if this tile_id was overridden to use a specific autotile
      override_filename = @custom_autotile_ids && @custom_autotile_ids[tile_id]
      filename = override_filename if override_filename

      return if nil_or_empty?(filename)
      return unless @bitmaps[filename]

      frame = current_frame(filename)

      if @bitmaps[filename].height == SOURCE_TILE_HEIGHT
        tile.src_rect.x = frame * SOURCE_TILE_WIDTH
        tile.src_rect.y = 0
        return
      end

      wraps = @bitmap_wraps[filename]
      high_id = ((tile_id % TILES_PER_AUTOTILE) >= TILES_PER_AUTOTILE / 2)
      tile.src_rect.x = 0
      tile.src_rect.y = (tile_id % TILES_PER_AUTOTILE) * SOURCE_TILE_HEIGHT
      if wraps && high_id
        tile.src_rect.x = SOURCE_TILE_WIDTH
        tile.src_rect.y -= SOURCE_TILE_HEIGHT * TILES_PER_AUTOTILE / 2
      end
      tile.src_rect.x += frame * SOURCE_TILE_WIDTH * (wraps ? 2 : 1)

      # Override the filename in the tile object for consistency
      tile.filename = filename if override_filename
    end

    def update
      super
      @timer += Graphics.delta_s
      # Update the current frame for each autotile
      @bitmaps.each_key do |filename|
        next if !@bitmaps[filename] || @bitmaps[filename].disposed?
        old_frame = @current_frames[filename]
        set_current_frame(filename)
        @changed = true if @current_frames[filename] != old_frame
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class TileSprite < Sprite
    attr_accessor :filename
    attr_accessor :tile_id
    attr_accessor :is_autotile
    attr_accessor :animated
    attr_accessor :priority
    attr_accessor :shows_reflection
    attr_accessor :underwater_tile
    attr_accessor :bridge
    attr_accessor :need_refresh

    def set_bitmap(filename, tile_id, autotile, animated, priority, bitmap)
      self.bitmap = bitmap
      self.src_rect = Rect.new(0, 0, SOURCE_TILE_WIDTH, SOURCE_TILE_HEIGHT)
      self.zoom_x = ZOOM_X
      self.zoom_y = ZOOM_Y
      @filename = filename
      @tile_id = tile_id
      @is_autotile = autotile
      @animated = animated
      @priority = priority
      @shows_reflection = false
      @bridge = false
      self.visible = !bitmap.nil?
      @need_refresh = true
    end
  end

  #-----------------------------------------------------------------------------

  def initialize(viewport)
    @tilesets = TilesetBitmaps.new
    @autotiles = AutotileBitmaps.new
    @custom_autotile_ids = {} # key: tile_id, value: filename
    @tiles_horizontal_count = (Graphics.width.to_f / DISPLAY_TILE_WIDTH).ceil + 1
    @tiles_vertical_count = (Graphics.height.to_f / DISPLAY_TILE_HEIGHT).ceil + 1
    @tone = Tone.new(0, 0, 0, 0)
    @old_tone = Tone.new(0, 0, 0, 0)
    @color = Color.new(0, 0, 0, 0)
    @old_color = Color.new(0, 0, 0, 0)
    @self_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport = (viewport) ? viewport : @self_viewport
    @old_viewport_ox = 0
    @old_viewport_oy = 0
    # NOTE: The extra tiles horizontally/vertically hang off the left and top
    #       edges of the screen, because the pixel_offset values are positive
    #       and are added to the tile sprite coordinates.
    @tiles = []
    @tiles_horizontal_count.times do |i|
      @tiles[i] = []
      @tiles_vertical_count.times do |j|
        @tiles[i][j] = Array.new(3) { TileSprite.new(@viewport) }
      end
    end
    @current_map_id = 0
    @tile_offset_x = 0
    @tile_offset_y = 0
    @pixel_offset_x = 0
    @pixel_offset_y = 0
    @ox = 0
    @oy = 0
    @visible = true
    @need_refresh = true
    @disposed = false
  end

  def dispose
    return if disposed?
    @tiles.each do |col|
      col.each do |coord|
        coord.each { |tile| tile.dispose }
        coord.clear
      end
    end
    @tiles.clear
    @tilesets.bitmaps.each_value { |bitmap| bitmap.dispose }
    @tilesets.bitmaps.clear
    @autotiles.bitmaps.each_value { |bitmap| bitmap.dispose }
    @autotiles.bitmaps.clear
    @self_viewport.dispose
    @self_viewport = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  #-----------------------------------------------------------------------------

  def add_tileset(filename)
    @tilesets.add(filename)
  end

  def remove_tileset(filename)
    @tilesets.remove(filename)
  end

  def add_autotile(filename)
    @autotiles.add(filename)
  end

  def remove_autotile(filename)
    @autotiles.remove(filename)
  end

  def get_autotile_overrides(tileset_id, map_id)
    base_overrides = EXTRA_AUTOTILES[tileset_id] || {}
    return base_overrides unless $game_weather
    wind_overrides = WIND_TREE_AUTOTILES[tileset_id] || {}
    if $game_weather.map_current_weather_type(map_id) == :Wind || $game_weather.map_current_weather_type(map_id) == :Storm && WIND_TREE_AUTOTILES[tileset_id]
      return base_overrides.merge(wind_overrides)
    end
    return base_overrides
  end

  def add_extra_autotiles(tileset_id, map_id)
    overrides = get_autotile_overrides(tileset_id, map_id)
    return if !overrides || overrides.empty?
    overrides.each do |tile_id, filename|
      @autotiles.add(filename)
      @custom_autotile_ids[tile_id] = filename
    end
  end

  def remove_extra_autotiles(tileset_id)
    return if !EXTRA_AUTOTILES[tileset_id]
    EXTRA_AUTOTILES[tileset_id].each do |arr|
      arr.each { |filename| remove_autotile(filename) }
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    @need_refresh = true
  end

  INVISIBLE_WALL_TILE_ID = 384

  def refresh_tile_bitmap(tile, map, tile_id)
    tile.tile_id = tile_id
    if tile_id < TILES_PER_AUTOTILE || (Settings::HOENN && tile_id == INVISIBLE_WALL_TILE_ID)
      tile.set_bitmap("", tile_id, false, false, 0, nil)
      tile.shows_reflection = false
      tile.bridge = false
    else
      terrain_tag = map.terrain_tags[tile_id] || 0
      terrain_tag_data = GameData::TerrainTag.try_get(terrain_tag)
      priority = map.priorities[tile_id] || 0
      single_autotile_start_id = TILESET_START_ID
      true_tileset_start_id = TILESET_START_ID
      # extra_autotile_arrays = EXTRA_AUTOTILES[map.tileset_id]
      # if extra_autotile_arrays
      #   large_autotile_count = extra_autotile_arrays[0].length
      #   single_autotile_count = extra_autotile_arrays[1].length
      #   single_autotile_start_id += large_autotile_count * TILES_PER_AUTOTILE
      #   true_tileset_start_id += large_autotile_count * TILES_PER_AUTOTILE
      #   true_tileset_start_id += single_autotile_count
      # end

      filename = nil
      extra_autotile_hash = get_autotile_overrides(map.tileset_id, map.map_id)

      if extra_autotile_hash && extra_autotile_hash[tile_id]
        # Custom tile_id override
        filename = extra_autotile_hash[tile_id]
        tile.set_bitmap(filename, tile_id, true, @autotiles.animated?(filename),
                        priority, @autotiles[filename])
      elsif tile_id < true_tileset_start_id
        # Default behavior
        if tile_id < TILESET_START_ID # Real autotiles
          filename = map.autotile_names[(tile_id / TILES_PER_AUTOTILE) - 1]
        elsif tile_id < single_autotile_start_id # Large extra autotiles
          filename = extra_autotile_arrays[0][(tile_id - TILESET_START_ID) / TILES_PER_AUTOTILE]
        else
          # Single extra autotiles
          filename = extra_autotile_arrays[1][tile_id - single_autotile_start_id]
        end
        tile.set_bitmap(filename, tile_id, true, @autotiles.animated?(filename),
                        priority, @autotiles[filename])
      else
        filename = map.tileset_name
        tile.set_bitmap(filename, tile_id, false, false, priority, @tilesets[filename])
      end

      tile.shows_reflection = terrain_tag_data&.shows_reflections
      tile.underwater_tile = terrain_tag_data&.underwater
      tile.bridge = terrain_tag_data&.bridge
    end
    refresh_tile_src_rect(tile, tile_id)
  end

  def refresh_tile_src_rect(tile, tile_id)
    if tile.is_autotile
      @autotiles.set_src_rect(tile, tile_id)
    else
      @tilesets.set_src_rect(tile, tile_id)
    end
  end

  # For animated autotiles only
  def refresh_tile_frame(tile, tile_id)
    return if !tile.animated
    @autotiles.set_src_rect(tile, tile_id)
  end

  # x and y are the positions of tile within @tiles, not a map x/y
  def refresh_tile_coordinates(tile, x, y)
    tile.x = (x * DISPLAY_TILE_WIDTH) - @pixel_offset_x
    tile.y = (y * DISPLAY_TILE_HEIGHT) - @pixel_offset_y
  end

  def refresh_tile_z(tile, map, y, layer, tile_id)
    if tile.underwater_tile # tile.shows_reflection -2000
      tile.z = -5
    elsif tile.bridge && $PokemonGlobal.bridge > 0
      tile.z = 0
    else
      priority = tile.priority
      tile.z = (priority == 0) ? 0 : y * DISPLAY_TILE_HEIGHT + priority * 32 + 32
    end
  end

  def refresh_tile(tile, x, y, map, layer, tile_id)
    refresh_tile_bitmap(tile, map, tile_id)
    refresh_tile_coordinates(tile, x, y)
    refresh_tile_z(tile, map, y, layer, tile_id)
    tile.need_refresh = false
  end

  #-----------------------------------------------------------------------------

  def check_if_screen_moved
    ret = false
    # Check for map change
    if @current_map_id != $game_map.map_id
      if MapFactoryHelper.hasConnections?(@current_map_id)
        offsets = $MapFactory.getRelativePos(@current_map_id, 0, 0, $game_map.map_id, 0, 0)
        if offsets
          @tile_offset_x -= offsets[0]
          @tile_offset_y -= offsets[1]
        else
          ret = true # Need a full refresh
        end
      else
        ret = true
      end
      @current_map_id = $game_map.map_id
    end
    # Check for tile movement
    current_map_display_x = ($game_map.display_x.to_f / Game_Map::X_SUBPIXELS).round
    current_map_display_y = ($game_map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
    new_tile_offset_x = (current_map_display_x / SOURCE_TILE_WIDTH) * ZOOM_X
    new_tile_offset_y = (current_map_display_y / SOURCE_TILE_HEIGHT) * ZOOM_Y
    if new_tile_offset_x != @tile_offset_x
      if new_tile_offset_x > @tile_offset_x
        # Take tile stacks off the right and insert them at the beginning (left)
        (new_tile_offset_x - @tile_offset_x).times do
          c = @tiles.shift
          @tiles.push(c)
          c.each do |coord|
            coord.each { |tile| tile.need_refresh = true }
          end
        end
      else
        # Take tile stacks off the beginning (left) and push them onto the end (right)
        (@tile_offset_x - new_tile_offset_x).times do
          c = @tiles.pop
          @tiles.prepend(c)
          c.each do |coord|
            coord.each { |tile| tile.need_refresh = true }
          end
        end
      end
      @screen_moved = true
      @tile_offset_x = new_tile_offset_x
    end
    if new_tile_offset_y != @tile_offset_y
      if new_tile_offset_y > @tile_offset_y
        # Take tile stacks off the bottom and insert them at the beginning (top)
        @tiles.each do |col|
          (new_tile_offset_y - @tile_offset_y).times do
            c = col.shift
            col.push(c)
            c.each { |tile| tile.need_refresh = true }
          end
        end
      else
        # Take tile stacks off the beginning (top) and push them onto the end (bottom)
        @tiles.each do |col|
          (@tile_offset_y - new_tile_offset_y).times do
            c = col.pop
            col.prepend(c)
            c.each { |tile| tile.need_refresh = true }
          end
        end
      end
      @screen_moved = true
      @screen_moved_vertically = true
      @tile_offset_y = new_tile_offset_y
    end
    # Check for pixel movement
    new_pixel_offset_x = (current_map_display_x % SOURCE_TILE_WIDTH) * ZOOM_X
    new_pixel_offset_y = (current_map_display_y % SOURCE_TILE_HEIGHT) * ZOOM_Y
    if new_pixel_offset_x != @pixel_offset_x
      @screen_moved = true
      @pixel_offset_x = new_pixel_offset_x
    end
    if new_pixel_offset_y != @pixel_offset_y
      @screen_moved = true
      @screen_moved_vertically = true
      @pixel_offset_y = new_pixel_offset_y
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def update
    # Update tone
    if @old_tone != @tone
      @tiles.each do |col|
        col.each do |coord|
          coord.each { |tile| tile.tone = @tone }
        end
      end
      @old_tone = @tone.clone
    end
    # Update color
    if @old_color != @color
      @tiles.each do |col|
        col.each do |coord|
          coord.each { |tile| tile.color = @color }
        end
      end
      @old_color = @color.clone
    end

    # Check for updated weather
    current_weather = $game_weather&.map_current_weather_type($game_map.map_id)
    if current_weather != @last_weather_type
      tileset_id = $game_map.tileset_id
      add_extra_autotiles(tileset_id, $game_map.map_id)
      refresh
      @last_weather_type = current_weather
    end

    # Recalculate autotile frames
    @tilesets.update
    @autotiles.update
    do_full_refresh = @need_refresh
    if @viewport.ox != @old_viewport_ox || @viewport.oy != @old_viewport_oy
      @old_viewport_ox = @viewport.ox
      @old_viewport_oy = @viewport.oy
      do_full_refresh = true
    end
    # Check whether the screen has moved since the last update
    @screen_moved = false
    @screen_moved_vertically = false
    if $PokemonGlobal.bridge != @bridge
      @bridge = $PokemonGlobal.bridge
      @screen_moved_vertically = true # To update bridge tiles' z values
    end
    do_full_refresh = true if check_if_screen_moved
    # Update all tile sprites
    visited = []
    @tiles_horizontal_count.times do |i|
      visited[i] = []
      @tiles_vertical_count.times { |j| visited[i][j] = false }
    end
    $MapFactory.maps.each do |map|
      # Calculate x/y ranges of tile sprites that represent them
      map_display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_x = ((map_display_x + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
      map_display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      map_display_y = ((map_display_y + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
      map_display_x_tile = map_display_x / DISPLAY_TILE_WIDTH
      map_display_y_tile = map_display_y / DISPLAY_TILE_HEIGHT
      start_x = [-map_display_x_tile, 0].max
      start_y = [-map_display_y_tile, 0].max
      end_x = @tiles_horizontal_count - 1
      end_x = [end_x, map.width - map_display_x_tile - 1].min
      end_y = @tiles_vertical_count - 1
      end_y = [end_y, map.height - map_display_y_tile - 1].min
      next if start_x > end_x || start_y > end_y || end_x < 0 || end_y < 0
      # Update all tile sprites representing this map
      (start_x..end_x).each do |i|
        tile_x = i + map_display_x_tile
        (start_y..end_y).each do |j|
          tile_y = j + map_display_y_tile
          @tiles[i][j].each_with_index do |tile, layer|
            tile_id = map.data[tile_x, tile_y, layer]
            if do_full_refresh || tile.need_refresh || tile.tile_id != tile_id
              refresh_tile(tile, i, j, map, layer, tile_id)
            else
              refresh_tile_frame(tile, tile_id) if tile.animated && @autotiles.changed
              # Update tile's x/y coordinates
              refresh_tile_coordinates(tile, i, j) if @screen_moved
              # Update tile's z value
              refresh_tile_z(tile, map, j, layer, tile_id) if @screen_moved_vertically
            end
          end
          # Record x/y as visited
          visited[i][j] = true
        end
      end
    end
    # Clear all unvisited tile sprites
    @tiles.each_with_index do |col, i|
      col.each_with_index do |coord, j|
        next if visited[i][j]
        coord.each do |tile|
          tile.set_bitmap("", 0, false, false, 0, nil)
          tile.shows_reflection = false
          tile.bridge = false
        end
      end
    end
    @need_refresh = false
    @autotiles.changed = false
  end
end
