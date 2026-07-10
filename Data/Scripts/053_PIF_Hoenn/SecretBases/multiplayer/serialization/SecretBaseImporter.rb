class SecretBaseImporter
  FRIEND_BASES_FILE = "Data/bases/friend_bases.json"
  VISITOR_BASES_FILE = "Data/bases/visitor_bases.json"

  def read_secret_base_json(path)
    return [] unless File.exist?(path)

    file_contents = File.read(path)
    begin
      # Parse with symbolized keys directly
      raw = JSON.parse(file_contents)
      return deep_clean(raw)   # cleaned object, keys stay symbols
    rescue Exception => e
      echoln caller
      echoln("SecretBaseImporter: Failed to parse JSON: #{e}")
      return []
    end
  end

  # Load all bases from the JSON
  def load_bases(path)
    all_bases_data = read_secret_base_json(path)
    return [] unless all_bases_data.is_a?(Array)

    # Only keep entries with a trainer
    visitor_bases = []
    all_bases_data.map do |entry|
      begin
      base_data    = entry[:base]
      trainer_data = entry[:trainer]

      biome = base_data[:biome].to_sym
      base = VisitorSecretBase.new(
        biome: biome,
        outside_map_id: base_data[:entrance_map],
        outside_entrance_position: base_data[:outside_entrance_position],
        inside_map_id: base_data[:inside_map_id],
        layout: import_layout_from_json(base_data[:layout],biome),
        base_layout_type: base_data[:layout_type],
        trainer_data: import_trainer_from_json(trainer_data),
        base_message: base_data[:base_message],
      )
      visitor_bases << base
      #base.dump_info
      rescue Exception => e
        echoln "COULD NOT LOAD BASE: #{e}"
      end
    end
    return visitor_bases
  end


  def import_layout_from_json(layout_json, biome)
    layout = SecretBaseLayout.new(
      biome,
      false
    )

    items = []
    (layout_json[:items] || []).each do |item_data|
      id       = item_data[:id].to_sym
      position = item_data[:position]
      direction = item_data[:direction]
      item_instance = SecretBaseItemInstance.new(id,position,direction)

      items << item_instance
    end

    layout.items = items
    return layout
  end


  def import_trainer_from_json(trainer_json)
    app = trainer_json[:appearance]
    trainer_appearance = TrainerAppearance.new(
      app[:skin_color], app[:hat], app[:clothes], app[:hair],
      app[:hair_color], app[:clothes_color], app[:hat_color],
      app[:hat2], app[:hat2_color]
    )

    team = trainer_json[:team].map { |poke_json| import_pokemon_from_json(poke_json) }
    SecretBaseTrainer.new(
      trainer_json[:name],
      trainer_json[:nb_badges],
      trainer_json[:game_mode],
      trainer_appearance,
      team
    )
  end

  def import_pokemon_from_json(poke_json)
    pokemon = Pokemon.new(poke_json[:species], poke_json[:level])
    pokemon.name     = poke_json[:name]
    pokemon.item     = poke_json[:item]
    pokemon.ability  = poke_json[:ability]
    pokemon.nature   = poke_json[:nature]
    pokemon.ot = poke_json[:owner] if poke_json[:owner]
    pokemon.hat = poke_json[:hat]
    pokemon.hat_x = poke_json[:hat_x]
    pokemon.hat_y = poke_json[:hat_y]
    pokemon.steps_to_hatch = poke_json[:steps_to_hatch] || 0
    pokemon.poke_ball = poke_json[:ball]
    if poke_json[:alt_sprite] && poke_json[:alt_sprite] != ""
      if pokemon.isFusion?
        pokemon.pif_sprite = PIFSprite.new(:CUSTOM, pokemon.get_head_num,pokemon.get_body_num,poke_json[:alt_sprite])
      else
        pokemon.pif_sprite = PIFSprite.new(:BASE, pokemon.id_number,nil,poke_json[:alt_sprite])
      end
    end
    moves = poke_json[:moves]
    pokemon_moves = []
    moves.each do |move_id|
      move = Pokemon::Move.new(move_id)
      pokemon_moves << Pokemon::Move.new(move_id)
      pokemon.add_learned_move(move)
    end
    pokemon.moves    = pokemon_moves

    if poke_json[:ivs]
      poke_json[:ivs].each do |stat, value|
        case stat.to_s.downcase
        when "hp"   then pokemon.iv[:HP] = value
        when "atk"  then pokemon.iv[:ATTACK] = value
        when "def"  then pokemon.iv[:DEFENSE] = value
        when "spe"  then pokemon.iv[:SPEED] = value
        when "spa"  then pokemon.iv[:SPECIAL_ATTACK] = value
        when "spd"  then pokemon.iv[:SPECIAL_DEFENSE] = value
        end
      end
    end

    if poke_json[:evs]
      poke_json[:evs].each do |stat, value|
        case stat.to_s.downcase
        when "hp"   then pokemon.ev[:HP] = value
        when "atk"  then pokemon.ev[:ATTACK] = value
        when "def"  then pokemon.ev[:DEFENSE] = value
        when "spe"  then pokemon.ev[:SPEED] = value
        when "spa"  then pokemon.ev[:SPECIAL_ATTACK] = value
        when "spd"  then pokemon.ev[:SPECIAL_DEFENSE] = value
        end
      end
    end

    pokemon.calc_stats
    pokemon
  end

  private

  # Recursively converts "" → nil, but keeps keys as symbols
  def deep_clean(obj)
    case obj
    when Hash
      obj.transform_values { |v| deep_clean(v) }
    when Array
      obj.map { |v| deep_clean(v) }
    when ""
      nil
    else
      obj
    end
  end
end
