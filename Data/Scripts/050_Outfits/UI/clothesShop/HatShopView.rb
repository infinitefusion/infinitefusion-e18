# frozen_string_literal: true

class HatShopView < ClothesShopView

  def initialize(currency_name = "Money")
    @currency_name = currency_name
  end


  def pbStartBuyOrSellScene(buying, stock, adapter)
    super(buying, stock, adapter)
    if !@adapter.isShop?
      @sprites["hatLayer_selected1"] = IconSprite.new(0, 0, @viewport)
      @sprites["hatLayer_selected2"] = IconSprite.new(0, 0, @viewport)

      @sprites["hatLayer_selected1"].setBitmap("Graphics/Pictures/Outfits/hatLayer_selected1")
      @sprites["hatLayer_selected2"].setBitmap("Graphics/Pictures/Outfits/hatLayer_selected2")

      updateSelectedLayerGraphicsVisibility

      @sprites["wornHat_layer1"] = IconSprite.new(25, 200, @viewport)
      @sprites["wornHat_layer2"] = IconSprite.new(95, 200, @viewport)

      displayLayerIcons
    end
  end

  def switchItemVersion(itemwindow)
    @adapter.switchVersion(itemwindow.item, 1)
    new_selected_hat = @adapter.is_secondary_hat ? $Trainer.hat2 : $Trainer.hat
    select_specific_item(new_selected_hat,true)
    updateTrainerPreview()
  end

  def onSpecialActionTrigger(itemwindow)
    #@adapter.doSpecialItemAction(itemwindow.item)
    #updateTrainerPreview()
    return @stock[itemwindow.index]
  end

  def handleHatlessLayerIcons(selected_item)
    other_hat = @adapter.is_secondary_hat ? $Trainer.hat : $Trainer.hat2
    if !selected_item.is_a?(Hat)
      if @adapter.is_secondary_hat
        @sprites["wornHat_layer2"].bitmap=nil
      else
        @sprites["wornHat_layer1"].bitmap=nil
      end
    end
    if !other_hat.is_a?(Hat)
      if @adapter.is_secondary_hat
        @sprites["wornHat_layer1"].bitmap=nil
      else
        @sprites["wornHat_layer2"].bitmap=nil
      end
    end

  end
  def displayLayerIcons(selected_item=nil)
    handleHatlessLayerIcons(selected_item)

    hat1Filename = getOverworldHatFilename($Trainer.hat)
    hat2Filename = getOverworldHatFilename($Trainer.hat2)


    hat_color_shift = $Trainer.dyed_hats[$Trainer.hat]
    hat2_color_shift = $Trainer.dyed_hats[$Trainer.hat2]

    hatBitmapWrapper = AnimatedBitmap.new(hat1Filename, hat_color_shift) if pbResolveBitmap(hat1Filename)
    hat2BitmapWrapper = AnimatedBitmap.new(hat2Filename, hat2_color_shift) if pbResolveBitmap(hat2Filename)

    @sprites["wornHat_layer1"].bitmap = hatBitmapWrapper.bitmap if hatBitmapWrapper
    @sprites["wornHat_layer2"].bitmap = hat2BitmapWrapper.bitmap if hat2BitmapWrapper

    frame_width=80
    frame_height=80

    @sprites["wornHat_layer1"].src_rect.set(0, 0, frame_width, frame_height) if hatBitmapWrapper
    @sprites["wornHat_layer2"].src_rect.set(0, 0, frame_width, frame_height) if hat2BitmapWrapper
  end


  def updateSelectedLayerGraphicsVisibility()
    @sprites["hatLayer_selected1"].visible = !@adapter.is_secondary_hat
    @sprites["hatLayer_selected2"].visible = @adapter.is_secondary_hat
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
      displayLayerIcons(item)
    else
      description = _INTL("Quit.")
    end
    @sprites["itemtextwindow"].text = description
  end

  def updateTrainerPreview()
    super
    updateSelectedLayerGraphicsVisibility
  end

end
