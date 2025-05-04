class ClothesShopView < PokemonMart_Scene

  def initialize(currency_name = "Money")
    @currency_name = currency_name
  end

  def pbStartBuyOrSellScene(buying, stock, adapter)
    super(buying, stock, adapter)
    @sprites["icon"].visible = false
    if @adapter.isShop?
      @sprites["background"].setBitmap("Graphics/Pictures/martScreenOutfit")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/changeOutfitScreen")
    end

    preview_y = @adapter.isShop? ? 80 : 0
    @sprites["trainerPreview"] = TrainerClothesPreview.new(0, preview_y, true, "WALLET")

    @sprites["trainerPreview"].show()
    @sprites["moneywindow"].visible = false if !@adapter.isShop?

    Kernel.pbDisplayText(@adapter.toggleText, 80, 200, 99999) if @adapter.toggleText

  end

  def scroll_map
    pbScrollMap(DIRECTION_UP, 5, 6)
    pbScrollMap(DIRECTION_RIGHT, 7, 6)
    @initial_direction = $game_player.direction
    $game_player.turn_down
    pbRefreshSceneMap
  end

  def scroll_back_map
    @adapter.reset_player_clothes()
    pbScrollMap(DIRECTION_LEFT, 7, 6)
    pbScrollMap(DIRECTION_DOWN, 5, 6)
    $game_player.turn_generic(@initial_direction)
    #$scene.reset_map(true)
    #pbRefreshSceneMap
    # $scene.reset_map(false)
  end

  def refreshStock(adapter)
    @adapter = adapter
    @sprites["itemwindow"].dispose
    @sprites["itemwindow"] = Window_PokemonMart.new(@stock, BuyAdapter.new(adapter),
                                                    Graphics.width - 316 - 16, 12, 330 + 16, Graphics.height - 126)
  end

  def pbRefresh
    if @subscene
      @subscene.pbRefresh
    else
      itemwindow = @sprites["itemwindow"]
      #@sprites["icon"].item = itemwindow.item
      #@sprites["icon"].item = itemwindow.item

      item = itemwindow.item
      if itemwindow.item
        if itemwindow.item.is_a?(Symbol)
          text = @adapter.getSpecialItemCaption(item)
        else
          text = @adapter.getDescription(item)
        end
      else
        text = _INTL("Quit.")
      end
      @sprites["itemtextwindow"].text = text
      itemwindow.refresh
    end
    @sprites["moneywindow"].text = _INTL("{2}:\r\n<r>{1}", @adapter.getMoneyString, @currency_name)
  end

  def updateTrainerPreview()
    displayNewItem(@sprites["itemwindow"])
  end

  def displayNewItem(itemwindow)
    item = itemwindow.item
    if item
      if item.is_a?(Symbol)
        description = @adapter.getSpecialItemDescription(itemwindow.item)
      else
        description = @adapter.getDescription(itemwindow.item)
      end
      @adapter.updateTrainerPreview(itemwindow.item, @sprites["trainerPreview"])
    else
      description = _INTL("Quit.")
    end
    @sprites["itemtextwindow"].text = description
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    refreshStock(@adapter) if !itemwindow
    displayNewItem(itemwindow)
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          displayNewItem(itemwindow)
        end
        if Input.trigger?(Input::AUX1) #L button  - disabled  because same key as speed up...
          #@adapter.switchVersion(itemwindow.item, -1)
          #updateTrainerPreview()
        end
        if Input.trigger?(Input::AUX2) #R button
          @adapter.switchVersion(itemwindow.item, 1)
          updateTrainerPreview()
        end
        if Input.trigger?(Input::SPECIAL) #R button
          @adapter.toggleEvent(itemwindow.item)
          updateTrainerPreview()
        end

        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          if itemwindow.item.is_a?(Symbol)
            @adapter.doSpecialItemAction(itemwindow.item)
            updateTrainerPreview()
          elsif itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    }
  end

  def update
    if Input.trigger?(Input::LEFT)
      pbSEPlay("GUI party switch", 80, 100)
      $game_player.turn_right_90
      pbRefreshSceneMap
    end
    if Input.trigger?(Input::RIGHT)
      pbSEPlay("GUI party switch", 80, 100)
      $game_player.turn_left_90
      pbRefreshSceneMap
    end
    super
  end

  def pbEndBuyScene
    if !@sprites.empty?
      @sprites["trainerPreview"].erase()
      @sprites["trainerPreview"] = nil
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Kernel.pbClearText()
    # Scroll left after showing screen
    scroll_back_map()
  end

end
