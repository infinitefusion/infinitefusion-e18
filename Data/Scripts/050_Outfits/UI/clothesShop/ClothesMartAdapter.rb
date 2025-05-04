class ClothesMartAdapter < OutfitsMartAdapter

  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A piece of clothing that trainers can wear."
  def toggleEvent(item)
    if !isShop? && $Trainer.clothes_color != 0
      if pbConfirmMessage(_INTL("Would you like to remove the dye?"))
        $Trainer.clothes_color = 0
      end
    end
  end

  def initialize(stock = nil, isShop = nil)
    super
  end

  def getName(item)
    name= item.id
    name = "* #{name}" if is_wearing_clothes(item.id)
    return name
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    return getOverworldOutfitFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    return if !item
    previewWindow.clothes = item.id
    $Trainer.clothes = item.id
    set_dye_color(item,previewWindow)

    pbRefreshSceneMap
    previewWindow.updatePreview()
  end

  def get_dye_color(item_id)
    return 0 if isShop?
    $Trainer.dyed_clothes= {} if ! $Trainer.dyed_clothes
    if $Trainer.dyed_clothes.include?(item_id)
      return $Trainer.dyed_clothes[item_id]
    end
    return 0
  end

  def set_dye_color(item,previewWindow)
    if !isShop?
      $Trainer.dyed_clothes= {} if ! $Trainer.dyed_clothes
      if $Trainer.dyed_clothes.include?(item.id)
        dye_color = $Trainer.dyed_clothes[item.id]
        $Trainer.clothes_color = dye_color
        previewWindow.clothes_color = dye_color
      else
        $Trainer.clothes_color=0
        previewWindow.clothes_color=0
      end
    else
      $Trainer.clothes_color=0
      previewWindow.clothes_color=0
    end
  end

  def addItem(item)
    changed_clothes = obtainClothes(item.id)
    if changed_clothes
      @worn_clothes = item.id
    end
  end

  def get_current_clothes()
    return $Trainer.clothes
  end

  def player_changed_clothes?()
    $Trainer.clothes != @worn_clothes
  end

  def putOnSelectedOutfit()
    putOnClothes($Trainer.clothes)
    @worn_clothes = $Trainer.clothes
  end

  def putOnOutfit(item)
    putOnClothes(item.id) if item
    @worn_clothes = item.id if item
  end

  def reset_player_clothes()
    $Trainer.clothes = @worn_clothes
    $Trainer.clothes_color = $Trainer.dyed_clothes[@worn_clothes] if  $Trainer.dyed_clothes && $Trainer.dyed_clothes[@worn_clothes]
  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_clothes
  end

  def isWornItem?(item)
    super
  end
end
