#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  PokemonContest
#====================================================================================
class PokemonContest
	attr_accessor :rank
	attr_accessor :category
	attr_accessor :playerPokemon
	attr_accessor :hallMapInfo #[Map ID, x, y]
	attr_accessor :returnMapInfo #[Map ID, x, y, facing direction]
	attr_accessor :trainerOne
	attr_accessor :trainerTwo
	attr_accessor :trainerThree
	attr_accessor :pokemonOne
	attr_accessor :pokemonTwo
	attr_accessor :pokemonThree
	attr_accessor :winningPosition
	attr_accessor :winningPokemon
	attr_accessor :winningTrainer
	attr_accessor :crowdEnergy
	attr_accessor :crowdPaused
	attr_accessor :round
	attr_accessor :roundOrder
	attr_accessor :nextTurnFirstOrder
	attr_accessor :nextTurnLastOrder
	attr_accessor :scramble
	attr_accessor :playerWin

	def initialize
		@rank = -1
		@category = -1
		@playerPokemon = nil
		@hallMapInfo = nil
		@returnMapInfo = nil
		@trainerOne = @trainerTwo = @trainerThree = nil
		@pokemonOne = @pokemonTwo = @pokemonThree = nil
		@crowdEnergy = 0
		@crowdPaused = nil
		@round = 1
		@roundOrder = []
		@nextTurnFirstOrder = [nil,nil,nil,nil]
		@nextTurnLastOrder = [nil,nil,nil,nil]
		@scramble = false
		@winningPosition = 0
		@winningPokemon = nil
		@winningTrainer = nil
		@playerWin = false
	end
	
	def isCrowdPaused?(pkmn)
		return false if @crowdPaused.nil?
		return false if @crowdPaused == pkmn
		return true
	end

	def set(rank, category, pokemon, hallMapInfo, returnMapInfo)
		@rank = rank
		@category = category
		@playerPokemon = $Trainer.party[pokemon]
		@hallMapInfo = hallMapInfo
		@returnMapInfo = returnMapInfo
		setupCoordinatorPokemon
		initialOrder
	end
	
	def setupCoordinatorPokemon
		if $PokemonGlobal.nextContestTrainerOne
			if $PokemonGlobal.nextContestTrainerOne.is_a?(Array)
				@trainerOne = $PokemonGlobal.nextContestTrainerOne[@category]
			else
				@trainerOne = $PokemonGlobal.nextContestTrainerOne
			end
		end
		$PokemonGlobal.nextContestTrainerOne = nil
		@trainerOne = getTrainer(0,@trainerOne)
		@pokemonOne = @trainerOne.pokemon
		@pokemonOne.setupContestVariables(@trainerOne)
		if $PokemonGlobal.nextContestTrainerTwo
			if $PokemonGlobal.nextContestTrainerTwo.is_a?(Array)
				@trainerTwo = $PokemonGlobal.nextContestTrainerTwo[@category]
			else
				@trainerTwo = $PokemonGlobal.nextContestTrainerTwo
			end
		end
		$PokemonGlobal.nextContestTrainerTwo = nil
		@trainerTwo = getTrainer(1,@trainerTwo)
		@pokemonTwo = @trainerTwo.pokemon
		@pokemonTwo.setupContestVariables(@trainerTwo)
		if $PokemonGlobal.nextContestTrainerThree
			if $PokemonGlobal.nextContestTrainerThree.is_a?(Array)
				@trainerThree = $PokemonGlobal.nextContestTrainerThree[@category]
			else
				@trainerThree = $PokemonGlobal.nextContestTrainerThree
			end
		end
		$PokemonGlobal.nextContestTrainerThree = nil
		@trainerThree = getTrainer(2,@trainerThree)
		@pokemonThree = @trainerThree.pokemon
		@pokemonThree.setupContestVariables(@trainerThree)
		@playerPokemon.setupContestVariables
	end

	def getTrainer(position,trainer)
		#trainer defined in command
		if trainer && trainer.contest_category.include?(ContestFunctions.getCategoryNameShort(@category)) &&
				trainer.contest_rank == ContestFunctions.getRankNameShort(@rank)
			pkmn = Pokemon.new(trainer.species,ContestSettings::DEFAULT_PKMN_LEVEL[@rank])
			pkmn.moves = []
			for move in trainer.moves
				pkmn.moves.push(Pokemon::Move.new(move))
			end
			pkmn.cool = trainer.pokemon_stat_val(0)
			pkmn.beauty = trainer.pokemon_stat_val(1)
			pkmn.cute = trainer.pokemon_stat_val(2)
			pkmn.smart = trainer.pokemon_stat_val(3)
			pkmn.tough = trainer.pokemon_stat_val(4)
			pkmn.sheen = trainer.pokemon_sheen_val
			pkmn.item = trainer.pokemon_item if trainer.pokemon_item
			pkmn.shiny = trainer.pokemon_shiny if trainer.pokemon_shiny
			pkmn.form = trainer.pokemon_form if trainer.pokemon_form
			trainer.pokemon = pkmn
			return trainer
		end
		#grab defined trainer
		if rand(100) < ContestSettings::DEFINED_TRAINER_CHANCE
			trainer = nil
			while !trainer || !trainer.contest_category.include?(ContestFunctions.getCategoryNameShort(@category)) ||
				@trainerOne == trainer || @trainerTwo == trainer || @trainerThree == trainer
				case @rank
				when 0 then defined_trainer = ContestSettings::DEFINED_TRAINERS_NORMAL.sample;
				when 1 then defined_trainer = ContestSettings::DEFINED_TRAINERS_SUPER.sample;
				when 2 then defined_trainer = ContestSettings::DEFINED_TRAINERS_HYPER.sample;
				when 3 then defined_trainer = ContestSettings::DEFINED_TRAINERS_MASTER.sample;
				end
				trainer = GameData::ContestTrainer.get(defined_trainer)
			end
			pkmn = Pokemon.new(trainer.species,ContestSettings::DEFAULT_PKMN_LEVEL[@rank])
			pkmn.moves = []
			for move in trainer.moves
				pkmn.moves.push(Pokemon::Move.new(move))
			end
			pkmn.cool = trainer.pokemon_stat_val(0)
			pkmn.beauty = trainer.pokemon_stat_val(1)
			pkmn.cute = trainer.pokemon_stat_val(2)
			pkmn.smart = trainer.pokemon_stat_val(3)
			pkmn.tough = trainer.pokemon_stat_val(4)
			pkmn.sheen = trainer.pokemon_sheen_val
			pkmn.item = trainer.pokemon_item if trainer.pokemon_item
			pkmn.shiny = trainer.pokemon_shiny if trainer.pokemon_shiny
			pkmn.form = trainer.pokemon_form if trainer.pokemon_form
			trainer.pokemon = pkmn
			return trainer
		end
		#random default trainer
		trainerInfo = ContestSettings::DEFAULT_TRAINERS[position].sample
		trainerName = getRandomUnisexName
		cat_val = (ContestSettings::DEFAULT_PKMN_STAT_RANDOM ? 10 + rand(ContestSettings::DEFAULT_PKMN_STAT_VALUE[@rank]-10) :
			ContestSettings::DEFAULT_PKMN_STAT_VALUE[@rank])
		sheen_val = (ContestSettings::DEFAULT_PKMN_SHEEN_RANDOM ? 10 + rand(ContestSettings::DEFAULT_PKMN_SHEEN_VALUE[@rank]-10) :
			ContestSettings::DEFAULT_PKMN_SHEEN_VALUE[@rank])
		pkmn= create_contest_trainer_pokemon(@rank, @category)
		species = pkmn.species
		pkmn.cool = pkmn.beauty = pkmn.cute = pkmn.smart = pkmn.tough = cat_val
		pkmn.sheen = sheen_val
		#Save for when you can define default moves
		# moves = []
		# available_moves = GameData::Species.get(species).moves
		# knowable_moves = []
		# available_moves.each { |m| knowable_moves.push(m[1]) if m[0] <= ContestSettings::DEFAULT_PKMN_LEVEL[@rank] }
		# # Remove duplicates (retaining the latest copy of each move)
		# knowable_moves = knowable_moves.reverse
		# knowable_moves |= []
		# knowable_moves = knowable_moves.reverse
		# first_move_index = knowable_moves.length - 4
		# first_move_index = 0 if first_move_index < 0
		# (first_move_index...knowable_moves.length).each do |i|
		  # moves.push(Pokemon::Move.new(knowable_moves[i]))
		# end
		trainer = GameData::ContestTrainer.new({
			:id  				=> ("Trainer"+(position+1).to_s).to_sym,
			:contest_category 	=> ContestFunctions.getCategoryNameShort(@category),
			:contest_rank 		=> ContestFunctions.getRankNameShort(@rank),
			:name 				=> trainerName,
			:character_sprite 	=> trainerInfo[1],
			:trainer_sprite 	=> trainerInfo[2],
			:pokemon_species 	=> species,
			:pokemon_stat_val 	=> cat_val,
			:pokemon_sheen_val 	=> sheen_val,
			:pokemon_moves 		=> pkmn.moves
		})
		trainer.pokemon = pkmn
		return trainer
	end

	def create_contest_trainer_pokemon(rank, category)
		case rank
		when 0
			hashmap = GameData::NORMAL_RANK_CONTEST_POKEMON
			level = 15
		when 1
			hashmap = GameData::SUPER_RANK_CONTEST_POKEMON
			level = 25
		when 2
			hashmap = GameData::HYPER_RANK_CONTEST_POKEMON
			level = 50
		when 3
			hashmap = GameData::MASTER_RANK_CONTEST_POKEMON
			level = 75
		end
		rank_name = ContestFunctions.getCategoryNameShort(category)
		pokemon_list = hashmap[rank_name]

		attempts = 0
		while attempts < 4
			head_pokemon = pokemon_list.sample
			body_pokemon = pokemon_list.sample
			pokemon_species = fusionOf(head_pokemon, body_pokemon)
			break if customSpriteExists(body_pokemon,head_pokemon)
		end
		return Pokemon.new(pokemon_species,level)

	end
	
	def initialOrder
		@roundOrder = [@pokemonOne, @pokemonTwo, @pokemonThree, @playerPokemon]
		case @category
		when 0 then @roundOrder.sort_by! {|p| p.cool}
		when 1 then @roundOrder.sort_by! {|p| p.beauty}
		when 2 then @roundOrder.sort_by! {|p| p.cute}
		when 3 then @roundOrder.sort_by! {|p| p.smart}
		when 4 then @roundOrder.sort_by! {|p| p.tough}
		end
		@roundOrder.reverse!
	end
	
	def setOrder
		heartOrder = @roundOrder
		heartOrder.sort_by! { |p| p.c_total_hearts }
		heartOrder.reverse!
		newOrder = []
		#Scramble
		if @scramble
			newOrder = heartOrder.shuffle
		else
			#Move Up
			@roundOrder.each { |p| newOrder[@nextTurnFirstOrder.find_index(p)] = p if p.c_moveup && !p.c_movedown }
			#Heart Order
			heartOrder.each { |p| newOrder.push(p) if !newOrder.include?(p) && !p.c_movedown}
			#Move Down (ones left over))
			@roundOrder.each { |p| newOrder[@nextTurnLastOrder.find_index(p)] = p if !newOrder.include?(p) }
		end
		@roundOrder.clear
		@roundOrder = newOrder
	end
	
	def setupFirstRound
		@roundOrder.each { |p| p.resetContestVariables}
		@scramble = false
		@crowdPaused = nil		
	end
	
	def setupNextRound
		setOrder
		@roundOrder.each { |p| p.resetContestVariables}

		@nextTurnFirstOrder = [nil,nil,nil,nil]
		@nextTurnLastOrder = [nil,nil,nil,nil]
		@scramble = false
		@crowdPaused = nil		
	end
	
	def getDifficulty(pokemon)
		if pokemon == @pokemonOne
			return @trainerOne.difficulty
		elsif pokemon == @pokemonTwo
			return @trainerTwo.difficulty
		elsif pokemon == @pokemonThree
			return @trainerThree.difficulty
		else
			return 0
		end
	end

