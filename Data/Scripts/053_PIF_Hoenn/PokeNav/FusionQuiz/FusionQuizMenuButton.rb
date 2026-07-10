class FusionQuizMenuButton < PokenavButton

  IMAGE_TEXT_GAP = 128
  DEFAULT_SPRITE_PATH = "000"
  IMAGE_X_OFFSET = 32
  SOURCE_IMAGE_Y_CROP = 24

  ICON_SIZE = 24
  ICON_X_MARGIN = 8
  ICON_GAP = 4

  def initialize(id, icon = nil, text = nil, viewport = nil)
    super
    @text_color = pbColor(:LIGHT_TEXT_MAIN_COLOR)
    @shadow_color = pbColor(:LIGHT_TEXT_SHADOW_COLOR)
  end
  def get_width
    return 180
  end

  def get_height
    return 52
  end

  def text_padding
    return 40
  end

  def text_alignment
    return 1 #Centered
  end
  def background_image
    return "Graphics/Pictures/Pokegear/FusionQuiz/icon_button"
  end
end