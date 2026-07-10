#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
  attr_reader :quickswap
  attr_accessor :sprites
  attr_accessor :choseFromParty
  attr_reader :inTransferBox

  def initialize
    @command = 1
  end

  def pbReleaseInstant(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box == -1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.dispose
    end
  end

  def pbStartBox(screen, command, animate=true)
    @screen = screen
    @storage = screen.storage
    @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @bgviewport.z = 99999
    @boxviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxviewport.z = 99999
    @boxsidesviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @boxsidesviewport.z = 99999
    @arrowviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @arrowviewport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @selection = 0
    @quickswap = false
    @sprites = {}
    @choseFromParty = false
    @partyTabBackButton = nil
    @command = command
    addBackgroundPlane(@sprites, "background", "Storage/bg", @bgviewport)
    checkOpenTransferBox(@storage.currentBox)
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport,true,@screen.filterProc)
    # echoln @screen.filterProc
    # if @screen.filterProc
    #   @sprites["box"].setFilterProc(@screen.filterProc)
    # end
    @sprites["boxsides"] = IconSprite.new(0, 0, @boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/overlay_main")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 90
    @sprites["pokemon"].y = 134
    @sprites["pokemon"].zoom_y = Settings::FRONTSPRITE_SCALE
    @sprites["pokemon"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport,@screen.filterProc)
    if command != 2 && command != 3 # Drop down tab only on Deposit and Select Pokemon
      @sprites["boxparty"].x = 182
      @sprites["boxparty"].y = Graphics.height
    end
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/markings")
    @sprites["markingbg"] = IconSprite.new(292, 68, @boxsidesviewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Storage/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z += 1
    if command != 2
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
      pbSetMosaic(@selection)
    end
    pbSEPlay("PC access") if animate
    pbFadeInAndShow(@sprites) if animate
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @markingbitmap.dispose if @markingbitmap
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  def pbDisplay(message)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        break
      end
      msgwindow.update
      self.update
    end
    msgwindow.dispose
    Input.update
  end

  def pbShowCommands(message, commands, index = 0)
    ret = -1
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.text = message
    msgwindow.resizeHeightToFit(message, Graphics.width - 180)
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    pbBottomRight(cmdwindow)
    cmdwindow.y -= msgwindow.height
    cmdwindow.index = index
    loop do
      Graphics.update
      Input.update
      msgwindow.update
      cmdwindow.update
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        break
      end
      self.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbSetArrow(arrow, selection)
    case selection
    when -1, -4, -5 # Box name, move left, move right
      arrow.x = 157 * 2
      arrow.y = -12 * 2
    when -2 # Party Pokémon
      arrow.x = 119 * 2
      arrow.y = 139 * 2
    when -3 # Close Box
      arrow.x = 207 * 2
      arrow.y = 139 * 2
    else
      arrow.x = (97 + 24 * (selection % PokemonBox::BOX_WIDTH)) * 2
      arrow.y = (8 + 24 * (selection / PokemonBox::BOX_WIDTH)) * 2
    end
  end

  def pbChangeSelection(key, selection)
    case key
    when Input::UP
      if selection == -1 # Box name
        selection = -2
      elsif selection == -2 # Party
        selection = PokemonBox::BOX_SIZE - 1 - PokemonBox::BOX_WIDTH * 2 / 3 # 25
      elsif selection == -3 # Close Box
        selection = PokemonBox::BOX_SIZE - PokemonBox::BOX_WIDTH / 3 # 28
      else
        selection -= PokemonBox::BOX_WIDTH
        selection = -1 if selection < 0
      end
    when Input::DOWN
      if selection == -1 # Box name
        selection = PokemonBox::BOX_WIDTH / 3 # 2
      elsif selection == -2 # Party
        selection = -1
      elsif selection == -3 # Close Box
        selection = -1
      else
        selection += PokemonBox::BOX_WIDTH
        if selection >= PokemonBox::BOX_SIZE
          if selection < PokemonBox::BOX_SIZE + PokemonBox::BOX_WIDTH / 2
            selection = -2 # Party
          else
            selection = -3 # Close Box
          end
        end
      end
    when Input::LEFT
      if selection == -1 # Box name
        selection = -4 # Move to previous box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
        selection += PokemonBox::BOX_WIDTH - 1
      else
        selection -= 1
      end
    when Input::RIGHT
      if selection == -1 # Box name
        selection = -5 # Move to next box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
        selection -= PokemonBox::BOX_WIDTH - 1
      else
        selection += 1
      end
    end
    return selection
  end

  def pbPartySetArrow(arrow, selection)
    return if selection < 0
    xvalues = [] # [200, 272, 200, 272, 200, 272, 236]
    yvalues = [] # [2, 18, 66, 82, 130, 146, 220]
    for i in 0...Settings::MAX_PARTY_SIZE
      xvalues.push(200 + 72 * (i % 2))
      yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
    end
    xvalues.push(236)
    yvalues.push(220)
    arrow.angle = 0
    arrow.mirror = false
    arrow.ox = 0
    arrow.oy = 0
    arrow.x = xvalues[selection]
    arrow.y = yvalues[selection]
  end

  def pbPartyChangeSelection(key, selection)
    case key
    when Input::LEFT
      selection -= 1
      selection = Settings::MAX_PARTY_SIZE if selection < 0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection > Settings::MAX_PARTY_SIZE
    when Input::UP
      if selection == Settings::MAX_PARTY_SIZE
        selection = Settings::MAX_PARTY_SIZE - 1
      else
        selection -= 2
        selection = Settings::MAX_PARTY_SIZE if selection < 0
      end
    when Input::DOWN
      if selection == Settings::MAX_PARTY_SIZE
        selection = 0
      else
        selection += 2
        selection = Settings::MAX_PARTY_SIZE if selection > Settings::MAX_PARTY_SIZE
      end
    end
    return selection
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
        if selection == -4
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection == -5
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection == -4 || selection == -5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
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
        if selection != -1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == -1 # Box name
          return [-4, -1]
        elsif selection == -2 # Party Pokémon
          return [-2, -1]
        elsif selection == -3 # Close Box
          return [-3, -1]
        end
      end
    end
  end

  def pbSelectBox(party)
    return pbSelectBoxInternal(party) if @command == 1 # Withdraw
    ret = nil
    loop do
      if !@choseFromParty
        ret = pbSelectBoxInternal(party)
      end
      if @choseFromParty || (ret && ret[0] == -2) # Party Pokémon
        if !@choseFromParty
          pbShowPartyTab
          @selection = 0
        end
        ret = pbSelectPartyInternal(party, false)
        if ret < 0
          pbHidePartyTab
          @selection = 0
          @choseFromParty = false
        else
          @choseFromParty = true
          return [-1, ret]
        end
      else
        @choseFromParty = false
        return ret
      end
    end
  end

  def setStartingTab(symbol)
    @command = (symbol == :party ? 1 : 0)   # 1 = party, 0 = box
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
      end
      self.update
      if Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
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

  def pbSelectParty(party)
    return pbSelectPartyInternal(party, true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites = false
    alpha = 0
    Graphics.update
    self.update
    timeTaken = Graphics.frame_rate * 4 / 10
    alphaDiff = (255.0 / timeTaken).ceil
    timeTaken.times do
      alpha += alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
    @sprites["box"].refreshBox = true
    @storage[@storage.currentBox].background = wp
    (Graphics.frame_rate / 10).times do
      Graphics.update
      Input.update
      self.update
    end
    timeTaken.times do
      alpha -= alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
    @sprites["box"].refreshSprites = true
  end

  def pbSwitchBoxToRight(newbox)
    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport, @sprites["box"].isFusionEnabled,@screen.filterProc)
    newbox.x = 520
    Graphics.frame_reset
    distancePerFrame = 64 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x -= distancePerFrame
      newbox.x -= distancePerFrame
      self.update
      break if newbox.x <= 184
    end
    diff = newbox.x - 184
    newbox.x = 184
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
    newbox.refreshAllBoxSprites
    checkOpenTransferBox(newbox.boxnumber)
  end

  def pbSwitchBoxToLeft(newbox)
    newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport, @sprites["box"].isFusionEnabled,@screen.filterProc)
    newbox.x = -152
    Graphics.frame_reset
    distancePerFrame = 64 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x += distancePerFrame
      newbox.x += distancePerFrame
      self.update
      break if newbox.x >= 184
    end
    diff = newbox.x - 184
    newbox.x = 184
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
    newbox.refreshAllBoxSprites
    checkOpenTransferBox(newbox.boxnumber)
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox != newbox
      if newbox > @storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox = newbox
    end
    checkOpenTransferBox(newbox)
  end

  def checkOpenTransferBox(newbox)
    @inTransferBox = @storage[newbox].is_a?(StorageTransferBox)
    if @inTransferBox
      checkTransferBoxTutorial(newbox)
      if @storage[newbox].can_use_transfer_box?
        @storage[newbox].loadTransferBoxPokemon
      else
        @storage[newbox].setDisabled
      end
    end
  end


  def checkTransferBoxTutorial(newbox)
    isTransferBox = @storage[newbox].is_a?(StorageTransferBox)
    if isTransferBox
      unless $PokemonGlobal.seen_transfer_box_tutorial
        transferBoxTutorial
        $PokemonGlobal.seen_transfer_box_tutorial=true
      end
    end
  end
  def pbSetMosaic(selection)
    if !@screen.pbHeldPokemon
      if @boxForMosaic != @storage.currentBox || @selectionForMosaic != selection
        @sprites["pokemon"].mosaic = Graphics.frame_rate / 4
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selection
      end
    end
  end

  def pbSetQuickSwap(value)
    @quickswap = value
    @sprites["arrow"].quickswap = value
  end

  def pbShowPartyTab
    pbSEPlay("GUI storage show party panel")
    distancePerFrame = 48 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y -= distancePerFrame
      self.update
      break if @sprites["boxparty"].y <= Graphics.height - 352
    end
    @sprites["boxparty"].y = Graphics.height - 352
  end

  def pbHidePartyTab
    pbSEPlay("GUI storage hide party panel")
    distancePerFrame = 48 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y += distancePerFrame
      self.update
      break if @sprites["boxparty"].y >= Graphics.height
    end
    @sprites["boxparty"].y = Graphics.height
  end

  def pbHold(selected)
    pbSEPlay("GUI storage pick up")
    if selected[0] == -1
      @sprites["boxparty"].grabPokemon(selected[1], @sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1], @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwap(selected, _heldpoke)
    pbSEPlay("GUI storage pick up")
    heldpokesprite = @sprites["arrow"].heldPokemon
    boxpokesprite = nil
    if selected[0] == -1
      boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite = @sprites["box"].getPokemon(selected[1])
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    @sprites["pokemon"].mosaic = 10
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbPlace(selected, _heldpoke)
    pbSEPlay("GUI storage put down")
    heldpokesprite = @sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if selected[0] == -1
      @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1], heldpokesprite)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbWithdraw(selected, heldpoke, partyindex)
    pbHold(selected) if !heldpoke
    pbShowPartyTab
    pbPartySetArrow(@sprites["arrow"], partyindex)
    pbPlace([-1, partyindex], heldpoke)
    pbHidePartyTab
  end

  def pbStore(selected, heldpoke, destbox, firstfree)
    if heldpoke
      if destbox == @storage.currentBox
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree, heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite = @sprites["boxparty"].getPokemon(selected[1])
      if destbox == @storage.currentBox
        @sprites["box"].setPokemon(firstfree, sprite)
        @sprites["boxparty"].setPokemon(selected[1], nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def pbRelease(selected, heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box == -1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        self.update
      end
    end
  end

  def pbChooseBox(msg)
    commands = []
    boxIndices = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        next if box.is_a?(StorageTransferBox)
        commands.push(_INTL("{1} ({2}/{3})", box.name, box.nitems, box.length))
        boxIndices.push(i)
      end
    end
    defaultIndex = boxIndices.index(@storage.currentBox) || 0
    cmdIndex = pbShowCommands(msg, commands, defaultIndex)
    return cmdIndex >= 0 ? boxIndices[cmdIndex] : -1
  end

  def pbBoxName(helptext, minchars, maxchars)
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = pbEnterBoxName(helptext, minchars, maxchars)
    if ret.length > 0
      @storage[@storage.currentBox].name = ret
    end
    @sprites["box"].refreshBox = true
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbChooseItem(bag)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).can_hold? })
    }
    return ret
  end

  def pbSummary(selected, heldpoke)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke], 0)
    elsif selected[0] == -1
      @selection = screen.pbStartScreen(@storage.party, selected[1])
      pbPartySetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection, @storage.party)
    else
      @selection = screen.pbStartScreen(@storage.boxes[selected[0]], selected[1])
      pbSetArrow(@sprites["arrow"], @selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbMarkingSetArrow(arrow, selection)
    if selection >= 0
      xvalues = [162, 191, 220, 162, 191, 220, 184, 184]
      yvalues = [24, 24, 24, 49, 49, 49, 77, 109]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection] * 2
      arrow.y = yvalues[selection] * 2
    end
  end

  def pbMarkingChangeSelection(key, selection)
    case key
    when Input::LEFT
      if selection < 6
        selection -= 1
        selection += 3 if selection % 3 == 2
      end
    when Input::RIGHT
      if selection < 6
        selection += 1
        selection -= 3 if selection % 3 == 0
      end
    when Input::UP
      if selection == 7;
        selection = 6
      elsif selection == 6;
        selection = 4
      elsif selection < 3;
        selection = 7
      else
        ; selection -= 3
      end
    when Input::DOWN
      if selection == 7;
        selection = 1
      elsif selection == 6;
        selection = 7
      elsif selection >= 3;
        selection = 6
      else
        ; selection += 3
      end
    end
    return selection
  end

  def pbMark(selected, heldpoke)
    @sprites["markingbg"].visible = true
    @sprites["markingoverlay"].visible = true
    msg = _INTL("Mark your Pokémon.")
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.text = msg
    msgwindow.resizeHeightToFit(msg, Graphics.width - 180)
    pbBottomRight(msgwindow)
    base = Color.new(248, 248, 248)
    shadow = Color.new(80, 80, 80)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0] == -1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    markings = pokemon.markings
    index = 0
    redraw = true
    markrect = Rect.new(0, 0, 16, 16)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        for i in 0...6
          markrect.x = i * 16
          markrect.y = (markings & (1 << i) != 0) ? 16 : 0
          @sprites["markingoverlay"].bitmap.blt(336 + 58 * (i % 3), 106 + 50 * (i / 3), @markingbitmap.bitmap, markrect)
        end
        textpos = [
          [_INTL("OK"), 402, 208, 2, base, shadow, 1],
          [_INTL("Cancel"), 402, 272, 2, base, shadow, 1]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
        pbMarkingSetArrow(@sprites["arrow"], index)
        redraw = false
      end
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        oldindex = index
        index = pbMarkingChangeSelection(key, index)
        pbPlayCursorSE if index != oldindex
        pbMarkingSetArrow(@sprites["arrow"], index)
      end
      self.update
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if index == 6 # OK
          pokemon.markings = markings
          break
        elsif index == 7 # Cancel
          break
        else
          mask = (1 << index)
          if (markings & mask) == 0
            markings |= mask
          else
            markings &= ~mask
          end
          redraw = true
        end
      end
    end
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"].visible = false
    msgwindow.dispose
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport,@screen.filterProc)
    @sprites["boxparty"].dispose
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport,@screen.filterProc)
    @sprites["boxparty"].y = oldPartyY
  end

  def drawMarkings(bitmap, x, y, _width, _height, markings)
    markrect = Rect.new(0, 0, 16, 16)
    for i in 0...8
      markrect.x = i * 16
      markrect.y = (markings & (1 << i) != 0) ? 16 : 0
      bitmap.blt(x + i * 16, y, @markingbitmap.bitmap, markrect)
    end
  end

  def pbUpdateOverlay(selection, party = nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248, 248, 248)
    buttonshadow = Color.new(80, 80, 80)
    pbDrawTextPositions(overlay, [
      [_INTL("Party: {1}", (@storage.party.length rescue 0)), 270, 326, 2, buttonbase, buttonshadow, 1],
      [_INTL("Exit"), 446, 326, 2, buttonbase, buttonshadow, 1],
    ])
    pokemon = nil
    if @screen.pbHeldPokemon && !@screen.fusionMode
      pokemon = @screen.pbHeldPokemon
    elsif selection >= 0
      pokemon = (party) ? party[selection] : @storage[@storage.currentBox, selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    nonbase = Color.new(208, 208, 208)
    nonshadow = Color.new(224, 224, 224)

    if isDarkMode
      base, shadow = shadow, base
    end

    pokename = pokemon.name
    textstrings = [
      [pokename, 10, 2, false, base, shadow]
    ]
    if !pokemon.egg?
      imagepos = []
      if pokemon.male?
        textstrings.push(["♂", 148, 2, false, Color.new(24, 112, 216), Color.new(136, 168, 208)])
      elsif pokemon.female?
        textstrings.push(["♀", 148, 2, false, Color.new(248, 56, 32), Color.new(224, 152, 144)])
      end
      imagepos.push(["Graphics/Pictures/Storage/overlay_lv", 6, 246])
      textstrings.push([pokemon.level.to_s, 28, 228, false, base, shadow])
      if pokemon.ability
        textstrings.push([pokemon.ability.name, 86, 300, 2, base, shadow])
      else
        textstrings.push([_INTL("No ability"), 86, 300, 2, base, nonshadow])
      end
      if pokemon.item
        textstrings.push([pokemon.item.name, 86, 336, 2, base, shadow])
      else
        textstrings.push([_INTL("No item"), 86, 336, 2, base, nonshadow])
      end
      if pokemon.shiny?
        addShinyStarsToGraphicsArray(imagepos, 156, 198, pokemon.bodyShiny?, pokemon.headShiny?, pokemon.debugShiny?, pokemon.radarShiny?, nil, nil, nil, nil, false, true)
        # imagepos.push(["Graphics/Pictures/shiny", 156, 198])
      end
      typebitmap = AnimatedBitmap.new("Graphics/Pictures/types")
      type1_number = GameData::Type.get(pokemon.type1).id_number
      type2_number = GameData::Type.get(pokemon.type2).id_number
      type1rect = Rect.new(0, type1_number * 28, 64, 28)
      type2rect = Rect.new(0, type2_number * 28, 64, 28)
      if pokemon.type1 == pokemon.type2
        overlay.blt(52, 272, typebitmap.bitmap, type1rect)
      else
        overlay.blt(18, 272, typebitmap.bitmap, type1rect)
        overlay.blt(88, 272, typebitmap.bitmap, type2rect)
      end
      drawMarkings(overlay, 70, 240, 128, 20, pokemon.markings)
      pbDrawImagePositions(overlay, imagepos)
    end
    pbDrawTextPositions(overlay, textstrings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)

    if pokemon.egg?
      @sprites["pokemon"].zoom_x = Settings::EGGSPRITE_SCALE
      @sprites["pokemon"].zoom_y = Settings::EGGSPRITE_SCALE
    else
      @sprites["pokemon"].zoom_x = Settings::FRONTSPRITE_SCALE
      @sprites["pokemon"].zoom_y = Settings::FRONTSPRITE_SCALE
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def setFusing(fusing, item = 0)
    sprite = @sprites["arrow"].setFusing(fusing)
    if item == :INFINITESPLICERS
      @sprites["arrow"].setSplicerType(2)
    elsif item == :SUPERSPLICERS
      @sprites["arrow"].setSplicerType(1)
    else
      @sprites["arrow"].setSplicerType(0)
    end
    pbRefresh
  end

end
