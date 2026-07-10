#====================================================================================
#  Contests Trainer and Types Definitions
#====================================================================================

#====================================================================================
#============================= Contest Type Definitions =============================
#====================================================================================
GameData::ContestType.register({
  :id           => :COOL,
  :name         => _INTL("Cool"),
  :long_name    => _INTL("Coolness"),
  :icon_index   => 0
})

GameData::ContestType.register({
  :id           => :BEAUTY,
  :name         => _INTL("Beauty"),
  :long_name    => _INTL("Beauty"),
  :icon_index   => 1
})

GameData::ContestType.register({
  :id           => :CUTE,
  :name         => _INTL("Cute"),
  :long_name    => _INTL("Cuteness"),
  :icon_index   => 2
})

GameData::ContestType.register({
  :id           => :SMART,
  :name         => _INTL("Smart"),
  :long_name    => _INTL("Smartness"),
  :icon_index   => 3
})

GameData::ContestType.register({
  :id           => :TOUGH,
  :name         => _INTL("Tough"),
  :long_name    => _INTL("Toughness"),
  :icon_index   => 4
})

#====================================================================================
#============================ Special Trainer Definitions ===========================
#====================================================================================

	# GameData::ContestTrainer.register({
	  # :id  					=> Unique ID Symbol to reference this Trainer
	  # :contest_category 		=> "Cool", "Beauty", "Cute", "Smart", or "Tough"
	  # :contest_rank 			=> "Normal", "Super", "Hyper", or "Master"
	  # :name 					=> Displayable name of the Trainer
	  # :character_sprite 		=> File name in Graphics\Characters for the Trainer
	  # :trainer_sprite 		=> File name in Graphics\Trainers for the Trainer
	  # :pokemon_species 		=> Species Symbol for the Pokemon they use
	  # :difficulty				=> Interger representing the AI difficulty for the trainer.
	  #							   91+ => will always use the most optimal move
	  #							   76-90 => will always one of the two most optimal moves
	  #							   51-75 => never does the least optimal move, higher chance of using better move
	  #							   26-50 => never does the least optimal move
	  #							   -25 => uses random move
	  # :pokemon_nickname 		=> Displayable nickname of the Pokemon. By default, will use the Pokemon's species name.
	  # :pokemon_stat_val 		=> Integer from 0-255, representing the Pokemon's Contest Stat
	  # :pokemon_sheen_val 		=> Integer from 0-255, representing the Pokemon's Sheen (if used)
	  # :pokemon_moves 			=> Array of 1-4 Move Symbols for the Pokemon to use
	  # :pokemon_item			=> Item Symbol for the Pokemon to hold. Currently, only Scarves or Mega Stones are actually used for anything.
	  # :pokemon_shiny			=> Set to true to be shiny. False by default.
	  # :pokemon_form			=> Integer representing the Pokemon's form, if not 0.

GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterCoolLisia,
	:contest_category 	=> "Cool",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lisia"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_May",
	:trainer_sprite 	=> "POKEMONTRAINER_May",
	:difficulty			=> 95,
	:pokemon_species 	=> :ALTARIA,
	:pokemon_nickname 	=> _INTL("Ali"),
	:pokemon_stat_val 	=> 251,
	:pokemon_sheen_val 	=> 251,
	:pokemon_moves 		=> [:OUTRAGE,:AERIALACE,:DRAGONDANCE,:TAILWIND],
	:pokemon_item		=> :ALTARIANITE
})
GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterBeautyLisia,
	:contest_category 	=> "Beauty",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lisia"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_May",
	:trainer_sprite 	=> "POKEMONTRAINER_May",
	:difficulty			=> 95,
	:pokemon_species 	=> :ALTARIA,
	:pokemon_nickname 	=> _INTL("Ali"),
	:pokemon_stat_val 	=> 254,
	:pokemon_sheen_val 	=> 254,
	:pokemon_moves 		=> [:DAZZLINGGLEAM,:ROUND,:MIST,:DRACOMETEOR],
	:pokemon_item		=> :ALTARIANITE
})
GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterCuteLisia,
	:contest_category 	=> "Cute",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lisia"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_May",
	:trainer_sprite 	=> "POKEMONTRAINER_May",
	:difficulty			=> 95,
	:pokemon_species 	=> :ALTARIA,
	:pokemon_nickname 	=> _INTL("Ali"),
	:pokemon_stat_val 	=> 254,
	:pokemon_sheen_val 	=> 254,
	:pokemon_moves 		=> [:DISARMINGVOICE,:GROWL,:HONECLAWS,:ATTRACT],
	:pokemon_item		=> :ALTARIANITE
})
GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterSmartLisia,
	:contest_category 	=> "Smart",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lisia"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_May",
	:trainer_sprite 	=> "POKEMONTRAINER_May",
	:difficulty			=> 95,
	:pokemon_species 	=> :ALTARIA,
	:pokemon_nickname 	=> _INTL("Ali"),
	:pokemon_stat_val 	=> 251,
	:pokemon_sheen_val 	=> 251,
	:pokemon_moves 		=> [:NATURALGIFT,:POWERSWAP,:SING,:DREAMEATER],
	:pokemon_item		=> :ALTARIANITE
})
GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterToughLisia,
	:contest_category 	=> "Tough",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lisia"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_May",
	:trainer_sprite 	=> "POKEMONTRAINER_May",
	:difficulty			=> 95,
	:pokemon_species 	=> :ALTARIA,
	:pokemon_nickname 	=> _INTL("Ali"),
	:pokemon_stat_val 	=> 247,
	:pokemon_sheen_val 	=> 247,
	:pokemon_moves 		=> [:EARTHQUAKE,:TAKEDOWN,:GIGAIMPACT,:AERIALACE],
	:pokemon_item		=> :ALTARIANITE
})
GameData::ContestTrainer.register({
	:id  				=> :Sp_MasterWallace,
	:contest_category 	=> "Beauty",
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Wallace"),
	:character_sprite 	=> "trainer_POKEMONTRAINER_Brendan",
	:trainer_sprite 	=> "POKEMONTRAINER_Brendan",
	:difficulty			=> 95,
	:pokemon_species 	=> :MILOTIC,
	:pokemon_nickname 	=> _INTL("Milotic"),
	:pokemon_stat_val 	=> 236,
	:pokemon_sheen_val 	=> 236,
	:pokemon_moves 		=> [:AQUATAIL,:BLIZZARD,:ROUND,:AQUARING]
})


