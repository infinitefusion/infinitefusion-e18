class PokemonGameOption_Scene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = []
    options << SliderOption.new(_INTL("Volume de la Musique"), 0, 100, 5,
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
                                }, "Règle le volume de la musique de fond"
    )

    options << SliderOption.new(_INTL("ES Volume"), 0, 100, 5,
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
                                }, "Règle le volume des effets sonores"
    )

    options << EnumOption.new(_INTL("Mouvement par défaut"), [_INTL("Marche"), _INTL("Courir")],
                              proc { $PokemonSystem.runstyle },
                              proc { |value| $PokemonSystem.runstyle = value },
                              ["Marche par défaut lorsque la touche Exécuter n'est pas maintenue",
                               "Courir par défaut lorsque la touche Exécuter n'est pas maintenue"]
    )

    options << EnumOption.new(_INTL("Vitesse du texte"), [_INTL("Normal"), _INTL("Rapide")],
                              proc { $PokemonSystem.textspeed },
                              proc { |value|
                                $PokemonSystem.textspeed = value
                                MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
                              }, "Définit la vitesse à laquelle le texte est affiché"
    )
    if $game_switches
      options << EnumOption.new(_INTL("Difficulté"), [_INTL("Facile"), _INTL("Normal"), _INTL("Difficile")],
                                proc { $Trainer.selected_difficulty },
                                proc { |value|
                                  setDifficulty(value)
                                  @manually_changed_difficulty = true
                                }, ["Tous les Pokémon de l'équipe gagnent de l'expérience. Sinon, même difficulté que la difficulté normale.",
                                    "L'expérience par défaut. Les niveaux sont similaires aux jeux officiels.",
                                    "Niveaux plus élevés et IA plus intelligente. Tous les dresseurs ont accès à des objets de soin."]
      )
    end

    if $game_switches
      options <<
        EnumOption.new(_INTL("Sauvegarde auto"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[AUTOSAVE_ENABLED_SWITCH] ? 0 : 1 },
                       proc { |value|
                         if !$game_switches[AUTOSAVE_ENABLED_SWITCH] && value == 0
                           @autosave_menu = true
                           openAutosaveMenu()
                         end
                         $game_switches[AUTOSAVE_ENABLED_SWITCH] = value == 0
                       },
                       "Sauvegarde automatiquement lors de la guérison dans les centres Pokémon"
        )
    end

    options << EnumOption.new(_INTL("Type d'accélération"), [_INTL("Maintenue"), _INTL("Basculer")],
                              proc { $PokemonSystem.speedup },
                              proc { |value|
                                $PokemonSystem.speedup = value
                              }, "Choisissez comment vous souhaitez que l'accélération soit activée"
    )

    options << SliderOption.new(_INTL("Vit. d'Accélérération"), 1, 10, 1,
                                proc { $PokemonSystem.speedup_speed },
                                proc { |value|
                                  $PokemonSystem.speedup_speed = value
                                }, "Définit de combien accélérer le jeu en maintenant le bouton d'accélération enfoncé (par défaut: 3x)"
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
      EnumOption.new(_INTL("Télécharger les données"), [_INTL("On"), _INTL("Off")],
                     proc { $PokemonSystem.download_sprites },
                     proc { |value|
                       $PokemonSystem.download_sprites = value
                     },
                     "Téléchargez automatiquement les sprites personnalisés manquants et les entrées Pokédex depuis Internet"
      )
    #
    generated_entries_option_selected = $PokemonSystem.use_generated_dex_entries ? 1 : 0
    options << EnumOption.new(_INTL("Autogen dex entries"), [_INTL("Off"), _INTL("On")],
                              proc { generated_entries_option_selected },
                              proc { |value|
                                $PokemonSystem.use_generated_dex_entries = value == 1
                              },
                              [
                                "Les fusions sans entrée Pokédex personnalisée n'affichent rien.",
                                "Les fusions sans entrée Pokédex personnalisée affichent un espace réservé généré automatiquement."

                              ]
    )

    custom_eggs_option_selected = $PokemonSystem.use_custom_eggs ? 1 : 0
    options << EnumOption.new(_INTL("Oeuf Custom"), [_INTL("On"), _INTL("Off")],
                              proc { custom_eggs_option_selected },
                              proc { |value|
                                $PokemonSystem.use_custom_eggs = value == 1
                              },
                              ["Les Oeufs ont different sprites pour chaque Pokemon.",
                               "Les Oeufs ont different tous le même sprite."]
    )

    if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) # beat the league
      options <<
        EnumOption.new(_INTL("Type de combat"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
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
                       }, "Définit le nombre de Pokémon envoyés en combat (quand cela est possible)"
        )
    end

    options << EnumOption.new(_INTL("Effets de Capacité"), [_INTL("On"), _INTL("Off")],
                              proc { $PokemonSystem.battlescene },
                              proc { |value| $PokemonSystem.battlescene = value },
                              "Afficher les animations d'attaques dans les combats"
    )

    options << EnumOption.new(_INTL("Style de combat"), [_INTL("Choix"), _INTL("Défini")],
                              proc { $PokemonSystem.battlestyle },
                              proc { |value| $PokemonSystem.battlestyle = value },
                              ["Incite à changer de Pokémon avant que l'adversaire n'envoie le suivant",
                               "Aucune invite à changer de Pokémon avant que l'adversaire n'envoie le suivant"]
    )

    options << NumberOption.new(_INTL("Texture du Cadre"), 1, Settings::SPEECH_WINDOWSKINS.length,
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
    options << EnumOption.new(_INTL("Saisie de texte"), [_INTL("Curseur"), _INTL("Clavier")],
                              proc { $PokemonSystem.textinput },
                              proc { |value| $PokemonSystem.textinput = value },
                              ["Saisissez du texte en sélectionnant des lettres sur l'écran",
                               "Saisir du texte en tapant sur le clavier"]
    )
    if $game_variables
      options << EnumOption.new(_INTL("Fusion Icons"), [_INTL("Combiner"), _INTL("DNA")],
                                proc { $game_variables[VAR_FUSION_ICON_STYLE] },
                                proc { |value| $game_variables[VAR_FUSION_ICON_STYLE] = value },
                                ["Combine les deux icônes de groupe de Pokémon",
                                 "Utilise la même icône de groupe pour toutes les fusions"]
      )
      battle_type_icon_option_selected = $PokemonSystem.type_icons ? 1 : 0
      options << EnumOption.new(_INTL("Icons des Types"), [_INTL("Off"), _INTL("On")],
                                proc { battle_type_icon_option_selected },
                                proc { |value| $PokemonSystem.type_icons = value == 1 },
                                "Affiche le type de Pokémon ennemi dans les combats."
      )
    end
    options << EnumOption.new(_INTL("Taille de l'écran"), [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
                              proc { [$PokemonSystem.screensize, 4].min },
                              proc { |value|
                                if $PokemonSystem.screensize != value
                                  $PokemonSystem.screensize = value
                                  pbSetResizeFactor($PokemonSystem.screensize)
                                  echoln $PokemonSystem.screensize
                                end
                              }, "Définit la taille de l'écran"
    )
    options << EnumOption.new(_INTL("Surf rapide"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksurf },
                              proc { |value| $PokemonSystem.quicksurf = value },
                              "Commencez à surfer automatiquement lorsque vous interagissez avec l'eau"
    )

    options << EnumOption.new(_INTL("Limites de niveau"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.level_caps },
                              proc { |value| $PokemonSystem.level_caps = value },
                              "Empêche le passage à un niveau supérieur au Pokémon de niveau le plus élevé du prochain leader du gymnase"
    )

    device_option_selected = $PokemonSystem.on_mobile ? 1 : 0
    options << EnumOption.new(_INTL("Appareil"), [_INTL("PC"), _INTL("Mobile")],
                              proc { device_option_selected },
                              proc { |value| $PokemonSystem.on_mobile = value == 1 },
                              ["L'appareil sur lequel le jeu est prévu.",
                               "Désactive certaines options qui ne sont pas prises en charge lors de la lecture sur mobile."]
    )

    return options
  end

  def pbEndScene
    echoln "Selected Difficulty: #{$Trainer.selected_difficulty}, lowest difficutly: #{$Trainer.lowest_difficulty}" if $Trainer
    if $Trainer && $Trainer.selected_difficulty < $Trainer.lowest_difficulty
      $Trainer.lowest_difficulty = $Trainer.selected_difficulty
      echoln "lowered difficulty (#{$Trainer.selected_difficulty})"
      if @manually_changed_difficulty
        pbMessage(_INTL("La difficulté la plus basse sélectionnée du fichier de sauvegarde a été modifiée en #{getDisplayDifficulty()}."))
        @manually_changed_difficulty = false
      end
    end
    super
  end
end

