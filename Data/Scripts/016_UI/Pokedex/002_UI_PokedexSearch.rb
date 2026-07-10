class PokemonPokedex_Scene
  def pbRefreshDexSearch(params, _index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base = Color.new(248, 248, 248)
    shadow = Color.new(72, 72, 72)

    if isDarkMode
      base, shadow = shadow, base
    end

    # Write various bits of text
    textpos = [
      [_INTL("Search Mode"), Graphics.width / 2, -2, 2, base, shadow],
      [_INTL("Order"), 136, 52, 2, base, shadow],
      [_INTL("Name"), 58, 110, 2, base, shadow],
      [_INTL("Type"), 58, 162, 2, base, shadow],
      [_INTL("Height"), 58, 214, 2, base, shadow],
      [_INTL("Weight"), 58, 266, 2, base, shadow],
      [_INTL("Color"), 326, 110, 2, base, shadow],
      [_INTL("Shape"), 454, 162, 2, base, shadow],
      [_INTL("Reset"), 80, 338, 2, base, shadow, 1],
      [_INTL("Start"), Graphics.width / 2, 338, 2, base, shadow, 1],
      [_INTL("Cancel"), Graphics.width - 80, 338, 2, base, shadow, 1]
    ]
    # Write order, name and color parameters
    textpos.push([@orderCommands[params[0]], 344, 58, 2, base, shadow, 1])
    textpos.push([(params[1] < 0) ? "----" : @nameCommands[params[1]], 176, 116, 2, base, shadow, 1])
    textpos.push([(params[8] < 0) ? "----" : @colorCommands[params[8]].name, 444, 116, 2, base, shadow, 1])
    # Draw type icons
    if params[2] >= 0
      type_number = @typeCommands[params[2]].id_number
      typerect = Rect.new(0, type_number * 32, 96, 32)
      overlay.blt(128, 168, @typebitmap.bitmap, typerect)
    else
      textpos.push(["----", 176, 168, 2, base, shadow, 1])
    end
    if params[3] >= 0
      type_number = @typeCommands[params[3]].id_number
      typerect = Rect.new(0, type_number * 32, 96, 32)
      overlay.blt(256, 168, @typebitmap.bitmap, typerect)
    else
      textpos.push(["----", 304, 168, 2, base, shadow, 1])
    end
    # Write height and weight limits
    ht1 = (params[4] < 0) ? 0 : (params[4] >= @heightCommands.length) ? 999 : @heightCommands[params[4]]
    ht2 = (params[5] < 0) ? 999 : (params[5] >= @heightCommands.length) ? 0 : @heightCommands[params[5]]
    wt1 = (params[6] < 0) ? 0 : (params[6] >= @weightCommands.length) ? 9999 : @weightCommands[params[6]]
    wt2 = (params[7] < 0) ? 9999 : (params[7] >= @weightCommands.length) ? 0 : @weightCommands[params[7]]
    hwoffset = false
    if System.user_language[3..4] == "US" # If the user is in the United States
      ht1 = (params[4] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
      ht2 = (params[5] < 0) ? 99 * 12 : (ht2 / 0.254).round
      wt1 = (params[6] >= @weightCommands.length) ? 99990 : (wt1 / 0.254).round
      wt2 = (params[7] < 0) ? 99990 : (wt2 / 0.254).round
      textpos.push([sprintf("%d'%02d''", ht1 / 12, ht1 % 12), 166, 220, 2, base, shadow, 1])
      textpos.push([sprintf("%d'%02d''", ht2 / 12, ht2 % 12), 294, 220, 2, base, shadow, 1])
      textpos.push([sprintf("%.1f", wt1 / 10.0), 166, 272, 2, base, shadow, 1])
      textpos.push([sprintf("%.1f", wt2 / 10.0), 294, 272, 2, base, shadow, 1])
      hwoffset = true
    else
      textpos.push([sprintf("%.1f", ht1 / 10.0), 166, 220, 2, base, shadow, 1])
      textpos.push([sprintf("%.1f", ht2 / 10.0), 294, 220, 2, base, shadow, 1])
      textpos.push([sprintf("%.1f", wt1 / 10.0), 166, 272, 2, base, shadow, 1])
      textpos.push([sprintf("%.1f", wt2 / 10.0), 294, 272, 2, base, shadow, 1])
    end
    overlay.blt(344, 214, @hwbitmap.bitmap, Rect.new(0, (hwoffset) ? 44 : 0, 32, 44))
    overlay.blt(344, 266, @hwbitmap.bitmap, Rect.new(32, (hwoffset) ? 44 : 0, 32, 44))
    # Draw shape icon
    if params[9] >= 0
      shape_number = @shapeCommands[params[9]].id_number
      shaperect = Rect.new(0, (shape_number - 1) * 60, 60, 60)
      overlay.blt(424, 218, @shapebitmap.bitmap, shaperect)
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbRefreshDexSearchParam(mode, cmds, sel, _index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base = Color.new(248, 248, 248)
    shadow = Color.new(72, 72, 72)

    if isDarkMode
      base, shadow = shadow, base
    end

    # Write various bits of text
    textpos = [
      [_INTL("Search Mode"), Graphics.width / 2, -2, 2, base, shadow],
      [_INTL("OK"), 80, 338, 2, base, shadow, 1],
      [_INTL("Cancel"), Graphics.width - 80, 338, 2, base, shadow, 1]
    ]
    title = [_INTL("Order"), _INTL("Name"), _INTL("Type"), _INTL("Height"),
             _INTL("Weight"), _INTL("Color"), _INTL("Shape")][mode]
    textpos.push([title, 102, (mode == 6) ? 58 : 52, 0, base, shadow])
    case mode
    when 0 # Order
      xstart = 46; ystart = 128
      xgap = 236; ygap = 64
      halfwidth = 92; cols = 2
      selbuttony = 0; selbuttonheight = 44
    when 1 # Name
      xstart = 78; ystart = 114
      xgap = 52; ygap = 52
      halfwidth = 22; cols = 7
      selbuttony = 156; selbuttonheight = 44
    when 2 # Type
      xstart = 8; ystart = 104
      xgap = 124; ygap = 44
      halfwidth = 62; cols = 4
      selbuttony = 44; selbuttonheight = 44
    when 3, 4 # Height, weight
      xstart = 44; ystart = 110
      xgap = 304 / (cmds.length + 1); ygap = 112
      halfwidth = 60; cols = cmds.length + 1
    when 5 # Color
      xstart = 62; ystart = 114
      xgap = 132; ygap = 52
      halfwidth = 62; cols = 3
      selbuttony = 44; selbuttonheight = 44
    when 6 # Shape
      xstart = 82; ystart = 116
      xgap = 70; ygap = 70
      halfwidth = 0; cols = 5
      selbuttony = 88; selbuttonheight = 68
    end
    # Draw selected option(s) text in top bar
    case mode
    when 2 # Type icons
      for i in 0...2
        if !sel[i] || sel[i] < 0
          textpos.push(["----", 298 + 128 * i, 58, 2, base, shadow, 1])
        else
          type_number = @typeCommands[sel[i]].id_number
          typerect = Rect.new(0, type_number * 32, 96, 32)
          overlay.blt(250 + 128 * i, 58, @typebitmap.bitmap, typerect)
        end
      end
    when 3 # Height range
      ht1 = (sel[0] < 0) ? 0 : (sel[0] >= @heightCommands.length) ? 999 : @heightCommands[sel[0]]
      ht2 = (sel[1] < 0) ? 999 : (sel[1] >= @heightCommands.length) ? 0 : @heightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4] == "US" # If the user is in the United States
        ht1 = (sel[0] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
        ht2 = (sel[1] < 0) ? 99 * 12 : (ht2 / 0.254).round
        txt1 = sprintf("%d'%02d''", ht1 / 12, ht1 % 12)
        txt2 = sprintf("%d'%02d''", ht2 / 12, ht2 % 12)
        hwoffset = true
      else
        txt1 = sprintf("%.1f", ht1 / 10.0)
        txt2 = sprintf("%.1f", ht2 / 10.0)
      end
      textpos.push([txt1, 286, 58, 2, base, shadow, 1])
      textpos.push([txt2, 414, 58, 2, base, shadow, 1])
      overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(0, (hwoffset) ? 44 : 0, 32, 44))
    when 4 # Weight range
      wt1 = (sel[0] < 0) ? 0 : (sel[0] >= @weightCommands.length) ? 9999 : @weightCommands[sel[0]]
      wt2 = (sel[1] < 0) ? 9999 : (sel[1] >= @weightCommands.length) ? 0 : @weightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4] == "US" # If the user is in the United States
        wt1 = (sel[0] >= @weightCommands.length) ? 99990 : (wt1 / 0.254).round
        wt2 = (sel[1] < 0) ? 99990 : (wt2 / 0.254).round
        txt1 = sprintf("%.1f", wt1 / 10.0)
        txt2 = sprintf("%.1f", wt2 / 10.0)
        hwoffset = true
      else
        txt1 = sprintf("%.1f", wt1 / 10.0)
        txt2 = sprintf("%.1f", wt2 / 10.0)
      end
      textpos.push([txt1, 286, 58, 2, base, shadow, 1])
      textpos.push([txt2, 414, 58, 2, base, shadow, 1])
      overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(32, (hwoffset) ? 44 : 0, 32, 44))
    when 5 # Color
      if sel[0] < 0
        textpos.push(["----", 362, 58, 2, base, shadow, 1])
      else
        textpos.push([cmds[sel[0]].name, 362, 58, 2, base, shadow, 1])
      end
    when 6 # Shape icon
      if sel[0] >= 0
        shaperect = Rect.new(0, (@shapeCommands[sel[0]].id_number - 1) * 60, 60, 60)
        overlay.blt(332, 50, @shapebitmap.bitmap, shaperect)
      end
    else
      if sel[0] < 0
        text = ["----", "-", "----", "", "", "----", ""][mode]
        textpos.push([text, 362, 58, 2, base, shadow, 1])
      else
        textpos.push([cmds[sel[0]], 362, 58, 2, base, shadow, 1])
      end
    end
    # Draw selected option(s) button graphic
    if mode == 3 || mode == 4 # Height, weight
      xpos1 = xstart + (sel[0] + 1) * xgap
      xpos1 = xstart if sel[0] < -1
      xpos2 = xstart + (sel[1] + 1) * xgap
      xpos2 = xstart + cols * xgap if sel[1] < 0
      xpos2 = xstart if sel[1] >= cols - 1
      ypos1 = ystart + 172
      ypos2 = ystart + 28
      overlay.blt(16, 120, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[1] < cols - 1
      overlay.blt(464, 120, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[1] >= 0
      overlay.blt(16, 264, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[0] >= 0
      overlay.blt(464, 264, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[0] < cols - 1
      hwrect = Rect.new(0, 0, 120, 96)
      overlay.blt(xpos2, ystart, @searchsliderbitmap.bitmap, hwrect)
      hwrect.y = 96
      overlay.blt(xpos1, ystart + ygap, @searchsliderbitmap.bitmap, hwrect)
      textpos.push([txt1, xpos1 + halfwidth, ypos1, 2, base, nil, 1])
      textpos.push([txt2, xpos2 + halfwidth, ypos2, 2, base, nil, 1])
    else
      for i in 0...sel.length
        if sel[i] >= 0
          selrect = Rect.new(0, selbuttony, @selbitmap.bitmap.width, selbuttonheight)
          overlay.blt(xstart + (sel[i] % cols) * xgap, ystart + (sel[i] / cols).floor * ygap, @selbitmap.bitmap, selrect)
        else
          selrect = Rect.new(0, selbuttony, @selbitmap.bitmap.width, selbuttonheight)
          overlay.blt(xstart + (cols - 1) * xgap, ystart + (cmds.length / cols).floor * ygap, @selbitmap.bitmap, selrect)
        end
      end
    end
    # Draw options
    case mode
    when 0, 1 # Order, name
      for i in 0...cmds.length
        x = xstart + halfwidth + (i % cols) * xgap
        y = ystart + 6 + (i / cols).floor * ygap
        textpos.push([cmds[i], x, y, 2, base, shadow, 1])
      end
      if mode != 0
        textpos.push([(mode == 1) ? "-" : "----",
                      xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1])
      end
    when 2 # Type
      typerect = Rect.new(0, 0, 96, 32)
      for i in 0...cmds.length
        typerect.y = @typeCommands[i].id_number * 32
        overlay.blt(xstart + 14 + (i % cols) * xgap, ystart + 6 + (i / cols).floor * ygap, @typebitmap.bitmap, typerect)
      end
      textpos.push(["----",
                    xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1])
    when 5 # Color
      for i in 0...cmds.length
        x = xstart + halfwidth + (i % cols) * xgap
        y = ystart + 6 + (i / cols).floor * ygap
        textpos.push([cmds[i].name, x, y, 2, base, shadow, 1])
      end
      textpos.push(["----",
                    xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1])
    when 6 # Shape
      shaperect = Rect.new(0, 0, 60, 60)
      for i in 0...cmds.length
        shaperect.y = (@shapeCommands[i].id_number - 1) * 60
        overlay.blt(xstart + 4 + (i % cols) * xgap, ystart + 4 + (i / cols).floor * ygap, @shapebitmap.bitmap, shaperect)
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end


  def pbSearchDexList(params)
    $PokemonGlobal.pokedexMode = params[0]
    dexlist = pbGetDexList
    # Filter by name
    if params[1] >= 0
      scanNameCommand = @nameCommands[params[1]].scan(/./)
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        firstChar = item[1][0, 1]
        next scanNameCommand.any? { |v| v == firstChar }
      }
    end
    # Filter by type
    if params[2] >= 0 || params[3] >= 0
      stype1 = (params[2] >= 0) ? @typeCommands[params[2]].id : nil
      stype2 = (params[3] >= 0) ? @typeCommands[params[3]].id : nil
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        type1 = item[6]
        type2 = item[7]
        if stype1 && stype2
          # Find species that match both types
          next (type1 == stype1 && type2 == stype2) || (type1 == stype2 && type2 == stype1)
        elsif stype1
          # Find species that match first type entered
          next type1 == stype1 || type2 == stype1
        elsif stype2
          # Find species that match second type entered
          next type1 == stype2 || type2 == stype2
        else
          next false
        end
      }
    end
    # Filter by height range
    if params[4] >= 0 || params[5] >= 0
      minh = (params[4] < 0) ? 0 : (params[4] >= @heightCommands.length) ? 999 : @heightCommands[params[4]]
      maxh = (params[5] < 0) ? 999 : (params[5] >= @heightCommands.length) ? 0 : @heightCommands[params[5]]
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        height = item[2]
        next height >= minh && height <= maxh
      }
    end
    # Filter by weight range
    if params[6] >= 0 || params[7] >= 0
      minw = (params[6] < 0) ? 0 : (params[6] >= @weightCommands.length) ? 9999 : @weightCommands[params[6]]
      maxw = (params[7] < 0) ? 9999 : (params[7] >= @weightCommands.length) ? 0 : @weightCommands[params[7]]
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        weight = item[3]
        next weight >= minw && weight <= maxw
      }
    end
    # Filter by color
    if params[8] >= 0
      scolor = @colorCommands[params[8]].id
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        next item[8] == scolor
      }
    end
    # Filter by shape
    if params[9] >= 0
      sshape = @shapeCommands[params[9]].id
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        next item[9] == sshape
      }
    end
    # Remove all unseen species from the results
    dexlist = dexlist.find_all { |item| next $Trainer.seen?(item[0]) }
    case $PokemonGlobal.pokedexMode
    when MODENUMERICAL then dexlist.sort! { |a, b| a[4] <=> b[4] }
    when MODEATOZ then dexlist.sort! { |a, b| a[1] <=> b[1] }
    when MODEHEAVIEST then dexlist.sort! { |a, b| b[3] <=> a[3] }
    when MODELIGHTEST then dexlist.sort! { |a, b| a[3] <=> b[3] }
    when MODETALLEST then dexlist.sort! { |a, b| b[2] <=> a[2] }
    when MODESMALLEST then dexlist.sort! { |a, b| a[2] <=> b[2] }
    end
    return dexlist
  end

  def pbCloseSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    oldspecies = @sprites["pokedex"].species
    @searchResults = false
    $PokemonGlobal.pokedexMode = MODENUMERICAL
    @searchParams = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    for i in 0...@dexlist.length
      next if @dexlist[i][0] != oldspecies
      @sprites["pokedex"].index = i
      pbRefresh
      break
    end
    $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbDexSearchCommands(mode, selitems, mainindex)
    cmds = [@orderCommands, @nameCommands, @typeCommands, @heightCommands,
            @weightCommands, @colorCommands, @shapeCommands][mode]
    cols = [2, 7, 4, 1, 1, 3, 5][mode]
    ret = nil
    # Set background
    case mode
    when 0 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_order")
    when 1 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_name")
    when 2
      count = 0
      GameData::Type.each { |t| count += 1 if !t.pseudo_type && t.id != :SHADOW }
      if count == 18
        @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_type_18")
      else
        @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_type")
      end
    when 3, 4 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_size")
    when 5 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_color")
    when 6 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_shape")
    end
    selindex = selitems.clone
    index = selindex[0]
    oldindex = index
    minmax = 1
    oldminmax = minmax
    if mode == 3 || mode == 4
      index = oldindex = selindex[minmax]
    end
    @sprites["searchcursor"].mode = mode
    @sprites["searchcursor"].cmds = cmds.length
    @sprites["searchcursor"].minmax = minmax
    @sprites["searchcursor"].index = index
    nextparam = cmds.length % 2
    pbRefreshDexSearchParam(mode, cmds, selindex, index)
    loop do
      pbUpdate
      if index != oldindex || minmax != oldminmax
        @sprites["searchcursor"].minmax = minmax
        @sprites["searchcursor"].index = index
        oldindex = index
        oldminmax = minmax
      end
      Graphics.update
      Input.update
      if mode == 3 || mode == 4
        if Input.trigger?(Input::UP)
          if index < -1;
            minmax = 0; index = selindex[minmax] # From OK/Cancel
          elsif minmax == 0;
            minmax = 1; index = selindex[minmax]
          end
          if index != oldindex || minmax != oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.trigger?(Input::DOWN)
          if minmax == 1;
            minmax = 0; index = selindex[minmax]
          elsif minmax == 0;
            minmax = -1; index = -2
          end
          if index != oldindex || minmax != oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.repeat?(Input::LEFT)
          if index == -3;
            index = -2
          elsif index >= -1
            if minmax == 1 && index == -1
              index = cmds.length - 1 if selindex[0] < cmds.length - 1
            elsif minmax == 1 && index == 0
              index = cmds.length if selindex[0] < 0
            elsif index > -1 && !(minmax == 1 && index >= cmds.length)
              index -= 1 if minmax == 0 || selindex[0] <= index - 1
            end
          end
          if index != oldindex
            selindex[minmax] = index if minmax >= 0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.repeat?(Input::RIGHT)
          if index == -2;
            index = -3
          elsif index >= -1
            if minmax == 1 && index >= cmds.length;
              index = 0
            elsif minmax == 1 && index == cmds.length - 1;
              index = -1
            elsif index < cmds.length && !(minmax == 1 && index < 0)
              index += 1 if minmax == 1 || selindex[1] == -1 ||
                (selindex[1] < cmds.length && selindex[1] >= index + 1)
            end
          end
          if index != oldindex
            selindex[minmax] = index if minmax >= 0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        end
      else
        if Input.trigger?(Input::UP)
          if index == -1;
            index = cmds.length - 1 - (cmds.length - 1) % cols - 1 # From blank
          elsif index == -2;
            index = ((cmds.length - 1) / cols).floor * cols # From OK
          elsif index == -3 && mode == 0;
            index = cmds.length - 1 # From Cancel
          elsif index == -3;
            index = -1 # From Cancel
          elsif index >= cols;
            index -= cols
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::DOWN)
          if index == -1;
            index = -3 # From blank
          elsif index >= 0
            if index + cols < cmds.length;
              index += cols
            elsif (index / cols).floor < ((cmds.length - 1) / cols).floor
              index = (index % cols < cols / 2.0) ? cmds.length - 1 : -1
            else
              index = (index % cols < cols / 2.0) ? -2 : -3
            end
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::LEFT)
          if index == -3;
            index = -2
          elsif index == -1;
            index = cmds.length - 1
          elsif index > 0 && index % cols != 0;
            index -= 1
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::RIGHT)
          if index == -2;
            index = -3
          elsif index == cmds.length - 1 && mode != 0;
            index = -1
          elsif index >= 0 && index % cols != cols - 1;
            index += 1
          end
          pbPlayCursorSE if index != oldindex
        end
      end
      if Input.trigger?(Input::ACTION)
        index = -2
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        ret = nil
        break
      elsif Input.trigger?(Input::USE)
        if index == -2 # OK
          pbPlayDecisionSE
          ret = selindex
          break
        elsif index == -3 # Cancel
          pbPlayCloseMenuSE
          ret = nil
          break
        elsif selindex != index && mode != 3 && mode != 4
          if mode == 2
            if index == -1
              nextparam = (selindex[1] >= 0) ? 1 : 0
            elsif index >= 0
              nextparam = (selindex[0] < 0) ? 0 : (selindex[1] < 0) ? 1 : nextparam
            end
            if index < 0 || selindex[(nextparam + 1) % 2] != index
              pbPlayDecisionSE
              selindex[nextparam] = index
              nextparam = (nextparam + 1) % 2
            end
          else
            pbPlayDecisionSE
            selindex[0] = index
          end
          pbRefreshDexSearchParam(mode, cmds, selindex, index)
        end
      end
    end
    Input.update
    # Set background image
    @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search")
    @sprites["searchcursor"].mode = -1
    @sprites["searchcursor"].index = mainindex
    return ret
  end

  def pbDexSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    params = @searchParams.clone
    @orderCommands = []
    @orderCommands[MODENUMERICAL] = _INTL("Numerical")
    @orderCommands[MODEATOZ] = _INTL("A to Z")
    @orderCommands[MODEHEAVIEST] = _INTL("Heaviest")
    @orderCommands[MODELIGHTEST] = _INTL("Lightest")
    @orderCommands[MODETALLEST] = _INTL("Tallest")
    @orderCommands[MODESMALLEST] = _INTL("Smallest")
    @nameCommands = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    @typeCommands = []

    count = 0
    GameData::Type.each do |t|
      @typeCommands.push(t) if !t.pseudo_type && count <= 18
      count += 1
    end
    @typeCommands.sort! { |a, b| a.id_number <=> b.id_number }
    @heightCommands = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                       11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                       21, 22, 23, 24, 25, 30, 35, 40, 45, 50,
                       55, 60, 65, 70, 80, 90, 100]
    @weightCommands = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50,
                       55, 60, 70, 80, 90, 100, 110, 120, 140, 160,
                       180, 200, 250, 300, 350, 400, 500, 600, 700, 800,
                       900, 1000, 1250, 1500, 2000, 3000, 5000]
    @colorCommands = []
    GameData::BodyColor.each { |c| @colorCommands.push(c) }
    @shapeCommands = []
    GameData::BodyShape.each { |c| @shapeCommands.push(c) if c.id != :None }
    @sprites["searchbg"].visible = true
    @sprites["overlay"].visible = true
    @sprites["searchcursor"].visible = true
    index = 0
    oldindex = index
    @sprites["searchcursor"].mode = -1
    @sprites["searchcursor"].index = index
    pbRefreshDexSearch(params, index)
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if index != oldindex
        @sprites["searchcursor"].index = index
        oldindex = index
      end
      if Input.trigger?(Input::UP)
        if index >= 7;
          index = 4
        elsif index == 5;
          index = 0
        elsif index > 0;
          index -= 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::DOWN)
        if index == 4 || index == 6;
          index = 8
        elsif index < 7;
          index += 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::LEFT)
        if index == 5;
          index = 1
        elsif index == 6;
          index = 3
        elsif index > 7;
          index -= 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::RIGHT)
        if index == 1;
          index = 5
        elsif index >= 2 && index <= 4;
          index = 6
        elsif index == 7 || index == 8;
          index += 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::ACTION)
        index = 8
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE if index != 9
        case index
        when 0 # Choose sort order
          newparam = pbDexSearchCommands(0, [params[0]], index)
          params[0] = newparam[0] if newparam != nil
          pbRefreshDexSearch(params, index)
        when 1 # Filter by name
          newparam = pbDexSearchCommands(1, [params[1]], index)
          params[1] = newparam[0] if newparam != nil
          pbRefreshDexSearch(params, index)
        when 2 # Filter by type
          newparam = pbDexSearchCommands(2, [params[2], params[3]], index)
          if newparam != nil
            params[2] = newparam[0]
            params[3] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 3 # Filter by height range
          newparam = pbDexSearchCommands(3, [params[4], params[5]], index)
          if newparam != nil
            params[4] = newparam[0]
            params[5] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 4 # Filter by weight range
          newparam = pbDexSearchCommands(4, [params[6], params[7]], index)
          if newparam != nil
            params[6] = newparam[0]
            params[7] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 5 # Filter by color filter
          newparam = pbDexSearchCommands(5, [params[8]], index)
          params[8] = newparam[0] if newparam != nil
          pbRefreshDexSearch(params, index)
        when 6 # Filter by form
          newparam = pbDexSearchCommands(6, [params[9]], index)
          params[9] = newparam[0] if newparam != nil
          pbRefreshDexSearch(params, index)
        when 7 # Clear filters
          for i in 0...10
            params[i] = (i == 0) ? MODENUMERICAL : -1
          end
          pbRefreshDexSearch(params, index)
        when 8 # Start search (filter)
          dexlist = pbSearchDexList(params)
          if dexlist.length == 0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index = 0
            @sprites["pokedex"].refresh
            @searchResults = true
            @searchParams = params
            break
          end
        when 9 # Cancel
          pbPlayCloseMenuSE
          break
        end
      end
    end
    pbFadeOutAndHide(@sprites)
    if @searchResults
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
    end
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
    Input.update
    return 0
  end

  def pokedexQuickSearch

    if $PokemonSystem.textinput == 1 # keyboard
      scene = PokedexTextEntry.new
    else
      # cursor
      scene = PokemonEntryScene2.new
    end
    scene.pbStartScene(
      _INTL("Search Pokémon by name."),
      1, # min length
      12, # max length
      ""
    )
    query = scene.pbEntry
    scene.pbEndScene

    if query && !query.empty?
      pbApplyTextNameSearch(query)
    end
  end

  def pbApplyTextNameSearch(query)
    query = query.downcase
    dexlist = pbGetDexList(@filter_owned)

    dexlist = dexlist.find_all do |item|
      next false if !$Trainer.seen?(item[0])
      item[1].downcase.include?(query)
    end

    @searchResults = true
    @dexlist = dexlist
    @sprites["pokedex"].commands = @dexlist
    @sprites["pokedex"].index = 0
    @sprites["pokedex"].refresh
    pbRefresh
  end
end