end


#====================================================================================
#  PokemonGlobalMetadata
#====================================================================================
class PokemonGlobalMetadata
	attr_accessor :pokemonContest
	attr_accessor :nextContestTrainerOne
	attr_accessor :nextContestTrainerTwo
	attr_accessor :nextContestTrainerThree
	attr_accessor :lastContestWinners
	
	alias contest_global_init initialize unless self.private_method_defined?(:contest_global_init)	
	def initialize
		contest_global_init
		@pokemonContest = nil
		@nextContestTrainerOne = nil
		@nextContestTrainerTwo = nil
		@nextContestTrainerThree = nil
		@lastContestWinners = initContestWinners
	end
	
	def nextContestTrainerOne=(value)
		if value.is_a?(Array)
			value.each_with_index{ |v,i|
				value[i] = GameData::ContestTrainer.try_get(v)
			}
			@nextContestTrainerOne = value
		else
			@nextContestTrainerOne = GameData::ContestTrainer.try_get(value)
		end
	end
	
	def nextContestTrainerTwo=(value)
		if value.is_a?(Array)
			value.each_with_index{ |v,i|
				value[i] = GameData::ContestTrainer.try_get(v)
			}
			@nextContestTrainerTwo = value
		else
			@nextContestTrainerTwo = GameData::ContestTrainer.try_get(value)
		end
	end
	
	def nextContestTrainerThree=(value)
		if value.is_a?(Array)
			value.each_with_index{ |v,i|
				value[i] = GameData::ContestTrainer.try_get(v)
			}
			@nextContestTrainerThree = value
		else
			@nextContestTrainerThree = GameData::ContestTrainer.try_get(value)
		end
	end
	
	def initContestWinners
		return winners = {
			"Category"	=> [[nil,nil,nil,nil,nil], #[Normal, Super, Hyper, Master, Overall]
							[nil,nil,nil,nil,nil],
							[nil,nil,nil,nil,nil],
							[nil,nil,nil,nil,nil],
							[nil,nil,nil,nil,nil]],
			"Rank"		=> [nil,nil,nil,nil], #[Normal, Super, Hyper, Master]
			"Overall"	=> nil
		}
	end
	
	def getLastContestWinner(rank, category)
		winner = @lastContestWinners["Overall"]
		if rank && category
			winner = @lastContestWinners["Category"][category][rank]
		elsif category
			winner = @lastContestWinners["Category"][category][4]
		elsif rank
			winner = @lastContestWinners["Rank"][rank]
		end
		return winner
	end
