module SwitchFinder

  def self.search_switch_trigger(switch_id)
    results = []
    mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
    mapinfos.each_key do |map_id|
      map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
      map.events.each_value do |event|
        event.pages.each do |page,index|
          # Check conditions for each page
          if page.condition.switch1_id == switch_id || page.condition.switch2_id == switch_id
            results.push("Map #{map_id}, Event #{event.id} (#{event.x},#{event.y}), Trigger for page #{index}")
          end

          # Check commands for switch control
          page.list.each do |command|
            if command.code == 122 && command.parameters[0] == switch_id
              results.push("Map #{map_id}, Event #{event.id} (#{event.x},#{event.y}), Command #{command.code}")
            end
          end
        end
      end
    end
    echoln "Switch #{switch_id} found:" + results.to_s
  end


  def self.search_switch_anyUse(switch_id)
    results = []

    # Load map info based on RPG Maker version
    mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

    # Iterate over each map
    mapinfos.each_key do |map_id|

      map_path = $RPGVX ? sprintf("Data/Map%03d.rvdata", map_id) : sprintf("Data/Map%03d.rxdata", map_id)
      next unless File.exist?(map_path)
      map = load_data(map_path)
      mapinfo = mapinfos[map_id]
      # Iterate over each event in the map
      map.events.each_value do |event|

        # Iterate over each page in the event
        event.pages.each_with_index do |page, page_index|

          # Check conditions for each page
          if page.condition.switch1_id == switch_id || page.condition.switch2_id == switch_id
            results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Trigger for page #{page_index + 1}")
          end

          # Iterate over each command in the page
          page.list.each_with_index do |command, command_index|

            # Check commands for switch control
            if command.code == 121
              # Command 121 is Control Switches
              range_start = command.parameters[0]
              range_end = command.parameters[1]
              value = command.parameters[2]

              # Check if the switch is within the specified range
              if range_start <= switch_id && switch_id <= range_end
                action = value == 0 ? "ON" : "OFF"
                results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Command #{command_index + 1}: Set Switch to #{action}")
              end

              # Check script calls for switch control
            elsif command.code == 355
              # Command 355 is Call Script
              script_text = command.parameters[0]

              # Collect multi-line scripts
              next_command_index = command_index + 1
              while page.list[next_command_index]&.code == 655
                script_text += page.list[next_command_index].parameters[0]
                next_command_index += 1
              end

              # Use a regular expression to find switch manipulations
              if script_text.match?(/\$game_switches\[\s*#{switch_id}\s*\]/)
                results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Command #{command_index + 1}: Script Manipulation")
              end
            end
          end
        end
      end
    end

    # Output the results
    results = "Switch #{switch_id} found:\n" + results.join("\n")
    echoln results
    return results
  end


  def self.find_unused_switches(total_switches)
    unused_switches = []

    # Check each switch from 1 to total_switches
    (1..total_switches).each do |switch_id|
      results = search_switch_anyUse(switch_id)
      report = "Switch #{switch_id}:\n#{results}"
      unused_switches << report
    end

    # Export to a text file
    File.open("unused_switches.txt", "w") do |file|
      file.puts "Unused Switches:"
      unused_switches.each do |switch_id|
        file.puts "\n\n#{switch_id}"
      end
    end

    echoln "#{unused_switches.length} unused switches found. Exported to unused_switches.txt."
  end

  def self.search_var_anyUse(variable_id)
    results = []

    mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

    mapinfos.each_key do |map_id|
      map_filename = sprintf("Data/Map%03d.rxdata", map_id)
      next unless File.exist?(map_filename)

      map = load_data(map_filename)
      mapinfo = mapinfos[map_id]
      map.events.each_value do |event|
        event.pages.each_with_index do |page, page_index|

          # Check page condition — variable condition uses variable_id and a value threshold
          if page.condition.variable_valid && page.condition.variable_id == variable_id
            results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Trigger for page #{page_index + 1} (variable condition)")
          end

          page.list.each_with_index do |command, command_index|

            # Command 122: Control Variables
            if command.code == 122
              range_start = command.parameters[0]
              range_end   = command.parameters[1]

              if range_start <= variable_id && variable_id <= range_end
                results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Command #{command_index + 1}: Control Variables (write)")
              end

              # Command 111: Conditional Branch — can reference a variable
            elsif command.code == 111
              # parameters[0] == 1 means "variable comparison" condition type
              if command.parameters[0] == 1 && command.parameters[1] == variable_id
                results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Command #{command_index + 1}: Conditional Branch (variable check)")
              end

              # Commands 355/655: Script calls
            elsif command.code == 355
              script_text = command.parameters[0]

              next_index = command_index + 1
              while page.list[next_index]&.code == 655
                script_text += page.list[next_index].parameters[0]
                next_index += 1
              end

              if script_text.match?(/\$game_variables\[\s*#{variable_id}\s*\]/)
                results.push("Map #{map_id}: #{mapinfo.name}, Event #{event.id} (#{event.x},#{event.y}), Command #{command_index + 1}: Script Manipulation")
              end
            end

          end
        end
      end
    end

    output = "Variable #{variable_id} found:\n" + results.join("\n")
    echoln output
    return output
  end


end

# Example usage: Replace 100 with the switch ID you want to search
# SwitchFinder.search_switch(100)


def search_event_scripts(target_string)
  results = []
  for map_id in 1..999  # Adjust based on your game's max map ID
    map_filename = sprintf("Data/Map%03d.rxdata", map_id)
    next unless File.exist?(map_filename)  # Skip if map file doesn't exist

    map_data = load_data(map_filename)
    next unless map_data.events  # Skip maps with no events

    map_data.events.each do |event_id, event|
      event.pages.each_with_index do |page, page_index|
        next unless page.list  # Skip pages with no commands

        page.list.each_with_index do |command, cmd_index|
          if command.code == 355 || command.code == 655  # Check script command (multi-line)
            if command.parameters[0].include?(target_string)
              results << {
                map_id: map_id,
                main_event_id: event_id,
                page_index: page_index + 1,
                command_index: cmd_index + 1
              }
            end
          end
        end
      end
    end
  end

  if results.empty?
    echoln "No occurrences of '#{target_string}' found."
  else
    echoln "Found occurrences of '#{target_string}':"
    results.each do |res|
      echoln "Map #{res[:map_id]}, Event #{res[:main_event_id]}, Page #{res[:page_index]}, Command #{res[:command_index]}"
    end
  end
end




def print_map_tiles
  # Define output file path
  file_path = "/Users/chardub/Documents/infinitefusion/TileIDs_Output.txt"

  # Open file for writing
  File.open(file_path, "w") do |file|
    map = $game_map
    width = map.width
    height = map.height

    (0...3).each do |z| # For each layer: 0, 1, 2
      file.puts("Layer #{z}:")
      (0...height).each do |y|
        row_ids = []
        (0...width).each do |x|
          tile_id = map.data[x, y, z]
          row_ids << tile_id
        end
        file.puts(row_ids.join(", "))
      end
      file.puts("") # Add a blank line between layers
    end
  end

  echoln("Tile IDs exported to #{file_path}")


end

SWITCH_LITTLEROOT_FINISHED_MOVING = 2005
SWITCH_LITTLEROOT_TRUCK = 2001
SWITCH_LITTLEROOT_DAD_ON_TV = 2006
SWITCH_LITTLEROOT_MOM_INTRO_OVER = 2007
SWITCH_HOENN_RIVAL_APPEARANCE_SET = 1998
SWITCH_HOENN_MET_RIVAL = 2010
SWITCH_HOENN_CHOOSING_STARTER = 2013
SWITCH_HOENN_SAVED_BIRCH = 2011

SWITCH_NO_BUMP_SOUND = 108

SWITCH_HOENN_GO_SEE_RIVAL = 2012
SWITCH_HOENN_BEAT_RIVAL_INTRO = 2014
SWITCH_HOENN_INTRO_GOT_POKEDEX = 2017

MAP_ROUTE_101 = 5
MAP_LITTLEROOT = 9
MAP_LITTLEROOT_INTERIOR = 13

def hoenn_dev_quick_start
  return false unless $DEBUG
  choices = []
  cmd_truck = "Intro (Normal)"
  cmd_starter = "Starter Selection"
  cmd_pokedex = "Pokédex obtained"
  choices << cmd_truck
  choices << cmd_starter
  choices << cmd_pokedex
  chosen = pbMessage("[Debug] Start where?",choices)
  case choices[chosen]
  when cmd_truck
    return false
  when cmd_starter
    setHoennDefaultIntroSwitches
    hoennCharacterSelection
    setHoennSwitchesToStarter
    pbFadeOutIn {
      $game_temp.player_new_map_id = MAP_ROUTE_101
      $game_temp.player_new_x = 19
      $game_temp.player_new_y = 19
      $game_temp.player_new_direction = DIRECTION_UP
      $scene.transfer_player(true)
      $game_map.autoplay
      $game_map.refresh
    }
  when cmd_pokedex
    setHoennDefaultIntroSwitches
    hoennCharacterSelection
    setHoennSwitchesToStarter
    setHoennSwitchesFromStarterToPokedex
    pbFadeOutIn {
      $game_temp.player_new_map_id = MAP_LITTLEROOT
      $game_temp.player_new_x = 16
      $game_temp.player_new_y = 23
      $game_temp.player_new_direction = DIRECTION_DOWN
      $scene.transfer_player(true)
      $game_map.autoplay
      $game_map.refresh
    }
  end
  return true
end

VAR_BATTLE_UI_STYLE = 199

def setHoennDefaultIntroSwitches
  pbSet(VAR_BATTLE_UI_STYLE, 0)
  $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = true
  $game_switches[SWITCH_TIME_PAUSED] = true
  $game_switches[SWITCH_NO_BUMP_SOUND]

  $PokemonSystem.overworld_encounters= true
  $PokemonGlobal.runningShoes=true
  pbChangePlayer(0)
  set_starting_options
  pbShuffleItems
  pbShuffleTMs
  Kernel.initRandomTypeArray()
  $game_switches[SWITCH_NEW_GAME_PLUS]= SaveData.exists?
end

def hoennCharacterSelection
  menu = CharacterSelectionMenuView.new
  menu.start
  setupStartingOutfit()
end
def setHoennSwitchesToStarter
  #Mom switches
  pbSetSelfSwitch(7,"A",true,MAP_LITTLEROOT) #outside (male)
  pbSetSelfSwitch(8,"A",true,MAP_LITTLEROOT) #outside (female)
  pbSetSelfSwitch(25,"A",true,MAP_LITTLEROOT_INTERIOR) #inside (male)
  pbSetSelfSwitch(39,"A",true,MAP_LITTLEROOT_INTERIOR) #inside (female)
  pbSetSelfSwitch(37,"A",true,MAP_LITTLEROOT_INTERIOR) #inside upstairs (male)
  pbSetSelfSwitch(38,"A",true,MAP_LITTLEROOT_INTERIOR) #inside upstairs (male)
  pbSetSelfSwitch(46,"A",true,MAP_LITTLEROOT_INTERIOR) #inside 3 (male)
  pbSetSelfSwitch(47,"A",true,MAP_LITTLEROOT_INTERIOR) #inside 3 (male)

  $game_switches[SWITCH_LITTLEROOT_FINISHED_MOVING] = true
  $game_switches[SWITCH_LITTLEROOT_TRUCK] = false
  $game_switches[SWITCH_LITTLEROOT_DAD_ON_TV] = true
  $game_switches[SWITCH_LITTLEROOT_MOM_INTRO_OVER] = true

  #Rival
  menu = CharacterSelectionMenuView.new
  menu.start_rival
  $game_switches[SWITCH_HOENN_RIVAL_APPEARANCE_SET] = true
  $game_switches[SWITCH_HOENN_MET_RIVAL] = true
  #Starter
  $game_switches[SWITCH_HOENN_CHOOSING_STARTER] = true
end

def setHoennSwitchesFromStarterToPokedex
  starter = hoennSelectStarter
  pbAddPokemonSilent(starter,5)
  pbSet(VAR_HOENN_STARTER,starter)
  $game_switches[SWITCH_HOENN_SAVED_BIRCH] = true

  $game_switches[SWITCH_HOENN_GO_SEE_RIVAL] = true
  $game_switches[SWITCH_HOENN_BEAT_RIVAL_INTRO] = true
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  rival_trainer = initializeRivalBattledTrainer()
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  $game_switches[SWITCH_TIME_PAUSED] = false
  $game_switches[SWITCH_HOENN_INTRO_GOT_POKEDEX] = true

  pbSetSelfSwitch(20,"A",true,MAP_ROUTE_101) #Rival route 101
  pbSetSelfSwitch(21,"A",true,MAP_ROUTE_101) #Rival route 101

  $Trainer.has_pokedex = true
  pbUnlockDex
  $PokemonBag.pbStoreItem(:POKEBALL,5)
end
