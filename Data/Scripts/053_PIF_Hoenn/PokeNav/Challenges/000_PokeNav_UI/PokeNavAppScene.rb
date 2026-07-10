class PokeNavAppScene


  #--------------------------------------------------------------------------
  # Configuration (override in child classes)
  #--------------------------------------------------------------------------
  HEADER_HEIGHT = -6

  def display_mode
    return :LIST # :LIST or :GRID
  end

  def start_x
    return 60;
  end

  def start_y
    return 80;
  end

  def x_gap
    return 220;
  end

  def y_gap
    return 100;
  end

  def visible_rows
    return 4;
  end

  def cursor_x_offset
    return 0
  end

  def cursor_y_offset
    return 0
  end

  def header_path
    return "Graphics/Pictures/Pokegear/bg_header"
  end

  def bg_path
    return ""
  end

  def cursor_path
    return "Graphics/Pictures/Pokegear/icon_button"
  end

  def header_name
    return _INTL("PokeNav App")
  end

  def columns
    return (display_mode == :GRID) ? 2 : 1
  end

  def initialize
    @text_color_base = pbColor(:DARK_TEXT_MAIN_COLOR)
    @text_color_shadow = pbColor(:DARK_TEXT_SHADOW_COLOR)
    if isDarkMode
      @text_color_base, @text_color_shadow = @text_color_shadow, @text_color_base
    end
  end

  # buttons should be a list of PokeNavButton
  def pbStartScene(buttons = [])
    @buttons = buttons
    @index = 0
    @mode = display_mode
    @exiting = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    createBackground
    createHeader if use_header?

    @buttons.each_with_index do |b, i|
      b.viewport = @viewport
      b.z=1
      @sprites["button#{i}"] = b
    end
    if @buttons && !@buttons.empty?
      createCursor
      layoutButtons
    end
    init_graphics
    pbUpdateSpriteHash(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }

  end

  def init_graphics
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(bg_path)
    @sprites["bg"].z=0
  end

  def pbUpdate
    layoutButtons
    pbUpdateSpriteHash(@sprites)
  end

  def layoutButtons
    return if @exiting
    cols = columns
    rows_visible = visible_rows

    # Current selected row
    current_row = @index / cols

    # Scroll offset in rows
    scroll_row = 0
    if current_row >= rows_visible
      scroll_row = current_row - rows_visible + 1
    end

    scroll_pixels = scroll_row * y_gap

    @buttons.each_with_index do |btn, i|
      row = i / cols
      col = i % cols

      btn.x = start_x + col * x_gap
      btn.y = start_y + row * y_gap - scroll_pixels
      # Only show buttons fully within the scrollable content area, never over the header
      btn.visible = (btn.y >= start_y && btn.y <= Graphics.height)
      btn.selected = (i == @index)
    end
    updateCursor
    updateHeader(scroll_row)
  end

  def updateCursor
    cursor = @sprites["cursor"]
    return unless cursor
    return if @buttons.empty?

    btn = @buttons[@index]
    return unless btn

    cursor.x = btn.x + cursor_x_offset
    cursor.y = btn.y + cursor_y_offset
    cursor.visible = btn.visible
  end

  def set_cursor_visible(value)
    if @sprites["cursor"]
      @sprites["cursor"].visible = value
    end
  end


  def createCursor
    return unless cursor_path
    @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["cursor"].setBitmap(cursor_path)
    @sprites["cursor"].z = 100000
  end

  def createHeader
    @sprites["header"] = IconSprite.new(0, 0, @viewport)
    @sprites["header"].setBitmap(header_path)
    # Ensure header always renders above buttons and cursor
    @sprites["header"].z = 100001
  end

  def createBackground
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if isDarkMode
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_dark")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
  end

  def updateHeader(scroll_row)
    return unless use_header?
    return unless @sprites["header"]
  end

  def displayTextElements
    Kernel.pbClearText
    showHeaderName
  end

  def use_header?
    return true
  end



  def showHeaderName
    Kernel.pbDisplayText(header_name, Graphics.width/2 , HEADER_HEIGHT)
  end
  def pbScene
    loop do
      Graphics.update
      Input.update

      updateInput
      layoutButtons
      pbUpdateSpriteHash(@sprites)

      break if @exiting
    end
  end

  def updateInput
    cols = columns
    total = @buttons.length
    move_delay = 2
    if Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @exiting = true
      return
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      click(@buttons[@index]&.id)
    elsif Input.repeat?(Input::LEFT) && cols > 1
      move_index(-1)
      pbWait(move_delay)
    elsif Input.repeat?(Input::RIGHT) && cols > 1
      move_index(1)
      pbWait(move_delay)
    elsif Input.repeat?(Input::UP)
      move_index(-cols)
      pbWait(move_delay)
    elsif Input.repeat?(Input::DOWN)
      move_index(cols)
      pbWait(move_delay)
    end
  end

  def hover(button_id)
    @buttons[@index]&.hover
  end

  def click(button_id)
    @buttons[@index]&.click
  end
  def move_index(delta)
    echoln "old: #{@index}"

    return if @buttons.empty?
    pbPlayCursorSE
    @index = (@index + delta) % @buttons.length
    hover(@buttons[@index]&.id)
  end

  def move_to_index(index)
    return if @buttons.empty?
    pbPlayCursorSE
    @index = index
    echoln "new: #{@index}"

    hover(@buttons[@index]&.id)


  end

  def pbEndScene
    @exiting = true
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @buttons.each do |button|
      button.dispose
    end
    Kernel.pbClearText
    @viewport.dispose
  end
end