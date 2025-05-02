#===============================================================================
#
#===============================================================================
class Bitmap
  def hue_customcolor(rules_string)
    return if rules_string.nil? || rules_string == "nil"
    rules = rules_string.split("|").map do |str|
      parts = str.split(".")
      {
        from: parts[0].split.map(&:to_f),
        to: parts[1].split.map(&:to_f)
      }
    end
    width.times do |x|
      height.times do |y|
        color = get_pixel(x, y)
        next if color.alpha == 0
        r, g, b = color.red.to_f, color.green.to_f, color.blue.to_f
        # Avoid division by zero
        r = 10 if r <= 10
        g = 10 if g <= 10
        b = 10 if b <= 10
        
        min_distance = Float::INFINITY
        closest_rule = nil
  
        rules.each do |rule|
          from = rule[:from]
          # Avoid division by zero
          from[0] = 10 if from[0] <= 10
          from[1] = 10 if from[1] <= 10
          from[2] = 10 if from[2] <= 10
          dist = (r - from[0])**2 + (g - from[1])**2 + (b - from[2])**2
          if dist < min_distance
            min_distance = dist
            closest_rule = rule
          end
        end
  
        next unless closest_rule
  
        from = closest_rule[:from]
        to = closest_rule[:to]
        # Avoid mult by zero
        to[0] = 10 if to[0] <= 10
        to[1] = 10 if to[1] <= 10
        to[2] = 10 if to[2] <= 10
        r_factor = r / from[0]
        g_factor = g / from[1]
        b_factor = b / from[2]
  
        adjusted_r = (to[0] * r_factor).clamp(0, 255)
        adjusted_g = (to[1] * g_factor).clamp(0, 255)
        adjusted_b = (to[2] * b_factor).clamp(0, 255)
        set_pixel(x, y, Color.new(adjusted_r.to_i, adjusted_g.to_i, adjusted_b.to_i, color.alpha))
      end
    end
  end  

  def hue_clear(dex_number, name)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
    end

    return unless Dir.exist?(shiny_directory)
  
    # browse files in shiny_directory
    Dir.foreach(shiny_directory) do |file|
      next if file == "." || file == ".." # Ignorer les entrées spéciales
      file_path = File.join(shiny_directory, file)
  
      # delete files whose name contains "name"
      if File.file?(file_path) && file.include?(name)
        File.delete(file_path)
      end
    end
  end

  def hue_rename(dex_number, name, newname)
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
    end
  
    return unless Dir.exist?(shiny_directory)
  
    Dir.entries(shiny_directory).each do |file|
      next unless file.include?(name) && file.end_with?(".png")
  
      old_path = "#{shiny_directory}/#{file}"
      new_file = file.sub(name, newname)
      new_path = "#{shiny_directory}/#{new_file}"
  
      File.rename(old_path, new_path)
    end
  end


  def hue_changecolors(dex_number, bodyShiny, headShiny, alt = "")
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
      shiny_file_path = "#{shiny_directory}/#{head_id}.#{body_id}"
      offsets = [SHINY_COLOR_OFFSETS[body_id], SHINY_COLOR_OFFSETS[head_id]]
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
      shiny_file_path = "#{shiny_directory}/#{dex_number}"
      offsets = [SHINY_COLOR_OFFSETS[dex_number]]
    end

    # Determine the destination folders
    shiny_file_path += alt + "_bodyShiny" if bodyShiny
    shiny_file_path += alt + "_headShiny" if headShiny
    shiny_file_path += alt +".png"
    if File.exist?(shiny_file_path)
      return
    end
  

  
    offset = offsets.compact.max_by { |o| o.keys.count }
    return unless offset
    onetime = true
    offset.keys.each do |version|
      value = offset&.dig(version)
  
      if value.is_a?(String) && onetime
        onetime = false
        hue_customcolor(GameData::Species.calculateCustomShinyHueOffset(dex_number, bodyShiny, headShiny))
        Dir.mkdir(shiny_directory) unless Dir.exist?(shiny_directory)
        self.save_to_png(shiny_file_path)
      elsif !value.is_a?(String)
        hue_change(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny, version))
      end
    end
  end
