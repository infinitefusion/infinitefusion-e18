#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

class PokemonContest
	attr_accessor :contestTrainers
	attr_accessor :contestTrainerAppearances

	RANK_POSITION_OFFSETS = [[0,0],[25,0],[50,0],[25,22]]

	def initEvents(rank)
		@mcEvent = $game_map.get_events_with_name("MC_#{rank}")[0]
		@judgeEvent = $game_map.get_events_with_name("Judge_#{rank}")[0]
		@contestTrainers = $game_map.get_events_with_name("ContestTrainer_#{rank}")
		@contestTrainerAppearances = initializeContestTrainerAppearances
		@crowdNPCs = $game_map.get_events_with_name("Crowd_#{rank}")
	end

	def initializeContestTrainerAppearances
		appearances = []
		update_global_outfit_lists
		@contestTrainers.each do |event|
			appearance = get_random_contest_trainer_appearance
			sprite = get_spritecharacter_for_event(event.id)
			sprite.setSpriteToAppearance(appearance)
			appearances.push(appearance)
		end
		return appearances
	end

	CONTEST_CONDITIONS = ["beautiful","cool","cute","clever","tough"]
	def get_random_contest_trainer_appearance
		appearance= get_random_appearance(false,20,10,30)
		appearance.hat = get_random_hat_contest(CONTEST_CONDITIONS[@category])
		appearance.clothes = get_random_clothes_contest(CONTEST_CONDITIONS[@category])
		return appearance
	end



	#====================================================================================
