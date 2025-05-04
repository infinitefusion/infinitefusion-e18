module GameData
  class FusedSpecies < GameData::Species
    attr_reader :growth_rate
    attr_reader :body_pokemon
    attr_reader :head_pokemon

    def initialize(id)
      if id.is_a?(Integer)
        body_id = getBodyID(id)
        head_id = getHeadID(id, body_id)
        pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
        return GameData::FusedSpecies.new(pokemon_id)
      end
      head_id = get_head_number_from_symbol(id)
      body_id = get_body_number_from_symbol(id)

      @body_pokemon = GameData::Species.get(body_id)
      @head_pokemon = GameData::Species.get(head_id)

      @id = id
      @id_number = calculate_dex_number()
      @species = @id
      @form = 0
      @real_name = calculate_name()
      @real_form_name = nil

      @type1 = calculate_type1()
      @type2 = calculate_type2()

      #Stats
      @base_stats = calculate_base_stats()
      @evs = calculate_evs()
      adjust_stats_with_evs()

      @base_exp = calculate_base_exp()
      @growth_rate = calculate_growth_rate()
      @gender_ratio = calculate_gender() #todo
      @catch_rate = calculate_catch_rate()
      @happiness = calculate_base_happiness()

      #Moves
      @moves = calculate_moveset()
      @tutor_moves = calculate_tutor_moves() # hash[:tutor_moves] || []
      @egg_moves = calculate_egg_moves() # hash[:egg_moves] || []

      #Abilities
      @abilities = calculate_abilities() # hash[:abilities] || []
      @hidden_abilities = calculate_hidden_abilities() # hash[:hidden_abilities] || []

      #wild held items
      @wild_item_common = get_wild_item(@head_pokemon.wild_item_common, @body_pokemon.wild_item_common) # hash[:wild_item_common]
      @wild_item_uncommon = get_wild_item(@head_pokemon.wild_item_uncommon, @body_pokemon.wild_item_uncommon) # hash[:wild_item_uncommon]
      @wild_item_rare = get_wild_item(@head_pokemon.wild_item_rare, @body_pokemon.wild_item_rare) #  hash[:wild_item_rare]

      @evolutions = calculate_evolutions() # hash[:evolutions] || []

      #breeding
      @egg_groups = [:Undiscovered] #calculate_egg_groups() # hash[:egg_groups] || [:Undiscovered]
      @hatch_steps = calculate_hatch_steps() #  hash[:hatch_steps] || 1
      @incense = nil #hash[:incense]

      #pokedex
      @pokedex_form = @form #ignored
      @real_category = calculate_category()
      @real_pokedex_entry = calculate_dex_entry()
      @height = average_values(@head_pokemon.height, @body_pokemon.height)
      @weight = average_values(@head_pokemon.weight, @body_pokemon.weight)
      @color = @head_pokemon.color
      @shape = @body_pokemon.shape

      #sprite positioning
      @back_sprite_x = @body_pokemon.back_sprite_x
      @back_sprite_y = @body_pokemon.back_sprite_y
      @front_sprite_x = @body_pokemon.front_sprite_x
      @front_sprite_y = @body_pokemon.front_sprite_y
      @front_sprite_altitude = @body_pokemon.front_sprite_altitude
      @shadow_x = @body_pokemon.shadow_x
      @shadow_size = @body_pokemon.shadow_size

      # #unused attributes from Species class
      #
      # @shape = :Head
      # @habitat = :None
      # @generation = 0
      # @mega_stone = nil
      # @mega_move = nil
      # @unmega_form = 0
      # @mega_message = 0
    end

    def get_body_number_from_symbol(id)
      return id.to_s.match(/\d+/)[0].to_i
    end

    def get_head_number_from_symbol(id)
      return id.to_s.match(/(?<=H)\d+/)[0].to_i
    end

    def get_body_species
      return @body_pokemon.id_number
    end

    def get_head_species
      return @head_pokemon.id_number
    end

    def get_body_species_symbol
      return @body_pokemon.id
    end

    def get_head_species_symbol
      return @head_pokemon.id
    end

    def adjust_stats_with_evs
      GameData::Stat.each_main do |s|
        @base_stats[s.id] = 1 if !@base_stats[s.id] || @base_stats[s.id] <= 0
        @evs[s.id] = 0 if !@evs[s.id] || @evs[s.id] < 0
      end
    end

    #FUSION CALCULATIONS
    def calculate_dex_number()
      return (@body_pokemon.id_number * NB_POKEMON) + @head_pokemon.id_number
    end

    def calculate_type1()
      return @head_pokemon.type2 if @head_pokemon.type1 == :NORMAL && @head_pokemon.type2 == :FLYING
      return @head_pokemon.type1
    end

    def calculate_type2()
      return @body_pokemon.type1 if @body_pokemon.type2 == @type1
      return @body_pokemon.type2
    end

    def calculate_base_stats()
      head_stats = @head_pokemon.base_stats
      body_stats = @body_pokemon.base_stats

      fused_stats = {}

      #Head dominant stats
      fused_stats[:HP] = calculate_fused_stats(head_stats[:HP], body_stats[:HP])
      fused_stats[:SPECIAL_DEFENSE] = calculate_fused_stats(head_stats[:SPECIAL_DEFENSE], body_stats[:SPECIAL_DEFENSE])
      fused_stats[:SPECIAL_ATTACK] = calculate_fused_stats(head_stats[:SPECIAL_ATTACK], body_stats[:SPECIAL_ATTACK])

      #Body dominant stats
      fused_stats[:ATTACK] = calculate_fused_stats(body_stats[:ATTACK], head_stats[:ATTACK])
      fused_stats[:DEFENSE] = calculate_fused_stats(body_stats[:DEFENSE], head_stats[:DEFENSE])
      fused_stats[:SPEED] = calculate_fused_stats(body_stats[:SPEED], head_stats[:SPEED])

      return fused_stats
    end

    def calculate_base_exp()
      head_exp = @head_pokemon.base_exp
      body_exp = @body_pokemon.base_exp
      return average_values(head_exp, body_exp)
    end

    def calculate_catch_rate
      return get_lowest_value(@body_pokemon.catch_rate, @head_pokemon.catch_rate)
    end

    def calculate_base_happiness
      return @head_pokemon.happiness
    end

    def calculate_moveset
      return combine_arrays(@body_pokemon.moves, @head_pokemon.moves)
    end

    def calculate_egg_moves
      return combine_arrays(@body_pokemon.egg_moves, @head_pokemon.egg_moves)
    end

    def calculate_tutor_moves
      return combine_arrays(@body_pokemon.tutor_moves, @head_pokemon.tutor_moves)
    end

    def get_wild_item(body_item, head_item)
      rand_num = rand(2)
      if rand_num == 0
        return body_item
      else
        return head_item
      end
    end

    def calculate_abilities()
      abilities_hash = []

      ability1 = @body_pokemon.abilities[0]
      ability2 = @head_pokemon.abilities[0]
      abilities_hash << ability1
      abilities_hash << ability2
      return abilities_hash
    end

    # def calculate_abilities(pokemon1, pokemon2)
    #   abilities_hash = []
    #
    #   ability1 = pokemon1.abilities[0]
    #   ability2 = pokemon2.abilities[1]
    #   if !ability2
    #     ability2 = pokemon2.abilities[0]
    #   end
    #   abilities_hash << ability1
    #   abilities_hash << ability2
    #   return abilities_hash
    # end

    def calculate_hidden_abilities()
      abilities_hash = []

      #First two spots are the other abilities of the two pokemon
      ability1 = @body_pokemon.abilities[1]
      ability2 = @head_pokemon.abilities[1]
      ability1 = @body_pokemon.abilities[0] if !ability1
      ability2 = @head_pokemon.abilities[0] if !ability2

      abilities_hash << ability1
      abilities_hash << ability2

      #add the hidden ability for the two base pokemon
      hiddenAbility1 = @body_pokemon.hidden_abilities[0]
      hiddenAbility1 = ability1 if !hiddenAbility1

      hiddenAbility2 = @head_pokemon.hidden_abilities[0]
      hiddenAbility2 = ability2 if !hiddenAbility2

      abilities_hash << hiddenAbility1
      abilities_hash << hiddenAbility2
      return abilities_hash
    end

    def calculate_name()
      body_nat_dex = GameData::NAT_DEX_MAPPING[@body_pokemon.id_number] ? GameData::NAT_DEX_MAPPING[@body_pokemon.id_number] : @body_pokemon.id_number
      head_nat_dex = GameData::NAT_DEX_MAPPING[@head_pokemon.id_number] ? GameData::NAT_DEX_MAPPING[@head_pokemon.id_number] : @head_pokemon.id_number
      begin
        prefix = GameData::SPLIT_NAMES[head_nat_dex][0]
        suffix = GameData::SPLIT_NAMES[body_nat_dex][1]
        if prefix[-1] == suffix[0]
          prefix = prefix[0..-2]
        end
        return prefix + suffix

      rescue
        print("species with error: " + @species.to_s)
      end

    end

    def calculate_evolutions()
      body_evolutions = @body_pokemon.evolutions
      head_evolutions = @head_pokemon.evolutions

      fused_evolutions = []

      #body
      for evolution in body_evolutions
        evolutionSpecies = evolution[0]
        evolutionSpecies_dex = GameData::Species.get(evolutionSpecies).id_number
        fused_species = _INTL("B{1}H{2}", evolutionSpecies_dex, @head_pokemon.id_number)
        fused_evolutions << build_evolution_array(evolution, fused_species)
      end

      #head
      for evolution in head_evolutions
        evolutionSpecies = evolution[0]
        evolutionSpecies_dex = GameData::Species.get(evolutionSpecies).id_number
        fused_species = _INTL("B{1}H{2}", @body_pokemon.id_number, evolutionSpecies_dex)
        fused_evolutions << build_evolution_array(evolution, fused_species)
      end

      return fused_evolutions
    end

    #Change the evolution species depending if head & body and keep the rest of the data the same
    def build_evolution_array(evolution_data, new_species)
      fused_evolution_array = []
      fused_evolution_array << new_species.to_sym

      #add the rest
      for data in evolution_data
        next if evolution_data.index(data) == 0
        fused_evolution_array << data
      end
      return fused_evolution_array
    end

    def calculate_dex_entry
      body_entry = @body_pokemon.real_pokedex_entry.gsub(@body_pokemon.real_name, @real_name)
      head_entry = @head_pokemon.real_pokedex_entry.gsub(@head_pokemon.real_name, @real_name)

      return split_and_combine_text(body_entry, head_entry, ".")
    end

    def get_random_dex_entry()
      begin
        file_path = Settings::POKEDEX_ENTRIES_PATH
        json_data = File.read(file_path)
        all_body_entries  = HTTPLite::JSON.parse(json_data)


        body_entry = all_body_entries[@body_pokemon.id_number.to_s].sample
        body_entry = body_entry.gsub(/#{@body_pokemon.real_name}/i, @real_name)
        body_entry = clean_json_string(body_entry).gsub(@body_pokemon.real_name, @real_name)

        head_entry = all_body_entries[@head_pokemon.id_number.to_s].sample
        head_entry = head_entry.gsub(/#{@head_pokemon.real_name}/i, @real_name)
        head_entry = clean_json_string(head_entry).gsub(@head_pokemon.real_name, @real_name)
      rescue
        body_entry = @body_pokemon.real_pokedex_entry.gsub(@body_pokemon.real_name, @real_name)
        head_entry = @head_pokemon.real_pokedex_entry.gsub(@head_pokemon.real_name, @real_name)
      end
      echoln body_entry
      echoln head_entry
      combined_entry = split_and_combine_text(body_entry, head_entry, ".")
      combined_entry += "." unless combined_entry.end_with?(".")
      return combined_entry
    end

    def calculate_egg_groups
      body_egg_groups = @body_pokemon.egg_groups
      head_egg_groups = @head_pokemon.egg_groups
      return :Undiscovered if body_egg_groups.include?(:Undiscovered) || head_egg_groups.include?(:Undiscovered)
      return combine_arrays(body_egg_groups, head_egg_groups)
    end

    def calculate_hatch_steps
      return average_values(@head_pokemon.hatch_steps, @body_pokemon.hatch_steps)
    end

    def calculate_evs()
      return average_map_values(@body_pokemon.evs, @head_pokemon.evs)
    end

    def calculate_category
      return split_and_combine_text(@body_pokemon.category, @head_pokemon.category, " ")
    end

    def calculate_growth_rate
      growth_rate_priority = [:Fast, :Medium, :Parabolic, :Fluctuating, :Erratic, :Slow] #todo rearrange order for balance?
      body_growth_rate = @body_pokemon.growth_rate
      head_growth_rate = @head_pokemon.growth_rate
      base_growth_rates = [body_growth_rate, head_growth_rate]
      for rate in growth_rate_priority
        return rate if base_growth_rates.include?(rate)
      end
      return :Medium
    end

    #TODO
    # ################## UNFINISHED ####################
    def calculate_gender
      return :Genderless
    end

    #############################  UTIL METHODS ###############################

    #Takes 2 strings, splits and combines them using the beginning of the first one and the end of the second one
    # (for example for pokedex entries)
    def split_and_combine_text(beginingText_full, endText_full, separator)
      beginingText_split = beginingText_full.split(separator, 2)
      endText_split = endText_full.split(separator, 2)

      beginningText = beginingText_split[0]
      endText = endText_split[1] && endText_split[1] != "" ? endText_split[1] : endText_split[0]
      return beginningText + separator + " " + endText
    end

    def calculate_fused_stats(dominantStat, otherStat)
      return ((2 * dominantStat) / 3) + (otherStat / 3).floor
    end

    def average_values(value1, value2)
      return ((value1 + value2) / 2).floor
    end

    def average_map_values(map1, map2)
      averaged_map = map1.merge(map2) do |key, value1, value2|
        ((value1 + value2) / 2.0).floor
      end
      return averaged_map
    end

    def get_highest_value(value1, value2)
      return value1 > value2 ? value1 : value2
    end

    def get_lowest_value(value1, value2)
      return value1 < value2 ? value1 : value2
    end

    def combine_arrays(array1, array2)
      return array1 + array2
    end

  end
end
