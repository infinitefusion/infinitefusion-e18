#====================================================================================
#  Contests General Settings
#====================================================================================

module ContestSettings

#====================================================================================
#================================ General Settings ==================================
#====================================================================================

	#--------------------------------------------------------------------------------
	# Set this to be the number of Talent Rounds you wish to occur during a contest.
	# By default it's 5. Generation 3 uses 5, while Generation 4 uses 4.
	#--------------------------------------------------------------------------------		
	NUMBER_OF_TALENT_ROUNDS 			= 5 
	
	#--------------------------------------------------------------------------------
	# When true, the CONTESTPASS item is required to participate in contests.
	#--------------------------------------------------------------------------------
	REQUIRE_CONTEST_PASS_ITEM			= true 
	
	#--------------------------------------------------------------------------------
	# When true, a Pokemon's Sheen will be considered during the Introduction Round.
	# If DONT_USE_SHEEN or SIMPLIFIED_BERRY_BLENDING in Pokeblocks >
	# 000_Pokeblock_Settings is true, this will always be treated as false.
	#--------------------------------------------------------------------------------
	USE_SHEEN_FOR_INTRODUCTION_ROUND 	= false
	
	#--------------------------------------------------------------------------------
	# Set to the Switch ID that will be used to control whether or not contest info
	# can be viewed in a Pokemon's Summary. Default is 80.
	#--------------------------------------------------------------------------------
	CONTEST_INFO_IN_SUMMARY_SWITCH 		= 1996
	
	#--------------------------------------------------------------------------------
	# When true, an ORAS style applause meter will be used. Otherwise, the classic
	# applause meter from Generation 3 will be used.
	#--------------------------------------------------------------------------------
	USE_ORAS_APPLAUSE_METER		 		= true
	
	#--------------------------------------------------------------------------------
	# When true, if a Pokemon maxes out the Applause meter and they have an available
	# mega evolution, they mega evolve and gain an extra 2 appeal.
	#--------------------------------------------------------------------------------
	SHOW_SPECIAL_TRANSFORMATIONS		= false
	
	#--------------------------------------------------------------------------------
	# When true, executing a combo in a contest will double the base appeal a move
	# does (which happens in Generation 3). Otherwise, it will do +3 (which happens
	# in Generation 6).
	#--------------------------------------------------------------------------------
	COMBOS_DOUBLE_APPEAL		 		= true
	
	#--------------------------------------------------------------------------------
	# Set the BGM file name for the audio that will play when showing a contest's
	# results. By default, it's "RSE 235 Results Announcement" (when using that BGM,
	# make sure to credit ENLS’s Pre-Looped Music Library https://reliccastle.com/resources/663/
	#--------------------------------------------------------------------------------
	BGM_CONTEST_RESULTS_FILE			= "RSE 235 Results Announcement"
	
	#--------------------------------------------------------------------------------
	# Set the BGM file name for the audio that will play when congratulating the 
	# contest winner. By default, it's "RSE 236 Contest Won!" (when using that BGM,
	# make sure to credit ENLS’s Pre-Looped Music Library https://reliccastle.com/resources/663/
	#--------------------------------------------------------------------------------
	BGM_CONTEST_WON_FILE				= "RSE 236 Contest Won!"
	
	#--------------------------------------------------------------------------------
	# Define which ribbons (as defined in PBS > ribbons) are awarded for each contest
	# based on category. Within each category's array, define them in the order of
	# rank: [Normal, Super, Hyper, Master]
	#--------------------------------------------------------------------------------
	CONTEST_RIBBONS = {
		0 => 	[:HOENNCOOL,:HOENNCOOLSUPER,:HOENNCOOLHYPER,:HOENNCOOLMASTER], # Cool
		1 => 	[:HOENNBEAUTY,:HOENNBEAUTYSUPER,:HOENNBEAUTYHYPER,:HOENNBEAUTYMASTER], # Beauty
		2 => 	[:HOENNCUTE,:HOENNCUTESUPER,:HOENNCUTEHYPER,:HOENNCUTEMASTER], # Cute
		3 => 	[:HOENNSMART,:HOENNSMARTSUPER,:HOENNSMARTHYPER,:HOENNSMARTMASTER], # Smart
		4 => 	[:HOENNTOUGH,:HOENNTOUGHSUPER,:HOENNTOUGHHYPER,:HOENNTOUGHMASTER] # Tough
	}
	
	#--------------------------------------------------------------------------------
	# Define which items are awarded for each contest based on category if your 
	# winning Pokemon already has the associated ribbon. Within each category's array, 
	# define them in the order of rank: [Normal, Super, Hyper, Master]
	#--------------------------------------------------------------------------------
	CONTEST_OTHER_PRIZE = {
		0 => 	[:POTION,:SUPERPOTION,:HYPERPOTION,:FULLRESTORE], # Cool
		1 => 	[:POTION,:SUPERPOTION,:HYPERPOTION,:FULLRESTORE], # Beauty
		2 => 	[:POTION,:SUPERPOTION,:HYPERPOTION,:FULLRESTORE], # Cute
		3 => 	[:POTION,:SUPERPOTION,:HYPERPOTION,:FULLRESTORE], # Smart
		4 => 	[:POTION,:SUPERPOTION,:HYPERPOTION,:FULLRESTORE] # Tough
	}

