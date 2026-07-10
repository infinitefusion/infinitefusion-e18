class ContactsAppScene < PokeNavAppScene
  INFO_TEXT_Y = 270
  def cursor_x_offset
    return 16
  end
  def cursor_y_offset
    return -16
  end

  def header_name
    return _INTL("Trainers")
  end

  def cursor_path
    return "Graphics/Pictures/Pokegear/Trainers/icon_button_static"
  end

  def header_path
    return "Graphics/Pictures/Pokegear/Trainers/bg_header_trainers"
  end

  def display_mode
    return :LIST
  end

  def x_gap
    return 74;
  end

  def y_gap
    return 48;
  end

  def columns
    return 1
  end

  def visible_rows
    return 3
  end

  def start_x
    return 40;
  end

  def start_y
    return 80;
  end


  def pbStartScene(screen)
    @screen = screen
    buttons = []
    @trainers = []
    @contacts_list = screen.list_contacts
    @contacts_list.each do |location, trainers_list|
      next unless location
      buttons << ContactsAppLocationButton.new(location, nil, location)
      next unless trainers_list && trainers_list.size > 0
      trainers_list.each do |trainer|
        next unless trainer
        next unless screen.can_be_listed(trainer)
        trainerClassName = GameData::TrainerType.get(trainer.trainerType).name
        trainerName = MessageTypes.getFromHash(MessageTypes::TrainerNames, trainer.trainerName) || trainer.trainerName
        trainer_name = _INTL("{1} {2}", trainerClassName, trainerName)
        @trainers << trainer.id
        button = ContactsAppTrainerButton.new(trainer.id, trainer.overworld_sprite, trainer_name)

        $Trainer.pokenav.viewed_trainers = [] unless $Trainer&.pokenav&.viewed_trainers
        button.set_trade_available(trainer.can_trade?)
        button.set_new(!$Trainer.pokenav.viewed_trainers.include?(trainer.id))
        buttons << button
      end
    end

    super(buttons)
    @index = 1
    scroll_to_current_location
    displayTextElements
    @buttons[@index].hover
  end


  def updateInput
    cols = columns
    total = @buttons.length
    move_delay = 2
    if Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @exiting = true
      return
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      click(@buttons[@index]&.id)
    elsif Input.repeat?(Input::LEFT)
      prev_location = find_previous_location_index
      move_to_index(prev_location+1)
      pbWait(move_delay)
    elsif Input.repeat?(Input::RIGHT)
      next_location = find_next_location_index
      move_to_index(next_location+1)
      pbWait(move_delay)
    elsif Input.repeat?(Input::UP)
      move_index(-cols)
      pbWait(move_delay)
    elsif Input.repeat?(Input::DOWN)
      move_index(cols)
      pbWait(move_delay)
    end
  end

  def scroll_to_current_location
    current_location_name = getMapName($game_map.map_id)
    for i in @index..@buttons.length-1
      if @buttons[i].is_a?(ContactsAppLocationButton) && @buttons[i].id == current_location_name
        new_index = i+1 #next index for the first trainer in that location
        move_to_index(new_index)
      end
    end
  end

  def find_next_location_index
    for i in @index..@buttons.length-1
      if @buttons[i].is_a?(ContactsAppLocationButton)
        return i
      end
    end
    return @buttons.length-1
  end

  def find_previous_location_index
    found_current_location = false
    for i in @index.downto(0)
      if @buttons[i].is_a?(ContactsAppLocationButton)
        return i if found_current_location
        found_current_location = true
      end
    end
    return 1
  end

  def move_index(delta)
    return if @buttons.empty?
    pbPlayCursorSE
    new_index = (@index + delta) % @buttons.length
    if @buttons[new_index].is_a?(ContactsAppLocationButton)
      new_index = new_index + delta
    end
    new_index = @buttons.length - 1 if new_index < 0
    @index = new_index
    hover(@buttons[@index]&.id)
  end

  def createCursor
    super
    @sprites["cursor"].x=16
    @sprites["cursor"].y=-32
  end

  def click(button_id)
    super
    @screen.view_trainer_page(button_id, @trainers)
    # cmd_info = _INTL("Info")
    # cmd_team = _INTL("View Team")
    # cmd_cancel = _INTL("Cancel")
    # commands = [cmd_info, cmd_team, cmd_cancel]
    # choice = pbMessage(_INTL("What would you like to do?"), commands, commands.size)
    # case commands[choice]
    # when cmd_info
    #   @screen.view_trainer_page(button_id, @trainers)
    # when cmd_team
    #   @screen.view_trainer_team(button_id)
    # end
  end

  def layoutButtons
    return if @exiting
    current_row = @index
    scroll_row = [current_row - visible_rows + 1, 0].max

    y_positions = []
    cumulative_y = 0
    @buttons.each do |btn|
      y_positions << cumulative_y
      cumulative_y += btn.get_height + (btn.respond_to?(:bottom_margin) ? btn.bottom_margin : 0)
    end

    scroll_pixels = y_positions[[scroll_row, @buttons.length - 1].min]

    @buttons.each_with_index do |btn, i|
      btn.x = start_x
      btn.y = start_y + y_positions[i] - scroll_pixels
      btn.visible = (btn.y >= start_y - btn.get_height && btn.y <= Graphics.height)
      btn.selected = (i == @index)
    end

    updateCursor
    updateHeader(scroll_row)
  end

  def pbUpdate
    super
    @buttons.each { |btn| btn.update if btn.respond_to?(:update) }
  end

  def hover(button_id)
    super
  end
end
