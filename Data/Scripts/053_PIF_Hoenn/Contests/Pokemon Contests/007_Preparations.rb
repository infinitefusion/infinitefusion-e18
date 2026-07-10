#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Main Command
#====================================================================================
def pbPokemonContest(rank: nil, category: nil, pokemon: nil)
	receptionistEvent = $game_map.get_events_with_name("Receptionist").first
	pbPrepPokemonContest(rank, category, pokemon, receptionistEvent)
	return if !$PokemonGlobal.pokemonContest
	ContestFunctions.bringPlayerToContestHall(receptionistEvent)
	pbCurrentPokemonContest.initEvents(rank)
	pbScrollMap(8, 2, 4)
	pbScrollMap(4, 3, 4)
	pbCurrentPokemonContest.pbIntroductionRound
	pbCurrentPokemonContest.pbTalentRound
	pbCurrentPokemonContest.pbResults
	pbEndPokemonContest
end

#====================================================================================
#  Setup In Lobby
#====================================================================================
def pbPrepPokemonContest(rank = nil, category = nil, pokemon = nil, receptionist_event = nil)
	event_id = receptionist_event.id
	echoln event_id
	if $Trainer.party.size <=0
		pbCallBubDown(2,event_id)
		pbMessage(_INTL("Oh, you don't have any Pokémon!"))
		pbCallBubDown(2,event_id)
		pbMessage(_INTL("Please come back when you have a Pokémon."))
		return
	end
	# if ContestSettings::REQUIRE_CONTEST_PASS_ITEM && !hasItem?(:CONTESTPASS)
	# 	pbMessage(_INTL("Oh, you don't have a Contest Pass!"))
	# 	pbMessage(_INTL("Please come back when you have a Contest Pass."))
	# 	return
	# end
	rank = ContestFunctions.sanitizeRank(rank)
	category = ContestFunctions.sanitizeCategory(category)
	pbCallBubDown(2,event_id)
	pbMessage(_INTL("Hello!"))
	pbCallBubDown(2,event_id)
	pbMessage(_INTL("This is the reception counter for Pokémon Contests."))
	cmds = [_INTL("Enter"),_INTL("Cancel")]
	if rank || category
		rankName = ContestFunctions.getRankName(rank,true)
		catName = ContestFunctions.getCategoryName(category,true)
		pbCallBubDown(2,event_id)
		pbMessage(_INTL("We're currently accepting registrations for \\C[1]{1}{2}\\C[0]Pokémon Contests.",rankName,catName))
		pbCallBubDown(2,event_id)
		choice = pbMessage(_INTL("Would you like to enter your Pokémon in a {1}{2}Contest?",rankName,catName),cmds,-1)	
	else
		pbCallBubDown(2,event_id)
		choice = pbMessage(_INTL("Would you like to enter your Pokémon in a Contest?"),cmds,-1)
	end
	pbCallBubDown(2,event_id)
	return pbMessage(_INTL("We hope you will participate another time.")) if choice < 0 || choice == 1
	#Choose Category
	if !category
		cmds_c = [_INTL("{1} Contest",pbContestCatName(0)),
							_INTL("{1} Contest",pbContestCatName(1)),
							_INTL("{1} Contest", pbContestCatName(2)),
							_INTL("{1} Contest", pbContestCatName(3)),
							_INTL("{1} Contest",pbContestCatName(4)),
							_INTL("Exit")]

		pbCallBubDown(2,event_id)
		cat = pbMessage(_INTL("Which Contest would you like to enter?"), cmds_c, -1)
		pbCallBubDown(2,event_id)
		return pbMessage(_INTL("We hope you will participate another time.")) if cat < 0 || cat == 5
		category = cat
		pbSet(VAR_CONTEST_CATEGORY,category)
	end
	#Choose Rank
	if !rank
		cmds_r = [_INTL("Normal Rank"), _INTL("Super Rank"), _INTL("Hyper Rank"), _INTL("Master Rank"), _INTL("Exit")]
		pbCallBubDown(2,event_id)
		rnk = pbMessage(_INTL("Which Rank would you like to enter?"), cmds_r, -1)
		pbCallBubDown(2,event_id)
		return pbMessage(_INTL("We hope you will participate another time.")) if rnk < 0 || rnk == 4
		rank = rnk
	end
	#Choose Pokemon
	loop do
		if !pokemon
			pbCallBubDown(2,event_id)
			pbMessage(_INTL("Which Pokémon would you like to enter?"))
			if rank == 0
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false)})
				pkmn = pbGet(1)
			else
				ribbon = ContestSettings::CONTEST_RIBBONS[category][rank-1]
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false) && p.hasRibbon?(ribbon)})
				pkmn = pbGet(1)
			end
		end
		pokemon = pkmn
		if pokemon < 0
			if pbConfirmMessage(_INTL("Cancel participation?"))
				pbCallBubDown(2,event_id)
				return pbMessage(_INTL("We hope you will participate another time."))
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end	
		#Pokemon has Ribbon
		if $Trainer.party[pokemon].hasRibbon?(ContestSettings::CONTEST_RIBBONS[category][rank])
			pbCallBubDown(2,event_id)
			pbMessage(_INTL("Oh, that Ribbon..."))
			pbCallBubDown(2,event_id)
			pbMessage(_INTL("Your {1} has won this Contest before, hasn't it?", $Trainer.party[pokemon].name))
			pbCallBubDown(2,event_id)
			if pbConfirmMessage(_INTL("Would you like to enter it in this Contest anyway?"))
				
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end
		if pbConfirmMessage(_INTL("Enter {1} in the Contest?",$Trainer.party[pokemon].name))
			#return pbMessage(_INTL("We hope you will participate another time."))
		else
			#pbMessage(_INTL("Which Pokémon would you like to enter?"))
			pokemon = nil
			next
		end	
		break
	end
	# if pbConfirmMessage("Cancel participation?")
		# return pbMessage(_INTL("We hope you will participate another time."))
	# else
		# pbMessage(_INTL("Which Pokémon would you like to enter?"))
		# pokemon = nil
		# next
	# end
	pbCallBubDown(2,event_id)
	pbMessage(_INTL("Okay, your {1} will be entered in this Contest.", $Trainer.party[pokemon].name))
	pbCallBubDown(2,event_id)
	pbMessage(_INTL("{1} is Entry Number 4. The Contest will begin shortly.", $Trainer.party[pokemon].name))
	pbCurrentPokemonContest.set(rank, category, pokemon, ContestFunctions.getHallMapInfo(rank, category), ContestFunctions.getReturnMapInfo(rank, category))
	return true