#  Introduction Round
#====================================================================================	
	def pbIntroductionRound
		mcEventId = @mcEvent.id
		map = $game_map.map_id
		trainerOneEvent = @contestTrainers[0]
		trainerTwoEvent = @contestTrainers[1]
		trainerThreeEvent = @contestTrainers[2]
		viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		viewport.z = 99999
		#MC
		pbMoveRoute(@mcEvent,[PBMoveRoute::Down])
		pbWaitForCharacterMove(@mcEvent)
		rankName = ContestFunctions.getRankName(rank,true)
		catName = ContestFunctions.getCategoryName(category,true)
		pbScrollMap(DIRECTION_UP, 2, 4)
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("Hello! We're just getting started with a {1}{2}Pokémon Contest.",rankName,catName))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("We'll start with the Introduction Round!"))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("The participating Coordinators and their Pokémon are as follows:"))
		pbMoveRoute(@mcEvent,[
			PBMoveRoute::Up,PBMoveRoute::TurnDown
		])
		pbWaitForCharacterMove(@mcEvent)
		pbWaitForCharacterMove(@mcEvent)
		#Introductions
		pbMoveRoute(trainerOneEvent,[
			PBMoveRoute::Up,PBMoveRoute::Right,PBMoveRoute::Right,
			PBMoveRoute::Right,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerOneEvent)
		#First
		pbWait(15)
		showPokemonIntro(@trainerOne, @pokemonOne, map, 1, viewport)
		pbWait(10)
		pbMoveRoute(trainerOneEvent,[
			PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::Left,
			PBMoveRoute::Down,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerOneEvent)
		pbMoveRoute(trainerTwoEvent,[
			PBMoveRoute::Up,PBMoveRoute::Right,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerTwoEvent)
		pbWait(15)
		#Second
		showPokemonIntro(@trainerTwo, @pokemonTwo, map, 2, viewport)
		pbWait(10)
		pbMoveRoute(trainerTwoEvent,[
			PBMoveRoute::Left,PBMoveRoute::Down,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerTwoEvent)
		pbMoveRoute(trainerThreeEvent,[
			PBMoveRoute::Up,PBMoveRoute::Left,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerThreeEvent)
		pbWait(15)
		#Third
		showPokemonIntro(@trainerThree, @pokemonThree, map, 3, viewport)
		pbWait(10)
		pbMoveRoute(trainerThreeEvent,[
			PBMoveRoute::Right,PBMoveRoute::Down,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove(trainerThreeEvent)
		pbScrollMap(DIRECTION_DOWN, 2, 4)
		pbScrollMap(DIRECTION_RIGHT, 3, 4)
		pbMoveRoute($game_player,[
			PBMoveRoute::Up,PBMoveRoute::Left,PBMoveRoute::Left,
			PBMoveRoute::Left,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove($game_player)
		pbWait(15)
		#Player
		showPokemonIntro($Trainer, @playerPokemon, map, 4, viewport)
		pbWait(10)
		pbMoveRoute($game_player,[
			PBMoveRoute::Right,PBMoveRoute::Right,PBMoveRoute::Right,
			PBMoveRoute::Down,PBMoveRoute::TurnUp
		])
		pbWaitForCharacterMove($game_player)
		pbScrollMap(DIRECTION_LEFT, 3, 4)
		pbScrollMap(DIRECTION_UP, 2, 4)
		#MC
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("We've just seen the four Pokémon contestants."))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("The audience will vote on their favorite Pokémon contestants."))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("Without any further ado, let the voting begin!"))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("Voting under way..."))
		pbWait(40)
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("Voting is now complete!"))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("While the votes are being tallied, let's move on to the Talent Round!"))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("May the contestants amaze us with superb appeals of dazzling moves!"))
		pbCallBub(2,mcEventId)
		pbMessage(_INTL("Let's see a little enthusiasm! Let's appeal!"))
		pbMoveRoute(@mcEvent,[PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::TurnDown])
		pbMoveRoute(@judgeEvent,[PBMoveRoute::Right,PBMoveRoute::Right,PBMoveRoute::TurnDown])
		pbWaitForCharacterMove(@judgeEvent)
		pbWait(5)
		viewport.dispose
	end

	def showPokemonIntro(trainer, pokemon, map, position, vp)
		trainerName = trainer.name
		pokemonName = pokemon.name
		sprite = PokemonSprite.new(vp)
		sprite.setPokemonBitmap(pokemon)
		sprite.visible = false

		appearance = @contestTrainerAppearances[position - 1]
		if position < 4 #NPC
			trainer_bitmap = generate_front_trainer_sprite_bitmap_from_appearance(appearance)
		else #player
			trainer_bitmap = generate_front_trainer_sprite_bitmap
		end
		trainer_bitmap.scale_bitmap(2)

		pokemon.play_cry
		if sprite.bitmap
			poke_bmp    = sprite.bitmap
			train_bmp   = trainer_bitmap.bitmap
			padding     = 8
			combined_width  = train_bmp.width + padding + poke_bmp.width
			combined_height = [train_bmp.height, poke_bmp.height].max
			combined_bitmap = Bitmap.new(combined_width, combined_height)

			#Trainer sprite
			trainer_x = 200
			trainer_y = combined_height - train_bmp.height
			combined_bitmap.blt(trainer_x, trainer_y, train_bmp, train_bmp.rect)

			#Pokemon sprite
			pokemon_x = (combined_width - poke_bmp.width) / 2 - 24
			pokemon_y = combined_height - poke_bmp.height
			combined_bitmap.blt(pokemon_x, pokemon_y, poke_bmp, poke_bmp.rect)

			iconWindow = PictureWindow.new(combined_bitmap)
			iconWindow.x = (Graphics.width  - iconWindow.width)  / 2
			iconWindow.y = (Graphics.height - 96 - iconWindow.height) / 2
			iconWindow.z = 100

			pbMessage(_INTL("<ac>Entry Number {1}\n{2} & {3}</ac>", position, pokemonName, trainerName))

			iconWindow.dispose
			combined_bitmap.dispose
			showCrowdHearts(pokemon, map)
		else
			pbMessage(_INTL("{1} & {2}", trainerName, pokemonName))
			showCrowdHearts(pokemon, map)
		end
		sprite.dispose
		trainer_bitmap.dispose
		unless pokemon.hat.nil?
			current_category_name = CONTEST_CONDITIONS[@category]
			pokemon_hat_categories = get_hat_contest_tags(pokemon.hat)

			if pokemon_hat_categories.include?(current_category_name)
				pbCallBub(1, @crowdNPCs.sample.id)
				pbMessage(_INTL("Oh! It's wearing a {1} hat!", current_category_name))

				trainer_hat_categories    = get_hat_contest_tags($Trainer.hat)
				trainer_hat2_categories   = get_hat_contest_tags($Trainer.hat2)
				trainer_clothes_categories = get_clothes_contest_tags($Trainer.clothes)

				hat_match     = trainer_hat_categories.include?(current_category_name) ||
					trainer_hat2_categories.include?(current_category_name)
				clothes_match = trainer_clothes_categories.include?(current_category_name)

				bonus = 40
				if hat_match && clothes_match
					pbCallBub(1, @crowdNPCs.sample.id)
					pbMessage(_INTL("It matches its Trainer's outfit wonderfully!"))
					bonus += 80
				elsif hat_match
					pbCallBub(1, @crowdNPCs.sample.id)
					pbMessage(_INTL("It matches its Trainer's!"))
					bonus += 40
				elsif clothes_match
					pbCallBub(1, @crowdNPCs.sample.id)
					pbMessage(_INTL("It goes well with its Trainer's clothes!"))
					bonus += 40
				end

				pokemon.contestVariables["Intro Score"] += bonus
			end
		end
	end

	def showCrowdHearts(pokemon,map)
		req = [ #Min requirement for each heart values, [8,7,6,5,4,3,2,1]
			[81,71,61,51,41,31,21,11],
			[141,126,112,98,84,70,56,42],
			[201,184,167,150,134,117,100,84],
			[251,237,223,209,195,181,167,153]
		][@rank]
		val = [pokemon.beauty, pokemon.cool, pokemon.cute, pokemon.smart, pokemon.tough][@category]
		hearts = 0
		if ContestSettings::USE_SHEEN_FOR_INTRODUCTION_ROUND && !(PokeblockSettings::SIMPLIFIED_BERRY_BLENDING || PokeblockSettings::DONT_USE_SHEEN)
			val = (val/2).round
			val += (pokemon.sheen/2).round
		end
		val += 20 if pokemon.hasItem?([:REDSCARF,:BLUESCARF,:PINKSCARF,:GREENSCARF,:YELLOWSCARF][@category])

		s = [@crowdNPCs.size, 8].min
		if val >= req[0]
			events = @crowdNPCs.sample(s)
			events.each { |event|
				$scene.spriteset(map).addUserAnimation(ContestSettings::HEART_ANIMATION_ID, event.x, event.y, false, 2)
				pbWait(rand(6)+4)
			}
			hearts = 8
		else
			hearts = 0
			req.each_with_index { |r, i|
				if val > r
					hearts = 8-i
					break
				end
			}
			events = @crowdNPCs.sample([hearts, @crowdNPCs.size].min)
			events.each { |event|
				playAnimation(ContestSettings::HEART_ANIMATION_ID, event.x, event.y)
				pbWait(rand(6)+4)
			}
		end

		pokemonOne.contestVariables["Intro Score"] = hearts*40 if pokemon == pokemonOne
		pokemonTwo.contestVariables["Intro Score"] = hearts*40 if pokemon == pokemonTwo
		pokemonThree.contestVariables["Intro Score"] = hearts*40 if pokemon == pokemonThree
		playerPokemon.contestVariables["Intro Score"] = hearts*40 if pokemon == playerPokemon		
	end
	
	def pbTalentRound
		pbFadeOutIn {
			scene = PokemonContestTalent_Scene.new(self)
			screen = PokemonContestTalent_Screen.new(scene, self)
			ret = screen.pbStartScreen
		}
	end
	
end

#====================================================================================
#  Talent Round
#====================================================================================	

class PokemonContestTalent_Scene
	def initialize(contest)
		@contest = contest
		@exit = false
	end
	
	def pbStartScene
		# Viewport
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["background"] = IconSprite.new(0, 0, @viewport)	
		@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Contest/contestbg"))
		@sprites["message"] = IconSprite.new(0, 0, @viewport)	
		@sprites["message"].setBitmap(sprintf("Graphics/Pictures/Contest/message_box"))
		@sprites["message"].z = 62
		@sprites["message"].y = Graphics.height - @sprites["message"].bitmap.height
		@sprites["pokemonlist"] = IconSprite.new(0, 0, @viewport)
		@sprites["pokemonlist"].setBitmap(sprintf("Graphics/Pictures/Contest/pokemon_list"))
		@sprites["pokemonlist"].x = Graphics.width - @sprites["pokemonlist"].bitmap.width
		@sprites["pokemonlist"].z = 63
		@sprites["pokemonlist_player"] = IconSprite.new(0, 0, @viewport)
		@sprites["pokemonlist_player"].setBitmap(sprintf("Graphics/Pictures/Contest/player_panel"))
		@sprites["pokemonlist_player"].x = Graphics.width - @sprites["pokemonlist_player"].bitmap.width
		@sprites["pokemonlist_player"].z = 64
		listWidth = @sprites["pokemonlist_player"].bitmap.width
		listSecHeight = @sprites["pokemonlist_player"].bitmap.height
		@sprites["pokemoninfo_player"] = BitmapSprite.new(listWidth, listSecHeight, @viewport)
		@sprites["pokemoninfo_player"].x = Graphics.width - listWidth
		@sprites["pokemoninfo_player"].z = 65
		pbSetSystemFont(@sprites["pokemoninfo_player"].bitmap)
		@sprites["pokemoninfo_one"] = BitmapSprite.new(listWidth, listSecHeight, @viewport)
		@sprites["pokemoninfo_one"].x = Graphics.width - listWidth
		@sprites["pokemoninfo_one"].z = 65
		pbSetSystemFont(@sprites["pokemoninfo_one"].bitmap)
		@sprites["pokemoninfo_two"] = BitmapSprite.new(listWidth, listSecHeight, @viewport)
		@sprites["pokemoninfo_two"].x = Graphics.width - listWidth
		@sprites["pokemoninfo_two"].z = 65
		pbSetSystemFont(@sprites["pokemoninfo_two"].bitmap)
		@sprites["pokemoninfo_three"] = BitmapSprite.new(listWidth, listSecHeight, @viewport)
		@sprites["pokemoninfo_three"].x = Graphics.width - listWidth
		@sprites["pokemoninfo_three"].z = 65
		pbSetSystemFont(@sprites["pokemoninfo_three"].bitmap)
		@sprites["pokemoninfo_nextorder"] = BitmapSprite.new(listWidth, @sprites["pokemonlist"].bitmap.height, @viewport)
		@sprites["pokemoninfo_nextorder"].x = Graphics.width - listWidth
		@sprites["pokemoninfo_nextorder"].z = 65
		@crowdAnim  = AnimatedSprite.create("Graphics/Pictures/Contest/crowd_animated", 2, 4, @viewport)
		@crowdAnim.visible = false
		@sprites["applausemeter"] = IconSprite.new(0, 0, @viewport)	
		meterPath = "Graphics/Pictures/Contest/applause_meter"
		if ContestSettings::USE_ORAS_APPLAUSE_METER
			meterPath = "Graphics/Pictures/Contest/applause_meter_m_"
			meterPath += ContestFunctions.getCategoryNameShort(@contest.category).downcase
		end
		@sprites["applausemeter"].setBitmap(sprintf(meterPath))
		@sprites["applausemeter"].x = 0 - @sprites["applausemeter"].bitmap.width
		@sprites["applausemeter"].y = 4
		@sprites["applausemeter"].z = 63
		@sprites["applausemeteroverlay"] = IconSprite.new(0, 0, @viewport)
		@sprites["applausemeteroverlay"].bitmap = Bitmap.new(@sprites["applausemeter"].bitmap.width, @sprites["applausemeter"].bitmap.height)
		@sprites["applausemeteroverlay"].x = @sprites["applausemeter"].x
		@sprites["applausemeteroverlay"].y = @sprites["applausemeter"].y
		@sprites["applausemeteroverlay"].z = @sprites["applausemeter"].z
		@sprites["judgeoverlay"] = IconSprite.new(0, 0, @viewport)
		@sprites["judgeoverlay"].bitmap = Bitmap.new(30, 30)
		@sprites["judgeoverlay"].x = 228
		@sprites["judgeoverlay"].y = 20
		@sprites["judgeoverlay"].z = 65
		@sprites["curtain"] = IconSprite.new(0, 0, @viewport)
		@sprites["curtain"].setBitmap(sprintf("Graphics/Pictures/Contest/curtain"))
		@sprites["curtain"].x = Graphics.width - @sprites["curtain"].bitmap.width
		@sprites["curtain"].y = 0
		@sprites["curtain"].z = 99
		@sprites["opponent"] = IconSprite.new(0, 0, @viewport)	
		@sprites["opponent"].setBitmap(sprintf("Graphics/Pictures/Contest/animation_target"))
		@sprites["opponent"].ox = @sprites["opponent"].bitmap.width / 2
		@sprites["opponent"].oy = @sprites["opponent"].bitmap.height / 2
		@sprites["opponent"].x = @sprites["opponent"].ox
		@sprites["opponent"].y = @sprites["opponent"].oy
		@sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
		@sprites["msgwindow"].visible  = false
		@sprites["msgwindow"].viewport = @viewport
		pbDeactivateWindows(@sprites)
		pbRefresh
		pbFadeInAndShow(@sprites)
	end
	
	def pbScene
		#Initial setup
		@contest.setupFirstRound
		@currentPosition = 0
		#Loop
		loop do
			break if @exit
			pbStartRound
			pbChooseMove
			pbSetAIMoves
			
			pbHideApplauseMeter
			4.times { |i|
				@currentPosition=i+1
				pbDisplayPokemon(@currentPosition)
				pbWait(20)
				pbUseMove(@currentPosition)
				pbWait(20)
				pbDismissPokemon(@currentPosition)
				pbWait(20)
			}
			pbEndRound
		end
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { pbUpdate }
		pbDisposeSpriteHash(@sprites)
		@crowdAnim.dispose
		@viewport.dispose
	end

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end
	
	def pbRefresh

	end
	
	def pbShowApplauseMeter
		while @sprites["applausemeter"].x < 0
			@sprites["applausemeter"].x += 10
			@sprites["applausemeter"].x = 0 if @sprites["applausemeter"].x > 0
			@sprites["applausemeteroverlay"].x = @sprites["applausemeter"].x
			Graphics.update
			Input.update
			pbUpdate
		end
	end
	
	def pbHideApplauseMeter
		while @sprites["applausemeter"].x > 0 - @sprites["applausemeter"].bitmap.width
			@sprites["applausemeter"].x -= 10
			@sprites["applausemeter"].x = 0 - @sprites["applausemeter"].bitmap.width if @sprites["applausemeter"].x < 0 - @sprites["applausemeter"].bitmap.width
			@sprites["applausemeteroverlay"].x = @sprites["applausemeter"].x
			Graphics.update
			Input.update
			pbUpdate
		end
	end
	
	def updateApplauseMeter
		@sprites["applausemeteroverlay"].bitmap.clear
		imgpos = []
		crowdEnergy = @contest.crowdEnergy
		if ContestSettings::USE_ORAS_APPLAUSE_METER
			imgpos << ["Graphics/Pictures/Contest/applause#{crowdEnergy}_m",0,0] if crowdEnergy > 0
		else
			imgpos << ["Graphics/Pictures/Contest/applause#{crowdEnergy}",0,0] if crowdEnergy > 0
		end
		pbDrawImagePositions(@sprites["applausemeteroverlay"].bitmap,imgpos)
	end
	
	def animateCrowd
		@crowdAnim.visible = true
		@crowdAnim.play
	end
	
	def pbWaitCrowd(numFrames)
		numFrames.times do
			Graphics.update
			Input.update
			pbUpdateSceneMap
			updateCrowdAnim
		end
	end
	
	def updateCrowdAnim
		return if !@crowdAnim.visible
		@crowdAnim.update
	end
	
	def deanimateCrowd
		@crowdAnim.stop
		@crowdAnim.visible = false
	end
	
	def pbStartRound
		pbUpdateAllContestantInfo
		@sprites["pokemonlist_player"].y = 96*@contest.roundOrder.find_index(@contest.playerPokemon)
		pbWait(20)
		pbSEPlay("Contest curtain up")
		while @sprites["curtain"].y > 0 - @sprites["curtain"].bitmap.height
			@sprites["curtain"].y -= 20
			@sprites["curtain"].y = 0 - @sprites["curtain"].bitmap.height if @sprites["curtain"].y < 0 - @sprites["curtain"].bitmap.height
			Graphics.update
			Input.update
			pbUpdate
		end
		pbWait(5)
		pbShowApplauseMeter
		round = pbCurrentPokemonContest.round
		if round >= ContestSettings::NUMBER_OF_TALENT_ROUNDS
			pbContestMessage(_INTL("\\c[1]Appeal move no. #{round}. It's the last move!\\n\\c[0]Which move will you use?"))
		else
			pbContestMessage(_INTL("\\c[1]Appeal move no. #{round}!\\n\\c[0]Which move will you use?"))
		end
		pbWait(20)
	end
	
	def pbShowJudgeIcon(icon)
		if icon == "bored"
			pbSEPlay("Contest jam")
		elsif icon == "scramble"
			pbSEPlay("Contest jam")
		else
			pbSEPlay("Exclaim")
		end
		bit = @sprites["judgeoverlay"].bitmap
		imgpos = [["Graphics/Pictures/Contest/judge_#{icon}",0,0]]
		pbDrawImagePositions(bit,imgpos)
		pbWait(60)
		bit.clear
		pbWait(5)
	end
	
	def pbUpdateAllContestantInfo(hideTurn = false)
		@contest.roundOrder.each { |p|
			pbUpdateContestantInfo(p,hideTurn)
		}			
	end
	
	def pbUpdateContestantInfo(pkmn,hideTurn = false)
		base = Color.new(72,72,72)
		shadow = Color.new(160,160,160)
		if pkmn == @contest.playerPokemon
			player = @sprites["pokemoninfo_player"].bitmap
			player.clear
			pbDrawTextPositions(player, [[pkmn.name,6,8,0,base,shadow]])
			@sprites["pokemoninfo_player"].y = 96*pkmn.c_orderindex
			imgpos = []
			heart = getHeartImage(pkmn.c_round_hearts)
			imgpos << heart if !heart.empty?
			spirit = pbCheckSpirit(pkmn)
			imgpos << spirit if !spirit.empty?
			status = pbCheckStatus(pkmn)
			imgpos << status if !status.empty?
			turn = pbCheckTurnOrder(pkmn)
			imgpos << turn if !turn.empty? && !hideTurn
			imgpos << ["Graphics/Pictures/Contest/potential",10,80] if pkmn.c_hasattention
			pbDrawImagePositions(player,imgpos)
		elsif pkmn == @contest.pokemonOne
			one = @sprites["pokemoninfo_one"].bitmap
			one.clear
			pbDrawTextPositions(one, [[pkmn.name,6,8,0,base,shadow]])
			@sprites["pokemoninfo_one"].y = 96*pkmn.c_orderindex
			imgpos = []
			heart = getHeartImage(pkmn.c_round_hearts)
			imgpos << heart if !heart.empty?
			spirit = pbCheckSpirit(pkmn)
			imgpos << spirit if !spirit.empty?
			status = pbCheckStatus(pkmn)
			imgpos << status if !status.empty?
			turn = pbCheckTurnOrder(pkmn)
			imgpos << turn if !turn.empty? && !hideTurn
			imgpos << ["Graphics/Pictures/Contest/potential",10,80] if pkmn.c_hasattention
			pbDrawImagePositions(one,imgpos)
		elsif pkmn == @contest.pokemonTwo			
			two = @sprites["pokemoninfo_two"].bitmap
			two.clear
			pbDrawTextPositions(two, [[pkmn.name,6,8,0,base,shadow]])
			@sprites["pokemoninfo_two"].y = 96*pkmn.c_orderindex
			imgpos = []
			heart = getHeartImage(pkmn.c_round_hearts)
			imgpos << heart if !heart.empty?
			spirit = pbCheckSpirit(pkmn)
			imgpos << spirit if !spirit.empty?
			status = pbCheckStatus(pkmn)
			imgpos << status if !status.empty?
			turn = pbCheckTurnOrder(pkmn)
			imgpos << turn if !turn.empty? && !hideTurn
			imgpos << ["Graphics/Pictures/Contest/potential",10,80] if pkmn.c_hasattention
			pbDrawImagePositions(two,imgpos)
		elsif pkmn == @contest.pokemonThree	
			three = @sprites["pokemoninfo_three"].bitmap
			three.clear
			pbDrawTextPositions(three, [[pkmn.name,6,8,0,base,shadow]])
			@sprites["pokemoninfo_three"].y = 96*pkmn.c_orderindex
			imgpos = []
			heart = getHeartImage(pkmn.c_round_hearts)
			imgpos << heart if !heart.empty?
			spirit = pbCheckSpirit(pkmn)
			imgpos << spirit if !spirit.empty?
			status = pbCheckStatus(pkmn)
			imgpos << status if !status.empty?
			turn = pbCheckTurnOrder(pkmn)
			imgpos << turn if !turn.empty? && !hideTurn
			imgpos << ["Graphics/Pictures/Contest/potential",10,80] if pkmn.c_hasattention
			pbDrawImagePositions(three,imgpos)			
		end
	end
	
	def pbDrawContestantHeartMeters
		pbUpdateAllContestantInfo(true)
		bitmap = Bitmap.new(sprintf("Graphics/Pictures/Contest/heart_scale"))
		newTotals = []
		diffs = []
		xPos = Graphics.width - @sprites["pokemonlist_player"].bitmap.width
		@contest.roundOrder.each_with_index { |p,i|
			@sprites["heartmeter_#{i}"] = IconSprite.new(0, 0, @viewport) 
			@sprites["heartmeter_#{i}"].bitmap = bitmap
			@sprites["heartmeter_#{i}"].x = xPos + 36 + 4*p.c_total_hearts
			@sprites["heartmeter_#{i}"].y = 80 + 96*i
			@sprites["heartmeter_#{i}"].z = 70
			newTotals[i] = (p.c_total_hearts + p.c_round_hearts).clamp(0,27)
			diffs[i] = newTotals[i] - p.c_total_hearts
		}	
		pbWait(20)
		animate = true
		while animate
			done = [false, false, false, false]
			diffs.each_with_index { |a,i|
				next if done[i]
				if diffs[i] < 0
					@sprites["heartmeter_#{i}"].x -= 4
					diffs[i] += 1
				elsif diffs[i] > 0
					@sprites["heartmeter_#{i}"].x += 4
					diffs[i] -= 1
				else #0
					done[i] = true
				end
			}
			Graphics.update
			Input.update
			animate = false if done[0] && done[1] && done[2] && done[3]
		end
		
		@contest.roundOrder.each { |p,i|
			p.c_total_hearts = (p.c_total_hearts + p.c_round_hearts).clamp(0,27)
		}	
	end

	def pbDisposeHeartMeters
		4.times do |i|
			@sprites["heartmeter_#{i}"].dispose
			@sprites.delete("heartmeter_#{i}")
		end
	end
	
	def getHeartImage(value)
		return ["Graphics/Pictures/Contest/heart#{value}",36,50] if value > 0
		return ["Graphics/Pictures/Contest/negaheart#{value.abs}",36,50]  if value < 0
		return []
	end
	
	def pbCheckSpirit(pkmn)
		return ["Graphics/Pictures/Contest/stars#{pkmn.c_spirit}",6,34] if pkmn.c_spirit > 0
		return []
	end
	
	def pbCheckStatus(pkmn)
		imgpos = []
		if pkmn.c_startled 
			imgpos = ["Graphics/Pictures/Contest/icon_startled",6,50]
		elsif pkmn.c_nomoremoves || pkmn.c_missturn
			imgpos = ["Graphics/Pictures/Contest/icon_resting",6,50]
		elsif pkmn.c_calm || pkmn.c_oblivious
			imgpos = ["Graphics/Pictures/Contest/icon_oblivious",6,50]
		elsif pkmn.c_nervous
			imgpos = ["Graphics/Pictures/Contest/icon_nervous",6,50]
		end
		return imgpos
	end
	
	def pbCheckTurnOrder(pkmn)
		return ["Graphics/Pictures/Contest/nextturn_random",46,78] if @contest.scramble
		imgpos = []
		if pkmn.c_moveup
			i = @contest.nextTurnFirstOrder.find_index(pkmn) 
			imgpos = ["Graphics/Pictures/Contest/nextturn#{i+1}",46,78]
		elsif pkmn.c_movedown
			i = @contest.nextTurnLastOrder.find_index(pkmn) 
			imgpos = ["Graphics/Pictures/Contest/nextturn#{i+1}",46,78]
		end
		return imgpos
	end
	
	def pbChooseMove
		if !@sprites["moves"]
			@sprites["moves"] = Sprite.new(@viewport)
			@sprites["moves"].bitmap = Bitmap.new("Graphics/Pictures/Contest/moves")
		end
		@sprites["moves"].x = 0
		@sprites["moves"].y = 184
		@sprites["moves"].z = 85
		@buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Contest/cursor_contest"))
		# Set overlay				
		if !@sprites["overlay"]
			@sprites["overlay"] = Sprite.new(@viewport)
			@sprites["overlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		end
		@sprites["overlay"].z = 87
		overlay  = @sprites["overlay"].bitmap
		overlay.clear
		if !@sprites["overlay1"]
			@sprites["overlay1"] = Sprite.new(@viewport)
			@sprites["overlay1"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		end
		@sprites["overlay1"].z = 87
		overlay1 = @sprites["overlay1"].bitmap
		overlay1.clear
		pbSetNarrowFont(overlay)
		pbSetSystemFont(overlay1)
		textpos  = [[_INTL("Please select a move."), 12, 150, 0, Color.new(256,256,256), Color.new(0,0,0)]]
		# Draw text
		@selection = 0
		# Move
		@selectedmove = GameData::Move.get(@contest.playerPokemon.moves[@selection].id)
		pbMoveShowDetails(@selectedmove)
		@contest.playerPokemon.numMoves.times { |i|
			if @contest.playerPokemon.moves[i].id
				move = GameData::Move.get(@contest.playerPokemon.moves[i].id)
				name = move.name
				@sprites["button_#{i}"] = Sprite.new(@viewport)
				@sprites["button_#{i}"].bitmap = @buttonBitmap.bitmap
				@sprites["button_#{i}"].x = xPos = 6
				@sprites["button_#{i}"].y = yPos = 192 + 46 * i
				@sprites["button_#{i}"].z = 86
				@sprites["button_#{i}"].src_rect.width  = @buttonBitmap.width / 2
				@sprites["button_#{i}"].src_rect.height  = @buttonBitmap.height / 6
				@sprites["button_#{i}"].src_rect.x = (@selection == i) ? @buttonBitmap.width / 2 : 0
				@sprites["button_#{i}"].src_rect.y = move.contest_type_position * 46
				colorb = Color.new(80, 80, 88)
				colorb = Color.new(175, 175, 175) if (@contest.playerPokemon.c_lastmove && name == @contest.playerPokemon.c_lastmove.name)
				colorb = Color.new(65, 0, 165) if @contest.playerPokemon.checkContestCombos(move)
				textpos << [name, xPos + @sprites["button_#{i}"].src_rect.width/2, yPos, 2, colorb, Color.new(160, 160, 168)]
			end
		}
		pbDrawTextPositions(overlay, textpos)
		waitingForInput = true
		pbWait(20)
		loop do
			break if !waitingForInput
			Graphics.update
			Input.update
			pbUpdate
			if Input.trigger?(Input::DOWN)
				@selection += 1
				@selection  = 0 if @selection >= @contest.playerPokemon.numMoves
				# Set information
				pbMoveShowDetails(GameData::Move.get(@contest.playerPokemon.moves[@selection].id))
				pbMoveUpdateButtons
				pbPlayCursorSE
			elsif Input.trigger?(Input::UP)
				@selection -= 1
				@selection  = @contest.playerPokemon.numMoves - 1 if @selection < 0
				# Set information
				pbMoveShowDetails(GameData::Move.get(@contest.playerPokemon.moves[@selection].id))
				pbMoveUpdateButtons
				pbPlayCursorSE
			elsif Input.trigger?(Input::USE)
				if GameData::Move.get(@contest.playerPokemon.moves[@selection].id).contest_can_be_used?
					pbPlayDecisionSE
					# Set select (move)
					@contest.playerPokemon.c_currentmove = @contest.playerPokemon.moves[@selection]
					# Dispose
					["moves","selecthearts","selectjam","button_0","button_1","button_2","button_3"].each { |sprite| dispose(@sprites, sprite) }
					["overlay", "overlay1"].each { |i| @sprites["#{i}"].bitmap.clear}
					@buttonBitmap.dispose
					waitingForInput = false
				else
					pbPlayBuzzerSE
				end
			end
		end
	end
	
	def pbMoveShowDetails(move)
		return if !move
		overlay1 = @sprites["overlay1"].bitmap
		overlay1.clear
		textpos1 = []
		imagepos1 = []
		description   = move.contest_description
		hearts        = !move.contest_can_be_used? ? 0 : move.contest_hearts
		jam           = !move.contest_can_be_used? ? 0 : move.contest_jam
		type = move.contest_type_position
		imagepos1 << ["Graphics/Pictures/Contest/contesttype", 206, 204, 0, type * 28, 64, 28]
		textpos1 << [_INTL("APPEAL"), 422, 180, 1, Color.new(248, 248, 248), Color.new(104, 104, 104)]
		textpos1 << [_INTL("JAMMING"), 422, 212, 1, Color.new(248, 248, 248), Color.new(104, 104, 104)]
		if hearts > 0
			file = "Graphics/Pictures/Contest/move_heart#{hearts}"
			@sprites["selecthearts"] = IconSprite.new(436, 190, @viewport) if !@sprites["selecthearts"]
			@sprites["selecthearts"].setBitmap(file)
			@sprites["selecthearts"].z = 88
		else
			@sprites["selecthearts"]&.clearBitmaps
		end
		if jam > 0
			file = "Graphics/Pictures/Contest/move_negaheart#{jam}"
			@sprites["selectjam"] = IconSprite.new(436, 222, @viewport) if !@sprites["selectjam"]
			@sprites["selectjam"].setBitmap(file)
			@sprites["selectjam"].z = 88
		else
			@sprites["selectjam"]&.clearBitmaps
		end
		pbDrawTextPositions(overlay1, textpos1)
		pbDrawImagePositions(overlay1, imagepos1)
		drawTextEx(overlay1, 208, 258, 296, 4, description, Color.new(64, 64, 64), Color.new(176, 176, 176))
	end
	
	def pbMoveUpdateButtons
		@contest.playerPokemon.numMoves.times { |i|
			@sprites["button_#{i}"].src_rect.x = (@selection == i) ? @buttonBitmap.width / 2 : 0
		}
	end
	
	def pbEndRound
		#clear next turn order boxes here
		pbWait(10)
		pbDrawContestantHeartMeters
		pbWait(20)
		pbSEPlay("Contest curtain down")
		while @sprites["curtain"].y < 0
			@sprites["curtain"].y += 20
			@sprites["curtain"].y = 0 if @sprites["curtain"].y > 0
			Graphics.update
			Input.update
			pbUpdate
		end
		pbWait(5)
		pbHideApplauseMeter
		pbWait(20)
		pbDisposeHeartMeters
		pbCurrentPokemonContest.round += 1
		if pbCurrentPokemonContest.round > ContestSettings::NUMBER_OF_TALENT_ROUNDS
			pbContestMessage(_INTL("\\c[1]That's it! \\c[0]We're all out of Appeal Time!"))
			@exit = true
			return
		end
		pbCurrentPokemonContest.setupNextRound
	end

end

class PokemonContestTalent_Screen
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


