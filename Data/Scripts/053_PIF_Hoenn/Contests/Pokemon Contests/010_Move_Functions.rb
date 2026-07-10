#====================================================================================
#  Move Functions
#====================================================================================	
module GameData
	class Move
		
		def getFunctionContestDescription
			return GameData::ContestMoveFunction.try_get(@contest_function_code)&.description || ""
		end
		
		def canBeUsedRepeatedly?
			return GameData::ContestMoveFunction.try_get(@contest_function_code)&.repeat_use
		end
		
		def getContestFunction
			return GameData::ContestMoveFunction.try_get(@contest_function_code)
		end
		
	end
	
	class ContestMoveFunction
		attr_reader :id
		attr_reader :description
		attr_reader :scope
		
		attr_reader :repeat_use
		attr_reader :skip_next_move
		attr_reader :no_more_moves
		attr_reader :random_appeal
		attr_reader :double_next_appeal
		
		attr_reader :startles
		attr_reader :unnerve
		
		attr_reader :pause_crowd
		attr_reader :max_crowd
		attr_reader :reset_crowd
		attr_reader :depends_on_crowd
		attr_reader :better_if_increases_crowd
		attr_reader :always_excites_crowd
		
		attr_reader :avoid_startled
		attr_reader :avoid_startled_once
		attr_reader :easily_startled
		
		attr_reader :depends_on_other_type
		
		attr_reader :depends_on_other_appeal
	
		attr_reader :depends_on_spirit
		attr_reader :increase_spirit
		attr_reader :decrease_other_spirit
		
		attr_reader :depends_on_order
		attr_reader :scramble_order
		attr_reader :do_next_earlier
		attr_reader :do_next_later
		
		attr_reader :depends_on_round
		
		attr_reader :steal_attention
		
		DATA = {}

		extend ClassMethodsSymbols
		include InstanceMethods

		def self.load; end
		def self.save; end
		def initialize(hash)
			@id        			= hash[:id]
			@description			= hash[:description] || ""
			@scope				= hash[:scope] || nil

			@repeat_use 			= hash[:repeat_use] || false
			@skip_next_move		= hash[:skip_next_move] || false
			@no_more_moves 		= hash[:no_more_moves] || false
			@random_appeal 		= hash[:random_appeal] || false
			@double_next_appeal 	= hash[:double_next_appeal] || false

			@startles 			= hash[:startles] || false
			@unnerve 				= hash[:unnerve] || false

			@pause_crowd 			= hash[:pause_crowd] || false
			@max_crowd 			= hash[:max_crowd] || false
			@reset_crowd 			= hash[:reset_crowd] || false
			@depends_on_crowd 	= hash[:depends_on_crowd] || false
			@better_if_increases_crowd 	= hash[:better_if_increases_crowd] || false
			@always_excites_crowd 	= hash[:always_excites_crowd] || false

			@avoid_startled 		= hash[:avoid_startled] || false
			@avoid_startled_once	= hash[:avoid_startled_once] || false
			@easily_startled		= hash[:easily_startled] || false

			@depends_on_other_type 	= hash[:depends_on_other_type] || false

			@depends_on_other_appeal 	= hash[:depends_on_other_appeal] || false

			@depends_on_spirit 	= hash[:depends_on_spirit] || false
			@increase_spirit	 	= hash[:increase_spirit] || false
			@decrease_other_spirit	= hash[:decrease_other_spirit] || false

			@depends_on_order 	= hash[:depends_on_order] || false
			@scramble_order 		= hash[:scramble_order] || false
			@do_next_earlier 		= hash[:do_next_earlier] || false
			@do_next_later 		= hash[:do_next_later] || false

			@depends_on_round 	= hash[:depends_on_round] || false

			@steal_attention		= hash[:steal_attention] || false
		end	
	end
end

