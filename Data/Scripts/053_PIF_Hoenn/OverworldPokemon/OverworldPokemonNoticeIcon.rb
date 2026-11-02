class OverworldNoticeIcon < Sprite
  DEFAULT_PATH = "Graphics/Pictures/Overworld/notice_icon"
  Y_OFFSET     = -12
  BOB_RANGE    = 1

  def initialize(event, behavior = nil)
    viewport = ($scene.spriteset.viewport1 rescue nil)
    super(viewport)
    @event = event
    @frame = 0
    @char_height = 32
    self.bitmap = load_icon_bitmap(behavior)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    refresh_character_height
    update
  end

  def load_icon_bitmap(behavior)
    path = pbResolveBitmap("Graphics/Pictures/Overworld/notice_#{behavior}") if behavior
    path ||= pbResolveBitmap(DEFAULT_PATH)
    return Bitmap.new(path) if path
    return nil
  end

  def refresh_character_height
    return unless $scene.respond_to?(:spriteset) && $scene.spriteset
    spr = $scene.spriteset.character_sprites.find { |s| s.character == @event }
    @char_height = spr.oy if spr && spr.oy > 0
  end

  def update
    return if disposed?
    @frame += 1
    refresh_character_height if @frame % 10 == 0
    bob = BOB_RANGE > 0 ? (Math.sin(@frame / 8.0) * BOB_RANGE).round : 0
    self.x = @event.screen_x
    self.y = @event.screen_y - @char_height - Y_OFFSET + bob
    self.z = @event.screen_z + 100
    self.opacity = @event.opacity
  end

  def dispose
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    super
  end
end