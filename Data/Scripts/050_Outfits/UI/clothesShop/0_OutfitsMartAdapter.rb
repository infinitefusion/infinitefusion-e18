class OutfitsMartAdapter < PokemonMartAdapter
  attr_accessor :worn_clothes

  WORN_ITEM_BASE_COLOR = MessageConfig::BLUE_TEXT_MAIN_COLOR
  WORN_ITEM_SHADOW_COLOR = MessageConfig::BLUE_TEXT_SHADOW_COLOR

  def initialize(stock = [], isShop = true)
    @items = stock
    @worn_clothes = get_current_clothes()
    @isShop = isShop
    @version = nil
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

  def getBaseColorOverride(item)
    return WORN_ITEM_BASE_COLOR if isWornItem?(item)
    return nil
  end

  def getShadowColorOverride(item)
    return WORN_ITEM_SHADOW_COLOR if isWornItem?(item)
    return nil
  end

  def getMoney
    super
  end

  def getMoneyString
    super
  end

  def setMoney(value)
    super
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
end
