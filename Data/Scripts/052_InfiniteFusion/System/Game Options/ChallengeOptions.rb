class ChallengeOptionsScene < PokemonOption_Scene
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
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Optional Challenge Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Optional challenge options")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    options << EnumOption.new(_INTL("Level caps"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.level_caps },
                              proc { |value| $PokemonSystem.level_caps = value },
                              _INTL("Prevents leveling above the next gym leader's highest leveled Pokemon."))

    options << EnumOption.new(_INTL("Battle Style"), [_INTL("Switch"), _INTL("Set")],
                              proc { $PokemonSystem.battlestyle },
                              proc { |value| $PokemonSystem.battlestyle = value },
                              [_INTL("Prompts to switch Pokémon before the opponent sends out the next one."),
                               _INTL("No prompt to switch Pokémon before the opponent sends the next one.")]
    )

    options << EnumOption.new(_INTL("No reviving"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.no_reviving ? 1 : 0},
                              proc { |value| $PokemonSystem.no_reviving = value == 1 },
                              _INTL("Fainted Pokémon cannot be revived."))

    #TODO
    # options << EnumOption.new(_INTL("Limited Catch"), [_INTL("Off"), _INTL("On")],
    #                           proc { $PokemonSystem.level_caps },
    #                           proc { |value| $PokemonSystem.level_caps = value },
    #                           _INTL("You're only allowed to catch the first X Pokémon on every route."))

    options << EnumOption.new(_INTL("No heals (battles)"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.no_healing_items_battles ? 1 : 0},
                              proc { |value| $PokemonSystem.no_healing_items_battles = value == 1 },
                              _INTL("Healing items cannot be used during battles (excluding held berries)."))

    options << EnumOption.new(_INTL("No heals (overworld)"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.no_healing_items_ow ? 1 : 0},
                              proc { |value| $PokemonSystem.no_healing_items_ow = value == 1 },
                              _INTL("Healing items cannot be used in the overworld."))

    if Settings::HOENN
      options << EnumOption.new(_INTL("No Pokécenters"), [_INTL("Off"), _INTL("On")],
                                proc { $PokemonSystem.no_pokemon_center ? 1 : 0},
                                proc { |value| $PokemonSystem.no_pokemon_center = value == 1 },
                                _INTL("Pokémon centers will not heal your Pokémon."))
    end

    return options
  end


  def selectAutosaveSteps()
    if pbGet(AUTOSAVE_STEPS_VAR) == 0
      pbSet(AUTOSAVE_STEPS_VAR,DEFAULT_AUTOSAVE_STEPS)
    end
    params=ChooseNumberParams.new
    params.setRange(20,999999)
    params.setInitialValue(pbGet(AUTOSAVE_STEPS_VAR))
    params.setCancelValue(0)
    val = Kernel.pbMessageChooseNumber(_INTL("Autosave every how many steps?"),params)
    if val < 200
      Kernel.pbMessage(_INTL("Warning: Choosing a low number of steps may decrease performance."))
    end
    if val == 0
      val = 1
    end
    pbSet(AUTOSAVE_STEPS_VAR,val)
  end

end
