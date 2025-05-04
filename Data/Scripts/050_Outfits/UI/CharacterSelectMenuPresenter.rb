class CharacterSelectMenuPresenter
  attr_accessor :options
  attr_reader :current_index

  OPTION_NAME = 'Name'
  OPTION_AGE = "Age"
  OPTION_GENDER = "Gender"
  OPTION_HAIR = "Hair"
  OPTION_SKIN = "Skin"
  OPTION_CONFIRM = "Confirm"

  MIN_AGE = 10
  MAX_AGE = 17
  DEFAULT_NAMES = ["Green", "Red"]

  MIN_SKIN_COLOR = 1
  MAX_SKIN_COLOR = 6
  SKIN_COLOR_IDS = ["Type A", "Type B", "Type C", "Type D", "Type E", "Type F"]
  GENDERS_IDS = ["Female", "Male"]

  HAIR_COLOR_IDS = [1, 2, 3, 4]
  HAIR_COLOR_NAMES = ["Blonde", "Light Brown", "Dark Brown", "Black"]

  #ids for displayed text sprites
  NAME_TEXT_ID = "name"
  HAIR_TEXT_ID = "hair"
  SKIN_TEXT_ID = "skin"

  def initialize(view)
    @view = view

    @gender = 1
    @age = MIN_AGE
    @name = ""
    @skinTone = 5
    @hairstyle = "red"
    @hairColor = 2

    @options = [OPTION_NAME, OPTION_GENDER, OPTION_AGE, OPTION_SKIN, OPTION_HAIR, OPTION_CONFIRM]

    @trainerPreview = TrainerClothesPreview.new(300, 80, false, "POKEBALL")
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
    selected_option = @options[current_index]
    case selected_option
    when OPTION_NAME
      pbSEPlay("GUI summary change page", 80, 100)
      @name = pbEnterPlayerName(_INTL("Enter your name"), 0, Settings::MAX_PLAYER_NAME_SIZE)
      @name = getDefaultName() if @name == ''
      pbSEPlay("GUI trainer card open", 80, 100)
      updateDisplayedName(current_index)
      applyHair() #for easter egg lol
    when OPTION_CONFIRM
      pbSEPlay("GUI save choice", 80, 100)
      @current_index = @options.length - 1
      update_cursor(@current_index)
      @name = getDefaultName if @name == ""
      updateDisplayedName(getOptionIndex(OPTION_NAME))
      cmd = pbMessage("Is this information correct?", [_INTL("Yes"), _INTL("No")])
      if cmd == 0
        pbSEPlay("GUI naming confirm", 80, 100)
        #pbMessage("You will be able to customize your appearance further while playing")
        applyAllSelectedValues()
        close_menu()
      end
    else
      pbSEPlay("GUI save choice", 80, 100)
      @current_index = @options.length - 1
      update_cursor(@current_index)
      @name = getDefaultName if @name == ""
      updateDisplayedName(getOptionIndex(OPTION_NAME))
    end
  end

  def getDefaultName()
    return DEFAULT_NAMES[@gender]
  end

  def updateDisplayedName(current_index)
    @view.displayText(NAME_TEXT_ID, @name, current_index)
  end

  def applyAllSelectedValues
    applyGender(@gender)
    echoln @age
    pbSet(VAR_TRAINER_AGE, @age)
    $Trainer.skin_tone = @skinTone
    $Trainer.name = @name
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
    selected_option = @options[index]
    case selected_option
    when OPTION_GENDER
      @view.showSideArrows(index)
    when OPTION_AGE
      @view.showSideArrows(index)
    when OPTION_HAIR
      @view.showSideArrows(index)
    when OPTION_SKIN
      @view.showSideArrows(index)
    else
      @view.hideSideArrows
    end
  end

  #HORIZONTAL NAVIGATION
  def move_menu_horizontal(current_index, incr)
    pbSEPlay("GUI sel cursor", 80, 100)
    selected_option = @options[current_index]
    case selected_option
    when OPTION_GENDER then
      setGender(current_index, incr)
    when OPTION_HAIR then
      setHairColor(current_index, incr)
    when OPTION_SKIN then
      setSkinColor(current_index, incr)
    when OPTION_AGE then
      setAge(current_index, incr)
    end
    updateTrainerPreview()
  end

  def setGender(current_index, incr)
    @gender += incr
    @gender = 0 if @gender >= 2
    @gender = 1 if @gender <= -1
    applyGender(@gender)
    label = GENDERS_IDS[@gender]
    @view.displayText(GENDERS_IDS, label, current_index)
  end

  def setSkinColor(current_index, incr)
    @skinTone += incr
    @skinTone = MIN_SKIN_COLOR if @skinTone > MAX_SKIN_COLOR
    @skinTone = MAX_SKIN_COLOR if @skinTone < MIN_SKIN_COLOR
    $Trainer.skin_tone = @skinTone
    label = SKIN_COLOR_IDS[@skinTone - 1]
    @view.displayText(SKIN_TEXT_ID, label, current_index)
  end

  def setHairColor(current_index, incr)
    max_id = HAIR_COLOR_IDS.length - 1
    @hairColor += incr
    @hairColor = 0 if @hairColor > max_id
    @hairColor = max_id if @hairColor <= -1
    applyHair()
    @view.displayText(HAIR_TEXT_ID, HAIR_COLOR_NAMES[@hairColor], current_index)
  end

  def applyHair()
    applyHairEasterEggs()
    hairColorId = HAIR_COLOR_IDS[@hairColor]
    hairId = hairColorId.to_s + "_" + @hairstyle.to_s
    $Trainer.hair = hairId
  end

  def applyHairEasterEggs()
    @hairstyle = HAIR_RIVAL if @name == "Gary" && @gender == 1
    @hairstyle = HAIR_BROCK if @name == "Brock" && @gender == 1
    @hairstyle = HAIR_MISTY1 if @name == "Misty" && @gender == 0

  end

  def applyGender(gender_index)
    # outfitId = gender + 1
    pbSet(VAR_TRAINER_GENDER, gender_index)

    outfitId = get_outfit_id_from_index(gender_index)
    @hairstyle = outfitId
    applyHair()
    #$Trainer.hair = outfitId
    $Trainer.clothes = outfitId
    $Trainer.hat = outfitId
  end

  def get_outfit_id_from_index(gender_index)
    if gender_index == 1 #Male
      return "red"
    else
      #Female
      return "leaf"
    end
  end

  #AGE
  def setAge(y_index, incr)
    @age += incr
    @age = MIN_AGE if @age > MAX_AGE
    @age = MAX_AGE if @age < MIN_AGE

    @view.displayAge(@age, y_index)
  end

  def setInitialValues()
    genderIndex = getOptionIndex(OPTION_GENDER)
    hairIndex = getOptionIndex(OPTION_HAIR)
    skinIndex = getOptionIndex(OPTION_SKIN)
    ageIndex = getOptionIndex(OPTION_AGE)

    setGender(genderIndex, 0)
    setAge(ageIndex, 0)
    setHairColor(hairIndex, 0)
    setSkinColor(skinIndex, 0)
    updateTrainerPreview()
  end

end
