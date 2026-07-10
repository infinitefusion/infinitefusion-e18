# For more complex item behaviors - to keep things organized

def useSecretBaseMannequin
  # Todo: This is the item that players can use to "place themselves" in the base.
  # When a base has a mannequin, the base will be shared online and
  # the mannequin will appear as the player in other people's games.


  secretBase = getEnteredSecretBase
  if secretBase && secretBase.is_visitor
    interact_other_player(secretBase)
  else
    secret_base_mannequin_menu(secretBase)
  end
  return
end

def secret_base_mannequin_menu(secretBase)
  friend_bases = SecretBaseLoader.new.list_friend_bases

  cmd_share = _INTL("Share your secret base")
  cmd_import = _INTL("Import a friend's secret base")
  cmd_removeFriend = _INTL("Remove a friend's secret base")
  cmd_setTeam = _INTL("Set your base's Team")
  cmd_trainerID = _INTL("[DEBUG] Copy your Trainer ID")
  cmd_export = _INTL("[DEBUG] Export base to clipboard")
  cmd_cancel = _INTL("Cancel")
  commands = [cmd_share, cmd_setTeam, cmd_import]
  commands << cmd_removeFriend if !friend_bases.empty?
  commands << cmd_trainerID if $DEBUG
  commands << cmd_export if $DEBUG
  commands << cmd_cancel
  pbMessage(_INTL("What would you like to do?"))
  choice = optionsMenu(commands)
  case commands[choice]
  when cmd_share
    pbMessage(_INTL("Once you share you base, it may randomly appear in other player's games."))
    pbMessage(_INTL("The other players will be able to see your character's name, your base's layout, your custom message, and battle your team."))
    continue = pbConfirmMessage(_INTL("You can only share your secret base once per day. Would you like to continue and publish your current secret base? (Your game will save automatically afterwards)"))
    if continue
      begin
        exporter = SecretBaseExporter.new
        json = exporter.export_secret_base(secretBase)

        publisher = SecretBasePublisher.new
        publisher.register unless $Trainer.secretBase_uuid
        publisher.upload_base(json)
        pbSEPlay('GUI save choice')
        pbMessage(_INTL("Your secret base was shared successfully!"))
      rescue Exception => e
        echoln e
        pbMessage(_INTL("There was a problem uploading your Secret Base. The operation was cancelled."))
      end

    end
  when cmd_import
    friend_code = input_friend_code
    if friend_code
      fetcher = SecretBaseFetcher.new
      begin
        fetcher.import_friend_base(friend_code)
        loader = SecretBaseLoader.new
        loader.load_visitor_bases
        pbMessage(_INTL("Your friend's base was imported!"))
      rescue
        pbMessage(_INTL("There was a problem, your friend's secret base was not imported."))
      end
    end
  when cmd_setTeam
  when cmd_trainerID
      Input.clipboard = $Trainer.id.to_s
      pbMessage(_INTL("Your Trainer ID was copied to the clipboard!"))
  when cmd_export
    exporter = SecretBaseExporter.new
    json = exporter.export_secret_base($Trainer.secretBase)
    Input.clipboard = json
  end
end

def check_copied_own_trainerId(clipboard_text)
  if clipboard_text == $Trainer.id.to_s
    pbMessage(_INTL("The trainer ID you copied is your own! You need to have your friend copy theirs and send it to you."))
    return true
  end
  return false
end

def input_friend_code()
  example = showPicture("Graphics/Pictures/Trainer Card/trainerID_example",0,0,0)

  cmd_refresh = _INTL("Refresh")
  cmd_confirm = _INTL("Confirm")
  cmd_manual = _INTL("Enter manually")
  cmd_cancel = _INTL("Cancel")
  loop do
    commands = []
    clipboard_text = Input.clipboard || ""
    clipboard_text = clipboard_text.slice(0, 10)

    if numeric_string?(clipboard_text) && clipboard_text.length == 10 && !check_copied_own_trainerId(clipboard_text)
      message = _INTL("Is this your friend's Trainer ID? \\C[1]{1}\\C[0]",clipboard_text)
      commands << cmd_refresh
      commands << cmd_confirm
      commands << cmd_manual
      commands << cmd_cancel
    else
      message = _INTL("Copy your friend's ID and choose 'Refresh'. The game will detect it from your clipboard.")
      commands << cmd_refresh
      commands << cmd_manual
      commands << cmd_cancel
    end

    choice = pbMessage(message, commands,commands.length)
    case commands[choice]
    when cmd_refresh
      next
    when cmd_confirm
      example.dispose
      return clipboard_text
    when cmd_manual
      friend_trainer_id = pbEnterText("Friend's Trainer ID", 10, 10, clipboard_text)
      unless numeric_string?(friend_trainer_id)
        pbMessage(_INTL("The Trainer ID you entered is not valid. Trainer IDs are composed of 10 numbers."))
      end
      Input.clipboard = friend_trainer_id
    else
      example.dispose
      return nil
    end
  end
end

def interact_other_player(secretBase)
  event = pbMapInterpreter.get_character(0)
  event.direction_fix = false
  event.turn_toward_player
  message = secretBase.base_message
  pbCallBub(3)
  pbMessage(_INTL("Hey, I'm \\C[1]{1}\\C[0], welcome to my secret base!",secretBase.trainer_name))
  if message
    pbCallBub(3)
    pbMessage(message)
  end
end

def pushEvent(itemInstance)
  event = itemInstance.getMainEvent
  old_x = event.x
  old_y = event.y
  return if !event.can_move_in_direction?($game_player.direction, false)
  case $game_player.direction
  when 2 then event.move_down
  when 4 then event.move_left
  when 6 then event.move_right
  when 8 then event.move_up
  end

  if old_x != event.x || old_y != event.y
    $game_player.lock
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if !event.moving?
    end
    itemInstance.position = [event.x, event.y]
    $PokemonTemp.pbClearTempEvents
    $PokemonTemp.enteredSecretBaseController.reloadItems

    $game_player.unlock
  end
end

def sit_on_chair_item(itemInstance)
  event=itemInstance.getMainEvent
  sit_on_chair_event(event)
end

def sit_on_chair_event(event)
  pbSEPlay("jump", 80, 100)
  $game_player.always_on_top=true
  $game_player.through =true
  $game_player.jump_forward
  case event.direction
  when DIRECTION_LEFT; $game_player.direction = DIRECTION_RIGHT
  when DIRECTION_RIGHT; $game_player.direction = DIRECTION_LEFT
  when DIRECTION_UP; $game_player.direction = DIRECTION_UP
  when DIRECTION_DOWN; $game_player.direction = DIRECTION_DOWN
  end
  $game_player.through =false
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN) || Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
      $game_player.jump_forward
      $game_player.always_on_top=false
      break
    end
  end
end

# PC behavior set directly in SecretBaseController
