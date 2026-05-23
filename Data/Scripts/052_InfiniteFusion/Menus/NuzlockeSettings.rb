class NuzlockeSettingsScene < PokemonOption_Scene
  def initialize
    super
    @openRandomizerOptions = false
  end

  def getDefaultDescription
    return _INTL("Configure your Nuzlocke challenge")
  end

  def pbStartScene(inloadscreen = false)
    super
    @changedColor = true
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Nuzlocke settings"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = getDefaultDescription
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Randomization"), [_INTL("On"), _INTL("Off")],
                     proc {
                       $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] ? 0 : 1
                     },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] && value == 0
                         @openRandomizerOptions = true
                         openRandomizerOptionsMenu()
                       elsif value == 1
                         $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = false
                         $game_switches[SWITCH_RANDOMIZED_MODE_INTRO] = false
                       end
                     },
                     "Configure randomization for your Nuzlocke run. When On, opens the Randomizer settings."
      ),

      EnumOption.new(_INTL("One catch per area"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] = (value == 0)
                     },
                     "Only your first encounter in each route or area can be caught."
      ),

      EnumOption.new(_INTL("Perma-death (unfused)"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] = (value == 0)
                     },
                     "Unfused Pokémon that faint are released. There is no coming back."
      ),

      EnumOption.new(_INTL("Perma-death (fused)"),
                     [_INTL("Off"), _INTL("Head"), _INTL("Body"), _INTL("Both")],
                     proc { pbGet(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE) || 0 },
                     proc { |value| pbSet(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, value) },
                     [_INTL("Fused Pokémon are not subject to perma-death."),
                      _INTL("A fused Pokémon dies when the Pokémon used as its head faints."),
                      _INTL("A fused Pokémon dies when the Pokémon used as its body faints."),
                      _INTL("A fused Pokémon dies regardless of which half faints (canonical).")]
      ),

      EnumOption.new(_INTL("Force nicknames"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] = (value == 0)
                     },
                     "Every caught Pokémon must be nicknamed."
      ),

      EnumOption.new(_INTL("Battle items"), [_INTL("Allowed"), _INTL("Forbidden")],
                     proc { $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = (value == 0)
                     },
                     "Whether the bag can be used during battle. Classic Nuzlockes forbid it."
      ),

      EnumOption.new(_INTL("Cap Candy item"), [_INTL("Enabled"), _INTL("Disabled")],
                     proc { $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] = (value == 0)
                     },
                     "Adds the Cap Candy: a single-use item that raises a Pokémon to the current level cap."
      ),

      EnumOption.new(_INTL("Guarantee Mart heals"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS] = (value == 0)
                     },
                     "Every PokéMart will stock at least one healing item, even when item randomization is on."
      ),

      EnumOption.new(_INTL("Enable Reset Run"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_RESET_ENABLED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_RESET_ENABLED] = (value == 0)
                     },
                     "Adds a 'Reset Run' option to the pause menu. Wipes all progress and rerolls randomization, keeping your name."
      ),
    ]
    return options
  end

  def openRandomizerOptionsMenu()
    return if !@openRandomizerOptions
    $game_switches[SWITCH_RANDOMIZED_MODE_INTRO] = true
    pbSet(VAR_CURRENT_GYM_TYPE, -1) if defined?(VAR_CURRENT_GYM_TYPE)
    pbFadeOutIn {
      scene = RandomizerOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openRandomizerOptions = false
  end
end
