class SecretBaseExporter
  # Export a secret base as JSON
  def export_secret_base(secretBase)
    base_data = {
      base: {
        biome: secretBase.biome_type || "",
        entrance_map: secretBase.outside_map_id || 0,
        outside_entrance_position: secretBase.outside_entrance_position || [0, 0],
        layout_type: secretBase.base_layout_type || "",
        base_message: secretBase.base_message || "",
        layout: {
          items: list_base_items(secretBase)
        }
      },
      trainer: {
        name: $Trainer.name || "",
        id: $Trainer.id,
        nb_badges: $Trainer.badge_count || 0,
        game_mode: $Trainer.game_mode || 0,
        appearance: sanitize_string(export_current_outfit_to_json),
        team: export_team_as_array
      }
    }

    JSON.generate(sanitize_string(base_data))
  end

  # Export all items in the base layout
  def list_base_items(secretBase)
    return [] unless secretBase&.layout&.items
    secretBase.layout.items.map do |item|
      {
        id: item.itemId || "",
        position: item.position || [0, 0],
        direction: item.direction || DIRECTION_DOWN,
      }
    end
  end

  def write_base_json_to_file(new_base_json, file_path, append = true)
    ensure_folder_exists(File.dirname(file_path))

    # Parse new_base JSON string into a Ruby object
    begin
      new_base = JSON.parse(new_base_json)
    rescue Exception => e
      echoln "[SecretBase] Failed to parse new base JSON: #{e.message}"
      return
    end

    bases = []

    if File.exist?(file_path)
      begin
        file_content = File.read(file_path).strip
        if !file_content.empty?
          # parse existing content into array
          bases = JSON.parse(file_content)
          bases = [] unless bases.is_a?(Array)
        end
      rescue Exception => e
        echoln "[SecretBase] Error reading existing file: #{e.message}"
        bases = []
      end
    end

    # Append or replace
    if append
      bases << new_base
    else
      bases = [new_base]
    end

    # Write back
    File.open(file_path, "w") do |file|
      file.write(JSON.generate(bases))
    end

    echoln "[SecretBase] Saved base to #{file_path}"
  end



  # Export the trainer's Pokémon party
  def export_team_as_array
    $Trainer.party.compact.map { |p| export_fused_pokemon_hash(p) }
  end

  # Export a single Pokémon as a hash
  def export_fused_pokemon_hash(pokemon)
    {
      species: pokemon.species.to_s,
      name: pokemon.name || "",
      item: pokemon.item ? pokemon.item.id.to_s : "",
      ability: pokemon.ability ? pokemon.ability.id.to_s : "",
      level: pokemon.level || 1,
      owner: pokemon.owner,
      ball: pokemon.poke_ball,

      hat: pokemon.hat,
      hat_x: pokemon.hat_x,
      hat_y: pokemon.hat_y,
      steps_to_hatch: pokemon.steps_to_hatch,
      alt_sprite: pokemon.pif_sprite&.alt_letter,
      evs: {
        hp: pokemon.ev[:HP] || 0,
        atk: pokemon.ev[:ATTACK] || 0,
        def: pokemon.ev[:DEFENSE] || 0,
        spa: pokemon.ev[:SPECIAL_ATTACK] || 0,
        spd: pokemon.ev[:SPECIAL_DEFENSE] || 0,
        spe: pokemon.ev[:SPEED] || 0
      },
      ivs: {
        hp: pokemon.iv[:HP] || 0,
        atk: pokemon.iv[:ATTACK] || 0,
        def: pokemon.iv[:DEFENSE] || 0,
        spa: pokemon.iv[:SPECIAL_ATTACK] || 0,
        spd: pokemon.iv[:SPECIAL_DEFENSE] || 0,
        spe: pokemon.iv[:SPEED] || 0
      },
      nature: GameData::Nature.get(pokemon.nature).id.to_s,
      moves: pokemon.moves.compact.map { |m| GameData::Move.get(m.id).id.to_s }
    }
  end

  private
end
# Recursively replace nils with empty strings (or zero if numeric leaf)
def sanitize_string(obj)
  case obj
  when Hash
    obj.transform_values { |v| sanitize_string(v) }
  when Array
    obj.map { |v| sanitize_string(v) }
  when NilClass
    ""
  else
    obj
  end
end
