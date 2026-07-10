class SecretBase
  attr_reader :outside_map_id #Id of the map where the secret base is
  attr_reader :inside_map_id #Id of the secret base's map itself

  attr_reader :location_name #Name of the Route where the secret base is in plain text


  attr_reader :outside_entrance_position #Fly coordinates
  attr_reader :inside_entrance_position #Where the player gets warped

  attr_reader :biome_type #:CAVE, :TREE,
  attr_reader :base_layout_type
  attr_accessor :base_name
  attr_accessor :base_message

  attr_accessor :layout
  attr_accessor :is_visitor


  def initialize(biome:,outside_map_id:,outside_entrance_position:, inside_map_id:, base_layout_type:, is_visitor:, layout: nil, visitor_message:nil)
    @biome_type = biome
    @outside_map_id = outside_map_id
    @inside_map_id = inside_map_id

    @outside_entrance_position = outside_entrance_position
    @base_layout_type = base_layout_type.to_sym

    @inside_entrance_position = SecretBasesData::SECRET_BASE_ENTRANCES[@base_layout_type][:position]

    @base_name=initializeBaseName
    @base_message=visitor_message
    initialize_base_message unless @base_message #Message that people see when visiting the secret base
    @is_visitor=is_visitor
    @layout = layout
    initializeLayout unless @layout
  end

  def initializeBaseName
    return _INTL("{1}'s secret base",$Trainer.name)
  end

  def initialize_base_message
    return _INTL("Welcome to my secret base!")
  end
  def initializeLayout
    @layout = SecretBaseLayout.new(@base_layout_type,!@is_visitor)
    entrance_x = @inside_entrance_position[0]
    entrance_y = @inside_entrance_position[1]

    @layout.add_item(:PC,[entrance_x,entrance_y-3])
  end

  def load_furniture
    @layout.items.each do |item_instance|
      next unless item_instance.is_a?(SecretBaseItemInstance)
      next unless SecretBasesData::SECRET_BASE_ITEMS[item_instance.itemId]

      item_instance.direction = DIRECTION_DOWN


       template = item_instance.itemTemplate
      echoln template


      item_instance.create_events

      # event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_FURNITURE, $game_map.map_id, item_instance.position, DIRECTION_DOWN)
      # event.character_name = "player/SecretBases/#{template.graphics}"
      # event.through = template.pass_through
      # event.under_player = template.under_player
      # event.direction = item_instance.direction


      if item_instance.itemTemplate.id == :MANNEQUIN && @is_visitor
        setEventAppearance(item_instance.main_event.id, @trainer_appearance) if @trainer_appearance
      end
      # item_instance.setMainEventId(event.id)
      item_instance.refresh_events
      #event.refresh
    end
  end

end
