#====================================================================================
#  Contests Trainer Settings
#====================================================================================

module ContestSettings

	#--------------------------------------------------------------------------------
	# Default difficulty for all trainers, if not specifically defined.
	#	91+ => will always use the most optimal move
	#	76-90 => will always one of the two most optimal moves
	#	51-75 => never does the least optimal move, higher chance of using better move
	#	26-50 => never does the least optimal move
	#	-25 => uses random move
	# Defined in the order of rank: [Normal, Super, Hyper, Master]
	#--------------------------------------------------------------------------------	
	DEFAULT_TRAINER_DIFFICULTY = [15,30,51,70]

#====================================================================================
#================================= Defined Trainers =================================
#====================================================================================
	#--------------------------------------------------------------------------------
	# These are the lists of defined trainers (in 
	# 004_Contests_Trainer_Types_Definitions) to include in contests, based on rank.
	#--------------------------------------------------------------------------------	
	DEFINED_TRAINERS_NORMAL = [
		:NormalORASMicah, :NormalORASShannon, :NormalORASMateo, :NormalORASJordyn,
		:NormalORASGianna, :NormalORASDeclan, :NormalORASCarlton, :NormalORASAdeline,
		:NormalORASAsher, :NormalORASLauren, :NormalORASJeremiah, :NormalORASMolly,
		:NormalORASMartinus, :NormalORASLiliana, :NormalORASCamden
	]
	DEFINED_TRAINERS_SUPER = [
		:SuperORASKeira, :SuperORASBentley, :SuperORASPlum, :SuperORASZachary,
		:SuperORASAlyssa, :SuperORASBrody, :SuperORASMila, :SuperORASRohan,
		:SuperORASAlaina, :SuperORASLevi, :SuperORASGabriella, :SuperORASDominic,
		:SuperORASKaitlyn, :SuperORASTyler, :SuperORASAdalyn, :SuperORASChaz
	]
	DEFINED_TRAINERS_HYPER = [
		:HyperORASLandon, :HyperORASMckenzie, :HyperORASNelson, :HyperORASRiley,
		:HyperORASNathan, :HyperORASTwyla, :HyperORASGavin, :HyperORASLily,
		:HyperORASPrimo, :HyperORASAlejandra, :HyperORASYoshinari, :HyperORASLacy,
		:HyperORASOwen, :HyperORASAddison, :HyperORASJayce, :HyperORASChaz
	]
	DEFINED_TRAINERS_MASTER = [
		:MasterORASYoko, :MasterORASJeff, :MasterORASElsie, :MasterORASJaylon,
		:MasterORASLayla, :MasterORASRuslan, :MasterORASLilias, :MasterORASAiden,
		:MasterORASMadelyn, :MasterORASElijah, :MasterORASHailey, :MasterORASClayton,
		:MasterORASAudrey, :MasterORASEvan, :MasterORASJulia, :MasterORASChaz
	]
	
	#--------------------------------------------------------------------------------
	# Chance out of 100 that a trainer is a defined trainer rather than random 
	# default. Random defaults are defined in Contest Trainer Defaults below.
	#--------------------------------------------------------------------------------	
	DEFINED_TRAINER_CHANCE = 0

