#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  AI
#====================================================================================
class PokemonContestTalent_Scene
	def pbSetAIMoves
		@contest.roundOrder.each_with_index { |ai,index|
			next if ai == @contest.playerPokemon
			next if ai.c_nomoremoves || ai.c_missturn
			moves = ai.moves
			if moves.length == 1
				ai.c_currentmove = moves[0]
				next
			end
			position = index + 1
			difficulty = @contest.getDifficulty(ai)
			moveScores = []
			moves.each { |m|
				m = GameData::Move.get(m.id)
				score = 100
				func = m.getContestFunction
				scope = func.scope
				hearts = m.contest_hearts
				round = pbCurrentPokemonContest.round
				#Basic
				if func.id == :Basic then score += (hearts > 3 ? 60 : 30); end
				#Matches Contest type
				if m.is_positive_category?(@contest.category)
					score += 60
				elsif m.is_negative_category?(@contest.category)
					score -= 30
				end
				#Combo Potential
				if ai.c_hasattention && ai.checkContestCombos(m) then score += 60; end
				#Can Be Repeated
				if func.repeat_use then score += 20;
				elsif ai.c_lastmove&.id == m.id then score -= 60; end
				#Random
				if func.random_appeal then score += 20; end
				#Better when done early (Gains Oblivious or Calm, Makes Nervous)
				if func.unnerve || func.avoid_startled_once || func.avoid_startled ||
					(func.depends_on_order && scope == "Earlier")
					case position
					when 1 then score += 60
					when 2 then score += 40
					when 4 then score -= 20
					end
				end
				if func.depends_on_other_appeal
					case position
					when 1 then score += 20
					when 2 then score += 10
					when 4 then score -= 10
					end
				end
				#Best Done First
				if (func.depends_on_order && scope == "First") && position == 1 then score += 60; end
				#Best Done Last
				if (func.depends_on_order && scope == "Last") && position == 4 then score += 60; end
				#Do Next Move Earlier
				if func.do_next_earlier then score += (position == 4 ? 30 : 10); end
				#Do Next Move Later
				if func.do_next_later then score += (position == 4 ? -20 : 20); end
				#No More Moves
				if func.no_more_moves then score += (round == ContestSettings::NUMBER_OF_TALENT_ROUNDS ? 90 : -60); end
				#Double Next
				if func.double_next_appeal then score += (round != ContestSettings::NUMBER_OF_TALENT_ROUNDS ? 40 : -60); end
				#Increase Spirit
				if func.increase_spirit then score += 30; end
				#Better when done later (Startles, easily startled)
				if func.startles || func.easily_startled || (func.depends_on_order && scope == "Later")
					if func.skip_next_move
						case position
						when 4 then score += 30
						when 3 then score += 20
						end
						case round
						when ContestSettings::NUMBER_OF_TALENT_ROUNDS then score += 60
						when 1 then score -= 10
						end
					else
						case position
						when 4 then score += 60
						when 3 then score += 40
						when 1 then score -= 20
						end
					end
				end
				if func.startles && scope == "Attention"
					(position-1).times { |k| score += 30 if @contest.roundOrder[k-1].c_hasattention }
				end
				if func.depends_on_other_type
					if position > 1 then score += 20; end
				end
				#Depends on round
				if func.depends_on_round
					if scope == "Later"
						case round
						when ContestSettings::NUMBER_OF_TALENT_ROUNDS then score += 60
						when 3 then score += 40
						when 2 then score += 20
						when 1 then score -= 20
						end
					elsif scope == "Earlier"
						case round
						when 1 then score += 60
						when 2 then score += 40
						when 3 then score += 20
						when ContestSettings::NUMBER_OF_TALENT_ROUNDS then score -= 20
						end
					end
				end
				#Pause Crowd
				if func.pause_crowd then score += (@contest.crowdEnergy + position >= 5 ? -20 : 20); end
				#Maxes Crowd
				if func.max_crowd then score += 40; end
				#If Raises Crowd
				if func.better_if_increases_crowd then score += ( m.is_positive_category?(@contest.category) ? 40 : -10); end
				#Depends on Crowd
				if func.depends_on_crowd 
					if scope == "Higher" && @contest.crowdEnergy + position > 2 then score += 20; end
					if scope == "Lower"
						case @contest.crowdEnergy + position
						when 1 then score += 60
						when 2 then score += 40
						when 4..5 then score -= 20
						end
					end
					if scope == "Equal"
						case @contest.crowdEnergy + position
						when 4..5 then score += 60
						when 3 then score += 40
						when 1..2 then score -= 20
						end
					end
				end
				#Changes Others Spirit
				if func.decrease_other_spirit
					if scope == "Before"
						case position
						when 4 then score += 20
						when 3 then score += 10
						when 1 then score -= 20
						end
						(position-1).times { |k| score += 40 if @contest.roundOrder[k].c_spirit > 0 }
					elsif scope == "After"
						case position
						when 1 then score += 20
						when 2 then score += 10
						when 4 then score -= 20
						end
						(4-position).times { |k| score += 40 if @contest.roundOrder[k+position].c_spirit > 0 }
					end
				end
				#Depends on Spirit
				if func.depends_on_spirit
					if scope == "Equal"
						score += (ai.c_spirit > 0 ? ai.c_spirit * 20 : -30)
					end
				end
				#Scramble
				if func.scramble_order && round != ContestSettings::NUMBER_OF_TALENT_ROUNDS then score += 30; end
				moveScores.push(score)
			}
			
			best = moveScores.index(moveScores.max)
			winner = best if difficulty > 90 || (pbStdDev(moveScores) >= 100 && rand(10) != 0)
			if !winner
				worst = moveScores.index(moveScores.min)
				secondWorst = moveScores.index(moveScores.clone.sort[1]) if moveScores.length > 2
				moveScores[worst] = nil if difficulty > 25
				moveScores[secondWorst] = nil if secondWorst && difficulty > 75 
				while !winner
					r = rand(moveScores.length) while !r || moveScores[r].nil?
					if difficulty <= 25
						#Always Random
						winner = r
					elsif difficulty <= 50
						#Never Worst + 1 extra roll for better score
						winner = r
						newR = rand(moveScores.length) while !newR || moveScores[newR].nil?
						winner = newR if moveScores[newR] > moveScores[r]
					elsif difficulty <= 75
						#Never Worst + 2 extra rolls for better score
						winner = r
						2.times {
							newR = rand(moveScores.length) while !newR || moveScores[newR].nil?
							winner = newR if moveScores[newR] > moveScores[r]
						}
					else
						#Never Worst or Second Worst + 2 extra rolls for better score
						winner = r
						2.times {
							newR = rand(moveScores.length) while !newR || moveScores[newR].nil?
							winner = newR if moveScores[newR] > moveScores[r]
						}
					end
				end
			end
			ai.c_currentmove = moves[winner]
		}
	end

	def pbStdDev(choices)
		sum = 0
		n   = 0
		choices.each do |c|
			sum += c
			n   += 1
		end
		return 0 if n < 2
		mean = sum.to_f / n.to_f
		varianceTimesN = 0
		choices.each do |c|
			next if c <= 0
			deviation = c.to_f - mean
			varianceTimesN += deviation*deviation
		end
		# Using population standard deviation
		# [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
		return Math.sqrt(varianceTimesN/n)
	end	
	
end