#====================================================================================
#================================ Technical Settings ================================
#====================================================================================	
	
	#--------------------------------------------------------------------------------
	# When true, instead of using ContestDescription as defined in movesx_contest, 
	# the Contest Description for moves will be written based on its 
	# ContestFunctionCode. These are defined in 010_Move_Functions.
	#--------------------------------------------------------------------------------
	GET_MOVE_DESCRIPTIONS_FROM_FUNCTION = false
	
	#--------------------------------------------------------------------------------
	# Default focal points of user and target in animations.
	#--------------------------------------------------------------------------------
	# Base X and Y coordinates for the User
	USER_X_BASE			= 466
	USER_Y_BASE			= 176
	# Offset X and Y coordinates for the User
	USER_X_OFFSET		= 0
	USER_Y_OFFSET		= 0
	# Equation to calculate X and Y cordinates for the User
	FOCUSUSER_X         = USER_X_BASE + USER_X_OFFSET
	FOCUSUSER_Y         = USER_Y_BASE + USER_Y_OFFSET
	
	# Base X and Y coordinates for the "target" of moves (invisible)
	TARGET_X_BASE		= 96
	TARGET_Y_BASE		= 96
	# Offset X and Y coordinates for the "target" of moves (invisible)
	TARGET_X_OFFSET		= 0
	TARGET_Y_OFFSET		= 0
	# Equation to calculate X and Y cordinates for the "target" of moves (invisible)
	FOCUSTARGET_X       = TARGET_X_BASE + TARGET_X_OFFSET
	FOCUSTARGET_Y       = TARGET_Y_BASE + TARGET_Y_OFFSET

