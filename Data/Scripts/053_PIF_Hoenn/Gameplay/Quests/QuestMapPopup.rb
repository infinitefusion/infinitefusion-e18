#==============================================================================
# QuestMapPopup - Side panel listing quests at a map location
#==============================================================================
class QuestMapPopup
  attr_reader :quests
  attr_reader :panel_active
  attr_reader :disposed

  PANEL_WIDTH  = 260 #220
  PANEL_HEIGHT = 320
  ITEM_HEIGHT  = 52
  MAX_VISIBLE  = 5
  FADE_SPEED   = 40

  OPACITY_SELECTED = 255
  OPACITY_UNSELECTED=200
  def initialize(quests, on_left, viewport, location_name = _INTL("Unknown Location"))
    @quests   = quests.sort_by { |q| q.type == :MAIN_QUEST ? 0 : 1 }
    @on_left  = on_left
    @viewport = viewport
    @index    = 0
    @scroll   = 0   # index of topmost visible quest
    @scroll_timer = 0
    @scroll_delay = 6
    @sprites  = {}
    @location_name = location_name
    create_sprites
    animate_in
  end

  def selected_quest
    @quests[@index]
  end

  def run
    set_selected(true)
    refresh
    loop do
      break if @disposed
      Graphics.update
      Input.update
      animate_arrows

      if Input.trigger?(Input::B)
        animate_out
        dispose
        set_selected(false)
        Input.update
        return nil
      end

      if Input.trigger?(Input::C)
        animate_out
        dispose
        return @quests[@index]
      end

      if @scroll_timer > 0
        @scroll_timer -= 1
      else
        if Input.press?(Input::DOWN)
          move(:DOWN)
          @scroll_timer = @scroll_delay
        elsif Input.press?(Input::UP)
          move(:UP)
          @scroll_timer = @scroll_delay
        end
      end
    end
  end



  def panel_x
    @on_left ? 8 : (Graphics.width - PANEL_WIDTH - 8)
  end

  def create_sprites
    @sprites["panel"] = IconSprite.new(0, 0, @viewport)
    @sprites["panel"].setBitmap("Graphics/Pictures/map/quests_panel")
    @sprites["panel"].x = panel_x
    @sprites["panel"].y = (Graphics.height - PANEL_HEIGHT) / 2
    @sprites["panel"].z = 110000
    @sprites["panel"].opacity = 0

    # Overlay bitmap for text
    @sprites["text"] = BitmapSprite.new(PANEL_WIDTH, PANEL_HEIGHT, @viewport)
    @sprites["text"].x = panel_x
    @sprites["text"].y = (Graphics.height - PANEL_HEIGHT) / 2
    @sprites["text"].z = 110001
    @sprites["text"].opacity = 0
    pbSetSystemFont(@sprites["text"].bitmap)

    # Quest row sprites (buttons)
    MAX_VISIBLE.times do |i|
      # Background image sprite (selected / unselected)
      bg = IconSprite.new(0, 0, @viewport)
      bg.x = panel_x + 6
      bg.y = (Graphics.height - PANEL_HEIGHT) / 2 + 36 + i * ITEM_HEIGHT
      bg.z = 110002
      bg.opacity = 0
      @sprites["rowbg#{i}"] = bg

      # Text/icon overlay bitmap
      s = BitmapSprite.new(PANEL_WIDTH - 12, ITEM_HEIGHT - 4, @viewport)
      pbSetSystemFont(s.bitmap)
      s.x = panel_x + 6
      s.y = (Graphics.height - PANEL_HEIGHT) / 2 + 36 + i * ITEM_HEIGHT
      s.z = 110003
      s.opacity = 0
      @sprites["row#{i}"] = s
    end

    # Character icon sprites for each visible row
    MAX_VISIBLE.times do |i|
      ic = IconSprite.new(0, 0, @viewport)
      ic.z = 110003
      ic.opacity = 0
      @sprites["icon#{i}"] = ic
    end

    # Up/down arrows
    panel_top_y = (Graphics.height - PANEL_HEIGHT) / 2
    create_arrow("uparrow",panel_top_y - 30)
    create_arrow("downarrow",panel_top_y + PANEL_HEIGHT - 46)
    refresh
  end


  def create_arrow(arrow_filename, y_position)
    panel_center_x = panel_x + PANEL_WIDTH / 2

    @sprites[arrow_filename] = AnimatedSprite.new("Graphics/Pictures/#{arrow_filename}", 8, 28, 40, 2, @viewport)
    @sprites[arrow_filename].x = panel_center_x - 8
    @sprites[arrow_filename].y = y_position
    @sprites[arrow_filename].visible = false
    @sprites[arrow_filename].z = @sprites["panel"].z+1
  end

  def refresh
    return unless @sprites["text"]
    text_bmp = @sprites["text"].bitmap
    text_bmp.clear
    pbDrawOutlineText(text_bmp, 0, 6, PANEL_WIDTH, 32, _INTL("{1} Quests", @location_name),
                      Color.new(255, 220, 100), Color.new(0, 0, 0), 1)

    MAX_VISIBLE.times do |i|
      qi = @scroll + i
      row_bmp = @sprites["row#{i}"].bitmap
      row_bmp.clear

      if qi < @quests.size
        quest    = @quests[qi]
        selected = (qi == @index) && @panel_active
        if quest.type == :MAIN_QUEST
          bg_path = "Graphics/Pictures/map/quests_row_main"
        else
          bg_path = "Graphics/Pictures/map/quests_row"
        end
        bg_path = selected \
                    ? "#{bg_path}_selected"
                    : "#{bg_path}_unselected"
        @sprites["rowbg#{i}"].setBitmap(bg_path)
        @sprites["rowbg#{i}"].visible = true

        # Quest name text (no background drawing needed here anymore)
        pbDrawOutlineText(row_bmp, 44, 8, row_bmp.width - 44, row_bmp.height,
                          quest.name, quest.default_color, Color.new(0, 0, 0))

        # Character icon
        icon = @sprites["icon#{i}"]
        begin
          icon.setBitmap("Graphics/Characters/#{quest.sprite}")
          icon.src_rect.width  = (icon.bitmap.width  / 4).round
          icon.src_rect.height = (icon.bitmap.height / 4).round - 16
          icon.src_rect.x = 0
          icon.src_rect.y = 0
          icon.x = panel_x - 16
          icon.y = (Graphics.height - PANEL_HEIGHT) / 2 + 16 + i * ITEM_HEIGHT
          icon.visible = true
        rescue
          icon.visible = false
        end
      else
        @sprites["rowbg#{i}"].visible = false
        @sprites["icon#{i}"].visible  = false
      end
    end

    @sprites["uparrow"].visible   = @scroll > 0             if @sprites["uparrow"]
    @sprites["downarrow"].visible = (@scroll + MAX_VISIBLE) < @quests.size if @sprites["downarrow"]
  end


  def move(dir)
    if dir == :DOWN
      return if @index >= @quests.size - 1
      @index += 1
      if @index >= @scroll + MAX_VISIBLE
        @scroll += 1
      end
    else
      return if @index <= 0
      @index -= 1
      if @index < @scroll
        @scroll -= 1
      end
    end
    refresh
  end

  def animate_in
    @sprites["panel"].opacity = OPACITY_UNSELECTED
    MAX_VISIBLE.times do |j|
      @sprites["rowbg#{j}"].opacity = OPACITY_UNSELECTED
      @sprites["row#{j}"].opacity   = OPACITY_UNSELECTED
      @sprites["icon#{j}"].opacity  = OPACITY_UNSELECTED
    end

    # 12.times do |i|
    #   Graphics.update
    #   alpha_step = FADE_SPEED
    #   if i < 8
    #     @sprites["panel"].opacity = [@sprites["panel"].opacity + alpha_step, OPACITY_UNSELECTED].min
    #   end
    #   if i > 2
    #     @sprites["text"].opacity = [@sprites["text"].opacity + alpha_step, OPACITY_UNSELECTED].min
    #     MAX_VISIBLE.times do |j|
    #       @sprites["rowbg#{j}"].opacity = [@sprites["rowbg#{j}"].opacity + alpha_step, OPACITY_UNSELECTED].min
    #       @sprites["row#{j}"].opacity   = [@sprites["row#{j}"].opacity   + alpha_step, OPACITY_UNSELECTED].min
    #       @sprites["icon#{j}"].opacity  = [@sprites["icon#{j}"].opacity  + alpha_step, OPACITY_UNSELECTED].min
    #     end
    #   end
    # end
  end
  def set_selected(selected)
    @panel_active = selected
    target = selected ? OPACITY_SELECTED : OPACITY_UNSELECTED
    @sprites["panel"]&.opacity = target
    @sprites["text"]&.opacity  = target
    MAX_VISIBLE.times do |j|
      @sprites["rowbg#{j}"]&.opacity = target
      @sprites["row#{j}"]&.opacity   = target
      @sprites["icon#{j}"]&.opacity  = target
    end
    @sprites["uparrow"]&.visible  = true
    @sprites["downarrow"]&.visible = true
  end

  def animate_out
    @disposed = true
    @sprites["uparrow"]&.visible  = false
    @sprites["downarrow"]&.visible = false
    8.times do
      Graphics.update
      @sprites["panel"]&.opacity -= FADE_SPEED
      @sprites["text"]&.opacity  -= FADE_SPEED
      MAX_VISIBLE.times do |j|
        @sprites["rowbg#{j}"]&.opacity -= FADE_SPEED
        @sprites["row#{j}"]&.opacity   -= FADE_SPEED
        @sprites["icon#{j}"]&.opacity  -= FADE_SPEED
      end
    end
  end

  @arrow_frame = 0
  def animate_arrows
    @sprites["uparrow"].visible=true
    @sprites["downarrow"].visible=true
    @sprites["uparrow"].play
    @sprites["downarrow"].play
  end

  def dispose
    @sprites.each_value { |s| s.dispose rescue nil }
    @sprites.clear
  end
end
