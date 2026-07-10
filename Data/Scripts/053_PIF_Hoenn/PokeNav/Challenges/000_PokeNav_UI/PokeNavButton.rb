#===============================================================================
#
#===============================================================================
class PokenavButton < SpriteWrapper
  DESC_Y = 10
  LINE_HEIGHT = 22
  REWARD_LINE = DESC_Y + LINE_HEIGHT * 2

  attr_reader :id

  attr_accessor :height
  attr_accessor :width
  attr_accessor :image_path
  attr_accessor :icon_bitmap
  attr_accessor :x
  attr_accessor :y
  attr_accessor :crop_width
  attr_accessor :crop_height

  attr_accessor :text_color
  attr_accessor :shadow_color

  DEFAULT_WIDTH = 200
  DEFAULT_HEIGHT = 40

  def initialize(id, icon = nil, text = nil, viewport = nil)
    super(viewport)

    @id = id
    @selected = false
    @text = text || get_text
    @crop_width = nil
    @crop_height = nil

    @text_color = pbColor(:DARK_TEXT_MAIN_COLOR)
    @shadow_color = pbColor(:DARK_TEXT_SHADOW_COLOR)
    @text_padding = text_padding
    if isDarkMode
      @text_color, @shadow_color = @shadow_color, @text_color
    end
    @bg = IconSprite.new(0, 0, @viewport)
    @bg.setBitmap(background_image)
    @bg.z = self.z - 1
    # Determine source bitmap
    if icon.is_a?(String)
      @icon_bitmap = AnimatedBitmap.new(icon)
      bmp = @icon_bitmap.bitmap
    elsif icon.is_a?(AnimatedBitmap)
      @icon_bitmap = icon
      bmp = icon.bitmap
    elsif icon.is_a?(Bitmap)
      bmp = icon
    else
      bmp = nil
    end

    # Create display bitmap
    if bmp
      self.bitmap = Bitmap.new(bmp.width, bmp.height)
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    else
      create_empty_bitmap
    end
    refresh
  end

  def text_alignment
    return 0 #Left
    #1 for centered
  end

  def text_padding
    return 4
  end
  def viewport=(vp)
    super(vp)
    @bg&.dispose
    @bg = IconSprite.new(0, 0, vp)
    @bg.setBitmap(background_image)
    @bg.z = self.z - 1
    create_empty_bitmap if self.bitmap.nil?
    refresh
  end

  def background_image
    return ""
  end

  def create_empty_bitmap
    self.bitmap = Bitmap.new(get_width, get_height)
    pbSetSystemFont(self.bitmap)

    # Draw background image directly onto bitmap
    bg_path = background_image
    if bg_path && bg_path != ""
      bg_bmp = AnimatedBitmap.new(bg_path).bitmap
      self.bitmap.stretch_blt(
        Rect.new(0, 0, get_width, get_height),
        bg_bmp,
        Rect.new(0, 0, bg_bmp.width, bg_bmp.height)
      )
    end
  end


  def x=(value)
    @x = value
    super(value)
    @bg.x = value if @bg
  end

  def y=(value)
    @y = value
    super(value)
    @bg.y = value if @bg
  end

  def z=(value)
    super(value)
    @bg.z = value - 1 if @bg
  end

  def get_height
    return DEFAULT_HEIGHT
  end

  def get_width
    return DEFAULT_WIDTH
  end

  def get_default_image_path
    return ""
  end

  def get_text
    return ""
  end

  def dispose
    dispose_graphics
    super
  end

  def dispose_graphics
    @icon_bitmap.dispose if @icon_bitmap
    @bg.dispose if @bg
    @icon_bitmap = nil
    @bg =nil
  end

  def click
    echoln "clicked #{@id}"
  end

  def hover
    echoln "hovering over #{@id}"
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    return unless self.bitmap
    self.bitmap.clear

    # Redraw background
    bg_path = background_image
    if bg_path && bg_path != ""
      bg_bmp = AnimatedBitmap.new(bg_path).bitmap
      self.bitmap.stretch_blt(
        Rect.new(0, 0, self.bitmap.width, self.bitmap.height),
        bg_bmp,
        Rect.new(0, 0, bg_bmp.width, bg_bmp.height)
      )
    end

    if @icon_bitmap
      bmp = @icon_bitmap.bitmap
      width = @crop_width || bmp.width
      height = @crop_height || bmp.height
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, width, height))
    end

    draw_text if @text && @text != ""
  end

  def draw_text
    return unless self.bitmap && @text && @text != ""
    padding = @text_padding
    max_width = self.bitmap.width - (padding * 2)

    lines = wrap_text(@text, self.bitmap, max_width)

    total_text_height = lines.length * LINE_HEIGHT
    start_y = (self.bitmap.height - total_text_height) / 2

    lines.each_with_index do |line, i|
      y_pos = start_y + (LINE_HEIGHT * i)
      self.bitmap.font.color = @shadow_color
      self.bitmap.draw_text(padding + 1, y_pos + 1, max_width, LINE_HEIGHT, line, text_alignment)
      self.bitmap.font.color = @text_color
      self.bitmap.draw_text(padding, y_pos, max_width, LINE_HEIGHT, line, text_alignment)
    end
  end

end