end
#===============================================================================
class AnimatedBitmap
  attr_reader :path
  attr_reader :filename

  def initialize(file, hue = 0)
    raise "Filename is nil (missing graphic)." if file.nil?
    path = file
    filename = ""
    if file.last != "/" # Isn't just a directory
      split_file = file.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join("/") + "/"
    end
    @filename = filename
    @path = path
    if filename[/^\[\d+(?:,\d+)?\]/] # Starts with 1 or 2 numbers in square brackets
      @bitmap = PngAnimatedBitmap.new(path, filename, hue)
    else
      @bitmap = GifBitmap.new(path, filename, hue)
    end
  end

  def setup_from_bitmap(bitmap, hue = 0)
    @path = ""
    @filename = ""
    @bitmap = GifBitmap.new("", "", hue)
    @bitmap.bitmap = bitmap
  end

  def self.from_bitmap(bitmap, hue = 0)
    obj = allocate
    obj.send(:setup_from_bitmap, bitmap, hue)
    obj
  end

  def pbSetColor(r = 0, g = 0, b = 0, a = 255)
    color = Color.new(r, g, b, a)
    pbSetColorValue(color)
  end

  def pbSetColorValue(color)
    for i in 0..@bitmap.bitmap.width
      for j in 0..@bitmap.bitmap.height
        if @bitmap.bitmap.get_pixel(i, j).alpha != 0
          @bitmap.bitmap.set_pixel(i, j, color)
        end
      end
    end
  end

  def shiftColors(offset = 0)
    @bitmap.bitmap.hue_change(offset)
  end

  def shiftCustomColors(rules)
    @bitmap.bitmap.hue_customcolor(rules)
  end
  
  def shiftAllColors(dex_number, bodyShiny, headShiny)
    # pratically the same as hue_changecolors but for the animated bitmap
    if isFusion(dex_number)
      body_id = getBodyID(dex_number)
      head_id = getHeadID(dex_number, body_id)
      shiny_directory = "Graphics/Battlers/Shiny/#{head_id}.#{body_id}"
      shiny_file_path = "#{shiny_directory}/#{head_id}.#{body_id}"
      offsets = [SHINY_COLOR_OFFSETS[body_id], SHINY_COLOR_OFFSETS[head_id]]
    else
      shiny_directory = "Graphics/Battlers/Shiny/#{dex_number}"
      shiny_file_path = "#{shiny_directory}/#{dex_number}"
      offsets = [SHINY_COLOR_OFFSETS[dex_number]]
    end
    
    # Determine the destination folders
    shiny_file_path += "_bodyShiny" if bodyShiny
    shiny_file_path += "_headShiny" if headShiny
    shiny_file_path += ".png"
    if File.exist?(shiny_file_path)
      @bitmap.bitmap = Bitmap.new(shiny_file_path)
      return
    end
  

  
    offset = offsets.compact.max_by { |o| o.keys.count }
    return unless offset
    onetime = true
    offset.keys.each do |version|
      value = offset&.dig(version)
  
      if value.is_a?(String) && onetime
        onetime = false
        shiftCustomColors(GameData::Species.calculateCustomShinyHueOffset(dex_number, bodyShiny, headShiny))
        Dir.mkdir(shiny_directory) unless Dir.exist?(shiny_directory)
        @bitmap.bitmap.save_to_png(shiny_file_path)
      elsif !value.is_a?(String)
        shiftColors(GameData::Species.calculateShinyHueOffset(dex_number, bodyShiny, headShiny, version))
      end
    end
  end
  

  def [](index)
    @bitmap[index]
  end

  def width
    @bitmap.bitmap.width
  end

  def height
    @bitmap.bitmap.height
  end

  def length
    @bitmap.length
  end

  def each
    @bitmap.each { |item| yield item }
  end

  def bitmap
    @bitmap.bitmap
  end

  def bitmap=(bitmap)
    @bitmap.bitmap = bitmap
  end

  def currentIndex
    @bitmap.currentIndex
  end

  def totalFrames
    @bitmap.totalFrames
  end

  def disposed?
    @bitmap.disposed?
  end

  def update
    @bitmap.update
  end

  def dispose
    @bitmap.dispose
  end

  def deanimate
    @bitmap.deanimate
  end

  def copy
    @bitmap.copy
  end

  def scale_bitmap(scale)
    return if scale == 1
    new_width = @bitmap.bitmap.width * scale
    new_height = @bitmap.bitmap.height * scale

    destination_rect = Rect.new(0, 0, new_width, new_height)
    source_rect = Rect.new(0, 0, @bitmap.bitmap.width, @bitmap.bitmap.height)
    new_bitmap = Bitmap.new(new_width, new_height)
    new_bitmap.stretch_blt(
      destination_rect,
      @bitmap.bitmap,
      source_rect
    )
    @bitmap.bitmap = new_bitmap
  end

  # def mirror
  #   for x in 0..@bitmap.bitmap.width / 2
  #     for y in 0..@bitmap.bitmap.height - 2
  #       temp = @bitmap.bitmap.get_pixel(x, y)
  #       newPix = @bitmap.bitmap.get_pixel((@bitmap.bitmap.width - x), y)
  #
  #       @bitmap.bitmap.set_pixel(x, y, newPix)
  #       @bitmap.bitmap.set_pixel((@bitmap.bitmap.width - x), y, temp)
  #     end
  #   end
  # end

  def mirror
    @bitmap.bitmap
  end
