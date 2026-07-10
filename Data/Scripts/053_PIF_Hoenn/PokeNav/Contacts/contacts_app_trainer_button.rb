class ContactsAppTrainerButton < PokenavButton
  IMAGE_TEXT_GAP = 128
  DEFAULT_SPRITE_PATH = "000"
  IMAGE_X_OFFSET = 32
  SOURCE_IMAGE_Y_CROP = 24

  ICON_SIZE = 24
  ICON_X_MARGIN = 8
  ICON_GAP = 4

  TRADE_AVAILABLE_ICON = "Graphics/Pictures/Pokegear/Trainers/tradeIcon"
  IS_NEW_ICON = "Graphics/Pictures/Pokegear/Trainers/dialogIcon"
  ICON_X_OFFSET = -20
  FADE_SPEED = 16


  def get_width
    return Graphics.width-72
  end

  def get_height
    return 56
  end

  def background_image
    if isDarkMode
      return "Graphics/Pictures/Pokegear/Trainers/trainer_list_button_dark.png"
    else
      return "Graphics/Pictures/Pokegear/Trainers/trainer_list_button.png"
    end
  end

  def set_trade_available(value)
    @is_trade_available = value
    create_icon_sprites
  end

  def set_new(value)
    @is_new = value
    create_icon_sprites
  end


  def initialize(id, image = nil, text = nil, viewport = nil)
    @image_path = image
    @image_path = DEFAULT_SPRITE_PATH if @image_path.nil?
    super(id, nil, text, viewport)
    @is_trade_available = false
    @is_new = false
    refresh
  end

  def viewport=(vp)
    super(vp)
    create_image_sprite
    create_icon_sprites
  end

  def create_image_sprite
    return unless @image_path && self.viewport
    @image_sprite = IconSprite.new(0, 0, self.viewport)
    if @id == BATTLED_TRAINER_RIVAL_KEY
      rival_bitmap = AnimatedBitmap.new(getBaseOverworldSpriteFilename())
      rival_bitmap.bitmap = generateNPCClothedBitmapStatic($Trainer.rival_appearance)
      @image_sprite.setBitmapDirectly(rival_bitmap)
    else
      @image_sprite.setBitmap("Graphics/Characters/#{@image_path}")
    end
    frame_w = (@image_sprite.bitmap.width / 4).round
    frame_h = (@image_sprite.bitmap.height / 4).round

    @image_sprite.src_rect.width  = frame_w
    @image_sprite.src_rect.height = [frame_h - SOURCE_IMAGE_Y_CROP, get_height].min
    @image_sprite.src_rect.x = 16
    @image_sprite.src_rect.y = 16
    @image_sprite.z = self.z + 1
  end

  def create_icon_sprites
    return unless self.viewport
    @icon_sprites&.each(&:dispose)
    @icon_sprites = []
    icons = []
    icons << TRADE_AVAILABLE_ICON if @is_trade_available
    icons << IS_NEW_ICON if @is_new
    icons.each do |path|
      sprite = IconSprite.new(0, 0, self.viewport)
      sprite.setBitmap(path)
      sprite.z = self.z + 1
      @icon_sprites << sprite
    end
    update_icon_positions
  end

  def update_icon_positions
    return unless @icon_sprites
    right_edge = (self.x || 0) + get_width - ICON_X_MARGIN
    @icon_sprites.each_with_index do |sprite, i|
      sprite.x = right_edge - ICON_SIZE - (i * (ICON_SIZE + ICON_GAP)) + ICON_X_OFFSET
      sprite.y = (self.y || 0) + (get_height - ICON_SIZE) / 2
      sprite.visible = self.visible
    end
  end

  def hover
    if @is_new
      $Trainer.pokenav.viewed_trainers << @id
      @is_new = false
      @fading_new_icon = @icon_sprites.last  # IS_NEW_ICON is last in array
    end
    super
  end

  def update
    return unless @fading_new_icon
    @fading_new_icon.opacity -= FADE_SPEED
    if @fading_new_icon.opacity <= 0
      @fading_new_icon.dispose
      @icon_sprites.delete(@fading_new_icon)
      @fading_new_icon = nil
      update_icon_positions  # reflow remaining icons
    end
  end



  def x=(value)
    super
    @image_sprite&.x = value + IMAGE_X_OFFSET
    update_icon_positions
  end

  def y=(value)
    super
    frame_h = @image_sprite ? @image_sprite.src_rect.height : 0
    @image_sprite&.y = value + (get_height - frame_h) / 2 - 8
    update_icon_positions
  end

  def visible=(value)
    super
    @image_sprite&.visible = value
    @icon_sprites&.each { |s| s.visible = value }
  end

  def dispose
    @image_sprite&.dispose
    @icon_sprites&.each(&:dispose)
    super
  end

  def draw_text(x_offset = 0)
    return unless self.bitmap && @text && @text != ""
    frame_w = @image_sprite ? @image_sprite.src_rect.width : 0
    text_x = IMAGE_TEXT_GAP
    max_width = self.bitmap.width - text_x

    lines = wrap_text(@text, self.bitmap, max_width)

    lines.each_with_index do |line, i|
      y_pos = (get_height / 2) - (LINE_HEIGHT * lines.size / 2) + (LINE_HEIGHT * i)
      self.bitmap.font.color = @shadow_color
      self.bitmap.draw_text(text_x + 1, y_pos + 1, max_width, LINE_HEIGHT, line)
      self.bitmap.font.color = @text_color
      self.bitmap.draw_text(text_x, y_pos, max_width, LINE_HEIGHT, line)
    end
  end
end