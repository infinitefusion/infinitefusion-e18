def export_music_use_map()
  music_hash = Hash.new
  for map_id in 1..796
    mapInfos = load_data(sprintf("Data/Map%03d.rxdata", map_id))
    bgm_name = mapInfos.bgm.name
    map_name = getMapName(map_id)
    formatted_value = map_name + " [" + map_id.to_s + "]"
    if music_hash.has_key?(bgm_name)
      music_hash[bgm_name] << formatted_value
    else
      music_hash[bgm_name] = Array.new(1, formatted_value)
    end
  end
  export_hash_to_csv(music_hash,"music_export.csv")
end

def export_hash_to_csv(hash, file_path)
  # Open the file for writing
  file = File.open(file_path, "w")

  # Write the CSV header
  file.puts "Key,Value"

  # Write each key-value pair as a new line in the CSV file
  hash.each do |key, values|
    if key == ""
      key = "(No value)"
    end
    # Join the values into a single string with newline characters
    values_str = values.join("\n,")
    file.puts "#{key},#{values_str}"
  end

  # Close the file
  file.close
end


