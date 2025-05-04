class ClothesShopPresenter < PokemonMartScreen

  def removeHat(item)
    pbSEPlay("GUI storage put down")
    @adapter.toggleEvent(item)
    @scene.select_specific_item(nil,true)
  end

  def wearAsHat1(item)
    @adapter.set_secondary_hat(false)
    putOnClothes(item)
    $Trainer.set_hat_color(@adapter.get_dye_color(item.id),false)
  end
  def wearAsHat2(item)
    @adapter.set_secondary_hat(true)
    putOnClothes(item)
    $Trainer.set_hat_color(@adapter.get_dye_color(item.id),true)
  end

  def removeDye(item)
    if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
      $Trainer.set_hat_color(0,@adapter.is_secondary_hat)
    end
  end

  def swapHats()
    echoln "hat 1: #{$Trainer.hat}"
    echoln "hat 2: #{$Trainer.hat2}"


    $Trainer.hat, $Trainer.hat2 = $Trainer.hat2, $Trainer.hat

    pbSEPlay("GUI naming tab swap start")
    new_selected_hat = @adapter.is_secondary_hat ? $Trainer.hat2 : $Trainer.hat
    echoln "hat 1: #{$Trainer.hat}"
    echoln "hat 2: #{$Trainer.hat2}"
    echoln "new selected hat: #{new_selected_hat}"

    @scene.select_specific_item(new_selected_hat,true)
    @scene.updatePreviewWindow
  end


  def build_options_menu(item,cmd_confirm,cmd_remove,cmd_dye,cmd_swap,cmd_cancel)
    options = []
    options << cmd_confirm
    options << cmd_remove

    options << cmd_swap
    options << cmd_dye if $PokemonBag.pbHasItem?(:HATSDYEKIT)
    options << cmd_cancel
  end

  def build_wear_options(cmd_wear_hat1,cmd_wear_hat2,cmd_replace_hat1,cmd_replace_hat2)
    options = []
    primary_hat, secondary_hat = @adapter.worn_clothes, @adapter.worn_clothes2
    primary_cmds = primary_hat ? cmd_replace_hat1 : cmd_wear_hat1
    secondary_cmds = secondary_hat ? cmd_replace_hat2 : cmd_wear_hat2

    if @adapter.is_secondary_hat
      options << secondary_cmds
      options << primary_cmds
    else
      options << primary_cmds
      options << secondary_cmds
    end
    return options
  end


  def putOnHats()
    @adapter.worn_clothes = $Trainer.hat
    @adapter.worn_clothes2 = $Trainer.hat2

    putOnHat($Trainer.hat,true,false)
    putOnHat($Trainer.hat2,true,true)

    playOutfitChangeAnimation()
    pbMessage(_INTL("You put on the hat(s)!\\wtnp[30]"))
  end

  def dyeOptions(secondary_hat=false,item)
    original_color = secondary_hat ? $Trainer.hat2_color : $Trainer.hat_color
    options = ["Shift up", "Shift down", "Reset", "Confirm", "Never Mind"]
    previous_input = 0
    while (true)
      choice = pbShowCommands(nil, options, options.length, previous_input,200)
      previous_input = choice
      case choice
      when 0 #NEXT
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftHatColor(10,secondary_hat)
        ret = true
      when 1 #PREVIOUS
        pbSEPlay("GUI storage pick up", 80, 100)
        shiftHatColor(-10,secondary_hat)
        ret = true
      when 2 #Reset
        pbSEPlay("GUI storage put down", 80, 100)
        $Trainer.hat_color = 0 if !secondary_hat
        $Trainer.hat2_color = 0 if secondary_hat
        ret = false
      when 3 #Confirm
        break
      else
        $Trainer.hat_color = original_color if !secondary_hat
        $Trainer.hat2_color = original_color if secondary_hat
        ret = false
        break
      end
      @scene.updatePreviewWindow
      @scene.displayLayerIcons(item)
    end
    return ret
  end

  def confirmPutClothes(item)
    if @adapter.is_a?(HatsMartAdapter)
      putOnHats()
      $Trainer.hat_color = @adapter.get_dye_color($Trainer.hat)
      $Trainer.hat2_color = @adapter.get_dye_color($Trainer.hat2)
    else
      putOnClothes(item,false)
    end
  end

  def playerHatActionsMenu(item)
    cmd_confirm = "Confirm"
    cmd_remove = "Remove hat"
    cmd_cancel = "Cancel"
    cmd_dye = "Dye Kit"
    cmd_swap = "Swap hat positions"

    options = build_options_menu(item,cmd_confirm,cmd_remove,cmd_dye,cmd_swap,cmd_cancel)
    choice = pbMessage("What would you like to do?", options, -1,nil,0)
    if options[choice] == cmd_remove
      removeHat(item)
      return true
    elsif options[choice] == cmd_confirm
      confirmPutClothes(nil)
      return true
    elsif options[choice] == cmd_dye
      dyeOptions(@adapter.is_secondary_hat,item)
      return true
    elsif options[choice] == cmd_swap
      swapHats()
      return true
    elsif options[choice] == "dye"
      selectHatColor
    end
    @scene.updatePreviewWindow
    return true
    end
end