end

#===============================================================================
#
#===============================================================================
class PngAnimatedBitmap
  attr_accessor :frames

  # Creates an animated bitmap from a PNG file.
  def initialize(dir, filename, hue = 0)
    @frames = []
    @currentFrame = 0
    @framecount = 0
    panorama = RPG::Cache.load_bitmap(dir, filename, hue)
    if filename[/^\[(\d+)(?:,(\d+))?\]/] # Starts with 1 or 2 numbers in brackets
      # File has a frame count
      numFrames = $1.to_i
      delay = $2.to_i
      delay = 10 if delay == 0
      raise "Invalid frame count in #{filename}" if numFrames <= 0
      raise "Invalid frame delay in #{filename}" if delay <= 0
      if panorama.width % numFrames != 0
        raise "Bitmap's width (#{panorama.width}) is not divisible by frame count: #{filename}"
      end
      @frameDelay = delay
      subWidth = panorama.width / numFrames
      for i in 0...numFrames
        subBitmap = BitmapWrapper.new(subWidth, panorama.height)
        subBitmap.blt(0, 0, panorama, Rect.new(subWidth * i, 0, subWidth, panorama.height))
        @frames.push(subBitmap)
      end
      panorama.dispose
    else
      @frames = [panorama]
    end
  end

  def [](index)
    return @frames[index]
  end

  def width
    self.bitmap.width
  end

  def height
    self.bitmap.height
  end

  def deanimate
    for i in 1...@frames.length
      @frames[i].dispose
    end
    @frames = [@frames[0]]
    @currentFrame = 0
    return @frames[0]
  end

  def bitmap
    return @frames[@currentFrame]
  end

  def currentIndex
    return @currentFrame
  end

  def frameDelay(_index)
    return @frameDelay
  end

  def length
    return @frames.length
  end

  def each
    @frames.each { |item| yield item }
  end

  def totalFrames
    return @frameDelay * @frames.length
  end

  def disposed?
    return @disposed
  end

  def update
    return if disposed?
    if @frames.length > 1
      @framecount += 1
      if @framecount >= @frameDelay
        @framecount = 0
        @currentFrame += 1
        @currentFrame %= @frames.length
      end
    end
  end

  def dispose
    if !@disposed
      @frames.each { |f| f.dispose }
    end
    @disposed = true
  end

  def copy
    x = self.clone
    x.frames = x.frames.clone
    for i in 0...x.frames.length
      x.frames[i] = x.frames[i].copy
    end
    return x
  end
end

#===============================================================================
#
#===============================================================================
class GifBitmap
  attr_accessor :bitmap
  attr_reader :loaded_from_cache
  # Creates a bitmap from a GIF file. Can also load non-animated bitmaps.
  def initialize(dir, filename, hue = 0)
    @bitmap = nil
    @disposed = false
    @loaded_from_cache = false
    filename = "" if !filename
    begin
      @bitmap = RPG::Cache.load_bitmap(dir, filename, hue)
      @loaded_from_cache = true
    rescue
      @bitmap = nil
    end
    @bitmap = BitmapWrapper.new(32, 32) if @bitmap.nil?
    @bitmap.play if @bitmap&.animated?
  end

  def [](_index)
    return @bitmap
  end

  def deanimate
    @bitmap&.goto_and_stop(0) if @bitmap&.animated?
    return @bitmap
  end

  def currentIndex
    return @bitmap&.current_frame || 0
  end

  def length
    return @bitmap&.frame_count || 1
  end

  def each
    yield @bitmap
  end

  def totalFrames
    f_rate = @bitmap.frame_rate
    f_rate = 1 if f_rate.nil? || f_rate == 0
    return (@bitmap) ? (@bitmap.frame_count / f_rate).floor : 1
  end

  def disposed?
    return @disposed
  end

  def width
    return @bitmap&.width || 0
  end

  def height
    return @bitmap&.height || 0
  end

  # Gifs are animated automatically by mkxp-z. This function does nothing.
  def update; end

  def dispose
    return if @disposed
    @bitmap.dispose
    @disposed = true
  end

  def copy
    x = self.clone
    x.bitmap = @bitmap.copy if @bitmap
    return x
  end
end

#===============================================================================
#
#===============================================================================
def pbGetTileBitmap(filename, tile_id, hue, width = 1, height = 1)
  return RPG::Cache.tileEx(filename, tile_id, hue, width, height) { |f|
           AnimatedBitmap.new("Graphics/Tilesets/" + filename).deanimate
         }
end

def pbGetTileset(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Tilesets/" + name, hue).deanimate
end

def pbGetAutotile(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Autotiles/" + name, hue).deanimate
end

def pbGetAnimation(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Animations/" + name, hue).deanimate
end
