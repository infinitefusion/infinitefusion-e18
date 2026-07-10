#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Results
#====================================================================================	
class PokemonContest

	def pbResults
		pbMoveRoute(@mcEvent,[PBMoveRoute::Right,PBMoveRoute::Right,PBMoveRoute::TurnDown])
		pbMoveRoute(@judgeEvent,[PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::TurnDown])
		pbWaitForCharacterMove(@judgeEvent)
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("That's it for the Talent Round!"))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("Thank you all for a most wonderful display of quality appeals!"))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("This concludes all judging! Thank you for your fine efforts!"))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("Now, all that remains is the pulse-pounding proclamation of the winner."))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("The Judge looks ready to make the announcement!"))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("We will now declare the winner!"))
		
		#27 hearts is max counted for Talent
		#convert 27 to 320...
		pokemonOne.contestVariables["Total Hearts"] = (320.0*pokemonOne.contestVariables["Total Hearts"]/27).floor
		pokemonTwo.contestVariables["Total Hearts"] = (320.0*pokemonTwo.contestVariables["Total Hearts"]/27).floor
		pokemonThree.contestVariables["Total Hearts"] = (320.0*pokemonThree.contestVariables["Total Hearts"]/27).floor
		playerPokemon.contestVariables["Total Hearts"] = (320.0*playerPokemon.contestVariables["Total Hearts"]/27).floor
		pbWait(15)
		pbFadeOutIn {
			scene = PokemonContestResults_Scene.new(self)
			screen = PokemonContestResults_Screen.new(scene, self)
			pbBGMPlay(ContestSettings::BGM_CONTEST_RESULTS_FILE)
			ret = screen.pbStartScreen
		}
		pbBGMPlay(ContestSettings::BGM_CONTEST_WON_FILE)
		pbWait(15)
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("{1} & {2}, congratulations!",@winningTrainer.name,@winningPokemon.name))
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("Please come up and accept your prize!"))
		if @winningTrainer == @trainerOne
			event = @contestTrainers[0]
			pbMoveRoute(event,[PBMoveRoute::Up,PBMoveRoute::Right,
				PBMoveRoute::Right,PBMoveRoute::Up])
			pbWaitForCharacterMove(event)
		elsif @winningTrainer == @trainerTwo
			event = @contestTrainers[1]
			pbMoveRoute(event,[PBMoveRoute::Up,PBMoveRoute::Up])
			pbWaitForCharacterMove(event)
		elsif @winningTrainer == @trainerThree
			event = @contestTrainers[2]
			pbMoveRoute(event,[PBMoveRoute::Up,PBMoveRoute::Left,
				PBMoveRoute::Left,PBMoveRoute::Up])
			pbWaitForCharacterMove(event)
		else
			pbMoveRoute($game_player,[PBMoveRoute::Up,PBMoveRoute::Left,
				PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::Up])
			pbWaitForCharacterMove($game_player)
		end
		ribbon = GameData::Ribbon.get(ContestSettings::CONTEST_RIBBONS[@category][@rank])
		pbCallBubDown(2,@mcEvent.id)
		pbMessage(_INTL("We confer on you the {1} as your prize!", ribbon.name)) if !@playerWin
		$Trainer.stats.initializeContestStats unless $Trainer.stats.contest_stats_initialized?
		if @playerWin
			if @playerPokemon.hasRibbon?(ribbon)
				pbCallBubDown(2,@mcEvent.id)
				pbMessage(_INTL("As {1} already has the \\c[1]{2}\\c[0], we offer a complimentary prize!", @playerPokemon.name, ribbon.name))
				pbReceiveItem(GameData::Item.get(ContestSettings::CONTEST_OTHER_PRIZE[@category][@rank]))
			else
				pbCallBubDown(2,@mcEvent.id)
				pbMessage(_INTL("We confer on you the {1} as your prize!", ribbon.name))
				@playerPokemon.giveRibbon(ribbon)
				pbCallBubDown(2,@mcEvent.id)
				pbMessage(_INTL("\\me[{1}]{2} received the \\c[1]{3}\\c[0]!\\wtnp[30]", "Item get", @playerPokemon.name, ribbon.name))	
			end
			$Trainer.stats.pokemon_contests_won_total += 1
			$Trainer.stats.pokemon_contests_won_category[@category] += 1
			$Trainer.stats.pokemon_contests_won_rank[@rank] += 1
			$Trainer.stats.pokemon_contests_won_category_rank[@category][@rank] += 1
		end
		pbSetLastContestWinner(@category,@rank,@winningTrainer.clone,@winningPokemon.clone)
		$Trainer.stats.pokemon_contests_participated_total += 1
		$Trainer.stats.pokemon_contests_participated_category[@category] += 1
		$Trainer.stats.pokemon_contests_participated_rank[@rank] += 1
		$Trainer.stats.pokemon_contests_participated_category_rank[@category][@rank] += 1
		pbWait(40)
	end

