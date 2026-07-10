CHALLENGE_ENCOUNTER_REWARDS_TIER1 = [:REPEL, :POTION, :ANTIDOTE]
CHALLENGE_ENCOUNTER_REWARDS_TIER2 = [:SUPERREPEL, :SUPERPOTION, :REVIVE, :DAWNSTONE, :DUSKSTONE]

CHALLENGE_BATTLE_REWARDS_TIER1 = [:XATTACK, :XDEFENSE, :ETHER, :FULLHEAL]
CHALLENGE_BATTLE_REWARDS_TIER2 = [:ELIXIR, :SITRUSBERRY]

CHALLENGE_CATCH_REWARDS_TIER1 = [:POKEBALL, :GREATBALL, :PREMIERBALL, :HEALBALL]
CHALLENGE_CATCH_REWARDS_TIER2 = [:ULTRABALL, :QUICKBALL, :DUSKBALL]

CHALLENGE_FUSE_REWARDS_TIER1 = [:DNASPLICERS, :DNAREVERSER]
CHALLENGE_FUSE_REWARDS_TIER2 = [:FUSIONBALL, :FUSIONREPEL]

########################
#   Encounter challenges
########################

define_challenge :encounter_2_pokemon_at_once,
                 description: _INTL("Get into a battle against 2 wild Pokémon at once"),
                 category: :encounter,
                 money_reward: 200

define_challenge :encounter_3_pokemon_at_once,
                 description: _INTL("Get into a battle against 3 wild Pokémon at once"),
                 category: :encounter,
                 money_reward: 750

define_challenge :encounter_2_different_pokemon_at_once,
                 description: _INTL("Get into a battle against 2 different wild Pokémon at once"),
                 category: :encounter,
                 money_reward: 350

define_challenge :encounter_3_different_pokemon_at_once,
                 description: _INTL("Get into a battle against 3 different wild Pokémon at once"),
                 category: :encounter,
                 money_reward: 750

define_challenge :encounter_2_fused_pokemon_at_once,
                 description: _INTL("Get into a battle against 2 wild fused Pokémon at once"),
                 category: :encounter,
                 money_reward: 1000

define_challenge :encounter_2_same_pokemon_at_once,
                 description: _INTL("Get into a battle against 2 of the same Pokémon at once"),
                 category: :encounter,
                 money_reward: 350

define_challenge :encounter_3_same_pokemon_at_once,
                 description: _INTL("Get into a battle against 3 of the same species of Pokémon at once"),
                 category: :encounter,
                 money_reward: 750


define_challenge :encounter_offguard_any,
                 description: _INTL("Catch a Pokémon off guard"),
                 category: :encounter,
                 money_reward: 200

define_challenge :encounter_offguard_curious,
                 description: _INTL("Catch a curious Pokémon off guard"),
                 category: :encounter,
                 money_reward: 350

define_challenge :encounter_offguard_aggressive,
                 description: _INTL("Catch an aggressive Pokémon off guard"),
                 category: :encounter,
                 money_reward: 500

define_challenge :encounter_offguard_skittish,
                 description: _INTL("Catch a skittish Pokémon off guard"),
                 category: :encounter,
                 money_reward: 500


# define_challenge :wild_pokemon_chase_20_steps,
#                  description: _INTL("Get a wild Pokémon to chase you for 20 steps"),
#                  money_reward: 1000


########################
#   Battle challenges
########################
define_challenge :defeat_1_not_very_effective,
                 description: _INTL("Defeat a  Pokémon in one move using a not-very-effective move"),
                 category: :battle,
                 money_reward: 400
#
# define_challenge :defeat_1_indirect_damage,
#                  description: _INTL("Defeat a wild Pokémon without inflicting any direct damage"),
#                  money_reward: 500
#
define_challenge :battle_enemy_1_hp,
                 description: _INTL("Get an opposing Pokémon to exactly 1 HP"),
                 category: :battle,
                 money_reward: 1000

