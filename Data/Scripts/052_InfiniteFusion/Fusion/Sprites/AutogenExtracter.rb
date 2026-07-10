class AutogenExtracter < PIFSpriteExtracter
  SPRITESHEET_FOLDER_PATH = "Graphics\\Battlers\\spritesheets_autogen\\"
  SPRITE_SIZE = 96 # Size of each sprite in the spritesheet
  COLUMNS = 10 # Number of columns in the spritesheet
  SHEET_WIDTH = SPRITE_SIZE * COLUMNS # 2880 pixels wide spritesheet

  @instance = new
  def self.instance
    @@instance ||= new # If @@instance is nil, create a new instance
    @@instance # Return the existing or new instance
  end

  def load_bitmap_from_spritesheet(pif_sprite)
    body_id = pif_sprite.body_id
    spritesheet_file = getSpritesheetPath(pif_sprite)
    spritesheet_bitmap = AnimatedBitmap.new(spritesheet_file).bitmap

    # Extract individual sprite
    sprite_x_position, sprite_y_position = get_sprite_position_on_spritesheet(body_id, SPRITE_SIZE, COLUMNS)
    src_rect = Rect.new(sprite_x_position, sprite_y_position, SPRITE_SIZE, SPRITE_SIZE)

    bitmap = Bitmap.new(SPRITE_SIZE, SPRITE_SIZE)
    bitmap.blt(0, 0, spritesheet_bitmap, src_rect)

    # Dispose of spritesheet if it's no longer needed
    spritesheet_bitmap.dispose
    return bitmap
  end

  def getSpritesheetPath(pif_sprite)
    head_id = pif_sprite.head_id
    return getSpritesheetPathFromId(head_id)
  end

  def getSpritesheetPathFromId(head_id)
    filename = head_id.to_s + ".png"
    return "#{SPRITESHEET_FOLDER_PATH}#{filename}"
  end

  def get_resize_scale
    return 3
  end
  #
  #   # Check cache before loading from disk
  #   sprite_bitmap = @@spritesheet_cache.fetch(pif_sprite) do
  #     # Load spritesheet from disk if necessary
  #     echoln "Loading spritesheet from disk: #{spritesheet_file}"
  #     spritesheet_bitmap = AnimatedBitmap.new(spritesheet_file).bitmap
  #
  #     # Extract individual sprite
  #     sprite_x_position, sprite_y_position = get_sprite_position_on_spritesheet(body_id, SPRITE_SIZE, COLUMNS)
  #     src_rect = Rect.new(sprite_x_position, sprite_y_position, SPRITE_SIZE, SPRITE_SIZE)
  #
  #     sprite = Bitmap.new(SPRITE_SIZE, SPRITE_SIZE)
  #     sprite.blt(0, 0, spritesheet_bitmap, src_rect)
  #
  #     # Dispose of spritesheet if it's no longer needed
  #     spritesheet_bitmap.dispose
  #
  #     sprite
  #   end
  #   animatedBitmap = AnimatedBitmap.from_bitmap(sprite_bitmap)
  #
  #   end_time = Time.now
  #   echoln "finished load sprite in  #{end_time - start_time} seconds"
  #   echoln animatedBitmap
  #   return animatedBitmap
  # end

  def load_sprite_with_spritesheet_cache(pif_sprite)
    start_time = Time.now
    head_id = pif_sprite.head_id
    body_id = pif_sprite.body_id
    spritesheet_file = getSpritesheetPathFromId(head_id)

    # Check cache before loading from disk
    spritesheet_bitmap = @@spritesheet_cache.fetch(spritesheet_file) do
      echoln "Loading spritesheet from disk: #{spritesheet_file}"
      AnimatedBitmap.new(spritesheet_file).bitmap
    end

    sprite_x_position, sprite_y_position = get_sprite_position_on_spritesheet(body_id, SPRITE_SIZE, COLUMNS)
    src_rect = Rect.new(sprite_x_position, sprite_y_position, SPRITE_SIZE, SPRITE_SIZE)

    sprite_bitmap = Bitmap.new(SPRITE_SIZE, SPRITE_SIZE)
    sprite_bitmap.blt(0, 0, spritesheet_bitmap, src_rect)

    #spritesheet_bitmap.dispose  # Dispose since not needed

    animatedBitmap = AnimatedBitmap.from_bitmap(sprite_bitmap)

    end_time = Time.now
    echoln "finished load sprite in  #{end_time - start_time} seconds"

    return animatedBitmap
  end
end

# def extract_bitmap_to_file(head_id, body_id, folder)
#   # Create the directory if it doesn't exist
#   Dir.mkdir(folder) unless Dir.exist?(folder)
#
#   # Load the entire spritesheet
#   spritesheet_file = "#{SPRITESHEET_FOLDER_PATH}#{head_id}.png"
#   spritesheet_bitmap = AnimatedBitmap.new(spritesheet_file).bitmap
#
#   # Calculate the 0-based row and column from the sprite index
#   zero_index = body_id - 1
#   row = zero_index / COLUMNS
#   col = zero_index % COLUMNS
#
#   # Define the area of the sprite on the spritesheet
#   sprite_x_position = col * SPRITE_SIZE
#   sprite_y_position = row * SPRITE_SIZE
#
#   # Create a new bitmap for the single sprite
#   single_sprite_bitmap = Bitmap.new(SPRITE_SIZE, SPRITE_SIZE)
#   single_sprite_bitmap.blt(0, 0, spritesheet_bitmap, Rect.new(sprite_x_position, sprite_y_position, SPRITE_SIZE, SPRITE_SIZE))
#
#   # Dispose of the spritesheet bitmap if it’s no longer needed
#   spritesheet_bitmap.dispose
#
#   # Save the single sprite bitmap to a file
#   file_path = "#{folder}/#{head_id}.#{body_id}.png"
#   single_sprite_bitmap.save_to_png(file_path)
#
#   # Dispose of the single sprite bitmap
#   single_sprite_bitmap.dispose
#
#   # Return the path to the saved PNG file
#   return file_path
# end
#end
#
#
# class SpritesBitmapCache
#   @@cache = {} # Cache storage for individual sprites
#   @@usage_order = [] # Tracks usage order for LRU eviction
#
#   def self.fetch(pif_sprite)
#     sprite_key = "B#{pif_sprite.body_id}H#{pif_sprite.head_id}".to_sym
#     if @@cache.key?(sprite_key)
#       # Move key to the end to mark it as recently used
#       @@usage_order.delete(sprite_key)
#       @@usage_order << sprite_key
#       return @@cache[sprite_key]
#     end
#
#     # Load sprite via block if not found in cache
#     sprite_bitmap = yield
#
#     if @@cache.size >= Settings::SPRITE_CACHE_MAX_NB
#       # Evict least recently used (first in order)
#       oldest_key = @@usage_order.shift
#       @@cache.delete(oldest_key)
#       echoln "Evicted: #{oldest_key} from sprite cache"
#     end
#
#     # Add new sprite to cache and track its usage
#     @@cache[sprite_key] = sprite_bitmap
#     @@usage_order << sprite_key
#     sprite_bitmap
#     echoln @@cache
#   end
# end