end

#====================================================================================
#  End the Contest
#====================================================================================

def pbEndPokemonContest
	ContestFunctions.bringPlayerToLobby
	$PokemonGlobal.pokemonContest = nil
	$PokemonGlobal.nextContestTrainerOne = nil
	$PokemonGlobal.nextContestTrainerTwo = nil
	$PokemonGlobal.nextContestTrainerThree = nil
	
end

#====================================================================================
#  Misc Contest Functions
#====================================================================================

module ContestFunctions
	module_function
	
	def bringPlayerToContestHall(guideEvent)
		map = $game_map.map_id
		doors = $game_map.get_events_with_name("ContestDoor")
		# Front Desk Guide
		pbMoveRoute(guideEvent,[PBMoveRoute::Left,
			PBMoveRoute::Left,PBMoveRoute::TurnDown])
		pbWaitForCharacterMove(guideEvent)
		pbWait(5)
		doors.length.times{ |i| $game_self_switches[[map, doors[i].id, 'A']] = true; $game_map.need_refresh = true} # Front Desk Door
		pbCallBubDown(2,guideEvent.id)
		pbMessage(_INTL("Please, follow me."))
		pbMoveRoute(guideEvent,[PBMoveRoute::Up])
		pbMoveRoute($game_player,[PBMoveRoute::Left,PBMoveRoute::Left, PBMoveRoute::Up, PBMoveRoute::Up, PBMoveRoute::TurnDown])
		pbWaitForCharacterMove($game_player)
		doors.length.times{ |i| $game_self_switches[[map, doors[i].id, 'A']] = false; $game_map.need_refresh  = true} # Front Desk Door
		pbWait(5)
		pbMoveRoute(guideEvent,[PBMoveRoute::Turn180])
		pbWaitForCharacterMove(guideEvent)
		pbMoveRoute(guideEvent,[PBMoveRoute::Right,PBMoveRoute::TurnLeft])
		pbWait(1)
		pbMoveRoute($game_player,[PBMoveRoute::Up,PBMoveRoute::TurnRight])
		pbWaitForCharacterMove($game_player)
		pbCallBub(2,guideEvent.id)
		pbMessage(_INTL("Please, go in through here. Good luck!"))
		pbMoveRoute($game_player,[PBMoveRoute::Up])
		pbWaitForCharacterMove($game_player)
		hallInfo = pbCurrentPokemonContest.hallMapInfo
		self.transfer(*hallInfo,8)
		$scene.reset_map(true)
	end


	def bringPlayerToLobby
		returnInfo = pbCurrentPokemonContest.returnMapInfo
		self.transfer(*returnInfo)

	end

	def set_switch(map, event, switch='A', set=true)
		$game_self_switches[[map, event, switch]] = set
		return unless set
		$game_map.need_refresh = set
		loop do
			break if !$game_self_switches[[map, event, switch]]
			pbWait(1)
		end
	end
		
	def transfer(id, x, y, dir)
		if $scene.is_a?(Scene_Map)
			pbFadeOutIn {
				$game_temp.player_transferring   = true
				$game_temp.transition_processing = true
				$game_temp.player_new_map_id    = id
				$game_temp.player_new_x         = x
				$game_temp.player_new_y         = y
				$game_temp.player_new_direction = dir
				pbWait(35)
				$scene.transfer_player
				pbWait(5)
			}
		end
	end
	
	def getHallMapInfo(rank, category)
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][category]
		echoln get
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][0] if !get
		echoln get
		return get
	end
	
	def getReturnMapInfo(rank, category)
		get = ContestSettings::LOBBY_MAP_COORDINATES[rank][category]
		get = ContestSettings::DEFAULT_RETURN_COORDINATES if !get
		return get
	end
	
	def sanitizeRank(rank)
		return nil if rank == nil
		return rank if rank.is_a?(Integer) && [0,1,2,3].include?(rank)
		rank = rank.to_s if rank.is_a?(Symbol)
		rank = rank.upcase if rank.is_a?(String)
		case rank
		when "NORMAL" then rank = 0
		when "SUPER" then rank = 1
		when "HYPER" then rank = 2
		when "MASTER" then rank = 3
		else rank = nil; end		
		return rank
	end
	
	def sanitizeCategory(category)
		return nil if category == nil
		return category if category.is_a?(Integer) && [0,1,2,3,4].include?(category)
		return GameData::ContestType.get(category).icon_index if category.is_a?(Symbol)
		category = category.upcase if category.is_a?(String)
		GameData::ContestType.each { |type|
			return type.icon_index if [type.name.upcase,type.long_name.upcase].include?(category)
		}
		return nil
	end
	
	def getRankName(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal Rank","Super Rank","Hyper Rank","Master Rank"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getRankNameShort(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal","Super","Hyper","Master"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryName(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.long_name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryNameShort(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
end

def pbContestCatName(int,spaceAfter=false)
	return ContestFunctions.getCategoryName(int,spaceAfter)
end

def pbContestCatShortName(int,spaceAfter=false)
	return ContestFunctions.getCategoryNameShort(int,spaceAfter)
end

# class ContestTrainerSprite
# 	def initialize(event, map, _viewport)
# 		@event     = event
# 		@id		   = event.id
# 		@map       = map
# 		@disposed  = false
# 		@event.character_name = ""
# 		set_event_graphic   # Set the event's graphic
# 	end
#
# 	def dispose
# 		@event    = nil
# 		@map      = nil
# 		@disposed = true
# 	end
#
# 	def disposed?
# 		@disposed
# 	end
#
# 	def set_event_graphic
# 		if @id == @contestTrainers[0].id
# 			@event.character_name = pbCurrentPokemonContest.trainerOne.character_sprite
# 		elsif @id == @contestTrainers[1].id
# 			@event.character_name = pbCurrentPokemonContest.trainerTwo.character_sprite
# 		elsif @id == @contestTrainers[2].id
# 			@event.character_name = pbCurrentPokemonContest.trainerThree.character_sprite
# 		end
# 	end
#
# 	def randomize_contest_trainer_appearance(event_id)
# 		sprite = get_spritecharacter_for_event(event_id)
# 		appearance= get_random_appearance
#
# 		#todo: Replace the hat & clothes by random hats/clothes of the correct contest category in higher ranks
#
# 		sprite.setSpriteToAppearance(appearance)
# 		echoln "set appearance for #{event_id}"
# 	end
#
# 	def update
# 		set_event_graphic
# 	end
# end

#
# Events.onSpritesetCreate += proc { |_sender,e|
# 	proc { |spriteset, viewport|
# 		map = spriteset.map
# 		map.events.each do |event|
# 			next if !event[1].name[/contesttrainer/i]
# 			echoln "on spritesetcreate"
# 			spriteset.addUserSprite(ContestTrainerSprite.new(event[1], map, viewport))
# 		end
# 	}
# }


# EventHandlers.add(:on_new_spriteset_map, :add_contest_trainer_graphics,
#   proc { |spriteset, viewport|
#     map = spriteset.map
#     map.events.each do |event|
#       next if !event[1].name[/contesttrainer/i]
#       spriteset.addUserSprite(ContestTrainerSprite.new(event[1], map, viewport))
#     end
#   }
# )