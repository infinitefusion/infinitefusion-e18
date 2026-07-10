class Pokeblock
	attr_accessor :color
	attr_accessor :flavor
	attr_accessor :level
	attr_accessor :smoothness
	attr_accessor :plus
	
	def initialize(color,flavor,smoothness,plus=false)
		@color = color # PokeblockColor
		@flavor = flavor # Array [x,x,x,x,x]
		@level = @flavor.max # Integer
		@smoothness = smoothness # Integer
		@plus = plus || false # Boolean
	end
	
	def color_name; return GameData::PokeblockColor.get(@color).name; end
	def name; return color_name + " Pokéblock" + (@plus ? " +" : ""); end
	def feel; return @smoothness; end

end

class Player
	attr_accessor :pokeblocks

	alias berry_blender_player_ini initialize unless private_method_defined?(:berry_blender_player_ini)
	def initialize(name, trainer_type)
		berry_blender_player_ini(name, trainer_type)
		@pokeblocks = []
	end
	
	def hasPokeblocks?
		@pokeblocks = [] if !@pokeblocks
		return @pokeblocks.length > 0
	end
	
	def gainPokeblock(pokeblock)
		@pokeblocks = [] if !@pokeblocks
		@pokeblocks.push(pokeblock)
		sortPokeblocks
	end
	
	def sortPokeblocks
		arr = @pokeblocks
		colors = GameData::PokeblockColor.keys
		#arr.sort! { |a, b| GameData::Item.keys.index(a[0]) <=> GameData::Item.keys.index(b[0]) }
		#arr.sort_by! { |x| colors.index x.color }
		arr.sort_by! { |x| [GameData::PokeblockColor.get(x.color).sort_number,x.level,(x.plus ? 1 : 0)] }	
	end

end

class Pokemon

	def totalContestStats
		return @cool+@beauty+@cute+@smart+@tough
	end

end