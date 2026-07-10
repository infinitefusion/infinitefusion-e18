class PokemonStorageScene
  include SelectionConstants

  attr_reader :cursormode
  attr_reader :screen
  attr_reader :sprites
  attr_accessor :selection

  alias _storageMultiselect_pbStartBox pbStartBox

  def pbStartBox(*args)
    _storageMultiselect_pbStartBox(*args)
    @cursormode = "default"
    # create a single selection rect sprite used when needed
    @sprites["selectionrect"] = BitmapSprite.new(Graphics.width, Graphics.height, @arrowviewport)
    @sprites["selectionrect"].visible = false
  end

  def pbChangeSelection(key, selection)
    if @choseFromParty
      return SelectionNavigator.navigate_party(key, selection, @screen)
    else
      return SelectionNavigator.navigate_box(key, selection, @screen)
    end
  end

  def pbPartyChangeSelection(key, selection)
    SelectionNavigator.navigate_party(key, selection, @screen)
  end

  def pbSelectPartyInternal(party, depositing)
    selection = @selection
    pbPartySetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection, party)
    pbSetMosaic(selection)
    lastsel = 1
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE
        newselection = pbPartyChangeSelection(key, selection)
        if newselection == -1
          return -1 if !depositing
        elsif newselection == -2
          selection = lastsel
        else
          selection = newselection
        end
        pbPartySetArrow(@sprites["arrow"], selection)
        lastsel = selection if selection > 0
        pbUpdateOverlay(selection, party)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(-1, selection)
        end
      end
      self.update
      if Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        if !@screen.pbHolding?
          pbPlayDecisionSE
          pbNextCursorMode
        end
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return -1
      elsif Input.trigger?(Input::USE)
        if selection >= 0 && selection < Settings::MAX_PARTY_SIZE
          @selection = selection
          return selection
        elsif selection == Settings::MAX_PARTY_SIZE # Close Box
          @selection = selection
          return (depositing) ? -3 : -1
        end
      end
    end
  end

  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)

      if key >= 0
        pbPlayCursorSE
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        if selection == SelectionConstants::PREV_BOX
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection == SelectionConstants::NEXT_BOX
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = BOX_NAME if selection == SelectionConstants::PREV_BOX || selection == SelectionConstants::NEXT_BOX
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(@storage.currentBox, selection)
        end
      end
      self.update
      if Input.trigger?(Input::JUMPUP)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::JUMPDOWN)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::SPECIAL) # Jump to box name
        if selection != BOX_NAME
          pbPlayCursorSE
          selection = BOX_NAME
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbNextCursorMode
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == BOX_NAME
          return [SelectionConstants::PREV_BOX, BOX_NAME]
        elsif selection == PARTY
          return [SelectionConstants::PARTY, BOX_NAME]
        elsif selection == CLOSE
          return [SelectionConstants::CLOSE, BOX_NAME]
        end
      end
    end
  end

  def restartBox(screen, command, animate = true)
    pbCloseBox(animate)
    cursormode = @cursormode
    selection = @selection
    pbStartBox(screen, command, animate)
    pbSetCursorMode(cursormode)
    @selection = selection
  end

  def pbNextCursorMode()
    return if @screen.pbHolding?
    case @cursormode
    when "default"
      pbSetCursorMode("multiselect")
    when "quickswap"  #Disabled
      pbSetCursorMode("default")
    when "multiselect"
      #pbSetCursorMode("quickswap") if !@screen.pbHolding?
      pbSetCursorMode("default")
    end
  end

  def pbSetCursorMode(value)
    return unless @sprites["arrow"]
    @cursormode = value
    @sprites["arrow"].cursormode = value
    if @screen.multiSelectRange
      @screen.multiSelectRange = nil
      pbUpdateSelectionRect(@choseFromParty ? -1 : @storage.currentBox, 0)
    end
  end

  def pbSetHeldPokemon(pokemon)
    pokesprite = PokemonBoxIcon.new(pokemon, @arrowviewport)
    @sprites["arrow"].grabImmediate(pokesprite)
  end

  # Scene draws the rect by asking SelectionHelper for the rect
  # in PokemonStorageScene
  def pbUpdateSelectionRect(box, selected)
    rect = SelectionHelper.compute_rect(self, @screen, box, selected)
    if rect.nil?
      @sprites["selectionrect"].visible = false
      return
    end

    bmp = @sprites["selectionrect"].bitmap
    bmp.clear

    color = Color.new(0, 255, 0, 50) # semi-transparent green
    radius = 12 # corner roundness in pixels

    draw_rounded_rect(bmp, rect.x, rect.y, rect.width, rect.height, radius, color)
    @sprites["selectionrect"].visible = true
  end

  # helper method (add to PokemonStorageScene)
  def draw_rounded_rect(bmp, x, y, w, h, r, color)
    # central rectangle
    bmp.fill_rect(x + r, y, w - 2 * r, h, color)
    bmp.fill_rect(x, y + r, w, h - 2 * r, color)

    # corner circles
    (0..r).each do |dy|
      dx = (r * r - dy * dy) ** 0.5
      # top-left
      bmp.fill_rect(x + r - dx, y + r - dy, 2 * dx, 1, color)
      # top-right
      bmp.fill_rect(x + w - r - dx, y + r - dy, 2 * dx, 1, color)
      # bottom-left
      bmp.fill_rect(x + r - dx, y + h - r + dy - 1, 2 * dx, 1, color)
      # bottom-right
      bmp.fill_rect(x + w - r - dx, y + h - r + dy - 1, 2 * dx, 1, color)
    end
  end

  # --- Animation methods (Scene-only) ---
  # The scene only animates; it does not change game state or run rules.
  def animate_hold_multi(box, selected, selected_index)
    pbSEPlay("GUI storage pick up")
    if box == BOX_NAME
      @sprites["boxparty"].grabPokemonMulti(selected, selected_index, @sprites["arrow"])
    else
      @sprites["box"].grabPokemonMulti(selected, selected_index, @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def animate_place_multi(box, index)
    pbSEPlay("GUI storage put down")
    heldpokesprites = @sprites["arrow"].multiHeldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if box == BOX_NAME
      @sprites["boxparty"].placePokemonMulti(index, heldpokesprites)
    else
      @sprites["box"].placePokemonMulti(index, heldpokesprites)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = index
  end

  def animate_release_multi(box, selected)
    release_sprites = []
    for index in selected
      sprite = nil
      if box == BOX_NAME
        sprite = @sprites["boxparty"].getPokemon(index)
      else
        sprite = @sprites["box"].getPokemon(index)
      end
      release_sprites << sprite if sprite
    end
    if release_sprites.length > 0
      for sprite in release_sprites
        sprite.release
      end
      while release_sprites[0].releasing?
        Graphics.update
        for sprite in release_sprites
          sprite.update
        end
        self.update
      end
    end
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport, @screen.filterProc)
    @sprites["boxparty"].dispose
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport,@screen.filterProc)
    @sprites["boxparty"].y = oldPartyY
  end

  def pbCloseBox(animate = true)
    pbFadeOutAndHide(@sprites) if animate
    pbDisposeSpriteHash(@sprites)
    @markingbitmap.dispose if @markingbitmap
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  # Convenience wrapper for external code that expects pbPlaceMulti/pbHoldMulti naming:
  alias pbPlaceMulti animate_place_multi
  alias pbHoldMulti animate_hold_multi
  alias pbReleaseMulti animate_release_multi
end