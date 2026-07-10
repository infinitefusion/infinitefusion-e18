class HairstyleSelectionMenuPresenter
  attr_accessor :options
  attr_reader :current_index

  OPTION_STYLE = "Hairstyle"
  OPTION_BASE_COLOR = "Base color"
  OPTION_DYE = "Dye"

  HAIR_COLOR_NAMES = ["Blonde","Light Brown", "Dark Brown", "Black"]
  HAIR_COLOR_IDS = [1, 2, 3, 4]

  #ids for displayed text sprites
  STYLE_TEXT_ID = "style"
  BASECOLOR_TEXT_ID = "baseColor"
  DYE_TEXT_ID = "dye"

  def initialize(view)
    @view = view
    @hairstyle_full_id = $Trainer.hair

    hairstyle_split = getSplitHairFilenameAndVersionFromID(@hairstyle_full_id)
    @hairstyle = hairstyle_split[0] if hairstyle_split[0]
    @hair_version = hairstyle_split[1] if hairstyle_split[1]
    @hairColor = $Trainer.hair_color

    @available_styles= $Trainer.unlocked_hairstyles
    @selected_hairstyle_index = 0

    echoln @available_styles

    @options = [OPTION_STYLE, OPTION_BASE_COLOR, OPTION_DYE]

    @trainerPreview = TrainerClothesPreview.new(300, 80, false)
    @trainerPreview.show()
    @closed = false
    @current_index = 0
    @view.setMaxIndex(@options.length - 1)
  end

  def main()
    pbSEPlay("GUI naming tab swap start", 80, 100)
    @current_index = 0
    loop do
      @view.updateGraphics()
      if Input.trigger?(Input::DOWN)
        @current_index = move_menu_vertical(1)
      elsif Input.trigger?(Input::UP)
        @current_index = move_menu_vertical(-1)
      elsif Input.trigger?(Input::RIGHT)
        move_menu_horizontal(@current_index, 1)
      elsif Input.trigger?(Input::LEFT)
        move_menu_horizontal(@current_index, -1)
      elsif Input.trigger?(Input::ACTION) || Input.trigger?(Input::USE)
        action_button_pressed(@current_index)
      end
      break if @closed
    end
  end

  def updateTrainerPreview
    @trainerPreview.resetOutfits
    @trainerPreview.updatePreview
  end

  def action_button_pressed(current_index)
    pbSEPlay("GUI save choice", 80, 100)
    @current_index = @options.length - 1
    update_cursor(@current_index)
  end

  def getDefaultName()
    return DEFAULT_NAMES[@gender]
  end


  def applyAllSelectedValues
    $Trainer.hair = getFullHairId(@hairstyle,@hair_version)
    $Trainer.hair_color = @hairColor
  end

  def getOptionIndex(option_name)
    i = 0
    for option in @options
      return i if option == option_name
      i += 1
    end
    return -1
  end

  #VERTICAL NAVIGATION

  def move_menu_vertical(offset)
    pbSEPlay("GUI sel decision", 80, 100)
    @current_index += offset
    @current_index = 0 if @current_index > @options.length - 1
    @current_index = @options.length - 1 if @current_index <= -1

    update_cursor(@current_index)
    return @current_index
  end

  def update_cursor(index)
    @view.sprites["select"].y = @view.get_cursor_y_position(index)
    @view.sprites["select"].x = @view.get_cursor_x_position(index)

    set_custom_cursor(index)
  end

  def close_menu
    @trainerPreview.erase()
    Kernel.pbClearNumber()
    Kernel.pbClearText()
    pbDisposeSpriteHash(@view.sprites)
    pbDisposeSpriteHash(@view.textValues)
    @closed = true
  end

  def set_custom_cursor(index)
    # selected_option = @options[index]
    # case selected_option
    # when OPTION_GENDER
    #   @view.showSideArrows(index)
    # when OPTION_AGE
    #   @view.showSideArrows(index)
    # when OPTION_HAIR
    #   @view.showSideArrows(index)
    # when OPTION_SKIN
    #   @view.showSideArrows(index)
    # else
    #   @view.hideSideArrows
    # end
  end

  #HORIZONTAL NAVIGATION
  def move_menu_horizontal(current_index, incr)
    pbSEPlay("GUI sel cursor", 80, 100)
    selected_option = @options[current_index]
    case selected_option
    when OPTION_STYLE then
      setHairstyle(@selected_hairstyle_index,incr)
    end

    # case selected_option
    # when OPTION_GENDER then
    #   setGender(current_index, incr)
    # when OPTION_HAIR then
    #   setHairColor(current_index, incr)
    # when OPTION_SKIN then
    #   setSkinColor(current_index, incr)
    # when OPTION_AGE then
    #   setAge(current_index, incr)
    # end
    updateTrainerPreview()
  end



  def setHairstyle(current_index, incr)
    @selected_hairstyle_index += incr
    @selected_hairstyle_index = 0 if @selected_hairstyle_index > @available_styles.length
    @selected_hairstyle_index = @available_styles.length-1 if @selected_hairstyle_index < 0

    @hairstyle = @available_styles[@selected_hairstyle_index]

    applyHair()
    echoln @hairstyle
    echoln "hairstyle: #{@hairstyle}, full list: #{@available_styles}, index: #{current_index}"

    @view.displayText(STYLE_TEXT_ID, @hairstyle, @selected_hairstyle_index)
  end

  def setBaseColor(current_index, incr)
    max_id = HAIR_COLOR_IDS.length - 1
    @hairColor += incr
    @hairColor = 0 if @hairColor > max_id
    @hairColor = max_id if @hairColor <= -1
    applyHair()
    @view.displayText(BASECOLOR_TEXT_ID, HAIR_COLOR_NAMES[@hairColor], current_index)
  end

  def applyHair()
    hairstyle = @hairstyle
    hair_version =@hair_version
    hairId = getFullHairId(hairstyle,hair_version)
    $Trainer.hair = hairId
  end
end
