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
      map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
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
                event_id: event_id,
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
      echoln "Map #{res[:map_id]}, Event #{res[:event_id]}, Page #{res[:page_index]}, Command #{res[:command_index]}"
    end
  end
end

