#====================================================================================
#  Settings
#====================================================================================
module PokeblockSettings
	#--------------------------------------------------------------------------------
	# Set this to be the pocket number your game uses for Berries. By default it's 5.
	#--------------------------------------------------------------------------------
	BERRY_POCKET_OF_BAG				= 5
	
	#--------------------------------------------------------------------------------
	# When true, a more simplified Berry Blending mode from Generation 6 (ORAS) will 
	# be used. When false, the original Generation 3 (RSE) mode will be used.
	# 
	# Generation 3 mode:
	# - Sheen/Feel will restrict how many Pokeblocks a Pokemon can eat
	# - Wider variety of Pokeblock flavors and colors (like Olive, Black, etc.)
	# - Blend with several NPCs to get stronger Pokemon
	# - Berry Blender will be a minigame
	#
	# Generation 6 mode:
	# - Sheen/Feel not a restriction, instead the Pokemon can max out each contest stat.
	# - Only 5 single Pokeblock colors, plus Rainbow, and their + versions.
	# - Blending is simplified: no NPCs needed and is not a minigame.
	#
	# More info:
	# https://bulbapedia.bulbagarden.net/wiki/Berry_Blender#Pok.C3.A9mon_Ruby.2C_Sapphire.2C_and_Emerald
	# https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9block
	#--------------------------------------------------------------------------------
	SIMPLIFIED_BERRY_BLENDING		= true

#====================================================================================
#======================= Generation 3 Mode Specific Settings ========================
#====================================================================================
	#--------------------------------------------------------------------------------
	# When true, Sheen will not be used, even in Generation 3 mode.
	#--------------------------------------------------------------------------------
	DONT_USE_SHEEN					= true
	
	#--------------------------------------------------------------------------------
	# When true, contest stats in the Conditions sceen will use a bar graph. Instead
	# of a pentagon.
	# The pentagon graph uses Marin's Better Bitmaps plugin, so it is required if true.
	# https://reliccastle.com/resources/169/
	#--------------------------------------------------------------------------------
	STATS_BAR_GRAPH					= true
	
	#--------------------------------------------------------------------------------
	# When true, NPCs will use any random berry when Berry Blending. When false, they
	# will use only predefined berries to help maximize the Pokeblock result.
	# More info: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9block#Blending_with_non-playable_characters
	#--------------------------------------------------------------------------------
	NPC_USE_RANDOM_BERRIES			= false 
	
	#--------------------------------------------------------------------------------
	# If you don't define a list of NPC names when calling pbBerryBlender, then they
	# fall back to using a randomly chosen name defined in this array.
	#--------------------------------------------------------------------------------
	NPC_DEFAULT_NAMES = [
		# Person 1 is yourself
		["Alice","Alex","Andrew"], # Person 2 name options
		["Barry","Beatrice","Bob"], # Person 3 name options
		["Carl","Chris","Caroline"], # Person 4 name options
		["Devin","Drew","Diane"]  # Berry Master name options
	]
	
	#--------------------------------------------------------------------------------
	# If NPC_USE_RANDOM_BERRIES is true, Berry Master NPCs will only use a berry
	# randomly chosen from this array.
	#--------------------------------------------------------------------------------
	BERRY_MASTER_BERRIES = [ 
		:LIECHIBERRY,:GANLONBERRY,:SALACBERRY,:PETAYABERRY,:APICOTBERRY,
		:LANSATBERRY,:STARFBERRY,:ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,
		:JABOCABERRY,:ROWAPBERRY,:ROSELIBERRY,:KEEBERRY,:MARANGABERRY
	]
	
#====================================================================================
#====================== Generation 6 Mode Specific Settings =========================
#====================================================================================
	#--------------------------------------------------------------------------------
	# Berries used when blending Pokeblocks in Generation 6 mode will each have a 
	# chance of making all the Pokeblocks a + version. Values for each berry are 
	# defined here.
	#--------------------------------------------------------------------------------
	SIMPLE_POKEBLOCK_PLUS_PROBABILITY = {
		"Very Low" => [ # Each berry adds 1/100 chance the Pokeblocks being a +
			:CHERIBERRY,:FIGYBERRY,:LEPPABERRY,:RAZZBERRY,:BLUKBERRY,:CHESTOBERRY,:ORANBERRY,
			:WIKIBERRY,:MAGOBERRY,:NANABBERRY,:PECHABERRY,:PERSIMBERRY,:AGUAVBERRY,:RAWSTBERRY,
			:WEPEARBERRY,:ASPEARBERRY,:IAPAPABERRY,:PINAPBERRY
		],
		"Low" => [ # Each berry adds 5/100 chance
			:POMEGBERRY,:TAMATOBERRY,:BELUEBERRY,:CORNNBERRY,:KELPSYBERRY,:PAMTREBERRY,:MAGOSTBERRY,
			:QUALOTBERRY,:SPELONBERRY,:DURINBERRY,:HONDEWBERRY,:LUMBERRY,:RABUTABERRY,:WATMELBERRY,
			:GREPABERRY,:NOMELBERRY,:SITRUSBERRY
		],
		"Medium" => [ # Each berry adds 15/100 chance
			:CHOPLEBERRY,:HABANBERRY,:OCCABERRY,:PAYAPABERRY,:ROSELIBERRY,:COBABERRY,:PASSHOBERRY,
			:YACHEBERRY,:COLBURBERRY,:KASIBBERRY,:BABIRIBERRY,:KEBIABERRY,:RINDOBERRY,:TANGABERRY,
			:CHARTIBERRY,:CHILANBERRY,:SHUCABERRY,:WACANBERRY
		],
		"Medium High" => [ # Each berry adds 25/100 chance
			:APICOTBERRY,:GANLONBERRY,:KEEBERRY,:PETAYABERRY,:SALACBERRY,:LIECHIBERRY,:MARANGABERRY
		],
		"High" => [ # Each berry adds 40/100 chance
			:CUSTAPBERRY,:ROWAPBERRY,:MICLEBERRY,:ENIGMABERRY,:JABOCABERRY
		],
		"Guaranteed" => [ # Each berry guarantees the Pokeblocks being a +
			:LANSATBERRY,:STARFBERRY
		]
	}
	#--------------------------------------------------------------------------------
	# A Pokemon's Nature has an impact on how effective Pokeblocks are based on  
	# taste preference. These preferences are defined below.
	#--------------------------------------------------------------------------------
	NATURE_FLAVOR_PREFERENCES = {
		"Likes" => [
			[:LONELY,:BRAVE,:ADAMANT,:NAUGHTY], #Likes Spicy
			[:MODEST,:MILD,:QUIET,:RASH], #Likes Dry
			[:TIMID,:HASTY,:JOLLY,:NAIVE], #Likes Sweet
			[:CALM,:GENTLE,:SASSY,:CAREFUL], #Likes Bitter
			[:BOLD,:RELAXED,:IMPISH,:LAX]  #Likes Sour
		],
		"Dislikes" => [
			[:BOLD,:TIMID,:MODEST,:CALM], #Dislikes Spicy
			[:ADAMANT,:IMPISH,:JOLLY,:CAREFUL], #Dislikes Dry
			[:BRAVE,:RELAXED,:QUIET,:SASSY], #Dislikes Sweet
			[:NAUGHTY,:LAX,:NAIVE,:RASH], #Dislikes Bitter
			[:LONELY,:HASTY,:MILD,:GENTLE]  #Dislikes Sour
		]
	}

end