end

def pbCurrentPokemonContest
	$PokemonGlobal.pokemonContest = PokemonContest.new if !$PokemonGlobal.pokemonContest
	return $PokemonGlobal.pokemonContest
end

def pbShowLastContestWinner(rank: nil, category: nil)
	$PokemonGlobal.lastContestWinners = $PokemonGlobal.initContestWinners if !$PokemonGlobal.lastContestWinners
	rank = ContestFunctions.sanitizeRank(rank) if rank
	category = ContestFunctions.sanitizeCategory(category) if category
	winner = $PokemonGlobal.getLastContestWinner(rank, category)
	if winner
		trainer = winner[0]
		pokemon = winner[1]
		w_rank 	= ContestFunctions.getRankName(winner[2])
		w_cat 	= ContestFunctions.getCategoryName(winner[3])
		sprite = PokemonSprite.new(Viewport.new(0, 0, Graphics.width, Graphics.height))
		sprite.setPokemonBitmap(pokemon)
		sprite.visible = false
		pokemon.play_cry
		if sprite.bitmap
			iconWindow = PictureWindow.new(sprite.bitmap)
			iconWindow.x = (Graphics.width - iconWindow.width) / 2
			iconWindow.y = (Graphics.height - 96 - iconWindow.height)/2
		end
		pbMessage(_INTL("<ac>{1} {2} Contest Winner:\n{3} & {4}</ac>",w_rank,w_cat,trainer.name,pokemon.name))
		iconWindow.dispose
		sprite.dispose
		return true
	else
		return false
	end
