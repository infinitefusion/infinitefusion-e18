class OutfitsMartAdapter < PokemonMartAdapter
  attr_accessor :worn_clothes
  attr_accessor :is_secondary_hat
  attr_accessor :items

  WORN_ITEM_BASE_COLOR = MessageConfig::BLUE_TEXT_MAIN_COLOR
  WORN_ITEM_SHADOW_COLOR = MessageConfig::BLUE_TEXT_SHADOW_COLOR




  def initialize(stock = [], isShop = true, isSecondaryHat = false, prices_override = {})
    @is_secondary_hat = isSecondaryHat
    @items = stock
    @worn_clothes = get_current_clothes()
    @isShop = isShop
    @version = nil
    @prices_override = prices_override
    $Trainer.dyed_hats = {} if !$Trainer.dyed_hats
    $Trainer.dyed_clothes = {} if !$Trainer.dyed_clothes


    @REGIONAL_SET_BASE_COLOR =   Color.new(76,72,104)
    @REGIONAL_SET_SHADOW_COLOR =   Color.new(173,165,189)

    @CITY_EXCLUSIVE_BASE_COLOR =   Color.new(61 , 125, 70) #Color.new(72 , 104, 83)
    @CITY_EXCLUSIVE_SHADOW_COLOR =   Color.new(165, 189, 178)

    if isDarkMode
      @REGIONAL_SET_BASE_COLOR, @REGIONAL_SET_SHADOW_COLOR = @REGIONAL_SET_SHADOW_COLOR, @REGIONAL_SET_BASE_COLOR
      @CITY_EXCLUSIVE_BASE_COLOR, @CITY_EXCLUSIVE_SHADOW_COLOR = @CITY_EXCLUSIVE_SHADOW_COLOR, @CITY_EXCLUSIVE_BASE_COLOR
    end
  end


  def list_regional_set_items()
    return []
  end

  def list_city_exclusive_items()
    return []
  end

  def getDisplayName(item)
    return getName(item) if !item.name
    name = item.name
    name = "* #{name}" if is_wearing_clothes(item.id)
    return name
  end

  def is_wearing_clothes(outfit_id)
    return outfit_id == @worn_clothes
  end

  def player_changed_clothes?()
    return false
    #implement in inheriting classes
  end

  def toggleText()
    return ""
  end

  def switchVersion(item,delta=1)
    return
  end

  def toggleEvent(item)
    return
  end

  def isWornItem?(item)
    return false
  end

  def isShop?()
    return @isShop
  end

  def getPrice(item, selling = nil)
    return 0 if !@isShop
    if @prices_override && @prices_override.has_key?(item.id)
      return @prices_override[item.id]
    end
    return nil if itemOwned(item)
    return item.price.to_i
  end

  def getDisplayPrice(item, selling = nil)
    return "" if !@isShop
    return "-" if itemOwned(item)
    super
  end

  def updateStock()
    updated_items = []
    for item in @items
      updated_items << item if !get_unlocked_items_list().include?(item.id)
    end
    @items = updated_items
  end

  def removeItem(item)
    super
  end

  def itemOwned(item)
    owned_list = get_unlocked_items_list()
    return owned_list.include?(item.id)
  end

  def canSell?(item)
    super
  end

  def isItemInRegionalSet(item)
    return false if Settings::HOENN
    return item.is_in_regional_set
  end

  def isItemCityExclusive(item)
    return item.is_in_city_exclusive_set
  end

  def getBaseColorOverride(item)
      return @REGIONAL_SET_BASE_COLOR if isItemInRegionalSet(item)
      return @CITY_EXCLUSIVE_BASE_COLOR  if isItemCityExclusive(item)
      return nil
  end

  def getShadowColorOverride(item)
    return @REGIONAL_SET_SHADOW_COLOR if isItemInRegionalSet(item)
    return @CITY_EXCLUSIVE_SHADOW_COLOR  if isItemCityExclusive(item)
    return nil
  end

  def getMoney
    if Settings::HOENN
      return $Trainer.cosmetics_money
    else
      super
    end
  end

  def getMoneyString
    if Settings::HOENN
      $Trainer.cosmetics_money = 0 unless $Trainer.cosmetics_money
      return pbGetCosmeticsMoneyString
    else
      super
    end
  end

  def setMoney(value)
    if Settings::HOENN
      $Trainer.cosmetics_money = value
    else
      super
    end
  end

  def getItemIconRect(_item)
    super
  end

  def getQuantity(item)
    super
  end

  def showQuantity?(item)
    super
  end

  def updateVersion(item)
    @version = 1 if !currentVersionExists?(item)
  end

  def currentVersionExists?(item)
    return true
  end
end
