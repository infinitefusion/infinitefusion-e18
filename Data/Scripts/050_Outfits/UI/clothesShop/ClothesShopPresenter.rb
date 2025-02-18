class ClothesShopPresenter < PokemonMartScreen
  def pbChooseBuyItem

  end

  def initialize(scene, stock, adapter = nil, versions = false)
    super(scene, stock, adapter)
    @use_versions = versions
  end

  def putOnClothes(item)
    @adapter.putOnOutfit(item)
    @scene.pbEndBuyScene
  end

  def playerHatActionsMenu(item)
    is_player_hat = item.id == @adapter.worn_clothes
    options = []
    if is_player_hat
      options << "Take off"
    else
      options << "Wear"
    end

    remove_dye_option_available = $Trainer.hat_color != 0
    options << "Remove dye" if remove_dye_option_available
    options << "Mark as favorite" if $Trainer.favorite_hat != item.id
    options << "Unmark as favorite" if $Trainer.favorite_hat == item.id

    options << "Cancel"
    # if $Trainer.hat_color != 0
    choice = pbMessage("What would you like to do?", options, -1)
    if choice == 0
      if is_player_hat # remove
        @adapter.doSpecialItemAction(:REMOVE)
        @scene.pbEndBuyScene
        return false
      else
        # wear
        putOnClothes(item)
        $Trainer.hat_color = @adapter.get_dye_color(item)
        return false
      end
    elsif choice == 1 && remove_dye_option_available
      if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
        $Trainer.hat_color = 0
      end
      return true
    elsif options[choice] == "Mark as favorite"
        $Trainer.favorite_hat = item.id
        pbSEPlay("GUI storage show party panel")
        pbMessage("The #{item.name} is now your favorite!")
        echoln "marked #{item.id} as favorite hat"
    elsif options[choice] == "Unmark as favorite"
      $Trainer.favorite_hat = nil
      pbSEPlay("GUI storage show party panel")
      pbMessage("The #{item.name} is no longer marked as your favorite!")
    end
    echoln "cancelled"
    return true
  end

  # returns if should stay in the menu
  def playerClothesActionsMenu(item)
    is_worn = item.id == @adapter.worn_clothes
    options = []
    options << "Wear"
    options << "Remove dye" if $Trainer.clothes_color != 0
    options << "Mark as favorite" if $Trainer.favorite_hat != item.id
    options << "Unmark as favorite" if $Trainer.favorite_hat == item.id
    options << "Cancel"
    choice = pbMessage("What would you like to do?", options, -1)

    if choice == 0
      putOnClothes(item)
      $Trainer.clothes_color = @adapter.get_dye_color(item)
      return false
    elsif options[choice] == "Remove dye"
      if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
        $Trainer.clothes_color = 0
      end
    elsif options[choice] == "Mark as favorite"
        $Trainer.favorite_clothes = item.id
        pbSEPlay("GUI storage show party panel")
        pbMessage("The #{item.name} is now your favorite!")
    elsif options[choice] == "Unmark favorite"
      $Trainer.favorite_clothes = nil
      pbSEPlay("GUI storage show party panel")
      pbMessage("The #{item.name} is no longer marked as your favorite!")
    end
    return true
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item

      if !@adapter.isShop?
        if @adapter.is_a?(ClothesMartAdapter)
          stay_in_menu = playerClothesActionsMenu(item)
          next if stay_in_menu
          return
        elsif @adapter.is_a?(HatsMartAdapter)
          stay_in_menu = playerHatActionsMenu(item)
          echoln stay_in_menu
          next if stay_in_menu
          return
        else
          if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
            putOnClothes(item)
            return
          end
          next
        end
        next
      end
      itemname = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)
      if !price.is_a?(Integer)
        pbDisplayPaused(_INTL("You already own this item!"))
        if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
          @adapter.putOnOutfit(item)
        end
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end

      if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
                          itemname, price.to_s_formatted))
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      @adapter.setMoney(@adapter.getMoney - price)
      @stock.compact!
      pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
      @adapter.addItem(item)
      # break
    end
    @scene.pbEndBuyScene
  end

end