#--------------------------------------------------------------------------------
# Function Definitions
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Basic move, no other effects
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :Basic,
	:description		=> _INTL("A highly appealing move.")
})
#--------------------------------------------------------------------------------
# Can be used on consecutive turns without penalty
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #015 
	:id  				=> :CanUseRepeatedly, 
	:description		=> _INTL("Can be used repeatedly without boring the judge."),
	:repeat_use			=> true
})
#--------------------------------------------------------------------------------
# Will either do 1, 2, 4, or 8 appeal
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #020 
	:id  				=> :AppealIsRandom,
	:description		=> _INTL("Increases the users appeal by varying amounts."),
	:random_appeal		=> true
})
#--------------------------------------------------------------------------------
# Applys jamming value to all others that have appealed
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #005 
	:id  				=> :StartleOthersThatMoved,
	:description		=> _INTL("Startles those that have made appeals."),
	:startles			=> true
})
#--------------------------------------------------------------------------------
# Applys jamming value to all others that have appealed, does +3 extra to those
# that used the same category type of move
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #006 
	:id  				=> :StartleOthersThatUsedSameType,
	:description		=> _INTL("Startles Pokémon that used a move of the same type."),
	:startles			=> true,
	:scope				=> "Same Type"
})
#--------------------------------------------------------------------------------
# Applys jamming value to all others that have appealed, does extra equal to half
# that Pokemon's appeal value (minimum 1)
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #012 
	:id  				=> :StartleOthersGoodAppeals,
	:description		=> _INTL("Startles all Pokémon, more so those that made good appeals."),
	:startles			=> true,
	:scope				=> "Good"
})
#--------------------------------------------------------------------------------
# Applys jamming value to all others that have appealed, does +4 extra to those
# that have the judge's attention
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #007 
	:id  				=> :StartleOtherWithJudgeAttention,
	:description		=> _INTL("Startles the Pokémon that has the judge's attention."),
	:startles			=> true,
	:scope				=> "Attention"
})
#--------------------------------------------------------------------------------
# Applys jamming value to the Pokemon that just moved before the user.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #008 
	:id  				=> :StartleOtherInFront,
	:description		=> _INTL("Startles the last Pokémon to act before the user."),
	:startles			=> true,
	:scope				=> "One"
})
#--------------------------------------------------------------------------------
# Applys jamming value to all others that have appealed. User can't act next turn
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #016 
	:id  				=> :StartleOthersMissNextTurn,
	:description		=> _INTL("Startles all other Pokémon. User cannot act in the next turn."),
	:startles			=> true,
	:skip_next_move		=> true
})
#--------------------------------------------------------------------------------
# Attempts to cause all remaining Pokemon to be nervous
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #017 
	:id  				=> :MakeAllOthersAfterUserNervous,
	:description		=> _INTL("Makes the remaining Pokémon nervous."),
	:unnerve			=> true,
	:scope				=> "All"
})
#--------------------------------------------------------------------------------
# Attempts to cause the next Pokemon to be nervous
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :MakeOtherJustAfterUserNervous,
	:description		=> _INTL("Makes the Pokémon just after the user nervous."),
	:unnerve			=> true,
	:scope				=> "One"
})
#--------------------------------------------------------------------------------
# Avoids being startled once during this turn
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #001 
	:id  				=> :AvoidBeingStartledOnce,
	:description		=> _INTL("Can avoid being startled by others once."),
	:avoid_startled_once	=> true
})
#--------------------------------------------------------------------------------
# Avoids being startled for the rest of this turn
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #002 
	:id  				=> :AvoidBeingStartled,
	:description		=> _INTL("Can avoid being startled by others until the turn ends."),
	:avoid_startled		=> true
})
#--------------------------------------------------------------------------------
# User is more easily startled, doubling jamming that would apply to them this turn
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #010 
	:id  				=> :EasilyStartled,
	:description		=> _INTL("After this move, the user is more easily startled."),
	:easily_startled	=> true
})
#--------------------------------------------------------------------------------
# Can no longer make moves for the rest of the contest.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #018 
	:id  				=> :NoMoreMoves,
	:description		=> _INTL("Makes a great appeal, but prevents the user from taking further contest moves."),
	:no_more_moves		=> true
})
#--------------------------------------------------------------------------------
# Adds +1 to the Pokemon's spirit (aka Condition)
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #004  
	:id  				=> :GetPumpedUp,
	:description		=> _INTL("Ups the user's spirit. Helps prevent nervousness."),
	:increase_spirit	=> true
})
#--------------------------------------------------------------------------------
# Will double the next appear the user does (only doubles the base appeal value)
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #027 
	:id  				=> :DoubleNextAppeal,
	:description		=> _INTL("User earns double the score in it's next appeal."),
	:double_next_appeal => true
})
#--------------------------------------------------------------------------------
# Crowd excitement won't go up the rest of the round, after this appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #013 
	:id  				=> :PauseCrowdExcitement,
	:description		=> _INTL("Temporarily stops the audience from growing excited."),
	:pause_crowd		=> true
})
#--------------------------------------------------------------------------------
# Maxes the crowd excitement (making it 5).
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #031 
	:id  				=> :MaxesCrowdExcitement,
	:description		=> _INTL("Gets the audience going!"),
	:max_crowd		 	=> true
})
#--------------------------------------------------------------------------------
# Makes the crowd excitement 0.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :ResetsCrowdExcitement,
	:description		=> _INTL("Settles the audience down."),
	:reset_crowd		=> true
})
#--------------------------------------------------------------------------------
# Does more appeal the higher the crowd excitement is.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #019 
	:id  				=> :DependsOnCrowdExcitementHigher,
	:description		=> _INTL("Works better the more the audience is excited."),
	:depends_on_crowd	=> true,
	:scope				=> "Higher"
})
#--------------------------------------------------------------------------------
# Does more appeal the lower the crowd excitement is.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #038 
	:id  				=> :DependsOnCrowdExcitementLower,
	:description		=> _INTL("Works better the less the audience is excited."),
	:depends_on_crowd	=> true,
	:scope				=> "Lower"
})
#--------------------------------------------------------------------------------
# Adds the current crowd excitement value to the appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #033 
	:id  				=> :EqualsCrowdExcitement,
	:description		=> _INTL("The appeal depends on the audience's excitement."),
	:depends_on_crowd	=> true,
	:scope				=> "Equal"
})
#--------------------------------------------------------------------------------
# If the move increases the crowd's excitement, does +3 appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #036 
	:id  				=> :DoesBetterIfIncreasesCrowdExcitement,
	:description		=> _INTL("Works best if the audience's excitement goes up."),
	:better_if_increases_crowd	=> true
})
#--------------------------------------------------------------------------------
# Will always add to the crowd's excitement meter.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :AlwaysExcitesCrowd,
	:description		=> _INTL("Excites the audience in any kind of contest."),
	:always_excites_crowd	=> true
})
#--------------------------------------------------------------------------------
# The worse the previous Pokemon's appeal, the more appeal is added to this move.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #009 
	:id  				=> :DependsOnAppealInFront,
	:description		=> _INTL("Affected by how well the previous Pokémon's move went."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Lower"
})
#--------------------------------------------------------------------------------
# If the previous Pokemon's appeal was 2 or less, does +6 appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #029  
	:id  				=> :DoesGreatIfOtherInFrontDidPoor,
	:description		=> _INTL("Works better if the last appeal did poorly."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Poor"
})
#--------------------------------------------------------------------------------
# If the previous Pokemon's appeal was 4 or more, does +6 appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #040  
	:id  				=> :DoesGreatIfOtherInFrontDidGreat,
	:description		=> _INTL("Works better if the last appeal was good."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Good"
})
#--------------------------------------------------------------------------------
# Makes the move's appeal equal to half the previous Pokemon's appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #030  
	:id  				=> :DoesHalfAppealValueAsOtherInFront,
	:description		=> _INTL("Earns half as much as the previous Pokémon's appeal."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Equal Half"
})
#--------------------------------------------------------------------------------
# Makes the move's appeal equal to the previous Pokemon's appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #034 
	:id  				=> :DoesSameAppealValueAsOtherInFront,
	:description		=> _INTL("Earns the same amount as the previous Pokémon's appeal."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Equal"
})
#--------------------------------------------------------------------------------
# Adds the previous Pokemon's appeal to this move.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #037 
	:id  				=> :GainAppealValueOfOtherInFront,
	:description		=> _INTL("Adds the score of the previous Pokémon's appeal to yours."),
	:depends_on_other_appeal	=> true,
	:scope				=> "Add"
})
#--------------------------------------------------------------------------------
# Makes the spirit (aka Condition) of all Pokemon that made appeals 0.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #032 
	:id  				=> :LowerSpiritOfOthersThatMoved,
	:description		=> _INTL("Lowers the spirit of those that made appeals."),
	:decrease_other_spirit	=> true,
	:scope				=> "Before"
})
#--------------------------------------------------------------------------------
# Makes the spirit (aka Condition) of all Pokemon that haven't appealed yet 0.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :LowerSpiritOfOthersAfterUser,
	:description		=> _INTL("Lowers the spirit of the remaining Pokémon."),
	:decrease_other_spirit	=> true,
	:scope				=> "After"
})
#--------------------------------------------------------------------------------
# If the previous Pokemon's move matches this move's type, then does +4 appeal.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #025 
	:id  				=> :DoesGreatWhenMatchesLastTurnMoveType,
	:description		=> _INTL("Works well if it is the same type as the move used by the last Pokémon."),
	:depends_on_other_type	=> true,
	:scope				=> "Same"
})
#--------------------------------------------------------------------------------
# Does more appeal the higher the user's spirit (aka Condition) is.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #035 
	:id  				=> :DependsOnUsersSpirit,
	:description		=> _INTL("Works well if the user's spirit is good."),
	:depends_on_spirit	=> true,
	:scope				=> "Equal"
})
#--------------------------------------------------------------------------------
# Does +5 appeal if it's the first move of the round.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #014 
	:id  				=> :DoesGreatWhenFirst,
	:description		=> _INTL("The appeal works great if performed first."),
	:depends_on_order	=> true,
	:scope				=> "First"
})
#--------------------------------------------------------------------------------
# Does +5 appeal if it's the last move of the round.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #021 
	:id  				=> :DoesGreatWhenLast,
	:description		=> _INTL("The appeal works great if performed last."),
	:depends_on_order	=> true,
	:scope				=> "Last"
})
#--------------------------------------------------------------------------------
# Does more appeal the earlier in a round the move is used.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :DoesBetterEarlierPerformed,
	:description		=> _INTL("The appeal works better the earlier it is performed in a turn."),
	:depends_on_order	=> true,
	:scope				=> "Earlier"
})
#--------------------------------------------------------------------------------
# Does more appeal the later in a round the move is used.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #023 
	:id  				=> :DoesBetterLaterPerformed,
	:description		=> _INTL("The appeal works better the later it is performed in a turn."),
	:depends_on_order	=> true,
	:scope				=> "Later"
})
#--------------------------------------------------------------------------------
# Does more appeal the earlier the round is in a contest.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :DependsOnRoundNumberLower,
	:description		=> _INTL("Appeal is better the earlier the round."),
	:depends_on_round	=> true,
	:scope				=> "Earlier"
})
#--------------------------------------------------------------------------------
# Does more appeal the later the round is in a contest.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #039 
	:id  				=> :DependsOnRoundNumberHigher,
	:description		=> _INTL("Appeal is better the later the round."),
	:depends_on_round	=> true,
	:scope				=> "Later"
})
#--------------------------------------------------------------------------------
# Scrambles the turn order for next round.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #024 
	:id  				=> :ScrambleOrderNextTurn,
	:description		=> _INTL("Scrambles the order of appeals on the next turn."),
	:scramble_order		=> true
})
#--------------------------------------------------------------------------------
# The user will move first next round (unless another Pokemon uses the same kind
# of move, in which case it will be shifted to second, and so on).
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #003 
	:id  				=> :DoNextMoveEarlier,
	:description		=> _INTL("Causes the user to move earlier on the next turn."),
	:do_next_earlier	=> true
})
#--------------------------------------------------------------------------------
# The user will move last next round (unless another Pokemon uses the same kind
# of move, in which case it will be shifted to second to last, and so on).
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ #026 
	:id  				=> :DoNextMoveLater,
	:description		=> _INTL("Causes the user to move later on the next turn."),
	:do_next_later		=> true
})
#--------------------------------------------------------------------------------
# All other Pokemon that currently have the judge's attention for combos lose
# the judge's attention.
#--------------------------------------------------------------------------------
GameData::ContestMoveFunction.register({ 
	:id  				=> :StealsAttention,
	:description		=> _INTL("Makes the judge expect little of other contestants."),
	:steal_attention	=> true
})

