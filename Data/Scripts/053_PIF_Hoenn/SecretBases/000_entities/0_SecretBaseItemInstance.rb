# frozen_string_literal: true
class SecretBaseItemInstance
  attr_reader :itemId
  attr_reader :instanceId
  attr_accessor :position
  attr_accessor :direction
  attr_accessor :itemTemplate
  attr_accessor :main_event_id
  attr_reader :disposed
  attr_reader :main_event

  RANDOM_ID_LENGTH = 6

  def initialize(itemId, position = [0, 0], direction = DIRECTION_DOWN)
    @itemId = itemId
    @instanceId = generate_new_instance_id()
    @direction = direction
    @position = position
    @main_event = nil # Objects that are wider or taller than 1 tile work by duplicating the object, but making only the middle instance visible. This contains the id of the middle instance
  end

  def create_events()
    template = get_item_template
    @volume_events = []
    main_event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_FURNITURE, $game_map.map_id, @position, @direction)
    main_event.character_name = "player/SecretBases/#{template.graphics}"
    main_event.through = template.pass_through
    main_event.under_player = template.under_player

    main_event.trigger = template.trigger
    @main_event = main_event
    occupied_positions = calculate_occupied_volume_positions(@position)
    occupied_positions.each do |position|
      event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_FURNITURE, $game_map.map_id, position)
      event.character_name = "player/SecretBases/empty" # Game will consider it passable if we don't put anything here
      event.through = template.pass_through
      event.trigger = template.trigger

      @volume_events << event
    end

  end

  # Use this - can't save it into the object because of proc
  def get_item_template
    return SecretBasesData::SECRET_BASE_ITEMS[@itemId]
  end

  # fake accessor
  def itemTemplate
    return get_item_template
  end

  def get_occupied_positions()
    occupied_positions = []
    occupied_positions << [@main_event.x, @main_event.y]
    @volume_events.each do |event|
      occupied_positions << [event.x, event.y]
    end
    return occupied_positions
  end

  def interactable?(position = [0,0])
    return true#

    #TODO
    return get_interactable_positions.include?(position)
  end

  def get_interactable_positions()
    all_positions = get_occupied_positions
    uninteractable_positions = get_item_template.uninteractable_positions
    main_x, main_y = @main_event.x, @main_event.y

    uninteractable_absolute_positions = uninteractable_positions.map do |dx, dy|
      [main_x + dx, main_y + dy]
    end
    interactable_positions = all_positions.reject do |pos|
      uninteractable_absolute_positions.include?(pos)
    end
    return interactable_positions
  end

  def calculate_occupied_volume_positions(main_event_position)
    return [] #TODO
    template = get_item_template

    item_x, item_y = main_event_position
    item_height = template.height || 1
    item_width = template.width || 1
    direction = @direction

    # Flip width/height if rotated sideways
    if direction == DIRECTION_LEFT || direction == DIRECTION_RIGHT
      item_width, item_height = item_height, item_width
    end

    half_width = (item_width - 1) / 2
    half_height = (item_height - 1) / 2

    occupied_positions = []

    x_range = (item_x - half_width..item_x + half_width)
    y_range = (item_y - half_height..item_y + half_height)
    x_range.each do |x|
      y_range.each do |y|
        is_main_event = (x == item_x && y == item_y)
        next if is_main_event

        occupied_positions << [x, y]
      end
    end
    return occupied_positions

  end

  def refresh_events
    @main_event.refresh
    @volume_events.each do |event|
      event.refresh
    end
  end

  def name
    return itemTemplate&.real_name
  end

  def getGraphics()
    return itemTemplate.graphics
  end

  def height
    return itemTemplate.height
  end

  def width
    return itemTemplate.width
  end

  def generate_new_instance_id()
    randomId = rand(36 ** RANDOM_ID_LENGTH).to_s(36)
    return "#{@itemId}_#{randomId}"
  end

  def getMainEvent()
    return @main_event
  end

  def disposed?
    return @disposed
  end

  def dispose
    @itemId = nil
    @position = nil
    @direction = nil
    @main_event_id = nil
    @itemTemplate = nil
    @disposed = true

    @main_event.erase
    @main_event = nil
    @volume_events.each do |event|
      event.erase
    end
    @volume_events = nil
  end

  def connect_to_other_instance(instance_id)
    @volume_events << instance_id
  end

  def set_main_instance(instance_id)
    @main_event = instance_id
  end
end