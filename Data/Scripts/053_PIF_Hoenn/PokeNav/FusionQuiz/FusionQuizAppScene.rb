class FusionQuizAppScene < PokeNavAppScene
  attr_accessor :playing
  attr_accessor :difficulty

  def initialize
    super
    @playing = false
  end

  def y_gap
    return 64;
  end

  def start_x
    return Graphics.width-200;
  end

  def pbStartScene(buttons = nil)
    $game_system.bgm_memorize
    super(buttons)
    pbBGMPlay("game_corner")
    displayTextElements
  end

  def bg_path
    if @playing
      if @difficulty == :ADVANCED
        return "Graphics/Pictures/Pokegear/FusionQuiz/bg_play_advanced"
      else
        return "Graphics/Pictures/Pokegear/FusionQuiz/bg_play"
      end
    else
      return "Graphics/Pictures/Pokegear/FusionQuiz/bg_menu"
    end
  end

  def cursor_path
    return "Graphics/Pictures/Pokegear/FusionQuiz/cursor"
  end

  def header_name
    return _INTL("Who's That Fusion!")
  end

  def header_path
    return "Graphics/Pictures/Pokegear/FusionQuiz/bg_header_quiz"
  end

  def click(button_id)
    case button_id
    when "play"
      @selected = :play
      @exiting = true
    when "score"
      @selected = :score
      @exiting = true
    else
      pbPlayCloseMenuSE
      @selected = :exit
      @exiting = true
    end
  end

  def updateInput
    if Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @selected = :exit
      @exiting = true
      return
    end
    super
  end

  def selected_action
    return @selected
  end

  def updateBackground
    echoln bg_path
    @sprites["bg"].setBitmap(bg_path) unless @sprites["bg"].disposed?
  end

  def pbEndSceneKeepBg
    @exiting = true
    sprites_without_bg = @sprites.reject { |k, _| ["bg", "background", "header"].include?(k) }
    pbFadeOutAndHide(sprites_without_bg) { pbUpdate }
    pbDisposeSpriteHash(sprites_without_bg)
    @buttons.each(&:dispose)
    Kernel.pbClearText
    showHeaderName
  end

  def disposeBg
    @sprites["bg"]&.dispose
    @sprites["background"]&.dispose
    @sprites["header"]&.dispose
    @viewport&.dispose
  end

  def pbEndScene
    echoln "ENDING"
    $game_system.bgm_stop
    $game_system.bgm_restore
    super
  end

end