define_challenge :battle_flinch,
                 description: _INTL("Make your opponent flinch during a battle"),
                 category: :battle,
                 money_reward: 250

define_challenge :rematch_trainer,
                 description: _INTL("Rematch a trainer"),
                 category: :battle,
                 money_reward: 400

# define_challenge :battle_use_healing_item,
#                  description: _INTL("Use a healing item during a battle."),
#                  category: :battle,
#                  money_reward: 200
#
define_challenge :battle_stat_boost,
                 description: _INTL("Use a stat-boosting move or item during a battle"),
                 category: :battle,
                 money_reward: 300

define_challenge :battle_stat_boost_sharp,
                 description: _INTL("Sharply boost your Pokémon's stats in a battle"),
                 category: :battle,
                 money_reward: 500

define_challenge :battle_stat_boost_max,
                 description: _INTL("Max out one of your stats during a battle"),
                 category: :battle,
                 money_reward: 1000

#
# define_challenge :battle_berry,
#                  description: _INTL("Have a Pokémon use a berry during a battle"),
#                  category: :battle,
#                  money_reward: 300

# define_challenge :battle_one_hit_ko,
#                  description: _INTL("Land a One-Hit-KO move"),
#                  category: :fight,
#                  money_reward: 1000
#

########################
#   Catching challenges
########################


define_challenge :catch_first_try,
                 description: _INTL("Catch a Pokémon on the first try"),
                 category: :catch,
                 money_reward: 400

define_challenge :catch_full_health,
                 description: _INTL("Catch a Pokémon at full health"),
                 category: :catch,
                 money_reward: 400

define_challenge :catch_no_damage,
                 description: _INTL("Catch a Pokémon without receiving any damage"),
                 category: :catch,
                 money_reward: 400

define_challenge :catch_premierball,
                 description: _INTL("Catch a Pokémon using a Premier Ball"),
                 category: :catch,
                 money_reward: 150

define_challenge :catch_fused,
                 description: _INTL("Catch a wild fused Pokémon"),
                 category: :catch,
                 money_reward: 300

define_challenge :catch_last_pokeball,
                 description: _INTL("Catch a Pokémon on your very last ball"),
                 category: :catch,
                 money_reward: 1000

define_challenge :catch_weather_encounter,
                 description: _INTL("Catch a Pokémon that appears in special weather conditions"),
                 category: :catch,
                 money_reward: 750


########################
#   Fusing challenges
########################


#
define_challenge :fuse_same_species,
                 description: _INTL("Fuse two Pokémon of the same species together"),
                category: :fusion,
                 money_reward: 500

define_challenge :fuse_same_type,
                 description: _INTL("Fuse two Pokémon that share the same type"),
                category: :fusion,
                 money_reward: 500



define_challenge :fuse_5_pokemon,
                 description: _INTL("Fuse Pokémon 5 times"),
                 category: :fusion,
                 money_reward: 750

define_challenge :fuse_1_pokemon,
                 description: _INTL("Fuse a Pokémon"),
                 category: :fusion,
                 money_reward: 200

define_challenge :fuse_2_pokemon,
                 description: _INTL("Fuse Pokémon 2 times"),
                 category: :fusion,
                 money_reward: 300

define_challenge :unfuse_5_pokemon,
                 description: _INTL("Unfuse Pokémon 5 times"),
                 category: :fusion,
                 money_reward: 750

define_challenge :unfuse_2_pokemon,
                 description: _INTL("Unfuse Pokémon 2 times"),
                 category: :fusion,
                 money_reward: 300

define_challenge :unfuse_1_pokemon,
                 description: _INTL("Unfuse a Pokémon"),
                 category: :fusion,
                 money_reward: 200

define_challenge :fuse_wild_pokemon,
                 description: _INTL("Get two wild Pokémon to fuse before a battle"),
                 category: :fusion,
                 money_reward: 400