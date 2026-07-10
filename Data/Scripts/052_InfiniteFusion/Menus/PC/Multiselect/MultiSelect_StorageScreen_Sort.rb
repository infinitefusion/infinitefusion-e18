class PokemonStorageScreen
  # --- Define sortable criteria ---
  def sortable_criteria
    [
      {
        key: :dex,
        label: _INTL("By Pokédex number"),
        value_proc: ->(p) { p.id_number || 0 },
        friendly: [_INTL("Lowest to Highest Pokédex #"), _INTL("Highest to Lowest Pokédex #")]
      },
      {
        key: :head_dex,
        label: _INTL("By head Pokédex number"),
        value_proc: ->(p) { p.head_id || 0 },
        friendly: [_INTL("Lowest to Highest Pokédex #"), _INTL("Highest to Lowest Pokédex #")]
      },
      {
        key: :body_dex,
        label: _INTL("By body Pokédex number"),
        value_proc: ->(p) { p.body_id || 0 },
        friendly: [_INTL("Lowest to Highest Pokédex #"), _INTL("Highest to Lowest Pokédex #")]
      },
      {
        key: :alpha_species,
        label: _INTL("By species name"),
        value_proc: ->(p) { (p.species.to_s || "").downcase },
        friendly: [_INTL("A to Z"), _INTL("Z to A")]
      },
      {
        key: :alpha,
        label: _INTL("By nickname"),
        value_proc: ->(p) { (p.name || "").downcase },
        friendly: [_INTL("A to Z"), _INTL("Z to A")]
      },
      {
        key: :level,
        label: _INTL("By base stats"),
        value_proc: ->(p) { p.bst || 0 },
        friendly: [_INTL("Lowest to Highest BST"), _INTL("Highest to Lowest BST")]
      },
      {
        key: :level,
        label: _INTL("By level"),
        value_proc: ->(p) { p.level || 0 },
        friendly: [_INTL("Lowest to Highest level"), _INTL("Highest to Lowest level")]
      },
      {
        key: :type,
        label: _INTL("By type"),
        value_proc: ->(p) {
          # Grab both types (fallbacks in case one is nil)
          t1 = p.type1 || :NORMAL
          t2 = p.type2 || ""
          [
            GameData::Type.get(t1).name,
            GameData::Type.get(t2).name
          ]
        },
        friendly: [_INTL("A to Z by type"), _INTL("Z to A by type")]
      },
      {
        key: :date,
        label: _INTL("By date caught"),
        value_proc: ->(p) { p.timeReceived || Time.at(0) },
        friendly: [_INTL("Oldest to Newest"), _INTL("Newest to Oldest")]
      },
      {
        key: :invert,
        label: _INTL("Reverse"),
        value_proc: ->(p) { reverse },
        friendly: [_INTL("Reverse the order")]
      },
      {
        key: :random,
        label: _INTL("Shuffle"),
        value_proc: ->(p) { rand },
        friendly: [_INTL("Randomize the order")]
      },

    ]
  end

  # --- Ask which criterion to sort by ---
  def pbAskSortCriterion
    commands = sortable_criteria.map { |c| c[:label] } + [_INTL("Cancel")]
    cmd = pbShowCommands(_INTL("Sort selected Pokémon how?"), commands)
    return nil if cmd == commands.length - 1
    return nil if cmd <= -1
    return cmd
  end

  # --- Ask for order using friendly text ---
  def pbAskSortOrder(criterion_index)
    crit = sortable_criteria[criterion_index]
    orders = crit[:friendly] + [_INTL("Cancel")]
    ord = pbShowCommands(_INTL("Sort order?"), orders)
    return nil if ord <= -1
    return nil if ord == orders.length - 1
    return ord == 1 # true if descending
  end

  # --- Sort the array according to criterion and order ---
  def sort_pokemon_array!(arr, criterion_index, descending)
    crit = sortable_criteria[criterion_index]
    if crit[:key] == :invert
      arr.reverse!
      return
    end
    arr.sort_by! { |p| crit[:value_proc].call(p) }
    arr.reverse! if descending
  end

  # --- Main method stays mostly unchanged ---
  def pbSortMulti(box)
    selected = getMultiSelection(box, nil)
    return if selected.empty?

    pokes = selected.map { |idx| @storage[box, idx] }.compact
    return if pokes.empty?

    criterion = pbAskSortCriterion
    return if criterion.nil?

    descending = pbAskSortOrder(criterion)
    return if descending.nil?

    sort_pokemon_array!(pokes, criterion, descending)

    # Clear selected slots
    selected.each { |idx| @storage[box, idx] = nil }

    # Refill the rectangle row-by-row
    rect = getSelectionRect(box, nil)
    i = 0
    if rect
      for y in rect.y...(rect.y + rect.height)
        for x in rect.x...(rect.x + rect.width)
          break if i >= pokes.length
          idx = getBoxIndex(box, x, y)
          @storage[box, idx] = pokes[i]
          i += 1
        end
      end
    else
      selected.each do |idx|
        break if i >= pokes.length
        @storage[box, idx] = pokes[i]
        i += 1
      end
    end

    pbSEPlay("GUI party switch")
    @scene.pbHardRefresh
  end


end