#====================================================================================
#================================ Move Combo Definitions ============================
#====================================================================================
	
	#--------------------------------------------------------------------------------
	# This is where contest combos are defined. The move defined on the left will
	# start a combo, and any move included in its associated array will successfully
	# execute the combo.
	#--------------------------------------------------------------------------------
	COMBOS = {
		:AGILITY		=> [:BATONPASS,:ELECTROBALL],
		:AMNESIA		=> [:BATONPASS,:STOREDPOWER],
		:BELLYDRUM		=> [:REST],
		:BLOCK			=> [:EXPLOSION,:MEMENTO,:PERISHSONG,:SELFDESTRUCT],
		:CALMMIND  		=> [:BATONPASS,:CONFUSION,:DREAMEATER,:FUTURESIGHT,:LIGHTSCREEN,:LUSTERPURGE,:MEDITATE,:MISTBALL,:PSYBEAM,:PSYCHIC,:PSYCHOBOOST,:PSYWAVE,:REFLECT,:STOREDPOWER],
		:CELEBRATE		=> [:BESTOW,:FLING,:PRESENT],
		:CHARGE			=> [:CHARGEBEAM,:DISCHARGE,:ELECTROBALL,:NUZZLE,:PARABOLICCHARGE,:SHOCKWAVE,:SPARK,:THUNDER,:THUNDERBOLT,:THUNDERPUNCH,:THUNDERSHOCK,:THUNDERWAVE,:VOLTSWITCH,:VOLTTACKLE,:ZAPCANNON], 
		:CHARM			=> [:FLATTER,:GROWL,:REST,:TAILWHIP],
		:CONFUSION		=> [:FUTURESIGHT,:KINESIS,:PSYCHIC,:TELEPORT],
		:COVET			=> [:BESTOW,:FLING,:PRESENT],
		:CURSE			=> [:DESTINYBOND,:GRUDGE,:MEANLOOK,:SPITE],
		:DARKVOID		=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:DEFENSECURL	=> [:ICEBALL,:ROLLOUT,:TACKLE],
		:DIVE			=> [:SURF],
		:DOUBLETEAM		=> [:AGILITY,:QUICKATTACK,:TELEPORT],
		:DRAGONBREATH	=> [:DRAGONCLAW,:DRAGONDANCE,:DRAGONRAGE],
		:DRAGONDANCE	=> [:DRAGONBREATH,:DRAGONCLAW,:DRAGONRAGE],
		:DRAGONRAGE		=> [:DRAGONBREATH,:DRAGONCLAW,:DRAGONDANCE],
		:EARTHQUAKE		=> [:ERUPTION,:FISSURE],
		:ELECTRICTERRAIN=> [:TERRAINPULSE,:RISINGVOLTAGE],
		:ENCORE			=> [:COUNTER,:DESTINYBOND,:GRUDGE,:METALBURST,:MIRRORCOAT,:SPITE],
		:ENDURE			=> [:ENDEAVOR,:FLAIL,:PAINSPLIT,:REVERSAL],
		:ENTRAINMENT	=> [:CIRCLETHROW,:ROAR,:SEISMICTOSS,:SKYDROP,:SMACKDOWN,:STORMTHROW,:VITALTHROW,:WAKEUPSLAP],
		:FAKEOUT		=> [:ARMTHRUST,:FEINTATTACK,:KNOCKOFF,:SEISMICTOSS,:VITALTHROW],
		:FIREPUNCH		=> [:ICEPUNCH,:THUNDERPUNCH],
		:FOCUSENERGY	=> [:ARMTHRUST,:BLAZEKICK,:BRICKBREAK,:CROSSCHOP,:DOUBLEEDGE,:DRILLRUN,:DYNAMICPUNCH,:FOCUSPUNCH,:HEADBUTT,:KARATECHOP,:NIGHTSLASH,:POISONTAIL,:SHADOWCLAW,:SKYUPPERCUT,:STONEEDGE,:TAKEDOWN],
		:FORCEPALM		=> [:HEX,:SMELLINGSALTS],
		:GLARE			=> [:HEX,:SMELLINGSALTS],
		:GRASSWHISTLE	=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:GRASSYTERRAIN	=> [:TERRAINPULSE,:GRASSYGLIDE,:FLORALHEALING],
		:GRAVITY		=> [:GRAVAPPLE],
		:GROWTH			=> [:ABSORB,:BULLETSEED,:FRENZYPLANT,:GIGADRAIN,:LEECHSEED,:MAGICALLEAF,:MEGADRAIN,:PETALDANCE,:RAZORLEAF,:SOLARBEAM,:VINEWHIP],
		:HAIL			=> [:AURORABEAM,:BLIZZARD,:GLACIATE,:HAZE,:ICEBALL,:ICEBEAM,:ICICLECRASH,:ICICLESPEAR,:ICYWIND,:POWDERSNOW,:SHEERCOLD,:WEATHERBALL],
		:HAPPYHOUR		=> [:BESTOW,:FLING,:PRESENT],
		:HARDEN			=> [:DOUBLEEDGE,:PROTECT,:ROLLOUT,:TACKLE,:TAKEDOWN],
		:HONECLAWS		=> [:BATONPASS,:STOREDPOWER],
		:HORNATTACK		=> [:HORNDRILL,:FURYATTACK],
		:HYPNOSIS		=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:ICEPUNCH		=> [:FIREPUNCH,:THUNDERPUNCH],
		:INFERNO		=> [:HEX],
		:KINESIS		=> [:CONFUSION,:FUTURESIGHT,:PSYCHIC,:TELEPORT],
		:LEER			=> [:BITE,:FEINTATTACK,:GLARE,:HORNATTACK,:SCARYFACE,:SCRATCH,:STOMP,:TACKLE],
		:LOCKON			=> [:SUPERPOWER,:THUNDER,:TRIATTACK,:ZAPCANNON],
		:LOVELYKISS		=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:MEANLOOK		=> [:DESTINYBOND,:EXPLOSION,:MEMENTO,:PERISHSONG,:SELFDESTRUCT],
		:METALSOUND		=> [:METALCLAW],
		:MINDREADER		=> [:DYNAMICPUNCH,:HIJUMPKICK,:SHEERCOLD,:SUBMISSION,:SUPERPOWER],
		:MISTYTERRAIN	=> [:TERRAINPULSE,:MISTYEXPLOSION],
		:MUDSPORT		=> [:MUDSLAP,:WATERGUN,:WATERSPORT],
		:NASTYPLOT		=> [:BATONPASS,:STOREDPOWER],
		:PARABOLICCHARGE=> [:ELECTRIFY],
		:PECK			=> [:DRILLPECK,:FURYATTACK],
		:PLAYNICE		=> [:CIRCLETHROW,:ROAR,:SEISMICTOSS,:SKYDROP,:SMACKDOWN,:STORMTHROW,:VITALTHROW,:WAKEUPSLAP],
		:POISONGAS		=> [:HEX,:VENOMDRENCH,:VENOSHOCK],
		:POISONPOWDER	=> [:HEX,:VENOMDRENCH,:VENOSHOCK],
		:POUND			=> [:DOUBLESLAP,:FEINTATTACK,:SLAM],
		:POWDERSNOW		=> [:BLIZZARD],
		:PSYCHIC		=> [:CONFUSION,:TELEPORT,:FUTURESIGHT,:KINESIS],
		:PSYCHICTERRAIN	=> [:TERRAINPULSE,:EXPANDINGFORCE],
		:RAGE			=> [:LEER,:SCARYFACE,:THRASH],
		:RAINDANCE		=> [:BUBBLE,:BUBBLEBEAM,:CLAMP,:CRABHAMMER,:DIVE,:HURRICANE,:HYDROCANNON,:HYDROPUMP,:MUDDYWATER,:OCTAZOOKA,:SOAK,:SURF,:THUNDER,:WATERGUN,
							:WATERPULSE,:WATERSPORT,:WATERSPOUT,:WATERFALL,:WEATHERBALL,:WHIRLPOOL],
		:REST			=> [:SLEEPTALK,:SNORE],
		:ROCKPOLISH		=> [:BATONPASS,:ELECTROBALL],
		:ROCKTHROW		=> [:ROCKSLIDE,:ROCKTOMB],
		:ROTOTILLER		=> [:BULLETSEED,:LEECHSEED,:SEEDBOMB,:WORRYSEED],
		:SANDATTACK		=> [:MUDSLAP],
		:SANDSTORM		=> [:MUDSHOT,:MUDSLAP,:MUDSPORT,:SANDTOMB,:SANDATTACK,:WEATHERBALL],
		:SCARYFACE		=> [:BITE,:CRUNCH,:LEER],
		:SCRATCH		=> [:FURYSWIPES,:SLASH],
		:SHIFTGEAR		=> [:GEARGRIND],
		:SING			=> [:DREAMEATER,:HEX,:NIGHTMARE,:PERISHSONG,:REFRESH,:WAKEUPSLAP],
		:SLEEPPOWDER	=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:SLUDGE			=> [:SLUDGEBOMB],
		:SLUDGEBOMB		=> [:SLUDGE],
		:SMOG			=> [:SMOKESCREEN],
		:SOFTBOILED		=> [:EGGBOMB],
		:SPIKES			=> [:DRAGONTAIL,:ROAR,:WHIRLWIND],
		:SPORE			=> [:DREAMEATER,:HEX,:NIGHTMARE,:WAKEUPSLAP],
		:STEALTHROCK	=> [:DRAGONTAIL,:ROAR,:WHIRLWIND],
		:STOCKPILE		=> [:SPITUP,:SWALLOW],
		:STRINGSHOT		=> [:ELECTROWEB,:SPIDERWEB,:STICKYWEB],
		:SUNNYDAY		=> [:BLASTBURN,:BLAZEKICK,:EMBER,:ERUPTION,:FIREBLAST,:FIREPUNCH,:FIRESPIN,:FLAMEWHEEL,:FLAMETHROWER,:GROWTH,:HEATWAVE,:MOONLIGHT,
							:MORNINGSUN,:OVERHEAT,:SACREDFIRE,:SOLARBEAM,:SYNTHESIS,:WEATHERBALL,:WILLOWISP], 
		:SURF			=> [:DIVE],
		:SWEETSCENT		=> [:POISONPOWDER,:SLEEPPOWDER,:STUNSPORE],
		:SWORDSDANCE	=> [:CRABHAMMER,:CRUSHCLAW,:CUT,:FALSESWIPE,:FURYCUTTER,:SLASH],
		:TAUNT			=> [:COUNTER,:DESTINYBOND,:DETECT,:GRUDGE,:METALBURST,:MIRRORCOAT,:SPITE],
		:THUNDERPUNCH	=> [:FIREPUNCH,:ICEPUNCH],
		:THUNDERWAVE	=> [:HEX,:SMELLINGSALTS],
		:TORMENT		=> [:COUNTER,:DESTINYBOND,:GRUDGE,:METALBURST,:MIRRORCOAT,:SPITE],
		:TOXIC			=> [:HEX,:VENOMDRENCH,:VENOSHOCK],
		:TOXICSPIKES	=> [:DRAGONTAIL,:HEX,:ROAR,:VENOMDRENCH,:VENOSHOCK,:WHIRLWIND],
		:VICEGRIP		=> [:BIND,:GUILLOTINE],
		:WATERSPORT		=> [:MUDSPORT,:REFRESH,:WATERGUN],
		:WILLOWISP		=> [:HEX],
		:WISH			=> [:BESTOW,:FLING,:PRESENT],
		:YAWN			=> [:DREAMEATER,:HEX,:NIGHTMARE,:REST,:SLACKOFF,:WAKEUPSLAP],
	}

	#https://bulbapedia.bulbagarden.net/wiki/Contest_combination#In_the_anime
	ANIME_COMBOS = { #Not implemented, but possibly in the future
		"Swift-Ember"				=> [:EMBER,:SWIFT],
		"Shadow Ball-Swift"			=> [:SHADOWBALL,:SWIFT],
		"Razor Leaf-Silver Wind"	=> [:RAZORLEAF,:SILVERWIND],
		"Swift-Psychic"				=> [:PSYCHIC,:SWIFT],
		"Focus Ball" 				=> [:FOCUSPUNCH,:SHADOWBALL],
		"Dragon Razor Wind"			=> [:DRAGONBREATH,:RAZORWIND],
		"Water and Fire Whirlwind"	=> [:BUBBLE,:FIRESPIN],
		"Mud Bomb-Shock Wave"		=> [:MUDBOMB,:SHOCKWAVE],
		"Spinning Poison Sting"		=> [:POISONSTING,:POISONTAIL],
		"Shadow Claw-Blizzard"		=> [:BLIZZARD,:SHADOWCLAW],
		"Ice Aqua Jet"				=> [:AQUAJET,:ICEBEAM],
		"Flame Ice"					=> [:FLAMEWHEEL,:ICESHARD],
		"Haze-SonicBoom"			=> [:HAZE,:SONICBOOM],
		"Poison Tail-Silver Wind"	=> [:POISONTAIL,:SILVERWIND],
		"Quadruple Combination"		=> [:ICESHARD,:SWIFT,:TAKEDOWN],
		"Scare Face-Sandstorm"		=> [:SANDSTORM,:SCARYFACE],
		"Ice Chandelier"			=> [:ICEBEAM,:DISCHARGE],
		"Energy Fusion Ball"		=> [:ENERGYBALL,:SHOCKWAVE],
		"Snowflakes"				=> [:BLIZZARD,:SILVERWIND],
		"Aerial Ace-Psywave"		=> [:AERIALACE,:PSYWAVE],
		"Signal Tail"				=> [:IRONTAIL,:SIGNALBEAM],
		"Aura Whirlpool"			=> [:AURASPHERE,:WHIRLPOOL],
		"Rocket Formation"			=> [:PECK,:SKYATTACK],
		"Electrified Psycho Cut"	=> [:PSYCHOCUT,:THUNDERBOLT]
	}
	
end
