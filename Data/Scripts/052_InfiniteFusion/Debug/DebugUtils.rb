def dump_ow_pokemon_info
  out = ""
  add = ->(s="") { out << s.to_s + "\n" }

  add.call "===== OW POKEMON DEBUG DUMP ====="
  add.call ""

  # --- PokemonTemp tracking array ---
  add.call "$PokemonTemp.overworld_pokemon_on_map"
  add.call "-------------------------------------"
  map = $PokemonTemp.overworld_pokemon_on_map
  add.call "Length: #{map&.length || 'nil'}"
  if map
    map.each_with_index do |id, i|
      event = $game_map.events[id]
      if event.nil?
        add.call "  [#{i}] id=#{id} => EVENT IS NIL (orphan id in list!)"
      elsif event.is_a?(OverworldPokemonEvent)
        add.call "  [#{i}] id=#{id} species=#{event.species} level=#{event.level} state=#{event.get_current_state} deleted=#{event.deleted?} pos=(#{event.x},#{event.y})"
      else
        add.call "  [#{i}] id=#{id} => NOT an OverworldPokemonEvent (#{event.class})"
      end
    end
  end
  add.call ""

  # --- game_map.events ---
  add.call "$game_map.events"
  add.call "-------------------------------------"
  add.call "Total events on map: #{$game_map.events.length}"
  ow_events = $game_map.events.select { |_, e| e.is_a?(OverworldPokemonEvent) }
  add.call "OverworldPokemonEvents in map.events: #{ow_events.length}"
  ow_events.each do |id, event|
    in_tracking = map&.include?(id)
    add.call "  id=#{id} species=#{event.species} deleted=#{event.deleted?} in_tracking_list=#{in_tracking}"
  end
  add.call ""

  # --- Sprites ---
  add.call "character_sprites (Spriteset)"
  add.call "-------------------------------------"
  spriteset = $scene.spritesets[$game_map.map_id]
  if spriteset.nil?
    add.call "  spriteset is NIL"
  else
    sprites = spriteset.character_sprites
    add.call "Total character_sprites: #{sprites.length}"
    ow_sprites = sprites.select { |s| s.character.is_a?(OverworldPokemonEvent) }
    add.call "Sprites with OverworldPokemonEvent character: #{ow_sprites.length}"
    ow_sprites.each do |s|
      event = s.character
      disposed = s.disposed? rescue "unknown"
      in_map = $game_map.events[event.id] == event
      in_tracking = map&.include?(event.id)
      add.call "  sprite -> id=#{event.id} species=#{event.species} disposed=#{disposed} in_map_events=#{in_map} in_tracking_list=#{in_tracking}"
    end

    orphaned = sprites.select do |s|
      s.character.is_a?(OverworldPokemonEvent) && $game_map.events[s.character.id] != s.character
    end
    add.call "Orphaned sprites (not in map.events): #{orphaned.length}"
  end
  add.call ""

  # --- tempEvents ---
  add.call "$PokemonTemp.tempEvents"
  add.call "-------------------------------------"
  temp = $PokemonTemp.tempEvents
  if temp.nil? || temp.empty?
    add.call "  empty or nil"
  else
    temp.each do |map_id, events|
      add.call "  map_id=#{map_id} => #{events.length} temp events"
      events.each do |e|
        add.call "    id=#{e.id} class=#{e.class}"
      end
    end
  end
  add.call ""

  # --- Battle state ---
  add.call "Battle state"
  add.call "-------------------------------------"
  participants = $PokemonTemp.overworld_wild_battle_participants
  add.call "overworld_wild_battle_triggered: #{$PokemonTemp.overworld_wild_battle_triggered}"
  add.call "overworld_wild_battle_participants: #{participants&.length || 'nil'}"
  participants&.each_with_index do |p, i|
    add.call "  [#{i}] species=#{p.pokemon.species} deleted=#{p.deleted?}"
  end
  add.call ""

  # --- RPG::Cache ---
  add.call "RPG::Cache"
  add.call "-------------------------------------"
  if RPG::Cache.respond_to?(:instance_variable_get)
    cache = RPG::Cache.instance_variable_get(:@cache)
    if cache
      add.call "Cache entries total: #{cache.length}"
      ow_cache = cache.select { |k, _| k.to_s.include?("Overworld") || k.to_s.include?("OW") }
      add.call "OW-related cache entries: #{ow_cache.length}"
      ow_cache.each { |k, _| add.call "  #{k}" }
    else
      add.call "Cache is nil"
    end
  end
  add.call ""

  add.call "Spritesets"
  add.call "-------------------------------------"
  add.call "Total spritesets: #{$scene.spritesets.length}"
  $scene.spritesets.each do |map_id, ss|
    add.call "  map_id=#{map_id} character_sprites=#{ss.character_sprites.length}"
  end
  add.call ""

  # --- Spawn stats ---
  add.call "Spawn stats"
  add.call "-------------------------------------"
  $ow_debug_spawn_count ||= 0
  $ow_debug_despawn_count ||= 0
  add.call "Total spawns since last dump: #{$ow_debug_spawn_count}"
  add.call "Total despawns since last dump: #{$ow_debug_despawn_count}"
  $ow_debug_spawn_count = 0
  $ow_debug_despawn_count = 0
  add.call ""

  # --- Pokemon objects ---
  add.call "ObjectSpace Pokemon count"
  add.call "-------------------------------------"
  GC.start
  count = ObjectSpace.each_object(Pokemon).count
  add.call "Live Pokemon objects (post-GC): #{count}"
  add.call ""

  add.call "Pokemon object sample (oldest survivors)"
  add.call "-------------------------------------"
  all_pokemon = []
  ObjectSpace.each_object(Pokemon) { |p| all_pokemon << p }
  add.call "Total: #{all_pokemon.length}"
  sample = all_pokemon.first(5) + all_pokemon.last(5)
  sample.each_with_index do |p, i|
    add.call "  [#{i}] species=#{p.species rescue '?'} level=#{p.level rescue '?'} shiny=#{p.shiny? rescue '?'} ow_coords=#{p.ow_coordinates rescue 'none'}"
  end
  add.call ""

  # --- Class vars ---
  add.call "Pokemon class-level variables"
  add.call "-------------------------------------"
  Pokemon.instance_variables.each do |var|
    val = Pokemon.instance_variable_get(var)
    add.call "  #{var} = #{val.class} (length: #{val.respond_to?(:length) ? val.length : 'n/a'})"
  end
  add.call ""

  add.call "Global shiny reroll tracking"
  add.call "-------------------------------------"
  add.call "  $PokemonTemp shiny vars: #{$PokemonTemp.instance_variables.select { |v| v.to_s.include?('shin') || v.to_s.include?('reroll') }}"
  add.call "  $PokemonGlobal shiny vars: #{$PokemonGlobal.instance_variables.select { |v| v.to_s.include?('shin') || v.to_s.include?('reroll') }}"
  add.call ""

  add.call "===== END DUMP ====="

  Input.clipboard = out
  echoln out
