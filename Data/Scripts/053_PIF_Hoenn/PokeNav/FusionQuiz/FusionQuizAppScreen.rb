class FusionQuizAppScreen
  def initialize(scene)
    @scene = scene
  end

  POINTS_TO_UNLOCK_MODES = {
    :regular_3_rounds => 0,
    :regular_5_rounds => 2000,
    :regular_10_rounds => 4000,
    :advanced_3_rounds => 5000,
    :advanced_5_rounds => 12000,
    :advanced_10_rounds => 16000,
  }

  def pbStartScreen(main_menu_scene, screen)
    @main_menu_scene = main_menu_scene
    @screen = screen
    #Possible modes:
    # :regular_3_rounds
    # :regular_5_rounds
    # :regular_10_rounds
    # :advanced_3_rounds
    # :advanced_5_rounds
    # :advanced_10_rounds
    $Trainer&.pokenav&.fusion_quiz_unlocked_modes = [:regular_3_rounds] unless $Trainer&.pokenav&.fusion_quiz_unlocked_modes
    loop do
      btn_play  = FusionQuizMenuButton.new("play",  nil, _INTL("Play"))
      btn_score = FusionQuizMenuButton.new("score", nil, _INTL("Score"))
      btn_close = FusionQuizMenuButton.new("exit",  nil, _INTL("Exit"))

      @scene.pbStartScene([btn_play, btn_score, btn_close])
      @scene.pbScene

      case @scene.selected_action
      when :play
        @scene.pbEndSceneKeepBg
        launch_quiz
        @scene.playing = false
        @scene.disposeBg
      when :score
        @scene.pbEndSceneKeepBg
        show_high_score
        @scene.disposeBg
      when :exit, nil
        @scene.pbEndScene
        break
      end
    end
  end

  def launch_quiz
    difficulty = prompt_difficulty
    high_score = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    @scene.difficulty = difficulty
    if difficulty
      nb_rounds = prompt_nb_rounds(difficulty)
      if nb_rounds > 0
        @scene.playing = true
        @scene.updateBackground
        quiz = FusionQuiz.new(difficulty)
        quiz.silhouette_color = Color.new(0, 0, 0, 200)
        quiz.windowed = false
        if difficulty == :ADVANCED
          quiz.picture_offset_x = -30
          quiz.picture_offset_y = 32
        else
          quiz.picture_offset_x = -40
          quiz.picture_offset_y = 32
        end
        quiz.start_quiz(nb_rounds)
        unless quiz.player_abandonned
          score = quiz.get_score
          if score > high_score
            pbMEPlay("Level Up")
            pbMessage(_INTL("You beat your previous high score!", score))
          end
          unlock_new_modes(score)
        end
      end
    end
  end

  def get_mode_name(mode_id)
    case mode_id
    when :regular_3_rounds
      return _INTL("Regular (3 Rounds)")
    when :regular_5_rounds
      return _INTL("Regular (5 Rounds)")
    when :regular_10_rounds
      return _INTL("Regular (10 Rounds)")
    when :advanced_3_rounds
      return _INTL("Advanced (3 Rounds)")
    when :advanced_5_rounds
      return _INTL("Advanced (5 Rounds)")
    when :advanced_10_rounds
      return _INTL("Advanced (10 Rounds)")
    end
  end

  def unlock_new_modes(score)
    POINTS_TO_UNLOCK_MODES.keys.each do |mode_id|
      points_to_unlock = POINTS_TO_UNLOCK_MODES[mode_id]
      next if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(mode_id)
      if score >= points_to_unlock
        $Trainer&.pokenav&.fusion_quiz_unlocked_modes = [:regular_3_rounds] unless $Trainer&.pokenav&.fusion_quiz_unlocked_modes
        $Trainer&.pokenav&.fusion_quiz_unlocked_modes << mode_id
        pbSEPlay("itemlevel", 80)
        pbMessage(_INTL("Unlocked a new difficulty: \\C[3]{1}",get_mode_name(mode_id)))
      end
    end

  end

  def prompt_difficulty
    advanced_difficulties = [:advanced_3_rounds, :advanced_5_rounds, :advanced_10_rounds]
    echoln $Trainer&.pokenav&.fusion_quiz_unlocked_modes
    cmd_regular = _INTL("Regular")
    cmd_advanced = _INTL("Advanced")
    cmd_cancel = _INTL("Cancel")
    options = []
    options << cmd_regular
    options << cmd_advanced if ($Trainer&.pokenav&.fusion_quiz_unlocked_modes & advanced_difficulties)&.any?
    options << cmd_cancel
    choice = pbMessage(
      _INTL("Choose a difficulty:"),
      options,3
    )

    case options[choice]
    when cmd_regular
      return :REGULAR
    when cmd_advanced
      return :ADVANCED
    else
      return nil
    end
  end

  def prompt_nb_rounds(difficulty)
    options = []

    cmd_3_rounds = _INTL("3 Rounds")
    cmd_5_rounds = _INTL("5 Rounds")
    cmd_10_rounds = _INTL("10 Rounds")
    cmd_cancel = _INTL("Cancel")

    case difficulty
    when :ADVANCED
      options << cmd_3_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:advanced_3_rounds)
      options << cmd_5_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:advanced_5_rounds)
      options << cmd_10_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:advanced_10_rounds)
    when :REGULAR
      options << cmd_3_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:regular_3_rounds)
      options << cmd_5_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:regular_5_rounds)
      options << cmd_10_rounds if $Trainer&.pokenav&.fusion_quiz_unlocked_modes&.include?(:regular_10_rounds)
    end
    options << cmd_cancel
    choice = pbMessage(
      _INTL("Choose the number of rounds:"),
      options,4
    )

    case options[choice]
    when cmd_3_rounds
      nb_rounds = 3
    when cmd_5_rounds
      nb_rounds = 5
    when cmd_10_rounds
      nb_rounds = 10
    else
      nb_rounds = 0
    end
    return nb_rounds
  end

  def show_high_score
    high = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    total = pbGet(VAR_STAT_FUSION_QUIZ_TOTAL_PTS)
    times = pbGet(VAR_STAT_FUSION_QUIZ_NB_TIMES)
    pbMessage(_INTL("High Score: {1} pts", high))
    pbMessage(_INTL("Total Points: {1}\\nGames Played: {2}", total, times))
  end
end
