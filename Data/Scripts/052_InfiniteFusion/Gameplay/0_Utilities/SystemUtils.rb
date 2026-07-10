def pbGetSelfSwitch(eventId, switch)
  return $game_self_switches[[@map_id, eventId, switch]]
end

def find_newer_available_version
  latest_Version = fetch_latest_game_version
  return nil if !latest_Version
  return nil if is_higher_version(Settings::GAME_VERSION_NUMBER, latest_Version)
  return latest_Version
end

def is_higher_version(gameVersion, latestVersion)
  gameVersion_parts = gameVersion.split('.').map(&:to_i)
  latestVersion_parts = latestVersion.split('.').map(&:to_i)

  # Compare each part of the version numbers from left to right
  gameVersion_parts.each_with_index do |part, i|
    return true if (latestVersion_parts[i].nil? || part > latestVersion_parts[i])
    return false if part < latestVersion_parts[i]
  end
  return latestVersion_parts.length <= gameVersion_parts.length
end

def get_current_game_difficulty
  return :EASY if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
  return :HARD if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  return :NORMAL
end

def get_difficulty_text
  if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
    return _INTL("Easy")
  elsif $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    return _INTL("Hard")
  else
    return _INTL("Normal")
  end
end

def getLatestSpritepackDate()
  return Time.new(Settings::NEWEST_SPRITEPACK_YEAR, Settings::NEWEST_SPRITEPACK_MONTH)
end

def new_spritepack_was_released()
  current_spritepack_date = $PokemonGlobal.current_spritepack_date
  latest_spritepack_date = getLatestSpritepackDate()
  if !current_spritepack_date || (current_spritepack_date < latest_spritepack_date)
    $PokemonGlobal.current_spritepack_date = latest_spritepack_date
    return true
  end
  return false
end

def clearAllSelfSwitches(mapID, switch = "A", newValue = false)
  map = $MapFactory.getMap(mapID, false)
  map.events.each { |event_array|
    event_id = event_array[0]
    pbSetSelfSwitch(event_id, switch, newValue, mapID)
  }
end

def openUrlInBrowser(url = "")
  begin
    # Open the URL in the default web browser
    system("xdg-open", url) || system("open", url) || system("start", url)
  rescue
    Input.clipboard = url
    pbMessage(_INTL("The game could not open the link in the browser"))
    pbMessage(_INTL("The link has been copied to your clipboard instead"))
  end
end

# todo: implement
def getMappedKeyFor(internalKey)

  keybinding_fileName = "keybindings.mkxp1"
  path = System.data_directory + keybinding_fileName

  parse_keybindings(path)

  # echoln Keybindings.new(path).bindings
end

def formatNumberToString(number)
  return number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def optionsMenu(options = [], cmdIfCancel = -1, startingOption = 0)
  $game_temp.message_window_showing = true
  cmdIfCancel = -1 if !cmdIfCancel
  result = pbShowCommands(nil, options, cmdIfCancel+1, startingOption)  #+1 parce que pbShowCommands fait un "-1" pour être "user friendly"...
  $game_temp.message_window_showing = false
  return result
end


def displaySpriteWindowWithMessage(pif_sprite, message = "", x = 0, y = 0, z = 0)
  spriteLoader = BattleSpriteLoader.new
  sprite_bitmap = spriteLoader.load_pif_sprite_directly(pif_sprite)
  if sprite_bitmap
    pictureWindow = PictureWindow.new(sprite_bitmap.bitmap)
  else
    pictureWindow = PictureWindow.new("")
  end

  pictureWindow.opacity = 0
  pictureWindow.z = z
  pictureWindow.x = x
  pictureWindow.y = y
  pbMessage(message)
  pictureWindow.dispose
end

def numeric_string?(str)
  str.match?(/\A\d+\z/)
end

def timeDateGreaterThan(date1, date2)
  return (
    date1.year  > date2.year ||
      date1.month > date2.month && date1.year == date2.year ||
      date1.day   > date2.day   && date1.month == date2.month && date1.year == date2.year
  )
end

def transferBoxDisclaimer(event)
  unless Settings::TRANSFER_BOX_DISCLAIMER_MESSAGE.empty?
    pbMessage(_INTL(Settings::TRANSFER_BOX_DISCLAIMER_MESSAGE))
  end
end