end


def dump_pokemon_referrers(sample_size = 3, max_depth = 3)
  GC.start

  all_pokemon = []
  ObjectSpace.each_object(Pokemon) { |p| all_pokemon << p }

  tracked_ids = ($PokemonTemp.overworld_pokemon_on_map || []).map { |id|
    $game_map.events[id]&.pokemon&.object_id
  }.compact

  leaked = all_pokemon.reject { |p| tracked_ids.include?(p.object_id) }
  echoln "Leaked Pokemon objects: #{leaked.length}"

  leaked.first(sample_size).each_with_index do |target, i|
    echoln ""
    echoln "=== Leaked Pokemon [#{i}] #{target.species} lv#{target.level} ==="

    visited = {}
    frontier = [[target, "Pokemon"]]

    depth = 0
    while !frontier.empty? && depth < max_depth
      next_frontier = []

      ObjectSpace.each_object do |obj|
        next if visited[obj.object_id]
        visited[obj.object_id] = true

        begin
          frontier.each do |child, path|
            # --- instance variables ---
            obj.instance_variables.each do |var|
              val = obj.instance_variable_get(var)

              if val.equal?(child)
                new_path = "#{path} <- #{obj.class}#{var}"
                echoln "  #{new_path}"
                next_frontier << [obj, new_path]
              end

              # --- array ---
              if val.is_a?(Array)
                val.each_with_index do |e, idx|
                  if e.equal?(child)
                    new_path = "#{path} <- #{obj.class}#{var}[#{idx}]"
                    echoln "  #{new_path}"
                    next_frontier << [obj, new_path]
                  end
                end
              end

              # --- hash ---
              if val.is_a?(Hash)
                val.each do |k, v|
                  if v.equal?(child)
                    new_path = "#{path} <- #{obj.class}#{var}[#{k.inspect}]"
                    echoln "  #{new_path}"
                    next_frontier << [obj, new_path]
                  end
                end
              end
            end
          end
        rescue
        end
      end

      frontier = next_frontier
      depth += 1
    end
  end
end