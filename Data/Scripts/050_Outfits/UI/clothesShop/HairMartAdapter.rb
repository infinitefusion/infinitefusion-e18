class HairMartAdapter < OutfitsMartAdapter
  DEFAULT_NAME = "[unknown]"
  DEFAULT_DESCRIPTION = "A hairstyle for trainers."

  POSSIBLE_VERSIONS = (1..9).to_a

  def initialize(stock = nil, isShop = nil)
    super

    @version = getCurrentHairVersion().to_i
    @worn_hair = $Trainer.hair
    @worn_hat = $Trainer.hat
    @worn_hat2 = $Trainer.hat2

    @hat_visible = false
    @removable = true
    @previous_item= find_first_item()
  end

  def find_first_item()
    return @items.find { |item| item.is_a?(Outfit) }
  end

  def switchVersion(item, delta = 1)
    if !item.is_a?(Outfit)
      item = @previous_item
    end
    pbSEPlay("GUI party switch", 80, 100)
    newVersion = @version + delta
    lastVersion = findLastHairVersion(item.id)
    newVersion = lastVersion if newVersion <= 0
    newVersion = 1 if newVersion > lastVersion
    @version = newVersion
  end

  def player_changed_clothes?()
    $Trainer.hairstyle != @worn_hair
  end

  #player can't "own" hairstyles
  # if you want to go back one you had before, you have to pay again
  def itemOwned(item)
    return false
  end

  def toggleEvent(item)
    pbSEPlay("GUI storage put down", 80, 100)
    toggleHatVisibility()
  end

  def toggleText()
    text = ""
    #text << "Color: R, \n"
    text << "Toggle Hat: D\n"

  end

  def toggleHatVisibility()
    @hat_visible = !@hat_visible
  end

  def getPrice(item, selling = nil)
    return 0 if !@isShop
    trainer_hair_id = getSplitHairFilenameAndVersionFromID(@worn_hair)[1]


    return nil if item.id == trainer_hair_id
    return item.price.to_i
  end

  def getDisplayPrice(item, selling = nil)
    trainerStyleID = getSplitHairFilenameAndVersionFromID(@worn_hair)[1]
    return "-" if item.id == trainerStyleID
    super
  end

  def getCurrentHairVersion()
    begin
      return getSplitHairFilenameAndVersionFromID($Trainer.hair)[0]
    rescue
      return 1
    end
  end

  def getCurrentHairId(itemId)
    return getFullHairId(itemId, @version)
  end

  def getName(item)
    echoln $Trainer.hair
    return item.id
  end

  def getDescription(item)
    return DEFAULT_DESCRIPTION if !item.description
    return item.description
  end

  def getItemIcon(item)
    return Settings::BACK_ITEM_ICON_PATH if !item
    itemId = getCurrentHairId(item.id)
    return getOverworldHatFilename(item.id)
  end

  def updateTrainerPreview(item, previewWindow)
    item = @previous_item if !item
    item = @previous_item if item.is_a?(Symbol)
    @previous_item = find_first_item() if !item.is_a?(Symbol)
    displayed_hat = @hat_visible ? @worn_hat : nil
    displayed_hat2 = @hat_visible ? @worn_hat2 : nil

    previewWindow.hat = displayed_hat
    previewWindow.hat2 = displayed_hat2

    $Trainer.hat = displayed_hat
    $Trainer.hat2 = displayed_hat2

    itemId = getCurrentHairId(item.id)
    previewWindow.hair = itemId
    $Trainer.hair = itemId
    pbRefreshSceneMap
    previewWindow.updatePreview()
  end

  def addItem(item)
    itemId = getCurrentHairId(item.id)

    obtainNewHairstyle(itemId)
    @worn_hair = itemId
  end

  def get_current_clothes()
    return $Trainer.hair
  end

  def putOnOutfit(item)
    itemFullId = getCurrentHairId(item.id)
    putOnHair(item.id, @version)
    @worn_hair = itemFullId
  end

  def reset_player_clothes()
    # can change hair color for free if not changing the style
    if getVersionFromFullID(@worn_hair) != @version
      worn_id = getSimplifiedHairIdFromFullID(@worn_hair)
      if getSimplifiedHairIdFromFullID($Trainer.hair) == worn_id
        @worn_hair = getFullHairId(worn_id,@version)
      end
    end

    $Trainer.hair = @worn_hair
    $Trainer.hat = @worn_hat
    $Trainer.hat2 = @worn_hat2

  end

  def get_unlocked_items_list()
    return $Trainer.unlocked_hairstyles
  end


  def getSpecialItemCaption(specialType)
    case specialType
    when :SWAP_COLOR
      return "Swap Color"
    end
    return nil
  end

  def getSpecialItemBaseColor(specialType)
    case specialType
    when :SWAP_COLOR
      return MessageConfig::BLUE_TEXT_MAIN_COLOR
    end
    return nil
  end

  def getSpecialItemShadowColor(specialType)
    case specialType
    when :SWAP_COLOR
      return MessageConfig::BLUE_TEXT_SHADOW_COLOR
    end
    return nil
  end

  def getSpecialItemDescription(specialType)
    return "Swap to the next base hair color."
  end

  def doSpecialItemAction(specialType)
    switchVersion(nil,1)
  end

end
