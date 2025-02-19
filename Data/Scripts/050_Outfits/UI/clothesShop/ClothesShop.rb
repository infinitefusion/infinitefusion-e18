def genericOutfitsShopMenu(stock = [], itemType = nil, versions = false, isShop=true, message=nil)
  commands = []
  commands[cmdBuy = commands.length] = _INTL("Buy")
  commands[cmdQuit = commands.length] = _INTL("Quit")
  message = _INTL("Welcome! How may I serve you?") if !message
  cmd = pbMessage(message, commands, cmdQuit + 1)
  loop do
    if cmdBuy >= 0 && cmd == cmdBuy
      adapter = getAdapter(itemType, stock, isShop)
      view = ClothesShopView.new()
      presenter = getPresenter(itemType, view, stock, adapter, versions)
      presenter.pbBuyScreen
      break
    else
      pbMessage(_INTL("Please come again!"))
      break
    end
  end
end

def getPresenter(itemType, view, stock, adapter, versions)
  case itemType
  when :HAIR
    return HairShopPresenter.new(view, stock, adapter, versions)
  else
    return ClothesShopPresenter.new(view, stock, adapter, versions)
  end
end

def getAdapter(itemType, stock, isShop)
  case itemType
  when :CLOTHES
    return ClothesMartAdapter.new(stock, isShop)
  when :HAT
    return HatsMartAdapter.new(stock, isShop)
  when :HAIR
    return HairMartAdapter.new(stock, isShop)
  end
end

def list_all_possible_outfits() end

def clothesShop(outfits_list = [], free=false,customMessage=nil)
  stock = []
  outfits_list.each { |outfit_id|
    outfit = get_clothes_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :CLOTHES,false,!free,customMessage)
end

def hatShop(outfits_list = [], free=false, customMessage=nil)
  stock = []
  outfits_list.each { |outfit_id|
    outfit = get_hat_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :HAT,false,!free,customMessage)
end

def hairShop(outfits_list = [],free=false, customMessage=nil)
  currentHair = getSimplifiedHairIdFromFullID($Trainer.hair)
  stock = [:SWAP_COLOR]
  #always add current hairstyle as first option (in case the player just wants to swap the color)
  stock << get_hair_by_id(currentHair) if $Trainer.hair
  outfits_list.each { |outfit_id|
    next if outfit_id == currentHair
    outfit = get_hair_by_id(outfit_id)
    stock << outfit if outfit
  }
  genericOutfitsShopMenu(stock, :HAIR, true,!free,customMessage)
end



SWAP_HAT_POSITIONS_CAPTION = "Switch hats position"
def set_hat_adapter_options(adapter)
  slot1_hat = $Trainer.hat ? "Swap #{get_hat_by_id($Trainer.hat).name}" : "(Empty slot)"
  slot2_hat = $Trainer.hat2 ? "Swap #{get_hat_by_id($Trainer.hat2).name}" : "(Empty slot)"
  options = [slot1_hat,slot2_hat]
  options << SWAP_HAT_POSITIONS_CAPTION if $Trainer.hat && $Trainer.hat2
  options << "Cancel"
  hat_options_choice = optionsMenu(options)
  if options[hat_options_choice] == SWAP_HAT_POSITIONS_CAPTION
    hat1 = $Trainer.hat
    hat2 = $Trainer.hat2
    $Trainer.hat = hat2
    $Trainer.hat2 = hat1
    pbSEPlay("GUI naming tab swap start")
    return set_hat_adapter_options(adapter)
  end
  if hat_options_choice == options.length #cancel
    return nil
  end
  is_secondary = hat_options_choice ==1
  adapter.set_secondary_hat(is_secondary)
  return adapter
end

def openSelectOutfitMenu(stock = [], itemType)
  adapter = getAdapter(itemType, stock, false)
  if adapter.is_a?(HatsMartAdapter)
    adapter = set_hat_adapter_options(adapter)
    return if !adapter
  end
  view = ClothesShopView.new()
  presenter = ClothesShopPresenter.new(view, stock, adapter)
  presenter.pbBuyScreen
end

def changeClothesMenu()
  stock = []
  $Trainer.unlocked_clothes.each { |outfit_id|
    outfit = get_clothes_by_id(outfit_id)
    stock << outfit if outfit
  }
  openSelectOutfitMenu(stock, :CLOTHES)
end

def changeHatMenu()
  stock = []
  $Trainer.unlocked_hats.each { |outfit_id|
    outfit = get_hat_by_id(outfit_id)
    stock << outfit if outfit
  }
  stock << :REMOVE_HAT
  openSelectOutfitMenu(stock, :HAT)
end

def changeOutfit()
  commands = []
  commands[cmdHat = commands.length] = _INTL("Change hat")
  commands[cmdClothes = commands.length] = _INTL("Change clothes")
  commands[cmdQuit = commands.length] = _INTL("Quit")

  cmd = pbMessage(_INTL("What would you like to do?"), commands, cmdQuit + 1)
  loop do
    if cmd == cmdClothes
      changeClothesMenu()
      break
    elsif cmd == cmdHat
      changeHatMenu()
      break
    else
      break
    end
  end



end