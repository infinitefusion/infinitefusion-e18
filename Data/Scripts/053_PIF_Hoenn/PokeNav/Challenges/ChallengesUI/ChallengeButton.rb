#===============================================================================
#
#===============================================================================
class ChallengeButton < SpriteWrapper
  attr_reader :challenge
  attr_reader :selected
  attr_reader :can_claim_reward

  DESC_Y      = 10
  LINE_HEIGHT = 22
  REWARD_LINE = DESC_Y + LINE_HEIGHT * 2

  def initialize(challenge, x, y, viewport=nil)
    super(viewport)
    @challenge = challenge
    @can_claim_reward = @challenge.completed

    @selected = false

    graphics_completed = "Graphics/Pictures/Challenges/button_complete_#{@challenge.category.to_s}"
    graphics_incompleted = "Graphics/Pictures/Challenges/button_incomplete_#{@challenge.category.to_s}"

    image_path = @can_claim_reward ?  graphics_completed : graphics_incompleted
    @cursor = AnimatedBitmap.new(image_path)
    @contents = BitmapWrapper.new(@cursor.width, @cursor.height)
    self.bitmap = @contents
    self.x = x
    self.y = y

    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @cursor.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear

    # Draw background
    rect = Rect.new(0, 0, @cursor.width, @cursor.height / 2)
    rect.y = @cursor.height / 2 if @selected
    self.bitmap.blt(0, 0, @cursor.bitmap, rect)

    # Text colors
    text_color   = @can_claim_reward ? Color.new(0,255,0) : Color.new(248,248,248)
    shadow_color = Color.new(40,40,40)

    # Description text
    desc_lines = wrap_text(@challenge.description, @contents, @cursor.width - 40)[0, 2]
    textpos = []
    y_offset = DESC_Y
    desc_lines.each do |line|
      textpos << [line, 10, y_offset, 0, text_color, shadow_color, false]
      y_offset += LINE_HEIGHT
    end

    reward_y = REWARD_LINE
    reward_text = @can_claim_reward ? _INTL("Collect") : _INTL("Reward")
    claim_color = @can_claim_reward ? Color.new(80, 220, 255) : Color.new(255, 215, 120)

    textpos << [
      "#{reward_text} $#{@challenge.money_reward}",
      10, reward_y, 0,
      claim_color, shadow_color, false
    ]

    pbDrawTextPositions(self.bitmap, textpos)

    # --------------------------------------------------
    # Draw item reward icons
    # --------------------------------------------------
    return if !@challenge.item_reward || @challenge.item_reward.empty?

    icon_x = 170          # starting X (adjust to taste)
    icon_y = reward_y #- 4 # align with text nicely
    icon_size = 48
    icon_gap = 8

    @challenge.item_reward.each do |item|
      icon_path = GameData::Item.icon_filename(item)
      next if !icon_path

      icon = Bitmap.new(icon_path)
      src_rect = Rect.new(0, 0, icon.width, icon.height)

      self.bitmap.stretch_blt(
        Rect.new(icon_x, icon_y, icon_size, icon_size),
        icon,
        src_rect
      )

      icon.dispose
      icon_x += icon_size + icon_gap
    end
  end


  # Helper method to wrap text into multiple lines
  def wrap_text(text, bitmap, max_width)
    words = text.split(" ")
    lines = []
    line = ""
    words.each do |word|
      test_line = line.empty? ? word : "#{line} #{word}"
      if bitmap.text_size(test_line).width > max_width
        lines << line
        line = word
      else
        line = test_line
      end
    end
    lines << line unless line.empty?
    return lines
  end



end
