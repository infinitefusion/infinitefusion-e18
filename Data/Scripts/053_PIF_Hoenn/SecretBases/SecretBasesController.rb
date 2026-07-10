SWITCH_SECRET_BASE_PLACED_FIRST_DECORATION = 2047

class Trainer
  attr_accessor :secretBase
  attr_accessor :owned_decorations
end

class PokemonTemp
  attr_accessor :enteredSecretBaseController
end

class SecretBaseController
  attr_accessor :secretBase

  def initialize(secretBase)
    @secretBase = secretBase
  end

  def callBehaviorPosition(item_position)
    item = @secretBase.layout.get_item_at_position(item_position)
    if item && item.itemTemplate.behavior && item.interactable?(item_position)
      item.itemTemplate.behavior.call(item)
    end
  end
  def furnitureInteract(item_position = [], menuStartIndex=0)
    cmd_labels = {
      use:          _INTL("Use"),
      move:         _INTL("Move"),
      rotate:         _INTL("Rotate"),
      delete:       _INTL("Put away"),
      cancel:       _INTL("Cancel"),
      decorate:     _INTL("Decorate!"),
      storage:      _INTL("Pokémon Storage"),
      item_storage: _INTL("Item Storage")
    }

    item = @secretBase.layout.get_item_at_position(item_position)
    return unless item
    options = []

    if item.itemId == :PC
      pbMessage(_INTL("\\se[PC open]{1} booted up the PC.", $Trainer.name))
      options << :decorate unless @secretBase.is_visitor
      options << :storage
      options << :item_storage
    else
      options << :use if item.itemTemplate.behavior && item.interactable?(item_position)
    end

    options << :move unless @secretBase.is_visitor
    options << :rotate unless @secretBase.is_visitor || item.itemId == :PC
    options << :delete if item.itemTemplate.deletable && !@secretBase.is_visitor
    options << :cancel

    actionable = options - [:cancel]
    if actionable.length == 1
      return executeFurnitureCommand(item, actionable.first,-1)
    end

    choice = optionsMenu(options.map { |cmd| cmd_labels[cmd] },-1,menuStartIndex)
    executeFurnitureCommand(item, options[choice],choice, item_position)
  end

  def executeFurnitureCommand(item, command, commandIndex, position = nil)
    case command
    when :use
      item.itemTemplate.behavior.call(item)
    when :move
      moveSecretBaseItem(item.instanceId, item.position)
    when :rotate
      rotateSecretBaseItem(item.getMainEvent)
      furnitureInteract(position,commandIndex)
    when :delete
      if pbConfirmMessage(_INTL("Put away the {1}?",item.name))
        pbSEPlay("GUI storage put down", 80, 100)
        resetFurniture(item.instanceId)
      else
        furnitureInteract(position,commandIndex)
      end
    when :decorate
      decorateSecretBase
    when :storage
      pbFadeOutIn {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(0)
      }
    when :item_storage
      pbPCItemStorage
    when :cancel
      return
    end
  end

  def reloadItems()
    $PokemonTemp.pbClearTempEvents
    SecretBaseLoader.new.loadSecretBaseFurniture(@secretBase)
  end


  def isMovingFurniture?
    return $game_temp.moving_furniture
  end

  def decorateSecretBase
    cmd_addItem = _INTL("Add a decoration")
    cmd_moveItem = _INTL("Move a decoration")
    cmd_cancel = _INTL("Back")

    commands = []
    commands << cmd_addItem
    commands << cmd_moveItem
    commands << cmd_cancel

    choice = optionsMenu(commands)
    case commands[choice]
    when cmd_addItem
      item_id = selectAnySecretBaseItem
      addSecretBaseItem(item_id)
    when cmd_moveItem
      item_instance = selectPlacedSecretBaseItemInstance
      moveSecretBaseItem(item_instance.instanceId, item_instance.position)
    when cmd_cancel
      return
    end
  end

  def addSecretBaseItem(item_id)
    return if @secretBase.is_a?(VisitorSecretBase)
    echoln "ADDING ITEM #{item_id}"
    if item_id
      new_item_instance = $Trainer.secretBase.layout.add_item(item_id, [$game_player.x, $game_player.y])
      SecretBaseLoader.new.loadSecretBaseFurniture(@secretBase)
      $game_temp.original_direction = $game_player.direction
      $game_player.direction = DIRECTION_DOWN
      moveSecretBaseItem(new_item_instance, nil)
    end
  end

  def rotateSecretBaseItem(event)
    pbSEPlay("GUI party switch", 80, 100)
    direction_fix = event.direction_fix
    event.direction_fix = false
    event.turn_left_90
    event.direction_fix = direction_fix
  end

  def moveSecretBaseItem(itemInstanceId, oldPosition = nil)
    return if @secretBase.is_a?(VisitorSecretBase)
    itemInstance = @secretBase.layout.get_item_by_id(itemInstanceId)

    event = itemInstance.getMainEvent

    $game_player.setPlayerGraphicsOverride("SecretBases/#{itemInstance.getGraphics}")
    $game_player.direction_fix = true
    $game_player.under_player = event.under_player
    $game_player.through = event.through # todo: Make it impossible to go past the walls
    $game_temp.moving_furniture = itemInstanceId
    $game_temp.moving_furniture_oldPlayerPosition = [$game_player.x, $game_player.y]
    $game_temp.moving_furniture_oldItemPosition = oldPosition

    event.opacity = 50 if event
    event.through = true if event

    $game_player.x, $game_player.y = itemInstance.position
    $game_system.menu_disabled = true
    $game_map.refresh
  end

  def cancelMovingFurniture()
    $game_system.menu_disabled = false
    $game_player.removeGraphicsOverride()
    $game_temp.moving_furniture = nil
  end


  def placeFurnitureMenu(menu_position = 0)
    if !$Trainer.secretBase || !$game_temp.moving_furniture
      cancelMovingFurniture()
    end

    cmd_place = _INTL("Place here")
    cmd_rotate = _INTL("Rotate")
    cmd_reset = _INTL("Reset")
    cmd_cancel = _INTL("Cancel")

    options = []
    options << cmd_place
    options << cmd_rotate
    options << cmd_reset
    options << cmd_cancel

    choice = optionsMenu(options, -1, menu_position)
    case options[choice]
    when cmd_place
      placeFurnitureAtCurrentPosition($game_temp.moving_furniture, $game_player.direction)
    when cmd_rotate
      rotateFurniture
      placeFurnitureMenu(choice)
    when cmd_reset
      resetFurniture($game_temp.moving_furniture)
    when cmd_cancel

    end
  end

  def placeFurnitureAtCurrentPosition(furnitureInstanceId, direction)
    $game_switches[SWITCH_SECRET_BASE_PLACED_FIRST_DECORATION] = true
    itemInstance = @secretBase.layout.get_item_by_id(furnitureInstanceId)
    currentPosition = [$game_player.x, $game_player.y]
    itemInstance.position = currentPosition
    itemInstance.direction = direction

    if @secretBase.layout.check_position_available_for_item(itemInstance,currentPosition)
      main_event = itemInstance.getMainEvent
      main_event.direction = $game_player.direction

      $PokemonTemp.pbClearTempEvents
      SecretBaseLoader.new.loadSecretBaseFurniture(@secretBase)

      # Roload after items update
      itemInstance = $Trainer.secretBase.layout.get_item_by_id(furnitureInstanceId)
      event = itemInstance.getMainEvent
      event.direction = $game_player.direction
      resetPlayerPosition
    else
      pbMessage(_INTL("There's no room here!"))
    end
  end

  def resetFurniture(furnitureInstanceId)
    adding_new_item = $game_temp.moving_furniture_oldItemPosition == nil
    itemInstance = $Trainer.secretBase.layout.get_item_by_id(furnitureInstanceId)
    $Trainer.secretBase.layout.remove_item_by_instance(itemInstance.instanceId) if adding_new_item
    reloadItems
    resetPlayerPosition
    itemInstance.dispose if adding_new_item
  end
  def resetPlayerPosition
    return unless $game_temp.moving_furniture
    $game_player.removeGraphicsOverride
    pbFadeOutIn {
      $game_player.direction_fix = false
      if $game_temp.original_direction
        $game_player.direction = $game_temp.original_direction
      end
      $game_player.through = false
      $game_player.under_player = false
      $game_temp.player_new_map_id = $game_map.map_id
      $game_temp.player_new_x = $game_temp.moving_furniture_oldPlayerPosition[0]
      $game_temp.player_new_y = $game_temp.moving_furniture_oldPlayerPosition[1]
      $scene.transfer_player(true)
      $game_map.autoplay
      $game_map.refresh
    }
    $game_temp.moving_furniture_oldPlayerPosition = nil
    $game_temp.moving_furniture_oldItemPosition = nil
    $game_temp.moving_furniture = nil
    $game_system.menu_disabled = false
  end

  def rotateFurniture()
    $game_player.direction_fix = false
    $game_player.turn_right_90
    $game_player.direction_fix = true
  end

end


def getEnteredSecretBase
  controller = $PokemonTemp.enteredSecretBaseController
  return controller.secretBase if controller
end

def getSecretBaseController
  return $PokemonTemp.enteredSecretBaseController
end

def secretBaseItem(event_id)
  return if $game_temp.moving_furniture
  begin
    event = $game_map.events[event_id]
    pos=[event.x,event.y]
    controller=getSecretBaseController
    controller.callBehaviorPosition(pos)
  end
end

def secretBaseItemMenu
  return unless Input.trigger?(Input::C)
  event = $game_player.pbFacingEvent
  return unless event
  event_position = [event.x, event.y]
  controller = getSecretBaseController
  controller.furnitureInteract(event_position)
end


def selectPlacedSecretBaseItemInstance()
  options = []
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    return item_instance if item_name == options[chosen]
  end
  return nil
end

def selectAnySecretBaseItem()
  options = []
  $Trainer.owned_decorations = [] if $Trainer.owned_decorations.nil?
  $Trainer.owned_decorations.each do |item_id|
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.owned_decorations.each do |item_id|
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    return item_id if item_name == options[chosen]
  end
  return nil
end

