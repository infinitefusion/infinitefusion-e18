class NuzlockeSettingsScene < PokemonOption_Scene
  # +mid_run+ true when opened from the pause menu of an existing run: the
  # Randomization entry (which re-opens the New Game randomizer flow) is hidden,
  # everything else can be changed at any time.
  def initialize(mid_run = false)
    super()
    @openRandomizerOptions = false
    @mid_run = mid_run
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
    options = []
    options << EnumOption.new(_INTL("Randomization"), [_INTL("On"), _INTL("Off")],
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
      ) if !@mid_run

    options += [
      EnumOption.new(_INTL("Catch rule"),
                     [_INTL("Off"), _INTL("First only"), _INTL("Per area")],
                     proc { pbGet(VAR_NUZLOCKE_CATCH_RULE_MODE) || 0 },
                     proc { |value|
                       pbSet(VAR_NUZLOCKE_CATCH_RULE_MODE, value)
                       # Keep the legacy boolean consistent so catch_rule_mode's
                       # fallback agrees with an explicit "Off" choice.
                       $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] = (value != 0)
                     },
                     [_INTL("No catch restriction - catch as many as you like."),
                      _INTL("Only the FIRST wild Pokémon you encounter in each area can be caught (canonical)."),
                      _INTL("Any single Pokémon may be caught per area; fleeing/KO doesn't forfeit it (lenient).")]
      ),

      EnumOption.new(_INTL("Encounter slots"),
                     [_INTL("Per area"), _INTL("Per method"), _INTL("Per rod")],
                     proc { pbGet(VAR_NUZLOCKE_ENCOUNTER_SLOTS) || 0 },
                     proc { |value| pbSet(VAR_NUZLOCKE_ENCOUNTER_SLOTS, value) },
                     [_INTL("One encounter per area, however you met it (strict)."),
                      _INTL("Walking, surfing, fishing and special encounters (webs, rock smash, headbutt) each get their own slot per area."),
                      _INTL("Like Per method, and the Old, Good and Super Rod each get their own fishing slot.")]
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

      EnumOption.new(_INTL("Shiny Clause"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] = (value == 0)
                     },
                     "A shiny wild Pokémon can always be caught and never uses up the area's catch."
      ),

      EnumOption.new(_INTL("Dupes Clause"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_DUPES_CLAUSE] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_DUPES_CLAUSE] = (value == 0)
                     },
                     "Skip duplicate first encounters. A fusion is still catchable if either half is a species you don't own yet."
      ),

      EnumOption.new(_INTL("Force nicknames"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] = (value == 0)
                     },
                     "Every caught Pokémon must be nicknamed."
      ),

      EnumOption.new(_INTL("Trainer fleeing"),
                     [_INTL("Allowed"), _INTL("Disallowed")],
                     proc { $game_switches[SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED] = (value == 0)
                     },
                     [_INTL("You can flee a trainer battle. Mons that already fainted still perma-die, but the rest survive -- a Nuzlocke-flavored partial-forfeit escape."),
                      _INTL("You cannot run from trainer battles (canonical mainline rule). If you lose, you wipe -- the run is over.")]
      ),

      EnumOption.new(_INTL("Battle items"), [_INTL("Allowed"), _INTL("Forbidden")],
                     proc { $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = (value == 0)
                     },
                     "Whether the bag can be used during battle. Classic Nuzlockes forbid it."
      ),

      EnumOption.new(_INTL("Battle style"), [_INTL("Player's choice"), _INTL("Set")],
                     proc { $game_switches[SWITCH_NUZLOCKE_SET_BATTLE_STYLE] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_SET_BATTLE_STYLE] = (value == 1)
                     },
                     [_INTL("Uses the Battle style chosen in the game's Options (Switch or Set)."),
                      _INTL("Forces Set style: no free switch when a foe's Pokémon faints (Hardcore rule).")]
      ),

      EnumOption.new(_INTL("Level cap"), [_INTL("Player's choice"), _INTL("Enforced")],
                     proc { $game_switches[SWITCH_NUZLOCKE_LEVEL_CAP] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_LEVEL_CAP] = (value == 1)
                     },
                     [_INTL("Uses the Level caps setting from the game's Options."),
                      _INTL("No EXP or Rare Candies past the next Gym Leader's level cap (Hardcore rule).")]
      ),

      EnumOption.new(_INTL("Cap Candy"), [_INTL("Off"), _INTL("On")],
                     proc { $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] = (value == 1)
                       NuzlockeKeyItems.sync_all! if defined?(NuzlockeKeyItems)
                     },
                     "A reusable Cap Candy key item in your Bag raises one Pokémon straight to the current level cap. Cuts grinding after a death."
      ),

      EnumOption.new(_INTL("Field Medkit"), [_INTL("Off"), _INTL("On")],
                     proc { $game_switches[SWITCH_NUZLOCKE_MEDKIT_ENABLED] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_MEDKIT_ENABLED] = (value == 1)
                       NuzlockeKeyItems.sync_all! if defined?(NuzlockeKeyItems)
                     },
                     "A reusable Field Medkit key item in your Bag fully heals your party anywhere outside battle."
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

      EnumOption.new(_INTL("Starter slot machine"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_NUZLOCKE_STARTER_REROLL] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_STARTER_REROLL] = (value == 0)
                     },
                     "A slot machine next to the starter table in Oak's lab rerolls the three starters. Works until you pick one."
      ),

      EnumOption.new(_INTL("Soul Link"), [_INTL("Off"), _INTL("On")],
                     proc { $game_switches[SWITCH_NUZLOCKE_SOUL_LINK] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_SOUL_LINK] = (value == 1)
                     },
                     "Soullocke with a friend: catches from the same area are linked across your games. If theirs dies, yours does too. Set up the room from the pause menu."
      ),

      EnumOption.new(_INTL("On wipe"), [_INTL("Blackout"), _INTL("Reset run")],
                     proc { $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] ? 1 : 0 },
                     proc { |value|
                       $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] = (value == 1)
                     },
                     [_INTL("Losing every Pokémon sends you to the Pokémon Center as usual. You decide what happens next."),
                      _INTL("Losing every Pokémon ends the run: on your next step the game performs a Reset Run automatically.")]
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

# Open the Nuzlocke settings from the pause menu of an existing run.
def pbOpenNuzlockeSettingsMidRun
  pbFadeOutIn {
    scene = NuzlockeSettingsScene.new(true)
    screen = PokemonOptionScreen.new(scene)
    screen.pbStartScreen
  }
  NuzlockeKeyItems.sync_all! if defined?(NuzlockeKeyItems)
end
