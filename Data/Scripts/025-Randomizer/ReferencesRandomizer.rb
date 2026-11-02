def select_randomizer_references(minimum_allowed = nil)
  references_map = map_sprites_by_reference()
  label_to_key = {}


  non_ref_list = getNonReferenceSprites(nil, references_map)
  references_map["Include non-reference"] = non_ref_list
  references_list = references_map.keys.sort_by { |k| [-references_map[k].length, k] }.map do |key|
    label = format_reference_for_menu(references_map,key)
    label_to_key[label] = key
    label
  end

  current_references = $PokemonSystem.selected_reference_sprite_categories
  current_references = references_map.keys if current_references.nil?

  formatted_current_references = current_references.map do |reference_key|
    format_reference_for_menu(references_map, reference_key)
  end.compact

  scene = MultiSelectOptionsScene.new(
    references_list, formatted_current_references,
    _INTL("Select all reference sprites to be included"), nil,
    _INTL("Press Shift to search"),
    proc { |label| references_map[label_to_key[label]].length }
  )
  screen = MultiSelectOptionScreen.new(scene)
  selected_labels = screen.pbStartScreen

  return [] if selected_labels.nil?
  selected_keys = selected_labels.map { |label| label_to_key[label] }


  total_sprites = 0
  selected_keys.each do |key|
    sprites = references_map[key]
    total_sprites += sprites.length
  end

  if minimum_allowed && total_sprites < minimum_allowed
    pbMessage(_INTL("Warning: The categories you selected only have a total of {1} sprites, and so is likely that you will see repeats during your playthrough.", total_sprites))
    pbMessage(_INTL("You can still continue but it is recommended to select at least {1} sprites for a new playthrough.", minimum_allowed))
  end

  write_selected_references_to_file(selected_keys, references_map)
  scene.pbEndScene
  $PokemonSystem.selected_reference_sprite_categories = selected_keys
  return selected_keys
end


#Util method to export a list - not used by the game itself
def print_reference_map_to_file(references_map)
  output_path = "reference_map_ids.txt"

  File.open(output_path, "w") do |file|
    references_map.keys.sort.each do |reference_id|
      file.puts(reference_id)
    end
  end
rescue => e
  echoln("Failed to write reference map to #{output_path}: #{e.message}")
end

def format_reference_for_menu(references_map, key)
  return nil unless references_map && references_map.key?(key)
  label = "#{titleize(key)} (#{references_map[key].length})"
  return label
end
def write_selected_references_to_file(selected_keys, references_map)
  output_path = Settings::REFERENCES_FILE_PATH
  sprite_names = selected_keys.flat_map { |key| references_map[key] }

  File.open(output_path, "w") do |file|
    sprite_names.each do |spritename|
      file.puts(spritename)
    end
  end
end# frozen_string_literal: true

