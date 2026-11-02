def displayCaughtPokemonIcons
  pbSafariState.caught_pokemon = [] unless pbSafariState.caught_pokemon
  return SafariCaughtIcons_UI.new(pbSafariState.caught_pokemon)
end

class SafariCaughtIcons_UI < PokeRadar_UI
  SAFARI_ICON_START_X    = 8
  SAFARI_ICON_START_Y    = 40
  SAFARI_ICON_SPACING_X  = 24   # gap between dupes
  SAFARI_ICON_MARGIN_Y   = 44   # preferred row height
  SAFARI_ICON_MIN_MARGIN = 24
  SAFARI_ICON_BOTTOM     = 32
  SAFARI_ICON_RIGHT      = 8
  SAFARI_ICON_WIDTH      = 32
  SAFARI_GRAPHICS_Z      = 19998
  SAFARI_BG_IMAGE        = "Safari/safari_caught_bg"   # Graphics/Pictures/
  SAFARI_BG_OPACITY      = 200

  SAFARI_COLUMN_GAP = 8   # space between columns
  SAFARI_BG_PADDING = 8
  def initialize(caught_pokemon = [])
    counts = Hash.new(0)
    caught_pokemon.each { |pokemon| counts[pokemon.species] += 1 }

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = SAFARI_GRAPHICS_Z
    @sprites = {}
    @bounds = nil
    return if counts.empty?

    usable_height = Graphics.height - SAFARI_ICON_START_Y - SAFARI_ICON_BOTTOM
    usable_width  = Graphics.width - SAFARI_ICON_START_X - SAFARI_ICON_RIGHT
    entries = counts.to_a   # [[species, count], ...]
    ideal_width = proc { |count| SAFARI_ICON_WIDTH + (count - 1) * SAFARI_ICON_SPACING_X }

    # Try 1, 2, 3... columns. Pass 1 wants comfortable row height,
    # pass 2 accepts the tightest row height.
    layout = nil
    [SAFARI_ICON_MARGIN_Y, SAFARI_ICON_MIN_MARGIN].each do |min_row_height|
      (1..entries.size).each do |num_cols|
        rows_per_col = (entries.size.to_f / num_cols).ceil
        next if usable_height / rows_per_col < min_row_height

        columns = entries.each_slice(rows_per_col).to_a
        col_widths = columns.map { |col| col.map { |_, c| ideal_width.call(c) }.max }
        total = col_widths.sum + SAFARI_COLUMN_GAP * (columns.size - 1)
        next if total > usable_width

        layout = [rows_per_col, columns, col_widths]
        break
      end
      break if layout
    end

    # Fallback: too many to fit comfortably, so squeeze columns/dupes as needed
    if !layout
      max_rows = [usable_height / SAFARI_ICON_MIN_MARGIN, 1].max
      num_cols = (entries.size.to_f / max_rows).ceil
      rows_per_col = (entries.size.to_f / num_cols).ceil
      columns = entries.each_slice(rows_per_col).to_a
      col_widths = columns.map { |col| col.map { |_, c| ideal_width.call(c) }.max }
      available = usable_width - SAFARI_COLUMN_GAP * (columns.size - 1)
      total = col_widths.sum
      if total > available
        scale = available.to_f / total
        col_widths = col_widths.map { |w| (w * scale).floor }
      end
      layout = [rows_per_col, columns, col_widths]
    end

    rows_per_col, columns, col_widths = layout
    row_margin = [[usable_height / rows_per_col, SAFARI_ICON_MARGIN_Y].min,
                  SAFARI_ICON_MIN_MARGIN].max

    x = SAFARI_ICON_START_X
    columns.each_with_index do |col, col_index|
      col.each_with_index do |(species, count), row|
        y = SAFARI_ICON_START_Y + row * row_margin
        addSpeciesRow(species, count, x, y, col_widths[col_index])
      end
      x += col_widths[col_index] + SAFARI_COLUMN_GAP
    end
    addBackground
  end

  def expandBounds(x, y, w, h)
    if !@bounds
      @bounds = [x, y, x + w, y + h]
    else
      @bounds[0] = [@bounds[0], x].min
      @bounds[1] = [@bounds[1], y].min
      @bounds[2] = [@bounds[2], x + w].max
      @bounds[3] = [@bounds[3], y + h].max
    end
  end

  def addBackground
    return if !@bounds
    left   = [@bounds[0] - SAFARI_BG_PADDING, 0].max
    top    = [@bounds[1] - SAFARI_BG_PADDING, 0].max
    right  = [@bounds[2] + SAFARI_BG_PADDING, Graphics.width].min
    bottom = [@bounds[3] + SAFARI_BG_PADDING, Graphics.height].min

    win = SpriteWindow_Base.new(left, top, right - left, bottom - top)
    win.viewport = @viewport
    win.setSkin(SAFARI_BG_IMAGE) if SAFARI_BG_IMAGE
    win.back_opacity = SAFARI_BG_OPACITY   # opacity of the stretched middle
    win.z = SAFARI_GRAPHICS_Z              # icons are at +1 and above
    @sprites["bg"] = win
  end

  def addSpeciesRow(species, count, start_x, y, column_width)
    pokemonId = dexNum(species)
    return if !pokemonId

    # Dupes must fit inside this column, not the whole screen
    available_width = column_width - SAFARI_ICON_WIDTH
    spacing = SAFARI_ICON_SPACING_X
    spacing = [available_width / (count - 1), spacing].min if count > 1

    count.times do |i|
      x = start_x + i * spacing

      if pokemonId > NB_POKEMON
        iconSprite = createFusionIcon(pokemonId, x, y)
      else
        iconSprite = IconSprite.new(x, y)
        iconSprite.setBitmap(pbCheckPokemonIconFiles(species))
      end

      iconSprite.src_rect.width /= 2 # icon sheets have 2 frames, show only the first
      iconSprite.x = x
      iconSprite.y = y
      iconSprite.z = SAFARI_GRAPHICS_Z + 1 + i
      iconSprite.visible = true
      expandBounds(x, y, iconSprite.src_rect.width, iconSprite.src_rect.height)
      @sprites[_INTL("{1}_{2}", species, i)] = iconSprite
    end
  end
end