#====================================================================================
#============================= Contest Trainer Defaults =============================
#====================================================================================

	#--------------------------------------------------------------------------------
	# Default Pokemon
	# If a Trainer is undefinied in contests, uses a Random Pokemon included in
	# the following arrays, based on category.
	#--------------------------------------------------------------------------------	
	DEFAULT_PKMN_COOL = [ 	# Cool
		[:LEDYBA, :MAKUHITA, :MIGHTYENA, :LOTAD, :POOCHYENA], # First trainer
		[:ARON, :POOCHYENA, :AGGRON, :ILLUMISE, :TRAPINCH], # Second trainer
		[:TOTODILE, :WHISMUR, :VOLBEAT, :WAILMER, :CORPHISH] # Third trainer
	]
	DEFAULT_PKMN_BEAUTY = [	# Beauty
		[:MILOTIC, :TYMPOLE, :VENIPEDE, :SCRAGGY, :TIRTOUGA], # First trainer
		[:SOLOSIS, :JOLTIK, :CHANDELURE, :SERPERIOR, :SAMUROTT], # Second trainer
		[:STOUTLAND, :MILOTIC, :LUCARIO, :ROSERADE, :INFERNAPE] # Third trainer
	]
	DEFAULT_PKMN_CUTE = [	# Cute
		[:RALTS, :PLUSLE, :MINUN, :ESPEON, :UMBREON], # First trainer
		[:EEVEE, :VAPOREON, :JOLTEON, :PORYGON, :PONYTA], # Second trainer
		[:DODUO, :GROWLITHE, :ESPEON, :GARDEVOIR, :LUVDISC] # Third trainer
	]
	DEFAULT_PKMN_SMART = [	# Smart
		[:CHIMCHAR, :AMBIPOM, :PANSAGE, :ZORUA, :RUFFLET], # First trainer
		[:MANDIBUZZ, :ZOROAK, :CUBONE, :GENGAR, :ZUBAT], # Second trainer
		[:ZOROAK, :ZORUA, :SNEASEL, :WEAVILE, :ARIADOS] # Third trainer
	]
	DEFAULT_PKMN_TOUGH = [	# Tough
		[:HARIYAMA, :WAILORD, :WHISCASH, :ABSOL, :PACHIRISU], # First trainer
		[:WAILORD, :BASTIODON, :LUCARIO, :TOXICROAK, :LICKILICKY], # Second trainer
		[:WAILMER, :WAILORD, :ARCHEN, :EMOLGA, :GALVANTULA] # Third trainer
	]
	
	#--------------------------------------------------------------------------------
	# Default Pokemon Levels
	# The level a default Pokemon will be based on rank. This is used to define the
	# Pokemon's move set.
	# Defined in the order of rank: [Normal, Super, Hyper, Master]
	#--------------------------------------------------------------------------------	
	DEFAULT_PKMN_LEVEL = [25, 50, 75, 100]
	
	#--------------------------------------------------------------------------------
	# Default Pokemon Condition Value
	# The default condition value a Pokemon will have be based on rank.
	# Defined in the order of rank: [Normal, Super, Hyper, Master]
	# If DEFAULT_PKMN_STAT_RANDOM is set to true, then value will be bewteen 10 and 
	# the appropriate DEFAULT_PKMN_STAT_VALUE
	#--------------------------------------------------------------------------------
	DEFAULT_PKMN_STAT_VALUE = [50, 85, 135, 200]
	DEFAULT_PKMN_STAT_RANDOM = true
	
	#--------------------------------------------------------------------------------
	# Default Pokemon Sheen Value
	# The default sheen value a Pokemon will have be based on rank.
	# Defined in the order of rank: [Normal, Super, Hyper, Master]
	# If DEFAULT_PKMN_SHEEN_RANDOM is set to true, then value will be bewteen 10 and 
	# the appropriate DEFAULT_PKMN_SHEEN_VALUE
	#--------------------------------------------------------------------------------
	DEFAULT_PKMN_SHEEN_VALUE = [50, 85, 135, 200]
	DEFAULT_PKMN_SHEEN_RANDOM = true
	
	#--------------------------------------------------------------------------------
	# Default Trainers
	# A list of possible default trainers. For each trainer, a random one will be
	# selected from the arrays.
	# Defined in the following way:
	# [Trainer Name, Graphics\Characters file name, Graphics\Trainers file name]
	#--------------------------------------------------------------------------------
	DEFAULT_TRAINERS = [
		[ #First trainer
			["Alice","trainer_BEAUTY","BEAUTY"],
			["Alan","trainer_BIKER","BIKER"],
			["Genevieve","trainer_LADY","LADY"]
		],[ #Second trainer
			["Scott","trainer_TAMER","TAMER"],
			["Timmy","trainer_CAMPER","CAMPER"],
			["Jay","trainer_COOLTRAINER_M","COOLTRAINER_M"],
			["Faye","trainer_COOLTRAINER_F","COOLTRAINER_F"]
		],[ #Third trainer
			["Matt","trainer_BLACKBELT","BLACKBELT"],
			["Kim","trainer_AROMALADY","AROMALADY"],
			["Teri","trainer_YOUNGSTER","YOUNGSTER"],
			["Sue","trainer_PICNICKER","PICNICKER"]
		]
	]

end
