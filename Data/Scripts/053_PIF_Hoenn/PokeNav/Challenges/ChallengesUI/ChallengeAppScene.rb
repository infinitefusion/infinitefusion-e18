class PokemonChallenges_Scene
  VISIBLE_BUTTONS = 3 # Number of buttons visible at once
  Y_START = 41
  Y_GAP = 108
  BUTTONS_X = 60

  def pbStartScene(challenges)
    @challenges = []
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if isDarkMode
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_dark")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
    @sprites["header"] = IconSprite.new(0, 0, @viewport)
    @sprites["header"].setBitmap("Graphics/Pictures/Challenges/bg_header")

    # Buttons
    @buttons = []

    $Trainer.challenges.keys.each_with_index do |challenge_id, i|
      challenge = $Trainer.challenges[challenge_id]
      next unless challenge
      @challenges << challenge
      btn = ChallengeButton.new(challenge, BUTTONS_X, Y_START + i * Y_GAP, @viewport)
      @sprites["button#{i}"] = btn
      @buttons << btn
    end
    displayTextElements
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def displayTextElements
    Kernel.pbClearText
    Kernel.pbDisplayText(_INTL("POKÉCHALLENGE"), 256,-8,99999, pbColor(:ORANGE), pbColor(:BROWN))
    Kernel.pbDisplayText($Trainer.nb_completed_challenges.to_s, 450,-6,99999, pbColor(:GREEN), pbColor(:DARKGREEN))
    if @buttons.empty?
      showEmptyMessage
    end
  end
  def showEmptyMessage
    text_pos_x =240
    text_pos_y =100
    text_color = pbColor(:WHITE)
    line_height = 36
    Kernel.pbDisplayText(_INTL("You finished all your PokéChallenges!"), text_pos_x, text_pos_y,99999, text_color)
    Kernel.pbDisplayText(_INTL("You'll be assigned new ones tomorrow."), text_pos_x, text_pos_y+line_height,99999, text_color)
  end
  def pbUpdate
    # Update selection
    @buttons.each_with_index do |btn, idx|
      btn.selected = (idx == @index)
    end

    # Scroll calculation
    scroll_offset = 0
    if @index >= VISIBLE_BUTTONS
      Kernel.pbClearText
      @sprites["header"].visible=false
      scroll_offset = (@index - VISIBLE_BUTTONS + 1) * Y_GAP
    else
      displayTextElements
      @sprites["header"].visible=true
    end

    # Move buttons according to scroll
    @buttons.each_with_index do |btn, idx|
      btn.y = Y_START + idx * Y_GAP - scroll_offset
    end
    if @buttons.empty?
      showEmptyMessage
    end

    pbUpdateSpriteHash(@sprites)
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate

      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @challenges.empty?
          pbPlayCloseMenuSE
          break
        end
        pbPlayDecisionSE
        challenge = @challenges[@index]

        if @buttons[@index].can_claim_reward
          $Trainer.remove_challenge(challenge.id)
          removeChallengeAt(@index)
          pbSEPlay("GUI storage show party panel")
          receiveChallengeReward(challenge)
          pbUpdate
        else
          pbSEPlay("GUI sel buzzer",80)
          pbMessage(_INTL("The reward can only be collected once you complete the challenge!"))
        end
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @challenges.length > 1
        @index -= 1
        @index = @challenges.length - 1 if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @challenges.length > 1
        @index += 1
        @index = 0 if @index >= @challenges.length
      end
    end
  end

  def receiveChallengeReward(challenge)
    money_reward = challenge.money_reward
    item_reward = challenge.item_reward
    quantity = item_reward.length
    pbReceiveMoney(money_reward)
    pbReceiveItem(item_reward[0], quantity)
    $Trainer.money += money_reward

  end

  def challengeCompleted?(challenge_id)
    return $Trainer.completed_challenge?(challenge_id)
  end

  #Removes the challenge button sprite
  def removeChallengeAt(index)
    btn = @buttons[index]
    btn.dispose
    @sprites.delete_if { |_, v| v == btn }
    @buttons.delete_at(index)
    @challenges.delete_at(index)

    if @index >= @buttons.length
      @index = @buttons.length - 1
    end
    @index = 0 if @index < 0
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    Kernel.pbClearText
    @viewport.dispose
  end
end