#--------------------------------------------------------------------------------
# Code - DO NOT MAKE EDITS HERE (Unless adding new custom functionalty...)
#--------------------------------------------------------------------------------

class PokemonContestTalent_Scene
	
	def pbUseMove(position)
		pkmn = @contest.roundOrder[position-1]
		move = pkmn.c_currentmove ? GameData::Move.get(pkmn.c_currentmove.id) : nil
		noMove = false
		if move
			move_name = move.name
			#atself = move.target == GameData::Target.get(:User)
			atself = move.target == :User
			type = move.contest_type
		end
		if pkmn.c_nomoremoves || !move
			pbContestMessage(_INTL("{1} watches the others.\\wtnp[30]", pkmn.name))
			noMove = true
		
		elsif pkmn.c_missturn
			pbContestMessage(_INTL("{1} took a break.\\wtnp[30]", pkmn.name))
			pkmn.c_missturn = false
			noMove = true
			
		else
			if pkmn.c_nervous
				pbContestMessage(_INTL("{1} is nervous.\\wtnp[30]", pkmn.name))
				# Check for nervousness, 30% base chance
				chance = 30
				chance += 15 if pkmn.c_hasattention
				chance -= 5 * pkmn.c_spirit
				if rand(100)<chance
					pbContestMessage(_INTL("{1} is too nervous to move!\\wtnp[30]", pkmn.name))
					noMove = true
				else
					moveHeart = (move.getContestFunction.random_appeal ? [1,2,4,8][rand(4)] : move.contest_hearts)
					pkmn.c_pending_hearts = moveHeart
					if pkmn.c_doublenext; pkmn.c_pending_hearts *= 2; pkmn.c_doublenext = false; end
					pbContestMessage(_INTL("{1} tried to show its appeal with {2}!\\wtnp[30]", pkmn.name, move_name))
					pbPlayAnimation(move.id, atself)
					pbApplyMoveEffects(pkmn, move, position)
				end
			else
				moveHeart = (move.getContestFunction.random_appeal ? [1,2,4,8][rand(4)] : move.contest_hearts)
				pkmn.c_pending_hearts = moveHeart
				if pkmn.c_doublenext; pkmn.c_pending_hearts *= 2; pkmn.c_doublenext = false; end
				pbContestMessage(_INTL("{1} tried to show its appeal with {2}!\\wtnp[30]", pkmn.name, move_name))
				pbPlayAnimation(move.id, atself)
				pbApplyMoveEffects(pkmn, move, position)
			end
		end
		if noMove
			
			pkmn.c_hasattention = false
			pkmn.c_lastmove = pkmn.c_currentmove = nil
		else
			round = pbCurrentPokemonContest.round
			if round > 1 && move && !move.canBeUsedRepeatedly? && pkmn.c_lastmove && pkmn.c_currentmove && pkmn.c_currentmove == pkmn.c_lastmove
				#Disappointed Judge
				pbShowJudgeIcon("bored")
				pkmn.c_pending_hearts -= 2
				pbContestMessage(_INTL("{1} disappointed the Judge by repeating the move.\\wtnp[30]", pkmn.name))
				pbApplyHeartsChange(pkmn)
			end
			if round > 1 && pkmn.c_hasattention && move && pkmn.checkContestCombos(move)
				pkmn.c_pending_hearts += (ContestSettings::COMBOS_DOUBLE_APPEAL ? (moveHeart ? moveHeart : move.contest_hearts) : 3)
				#Combo Judge
				pbShowJudgeIcon("combo")
				pbContestMessage(_INTL("The combo went over well!\\wtnp[30]"))
				pkmn.c_hasattention = false
				pbApplyHeartsChange(pkmn)
				
			end
		
			pkmn.c_hasattention = false
		
			if round < 5 && move && move.startsContestCombo 
				#Anticipation Judge
				pbShowJudgeIcon("potential")
				pbContestMessage(_INTL("Anticipation is swelling for a combo on the next turn!\\wtnp[30]"))
				pkmn.c_hasattention = true
				pbUpdateContestantInfo(pkmn)
			end
			
			#Crowd Effects here
			pbShowApplauseMeter
			pbWait(4)
			if @contest.isCrowdPaused?(pkmn) || move.is_neutral_category?(@contest.category)
				#nothing
				pbWait(20)
			elsif move.getContestFunction.reset_crowd && @contest.crowdEnergy > 0
				@contest.crowdEnergy = 0
				pbContestMessage(_INTL("The audience settled down.\\wtnp[30]"))
				updateApplauseMeter
				pbWait(20)
			elsif move.is_positive_category?(@contest.category) || move.getContestFunction.always_excites_crowd
				@contest.crowdEnergy += 1
				@contest.crowdEnergy = 5 if move.getContestFunction.max_crowd
				if @contest.crowdEnergy >= 5
					pkmn.c_pending_hearts += 6
					pbContestMessage(_INTL("{1}'s {2} got the audience going!\\wtnp[30]", pkmn.name,pbContestCatName(@contest.category)))
					pbSEPlay("Contest crowd")
					animateCrowd
					updateApplauseMeter
					pbWaitCrowd(6)
					pbApplyHeartsChange(pkmn)
					pbWaitCrowd(40)
				else
					pkmn.c_pending_hearts += 1
					pbContestMessage(_INTL("{1}'s {2} really excited the audience!\\wtnp[30]", pkmn.name,pbContestCatName(move.contest_type_position)))
					pbSEPlay("Contest crowd")
					animateCrowd
					updateApplauseMeter
					pbWaitCrowd(6)
					pbApplyHeartsChange(pkmn)
					pbWaitCrowd(40)
				end
				if move.getContestFunction.better_if_increases_crowd
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("Exciting the audience improved {1}'s appeal even more!\\wtnp[30]", pkmn.name))
					pbWaitCrowd(6)
					pbApplyHeartsChange(pkmn)
				end
			elsif move.is_negative_category?(@contest.category)
				@contest.crowdEnergy -= 1 if @contest.crowdEnergy > 0
				pkmn.c_pending_hearts -= 1
				pbContestMessage(_INTL("{1}'s show of {2} didn't go over very well with this audience.\\wtnp[30]", pkmn.name,pbContestCatName(move.contest_type_position)))
				updateApplauseMeter
				pbWait(6)
				pbApplyHeartsChange(pkmn)
				pbWait(20)
			else
				#nothing
				pbWait(20)
			end
			
			deanimateCrowd
			pbHideApplauseMeter
			pbWait(6)
			
			if @contest.crowdEnergy >= 5
				@contest.crowdEnergy = 0
				updateApplauseMeter
			end
			pkmn.c_lastmove = pkmn.c_currentmove
			pkmn.c_currentmove = nil
		end
		pbWait(3)
		
	end
	
	def pbApplyMoveEffects(pkmn, move, position)
		pkmn.c_pending_hearts += pkmn.c_spirit
		pbWait(6)
		pbApplyHeartsChange(pkmn)
	
		func = move.getContestFunction
		scope = func.scope
		#Startling others
		if func.startles
			affected = 0
			if position == 1
			else
				for i in 0...position-1
					next if @contest.roundOrder[i].c_lastmove.nil?
					if scope.nil? || scope == "Good" || scope == "Attention" || scope == "Same Type"
						@contest.roundOrder[i].c_startled = true
						affected += 1
					# elsif scope == "Same Type"
						# if GameData::Move.get(@contest.roundOrder[i].c_lastmove.id).contest_type  == move.contest_type 
							# @contest.roundOrder[i].c_startled = true
							# affected += 1
						# end
					# elsif scope == "Attention"
						# if @contest.roundOrder[i].c_hasattention
							# @contest.roundOrder[i].c_startled = true
							# affected += 1
						# end
					elsif scope == "One"
						if i == position-2
							@contest.roundOrder[i].c_startled = true
							affected += 1
						end
					end
				end
			end	
			if affected != 0
				pbUpdateAllContestantInfo
				pbSEPlay("Contest status effect add")
			end
			pbContestMessage(_INTL("It tried to startle the other Pokémon!\\wtnp[30]"))
			if affected == 0
				pbContestMessage(_INTL("But it failed!\\wtnp[30]"))
			else
				for i in 0...position-1
					p = @contest.roundOrder[i]
					next if !p.c_startled
					if p.c_oblivious
						pbContestMessage(_INTL("{1} managed to avoid seeing it.\\wtnp[30]", p.name))
						p.c_startled = false
						pbSEPlay("Contest status effect remove")
						pbUpdateContestantInfo(p)
					elsif p.c_calm
						pbContestMessage(_INTL("{1} managed to avert its gaze.\\wtnp[30]", p.name))
						p.c_startled = false
						p.c_calm = false
						pbSEPlay("Contest status effect remove")
						pbUpdateContestantInfo(p)
					else
						p.c_pending_hearts -= move.contest_jam
						p.c_pending_hearts -= move.contest_jam if p.c_easilystartled
						p.c_pending_hearts -= 4 if scope == "Attention" && p.c_hasattention
						p.c_pending_hearts -= 3 if scope == "Same Type" && p.c_lastmove && 
							GameData::Move.get(p.c_lastmove.id).contest_type == move.contest_type
						#p.c_pending_hearts -= 3 if scope == "Good" && p.c_round_hearts > 3
						p.c_pending_hearts -= [1,(p.c_round_hearts/2).round].max if scope == "Good"
						if p.c_pending_hearts >= -1
							pbContestMessage(_INTL("{1} looked down out of distraction.\\wtnp[30]", p.name))
						elsif p.c_pending_hearts >= -3
							pbContestMessage(_INTL("{1} turned back out of distraction.\\wtnp[30]", p.name))
						else
							pbContestMessage(_INTL("{1} couldn't help leaping up.\\wtnp[30]", p.name))
						end
						pbWait(6)
						pbApplyHeartsChange(p)
						p.c_startled = false
						pbUpdateContestantInfo(p)
					end
				end
			end
		end
		#Unnerving others
		if func.unnerve
			if position == 4
				pbContestMessage(_INTL("It tried to unnerve the other Pokémon!\\wtnp[30]"))
				pbContestMessage(_INTL("But it failed!\\wtnp[30]"))
			elsif scope == "All"
				for i in position..3
					@contest.roundOrder[i].c_nervous = true
				end
				pbContestMessage(_INTL("It tried to unnerve the Pokémon waiting for their turns!\\wtnp[30]"))
				pbUpdateAllContestantInfo
			elsif scope == "One"
				@contest.roundOrder[position].c_nervous = true
				pbUpdateAllContestantInfo
				pbContestMessage(_INTL("It tried to unnerve the next Pokémon waiting for its turn!\\wtnp[30]"))
			end
		end
		#User Status
		if func.double_next_appeal
			pkmn.c_doublenext = true
			pbContestMessage(_INTL("It started getting prepared for its next appeal.\\wtnp[30]"))
		end
		if func.increase_spirit
			if pkmn.c_spirit < 3
				pkmn.c_spirit += 1
				pbContestMessage(_INTL("{1} got even more pumped up than usual!\\wtnp[30]", pkmn.name))
				pbSEPlay("Contest spirit up")
				pbUpdateContestantInfo(pkmn)
			else
				pbContestMessage(_INTL("{1}'s spirit won't go any higher!\\wtnp[30]", pkmn.name))
			end
		end
		if func.no_more_moves
			pkmn.c_nomoremoves = true
			pbContestMessage(_INTL("{1} will be unable to use any moves after this!\\wtnp[30]", pkmn.name))
			pbUpdateContestantInfo(pkmn)
		end
		if func.easily_startled
			pkmn.c_easilystartled = true
			pbContestMessage(_INTL("It became very aware of the Pokémon going on after it.\\wtnp[30]"))
		end
		if func.avoid_startled
			pkmn.c_oblivious = true
			pbContestMessage(_INTL("It is completely oblivious to the other Pokémon's moves.\\wtnp[30]"))
			pbUpdateContestantInfo(pkmn)
		end
		if func.avoid_startled_once
			pkmn.c_calm = true
			pbContestMessage(_INTL("It is feeling pretty calm and collected now.\\wtnp[30]"))
			pbUpdateContestantInfo(pkmn)
		end		
		#Changes Crowd
		if func.pause_crowd
			if move.is_positive_category?(@contest.category) && !@contest.isCrowdPaused?(pkmn)
				@contest.crowdPaused = pkmn
				pbContestMessage(_INTL("{1} attracted the audience's full attention!\\wtnp[30]", pkmn.name))
			else
				pbContestMessage(_INTL("{1} tried to dazzle the audience!\\wtnp[30]", pkmn.name))
				pbContestMessage(_INTL("But it failed!\\wtnp[30]"))
			end
		end
		#Depends on Crowd
		if func.depends_on_crowd
			crowd = @contest.crowdEnergy
			if scope == "Equal" && crowd > 0
				pkmn.c_pending_hearts += crowd
				pbContestMessage(_INTL("{1} matched the audience's excitement!\\wtnp[30]", pkmn.name))
			elsif scope == "Higher"
				case crowd
				when 0
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				when 1..2
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				when 3
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				when 4
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				end
			elsif scope == "Lower"
				case crowd
				when 4
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				when 2..3
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				when 1
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				when 0
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				end
			end
		end
		#Depends on other appeals
		if func.depends_on_other_appeal
			other = @contest.roundOrder[position-2].c_round_hearts if position > 1 && @contest.roundOrder[position-2].c_lastmove
			if ["Lower","Poor","Good"].include?(scope) && other
				if other <= 2
					if scope == "Poor" || scope == "Lower"
						pkmn.c_pending_hearts += 6
						pbContestMessage(_INTL("{1} totally outshone the last Pokémon! What appeal!\\wtnp[30]", pkmn.name))
					elsif scope == "Good"
						pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
					end
				elsif other <=3
					if scope == "Poor" || scope == "Good" 
						pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
					elsif scope == "Lower"
						pkmn.c_pending_hearts += 3
						pbContestMessage(_INTL("{1} was on par with the last Pokémon.\\wtnp[30]", pkmn.name))
					end
				else
					if scope == "Poor" || scope == "Lower" 
						pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
					elsif scope == "Good"
						pkmn.c_pending_hearts += 6
						pbContestMessage(_INTL("{1} showed off as well as the last Pokémon! What appeal!\\wtnp[30]", pkmn.name))
					end
				end				
			elsif scope == "Equal Half" && other
				pkmn.c_pending_hearts = (other/2).round - move.contest_hearts
				pbContestMessage(_INTL("The previous appeal influenced {1}'s appeal!\\wtnp[30]", pkmn.name))
			elsif scope == "Equal" && other
				pkmn.c_pending_hearts = other - move.contest_hearts
				pbContestMessage(_INTL("The previous appeal influenced {1}'s appeal!\\wtnp[30]", pkmn.name))
			elsif scope == "Add" && other
				pkmn.c_pending_hearts += other
				pbContestMessage(_INTL("The previous appeal influenced {1}'s appeal!\\wtnp[30]", pkmn.name))	
			end
		end
		if func.depends_on_other_type
			if scope == "Same"
				if position > 1 && @contest.roundOrder[position-2].c_lastmove && 
						GameData::Move.get(@contest.roundOrder[position-2].c_lastmove.id).contest_type == move.contest_type 
					pkmn.c_pending_hearts += 4
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				end
			end
		end
		#Lower spirit of others
		if func.decrease_other_spirit
			pbContestMessage(_INTL("It tried to taunt the Pokémon that are feeling pumped up!\\wtnp[30]"))
			if scope == "Before"
				if position == 1
					pbContestMessage(_INTL("But it failed!\\wtnp[30]"))
				else
					affected = 0
					for i in 0...position-1
						p = @contest.roundOrder[i]
						if p.c_spirit > 0 && p.c_lastmove
							p.c_spirit = 0
							affected += 1
							pbSEPlay("Contest jam")
							pbUpdateContestantInfo(p)
						end
					end
					pbContestMessage(_INTL("But it failed!\\wtnp[30]")) if affected == 0
				end
			elsif scope == "After"
				if position == 4
					pbContestMessage(_INTL("But it failed!\\wtnp[30]"))
				else
					affected = 0
					for i in position..3
						p = @contest.roundOrder[i]
						if p.c_spirit > 0
							p.c_spirit = 0
							affected += 1
							pbSEPlay("Contest jam")
							pbUpdateContestantInfo(p)
						end
					end
					pbContestMessage(_INTL("But it failed!\\wtnp[30]")) if affected == 0
				end
			end
		end
		#Depends on spirit
		if func.depends_on_spirit
			if scope == "Equal"
				case pkmn.c_spirit
				when 0
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				when 1
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				when 2
					pkmn.c_pending_hearts += 4
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				when 3
					pkmn.c_pending_hearts += 6
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				end
			end
		end
		#Depends on turn order
		if func.depends_on_order
			case position
			when 1
				if scope == "First" || scope == "Earlier"
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				elsif scope == "Last" || scope == "Later"
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				end
			when 2
				if scope == "First" || scope == "Last" 
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				elsif scope == "Earlier"
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				end
			when 3
				if scope == "First" || scope == "Last" 
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				elsif scope == "Earlier"
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				end
			when 4
				if scope == "First" || scope == "Earlier"
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				elsif scope == "Last" || scope == "Later"
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				end
			end 
		end
		if func.depends_on_round
			round = pbCurrentPokemonContest.round
			max = ContestSettings::NUMBER_OF_TALENT_ROUNDS
			mid = (max/2).ceil
			case round
			when 1
				if scope == "Earlier"
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				end
			when 2...mid
				if scope == "Earlier"
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				end
			when mid...max
				if scope == "Earlier"
					pkmn.c_pending_hearts += 2
					pbContestMessage(_INTL("{1} showed off a little of its appeal.\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pkmn.c_pending_hearts += 3
					pbContestMessage(_INTL("{1} showed off its appeal pretty well!\\wtnp[30]", pkmn.name))
				end
			when max
				if scope == "Earlier"
					pbContestMessage(_INTL("{1} didn't show off its appeal well.\\wtnp[30]", pkmn.name))
				elsif scope == "Later"
					pkmn.c_pending_hearts += 5
					pbContestMessage(_INTL("{1} showed off its appeal fantastically well!\\wtnp[30]", pkmn.name))
				end
			end
		end
		#Change turn order
		if func.scramble_order
			@contest.scramble = true
			#Confused judge
			pbShowJudgeIcon("scramble")
			pbContestMessage(_INTL("{1} scrambled the order for the next turn!\\wtnp[30]", pkmn.name))
			pbUpdateAllContestantInfo
		end
		if func.do_next_earlier && !@contest.scramble
			pkmn.c_moveup = true
			@contest.nextTurnFirstOrder.rotate!(-1)
			@contest.nextTurnFirstOrder[0] = pkmn
			#Turn Order Judge
			pbShowJudgeIcon("turn1")
			pbContestMessage(_INTL("{1} moved up in line so that it can go earlier next turn.\\wtnp[30]", pkmn.name))
			pbUpdateAllContestantInfo
		end
		if func.do_next_later && !@contest.scramble
			pkmn.c_movedown = true
			@contest.nextTurnLastOrder.rotate!
			@contest.nextTurnLastOrder[3] = pkmn
			#Turn Order Judge
			pbShowJudgeIcon("turn4")
			pbContestMessage(_INTL("{1} moved back in line so that it can go later next turn.\\wtnp[30]", pkmn.name))
			pbUpdateAllContestantInfo
		end
		#Steal attention
		if func.steal_attention
			@contest.roundOrder.each { |p|
				next if p == pkmn
				p.c_hasattention = false
			}
			#Anticipation Judge
			pbShowJudgeIcon("potential")
			pbContestMessage(_INTL("{1} stole the Judge's attention from others!\\wtnp[30]", pkmn.name))
		end
		
		pbWait(6)
		pbApplyHeartsChange(pkmn)
		
		if func.skip_next_move
			pkmn.c_missturn = true
			pbContestMessage(_INTL("{1} can't appeal next turn!\\wtnp[30]", pkmn.name))
		end
	end
	
	def pbApplyHeartsChange(pkmn)
		return if pkmn.c_pending_hearts == 0
		until pkmn.c_pending_hearts == 0 do
			if pkmn.c_pending_hearts > 0
				pkmn.c_pending_hearts -= 1
				if pkmn.c_round_hearts < 16
					pkmn.c_round_hearts += 1
					pitch = 97 + 3*pkmn.c_round_hearts
					pbUpdateContestantInfo(pkmn)
					pbSEPlay("Contest heart",nil,pitch)
					pbWaitCrowd(6)
				end
			else
				pkmn.c_pending_hearts += 1
				if pkmn.c_round_hearts > -16
					pkmn.c_round_hearts -= 1
					pbUpdateContestantInfo(pkmn)
					pbSEPlay("Contest jam")
					pbWait(6)
				end
			end
		end
	end
	
end