end


class PokemonContestResults_Scene
	def initialize(contest)
		@contest = contest
	end
	
	def pbStartScene
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["background"] = IconSprite.new(0, 0, @viewport)	
		@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Contest/resultsbg"))
		@sprites["pokemonOne"] = PokemonIconSprite.new(@contest.pokemonOne, @viewport)
		@sprites["pokemonOne"].setOffset(PictureOrigin::Center)
		@sprites["pokemonOne"].x = 56
		@sprites["pokemonOne"].y = 48
		@sprites["pokemonTwo"] = PokemonIconSprite.new(@contest.pokemonTwo, @viewport)
		@sprites["pokemonTwo"].setOffset(PictureOrigin::Center)
		@sprites["pokemonTwo"].x = 56
		@sprites["pokemonTwo"].y = 48 + 64
		@sprites["pokemonThree"] = PokemonIconSprite.new(@contest.pokemonThree, @viewport)
		@sprites["pokemonThree"].setOffset(PictureOrigin::Center)
		@sprites["pokemonThree"].x = 56
		@sprites["pokemonThree"].y = 48 + 64*2
		@sprites["pokemonPlayer"] = PokemonIconSprite.new(@contest.playerPokemon, @viewport)
		@sprites["pokemonPlayer"].setOffset(PictureOrigin::Center)
		@sprites["pokemonPlayer"].x = 56
		@sprites["pokemonPlayer"].y = 48 + 64*3
		@sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
		@sprites["msgwindow"].visible  = false
		@sprites["msgwindow"].viewport = @viewport
		pbDeactivateWindows(@sprites)
		pbRefresh
		pbFadeInAndShow(@sprites)
	end
	
	def pbScene
		pbDisplay(_INTL("First, the results of the Introduction Round!")) 
		pbShowIntroRoundBars
		pbDisplay(_INTL("Now, the results of the Talent Round!")) 
		pbShowTalentRoundBars
		pbDisplay(_INTL("And the winner is...")) 
		pbShowPlaces
		position = @contest.winningPosition
		trainerName = @contest.winningTrainer.name
		pokemonName = @contest.winningPokemon.name
		pbDisplay(_INTL("Entry Number {1}: {2} & {3}! Congratulations!",position,pokemonName,trainerName))
	end
	
	def pbEndScene
		@sprites["barBitmap"].dispose
		pbFadeOutAndHide(@sprites) { pbUpdate }
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbDisplay(msg, brief = false)
		UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
	end

	def pbUpdate
		pbUpdateIntroBars
		pbUpdateTalentBars
		pbUpdatePlaces
		pbUpdateSpriteHash(@sprites)
	end
	
	def pbRefresh

	end
	
	def pbShowIntroRoundBars
		@barx = 96
		@bary = 58
		@barMaxWidth = 192 #128 for 3 rounds, future
		@maxX = []
		max = 320.0
		@sprites["barBitmap"] = AnimatedBitmap.new("Graphics/Pictures/Contest/overlay_results")
		@sprites["pokemonOneScoreIntro"] = Sprite.new(@viewport)
		@sprites["pokemonOneScoreIntro"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonOneScoreIntro"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonOneScoreIntro"].src_rect.width = 0
		@sprites["pokemonOneScoreIntro"].x = @barx
		@sprites["pokemonOneScoreIntro"].y = @bary
		@maxX[0] = (@barMaxWidth*(@contest.pokemonOne.contestVariables["Intro Score"]/max)).round
		
		@sprites["pokemonTwoScoreIntro"] = Sprite.new(@viewport)
		@sprites["pokemonTwoScoreIntro"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonTwoScoreIntro"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonTwoScoreIntro"].src_rect.width = 0
		@sprites["pokemonTwoScoreIntro"].x = @barx
		@sprites["pokemonTwoScoreIntro"].y = @bary + 64
		@maxX[1] = (@barMaxWidth*(@contest.pokemonTwo.contestVariables["Intro Score"]/max)).round
	
		@sprites["pokemonThreeScoreIntro"] = Sprite.new(@viewport)
		@sprites["pokemonThreeScoreIntro"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonThreeScoreIntro"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonThreeScoreIntro"].src_rect.width = 0
		@sprites["pokemonThreeScoreIntro"].x = @barx
		@sprites["pokemonThreeScoreIntro"].y = @bary + 64*2
		@maxX[2] = (@barMaxWidth*(@contest.pokemonThree.contestVariables["Intro Score"]/max)).round
		
		@sprites["pokemonPlayerScoreIntro"] = Sprite.new(@viewport)
		@sprites["pokemonPlayerScoreIntro"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonPlayerScoreIntro"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonPlayerScoreIntro"].src_rect.width = 0
		@sprites["pokemonPlayerScoreIntro"].x = @barx
		@sprites["pokemonPlayerScoreIntro"].y = @bary + 64*3
		@maxX[3] = (@barMaxWidth*(@contest.playerPokemon.contestVariables["Intro Score"]/max)).round
				
		@animatingIntros = true	
		pbUpdate
	end
	
	def pbShowTalentRoundBars
		@maxX_t = []
		max = 320.0
		@sprites["barBitmap"] = AnimatedBitmap.new("Graphics/Pictures/Contest/overlay_results")
		@sprites["pokemonOneScoreTalent"] = Sprite.new(@viewport)
		@sprites["pokemonOneScoreTalent"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonOneScoreTalent"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonOneScoreTalent"].src_rect.width = 0
		@sprites["pokemonOneScoreTalent"].src_rect.y = 12
		@sprites["pokemonOneScoreTalent"].x = @barx + @maxX[0]
		@sprites["pokemonOneScoreTalent"].y = @bary
		@maxX_t[0] = (@barMaxWidth*(@contest.pokemonOne.contestVariables["Total Hearts"]/max)).round
		
		@sprites["pokemonTwoScoreTalent"] = Sprite.new(@viewport)
		@sprites["pokemonTwoScoreTalent"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonTwoScoreTalent"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonTwoScoreTalent"].src_rect.width = 0
		@sprites["pokemonTwoScoreTalent"].src_rect.y = 12
		@sprites["pokemonTwoScoreTalent"].x = @barx + @maxX[1]
		@sprites["pokemonTwoScoreTalent"].y = @bary + 64
		@maxX_t[1] = (@barMaxWidth*(@contest.pokemonTwo.contestVariables["Total Hearts"]/max)).round
	
		@sprites["pokemonThreeScoreTalent"] = Sprite.new(@viewport)
		@sprites["pokemonThreeScoreTalent"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonThreeScoreTalent"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonThreeScoreTalent"].src_rect.width = 0
		@sprites["pokemonThreeScoreTalent"].src_rect.y = 12
		@sprites["pokemonThreeScoreTalent"].x = @barx + @maxX[2]
		@sprites["pokemonThreeScoreTalent"].y = @bary + 64*2
		@maxX_t[2] = (@barMaxWidth*(@contest.pokemonThree.contestVariables["Total Hearts"]/max)).round
		
		@sprites["pokemonPlayerScoreTalent"] = Sprite.new(@viewport)
		@sprites["pokemonPlayerScoreTalent"].bitmap = @sprites["barBitmap"].bitmap
		@sprites["pokemonPlayerScoreTalent"].src_rect.height = @sprites["barBitmap"].height / 3
		@sprites["pokemonPlayerScoreTalent"].src_rect.width = 0
		@sprites["pokemonPlayerScoreTalent"].src_rect.y = 12
		@sprites["pokemonPlayerScoreTalent"].x = @barx + @maxX[3]
		@sprites["pokemonPlayerScoreTalent"].y = @bary + 64*3
		@maxX_t[3] = (@barMaxWidth*(@contest.playerPokemon.contestVariables["Total Hearts"]/max)).round
				
		@animatingTalents = true
		pbUpdate
	end
	
	def pbUpdateIntroBars #updateHPAnimation
		return if !@animatingIntros
		while @animatingIntros
			#return if @frames % 5 != 0
			perFrameOne = 4 #[@maxX[0] / Graphics.frame_rate, 1].max
			perFrameTwo = 4 #[@maxX[1] / Graphics.frame_rate, 1].max
			perFrameThree = 4 #[@maxX[2] / Graphics.frame_rate, 1].max
			perFrameFour = 4 #[@maxX[3] / Graphics.frame_rate, 1].max
			
			@sprites["pokemonOneScoreIntro"].src_rect.width += perFrameOne
			@sprites["pokemonTwoScoreIntro"].src_rect.width += perFrameTwo
			@sprites["pokemonThreeScoreIntro"].src_rect.width += perFrameThree
			@sprites["pokemonPlayerScoreIntro"].src_rect.width += perFrameFour
			@sprites["pokemonOneScoreIntro"].src_rect.width = @maxX[0] if @sprites["pokemonOneScoreIntro"].src_rect.width > @maxX[0]
			@sprites["pokemonTwoScoreIntro"].src_rect.width = @maxX[1] if @sprites["pokemonTwoScoreIntro"].src_rect.width > @maxX[1]
			@sprites["pokemonThreeScoreIntro"].src_rect.width = @maxX[2] if @sprites["pokemonThreeScoreIntro"].src_rect.width > @maxX[2]
			@sprites["pokemonPlayerScoreIntro"].src_rect.width = @maxX[3] if @sprites["pokemonPlayerScoreIntro"].src_rect.width > @maxX[3]
			@animatingIntros = false if @sprites["pokemonOneScoreIntro"].src_rect.width >= @maxX[0] &&
				@sprites["pokemonTwoScoreIntro"].src_rect.width >= @maxX[1] &&
				@sprites["pokemonThreeScoreIntro"].src_rect.width >= @maxX[2] &&
				@sprites["pokemonPlayerScoreIntro"].src_rect.width >= @maxX[3]
			Graphics.update
			pbUpdateSpriteHash(@sprites)
		end
	end
	
	def pbUpdateTalentBars #updateHPAnimation
		return if !@animatingTalents
		while @animatingTalents
			perFrameOne = 4
			perFrameTwo = 4
			perFrameThree = 4
			perFrameFour = 4
			
			@sprites["pokemonOneScoreTalent"].src_rect.width += perFrameOne
			@sprites["pokemonTwoScoreTalent"].src_rect.width += perFrameTwo
			@sprites["pokemonThreeScoreTalent"].src_rect.width += perFrameThree
			@sprites["pokemonPlayerScoreTalent"].src_rect.width += perFrameFour
			@sprites["pokemonTwoScoreTalent"].src_rect.width = @maxX_t[1] if @sprites["pokemonTwoScoreTalent"].src_rect.width > @maxX_t[1]
			@sprites["pokemonOneScoreTalent"].src_rect.width = @maxX_t[0] if @sprites["pokemonOneScoreTalent"].src_rect.width > @maxX_t[0]
			@sprites["pokemonThreeScoreTalent"].src_rect.width = @maxX_t[2] if @sprites["pokemonThreeScoreTalent"].src_rect.width > @maxX_t[2]
			@sprites["pokemonPlayerScoreTalent"].src_rect.width = @maxX_t[3] if @sprites["pokemonPlayerScoreTalent"].src_rect.width > @maxX_t[3]
			@animatingTalents = false if @sprites["pokemonOneScoreTalent"].src_rect.width >= @maxX_t[0] &&
				@sprites["pokemonTwoScoreTalent"].src_rect.width >= @maxX_t[1] &&
				@sprites["pokemonThreeScoreTalent"].src_rect.width >= @maxX_t[2] &&
				@sprites["pokemonPlayerScoreTalent"].src_rect.width >= @maxX_t[3]
			Graphics.update
			pbUpdateSpriteHash(@sprites)
		end
	end

	def pbShowPlaces
		@contest.pokemonOne.contestVariables["Total Score"] = @contest.pokemonOne.c_intro_score + @contest.pokemonOne.c_total_hearts
		@contest.pokemonTwo.contestVariables["Total Score"] = @contest.pokemonTwo.c_intro_score + @contest.pokemonTwo.c_total_hearts
		@contest.pokemonThree.contestVariables["Total Score"] = @contest.pokemonThree.c_intro_score + @contest.pokemonThree.c_total_hearts
		@contest.playerPokemon.contestVariables["Total Score"] = @contest.playerPokemon.c_intro_score + @contest.playerPokemon.c_total_hearts
		totals = [@contest.pokemonOne.c_total_score,@contest.pokemonTwo.c_total_score,@contest.pokemonThree.c_total_score,@contest.playerPokemon.c_total_score]
		if totals.clone.uniq.length != totals.length #handling duplicates
			totals.each_with_index{ |v,i|
				next if i==3
				p1 = nil
				p2 = nil
				if totals[i+1] && v == totals[i+1]
					case i
					when 0 then p1 = @contest.pokemonOne
					when 1 then p1 = @contest.pokemonTwo
					when 2 then p1 = @contest.pokemonThree
					end
					case i+1
					when 1 then p2 = @contest.pokemonTwo
					when 2 then p2 = @contest.pokemonThree
					when 3 then p2 = @contest.playerPokemon
					end
				elsif totals[i+2] && v == totals[i+2]
					case i
					when 0 then p1 = @contest.pokemonOne
					when 1 then p1 = @contest.pokemonTwo
					end
					case i+2
					when 2 then p2 = @contest.pokemonThree
					when 3 then p2 = @contest.playerPokemon
					end
				elsif totals[i+3] && v == totals[i+3]
					p1 = @contest.pokemonOne
					p2 = @contest.playerPokemon
				end
				next if !p1 || !p2
				if (p1.c_total_hearts > p2.c_total_hearts) && (p2.c_total_hearts > 0) then p2.contestVariables["Total Hearts"] -= 1;
				elsif  (p1.c_total_hearts < p2.c_total_hearts) && (p1.c_total_hearts > 0) then p1.contestVariables["Total Hearts"] -= 1;
				elsif (p1.c_intro_score > p2.c_intro_score) && (p2.c_intro_score > 0) then p2.contestVariables["Intro Score"] -= 1;
				elsif (p1.c_intro_score < p2.c_intro_score) && (p1.c_intro_score > 0) then p1.contestVariables["Intro Score"] -= 1;
				elsif rand(2) == 0 
					if p1.c_intro_score > 0 then p1.contestVariables["Intro Score"] -= 1;
					else p1.contestVariables["Intro Score"] += 1; end
				else 
					if p2.c_intro_score > 0 then p2.contestVariables["Intro Score"] -= 1;
					else p2.contestVariables["Intro Score"] += 1; end
				end
			}
			@contest.pokemonOne.contestVariables["Total Score"] = @contest.pokemonOne.c_intro_score + @contest.pokemonOne.c_total_hearts
			@contest.pokemonTwo.contestVariables["Total Score"] = @contest.pokemonTwo.c_intro_score + @contest.pokemonTwo.c_total_hearts
			@contest.pokemonThree.contestVariables["Total Score"] = @contest.pokemonThree.c_intro_score + @contest.pokemonThree.c_total_hearts
			@contest.playerPokemon.contestVariables["Total Score"] = @contest.playerPokemon.c_intro_score + @contest.playerPokemon.c_total_hearts
			totals = [@contest.pokemonOne.c_total_score,@contest.pokemonTwo.c_total_score,@contest.pokemonThree.c_total_score,@contest.playerPokemon.c_total_score]
		end
		places = totals.sort.reverse
		#Winner
		case totals.find_index(places[0])
		when 0
			@contest.winningPosition = 1
			@contest.winningPokemon = @contest.pokemonOne
			@contest.winningTrainer = @contest.trainerOne
			@contest.playerWin = false
		when 1
			@contest.winningPosition = 2
			@contest.winningPokemon = @contest.pokemonTwo
			@contest.winningTrainer = @contest.trainerTwo
			@contest.playerWin = false
		when 2
			@contest.winningPosition = 3
			@contest.winningPokemon = @contest.pokemonThree
			@contest.winningTrainer = @contest.trainerThree
			@contest.playerWin = false
		when 3
			@contest.winningPosition = 4
			@contest.winningPokemon = @contest.playerPokemon
			@contest.winningTrainer = $Trainer
			@contest.playerWin = true
		end
		#Place Icons
		place_x = 448
		place_y = 14
		@sprites["first"] = IconSprite.new(0, 0, @viewport)	
		@sprites["first"].setBitmap(sprintf("Graphics/Pictures/Contest/result_first"))
		@sprites["first"].x = place_x
		@sprites["first"].y = place_y + 64*(totals.find_index(places[0]))
		@sprites["first"].visible = false
		@sprites["second"] = IconSprite.new(0, 0, @viewport)	
		@sprites["second"].setBitmap(sprintf("Graphics/Pictures/Contest/result_second"))
		@sprites["second"].x = place_x
		@sprites["second"].y = place_y + 64*(totals.find_index(places[1]))
		@sprites["second"].visible = false
		@sprites["third"] = IconSprite.new(0, 0, @viewport)	
		@sprites["third"].setBitmap(sprintf("Graphics/Pictures/Contest/result_third"))
		@sprites["third"].x = place_x
		@sprites["third"].y = place_y + 64*(totals.find_index(places[2]))
		@sprites["third"].visible = false
		@sprites["fourth"] = IconSprite.new(0, 0, @viewport)	
		@sprites["fourth"].setBitmap(sprintf("Graphics/Pictures/Contest/result_fourth"))
		@sprites["fourth"].x = place_x
		@sprites["fourth"].y = place_y + 64*(totals.find_index(places[3]))
		@sprites["fourth"].visible = false
		@updatePlaces = true
		pbUpdate
	end
	
	def pbUpdatePlaces
		return if !@updatePlaces
		count = 0
		while @updatePlaces
			@sprites["fourth"].visible = true
			@sprites["third"].visible = true if count >=40
			@sprites["second"].visible = true if count >=80
			@sprites["first"].visible = true  if count >=120
			@updatePlaces = false if count >= 160
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			count += 1
		end
	end

end

class PokemonContestResults_Screen
	def initialize(scene,contest)
		@scene = scene
		@contest = contest
	end

	def pbStartScreen
		@scene.pbStartScene
		@scene.pbScene
		@scene.pbEndScene
		return true
	end
end