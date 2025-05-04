class ClothesShopPresenter < PokemonMartScreen
  def pbChooseBuyItem

  end

  def initialize(scene, stock, adapter = nil, versions = false)
    super(scene, stock, adapter)
    @use_versions = versions
  end

  def putOnClothes(item,end_scene=true)
    @adapter.putOnOutfit(item) if item
    @scene.pbEndBuyScene if end_scene
  end


  def dyeClothes()
    original_color = $Trainer.clothes_color
    options = ["Shift up", "Shift down", "Reset", "Confirm", "Never Mind"]
    previous_input = 0
    ret = false
    while (true)
      choice = pbShowCommands(nil, options, options.length, previous_input,200)
      previous_input = choice
      case choice
      when 0 #NEXT
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftClothesColor(10)
        ret = true
      when 1 #PREVIOUS
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftClothesColor(-10)
        ret = true
      when 2 #Reset
        pbSEPlay("GUI storage pick up", 80, 100)
        $Trainer.clothes_color = 0
        ret = false
      when 3 #Confirm
        break
      else
        $Trainer.clothes_color = original_color
        ret = false
        break
      end
      @scene.updatePreviewWindow
    end
    return ret
  end


  # returns true if should stay in the menu
  def playerClothesActionsMenu(item)
    cmd_wear = "Wear"
    cmd_dye = "Dye Kit"
    options = []
    options << cmd_wear
    options << cmd_dye  if $PokemonBag.pbHasItem?(:CLOTHESDYEKIT)
    options << "Cancel"
    choice = pbMessage("What would you like to do?", options, -1)

    if options[choice] == cmd_wear
      putOnClothes(item,false)
      $Trainer.clothes_color = @adapter.get_dye_color(item.id)
      return true
    elsif options[choice] == cmd_dye
      dyeClothes()
    end
    return true
  end

  def confirmPutClothes(item)
    putOnClothes(item)
  end

  def quitMenuPrompt()
    return true if !(@adapter.is_a?(HatsMartAdapter) || @adapter.is_a?(ClothesMartAdapter))
    boolean_changes_detected = @adapter.player_changed_clothes?
    return true if !boolean_changes_detected
    pbPlayCancelSE
    cmd_confirm = "Set outfit"
    cmd_discard = "Discard changes"
    cmd_cancel = "Cancel"
    options = [cmd_discard,cmd_confirm,cmd_cancel]
    choice = pbMessage("You have unsaved changes!",options,3)
    case options[choice]
    when cmd_confirm
      @adapter.putOnSelectedOutfit
      pbPlayDecisionSE
      return true
    when cmd_discard
      pbPlayCloseMenuSE
      return true
    else
      return false
    end
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    @scene.select_specific_item(@adapter.worn_clothes) if !@adapter.isShop?
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      if !item
        break if @adapter.isShop?
        #quit_menu_choice = quitMenuPrompt()
        #break if quit_menu_choice
        break
        next
      end


      if !@adapter.isShop?
        if @adapter.is_a?(ClothesMartAdapter)
          stay_in_menu = playerClothesActionsMenu(item)
          next if stay_in_menu
          return
        elsif @adapter.is_a?(HatsMartAdapter)
          stay_in_menu = playerHatActionsMenu(item)
          next if stay_in_menu
          return
        else
          if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
            confirmPutClothes(item)
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
    end
    @scene.pbEndBuyScene
  end

end