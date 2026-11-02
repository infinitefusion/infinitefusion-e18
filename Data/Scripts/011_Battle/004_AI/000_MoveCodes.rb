module MoveFunctions
  # --- 000-00F: Basic / status conditions ----------------------------------
  NO_ADDITIONAL_EFFECT            = "000" # Tackle, Slash, Hydro Pump, Megahorn, X-Scissor, etc.
  NO_EFFECT                       = "001" # Splash, Counterfeit
  STRUGGLE                        = "002"
  INFLICT_SLEEP                   = "003" # Spore, Sing, Hypnosis, Sleep Powder, Dark Void, Relic Song...
  INFLICT_DROWSY                  = "004" # Yawn
  INFLICT_POISON                  = "005" # Sludge Bomb, Poison Jab, Gunk Shot, Smog, Poison Gas...
  INFLICT_BAD_POISON              = "006" # Toxic, Poison Fang
  INFLICT_PARALYSIS               = "007" # Thunderbolt, Thunder Wave, Body Slam, Glare, Stun Spore...
  INFLICT_PARALYSIS_THUNDER       = "008" # Thunder (weather affects accuracy)
  PARALYZE_OR_FLINCH              = "009" # Thunder Fang
  INFLICT_BURN                    = "00A" # Flamethrower, Fire Blast, Will-O-Wisp, Scald, Ember...
  BURN_OR_FLINCH                  = "00B" # Fire Fang
  INFLICT_FREEZE                  = "00C" # Ice Beam, Ice Punch, Powder Snow
  INFLICT_FREEZE_BLIZZARD         = "00D" # Blizzard (perfect accuracy in hail)
  FREEZE_OR_FLINCH                = "00E" # Ice Fang
  FLINCH                          = "00F" # Bite, Air Slash, Iron Head, Headbutt, Rock Slide...

  # --- 010-01F: Flinch / confusion / misc status ----------------------------
  FLINCH_MINIMIZE_BOOST           = "010" # Stomp, Steamroller, Dragon Rush
  HIT_ONLY_WHILE_ASLEEP           = "011" # Snore
  FLINCH_FIRST_TURN_ONLY          = "012" # Fake Out
  INFLICT_CONFUSION               = "013" # Psybeam, Confusion, Confuse Ray, Supersonic, Water Pulse...
  INFLICT_CONFUSION_CHATTER       = "014" # Chatter
  INFLICT_CONFUSION_HURRICANE     = "015" # Hurricane (weather affects accuracy)
  INFLICT_ATTRACT                 = "016" # Attract
  BURN_FREEZE_OR_PARALYZE         = "017" # Tri Attack
  CURE_USER_STATUS                = "018" # Refresh
  CURE_PARTY_STATUS               = "019" # Aromatherapy, Heal Bell
  SAFEGUARD                       = "01A" # Safeguard
  TRANSFER_STATUS                 = "01B" # Psycho Shift
  USER_ATTACK_UP_1                = "01C" # Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch
  USER_DEFENSE_UP_1               = "01D" # Harden, Withdraw, Steel Wing
  USER_DEFENSE_UP_1_CURL          = "01E" # Defense Curl
  USER_SPEED_UP_1                 = "01F" # Flame Charge

  # --- 020-02F: User stat boosts ---------------------------------------------
  USER_SP_ATK_UP_1                = "020" # Charge Beam, Fiery Dance
  USER_SP_DEF_UP_1_CHARGE         = "021" # Charge
  USER_EVASION_UP_1               = "022" # Double Team
  USER_CRIT_RATE_UP               = "023" # Focus Energy
  USER_ATK_DEF_UP_1               = "024" # Bulk Up
  USER_ATK_DEF_ACC_UP_1           = "025" # Coil
  USER_ATK_SPEED_UP_1             = "026" # Dragon Dance
  USER_ATK_SP_ATK_UP_1            = "027" # Work Up
  USER_ATK_SP_ATK_UP_1_SUN        = "028" # Growth (doubled in sun)
  USER_ATK_ACC_UP_1               = "029" # Hone Claws
  USER_DEF_SP_DEF_UP_1            = "02A" # Cosmic Power, Defend Order
  USER_SP_ATK_SP_DEF_SPEED_UP_1   = "02B" # Quiver Dance
  USER_SP_ATK_SP_DEF_UP_1         = "02C" # Calm Mind
  USER_ALL_STATS_UP_1             = "02D" # Ancient Power, Ominous Wind, Silver Wind
  USER_ATTACK_UP_2                = "02E" # Swords Dance
  USER_DEFENSE_UP_2               = "02F" # Acid Armor, Barrier, Iron Defense

  # --- 030-03F: User stat boosts / drops --------------------------------------
  USER_SPEED_UP_2                 = "030" # Agility, Rock Polish
  USER_SPEED_UP_2_LOSE_WEIGHT     = "031" # Autotomize
  USER_SP_ATK_UP_2                = "032" # Nasty Plot
  USER_SP_DEF_UP_2                = "033" # Amnesia
  USER_EVASION_UP_2_MINIMIZE      = "034" # Minimize
  USER_SHELL_SMASH                = "035" # Shell Smash
  USER_SPEED_UP_2_ATTACK_UP_1     = "036" # Shift Gear
  RAISE_RANDOM_STAT_2             = "037" # Acupressure
  USER_DEFENSE_UP_3               = "038" # Cotton Guard
  USER_SP_ATK_UP_3                = "039" # Tail Glow
  USER_BELLY_DRUM                 = "03A" # Belly Drum
  USER_ATK_DEF_DOWN_1             = "03B" # Superpower
  USER_DEF_SP_DEF_DOWN_1          = "03C" # Close Combat, Dragon Ascent
  USER_DEF_SP_DEF_SPEED_DOWN_1    = "03D" # V-create
  USER_SPEED_DOWN_1               = "03E" # Hammer Arm, Ice Hammer
  USER_SP_ATK_DOWN_2              = "03F" # Draco Meteor, Overheat, Leaf Storm, Psycho Boost, Fleur Cannon

  # --- 040-04F: Target stat changes -------------------------------------------
  TARGET_SP_ATK_UP_1_CONFUSE      = "040" # Flatter
  TARGET_ATTACK_UP_2_CONFUSE      = "041" # Swagger
  TARGET_ATTACK_DOWN_1            = "042" # Growl, Play Rough, Lunge, Baby-Doll Eyes, Aurora Beam...
  TARGET_DEFENSE_DOWN_1           = "043" # Leer, Tail Whip, Crunch, Iron Tail, Rock Smash...
  TARGET_SPEED_DOWN_1             = "044" # Icy Wind, Bulldoze, Mud Shot, Rock Tomb, Bubble Beam...
  TARGET_SP_ATK_DOWN_1            = "045" # Moonblast, Snarl, Struggle Bug, Mystical Fire, Mist Ball
  TARGET_SP_DEF_DOWN_1            = "046" # Psychic, Shadow Ball, Energy Ball, Earth Power, Bug Buzz...
  TARGET_ACCURACY_DOWN_1          = "047" # Smokescreen, Sand Attack, Mud-Slap, Flash, Octazooka...
  TARGET_EVASION_DOWN             = "048" # Sweet Scent
  TARGET_EVASION_DOWN_CLEAR_FIELD = "049" # Defog
  TARGET_ATK_DEF_DOWN_1           = "04A" # Tickle
  TARGET_ATTACK_DOWN_2            = "04B" # Charm, Feather Dance
  TARGET_DEFENSE_DOWN_2           = "04C" # Screech
  TARGET_SPEED_DOWN_2             = "04D" # String Shot, Cotton Spore, Scary Face
  TARGET_SP_ATK_DOWN_2_GENDER     = "04E" # Captivate
  TARGET_SP_DEF_DOWN_2            = "04F" # Fake Tears, Acid Spray, Seed Flare, Metal Sound

  # --- 050-05F: Stat stage manipulation / type & ability changes ----------------
  RESET_TARGET_STAT_STAGES        = "050" # Clear Smog
  RESET_ALL_STAT_STAGES           = "051" # Haze
  SWAP_ATTACK_STAGES              = "052" # Power Swap
  SWAP_DEFENSE_STAGES             = "053" # Guard Swap
  SWAP_ALL_STAGES                 = "054" # Heart Swap
  COPY_TARGET_STAGES              = "055" # Psych Up
  PREVENT_STAT_DROPS              = "056" # Mist
  SWAP_USER_ATK_DEF               = "057" # Power Trick
  AVERAGE_ATTACK_STATS            = "058" # Power Split
  AVERAGE_DEFENSE_STATS           = "059" # Guard Split
  AVERAGE_HP                      = "05A" # Pain Split
  TAILWIND                        = "05B" # Tailwind
  MIMIC                           = "05C" # Mimic
  SKETCH                          = "05D" # Sketch
  CHANGE_TYPE_TO_MOVE             = "05E" # Conversion
  CHANGE_TYPE_TO_RESIST           = "05F" # Conversion 2

  # --- 060-06F: Type / ability changes, fixed damage ---------------------------
  CHANGE_TYPE_BY_ENVIRONMENT      = "060" # Camouflage
  TARGET_BECOMES_WATER            = "061" # Soak
  COPY_TARGET_TYPE                = "062" # Reflect Type
  TARGET_ABILITY_SIMPLE           = "063" # Simple Beam
  TARGET_ABILITY_INSOMNIA         = "064" # Worry Seed
  USER_COPY_TARGET_ABILITY        = "065" # Role Play
  TARGET_COPY_USER_ABILITY        = "066" # Entrainment
  SWAP_ABILITIES                  = "067" # Skill Swap
  NEGATE_TARGET_ABILITY           = "068" # Gastro Acid
  TRANSFORM                       = "069" # Transform
  FIXED_DAMAGE_20                 = "06A" # Sonic Boom
  FIXED_DAMAGE_40                 = "06B" # Dragon Rage
  FIXED_DAMAGE_HALF_TARGET_HP     = "06C" # Super Fang, Nature's Madness
  FIXED_DAMAGE_USER_LEVEL         = "06D" # Seismic Toss, Night Shade
  FIXED_DAMAGE_MATCH_USER_HP      = "06E" # Endeavor
  FIXED_DAMAGE_RANDOM_LEVEL       = "06F" # Psywave

  # --- 070-07F: OHKO, counters, conditional power ----------------------------------
  ONE_HIT_KO                      = "070" # Fissure, Sheer Cold, Guillotine, Horn Drill
  COUNTER_PHYSICAL                = "071" # Counter
  COUNTER_SPECIAL                 = "072" # Mirror Coat
  COUNTER_LAST_DAMAGE             = "073" # Metal Burst
  DAMAGE_TARGET_ALLY              = "074" # Flame Burst
  DOUBLE_POWER_VS_DIVE            = "075" # Surf
  DOUBLE_POWER_VS_DIG             = "076" # Earthquake
  DOUBLE_POWER_VS_FLYING_GUST     = "077" # Gust
  DOUBLE_POWER_VS_FLYING_TWISTER  = "078" # Twister (also flinches)
  DOUBLE_POWER_AFTER_FUSION_FLARE = "079" # Fusion Bolt
  DOUBLE_POWER_AFTER_FUSION_BOLT  = "07A" # Fusion Flare
  DOUBLE_POWER_IF_POISONED        = "07B" # Venoshock
  DOUBLE_POWER_IF_PARALYZED       = "07C" # Smelling Salts
  DOUBLE_POWER_IF_ASLEEP          = "07D" # Wake-Up Slap
  DOUBLE_POWER_IF_USER_STATUS     = "07E" # Facade
  DOUBLE_POWER_IF_TARGET_STATUS   = "07F" # Hex

  # --- 080-08F: Conditional / variable power ------------------------------------------
  DOUBLE_POWER_IF_TARGET_HALF_HP  = "080" # Brine
  DOUBLE_POWER_IF_USER_HIT        = "081" # Revenge, Avalanche
  DOUBLE_POWER_IF_TARGET_DAMAGED  = "082" # Assurance
  ROUND                           = "083" # Round
  DOUBLE_POWER_IF_TARGET_MOVED    = "084" # Payback
  DOUBLE_POWER_IF_ALLY_FAINTED    = "085" # Retaliate
  DOUBLE_POWER_IF_NO_ITEM         = "086" # Acrobatics
  WEATHER_BALL                    = "087" # Weather Ball
  PURSUIT                         = "088" # Pursuit
  POWER_BY_HAPPINESS              = "089" # Return
  POWER_BY_LOW_HAPPINESS          = "08A" # Frustration
  POWER_BY_USER_HP                = "08B" # Eruption, Water Spout
  POWER_BY_TARGET_HP              = "08C" # Crush Grip, Wring Out
  POWER_BY_SPEED_DIFF_SLOWER      = "08D" # Gyro Ball
  POWER_BY_USER_STAT_BOOSTS       = "08E" # Power Trip, Stored Power
  POWER_BY_TARGET_STAT_BOOSTS     = "08F" # Punishment

  # --- 090-09F: Variable power / field effects ----------------------------------------
  HIDDEN_POWER                    = "090" # Hidden Power
  POWER_DOUBLES_CONSECUTIVE       = "091" # Fury Cutter
  POWER_BY_CONSECUTIVE_TURNS      = "092" # Echoed Voice
  RAGE                            = "093" # Rage
  PRESENT                         = "094" # Present
  MAGNITUDE                       = "095" # Magnitude
  NATURAL_GIFT                    = "096" # Natural Gift
  POWER_BY_LOW_PP                 = "097" # Trump Card
  POWER_BY_LOW_USER_HP            = "098" # Flail, Reversal
  POWER_BY_SPEED_DIFF_FASTER      = "099" # Electro Ball
  POWER_BY_TARGET_WEIGHT          = "09A" # Low Kick, Grass Knot
  POWER_BY_WEIGHT_DIFF            = "09B" # Heat Crash, Heavy Slam
  HELPING_HAND                    = "09C" # Helping Hand
  MUD_SPORT                       = "09D" # Mud Sport
  WATER_SPORT                     = "09E" # Water Sport
  TYPE_BY_HELD_ITEM               = "09F" # Judgment, Multi-Attack, Techno Blast

  # --- 0A0-0AF: Crits, screens, accuracy, protection, move copying ---------------------
  ALWAYS_CRITICAL_HIT             = "0A0" # Frost Breath, Storm Throw
  LUCKY_CHANT                     = "0A1" # Lucky Chant
  REFLECT                         = "0A2" # Reflect
  LIGHT_SCREEN                    = "0A3" # Light Screen
  SECRET_POWER                    = "0A4" # Secret Power
  ALWAYS_HITS                     = "0A5" # Swift, Aerial Ace, Aura Sphere, Shock Wave, Magical Leaf...
  LOCK_ON                         = "0A6" # Lock-On, Mind Reader
  FORESIGHT                       = "0A7" # Foresight, Odor Sleuth
  MIRACLE_EYE                     = "0A8" # Miracle Eye
  IGNORE_DEFENSE_STAGES           = "0A9" # Chip Away, Darkest Lariat, Sacred Sword
  PROTECT                         = "0AA" # Protect, Detect
  QUICK_GUARD                     = "0AB" # Quick Guard
  WIDE_GUARD                      = "0AC" # Wide Guard
  FEINT                           = "0AD" # Feint
  MIRROR_MOVE                     = "0AE" # Mirror Move
  COPYCAT                         = "0AF" # Copycat

  # --- 0B0-0BF: Move calling, disruption, multi-hit ------------------------------------
  ME_FIRST                        = "0B0" # Me First
  MAGIC_COAT                      = "0B1" # Magic Coat
  SNATCH                          = "0B2" # Snatch
  NATURE_POWER                    = "0B3" # Nature Power
  RANDOM_MOVE_WHILE_ASLEEP        = "0B4" # Sleep Talk
  ASSIST                          = "0B5" # Assist
  METRONOME                       = "0B6" # Metronome
  TORMENT                         = "0B7" # Torment
  IMPRISON                        = "0B8" # Imprison
  DISABLE                         = "0B9" # Disable
  TAUNT                           = "0BA" # Taunt
  HEAL_BLOCK                      = "0BB" # Heal Block
  ENCORE                          = "0BC" # Encore
  HIT_TWICE                       = "0BD" # Double Kick, Dual Chop, Bonemerang, Double Hit, Gear Grind
  HIT_TWICE_POISON                = "0BE" # Twineedle
  HIT_THREE_TIMES_POWER_UP        = "0BF" # Triple Kick

  # --- 0C0-0CF: Multi-hit, recharge, two-turn moves --------------------------------------
  HIT_2_TO_5_TIMES                = "0C0" # Fury Attack, Bullet Seed, Rock Blast, Icicle Spear, Pin Missile...
  BEAT_UP                         = "0C1" # Beat Up
  RECHARGE_NEXT_TURN              = "0C2" # Hyper Beam, Giga Impact, Blast Burn, Frenzy Plant, Hydro Cannon...
  TWO_TURN_RAZOR_WIND             = "0C3" # Razor Wind
  TWO_TURN_SOLAR_BEAM             = "0C4" # Solar Beam, Solar Blade
  TWO_TURN_FREEZE_SHOCK           = "0C5" # Freeze Shock
  TWO_TURN_ICE_BURN               = "0C6" # Ice Burn
  TWO_TURN_SKY_ATTACK             = "0C7" # Sky Attack
  TWO_TURN_SKULL_BASH             = "0C8" # Skull Bash
  TWO_TURN_FLY                    = "0C9" # Fly
  TWO_TURN_DIG                    = "0CA" # Dig
  TWO_TURN_DIVE                   = "0CB" # Dive
  TWO_TURN_BOUNCE                 = "0CC" # Bounce
  TWO_TURN_SHADOW_FORCE           = "0CD" # Shadow Force
  TWO_TURN_SKY_DROP               = "0CE" # Sky Drop
  TRAP_TARGET                     = "0CF" # Bind, Wrap, Clamp, Fire Spin, Magma Storm, Sand Tomb, Infestation

  # --- 0D0-0DF: Trapping, rampage, healing / draining ----------------------------------------
  TRAP_TARGET_WHIRLPOOL           = "0D0" # Whirlpool
  UPROAR                          = "0D1" # Uproar
  RAMPAGE_THEN_CONFUSE            = "0D2" # Outrage, Petal Dance, Thrash
  ROLLOUT                         = "0D3" # Rollout, Ice Ball
  BIDE                            = "0D4" # Bide
  HEAL_USER_HALF                  = "0D5" # Recover, Slack Off, Soft-Boiled, Milk Drink, Heal Order
  HEAL_USER_HALF_ROOST            = "0D6" # Roost
  WISH                            = "0D7" # Wish
  HEAL_USER_BY_WEATHER            = "0D8" # Moonlight, Morning Sun, Synthesis
  REST                            = "0D9" # Rest
  AQUA_RING                       = "0DA" # Aqua Ring
  INGRAIN                         = "0DB" # Ingrain
  LEECH_SEED                      = "0DC" # Leech Seed
  DRAIN_HALF_DAMAGE               = "0DD" # Absorb, Giga Drain, Drain Punch, Horn Leech, Leech Life...
  DREAM_EATER                     = "0DE" # Dream Eater
  HEAL_TARGET_HALF                = "0DF" # Heal Pulse

  # --- 0E0-0EF: Self-KO, switching, trapping -------------------------------------------------
  USER_FAINTS_EXPLODE             = "0E0" # Explosion, Self-Destruct
  FINAL_GAMBIT                    = "0E1" # Final Gambit
  MEMENTO                         = "0E2" # Memento
  HEALING_WISH                    = "0E3" # Healing Wish
  LUNAR_DANCE                     = "0E4" # Lunar Dance
  PERISH_SONG                     = "0E5" # Perish Song
  GRUDGE                          = "0E6" # Grudge
  DESTINY_BOND                    = "0E7" # Destiny Bond
  ENDURE                          = "0E8" # Endure
  NON_LETHAL_HIT                  = "0E9" # False Swipe, Hold Back
  TELEPORT                        = "0EA" # Teleport
  FORCE_SWITCH_STATUS             = "0EB" # Roar, Whirlwind
  FORCE_SWITCH_DAMAGE             = "0EC" # Dragon Tail, Circle Throw
  BATON_PASS                      = "0ED" # Baton Pass
  SWITCH_OUT_AFTER_HIT            = "0EE" # U-turn, Volt Switch
  PREVENT_ESCAPE                  = "0EF" # Mean Look, Block, Spider Web, Anchor Shot, Spirit Shackle...

  # --- 0F0-0FF: Items, recoil, weather ---------------------------------------------------------
  KNOCK_OFF                       = "0F0" # Knock Off
  STEAL_ITEM                      = "0F1" # Thief, Covet
  SWAP_ITEMS                      = "0F2" # Trick, Switcheroo
  BESTOW                          = "0F3" # Bestow
  EAT_TARGET_BERRY                = "0F4" # Bug Bite, Pluck
  DESTROY_TARGET_BERRY            = "0F5" # Incinerate
  RECYCLE                         = "0F6" # Recycle
  FLING                           = "0F7" # Fling
  EMBARGO                         = "0F8" # Embargo
  MAGIC_ROOM                      = "0F9" # Magic Room
  RECOIL_QUARTER                  = "0FA" # Take Down, Submission, Wild Charge, Head Charge
  RECOIL_THIRD                    = "0FB" # Double-Edge, Brave Bird, Wood Hammer
  RECOIL_HALF                     = "0FC" # Head Smash, Light of Ruin
  RECOIL_THIRD_PARALYZE           = "0FD" # Volt Tackle
  RECOIL_THIRD_BURN               = "0FE" # Flare Blitz
  WEATHER_SUN                     = "0FF" # Sunny Day

  # --- 100-10F: Weather, hazards, misc ----------------------------------------------------------
  WEATHER_RAIN                    = "100" # Rain Dance
  WEATHER_SANDSTORM               = "101" # Sandstorm
  WEATHER_HAIL                    = "102" # Hail
  HAZARD_SPIKES                   = "103" # Spikes
  HAZARD_TOXIC_SPIKES             = "104" # Toxic Spikes
  HAZARD_STEALTH_ROCK             = "105" # Stealth Rock
  PLEDGE_GRASS                    = "106" # Grass Pledge
  PLEDGE_FIRE                     = "107" # Fire Pledge
  PLEDGE_WATER                    = "108" # Water Pledge
  PAY_DAY                         = "109" # Pay Day
  BREAK_SCREENS                   = "10A" # Brick Break, Psychic Fangs
  CRASH_DAMAGE_ON_MISS            = "10B" # Jump Kick, High Jump Kick
  SUBSTITUTE                      = "10C" # Substitute
  CURSE                           = "10D" # Curse
  SPITE                           = "10E" # Spite
  NIGHTMARE                       = "10F" # Nightmare

  # --- 110-11F: Misc, stockpile, redirect, field effects ----------------------------------------
  RAPID_SPIN                      = "110" # Rapid Spin
  DELAYED_ATTACK                  = "111" # Future Sight, Doom Desire
  STOCKPILE                       = "112" # Stockpile
  SPIT_UP                         = "113" # Spit Up
  SWALLOW                         = "114" # Swallow
  FAILS_IF_USER_HIT               = "115" # Focus Punch
  FAILS_IF_TARGET_NOT_ATTACKING   = "116" # Sucker Punch
  REDIRECT_ATTACKS_TO_USER        = "117" # Follow Me, Rage Powder
  GRAVITY                         = "118" # Gravity
  MAGNET_RISE                     = "119" # Magnet Rise
  TELEKINESIS                     = "11A" # Telekinesis
  HITS_FLYING_TARGETS             = "11B" # Sky Uppercut
  GROUND_TARGET                   = "11C" # Smack Down, Thousand Arrows
  AFTER_YOU                       = "11D" # After You
  QUASH                           = "11E" # Quash
  TRICK_ROOM                      = "11F" # Trick Room

  # --- 120-12F: Misc (126-132 are reserved for Shadow moves) --------------------------------------
  ALLY_SWITCH                     = "120" # Ally Switch
  USE_TARGET_ATTACK               = "121" # Foul Play
  USE_TARGET_DEFENSE              = "122" # Psyshock, Psystrike, Secret Sword
  DAMAGE_SAME_TYPE_ONLY           = "123" # Synchronoise
  WONDER_ROOM                     = "124" # Wonder Room
  LAST_RESORT                     = "125" # Last Resort
  # 126-132: reserved for Shadow moves (no constants defined)

  # --- 133-13F: Gen 6 moves --------------------------------------------------------------------
  HOLD_HANDS                      = "133" # Hold Hands
  CELEBRATE                       = "134" # Celebrate
  FREEZE_SUPER_EFFECTIVE_WATER    = "135" # Freeze-Dry
  USER_DEFENSE_UP_2_DIAMOND_STORM = "136" # Diamond Storm
  MAGNETIC_FLUX                   = "137" # Magnetic Flux
  AROMATIC_MIST                   = "138" # Aromatic Mist
  TARGET_ATTACK_DOWN_1_NEVER_MISS = "139" # Play Nice
  TARGET_ATK_SP_ATK_DOWN_1        = "13A" # Noble Roar, Tearful Look
  HYPERSPACE_FURY                 = "13B" # Hyperspace Fury
  TARGET_SP_ATK_DOWN_1_NEVER_MISS = "13C" # Confide
  TARGET_SP_ATK_DOWN_2_PLAIN      = "13D" # Eerie Impulse
  ROTOTILLER                      = "13E" # Rototiller
  FLOWER_SHIELD                   = "13F" # Flower Shield

  # --- 140-14F ----------------------------------------------------------------------------------
  VENOM_DRENCH                    = "140" # Venom Drench
  TOPSY_TURVY                     = "141" # Topsy-Turvy
  ADD_GHOST_TYPE                  = "142" # Trick-or-Treat
  ADD_GRASS_TYPE                  = "143" # Forest's Curse
  FLYING_PRESS                    = "144" # Flying Press
  ELECTRIFY                       = "145" # Electrify
  ION_DELUGE                      = "146" # Ion Deluge, Plasma Fists
  HYPERSPACE_HOLE                 = "147" # Hyperspace Hole
  POWDER                          = "148" # Powder
  MAT_BLOCK                       = "149" # Mat Block
  CRAFTY_SHIELD                   = "14A" # Crafty Shield
  KINGS_SHIELD                    = "14B" # King's Shield
  SPIKY_SHIELD                    = "14C" # Spiky Shield
  TWO_TURN_PHANTOM_FORCE          = "14D" # Phantom Force
  GEOMANCY                        = "14E" # Geomancy
  DRAIN_THREE_QUARTERS_DAMAGE     = "14F" # Draining Kiss, Oblivion Wing

  # --- 150-15F ----------------------------------------------------------------------------------
  FELL_STINGER                    = "150" # Fell Stinger
  PARTING_SHOT                    = "151" # Parting Shot
  FAIRY_LOCK                      = "152" # Fairy Lock
  HAZARD_STICKY_WEB               = "153" # Sticky Web
  TERRAIN_ELECTRIC                = "154" # Electric Terrain
  TERRAIN_GRASSY                  = "155" # Grassy Terrain
  TERRAIN_MISTY                   = "156" # Misty Terrain
  HAPPY_HOUR                      = "157" # Happy Hour
  BELCH                           = "158" # Belch
  TOXIC_THREAD                    = "159" # Toxic Thread
  SPARKLING_ARIA                  = "15A" # Sparkling Aria
  PURIFY                          = "15B" # Purify
  GEAR_UP                         = "15C" # Gear Up
  SPECTRAL_THIEF                  = "15D" # Spectral Thief
  LASER_FOCUS                     = "15E" # Laser Focus
  USER_DEFENSE_DOWN_1             = "15F" # Clanging Scales

  # --- 160-16F ----------------------------------------------------------------------------------
  STRENGTH_SAP                    = "160" # Strength Sap
  SPEED_SWAP                      = "161" # Speed Swap
  BURN_UP                         = "162" # Burn Up
  IGNORE_ABILITIES                = "163" # Moongeist Beam, Sunsteel Strike
  PHOTON_GEYSER                   = "164" # Photon Geyser
  CORE_ENFORCER                   = "165" # Core Enforcer
  DOUBLE_POWER_IF_LAST_MOVE_FAILED = "166" # Stomping Tantrum
  AURORA_VEIL                     = "167" # Aurora Veil
  BANEFUL_BUNKER                  = "168" # Baneful Bunker
  REVELATION_DANCE                = "169" # Revelation Dance
  SPOTLIGHT                       = "16A" # Spotlight
  INSTRUCT                        = "16B" # Instruct
  THROAT_CHOP                     = "16C" # Throat Chop
  HEAL_USER_HALF_SANDSTORM_BOOST  = "16D" # Shore Up
  HEAL_TARGET_HALF_GRASSY_BOOST   = "16E" # Floral Healing
  POLLEN_PUFF                     = "16F" # Pollen Puff

  # --- 170-175 ----------------------------------------------------------------------------------
  MIND_BLOWN                      = "170" # Mind Blown
  SHELL_TRAP                      = "171" # Shell Trap
  BEAK_BLAST                      = "172" # Beak Blast
  TERRAIN_PSYCHIC                 = "173" # Psychic Terrain
  FAILS_AFTER_FIRST_TURN          = "174" # First Impression
  HIT_TWICE_FLINCH                = "175" # Double Iron Bash

  # New custom function codes should start at 176 (or high values like 500+).
end