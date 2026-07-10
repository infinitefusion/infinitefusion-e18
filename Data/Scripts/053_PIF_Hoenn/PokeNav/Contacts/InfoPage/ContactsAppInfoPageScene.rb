class ContactsAppInfoPageScene < PokeNavAppScene
  attr_accessor :trainer

  SPRITE_POSITION_X = 375
  SPRITE_POSITION_Y = 230

  TITLE_TEXT_X = 380
  TITLE_TEXT_Y = 50

  INFO_HEADER_X = 40
  INFO_TEXT_X = 60
  INFO_TEXT_START_Y = 50
  INFO_TEXT_GAP = 40
  INFO_HEADER_GAP = 30

  FRIENDSHIP_ICON = "Graphics/Pictures/Pokegear/Trainers/friendship"
  FRIENDSHIP_ICON_GAP = 4
  ICON_SIZE = 16
  FRIENDSHIP_ICON_START_X = 40
  FRIENDSHIP_ICON_START_Y = 20

  INFO_TEXT_LINES_PER_PAGE = 2

  def header_name
    return _INTL("Trainers")
  end

  def cursor_path
    return "Graphics/Pictures/Pokeradar/icon_button"
  end

  def header_path
    return "Graphics/Pictures/Pokegear/bg_header_trainers"
  end

  def bg_path
    return "Graphics/Pictures/Pokegear/Trainers/bg_summary"
  end

  def display_mode
    return :LIST
  end

  def x_gap
    return 75;
  end

  def y_gap
    return 64;
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

  def initialize
    super
    @value_color_base = Color.new(24, 112, 216)
    @value_color_shadow = Color.new(136, 168, 208)
    if isDarkMode
      @value_color_base, @value_color_shadow = @value_color_shadow, @value_color_base
    end
    @info_text_page = 0
    @info_text_pages = []
  end

  def pbStartScene(screen, trainer)
    echoln "start"
    @screen = screen
    buttons = []
    @trainer = trainer
    super(buttons)
    if @trainer
      showTrainerSprite
      showTrainerInfo
      showFriendshipIcons
    else
      pbEndScene
    end
  end

  def showTrainerSprite
    if @trainer.id == BATTLED_TRAINER_RIVAL_KEY
      bitmap = generate_front_trainer_sprite_bitmap_from_appearance($Trainer.rival_appearance)
      @sprites["trainer"] = IconSprite.new(0, 0, @viewport)
      @sprites["trainer"].setBitmapDirectly(bitmap)
    else
      trainerFile = GameData::TrainerType.front_sprite_filename(@trainer.trainerType)
      @sprites["trainer"] = IconSprite.new(0, 0, @viewport)
      @sprites["trainer"].setBitmap(trainerFile)
    end

    if @sprites["trainer"].bitmap &&
      @sprites["trainer"].bitmap.width > @sprites["trainer"].bitmap.height * 2
      @sprites["trainer"].src_rect.x = 0
      @sprites["trainer"].src_rect.width = @sprites["trainer"].bitmap.width / 5
    end

    @sprites["trainer"].ox = @sprites["trainer"].src_rect.width / 2
    @sprites["trainer"].oy = @sprites["trainer"].bitmap.height
    @sprites["trainer"].z = 50
    @sprites["trainer"].x = SPRITE_POSITION_X
    @sprites["trainer"].y = SPRITE_POSITION_Y

  end


  def showFriendshipIcons
    @friendship_icons&.each(&:dispose)
    @friendship_icons = []
    (@trainer.friendship_level || 0).times do |i|
      sprite = IconSprite.new(0, 0, @viewport)
      sprite.setBitmap(FRIENDSHIP_ICON)
      sprite.x = FRIENDSHIP_ICON_START_X + i * (ICON_SIZE + FRIENDSHIP_ICON_GAP)
      sprite.y = FRIENDSHIP_ICON_START_Y
      sprite.z = 100002
      @friendship_icons << sprite
      @sprites["friendship_icon_#{i}"] = sprite
    end
  end

  def showTrainerInfo
    Kernel.pbClearText
    showHeaderName

    trainerClassName = GameData::TrainerType.get(@trainer.trainerType).name
    trainerName = MessageTypes.getFromHash(MessageTypes::TrainerNames, @trainer.trainerName) || @trainer.trainerName
    trainer_name = _INTL("{1} {2}", trainerClassName, trainerName)
    level_sum = 0
    if @trainer.currentTeam.size > 0
      @trainer.currentTeam.each do |pokemon|
        level_sum += pokemon.level
      end
      average_level = (level_sum / @trainer.currentTeam.length).round
    else
      average_level = _INTL("N/A")
    end

    location = @trainer.location
    if @trainer.id == BATTLED_TRAINER_RIVAL_KEY
      favorite_type = _INTL("All")
    elsif @trainer.id == BATTLED_TRAINER_WALLY_KEY
      favorite_type = _INTL("Unknown")
    else
      favorite_type = (GameData::Type.try_get(@trainer.favorite_type)&.name) || _INTL("Unknown")
    end

    Kernel.pbDisplayText(trainer_name, TITLE_TEXT_X, TITLE_TEXT_Y, 999999, @text_color_base, @text_color_shadow)
    current_y = INFO_TEXT_START_Y
    displayText(_INTL("Location:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(location, INFO_TEXT_X, current_y)

    current_y += INFO_TEXT_GAP
    displayText(_INTL("Average team level:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(average_level.to_s, INFO_TEXT_X, current_y)

    current_y += INFO_TEXT_GAP
    displayText(_INTL("Favorite type:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(favorite_type, INFO_TEXT_X, current_y)

    trainer_data = GameData::Trainer.try_get(@trainer.trainerType, @trainer.trainerName, 0)
    current_y += INFO_TEXT_GAP * 1.5
    if @trainer.previous_random_events
      action = getBestMatchingPreviousRandomEvent(trainer_data, @trainer.previous_random_events)
      if action
        case action.eventType
        when :CATCH
          action_text = _INTL("Recently caught a {1}.",
                              GameData::Species.get(action.caught_pokemon).name)
        when :EVOLVE
          action_text = _INTL("Recently evolved their {1}.",
                              GameData::Species.get(action.evolved_pokemon).name)
        when :FUSE
          action_text = _INTL("Recently fused their {1} and {2}\.",
                              GameData::Species.get(action.fusion_head_pokemon).name,
                              GameData::Species.get(action.fusion_body_pokemon).name)
        when :UNFUSE
          action_text = _INTL("Recently unfused their {1}.",
                              GameData::Species.get(action.unfused_pokemon).name)
        when :REVERSE
          action_text = _INTL("Recently reversed their {1}.",
                              GameData::Species.get(action.reversed_pokemon).name)
        end
      end
    end
    displayInfoText(current_y, trainer_data, action_text)
  end

  def displayInfoText(current_y, trainer_data, action_text = nil)
    infoText = trainer_data&.infoText
    if infoText || action_text
      if infoText
        full_text = infoText.gsub("___", "")
        full_text = full_text.gsub("<PLAYER_NAME>", $Trainer.name)
        full_text = "\"#{full_text}\"" unless full_text.empty?
      end

      max_width = SPRITE_POSITION_X - INFO_HEADER_X - 20
      temp_bitmap = Bitmap.new(1, 1)
      all_lines = full_text ? wrap_text(full_text, temp_bitmap, max_width) : []
      temp_bitmap.dispose

      @info_text_pages = all_lines.each_slice(INFO_TEXT_LINES_PER_PAGE).to_a

      #insert action page as first
      @info_text_pages.unshift([action_text]) if action_text
      @info_text_page = @info_text_page.clamp(0, [@info_text_pages.size - 1, 0].max)

      page_lines = @info_text_pages[@info_text_page] || []
      page_lines.each do |line|
        displayText(line, INFO_HEADER_X, current_y)
        current_y += INFO_TEXT_GAP
      end

      if @info_text_pages.size > 1
        indicator = "#{@info_text_page + 1} / #{@info_text_pages.size}"
        displayText(indicator, Graphics.width - 80, 340)
      end
    else
      @info_text_pages = []
      @info_text_page = 0
    end
  end

  def rebuildInfoTextPage(all_lines)
    @info_text_pages = all_lines.each_slice(INFO_TEXT_LINES_PER_PAGE).to_a
    @info_text_page = @info_text_page.clamp(0, [@info_text_pages.size - 1, 0].max)
  end

  def updateInput
    if Input.trigger?(Input::UP)
      change_trainer(-1)
      pbSEPlay("GUI naming tab swap start")
    elsif Input.trigger?(Input::DOWN)
      change_trainer(1)
      pbSEPlay("GUI naming tab swap start")
    elsif Input.trigger?(Input::LEFT)
      if @info_text_pages.size > 1 && @info_text_page > 0
        @info_text_page -= 1
        pbSEPlay("GUI naming tab swap start")
        refresh_info_text
      end
    elsif Input.trigger?(Input::RIGHT)
      if @info_text_pages.size > 1 && @info_text_page < @info_text_pages.size - 1
        @info_text_page += 1
        pbSEPlay("GUI naming tab swap start")
        refresh_info_text
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @exiting = true
      return
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      click(@buttons[@index]&.id)
    end
  end

  # Re-renders only the info text area without rebuilding the whole scene.
  def refresh_info_text
    Kernel.pbClearText
    showHeaderName
    showTrainerInfo
  end

  def change_trainer(index_delta)
    @info_text_page = 0
    @info_text_pages = []
    @screen.change_trainer(index_delta)
    @sprites["trainer"]&.dispose
    @friendship_icons&.each_with_index { |_, i| @sprites.delete("friendship_icon_#{i}") }
    Kernel.pbClearText()
    showTrainerSprite
    showTrainerInfo
    showFriendshipIcons
  end

  def displayText(text, x_position, y_position)
    Kernel.pbDisplayText(text, x_position, y_position, nil, @text_color_base, @text_color_shadow, 3)
  end

  def displayValue(text, x_position, y_position)
    Kernel.pbDisplayText(text, x_position, y_position, nil, @value_color_base, @value_color_shadow, 3)
  end

  # def Kernel.pbDisplayText(message,xposition,yposition,z=nil, baseColor=nil, shadowColor=nil,alignment=2)

  def createCursor
    return if $PokemonTemp.pokeradar
    super
  end

  def click(button_id)
    super
    echoln @trainer.id
    cmd_team = _INTL("View Team")
    cmd_cancel = _INTL("Cancel")
    commands = []
    commands << cmd_team if @trainer.currentTeam.size > 0
    commands << cmd_cancel
    #choice = pbMessage(nil, commands, commands.size)
    choice = pbShowCommands(nil, commands, commands.size, 0, 330,200)
    case commands[choice]
    when cmd_team
      Kernel.pbClearText()
      @screen.view_trainer_team(@trainer.id)
      showTrainerInfo
    end
  end

  def hover(button_id)
    super
  end

  def pbEndScene
    super
    #Re-write the header name since going back to trainers list which has already been initialized
    Kernel.pbDisplayText(header_name, Graphics.width/2 , HEADER_HEIGHT)
  end
end
