class SpriteOptionsScene < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Visuals & Content Options"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Visuals & Content Options")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []



    generated_entries_option_selected = $PokemonSystem.use_generated_dex_entries ? 1 : 0
    options << EnumOption.new(_INTL("Autogen dex entries"), [_INTL("Off"), _INTL("On")],
                              proc { generated_entries_option_selected },
                              proc { |value|
                                $PokemonSystem.use_generated_dex_entries = value == 1
                              },
                              [
                                _INTL("Fusions without a custom Pokédex entry display nothing."),
                                _INTL("Fusions without a custom Pokédex entry display an auto-generated placeholder.")

                              ]
    )

    use_random_sprites = $PokemonSystem.random_sprites ? 1 : 0
    options << EnumOption.new(_INTL("Random Sprites"), [_INTL("Off"), _INTL("On")],
                              proc { use_random_sprites },
                              proc { |value|
                                $PokemonSystem.random_sprites = value == 1
                              },
                              [
                                _INTL("The game uses the same sprite each time you encounter the same species."),
                                _INTL("A random sprite is selected each time you encounter a Pokémon."),
                              ]
    ) ? 1 : 0


    allow_joke_sprites = $PokemonSystem.include_alt_sprites_in_random ? 1 : 0
    options << EnumOption.new(_INTL("Joke Sprites"), [_INTL("Off"), _INTL("On")],
                              proc { allow_joke_sprites },
                              proc { |value|
                                $PokemonSystem.include_alt_sprites_in_random = value == 1
                              },
                              [
                                _INTL("Auto-selected sprites follow standard Pokémon sprites rules."),
                                _INTL("Auto-selected sprites can be anything, including references, memes, jokes, etc.")
                              ]
    ) ? 1 : 0

    custom_eggs_option_selected = $PokemonSystem.hide_custom_eggs ? 1 : 0
    options << EnumOption.new(_INTL("Custom Eggs"), [_INTL("On"), _INTL("Off")],
                              proc { custom_eggs_option_selected },
                              proc { |value|
                                $PokemonSystem.hide_custom_eggs = value == 1
                              },
                              [_INTL("Eggs have different sprites for each Pokémon."),
                               _INTL("Eggs all use the same sprite.")]
    )

    options << EnumOption.new(_INTL("Fusion Icons"), [_INTL("Combined"), _INTL("DNA")],
                              proc { $game_variables[VAR_FUSION_ICON_STYLE] },
                              proc { |value| $game_variables[VAR_FUSION_ICON_STYLE] = value },
                              [_INTL("Combines both Pokémon's party icons"),
                               _INTL("Uses the same party icon for all fusions")]
    )

    battle_type_icon_option_selected = $PokemonSystem.type_icons ? 1 : 0
    options << EnumOption.new(_INTL("Battle Type Icons"), [_INTL("Off"), _INTL("On")],
                              proc { battle_type_icon_option_selected },
                              proc { |value| $PokemonSystem.type_icons = value == 1 },
                              _INTL("Display the enemy Pokémon type in battles.")
    )

    options << EnumOption.new(_INTL("Battle Animations"), [_INTL("On"), _INTL("Off")],
                              proc { $PokemonSystem.battlescene },
                              proc { |value| $PokemonSystem.battlescene = value },
                              _INTL("Display move animations in battles")
    )

    options << EnumOption.new(_INTL("Battle Movement"), [_INTL("On"), _INTL("Off")],
                              proc { $PokemonSystem.nobattlemovement ? 1 : 0 },
                              proc { |value| $PokemonSystem.nobattlemovement = value == 1 },
                              [_INTL("Sprites move up and down slightly during battles."),
                               _INTL("Sprites are completely static during battles.")
                              ]
    )

    return options
  end

end