end

def pbGetLastContestWinner(rank: nil, category: nil, namesOnly: false)
	$PokemonGlobal.lastContestWinners = $PokemonGlobal.initContestWinners if !$PokemonGlobal.lastContestWinners
	rank = ContestFunctions.sanitizeRank(rank) if rank
	category = ContestFunctions.sanitizeCategory(category) if category
	winner = $PokemonGlobal.getLastContestWinner(rank, category)
	winner = [winner[0].name,winner[1].name,ContestFunctions.getRankNameShort(winner[2]),ContestFunctions.getCategoryNameShort(winner[3])] if namesOnly
	return winner
end

def pbSetLastContestWinner(category,rank,trainer,pokemon)
	$PokemonGlobal.lastContestWinners = $PokemonGlobal.initContestWinners if !$PokemonGlobal.lastContestWinners
	winner = [trainer,pokemon,rank,category]
	$PokemonGlobal.lastContestWinners["Category"][category][rank] = winner
	$PokemonGlobal.lastContestWinners["Category"][category][4] = winner #Overall
	$PokemonGlobal.lastContestWinners["Rank"][rank] = winner
	$PokemonGlobal.lastContestWinners["Overall"] = winner
end

#====================================================================================
#  Pokemon
#====================================================================================
class Pokemon
	attr_accessor :contestVariables
	
	def setupContestVariables(trainer = $Trainer) #Beginning of Contest
		@contestVariables = {
			"Total Score"		=> 0,
			"Intro Score" 		=> 0,
			"Total Hearts" 		=> 0,
			"Round Hearts"		=> 0,
			"Pending Hearts"	=> 0,
			"Spirit"			=> 0,
			"Last Move"			=> nil,
			"Current Move"		=> nil,
			"Move Up"			=> false,
			"Move Down"			=> false,
			"Miss Turn"			=> false,
			"No More Moves"		=> false,
			"Double Next"		=> false,
			"Good Appeal"		=> false,
			"Has Attention"		=> false,
			"Calm"				=> false,
			"Oblivious"			=> false,
			"Easily Startled"	=> false,
			"Startled"			=> false,
			"Nervous"			=> false,
		}
	end
	
	def resetContestVariables #New Round
		@contestVariables["Round Hearts"] = 0
		@contestVariables["Pending Hearts"] = 0
		@contestVariables["Move Up"] = false
		@contestVariables["Move Down"] = false
		@contestVariables["Good Appeal"] = false
		@contestVariables["Calm"] = false
		@contestVariables["Oblivious"] = false
		@contestVariables["Easily Startled"] = false
		@contestVariables["Startled"] = false
		@contestVariables["Nervous"] = false
	end
	
	def clearContestVariables #End of Contest
		@contestVariables = nil
	end
	
	def c_total_score; return (@contestVariables ? @contestVariables["Total Score"] : 0); end 
	def c_total_score=(value); @contestVariables["Total Score"] = value; end 
	def c_intro_score; return (@contestVariables ? @contestVariables["Intro Score"] : 0); end 
	def c_intro_score=(value); @contestVariables["Intro Score"] = value; end 
	def c_total_hearts; return (@contestVariables ? @contestVariables["Total Hearts"] : 0); end 
	def c_total_hearts=(value); @contestVariables["Total Hearts"] = value.clamp(0,27); end 
	def c_round_hearts; return (@contestVariables ? @contestVariables["Round Hearts"] : 0); end 
	def c_round_hearts=(value); @contestVariables["Round Hearts"] = value; end 
	def c_pending_hearts; return (@contestVariables ? @contestVariables["Pending Hearts"] : 0); end 
	def c_pending_hearts=(value); @contestVariables["Pending Hearts"] = value; end 
	def c_spirit; return (@contestVariables ? @contestVariables["Spirit"] : 0); end 
	def c_spirit=(value); @contestVariables["Spirit"] = value.clamp(0,3); end 
	def c_lastmove; return (@contestVariables ? @contestVariables["Last Move"] : nil); end 
	def c_lastmove=(value); @contestVariables["Last Move"] = value; end 
	def c_currentmove; return (@contestVariables ? @contestVariables["Current Move"] : nil); end 
	def c_currentmove=(value); @contestVariables["Current Move"] = value; end 
	def c_moveup; return (@contestVariables ? @contestVariables["Move Up"] : false); end 
	def c_moveup=(value); @contestVariables["Move Up"] = value; end 
	def c_movedown; return (@contestVariables ? @contestVariables["Move Down"] : false); end 
	def c_movedown=(value); @contestVariables["Move Down"] = value; end 
	def c_missturn; return (@contestVariables ? @contestVariables["Miss Turn"] : false); end 
	def c_missturn=(value); @contestVariables["Miss Turn"] = value; end 
	def c_nomoremoves; return (@contestVariables ? @contestVariables["No More Moves"] : false); end 
	def c_nomoremoves=(value); @contestVariables["No More Moves"] = value; end 
	def c_doublenext; return (@contestVariables ? @contestVariables["Double Next"] : false); end 
	def c_doublenext=(value); @contestVariables["Double Next"] = value; end 
	def c_goodappeal; return (@contestVariables ? @contestVariables["Good Appeal"] : false); end 
	def c_goodappeal=(value); @contestVariables["Good Appeal"] = value; end 
	def c_hasattention; return (@contestVariables ? @contestVariables["Has Attention"] : false); end 
	def c_hasattention=(value); @contestVariables["Has Attention"] = value; end 
	def c_calm; return (@contestVariables ? @contestVariables["Calm"] : false); end 
	def c_calm=(value); @contestVariables["Calm"] = value; end 
	def c_oblivious; return (@contestVariables ? @contestVariables["Oblivious"] : false); end 
	def c_oblivious=(value); @contestVariables["Oblivious"] = value; end 
	def c_easilystartled; return (@contestVariables ? @contestVariables["Easily Startled"] : false); end 
	def c_easilystartled=(value); @contestVariables["Easily Startled"] = value; end 
	def c_startled; return (@contestVariables ? @contestVariables["Startled"] : false); end 
	def c_startled=(value); @contestVariables["Startled"] = value; end 
	def c_nervous; return (@contestVariables ? @contestVariables["Nervous"] : false); end 
	def c_nervous=(value); @contestVariables["Nervous"] = value; end 
	def c_orderindex; return pbCurrentPokemonContest.roundOrder.find_index(self); end

	def checkContestCombos(move)
		return false if !@contestVariables["Last Move"]
		oldmove  = @contestVariables["Last Move"].id
		return false if !ContestSettings::COMBOS[oldmove]
		return ContestSettings::COMBOS[oldmove].include?(move.id)
	end