#====================================================================================
# Defined RSE Trainer Definitions https://bulbapedia.bulbagarden.net/wiki/List_of_Contest_opponents_(Generation_III)
#====================================================================================
#Normal
#Intervals of 10
#8=81+, 7=80-71, 6=70-61, 5=60-51, 4=50-41, 3=40-31, 2=30-21, 1=20-11, 0=10-
GameData::ContestTrainer.register({
	:id  				=> :NormalAgatha,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Agatha"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :BULBASAUR,
	:pokemon_nickname 	=> _INTL("Bulby"),
	:pokemon_stat_val 	=> 45,
	:pokemon_sheen_val 	=> 45,
	:pokemon_moves 		=> [:TACKLE,:GROWL,:LEECHSEED,:SWEETSCENT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalAlec,
	:contest_category 	=> ["Beauty","Cute","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Alec"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :SLAKOTH,
	:pokemon_nickname 	=> _INTL("Slokth"),
	:pokemon_stat_val 	=> [0,43,43,0,54],
	:pokemon_sheen_val 	=> 48,
	:pokemon_moves 		=> [:STRENGTH,:COUNTER,:YAWN,:ENCORE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalBeau,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Beau"),
	:character_sprite 	=> "trainer_PSYCHIC_F",
	:trainer_sprite 	=> "PSYCHIC_F",
	:pokemon_species 	=> :BUTTERFREE,
	:pokemon_nickname 	=> _INTL("Futterbe"),
	:pokemon_stat_val 	=> 47,
	:pokemon_sheen_val 	=> 47,
	:pokemon_moves 		=> [:SUPERSONIC,:WHIRLWIND,:SILVERWIND,:SAFEGUARD]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalCaitlin,
	:contest_category 	=> ["Beauty","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Caitlin"),
	:character_sprite 	=> "trainer_TUBER_F",
	:trainer_sprite 	=> "TUBER_F",
	:pokemon_species 	=> :POLIWAG,
	:pokemon_nickname 	=> _INTL("Wagil"),
	:pokemon_stat_val 	=> 58,
	:pokemon_sheen_val 	=> 58,
	:pokemon_moves 		=> [:HYDROPUMP,:RAINDANCE,:BODYSLAM,:ICEBEAM]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalCale,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Cale"),
	:character_sprite 	=> "trainer_HIKER",
	:trainer_sprite 	=> "HIKER",
	:pokemon_species 	=> :DIGLETT,
	:pokemon_nickname 	=> _INTL("Digle"),
	:pokemon_stat_val 	=> 56,
	:pokemon_sheen_val 	=> 56,
	:pokemon_moves 		=> [:DIG,:EARTHQUAKE,:FISSURE,:MAGNITUDE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalChance,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Chance"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :ELECTRIKE,
	:pokemon_nickname 	=> _INTL("Rikelec"),
	:pokemon_stat_val 	=> 52,
	:pokemon_sheen_val 	=> 52,
	:pokemon_moves 		=> [:SPARK,:THUNDERWAVE,:THUNDER,:ROAR]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalColby,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Colby"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :TOTODILE,
	:pokemon_nickname 	=> _INTL("Totdil"),
	:pokemon_stat_val 	=> 64,
	:pokemon_sheen_val 	=> 64,
	:pokemon_moves 		=> [:RAGE,:SCREECH,:SURF,:BLIZZARD]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalEdith,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Edith"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :ZIGZAGOON,
	:pokemon_nickname 	=> _INTL("Zigoon"),
	:pokemon_stat_val 	=> 47,
	:pokemon_sheen_val 	=> 47,
	:pokemon_moves 		=> [:REST,:TAILWHIP,:TACKLE,:COVET]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalEvan,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Evan"),
	:character_sprite 	=> "trainer_BUGCATCHER",
	:trainer_sprite 	=> "BUGCATCHER",
	:pokemon_species 	=> :DUSTOX,
	:pokemon_nickname 	=> _INTL("Duster"),
	:pokemon_stat_val 	=> 55,
	:pokemon_sheen_val 	=> 55,
	:pokemon_moves 		=> [:SILVERWIND,:MOONLIGHT,:LIGHTSCREEN,:GUST]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalGrant,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Grant"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :SHROOMISH,
	:pokemon_nickname 	=> _INTL("Smish"),
	:pokemon_stat_val 	=> 38,
	:pokemon_sheen_val 	=> 38,
	:pokemon_moves 		=> [:STUNSPORE,:LEECHSEED,:MEGADRAIN,:ATTRACT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalJimmy,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Jimmy"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :POOCHYENA,
	:pokemon_nickname 	=> _INTL("Poochy"),
	:pokemon_stat_val 	=> 35,
	:pokemon_sheen_val 	=> 35,
	:pokemon_moves 		=> [:ROAR,:BITE,:TAKEDOWN,:HOWL]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalKay,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Kay"),
	:character_sprite 	=> "trainer_COOLTRAINER_F",
	:trainer_sprite 	=> "COOLTRAINER_F",
	:pokemon_species 	=> :PIDGEOTTO,
	:pokemon_nickname 	=> _INTL("Pideot"),
	:pokemon_stat_val 	=> 41,
	:pokemon_sheen_val 	=> 41,
	:pokemon_moves 		=> [:MIRRORMOVE,:QUICKATTACK,:AERIALACE,:FEATHERDANCE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalKelsey,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Kelsey"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :SEEDOT,
	:pokemon_nickname 	=> _INTL("Dots"),
	:pokemon_stat_val 	=> 47,
	:pokemon_sheen_val 	=> 47,
	:pokemon_moves 		=> [:BIDE,:SYNTHESIS,:BULLETSEED,:GROWTH]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalKylie,
	:contest_category 	=> ["Cool","Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Kylie"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :LEDYBA,
	:pokemon_nickname 	=> _INTL("Baledy"),
	:pokemon_stat_val 	=> 53,
	:pokemon_sheen_val 	=> 53,
	:pokemon_moves 		=> [:BATONPASS,:AGILITY,:SWIFT,:ATTRACT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalLiam,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Liam"),
	:character_sprite 	=> "trainer_ROCKER",
	:trainer_sprite 	=> "ROCKER",
	:pokemon_species 	=> :DELIBIRD,
	:pokemon_nickname 	=> _INTL("Birdly"),
	:pokemon_stat_val 	=> [0,0,56,55,45],
	:pokemon_sheen_val 	=> 53,
	:pokemon_moves 		=> [:PRESENT,:FACADE,:FOCUSPUNCH,:RETURN]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalMadison,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Madison"),
	:character_sprite 	=> "trainer_PAINTER",
	:trainer_sprite 	=> "PAINTER",
	:pokemon_species 	=> :TAILLOW,
	:pokemon_nickname 	=> _INTL("Tatay"),
	:pokemon_stat_val 	=> 42,
	:pokemon_sheen_val 	=> 52,
	:pokemon_moves 		=> [:WINGATTACK,:AGILITY,:AERIALACE,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalMariah,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Mariah"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :ARON,
	:pokemon_nickname 	=> _INTL("Ronar"),
	:pokemon_stat_val 	=> [66,0,0,0,55],
	:pokemon_sheen_val 	=> 61,
	:pokemon_moves 		=> [:METALCLAW,:IRONDEFENSE,:HEADBUTT,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalMelanie,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Melanie"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :GULPIN,
	:pokemon_nickname 	=> _INTL("Gulin"),
	:pokemon_stat_val 	=> 48,
	:pokemon_sheen_val 	=> 48,
	:pokemon_moves 		=> [:SLUDGE,:AMNESIA,:TOXIC,:YAWN]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalMilo,
	:contest_category 	=> ["Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Milo"),
	:character_sprite 	=> "trainer_POKEMANIAC",
	:trainer_sprite 	=> "POKEMANIAC",
	:pokemon_species 	=> :LARVITAR,
	:pokemon_nickname 	=> _INTL("Tarvitar"),
	:pokemon_stat_val 	=> 59,
	:pokemon_sheen_val 	=> 59,
	:pokemon_moves 		=> [:THRASH,:TORMENT,:CRUNCH,:DIG]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalMorris,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Morris"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :MAKUHITA,
	:pokemon_nickname 	=> _INTL("Mahita"),
	:pokemon_stat_val 	=> 56,
	:pokemon_sheen_val 	=> 56,
	:pokemon_moves 		=> [:SEISMICTOSS,:VITALTHROW,:TACKLE,:REVERSAL]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalPaige,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Paige"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :WINGULL,
	:pokemon_nickname 	=> _INTL("Gulwee"),
	:pokemon_stat_val 	=> 33,
	:pokemon_sheen_val 	=> 33,
	:pokemon_moves 		=> [:MIST,:WATERGUN,:GROWL,:PURSUIT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalRaymond,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Raymond"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :NINCADA,
	:pokemon_nickname 	=> _INTL("Ninda"),
	:pokemon_stat_val 	=> 68,
	:pokemon_sheen_val 	=> 68,
	:pokemon_moves 		=> [:LEECHLIFE,:FALSESWIPE,:FURYSWIPES,:MINDREADER]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalRussell,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Russell"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :ZUBAT,
	:pokemon_nickname 	=> _INTL("ZUTZU"),
	:pokemon_stat_val 	=> [0,27,28,34],
	:pokemon_sheen_val 	=> 30,
	:pokemon_moves 		=> [:HAZE,:MEANLOOK,:CONFUSERAY,:LEECHLIFE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalSydney,
	:contest_category 	=> ["Cool","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Sydney"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :WHISMUR,
	:pokemon_nickname 	=> _INTL("Whiris"),
	:pokemon_stat_val 	=> 44,
	:pokemon_sheen_val 	=> 44,
	:pokemon_moves 		=> [:ASTONISH,:SCREECH,:UPROAR,:HYPERVOICE]
})
#Super
#Intervals of 14
#8=141+, 7=140-126, 6=125-112, 5=111-98, 4=97-84, 3=83-70, 2=69-56, 1=55-42, 0=41-
GameData::ContestTrainer.register({
	:id  				=> :SuperAliyah,
	:contest_category 	=> ["Beauty","Cute","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Aliyah"),
	:character_sprite 	=> "trainer_PSYCHIC_F",
	:trainer_sprite 	=> "PSYCHIC_F",
	:pokemon_species 	=> :BLISSEY,
	:pokemon_nickname 	=> _INTL("Bliss"),
	:pokemon_stat_val 	=> [0,74,77,0,60],
	:pokemon_sheen_val 	=> 70,
	:pokemon_moves 		=> [:SING,:SOFTBOILED,:EGGBOMB,:DOUBLEEDGE]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperAriana,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Ariana"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :KECLEON,
	:pokemon_nickname 	=> _INTL("Kecon"),
	:pokemon_stat_val 	=> [0,0,0,100,79],
	:pokemon_sheen_val 	=> 80,
	:pokemon_moves 		=> [:THIEF,:SCREECH,:ANCIENTPOWER,:BIND]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperAshton,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Ashton"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :GOLDEEN,
	:pokemon_nickname 	=> _INTL("Golden"),
	:pokemon_stat_val 	=> [105,73,0,0,0],
	:pokemon_sheen_val 	=> 100,
	:pokemon_moves 		=> [:HORNATTACK,:FURYATTACK,:HORNDRILL,:TAILWHIP]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperAudrey,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Audrey"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :SWABLU,
	:pokemon_nickname 	=> _INTL("Swaby"),
	:pokemon_stat_val 	=> 60,
	:pokemon_sheen_val 	=> 60,
	:pokemon_moves 		=> [:MIRRORMOVE,:PERISHSONG,:SAFEGUARD,:MIST]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperAvery,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Avery"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :LINOONE,
	:pokemon_nickname 	=> _INTL("Noone"),
	:pokemon_stat_val 	=> [0,80,67,0,0],
	:pokemon_sheen_val 	=> 70,
	:pokemon_moves 		=> [:GROWL,:COVET,:SANDATTACK,:REST]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperBobby,
	:contest_category 	=> ["Cool","Beauty","Cute","Smart","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Bobby"),
	:character_sprite 	=> "trainer_POKEMONRANGER_M",
	:trainer_sprite 	=> "POKEMONRANGER_M",
	:pokemon_species 	=> :DODUO,
	:pokemon_nickname 	=> _INTL("Duodo"),
	:pokemon_stat_val 	=> [44,47,60,94,80],
	:pokemon_sheen_val 	=> 80,
	:pokemon_moves 		=> [:PECK,:FURYATTACK,:RETURN,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperCarson,
	:contest_category 	=> ["Cool","Beauty","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Carson"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :SKARMORY,
	:pokemon_nickname 	=> _INTL("Corpy"),
	:pokemon_stat_val 	=> 65,
	:pokemon_sheen_val 	=> 65,
	:pokemon_moves 		=> [:SWIFT,:DOUBLETEAM,:AGILITY,:CUT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperCassidy,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Cassidy"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :SANDSHREW,
	:pokemon_nickname 	=> _INTL("Shrand"),
	:pokemon_stat_val 	=> [115,0,0,0,108],
	:pokemon_sheen_val 	=> 110,
	:pokemon_moves 		=> [:SLASH,:DEFENSECURL,:SWIFT,:FURYSWIPES]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperClaire,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Claire"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :TRAPINCH,
	:pokemon_nickname 	=> _INTL("Pinchin"),
	:pokemon_stat_val 	=> [0,0,45,43,60],
	:pokemon_sheen_val 	=> 50,
	:pokemon_moves 		=> [:BITE,:SANDATTACK,:DIG,:FAINTATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperDevin,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Devin"),
	:character_sprite 	=> "trainer_GENTLEMAN",
	:trainer_sprite 	=> "GENTLEMAN",
	:pokemon_species 	=> :SNUBULL,
	:pokemon_nickname 	=> _INTL("Snubbins"),
	:pokemon_stat_val 	=> 54,
	:pokemon_sheen_val 	=> 54,
	:pokemon_moves 		=> [:SCARYFACE,:TAUNT,:TAILWHIP,:BITE]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperDiego,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Diego"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :HITMONCHAN,
	:pokemon_nickname 	=> _INTL("Hitemon"),
	:pokemon_stat_val 	=> 78,
	:pokemon_sheen_val 	=> 78,
	:pokemon_moves 		=> [:SKYUPPERCUT,:DETECT,:REVENGE,:MEGAPUNCH]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperJada,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Jada"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :SEEL,
	:pokemon_nickname 	=> _INTL("Seeley"),
	:pokemon_stat_val 	=> 68,
	:pokemon_sheen_val 	=> 68,
	:pokemon_moves 		=> [:ATTRACT,:ICEBEAM,:SAFEGUARD,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperKarina,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Karina"),
	:character_sprite 	=> "trainer_PICNICKER",
	:trainer_sprite 	=> "PICNICKER",
	:pokemon_species 	=> :ROSELIA,
	:pokemon_nickname 	=> _INTL("Relia"),
	:pokemon_stat_val 	=> [0,69,0,54,0],
	:pokemon_sheen_val 	=> 58,
	:pokemon_moves 		=> [:PETALDANCE,:MAGICALLEAF,:GRASSWHISTLE,:INGRAIN]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperKatrina,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Katrina"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :LOTAD,
	:pokemon_nickname 	=> _INTL("Tado"),
	:pokemon_stat_val 	=> [0,47,44,57,0],
	:pokemon_sheen_val 	=> 50,
	:pokemon_moves 		=> [:ASTONISH,:GROWL,:RAINDANCE,:WATERPULSE]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperLuke,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Luke"),
	:character_sprite 	=> "trainer_FISHERMAN",
	:trainer_sprite 	=> "FISHERMAN",
	:pokemon_species 	=> :SLOWBRO,
	:pokemon_nickname 	=> _INTL("Browlo"),
	:pokemon_stat_val 	=> [0,0,59,44,0],
	:pokemon_sheen_val 	=> 50,
	:pokemon_moves 		=> [:YAWN,:DISABLE,:GROWL,:CONFUSION]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperMiles,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Miles"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :SPINDA,
	:pokemon_nickname 	=> _INTL("Spinin"),
	:pokemon_stat_val 	=> [0,0,61,38,0],
	:pokemon_sheen_val 	=> 45,
	:pokemon_moves 		=> [:TEETERDANCE,:PSYCHUP,:HYPNOSIS,:UPROAR]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperMorgan,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Morgan"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :BALTOY,
	:pokemon_nickname 	=> _INTL("Toybal"),
	:pokemon_stat_val 	=> 82,
	:pokemon_sheen_val 	=> 82,
	:pokemon_moves 		=> [:SELFDESTRUCT,:ROCKTOMB,:PSYBEAM,:CONFUSION]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperNatalia,
	:contest_category 	=> ["Cool","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Natalia"),
	:character_sprite 	=> "trainer_COOLTRAINER_F",
	:trainer_sprite 	=> "COOLTRAINER_F",
	:pokemon_species 	=> :ELEKID,
	:pokemon_nickname 	=> _INTL("Kidlek"),
	:pokemon_stat_val 	=> 66,
	:pokemon_sheen_val 	=> 66,
	:pokemon_moves 		=> [:SHOCKWAVE,:QUICKATTACK,:SCREECH,:ATTRACT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperRaul,
	:contest_category 	=> ["Cool","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Raul"),
	:character_sprite 	=> "trainer_BIRDKEEPER",
	:trainer_sprite 	=> "BIRDKEEPER",
	:pokemon_species 	=> :FARFETCHD,
	:pokemon_nickname 	=> _INTL("Fetchin"),
	:pokemon_stat_val 	=> 46,
	:pokemon_sheen_val 	=> 46,
	:pokemon_moves 		=> [:FACADE,:FURYCUTTER,:FLY,:RETURN]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperSandra,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Sandra"),
	:character_sprite 	=> "trainer_TUBER_F",
	:trainer_sprite 	=> "TUBER_F",
	:pokemon_species 	=> :BARBOACH,
	:pokemon_nickname 	=> _INTL("Boboach"),
	:pokemon_stat_val 	=> [0,0,72,60,51],
	:pokemon_sheen_val 	=> 60,
	:pokemon_moves 		=> [:MUDSPORT,:WATERSPORT,:EARTHQUAKE,:FUTURESIGHT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperSummer,
	:contest_category 	=> ["Cool","Beauty","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Summer"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :NUMEL,
	:pokemon_nickname 	=> _INTL("Lenum"),
	:pokemon_stat_val 	=> [63,46,0,0,57],
	:pokemon_sheen_val 	=> 55,
	:pokemon_moves 		=> [:MAGNITUDE,:EARTHQUAKE,:SUNNYDAY,:FLAMETHROWER]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperTylor,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Tylor"),
	:character_sprite 	=> "trainer_PSYCHIC_F",
	:trainer_sprite 	=> "PSYCHIC_F",
	:pokemon_species 	=> :MISDREAVUS,
	:pokemon_nickname 	=> _INTL("Dreavis"),
	:pokemon_stat_val 	=> [0,48,0,59,0],
	:pokemon_sheen_val 	=> 54,
	:pokemon_moves 		=> [:PERISHSONG,:MEANLOOK,:CONFUSERAY,:PAINSPLIT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperWillie,
	:contest_category 	=> ["Cool","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Willie"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :CACNEA,
	:pokemon_nickname 	=> _INTL("Nacac"),
	:pokemon_stat_val 	=> [55,0,0,94,0],
	:pokemon_sheen_val 	=> 80,
	:pokemon_moves 		=> [:SPIKES,:LEER,:POISONSTING,:SANDATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperZeek,
	:contest_category 	=> ["Beauty","Cute","Smart","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Zeek"),
	:character_sprite 	=> "trainer_PSYCHIC_M",
	:trainer_sprite 	=> "PSYCHIC_M",
	:pokemon_species 	=> :DROWZEE,
	:pokemon_nickname 	=> _INTL("Drowzin"),
	:pokemon_stat_val 	=> [0,81,80,79,68],
	:pokemon_sheen_val 	=> 76,
	:pokemon_moves 		=> [:DISABLE,:FUTURESIGHT,:HIDDENPOWER,:RETURN]
})

#Hyper
#Intervals of 16
#8=201+, 7=200-184, 6=183-167, 5=166-150, 4=149-134, 3=133-117, 2=116-100, 1=99-84, 0=83-
GameData::ContestTrainer.register({
	:id  				=> :HyperAlisha,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Alisha"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :BEAUTIFLY,
	:pokemon_nickname 	=> _INTL("Tifly"),
	:pokemon_stat_val 	=> [0,108,0,140,0],
	:pokemon_sheen_val 	=> 108,
	:pokemon_moves 		=> [:MORNINGSUN,:SILVERWIND,:STUNSPORE,:SECRETPOWER]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperBryce,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Bryce"),
	:character_sprite 	=> "trainer_BUGCATCHER",
	:trainer_sprite 	=> "BUGCATCHER",
	:pokemon_species 	=> :PINECO,
	:pokemon_nickname 	=> _INTL("Pinoc"),
	:pokemon_stat_val 	=> 147,
	:pokemon_sheen_val 	=> 147,
	:pokemon_moves 		=> [:EXPLOSION,:SPIKES,:LIGHTSCREEN,:GIGADRAIN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperClaudia,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Claudia"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :SHIFTRY,
	:pokemon_nickname 	=> _INTL("Shifty"),
	:pokemon_stat_val 	=> 132,
	:pokemon_sheen_val 	=> 132,
	:pokemon_moves 		=> [:GROWTH,:RAZORWIND,:EXPLOSION,:EXTRASENSORY]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperColtin,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Coltin"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :CUBONE,
	:pokemon_nickname 	=> _INTL("Cubin"),
	:pokemon_stat_val 	=> [0,0,106,0,120],
	:pokemon_sheen_val 	=> 110,
	:pokemon_moves 		=> [:BONECLUB,:BONEMERANG,:BONERUSH,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperCorbin,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Corbin"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :ABSOL,
	:pokemon_nickname 	=> _INTL("Abso"),
	:pokemon_stat_val 	=> 142,
	:pokemon_sheen_val 	=> 142,
	:pokemon_moves 		=> [:PERISHSONG,:HAIL,:HYPERBEAM,:SLASH]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperDarryl,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Darryl"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :SEVIPER,
	:pokemon_nickname 	=> _INTL("Vipes"),
	:pokemon_stat_val 	=> 129,
	:pokemon_sheen_val 	=> 129,
	:pokemon_moves 		=> [:POISONFANG,:GLARE,:WRAP,:SCREECH]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperDevon,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Devon"),
	:character_sprite 	=> "trainer_GENTLEMAN",
	:trainer_sprite 	=> "GENTLEMAN",
	:pokemon_species 	=> :MILTANK,
	:pokemon_nickname 	=> _INTL("Milkan"),
	:pokemon_stat_val 	=> [0,160,145,0,0],
	:pokemon_sheen_val 	=> 145,
	:pokemon_moves 		=> [:MILKDRINK,:HEALBELL,:DEFENSECURL,:BLIZZARD]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperElias,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Elias"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :NINJASK,
	:pokemon_nickname 	=> _INTL("Ninas"),
	:pokemon_stat_val 	=> [0,0,149,147,101],
	:pokemon_sheen_val 	=> 140,
	:pokemon_moves 		=> [:SCREECH,:FURYSWIPES,:SANDATTACK,:BATONPASS]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperEllie,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Ellie"),
	:character_sprite 	=> "trainer_CRUSHGIRL",
	:trainer_sprite 	=> "CRUSHGIRL",
	:pokemon_species 	=> :HITMONLEE,
	:pokemon_nickname 	=> _INTL("Hitmon"),
	:pokemon_stat_val 	=> [127,0,0,0,136],
	:pokemon_sheen_val 	=> 130,
	:pokemon_moves 		=> [:REVERSAL,:REVENGE,:FOCUSENERGY,:MEGAKICK]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperEmilio,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Emilio"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :MACHOKE,
	:pokemon_nickname 	=> _INTL("Chokern"),
	:pokemon_stat_val 	=> [129,0,0,0,114],
	:pokemon_sheen_val 	=> 120,
	:pokemon_moves 		=> [:SEISMICTOSS,:FOCUSENERGY,:KARATECHOP,:SCARYFACE]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperFelicia,
	:contest_category 	=> ["Cool","Beauty","Cute","Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Felicia"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :CASTFORM,
	:pokemon_nickname 	=> _INTL("Caster"),
	:pokemon_stat_val 	=> [130,130,130,115,115],
	:pokemon_sheen_val 	=> 115,
	:pokemon_moves 		=> [:SUNNYDAY,:WEATHERBALL,:SANDSTORM,:RETURN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperFrancis,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Francis"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :MIGHTYENA,
	:pokemon_nickname 	=> _INTL("Yena"),
	:pokemon_stat_val 	=> 120,
	:pokemon_sheen_val 	=> 120,
	:pokemon_moves 		=> [:TAUNT,:THIEF,:ODORSLEUTH,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperGracie,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Gracie"),
	:character_sprite 	=> "trainer_PICNICKER",
	:trainer_sprite 	=> "PICNICKER",
	:pokemon_species 	=> :EXEGGUTOR,
	:pokemon_nickname 	=> _INTL("Eggsor"),
	:pokemon_stat_val 	=> [0,0,0,135,132],
	:pokemon_sheen_val 	=> 133,
	:pokemon_moves 		=> [:STOMP,:HYPNOSIS,:EGGBOMB,:SKILLSWAP]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperJade,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Jade"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :SWELLOW,
	:pokemon_nickname 	=> _INTL("Welow"),
	:pokemon_stat_val 	=> 131,
	:pokemon_sheen_val 	=> 131,
	:pokemon_moves 		=> [:AGILITY,:AERIALACE,:WINGATTACK,:FLY]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperJamie,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Jamie"),
	:character_sprite 	=> "trainer_COOLTRAINER_F",
	:trainer_sprite 	=> "COOLTRAINER_F",
	:pokemon_species 	=> :DUNSPARCE,
	:pokemon_nickname 	=> _INTL("Diltot"),
	:pokemon_stat_val 	=> [0,0,119,0,147],
	:pokemon_sheen_val 	=> 130,
	:pokemon_moves 		=> [:SPITE,:YAWN,:DEFENSECURL,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperJorge,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Jorge"),
	:character_sprite 	=> "trainer_GENTLEMAN",
	:trainer_sprite 	=> "GENTLEMAN",
	:pokemon_species 	=> :HOUNDOOM,
	:pokemon_nickname 	=> _INTL("Doomond"),
	:pokemon_stat_val 	=> [161,144,0,0,0],
	:pokemon_sheen_val 	=> 150,
	:pokemon_moves 		=> [:ROAR,:FLAMETHROWER,:FAINTATTACK,:SUNNYDAY]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperKarla,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Karla"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :LOMBRE,
	:pokemon_nickname 	=> _INTL("Lombe"),
	:pokemon_stat_val 	=> 126,
	:pokemon_sheen_val 	=> 126,
	:pokemon_moves 		=> [:ATTRACT,:FLASH,:UPROAR,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperKiara,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Kiara"),
	:character_sprite 	=> "trainer_CRUSHGIRL",
	:trainer_sprite 	=> "CRUSHGIRL",
	:pokemon_species 	=> :KANGASKHAN,
	:pokemon_nickname 	=> _INTL("Khankan"),
	:pokemon_stat_val 	=> 162,
	:pokemon_sheen_val 	=> 162,
	:pokemon_moves 		=> [:MEGAPUNCH,:RAGE,:FOCUSPUNCH,:TAILWHIP]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperLacey,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Lacey"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :LUNATONE,
	:pokemon_nickname 	=> _INTL("Lunone"),
	:pokemon_stat_val 	=> 109,
	:pokemon_sheen_val 	=> 109,
	:pokemon_moves 		=> [:EXPLOSION,:FUTURESIGHT,:PSYCHIC,:CONFUSION]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperMarcus,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Marcus"),
	:character_sprite 	=> "trainer_SAILOR",
	:trainer_sprite 	=> "SAILOR",
	:pokemon_species 	=> :SQUIRTLE,
	:pokemon_nickname 	=> _INTL("Surtle"),
	:pokemon_stat_val 	=> 121,
	:pokemon_sheen_val 	=> 121,
	:pokemon_moves 		=> [:TAILWHIP,:BUBBLE,:FOCUSPUNCH,:WITHDRAW]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperNoel,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Noel"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :MAGIKARP,
	:pokemon_nickname 	=> _INTL("Karpag"),
	:pokemon_stat_val 	=> 180,
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:TACKLE,:SPLASH,:FLAIL,:TACKLE]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperRonnie,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Ronnie"),
	:character_sprite 	=> "trainer_HIKER",
	:trainer_sprite 	=> "HIKER",
	:pokemon_species 	=> :LAIRON,
	:pokemon_nickname 	=> _INTL("Lairn"),
	:pokemon_stat_val 	=> [0,0,0,139,118],
	:pokemon_sheen_val 	=> 125,
	:pokemon_moves 		=> [:METALSOUND,:METALCLAW,:HARDEN,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperSaul,
	:contest_category 	=> ["Cool","Cute","Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Saul"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :SEAKING,
	:pokemon_nickname 	=> _INTL("Kingsea"),
	:pokemon_stat_val 	=> [126,0,89,115,149],
	:pokemon_sheen_val 	=> 125,
	:pokemon_moves 		=> [:FLAIL,:SUPERSONIC,:HORNATTACK,:FURYATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperSelena,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Selena"),
	:character_sprite 	=> "trainer_SWIMMER_F",
	:trainer_sprite 	=> "SWIMMER_F",
	:pokemon_species 	=> :WAILMER,
	:pokemon_nickname 	=> _INTL("Merail"),
	:pokemon_stat_val 	=> [0,136,153,0,0],
	:pokemon_sheen_val 	=> 145,
	:pokemon_moves 		=> [:WATERPULSE,:REST,:WATERSPOUT,:SPLASH]
})
#Master
#Intervals of 13
#8=251+, 7=250-237, 6=236-223, 5=222-209, 4=208-195, 3=194-181, 2=180-167, 1=166-153, 0=152-
GameData::ContestTrainer.register({
	:id  				=> :MasterAubrey,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Aubrey"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :BELLOSSOM,
	:pokemon_nickname 	=> _INTL("Blossom"),
	:pokemon_stat_val 	=> [0,190,201,157,0],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:PETALDANCE,:SWEETSCENT,:STUNSPORE,:FLASH]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterCamille,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Camille"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :XATU,
	:pokemon_nickname 	=> _INTL("Utan"),
	:pokemon_stat_val 	=> [0,0,156,193,170],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:NIGHTSHADE,:FUTURESIGHT,:CONFUSERAY,:PSYCHIC]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterClara,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Clara"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :TOGEPI,
	:pokemon_nickname 	=> _INTL("Gepito"),
	:pokemon_stat_val 	=> 208,
	:pokemon_sheen_val 	=> 208,
	:pokemon_moves 		=> [:GROWL,:YAWN,:ENCORE,:FOLLOWME]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterDeon,
	:contest_category 	=> ["Cool","Cute","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Deon"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :SHARPEDO,
	:pokemon_nickname 	=> _INTL("Pedos"),
	:pokemon_stat_val 	=> 155,
	:pokemon_sheen_val 	=> 155,
	:pokemon_moves 		=> [:AGILITY,:SWAGGER,:TAUNT,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterFrankie,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Frankie"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :PICHU,
	:pokemon_nickname 	=> _INTL("Chupy"),
	:pokemon_stat_val 	=> [0,171,191,171,0],
	:pokemon_sheen_val 	=> 178,
	:pokemon_moves 		=> [:SWEETKISS,:ATTRACT,:REST,:TAILWHIP]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterHeath,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Heath"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :HERACROSS,
	:pokemon_nickname 	=> _INTL("Heross"),
	:pokemon_stat_val 	=> [190,0,0,0,200],
	:pokemon_sheen_val 	=> 195,
	:pokemon_moves 		=> [:STRENGTH,:ENDURE,:REVERSAL,:ROCKTOMB]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterHelen,
	:contest_category 	=> ["Cool","Beauty","Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Helen"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :WOBBUFFET,
	:pokemon_nickname 	=> _INTL("Wobet"),
	:pokemon_stat_val 	=> [189,189,0,205,205],
	:pokemon_sheen_val 	=> 195,
	:pokemon_moves 		=> [:COUNTER,:MIRRORCOAT,:SAFEGUARD,:DESTINYBOND]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterJakob,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Jakob"),
	:character_sprite 	=> "trainer_PSYCHIC_M",
	:trainer_sprite 	=> "PSYCHIC_M",
	:pokemon_species 	=> :ESPEON,
	:pokemon_nickname 	=> _INTL("Speon"),
	:pokemon_stat_val 	=> [206,183,0,0,0],
	:pokemon_sheen_val 	=> 190,
	:pokemon_moves 		=> [:SWIFT,:QUICKATTACK,:MORNINGSUN,:TAILWHIP]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterJanelle,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Janelle"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :LUVDISC,
	:pokemon_nickname 	=> _INTL("Speon"),
	:pokemon_stat_val 	=> [0,0,184,0,179],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:SWEETKISS,:ATTRACT,:TAKEDOWN,:CHARM]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterJustina,
	:contest_category 	=> ["Cool","Beauty","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Justina"),
	:character_sprite 	=> "trainer_PICNICKER",
	:trainer_sprite 	=> "PICNICKER",
	:pokemon_species 	=> :GYARADOS,
	:pokemon_nickname 	=> _INTL("Rados"),
	:pokemon_stat_val 	=> [199,184,0,0,178],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:HYPERBEAM,:HYDROPUMP,:RAINDANCE,:BITE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterKailey,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Kailey"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :MEOWTH,
	:pokemon_nickname 	=> _INTL("Meowy"),
	:pokemon_stat_val 	=> [0,0,206,194,0],
	:pokemon_sheen_val 	=> 200,
	:pokemon_moves 		=> [:GROWL,:TAUNT,:PAYDAY,:BITE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterKeaton,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Keaton"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :SLAKING,
	:pokemon_nickname 	=> _INTL("Sling"),
	:pokemon_stat_val 	=> 177,
	:pokemon_sheen_val 	=> 177,
	:pokemon_moves 		=> [:COVET,:COUNTER,:ENCORE,:SLACKOFF]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterLamar,
	:contest_category 	=> ["Cool","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lamar"),
	:character_sprite 	=> "trainer_COOLTRAINER_M",
	:trainer_sprite 	=> "COOLTRAINER_M",
	:pokemon_species 	=> :KIRLIA,
	:pokemon_nickname 	=> _INTL("Lirki"),
	:pokemon_stat_val 	=> 186,
	:pokemon_sheen_val 	=> 186,
	:pokemon_moves 		=> [:WAVE,:SHADOWBALL,:SKILLSWAP,:RETURN]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterLane,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lane"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :URSARING,
	:pokemon_nickname 	=> _INTL("Ursing"),
	:pokemon_stat_val 	=> 201,
	:pokemon_sheen_val 	=> 201,
	:pokemon_moves 		=> [:THRASH,:AERIALACE,:FAKETEARS,:LEER]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterMartin,
	:contest_category 	=> ["Cool","Beauty","Cute","Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Martin"),
	:character_sprite 	=> "trainer_SCIENTIST",
	:trainer_sprite 	=> "SCIENTIST",
	:pokemon_species 	=> :PORYGON,
	:pokemon_nickname 	=> _INTL("Gonpor"),
	:pokemon_stat_val 	=> 173,
	:pokemon_sheen_val 	=> 173,
	:pokemon_moves 		=> [:CONVERSION2,:CONVERSION,:RETURN,:RECYCLE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterNigel,
	:contest_category 	=> ["Cute","Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Nigel"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :SABLEYE,
	:pokemon_nickname 	=> _INTL("Eyesab"),
	:pokemon_stat_val 	=> [0,0,202,202,174],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:MEANLOOK,:FAINTATTACK,:KNOCKOFF,:CONFUSERAY]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterPerla,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Perla"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :JYNX,
	:pokemon_nickname 	=> _INTL("Nyx"),
	:pokemon_stat_val 	=> 170,
	:pokemon_sheen_val 	=> 170,
	:pokemon_moves 		=> [:PERISHSONG,:MEANLOOK,:LOVELYKISS,:FAKETEARS]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterRalph,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Ralph"),
	:character_sprite 	=> "trainer_GENTLEMAN",
	:trainer_sprite 	=> "GENTLEMAN",
	:pokemon_species 	=> :LOUDRED,
	:pokemon_nickname 	=> _INTL("Louderd"),
	:pokemon_stat_val 	=> [193,0,0,0,206],
	:pokemon_sheen_val 	=> 198,
	:pokemon_moves 		=> [:HYPERVOICE,:STOMP,:ROAR,:HOWL]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterRosa,
	:contest_category 	=> ["Beauty","Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Rosa"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :DELCATTY,
	:pokemon_nickname 	=> _INTL("Catted"),
	:pokemon_stat_val 	=> [0,184,207,184,0],
	:pokemon_sheen_val 	=> 190,
	:pokemon_moves 		=> [:ATTRACT,:ASSIST,:FAINTATTACK,:TAILWHIP]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterSasha,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Sasha"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :ELECTRODE,
	:pokemon_nickname 	=> _INTL("Rodlect"),
	:pokemon_stat_val 	=> 203,
	:pokemon_sheen_val 	=> 203,
	:pokemon_moves 		=> [:EXPLOSION,:LIGHTSCREEN,:SWIFT,:FLASH]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterSergio,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Sergio"),
	:character_sprite 	=> "trainer_POKEMANIAC",
	:trainer_sprite 	=> "POKEMANIAC",
	:pokemon_species 	=> :DRAGONITE,
	:pokemon_nickname 	=> _INTL("Drite"),
	:pokemon_stat_val 	=> 191,
	:pokemon_sheen_val 	=> 191,
	:pokemon_moves 		=> [:OUTRAGE,:SLAM,:TWISTER,:EARTHQUAKE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterTrey,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Trey"),
	:character_sprite 	=> "trainer_SAILOR",
	:trainer_sprite 	=> "SAILOR",
	:pokemon_species 	=> :SLOWKING,
	:pokemon_nickname 	=> _INTL("Slowgo"),
	:pokemon_stat_val 	=> 187,
	:pokemon_sheen_val 	=> 187,
	:pokemon_moves 		=> [:FACADE,:CURSE,:YAWN,:FOCUSPUNCH]
})

#====================================================================================
# Defined ORAS Trainer Definitions https://bulbapedia.bulbagarden.net/wiki/List_of_Contest_opponents_(Generation_VI)
#====================================================================================
#Normal
#Intervals of 10
#Original Range: 10-23
# 2:9-11 3:12-14 4:15-17 5:18-20 6:21-23
#8=81+, 7=80-71, 6=70-61, 5=60-51, 4=50-41, 3=40-31, 2=30-21, 1=20-11, 0=10-
GameData::ContestTrainer.register({
	:id  				=> :NormalORASMicah,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Micah"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :POOCHYENA,
	:pokemon_nickname 	=> _INTL("Poochin"),
	:pokemon_stat_val 	=> [39,0,0,0,26],
	:pokemon_sheen_val 	=> 32,
	:pokemon_moves 		=> [:BITE,:SCARYFACE,:TACKLE,:FIREFANG]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASShannon,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Shannon"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :ZIGZAGOON,
	:pokemon_nickname 	=> _INTL("Gonzer"),
	:pokemon_stat_val 	=> 25,
	:pokemon_sheen_val 	=> 25,
	:pokemon_moves 		=> [:MUDSPORT,:TAILWHIP,:PINMISSILE,:ODORSLEUTH]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASMateo,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Mateo"),
	:character_sprite 	=> "trainer_BUGCATCHER",
	:trainer_sprite 	=> "BUGCATCHER",
	:pokemon_species 	=> :DUSTOX,
	:pokemon_nickname 	=> _INTL("Nox"),
	:pokemon_stat_val 	=> 32,
	:pokemon_sheen_val 	=> 32,
	:pokemon_moves 		=> [:SILVERWIND,:MOONLIGHT,:STRUGGLEBUG,:PROTECT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASJordyn,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Jordyn"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :SEEDOT,
	:pokemon_nickname 	=> _INTL("Seedottie"),
	:pokemon_stat_val 	=> [0,0,0,27,33],
	:pokemon_sheen_val 	=> 30,
	:pokemon_moves 		=> [:HARDEN,:BIDE,:SYNTHESIS,:LEECHSEED]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASGianna,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Gianna"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :TAILLOW,
	:pokemon_nickname 	=> _INTL("Tailster"),
	:pokemon_stat_val 	=> 59,
	:pokemon_sheen_val 	=> 59,
	:pokemon_moves 		=> [:WINGATTACK,:DOUBLETEAM,:AERIALACE,:ECHOEDVOICE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASDeclan,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Declan"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :NINCADA,
	:pokemon_nickname 	=> _INTL("Ninny"),
	:pokemon_stat_val 	=> 50,
	:pokemon_sheen_val 	=> 50,
	:pokemon_moves 		=> [:LEECHLIFE,:MINDREADER,:FURYSWIPES,:MUDSLAP]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASCarlton,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Carlton"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :SHROOMISH,
	:pokemon_nickname 	=> _INTL("Shrewmish"),
	:pokemon_stat_val 	=> 59,
	:pokemon_sheen_val 	=> 59,
	:pokemon_moves 		=> [:ABSORB,:STUNSPORE,:LEECHSEED,:HEADBUTT]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASAdeline,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Adeline"),
	:character_sprite 	=> "trainer_TUBER_F",
	:trainer_sprite 	=> "TUBER_F",
	:pokemon_species 	=> :WINGULL,
	:pokemon_nickname 	=> _INTL("Win"),
	:pokemon_stat_val 	=> [0,44,47,0,0],
	:pokemon_sheen_val 	=> 45,
	:pokemon_moves 		=> [:WATERGUN,:GROWL,:WATERPULSE,:MIST]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASAsher,
	:contest_category 	=> ["Beauty","Cute","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Asher"),
	:character_sprite 	=> "trainer_POKEMANIAC",
	:trainer_sprite 	=> "POKEMANIAC",
	:pokemon_species 	=> :SLAKOTH,
	:pokemon_nickname 	=> _INTL("Visikoth"),
	:pokemon_stat_val 	=> [0,40,35,0,46],
	:pokemon_sheen_val 	=> 40,
	:pokemon_moves 		=> [:STRENGTH,:COUNTER,:YAWN,:ENCORE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASLauren,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Lauren"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :WHISMUR,
	:pokemon_nickname 	=> _INTL("Whizz"),
	:pokemon_stat_val 	=> 38,
	:pokemon_sheen_val 	=> 38,
	:pokemon_moves 		=> [:ASTONISH,:SLEEPTALK,:SUBSTITUTE,:SCREECH]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASJeremiah,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Jeremiah"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :MAKUHITA,
	:pokemon_nickname 	=> _INTL("Makuwaku"),
	:pokemon_stat_val 	=> [32,0,0,0,59],
	:pokemon_sheen_val 	=> 48,
	:pokemon_moves 		=> [:ARMTHRUST,:SMELLINGSALTS,:FORCEPALM,:FOCUSENERGY]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASMolly,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Molly"),
	:character_sprite 	=> "trainer_PICNICKER",
	:trainer_sprite 	=> "PICNICKER",
	:pokemon_species 	=> :ARON,
	:pokemon_nickname 	=> _INTL("Ronnie"),
	:pokemon_stat_val 	=> [60,0,0,0,37],
	:pokemon_sheen_val 	=> 45,
	:pokemon_moves 		=> [:METALCLAW,:HEADBUTT,:HARDEN,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASMartinus,
	:contest_category 	=> ["Beauty","Smart"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Martinus"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :ZUBAT,
	:pokemon_nickname 	=> _INTL("Zoonby"),
	:pokemon_stat_val 	=> [0,26,0,32,0],
	:pokemon_sheen_val 	=> 30,
	:pokemon_moves 		=> [:HAZE,:MEANLOOK,:CONFUSERAY,:LEECHLIFE]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASLiliana,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Liliana"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :GULPIN,
	:pokemon_nickname 	=> _INTL("Guligan"),
	:pokemon_stat_val 	=> 67,
	:pokemon_sheen_val 	=> 67,
	:pokemon_moves 		=> [:POISONGAS,:TOXIC,:AMNESIA,:YAWN]
})
GameData::ContestTrainer.register({
	:id  				=> :NormalORASCamden,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Normal",
	:name 				=> _INTL("Camden"),
	:character_sprite 	=> "trainer_ROCKER",
	:trainer_sprite 	=> "ROCKER",
	:pokemon_species 	=> :ELECTRIKE,
	:pokemon_nickname 	=> _INTL("Bolt"),
	:pokemon_stat_val 	=> [69,62,0,0,0],
	:pokemon_sheen_val 	=> 65,
	:pokemon_moves 		=> [:SPARK,:HOWL,:BITE,:LIGHTSCREEN]
})

#Super
#Intervals of 14
#Original Range: 28-80
# 1:21-30 2:31-40 3:41-50 4:51-60 5:61-70 6:71-80
#8=141+, 7=140-126, 6=125-112, 5=111-98, 4=97-84, 3=83-70, 2=69-56, 1=55-42, 0=41-
GameData::ContestTrainer.register({
	:id  				=> :SuperORASKeira,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Keira"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :ROSELIA,
	:pokemon_nickname 	=> _INTL("Rosalie"),
	:pokemon_stat_val 	=> [0,66,67,0,0],
	:pokemon_sheen_val 	=> 66,
	:pokemon_moves 		=> [:MAGICALLEAF,:GROWTH,:SWEETSCENT,:GRASSKNOT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASBentley,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Bentley"),
	:character_sprite 	=> "trainer_BIRDKEEPER",
	:trainer_sprite 	=> "BIRDKEEPER",
	:pokemon_species 	=> :DODUO,
	:pokemon_nickname 	=> _INTL("Dodon't"),
	:pokemon_stat_val 	=> [66,0,0,0,66],
	:pokemon_sheen_val 	=> 66,
	:pokemon_moves 		=> [:PECK,:FURYATTACK,:RAGE,:ACUPRESSURE]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASPlum,
	:contest_category 	=> ["Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Plum"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :TRAPINCH,
	:pokemon_nickname 	=> _INTL("Tracy"),
	:pokemon_stat_val 	=> 72,
	:pokemon_sheen_val 	=> 72,
	:pokemon_moves 		=> [:BITE,:DIG,:BULLDOZE,:FEINTATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASZachary,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Zachary"),
	:character_sprite 	=> "trainer_POKEMONRANGER_M",
	:trainer_sprite 	=> "POKEMONRANGER_M",
	:pokemon_species 	=> :CACNEA,
	:pokemon_nickname 	=> _INTL("Succulus"),
	:pokemon_stat_val 	=> 71,
	:pokemon_sheen_val 	=> 71,
	:pokemon_moves 		=> [:NEEDLEARM,:POISONSTING,:LEECHSEED,:SANDATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASAlyssa,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Alyssa"),
	:character_sprite 	=> "trainer_PICNICKER",
	:trainer_sprite 	=> "PICNICKER",
	:pokemon_species 	=> :SANDSHREW,
	:pokemon_nickname 	=> _INTL("Sandyclaws"),
	:pokemon_stat_val 	=> 82,
	:pokemon_sheen_val 	=> 82,
	:pokemon_moves 		=> [:FURYCUTTER,:RAPIDSPIN,:FURYSWIPES,:DIG]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASBrody,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Brody"),
	:character_sprite 	=> "trainer_RUINMANIAC",
	:trainer_sprite 	=> "RUINMANIAC",
	:pokemon_species 	=> :BALTOY,
	:pokemon_nickname 	=> _INTL("Baltop"),
	:pokemon_stat_val 	=> 96,
	:pokemon_sheen_val 	=> 96,
	:pokemon_moves 		=> [:CONFUSION,:ROCKTOMB,:MUDSLAP,:HARDEN]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASMila,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Mila"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :NUMEL,
	:pokemon_nickname 	=> _INTL("Mel"),
	:pokemon_stat_val 	=> 97,
	:pokemon_sheen_val 	=> 97,
	:pokemon_moves 		=> [:FLAMEBURST,:EARTHPOWER,:EMBER,:AMNESIA]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASRohan,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Rohan"),
	:character_sprite 	=> "trainer_CAMPER",
	:trainer_sprite 	=> "CAMPER",
	:pokemon_species 	=> :SPINDA,
	:pokemon_nickname 	=> _INTL("Spinmaster"),
	:pokemon_stat_val 	=> [0,0,66,80,0],
	:pokemon_sheen_val 	=> 72,
	:pokemon_moves 		=> [:DIZZYPUNCH,:TEETERDANCE,:HYPNOSIS,:DREAMEATER]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASAlaina,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Alaina"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :SWABLU,
	:pokemon_nickname 	=> _INTL("Swellbell"),
	:pokemon_stat_val 	=> [0,65,76,0,0],
	:pokemon_sheen_val 	=> 70,
	:pokemon_moves 		=> [:ASTONISH,:SING,:ROUND,:MIST]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASLevi,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Levi"),
	:character_sprite 	=> "trainer_SWIMMER_M",
	:trainer_sprite 	=> "SWIMMER_M",
	:pokemon_species 	=> :LINOONE,
	:pokemon_nickname 	=> _INTL("Noone"),
	:pokemon_stat_val 	=> [96,0,0,0,54],
	:pokemon_sheen_val 	=> 90,
	:pokemon_moves 		=> [:CUT,:SURF,:ROCKSMASH,:STRENGTH]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASGabriella,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Gabriella"),
	:character_sprite 	=> "trainer_COOLTRAINER_F",
	:trainer_sprite 	=> "COOLTRAINER_F",
	:pokemon_species 	=> :KECLEON,
	:pokemon_nickname 	=> _INTL("Leon"),
	:pokemon_stat_val 	=> 80,
	:pokemon_sheen_val 	=> 80,
	:pokemon_moves 		=> [:SLASH,:SHADOWCLAW,:FURYSWIPES,:THIEF]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASDominic,
	:contest_category 	=> ["Tough"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Dominic"),
	:character_sprite 	=> "trainer_SUPERNERD",
	:trainer_sprite 	=> "SUPERNERD",
	:pokemon_species 	=> :CORPHISH,
	:pokemon_nickname 	=> _INTL("Snip"),
	:pokemon_stat_val 	=> 107,
	:pokemon_sheen_val 	=> 107,
	:pokemon_moves 		=> [:CUT,:HARDEN,:KNOCKOFF,:DOUBLEHIT]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASKaitlyn,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Kaitlyn"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :BARBOACH,
	:pokemon_nickname 	=> _INTL("Barbra"),
	:pokemon_stat_val 	=> [0,76,69,0,0],
	:pokemon_sheen_val 	=> 72,
	:pokemon_moves 		=> [:WATERGUN,:WATERSPORT,:WATERPULSE,:ROUND]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASTyler,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Tyler"),
	:character_sprite 	=> "trainer_PSYCHIC_M",
	:trainer_sprite 	=> "PSYCHIC_M",
	:pokemon_species 	=> :SPOINK,
	:pokemon_nickname 	=> _INTL("Spearl"),
	:pokemon_stat_val 	=> [0,57,83,0,0],
	:pokemon_sheen_val 	=> 75,
	:pokemon_moves 		=> [:PSYBEAM,:MAGICCOAT,:ATTRACT,:REST]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASAdalyn,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Adalyn"),
	:character_sprite 	=> "trainer_POKEMONRANGER_F",
	:trainer_sprite 	=> "POKEMONRANGER_F",
	:pokemon_species 	=> :LOTAD,
	:pokemon_nickname 	=> _INTL("Tad"),
	:pokemon_stat_val 	=> 93,
	:pokemon_sheen_val 	=> 93,
	:pokemon_moves 		=> [:MEGADRAIN,:ZENHEADBUTT,:GROWL,:BUBBLE]
})
GameData::ContestTrainer.register({
	:id  				=> :SuperORASChaz,
	:contest_category 	=> ["Cool","Smart"],
	:contest_rank 		=> "Super",
	:name 				=> _INTL("Chaz"),
	:character_sprite 	=> "trainer_ENGINEER",
	:trainer_sprite 	=> "ENGINEER",
	:pokemon_species 	=> :MACHOKE,
	:pokemon_nickname 	=> _INTL("Macherie"),
	:pokemon_stat_val 	=> [125,0,0,123,0],
	:pokemon_sheen_val 	=> 125,
	:pokemon_moves 		=> [:ATTRACT,:BULKUP,:BRICKBREAK,:LOWSWEEP]
})

#Hyper
#Intervals of 16
#Original Range: 74-180
# 2:71-92 3:93-114 4:115-136 5:137-158 6:159-180
#8=201+, 7=200-184, 6=183-167, 5=166-150, 4=149-134, 3=133-117, 2=116-100, 1=99-84, 0=83-
GameData::ContestTrainer.register({
	:id  				=> :HyperORASLandon,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Landon"),
	:character_sprite 	=> "trainer_POKEMANIAC",
	:trainer_sprite 	=> "POKEMANIAC",
	:pokemon_species 	=> :LAIRON,
	:pokemon_nickname 	=> _INTL("Wonwon"),
	:pokemon_stat_val 	=> [0,0,0,121,128],
	:pokemon_sheen_val 	=> 125,
	:pokemon_moves 		=> [:ROCKTOMB,:METALSOUND,:IRONDEFENSE,:TAKEDOWN]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASMckenzie,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Mckenzie"),
	:character_sprite 	=> "trainer_POKEMONRANGER_F",
	:trainer_sprite 	=> "POKEMONRANGER_F",
	:pokemon_species 	=> :NUZLEAF,
	:pokemon_nickname 	=> _INTL("Nuzlad"),
	:pokemon_stat_val 	=> [142,130,0,0,0],
	:pokemon_sheen_val 	=> 136,
	:pokemon_moves 		=> [:RAZORLEAF,:EXTRASENSORY,:EXPLOSION,:NATUREPOWER]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASNelson,
	:contest_category 	=> ["Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Nelson"),
	:character_sprite 	=> "trainer_YOUNGSTER",
	:trainer_sprite 	=> "YOUNGSTER",
	:pokemon_species 	=> :NINJASK,
	:pokemon_nickname 	=> _INTL("Ninjackie"),
	:pokemon_stat_val 	=> 104,
	:pokemon_sheen_val 	=> 104,
	:pokemon_moves 		=> [:FURYSWIPES,:HARDEN,:XSCISSOR,:DOUBLETEAM]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASRiley,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Riley"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :SWELLOW,
	:pokemon_nickname 	=> _INTL("Wollew"),
	:pokemon_stat_val 	=> 102,
	:pokemon_sheen_val 	=> 102,
	:pokemon_moves 		=> [:WINGATTACK,:AIRSLASH,:FOCUSENERGY,:QUICKATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASNathan,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Nathan"),
	:character_sprite 	=> "trainer_GENTLEMAN",
	:trainer_sprite 	=> "GENTLEMAN",
	:pokemon_species 	=> :MIGHTYENA,
	:pokemon_nickname 	=> _INTL("Mighty"),
	:pokemon_stat_val 	=> 110,
	:pokemon_sheen_val 	=> 110,
	:pokemon_moves 		=> [:ODORSLEUTH,:EMBARGO,:ASSURANCE,:CRUNCH]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASTwyla,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Twyla"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :BEAUTIFLY,
	:pokemon_nickname 	=> _INTL("Papi"),
	:pokemon_stat_val 	=> 139,
	:pokemon_sheen_val 	=> 139,
	:pokemon_moves 		=> [:SILVERWIND,:MORNINGSUN,:CONFIDE,:AIRCUTTER]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASGavin,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Gavin"),
	:character_sprite 	=> "trainer_FISHERMAN",
	:trainer_sprite 	=> "FISHERMAN",
	:pokemon_species 	=> :SEAKING,
	:pokemon_nickname 	=> _INTL("The King"),
	:pokemon_stat_val 	=> 119,
	:pokemon_sheen_val 	=> 119,
	:pokemon_moves 		=> [:WATERPULSE,:WATERFALL,:HORNATTACK,:FURYATTACK]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASLily,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Lily"),
	:character_sprite 	=> "trainer_LADY",
	:trainer_sprite 	=> "LADY",
	:pokemon_species 	=> :CAMERUPT,
	:pokemon_nickname 	=> _INTL("Camelot"),
	:pokemon_stat_val 	=> 134,
	:pokemon_sheen_val 	=> 134,
	:pokemon_moves 		=> [:EARTHPOWER,:FLAMEBURST,:AMNESIA,:GROWL]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASPrimo,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Primo"),
	:character_sprite 	=> "trainer_HIKER",
	:trainer_sprite 	=> "HIKER",
	:pokemon_species 	=> :MACHOP,
	:pokemon_nickname 	=> _INTL("Chopchop"),
	:pokemon_stat_val 	=> 112,
	:pokemon_sheen_val 	=> 112,
	:pokemon_moves 		=> [:BRICKBREAK,:BULKUP,:KARATECHOP,:DUALCHOP]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASAlejandra,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Alejandra"),
	:character_sprite 	=> "trainer_POKEMONBREEDER",
	:trainer_sprite 	=> "POKEMONBREEDER",
	:pokemon_species 	=> :LOMBRE,
	:pokemon_nickname 	=> _INTL("Nombre"),
	:pokemon_stat_val 	=> [0,0,119,125,0],
	:pokemon_sheen_val 	=> 122,
	:pokemon_moves 		=> [:FAKEOUT,:WATERSPORT,:NATURALGIFT,:KNOCKOFF]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASYoshinari,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Yoshinari"),
	:character_sprite 	=> "trainer_GAMBLER",
	:trainer_sprite 	=> "GAMBLER",
	:pokemon_species 	=> :SEVIPER,
	:pokemon_nickname 	=> _INTL("Crawly"),
	:pokemon_stat_val 	=> [0,0,0,120,136],
	:pokemon_sheen_val 	=> 130,
	:pokemon_moves 		=> [:VENOSHOCK,:VENOMDRENCH,:GLARE,:THIEF]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASLacy,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Lacy"),
	:character_sprite 	=> "trainer_TUBER_F",
	:trainer_sprite 	=> "TUBER_F",
	:pokemon_species 	=> :WAILMER,
	:pokemon_nickname 	=> _INTL("Bobble"),
	:pokemon_stat_val 	=> 109,
	:pokemon_sheen_val 	=> 109,
	:pokemon_moves 		=> [:ASTONISH,:ROLLOUT,:REST,:WATERSPOUT]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASOwen,
	:contest_category 	=> ["Cute","Tough"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Owen"),
	:character_sprite 	=> "trainer_SWIMMER_M",
	:trainer_sprite 	=> "SWIMMER_M",
	:pokemon_species 	=> :MAGIKARP,
	:pokemon_nickname 	=> _INTL("Magi"),
	:pokemon_stat_val 	=> [0,0,142,154,0],
	:pokemon_sheen_val 	=> 146,
	:pokemon_moves 		=> [:SPLASH,:FLAIL,:TACKLE,:BOUNCE]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASAddison,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Addison"),
	:character_sprite 	=> "trainer_PSYCHIC_F",
	:trainer_sprite 	=> "PSYCHIC_F",
	:pokemon_species 	=> :LUNATONE,
	:pokemon_nickname 	=> _INTL("Moony"),
	:pokemon_stat_val 	=> 141,
	:pokemon_sheen_val 	=> 141,
	:pokemon_moves 		=> [:PSYCHIC,:FUTURESIGHT,:HYPNOSIS,:ROCKPOLISH]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASJayce,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Jayce"),
	:character_sprite 	=> "trainer_SAILOR",
	:trainer_sprite 	=> "SAILOR",
	:pokemon_species 	=> :PELIPPER,
	:pokemon_nickname 	=> _INTL("Piper"),
	:pokemon_stat_val 	=> 124,
	:pokemon_sheen_val 	=> 124,
	:pokemon_moves 		=> [:WINGATTACK,:STOCKPILE,:SWALLOW,:SPITUP]
})
GameData::ContestTrainer.register({
	:id  				=> :HyperORASChaz,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Hyper",
	:name 				=> _INTL("Chaz"),
	:character_sprite 	=> "trainer_ENGINEER",
	:trainer_sprite 	=> "ENGINEER",
	:pokemon_species 	=> :MACHOKE,
	:pokemon_nickname 	=> _INTL("Macherie"),
	:pokemon_stat_val 	=> [0,181,183,0,0],
	:pokemon_sheen_val 	=> 182,
	:pokemon_moves 		=> [:RETURN,:ATTRACT,:ROUND,:SUNNYDAY]
})

#Master
#Intervals of 13
#Original Range: 137-256
# 1:135-157 2:158-180 3:181-203 4:204-226 5:226-248 6:249-271
#8=251+, 7=250-237, 6=236-223, 5=222-209, 4=208-195, 3=194-181, 2=180-167, 1=166-153, 0=152-
GameData::ContestTrainer.register({
	:id  				=> :MasterORASYoko,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Yoko"),
	:character_sprite 	=> "trainer_POKEMONRANGER_F",
	:trainer_sprite 	=> "POKEMONRANGER_F",
	:pokemon_species 	=> :GYARADOS,
	:pokemon_nickname 	=> _INTL("Gyalaxy"),
	:pokemon_stat_val 	=> [192,0,0,0,182],
	:pokemon_sheen_val 	=> 186,
	:pokemon_moves 		=> [:DRAGONDANCE,:HYPERBEAM,:CRUNCH,:THRASH]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASJeff,
	:contest_category 	=> ["Cool"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Jeff"),
	:character_sprite 	=> "trainer_ROCKER",
	:trainer_sprite 	=> "ROCKER",
	:pokemon_species 	=> :LOUDRED,
	:pokemon_nickname 	=> _INTL("Louduff"),
	:pokemon_stat_val 	=> 173,
	:pokemon_sheen_val 	=> 173,
	:pokemon_moves 		=> [:HYPERVOICE,:RETALIATE,:HOWL,:ECHOEDVOICE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASElsie,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Elsie"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :DELCATTY,
	:pokemon_nickname 	=> _INTL("Mione"),
	:pokemon_stat_val 	=> 169,
	:pokemon_sheen_val 	=> 169,
	:pokemon_moves 		=> [:FAKEOUT,:DOUBLESLAP,:DISARMINGVOICE,:SAFEGUARD]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASJaylon,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Jaylon"),
	:character_sprite 	=> "trainer_TAMER",
	:trainer_sprite 	=> "TAMER",
	:pokemon_species 	=> :SLAKING,
	:pokemon_nickname 	=> _INTL("Slacker"),
	:pokemon_stat_val 	=> [188,0,0,0,200],
	:pokemon_sheen_val 	=> 195,
	:pokemon_moves 		=> [:BULKUP,:SLACKOFF,:CHIPAWAY,:COUNTER]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASLayla,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Layla"),
	:character_sprite 	=> "trainer_SWIMMER_F",
	:trainer_sprite 	=> "SWIMMER_F",
	:pokemon_species 	=> :GOREBYSS,
	:pokemon_nickname 	=> _INTL("Gorflir"),
	:pokemon_stat_val 	=> 189,
	:pokemon_sheen_val 	=> 189,
	:pokemon_moves 		=> [:WHIRLPOOL,:AQUATAIL,:SURF,:AGILITY]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASRuslan,
	:contest_category 	=> ["Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Ruslan"),
	:character_sprite 	=> "trainer_PSYCHIC_M",
	:trainer_sprite 	=> "PSYCHIC_M",
	:pokemon_species 	=> :KIRLIA,
	:pokemon_nickname 	=> _INTL("Lia"),
	:pokemon_stat_val 	=> 187,
	:pokemon_sheen_val 	=> 187,
	:pokemon_moves 		=> [:STOREDPOWER,:CALMMIND,:PSYCHUP,:TRICKROOM]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASLilias,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Lilias"),
	:character_sprite 	=> "trainer_AROMALADY",
	:trainer_sprite 	=> "AROMALADY",
	:pokemon_species 	=> :VILEPLUME,
	:pokemon_nickname 	=> _INTL("Plumette"),
	:pokemon_stat_val 	=> 171,
	:pokemon_sheen_val 	=> 171,
	:pokemon_moves 		=> [:PETALBLIZZARD,:PETALDANCE,:GRASSYTERRAIN,:SOLARBEAM]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASAiden,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Aiden"),
	:character_sprite 	=> "trainer_BIKER",
	:trainer_sprite 	=> "BIKER",
	:pokemon_species 	=> :DUSCLOPS,
	:pokemon_nickname 	=> _INTL("Topclops"),
	:pokemon_stat_val 	=> [0,0,0,157,158],
	:pokemon_sheen_val 	=> 158,
	:pokemon_moves 		=> [:TOXIC,:HEX,:SPITE,:CURSE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASMadelyn,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Madelyn"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :ILLUMISE,
	:pokemon_nickname 	=> _INTL("Princess"),
	:pokemon_stat_val 	=> [0,0,185,169,0],
	:pokemon_sheen_val 	=> 185,
	:pokemon_moves 		=> [:WISH,:PLAYNICE,:ZENHEADBUTT,:CONFUSERAY]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASElijah,
	:contest_category 	=> ["Smart","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Elijah"),
	:character_sprite 	=> "trainer_SAILOR",
	:trainer_sprite 	=> "SAILOR",
	:pokemon_species 	=> :SHARPEDO,
	:pokemon_nickname 	=> _INTL("Shargob"),
	:pokemon_stat_val 	=> [0,0,0,188,188],
	:pokemon_sheen_val 	=> 188,
	:pokemon_moves 		=> [:POISONFANG,:ASSURANCE,:RAGE,:SCALD]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASHailey,
	:contest_category 	=> ["Cute","Smart"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Hailey"),
	:character_sprite 	=> "trainer_SWIMMER_F",
	:trainer_sprite 	=> "SWIMMER_F",
	:pokemon_species 	=> :LUVDISC,
	:pokemon_nickname 	=> _INTL("Lovelynn"),
	:pokemon_stat_val 	=> [0,0,176,200,0],
	:pokemon_sheen_val 	=> 185,
	:pokemon_moves 		=> [:DRAININGKISS,:SWEETKISS,:PSYCHUP,:SUBSTITUTE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASClayton,
	:contest_category 	=> ["Cool","Tough"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Clayton"),
	:character_sprite 	=> "trainer_BLACKBELT",
	:trainer_sprite 	=> "BLACKBELT",
	:pokemon_species 	=> :HERACROSS,
	:pokemon_nickname 	=> _INTL("Heracles"),
	:pokemon_stat_val 	=> [154,0,0,0,154],
	:pokemon_sheen_val 	=> 154,
	:pokemon_moves 		=> [:FURYATTACK,:REVERSAL,:ENDURE,:GIGAIMPACT]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASAudrey,
	:contest_category 	=> ["Cool","Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Audrey"),
	:character_sprite 	=> "trainer_LASS",
	:trainer_sprite 	=> "LASS",
	:pokemon_species 	=> :ELECTRODE,
	:pokemon_nickname 	=> _INTL("Trode"),
	:pokemon_stat_val 	=> [180,178,0,0,0],
	:pokemon_sheen_val 	=> 180,
	:pokemon_moves 		=> [:SONICBOOM,:ELECTROBALL,:DISCHARGE,:EXPLOSION]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASEvan,
	:contest_category 	=> ["Cute"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Evan"),
	:character_sprite 	=> "trainer_POKEMANIAC",
	:trainer_sprite 	=> "POKEMANIAC",
	:pokemon_species 	=> :PICHU,
	:pokemon_nickname 	=> _INTL("Pinchurlink"),
	:pokemon_stat_val 	=> 197,
	:pokemon_sheen_val 	=> 197,
	:pokemon_moves 		=> [:SWEETKISS,:TAILWHIP,:CHARM,:CONFIDE]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASJulia,
	:contest_category 	=> ["Beauty"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Julia"),
	:character_sprite 	=> "trainer_BEAUTY",
	:trainer_sprite 	=> "BEAUTY",
	:pokemon_species 	=> :WOBBUFFET,
	:pokemon_nickname 	=> _INTL("Elizabeth"),
	:pokemon_stat_val 	=> 230,
	:pokemon_sheen_val 	=> 230,
	:pokemon_moves 		=> [:COUNTER,:MIRRORCOAT,:SAFEGUARD,:DESTINYBOND]
})
GameData::ContestTrainer.register({
	:id  				=> :MasterORASChaz,
	:contest_category 	=> ["Beauty","Cute"],
	:contest_rank 		=> "Master",
	:name 				=> _INTL("Chaz"),
	:character_sprite 	=> "trainer_ENGINEER",
	:trainer_sprite 	=> "ENGINEER",
	:pokemon_species 	=> :MACHOKE,
	:pokemon_nickname 	=> _INTL("Macherie"),
	:pokemon_stat_val 	=> [0,185,185,0,0],
	:pokemon_sheen_val 	=> 185,
	:pokemon_moves 		=> [:RETURN,:ATTRACT,:ROUND,:SUNNYDAY]
})