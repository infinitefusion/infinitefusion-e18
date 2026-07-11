class BattledTrainer
  DELAY_BETWEEN_NPC_TRADES = 180 # In seconds (3 minutes)
  MAX_FRIENDSHIP = 100

  attr_accessor :trainerType
  attr_accessor :trainerName
  attr_accessor :trainerKey

  attr_accessor :currentTeam # list of Pokemon. The game selects in this list for trade offers. They can increase levels & involve as you rebattle them.

  # trainers will randomly find items and add them to this list. When they have the :ITEM status, they will
  # give one of them at random.
  # Items equipped to the Pokemon traded by the player will end up in that list.
  #
  # If there is an evolution that the trainer can use on one of their Pokemon in that list, they will
  # instead use it to evolve their Pokemon.
  #
  # DNA Splicers/reversers can be used on their Pokemon if they have at least 2 unfused/1 fused
  #
  # Healing items that are in that list can be used by the trainer in rematches
  #
  attr_accessor :inventory
  attr_accessor :nb_rematches

  # What the trainer currently wants to do
  # :IDLE -> Nothing. Normal postbattle dialogue
  # Should prompt the player to register the trainer in their phone.
  # Or maybe done automatically at the end of the battle?

  # :TRADE -> Trainer wants to trade one of its Pokémon with the player

  # :BATTLE -> Trainer wants to rebattle the player

  # :ITEM -> Trainer has an item they want to give the player
  attr_accessor :current_status
  attr_accessor :previous_status
  attr_accessor :previous_trade_timestamp

  attr_accessor :favorite_type
  attr_accessor :favorite_pokemon # Used for generating trade offers. Should be set from trainer.txt (todo)
  # If empty, then trade offers ask for a Pokemon of a type depending on the trainer's class

  attr_accessor :previous_random_events
  attr_accessor :has_pending_action
  attr_accessor :custom_appearance

  attr_accessor :friendship # increases the more you interact with them, unlocks more interact options
  attr_accessor :friendship_level

  attr_accessor :overworld_sprite

  attr_reader :favorite

  def initialize(trainerType, trainerName, trainerVersion, trainerKey)
    @trainerKey = trainerKey
    @trainerType = trainerType
    @trainerName = trainerName
    original_trainer = pbLoadTrainer(@trainerType, @trainerName, trainerVersion)
    @currentTeam = loadOriginalTrainerTeam(trainerVersion, original_trainer)
    @inventory = original_trainer.items || []
    @nb_rematches = 0
    @currentStatus = :IDLE
    @previous_status = :IDLE
    @previous_trade_timestamp = Time.now - DELAY_BETWEEN_NPC_TRADES
    @previous_random_events = []
    @has_pending_action = false
    @favorite_type = pick_favorite_type(trainerType)
    @friendship = 0
    @friendship_level = 0
    @overworld_sprite = ""
    @location = _INTL("Unknown location")
    @favorite = false
  end

  def id
    return @trainerKey
  end

  def location
    if @location.nil?
      return _INTL("Unknown location")
    end
    return @location
  end

  # For double trainer classes like twins, etc. Adds an additional double rematch option.
  def setLinkedTrainer(linked_trainer_event)
    return if @linked_event
    @linked_event = linked_trainer_event
  end

  def setOverworldSprite(overworld_sprite)
    @overworld_sprite = overworld_sprite
  end

  def setLocation(location_name)
    @location = location_name
  end

  def setFavorite(value)
    @favorite = value
  end

  def getLinkedTrainer()
    trainer = getRebattledTrainer(@linked_event, $game_map.map_id)
    return trainer if trainer
    return nil
  end

  def friendship_level
    @friendship_level = 0 if !@friendship_level
    return @friendship_level
  end

  def list_battle_items
    @inventory = [] unless @inventory
    battle_items = []
    @inventory.each do |item_id|
      item = GameData::Item.get(item_id)
      can_use_in_battle = item.has_battle_use? && !item.is_poke_ball?
      battle_items << item_id if can_use_in_battle
    end
    return battle_items
  end

  def list_evolution_items
    @inventory = [] unless @inventory
    evo_items = []
    @inventory.each do |item_id|
      item = GameData::Item.get(item_id)
      evo_items << item_id if item.is_evolution_stone?
    end
    return evo_items
  end

  def increase_friendship(amount)
    @friendship = 0 if !@friendship
    @friendship_level = 0 if !@friendship_level
    gain = amount / ((@friendship + 1) ** 0.4)
    @friendship += gain
    @friendship = MAX_FRIENDSHIP if @friendship > MAX_FRIENDSHIP

    echoln "Friendship with #{@trainerName} increased by #{gain.round(2)} (total: #{@friendship.round(2)})"

    thresholds = FRIENDSHIP_LEVELS[@trainerType] || []
    while @friendship_level < thresholds.length && @friendship >= thresholds[@friendship_level]
      @friendship_level += 1

      trainerClassName = GameData::TrainerType.get(@trainerType).real_name
      pbMessage(_INTL("\\C[3]Friendship increased with {1} {2}!", trainerClassName, @trainerName))
      case @friendship_level
      when 1
        pbMessage(_INTL("You can now trade with each other!"))
      when 2
        pbMessage(_INTL("They will now give you items after rematches from time to time!"))
        $Trainer.nb_npc_friends = 0 unless $Trainer.nb_npc_friends
        $Trainer.nb_npc_friends += 1 # odds of shiny pokemon increases slightly the more NPCs at matx friendship you have
      when 3
        # pbMessage(_INTL("You can now partner up with them!"))
      end
      echoln "#{@trainerName}'s friendship level increased to #{@friendship_level}!"
    end
    if @friendship_level >= 3 && !@gave_clothes
      tryGiftTrainerClothes(@trainerType)
      @gave_clothes = true
    end
  end

  def process_party_pokemon_held_items
    store_held_item_chance = 25
    store_evolution_item_chance = 70
    store_usable_item_chance = 80

    chance_to_give_item = 60

    #Move pokemon held items to inventory
    @currentTeam.each do |pokemon|
      next unless pokemon.item
      next if pokemon.item.id == :EVERSTONE
      held_item = pokemon.item
      is_holdable_item = HELD_ITEMS.include?(held_item.id)
      echoln "#{held_item} #{is_holdable_item}"
      next if is_holdable_item && rand(100) >= store_held_item_chance

      is_evolution_item = held_item.is_evolution_stone?
      is_battle_item = held_item.has_battle_use?

      chance_to_store = store_held_item_chance
      chance_to_store = store_evolution_item_chance if is_evolution_item
      chance_to_store = store_usable_item_chance if is_battle_item
      if rand(100) <= chance_to_store
        @inventory << held_item.id
        echoln "#{@trainerType} #{@trainerName} took the #{pokemon.item} from #{pokemon.name}"
        pokemon.item = nil
      end
    end

    #give inventory items to pokemon
    items_to_delete = []
    @inventory.each do |item|
      is_holdable_item = HELD_ITEMS.include?(item)
      if is_holdable_item && rand(100) <= chance_to_give_item
        party_pokemon_without_items = []
        # give to random party member
        party_index = 0
        @currentTeam.each do |pokemon|
          party_pokemon_without_items << party_index unless pokemon.item
          party_index+=1
        end

        unless party_pokemon_without_items.empty?
          chosen_pokemon_index= party_pokemon_without_items.sample
          @currentTeam[chosen_pokemon_index].item = item
          echoln "#{@trainerType} #{@trainerName} gave a #{item} to #{@currentTeam[chosen_pokemon_index].name}"
          items_to_delete << item
        end
      end
    end

    items_to_delete.each do |item|
      index = @inventory.index(item)
      @inventory.delete_at(index) if index
    end
  end

  def tryGiftTrainerClothes(trainerType)
    event = pbMapInterpreter.get_character(0)
    case trainerType
    when :BUGCATCHER
      if !hasClothes?(CLOTHES_BUG_CATCHER_RSE)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Oh, you really like bugs too, right? Well, I have something for you!"))
        obtainClothes(CLOTHES_BUG_CATCHER_RSE)
      elsif !hasClothes?(CLOTHES_BUG_CATCHER_ORAS)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Hey! You know, if you're looking to catch more bugs, you should try putting this on!"))
        obtainClothes(CLOTHES_BUG_CATCHER_ORAS)
        obtainHat(HAT_BUG_CATCHER_ORAS)
      end
    when :FISHERMAN
      if !hasClothes?(CLOTHES_FISHERMAN_ORAS)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Ho ho! You've been hanging around while I fish for so long, you're practically an angler yourself. It's time you dressed like one!"))
        obtainClothes(CLOTHES_FISHERMAN_ORAS)
        obtainHat(HAT_FISHERMAN_ORAS)
      end
    when :YOUNGSTER
      if !hasClothes?(CLOTHES_YOUNGSTER_RSE)
        pbCallBub(2, event.id)
        pbMessage(_INTL("All these rematches are so fun! Here, you should dress like me!"))
        obtainClothes(CLOTHES_YOUNGSTER_RSE)
      elsif !hasClothes?(CLOTHES_YOUNGSTER_ORAS)
        pbCallBub(2, event.id)
        pbMessage(_INTL("I give clothes to all of my friends! Here you go!"))
        obtainClothes(CLOTHES_YOUNGSTER_ORAS)
      elsif !hasClothes?(CLOTHES_YOUNGSTER_HGSS)
        pbCallBub(2, event.id)
        pbMessage(_INTL("You moved here from Johto, right? My friend from Johto wears clothes like these!"))
        obtainClothes(CLOTHES_YOUNGSTER_HGSS)
      end
    when :LADY
      if !hasClothes?(CLOTHES_LADY)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Oh my goodness, look at your clothes! This simply won't do. Here, I bought this for you!"))
        obtainClothes(CLOTHES_LADY)
      end
    when :TUBER_M, :TUBER_F # Todo: Change for Swimmer Male when it's in the game!
      if !hasClothes?(CLOTHES_SWIMMING_M)
        pbCallBub(2, event.id)
        pbMessage(_INTL("The beach is so fun! Oh! Wear this before you go swimming in the water!"))
        obtainClothes(CLOTHES_SWIMMING_M)
      end
    when :SAILOR # Todo: Change for Swimmer Male when it's in the game!
      if !hasClothes?(CLOTHES_SAILOR)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Sailor! You're a good battler, but you need to wear something this if you want to conquer the sea!"))
        obtainClothes(CLOTHES_SAILOR)
        obtainHat(HAT_SAILOR)
      end
    when :PSYCHIC_M
      if !hasClothes?(CLOTHES_PSYSHAMAN_M)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Don't say anything... I know you want this."))
        obtainClothes(CLOTHES_PSYSHAMAN_M)
      end
    when :PSYCHIC_F
      if !hasClothes?(CLOTHES_PSYSHAMAN_F)
        pbCallBub(2, event.id)
        pbMessage(_INTL("Don't say anything... I know you want this."))
        obtainClothes(CLOTHES_PSYSHAMAN_F)
      end
    when :POKEFAN_M, :POKEFAN_F
      possible_masks = [HAT_POOCHYENA_MASK, HAT_LOTAD_MASK, HAT_ZIGZAGOON_MASK, HAT_WURMPLE_MASK]
      unobtained_masks = possible_masks.reject { |hatID| hasHat?(hatID) }
      unless unobtained_masks.empty?
        pbCallBub(2, event.id)
        pbMessage(_INTL("\\PN, you're a true Poké Fan like me! Here's a fun mask for you or your Pokémon!"))
        obtainHat(unobtained_masks.sample)
      end
    end

  end

  def set_custom_appearance(trainer_appearance)
    @custom_appearance = trainer_appearance
  end

  def pick_favorite_type(trainer_type)
    if TRAINER_CLASS_FAVORITE_TYPES.has_key?(trainer_type)
      return TRAINER_CLASS_FAVORITE_TYPES[trainer_type].sample
    else
      return :NORMAL
    end
  end

  def set_pending_action(value)
    @has_pending_action = value
  end

  def log_evolution_event(unevolved_pokemon_species, evolved_pokemon_species)
    echoln "NPC Trainer #{@trainerName} evolved their #{get_species_readable_internal_name(unevolved_pokemon_species)} to #{get_species_readable_internal_name(evolved_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:EVOLVE)
    event.unevolved_pokemon = unevolved_pokemon_species
    event.evolved_pokemon = evolved_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_fusion_event(body_pokemon_species, head_pokemon_species, fused_pokemon_species)
    echoln "NPC trainer #{@trainerName} fused #{body_pokemon_species} and #{head_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:FUSE)
    event.fusion_body_pokemon = body_pokemon_species
    event.fusion_head_pokemon = head_pokemon_species
    event.fusion_fused_pokemon = fused_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_unfusion_event(original_fused_pokemon_species, unfused_body_species, unfused_body_head)
    echoln "NPC trainer #{@trainerName} unfused #{get_species_readable_internal_name(original_fused_pokemon_species)}!"
    event = BattledTrainerRandomEvent.new(:UNFUSE)
    event.unfused_pokemon = original_fused_pokemon_species
    event.fusion_body_pokemon = unfused_body_species
    event.fusion_head_pokemon = unfused_body_head
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_reverse_event(original_fused_pokemon_species, reversed_fusion_species)
    echoln "NPC trainer #{@trainerName} reversed #{get_species_readable_internal_name(original_fused_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:REVERSE)
    event.unreversed_pokemon = original_fused_pokemon_species
    event.reversed_pokemon = reversed_fusion_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_catch_event(new_pokemon_species)
    echoln "NPC Trainer #{@trainerName} caught a #{new_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:CATCH)
    event.caught_pokemon = new_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def clear_previous_random_events()
    @previous_random_events = []
  end

  def loadOriginalTrainer(trainerVersion = 0)
    return pbLoadTrainer(@trainerType, @trainerName, trainerVersion)
  end

  def loadOriginalTrainerTeam(trainerVersion = 0, original_trainer=nil)
    original_trainer = pbLoadTrainer(@trainerType, @trainerName, trainerVersion) unless original_trainer

    return if !original_trainer
    echoln "Loading Trainer #{@trainerType}"
    current_party = []
    original_trainer.party.each do |partyMember|
      echoln "PartyMember: #{partyMember}"
      if partyMember.is_a?(Pokemon)
        current_party << partyMember
      elsif partyMember.is_a?(Array) # normally always gonna be this
        pokemon_species = partyMember[0]
        pokemon_level = partyMember[1]
        current_party << Pokemon.new(pokemon_species, pokemon_level, original_trainer.name)
      else
        echoln "Could not add Pokemon #{partyMember} to rematchable trainer's party."
      end
    end

    return current_party
  end

  def getTimeSinceLastTrade()
    @previous_trade_timestamp ||= Time.now - DELAY_BETWEEN_NPC_TRADES
    return Time.now - @previous_trade_timestamp
  end

  def isNextTradeReady?()
    return getTimeSinceLastTrade >= DELAY_BETWEEN_NPC_TRADES
  end

  def can_trade?()
    trade_unlocked = @friendship_level >= FRIENDSHIP_LEVEL_FOR_TRADE
    if trade_unlocked
      return isNextTradeReady?
    end
    return false
  end

  def list_team_unfused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if !pokemon.isFusion?
    end
    return list
  end

  def list_team_fused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if pokemon.isFusion?
    end
    return list
  end
end