end

#====================================================================================
#  GameData
#====================================================================================
module GameData
	class ContestTrainer
		attr_reader :id
		attr_reader :real_name
		attr_reader :character_sprite
		attr_reader :trainer_sprite
		attr_reader :contest_category
		attr_reader :contest_rank
		attr_reader :difficulty
		attr_accessor :pokemon
		attr_reader :pokemon_species
		attr_reader :pokemon_nickname
		attr_reader :pokemon_stat_val
		attr_reader :pokemon_sheen_val
		attr_reader :pokemon_moves
		attr_reader :pokemon_item
		attr_reader :pokemon_shiny
		attr_reader :pokemon_form
		
		DATA = {}

		extend ClassMethodsSymbols
		include InstanceMethods

		def self.load; end
		def self.save; end

		def initialize(hash)
			@id        			= hash[:id]
			@contest_category 	= hash[:contest_category]
			@contest_rank 		= hash[:contest_rank]
			@difficulty 		= hash[:difficulty] || ContestSettings::DEFAULT_TRAINER_DIFFICULTY[["Normal","Super","Hyper","Master"].find_index(@contest_rank)]
			@pokemon_species 	= hash[:pokemon_species]
			@pokemon_stat_val 	= hash[:pokemon_stat_val]
			@pokemon_sheen_val 	= hash[:pokemon_sheen_val]
			@pokemon_moves 		= hash[:pokemon_moves]
			@pokemon_item		= hash[:pokemon_item] || nil
			@pokemon_shiny		= hash[:pokemon_shiny] || false
			@pokemon_form 		= hash[:pokemon_form] || nil
			@real_name 			= hash[:name] || "Unnamed"
			@character_sprite 	= hash[:character_sprite] || nil
			@trainer_sprite		= hash[:trainer_sprite] || nil
			@pokemon_nickname 	= hash[:pokemon_nickname] || GameData::Species.get(@pokemon_species).real_name
			@pokemon			= hash[:pokemon] || nil
		end

		def name
			return _INTL(@real_name)
		end

		def pokemon_name
			return _INTL(@pokemon_nickname)
		end
		
		def species
			return @pokemon_species
		end
		
		def moves
			return @pokemon_moves
		end
		
		def pokemon_stat_val (category=0)
			if @pokemon_stat_val.is_a?(Array)
				@pokemon_stat_val[category]
			else
				return @pokemon_stat_val
			end
		end
	
		def contest_category
			return [@contest_category] if !@contest_category.is_a?(Array)
			return @contest_category
		end
		
		def difficulty
			return @difficulty || 0
		end
	
	end
  
	class ContestType
		attr_reader :id
		attr_reader :real_name
		attr_reader :long_name
		attr_reader :icon_index
	  
		DATA = {}

		extend ClassMethodsSymbols
		include InstanceMethods

		def self.load; end
		def self.save; end

		def initialize(hash)
			@id           = hash[:id]
			@real_name    = hash[:name]         || "Unnamed"
			@long_name    = hash[:long_name]    || @real_name
			@icon_index   = hash[:icon_index]   || 0
		end
		
		def name
			return _INTL(@real_name)
		end
	
	end
end