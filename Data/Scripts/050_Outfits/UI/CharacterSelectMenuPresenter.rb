class CharacterSelectMenuPresenter
  attr_accessor :options
  attr_reader :current_index
  OPTION_NAME = _INTL("Name")
  OPTION_AGE = _INTL("Age")
  OPTION_GENDER = _INTL("Gender")
  OPTION_HAIR = _INTL("Hair")
  OPTION_SKIN = _INTL("Skin")
  OPTION_CONFIRM = _INTL("Confirm")

  MIN_AGE = 10
  MAX_AGE = 17

  MIN_SKIN_COLOR = 1
  MAX_SKIN_COLOR = 6
  SKIN_COLOR_IDS = [_INTL("Type A"), _INTL("Type B"), _INTL("Type C"), _INTL("Type D"), _INTL("Type E"), _INTL("Type F")]
  GENDERS_IDS = [_INTL("Female"), _INTL("Male")]

  HAIR_COLOR_IDS = [1, 2, 3, 4]
  HAIR_COLOR_NAMES = [_INTL("Blonde"), _INTL("Light Brown"), _INTL("Dark Brown"), _INTL("Black")]

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

    @is_player= true
    @options = [OPTION_NAME, OPTION_GENDER, OPTION_AGE, OPTION_SKIN, OPTION_HAIR, OPTION_CONFIRM]

    @trainerPreview = TrainerClothesPreview.new(300, 80, false, "POKEBALL")
    @trainerPreview.show()
    @closed = false
    @current_index = 0
    @view.setMaxIndex(@options.length - 1)
    @rival = false
  end

  #For selecting the rival in Hoenn
  def main_rival()
    trainer_hair = $Trainer.hair
    trainer_hat = $Trainer.hat
    trainer_clothes = $Trainer.clothes
    trainer_skinTone = $Trainer.skin_tone
    trainer_name = $Trainer.name
    @trainerPreview.set_trainer(false)
    $Trainer.hat = nil
    @options = [OPTION_NAME, OPTION_SKIN, OPTION_HAIR, OPTION_CONFIRM]
    @view.setMaxIndex(@options.length - 1)
    if isPlayerMale
      @hairstyle = getDefaultHair(GENDER_FEMALE)
      $Trainer.clothes = getDefaultClothes(GENDER_FEMALE)
      $Trainer.hair = getDefaultHair(GENDER_FEMALE)
    else
      @hairstyle = getDefaultHair(GENDER_MALE)
      $Trainer.clothes = getDefaultClothes(GENDER_MALE)
      $Trainer.hair = getDefaultHair(GENDER_MALE)
    end
    @rival = true
    setInitialValuesRival()
    main()
    $Trainer.init_rival_appearance($Trainer.skin_tone, $Trainer.hair)
    pbSet(VAR_RIVAL_NAME, @name)
    $Trainer.hair = trainer_hair
    $Trainer.hat = trainer_hat
    $Trainer.clothes = trainer_clothes
    $Trainer.skin_tone = trainer_skinTone
    $Trainer.name = trainer_name
    $scene.reset_player_sprite
  end

  def main()
    #@trainerPreview.show()
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
    @trainerPreview.hat2=nil
    @trainerPreview.updatePreview
  end

  def action_button_pressed(current_index)
    selected_option = @options[current_index]
    case selected_option
    when OPTION_NAME
      pbSEPlay("GUI summary change page", 80, 100)
      @name = pbEnterPlayerName(_INTL("Name?"), 0, Settings::MAX_PLAYER_NAME_SIZE, @name)
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
      cmd = pbMessage(_INTL("Is this information correct?"), [_INTL("Yes"), _INTL("No")])
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
    if @rival
      return init_rival_name
    end
    return getPlayerDefaultName(@gender)
  end

  def updateDisplayedName(current_index)
    @view.displayText(NAME_TEXT_ID, @name, current_index)
  end

  def applyAllSelectedValues
    applyGender(@gender)
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
    setHatVisibility(@current_index)
    return @current_index
  end

  def setHatVisibility(index)
    return if @rival
    case @options[index]
    when OPTION_HAIR
      $Trainer.hat=nil
    else
      $Trainer.hat = getDefaultHat(@gender)
    end
    updateTrainerPreview
  end

  def update_cursor(index)
    @view.sprites["select"].y = @view.get_cursor_y_position(index)
    @view.sprites["select"].x = @view.get_cursor_x_position(index)

    set_custom_cursor(index)
  end

  def close_menu
    @trainerPreview.erase
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
    return if @rival
    # outfitId = gender + 1
    pbSet(VAR_TRAINER_GENDER, gender_index)

    outfitId = getDefaultClothes(gender_index)
    hatID = getDefaultHat(gender_index)
    @hairstyle = getDefaultHair(gender_index)
    applyHair()
    #$Trainer.hair = outfitId
    $Trainer.clothes = outfitId
    $Trainer.hat = hatID
  end

  def get_outfit_id_from_index(gender_index)

    if gender_index == 1 #Male
      return getD
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

  def setInitialValuesRival()
    hairIndex = getOptionIndex(OPTION_HAIR)
    skinIndex = getOptionIndex(OPTION_SKIN)

    @name = init_rival_name
    updateDisplayedName(getOptionIndex(OPTION_NAME))

    setHairColor(hairIndex, 0)
    setSkinColor(skinIndex, 0)
    updateTrainerPreview()
  end

end
