class PokemonGameOption_Scene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = []
    options << SliderOption.new(_INTL("Music Volume"), 0, 100, 5,
                                proc { $PokemonSystem.bgmvolume },
                                proc { |value|
                                  if $PokemonSystem.bgmvolume != value
                                    $PokemonSystem.bgmvolume = value
                                    if $game_system.playing_bgm != nil && !inloadscreen
                                      playingBGM = $game_system.getPlayingBGM
                                      $game_system.bgm_pause
                                      $game_system.bgm_resume(playingBGM)
                                    end
                                  end
                                }, "Sets the volume for background music"
    )

    options << SliderOption.new(_INTL("SE Volume"), 0, 100, 5,
                                proc { $PokemonSystem.sevolume },
                                proc { |value|
                                  if $PokemonSystem.sevolume != value
                                    $PokemonSystem.sevolume = value
                                    if $game_system.playing_bgs != nil
                                      $game_system.playing_bgs.volume = value
                                      playingBGS = $game_system.getPlayingBGS
                                      $game_system.bgs_pause
                                      $game_system.bgs_resume(playingBGS)
                                    end
                                    pbPlayCursorSE
                                  end
                                }, "Sets the volume for sound effects"
    )

    options << EnumOption.new(_INTL("Default Movement"), [_INTL("Walking"), _INTL("Running")],
                              proc { $PokemonSystem.runstyle },
                              proc { |value| $PokemonSystem.runstyle = value },
                              ["Default to walking when not holding the Run key",
                               "Default to running when not holding the Run key"]
    )

    options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast")],
                              proc { $PokemonSystem.textspeed },
                              proc { |value|
                                $PokemonSystem.textspeed = value
                                MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
                              }, "Sets the speed at which the text is displayed"
    )
    if $game_switches
      options << EnumOption.new(_INTL("Difficulty"), [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
                                proc { $Trainer.selected_difficulty },
                                proc { |value|
                                  setDifficulty(value)
                                  @manually_changed_difficulty=true
                                }, ["All Pokémon in the team gain experience. Otherwise the same as Normal difficulty.",
                                    "The default experience. Levels are similar to the official games.",
                                    "Higher levels and smarter AI. All trainers have access to healing items."]
      )
    end

    if $game_switches
      options <<
        EnumOption.new(_INTL("Autosave"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[AUTOSAVE_ENABLED_SWITCH] ? 0 : 1 },
                       proc { |value|
                         if !$game_switches[AUTOSAVE_ENABLED_SWITCH] && value == 0
                           @autosave_menu = true
                           openAutosaveMenu()
                         end
                         $game_switches[AUTOSAVE_ENABLED_SWITCH] = value == 0
                       },
                       "Automatically saves when healing at Pokémon centers"
        )
    end

    options << EnumOption.new(_INTL("Speed-up type"), [_INTL("Hold"), _INTL("Toggle")],
                              proc { $PokemonSystem.speedup },
                              proc { |value|
                                $PokemonSystem.speedup = value
                              }, "Pick how you want speed-up to be enabled"
    )

    options << SliderOption.new(_INTL("Speed-up speed"), 1, 10, 1,
                                proc { $PokemonSystem.speedup_speed },
                                proc { |value|
                                  $PokemonSystem.speedup_speed = value
                                }, "Sets by how much to speed up the game when holding the speed up button (Default: 3x)"
    )
    # if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) #beat the league
    #   options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast"), _INTL("Instant")],
    #                             proc { $PokemonSystem.textspeed },
    #                             proc { |value|
    #                               $PokemonSystem.textspeed = value
    #                               MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    #                             }, "Sets the speed at which the text is displayed"
    #   )
    # else
    #   options << EnumOption.new(_INTL("Text Speed"), [_INTL("Normal"), _INTL("Fast")],
    #                             proc { $PokemonSystem.textspeed },
    #                             proc { |value|
    #                               $PokemonSystem.textspeed = value
    #                               MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    #                             }, "Sets the speed at which the text is displayed"
    #   )
    # end
    options <<
      EnumOption.new(_INTL("Download data"), [_INTL("On"), _INTL("Off")],
                     proc { $PokemonSystem.download_sprites },
                     proc { |value|
                       $PokemonSystem.download_sprites = value
                     },
                     "Automatically download missing custom sprites and Pokédex entries from the internet"
      )
    #
    generated_entries_option_selected=$PokemonSystem.use_generated_dex_entries ? 1 : 0
    options << EnumOption.new(_INTL("Autogen dex entries"), [_INTL("Off"), _INTL("On")],
                              proc { generated_entries_option_selected },
                              proc { |value|
                                $PokemonSystem.use_generated_dex_entries = value == 1
                              },
                              [
                                "Fusions without a custom Pokédex entry display nothing.",
                                "Fusions without a custom Pokédex entry display an auto-generated placeholder."

                              ]
    )

    if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) #beat the league
      options <<
        EnumOption.new(_INTL("Battle type"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
                       proc { $PokemonSystem.battle_type },
                       proc { |value|
                         if value == 0
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         elsif value == 1
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [2, 2]
                         elsif value == 2
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [3, 3]
                         else
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         end
                         $PokemonSystem.battle_type = value
                       }, "Sets the number of Pokémon sent out in battles (when possible)"
        )
    end

    options << EnumOption.new(_INTL("Battle Effects"), [_INTL("On"), _INTL("Off")],
                              proc { $PokemonSystem.battlescene },
                              proc { |value| $PokemonSystem.battlescene = value },
                              "Display move animations in battles"
    )

    options << EnumOption.new(_INTL("Battle Style"), [_INTL("Switch"), _INTL("Set")],
                              proc { $PokemonSystem.battlestyle },
                              proc { |value| $PokemonSystem.battlestyle = value },
                              ["Prompts to switch Pokémon before the opponent sends out the next one",
                               "No prompt to switch Pokémon before the opponent sends the next one"]
    )

    options << NumberOption.new(_INTL("Speech Frame"), 1, Settings::SPEECH_WINDOWSKINS.length,
                                proc { $PokemonSystem.textskin },
                                proc { |value|
                                  $PokemonSystem.textskin = value
                                  MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
                                }
    )
    # NumberOption.new(_INTL("Menu Frame"),1,Settings::MENU_WINDOWSKINS.length,
    #   proc { $PokemonSystem.frame },
    #   proc { |value|
    #     $PokemonSystem.frame = value
    #     MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    #   }
    # ),
    options << EnumOption.new(_INTL("Text Entry"), [_INTL("Cursor"), _INTL("Keyboard")],
                              proc { $PokemonSystem.textinput },
                              proc { |value| $PokemonSystem.textinput = value },
                              ["Enter text by selecting letters on the screen",
                               "Enter text by typing on the keyboard"]
    )
    if $game_variables
      options << EnumOption.new(_INTL("Fusion Icons"), [_INTL("Combined"), _INTL("DNA")],
                                proc { $game_variables[VAR_FUSION_ICON_STYLE] },
                                proc { |value| $game_variables[VAR_FUSION_ICON_STYLE] = value },
                                ["Combines both Pokémon's party icons",
                                 "Uses the same party icon for all fusions"]
      )
      battle_type_icon_option_selected=$PokemonSystem.type_icons ? 1 : 0
      options << EnumOption.new(_INTL("Battle Type Icons"), [_INTL("Off"), _INTL("On")],
                                proc { battle_type_icon_option_selected },
                                proc { |value| $PokemonSystem.type_icons = value == 1 },
                                "Display the enemy Pokémon type in battles."
      )



    end
    options << EnumOption.new(_INTL("Screen Size"), [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
                              proc { [$PokemonSystem.screensize, 4].min },
                              proc { |value|
                                if $PokemonSystem.screensize != value
                                  $PokemonSystem.screensize = value
                                  pbSetResizeFactor($PokemonSystem.screensize)
                                  echoln $PokemonSystem.screensize
                                end
                              }, "Sets the size of the screen"
    )
    options << EnumOption.new(_INTL("Quick Surf"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksurf },
                              proc { |value| $PokemonSystem.quicksurf = value },
                              "Start surfing automatically when interacting with water"
    )

    options << EnumOption.new(_INTL("Level caps"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.level_caps },
                              proc { |value| $PokemonSystem.level_caps = value },
                              "Prevents leveling above the next gym leader's highest leveled Pokemon"
    )

    device_option_selected=$PokemonSystem.on_mobile ? 1 : 0
    options << EnumOption.new(_INTL("Device"), [_INTL("PC"), _INTL("Mobile")],
                              proc { device_option_selected },
                              proc { |value| $PokemonSystem.on_mobile = value == 1 },
                              ["The intended device on which to play the game.",
                               "Disables some options that aren't supported when playing on mobile."]
    )

    return options
  end

  def pbEndScene
    echoln "Selected Difficulty: #{$Trainer.selected_difficulty}, lowest difficutly: #{$Trainer.lowest_difficulty}" if $Trainer
    if $Trainer && $Trainer.selected_difficulty < $Trainer.lowest_difficulty
      $Trainer.lowest_difficulty = $Trainer.selected_difficulty
      echoln "lowered difficulty (#{$Trainer.selected_difficulty})"
      if @manually_changed_difficulty
        pbMessage(_INTL("The savefile's lowest selected difficulty was changed to #{getDisplayDifficulty()}."))
        @manually_changed_difficulty = false
      end
    end
    super
  end
end

