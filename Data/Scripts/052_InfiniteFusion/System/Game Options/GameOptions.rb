class PokemonGameOption_Scene < PokemonOption_Scene
  ICON_AUDIO = "optionIcons/AUDIO"
  ICON_GAMEPLAY = "optionIcons/GAMEPLAY"
  ICON_VISUALS = "optionIcons/VISUALS"
  ICON_CHALLENGE = "optionIcons/CHALLENGE"
  ICON_RANDOMIZER = "optionIcons/RANDOMIZER"

  def pbGetOptions(inloadscreen = false)
    @current_game_mode = getTrainersDataMode
    options = []

    options << ButtonOption.new(
      _INTL("System & Audio"),
      proc {
        @system_menu = true
        openSystemMenu()
      },
      "<icon=#{ICON_AUDIO}> " + _INTL("Volume, UI, Autosave, etc.")
    )

    if $game_switches
      options << ButtonOption.new(
        _INTL("Gameplay"),
        proc {
          @gameplay_menu = true
          openGameplayMenu()
        },
        "<icon=#{ICON_GAMEPLAY}> " + _INTL("Difficulty, movement, etc.")
      )

      options << ButtonOption.new(
        _INTL("Visuals & Content"),
        proc {
          @sprites_menu = true
          openSpritesMenu()
        },
        "<icon=#{ICON_VISUALS}> " + _INTL("Sprites, Pokédex entries, etc.")
      )

      options << ButtonOption.new(
        _INTL("Challenge Options"),
        proc {
          @challenge_menu = true
          openChallengeMenu()
        },
        "<icon=#{ICON_CHALLENGE}> " + _INTL("Set optional self-imposed challenges.")
      )

      # if $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE]
      #   options << ButtonOption.new(
      #     _INTL("Randomizer Options"),
      #     proc {
      #       @randomizer_menu = true
      #       openRandomizerMenu()
      #     },
      #     "<icon=#{ICON_RANDOMIZER}> " + _INTL("Set how to randomize the game.")
      #   )
      # end
    end
    return options
  end

  def openChallengeMenu()
    return unless @challenge_menu
    pbFadeOutIn {
      scene = ChallengeOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @challenge_menu = false
  end

  def openRandomizerMenu()
    return unless @randomizer_menu
    pbFadeOutIn {
      scene = RandomizerOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @randomizer_menu = false
  end

  def openSystemMenu()
    return unless @system_menu
    pbFadeOutIn {
      scene = SystemOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @system_menu = false
  end

  def openSpritesMenu()
    return unless @sprites_menu
    pbFadeOutIn {
      scene = SpriteOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @sprites_menu = false
  end
  def openGameplayMenu()
    return unless @gameplay_menu
    pbFadeOutIn {
      scene = GameplayOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @gameplay_menu = false
  end



  def pbEndScene
    echoln "Selected Difficulty: #{$Trainer.selected_difficulty}, lowest difficutly: #{$Trainer.lowest_difficulty}" if $Trainer
    if $Trainer && $Trainer.selected_difficulty < $Trainer.lowest_difficulty
      $Trainer.lowest_difficulty = $Trainer.selected_difficulty
      echoln "lowered difficulty (#{$Trainer.selected_difficulty})"
      if @manually_changed_difficulty
        pbMessage(_INTL("The savefile's lowest selected difficulty was changed to {1}.",getDisplayDifficulty()))
        @manually_changed_difficulty = false
      end
    end

    if getTrainersDataMode != @current_game_mode
      pbMessage(_INTL("The game was mode changed - Reshuffling trainers."))
      Kernel.pbShuffleTrainers
      @manually_changed_gamemode = false
    end

    super
  end
end

