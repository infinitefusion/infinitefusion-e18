class ColorCodeDoor
  COLS = 2
  ROWS = 3
  ORIGIN_X = 70
  ORIGIN_Y = 20
  STEP_X = 60
  STEP_Y = 40

  CURSOR_OFFSET_X = -6
  CURSOR_OFFSET_Y = -6

  # Confirm button position — centered below the grid
  CONFIRM_X = 70
  CONFIRM_Y = 140

  COLOR_ORDER = ["R", "B", "G", "Y"]

  COLOR_BITMAPS = {
    "R" => "Graphics/Pictures/Puzzles/codeDoor_red",
    "B" => "Graphics/Pictures/Puzzles/codeDoor_blue",
    "G" => "Graphics/Pictures/Puzzles/codeDoor_green",
    "Y" => "Graphics/Pictures/Puzzles/codeDoor_yellow",
  }

  # Total selectable positions: 6 color cells + 1 confirm button
  CONFIRM_INDEX = COLS * ROWS  # = 6

  def initialize(codeVariable)
    @codeVariable = codeVariable
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @cursor_index = 0
    @confirmed = false

    current_code = pbGet(@codeVariable)
    current_code = "RRRRRR" unless current_code.is_a?(String) && current_code.length == 6
    @current_code = current_code.chars  # store as array for easy per-index mutation

    @options = Array.new(COLS * ROWS) do |i|
      col = i / ROWS
      row = i % ROWS
      x = ORIGIN_X + col * STEP_X
      y = ORIGIN_Y + row * STEP_Y
      sprite = IconSprite.new(x, y, @viewport)
      sprite.setBitmap(COLOR_BITMAPS[@current_code[i]])
      sprite
    end

    @confirm_button = IconSprite.new(CONFIRM_X, CONFIRM_Y, @viewport)
    @confirm_button.setBitmap("Graphics/Pictures/Puzzles/confirm")

    @cursor = IconSprite.new(0, 0, @viewport)
    @cursor.setBitmap("Graphics/Pictures/Puzzles/cursor")
    update_cursor
  end

  def inputColorCode
    loop do
      Graphics.update
      Input.update
      handle_input

      if @confirmed
        code = @current_code.join
        pbSet(@codeVariable, code)
        return code
      end

      break if Input.trigger?(Input::B)
    end
    return @current_code.join  # cancelled
  ensure
    dispose
  end

  private

  def handle_input
    moved = false

    if Input.trigger?(Input::RIGHT)
      if @cursor_index < CONFIRM_INDEX  # don't move right from confirm
        @cursor_index = (@cursor_index + ROWS) % (COLS * ROWS)
        moved = true
      end
    elsif Input.trigger?(Input::LEFT)
      if @cursor_index < CONFIRM_INDEX  # don't move left from confirm
        @cursor_index = (@cursor_index - ROWS) % (COLS * ROWS)
        moved = true
      end
    elsif Input.trigger?(Input::DOWN)
      if @cursor_index == CONFIRM_INDEX
        # wrap from confirm back to top row
        @cursor_index = @cursor_index % ROWS  # keeps same column as before; just go to row 0 left col
        moved = true
      else
        col = @cursor_index / ROWS
        row = @cursor_index % ROWS
        if row == ROWS - 1
          # bottom of column -> go to confirm
          @cursor_index = CONFIRM_INDEX
        else
          @cursor_index = col * ROWS + (row + 1)
        end
        moved = true
      end
    elsif Input.trigger?(Input::UP)
      if @cursor_index == CONFIRM_INDEX
        # go back to bottom row, left column
        @cursor_index = ROWS - 1
        moved = true
      else
        col = @cursor_index / ROWS
        row = @cursor_index % ROWS
        if row == 0
          # top of column -> wrap to confirm
          @cursor_index = CONFIRM_INDEX
        else
          @cursor_index = col * ROWS + (row - 1)
        end
        moved = true
      end
    elsif Input.trigger?(Input::C)
      if @cursor_index == CONFIRM_INDEX
        @confirmed = true
      else
        cycle_color(@cursor_index)
      end
    end

    update_cursor if moved
  end

  def cycle_color(index)
    current = @current_code[index]
    next_color = COLOR_ORDER[(COLOR_ORDER.index(current) + 1) % COLOR_ORDER.length]
    @current_code[index] = next_color
    @options[index].setBitmap(COLOR_BITMAPS[next_color])
  end

  def update_cursor
    if @cursor_index == CONFIRM_INDEX
      @cursor.setBitmap("Graphics/Pictures/Puzzles/cursor_confirm")
      @cursor.x = CONFIRM_X + CURSOR_OFFSET_X
      @cursor.y = CONFIRM_Y + CURSOR_OFFSET_Y
    else
      @cursor.setBitmap("Graphics/Pictures/Puzzles/cursor")
      col = @cursor_index / ROWS
      row = @cursor_index % ROWS
      @cursor.x = ORIGIN_X + col * STEP_X + CURSOR_OFFSET_X
      @cursor.y = ORIGIN_Y + row * STEP_Y + CURSOR_OFFSET_Y
    end
  end

  def dispose
    @options&.each { |sprite| sprite.dispose }
    @confirm_button&.dispose
    @cursor&.dispose
    @viewport&.dispose
  end
end