#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Summary
#====================================================================================




class PokemonSummary_Scene
	alias tdw_contests_summary_start_scene pbStartScene
	def pbStartScene(party, partyindex, inbattle = false, is_player = true)
		@contestpage = $game_map.map_id == ContestSettings::DEFAULT_LOBBY_MAP_ID
		echoln @contestpage
		tdw_contests_summary_start_scene(party, partyindex, inbattle, is_player)
	end

	alias tdw_contests_summary_page_three drawPageThree
	def drawPageThree
		if !@contestpage
			tdw_contests_summary_page_three
		else
			simple = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
			bargraph = (PluginManager.installed?("Better Bitmaps") ? PokeblockSettings::STATS_BAR_GRAPH : true)
			@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Summary/bg_3_contest"))
			pbCreateConditionBars(simple,bargraph)
		end
	end
	
	alias tdw_contests_summary_page_four drawPageFour
	def drawPageFour
		if !@contestpage
			tdw_contests_summary_page_four
		else
			overlay = @sprites["overlay"].bitmap
			moveBase   = Color.new(64, 64, 64)
			moveShadow = Color.new(176, 176, 176)
			ppBase   = [moveBase,                # More than 1/2 of total PP
						Color.new(248, 192, 0),    # 1/2 of total PP or less
						Color.new(248, 136, 32),   # 1/4 of total PP or less
						Color.new(248, 72, 72)]    # Zero PP
			ppShadow = [moveShadow,             # More than 1/2 of total PP
						Color.new(144, 104, 0),   # 1/2 of total PP or less
						Color.new(144, 72, 24),   # 1/4 of total PP or less
						Color.new(136, 48, 48)]   # Zero PP
			@sprites["pokemon"].visible  = true
			@sprites["pokeicon"].visible = false
			@sprites["itemicon"].visible = true
			textpos  = []
			imagepos = []
			# Write move names, types and PP amounts for each known move
			xPos = 248
			yPos = 92
			yAdj = 0
			Pokemon::MAX_MOVES.times do |i|
			  move = @pokemon.moves[i]
			  if move
				type_number = GameData::Move.get(move.id).contest_type_position
				imagepos.push(["Graphics/Pictures/Contest/contesttype", xPos, yPos + yAdj +8, 0, type_number * 28, 64, 28])
				textpos.push([move.name, xPos+68, yPos + yAdj, 0, moveBase, moveShadow])
				if move.total_pp > 0
				  textpos.push([_INTL("PP"), xPos+94, yPos + yAdj + 32, 0, moveBase, moveShadow])
				  ppfraction = 0
				  if move.pp == 0
					ppfraction = 3
				  elsif move.pp * 4 <= move.total_pp
					ppfraction = 2
				  elsif move.pp * 2 <= move.total_pp
					ppfraction = 1
				  end
				  textpos.push([sprintf("%d/%d", move.pp, move.total_pp), xPos+212, yPos + yAdj + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
				end
			  else
				textpos.push(["-", xPos+68, yPos, 0, moveBase, moveShadow])
				textpos.push(["--", xPos+194, yPos + yAdj + 32, 1, moveBase, moveShadow])
			  end
			  yPos += 64
			end
			# Draw all text and images
			pbDrawTextPositions(overlay, textpos)
			pbDrawImagePositions(overlay, imagepos)
		end
	end

	def drawPageFourContestSelecting(move_to_learn)
		overlay = @sprites["overlay"].bitmap
		overlay.clear

		base   = Color.new(248, 248, 248)
		shadow = Color.new(104, 104, 104)
		moveBase   = Color.new(64, 64, 64)
		moveShadow = Color.new(176, 176, 176)
		ppBase   = [moveBase,                # More than 1/2 of total PP
					Color.new(248, 192, 0),    # 1/2 of total PP or less
					Color.new(248, 136, 32),   # 1/4 of total PP or less
					Color.new(248, 72, 72)]    # Zero PP
		ppShadow = [moveShadow,             # More than 1/2 of total PP
					Color.new(144, 104, 0),   # 1/2 of total PP or less
					Color.new(144, 72, 24),   # 1/4 of total PP or less
					Color.new(136, 48, 48)]   # Zero PP

		# Set background image
		if move_to_learn
		  @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
		else
			@sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
		end
		# Write various bits of text
		textpos = [
			[_INTL("MOVES"), 26, 10, 0, base, shadow],
			[_INTL("APPEAL"), 20, 116, 0, base, shadow],
			[_INTL("JAMMING"), 20, 148, 0, base, shadow]
		]
		imagepos = []
		# Write move names, types and PP amounts for each known move
		xPos = 248
		yPos = 104
		yAdj = -12
		yPos -= 76 if move_to_learn
		limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
		limit.times do |i|
		  move = @pokemon.moves[i]
		  if i == Pokemon::MAX_MOVES
			move = move_to_learn
			yPos += 20
		  end
		  if move
			type_number = GameData::Move.get(move.id).contest_type_position
			imagepos.push(["Graphics/Pictures/Contest/contesttype", xPos, yPos + yAdj + 8, 0, type_number * 28, 64, 28])
			textpos.push([move.name, xPos + 68, yPos + yAdj, 0, moveBase, moveShadow])
			if move.total_pp > 0
			  textpos.push([_INTL("PP"), xPos + 94, yPos + yAdj + 32, 0, moveBase, moveShadow])
			  ppfraction = 0
			  if move.pp == 0
				ppfraction = 3
			  elsif move.pp * 4 <= move.total_pp
				ppfraction = 2
			  elsif move.pp * 2 <= move.total_pp
				ppfraction = 1
			  end
			  textpos.push([sprintf("%d/%d", move.pp, move.total_pp), xPos + 212, yPos + yAdj + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
			end
		  else
			textpos.push(["-", xPos + 68, yPos + yAdj, 0, moveBase, moveShadow])
			textpos.push(["--", xPos + 194, yPos + yAdj + 32, 1, moveBase, moveShadow])
		  end
		  yPos += 64
		end
		# Draw all text and images
		pbDrawTextPositions(overlay, textpos)
		pbDrawImagePositions(overlay, imagepos)
		# Draw Pokémon's type icon(s)
		@pokemon.types.each_with_index do |type, i|
			type_number = GameData::Type.get(type).id_number
		  type_rect = Rect.new(0, type_number * 28, 64, 28)
		  type_x = (@pokemon.types.length == 1) ? 130 : 96 + (70 * i)
		  overlay.blt(type_x, 78, @typebitmap.bitmap, type_rect)
		end
	end
		
	def drawSelectedContestMove(move_to_learn, selected_move)
		# Draw all of page four, except selected move's details
		drawPageFourContestSelecting(move_to_learn)
		move = GameData::Move.get(selected_move.id)
		# Set various values
		overlay = @sprites["overlay"].bitmap
		base = Color.new(64, 64, 64)
		shadow = Color.new(176, 176, 176)
		@sprites["pokemon"].visible = false if @sprites["pokemon"]
		@sprites["pokeicon"].pokemon = @pokemon
		@sprites["pokeicon"].visible = true
		@sprites["itemicon"].visible = false if @sprites["itemicon"]
		hearts = !move.contest_can_be_used? ? 0 : move.contest_hearts
		jam = !move.contest_can_be_used? ? 0 : move.contest_jam
		description = move.contest_description
		textpos = []
		imagepos = []
		# Draw all text
		pbDrawTextPositions(overlay, textpos)
		# Draw selected move's information
		imagepos.push(["Graphics/Pictures/Contest/move_heart#{hearts}", 166, 124]) if hearts > 0
		imagepos.push(["Graphics/Pictures/Contest/move_negaheart#{jam}", 166, 156]) if jam > 0
		pbDrawImagePositions(overlay, imagepos)
		# Draw selected move's description
		drawTextEx(overlay, 4, 224, 230, 5, description, base, shadow)
	end
	
	def pbScene
		@pokemon.play_cry
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  dorefresh = false
		  if Input.trigger?(Input::ACTION)
			pbSEStop
			@pokemon.play_cry
		  elsif Input.trigger?(Input::BACK)
			pbPlayCloseMenuSE
			break
		  elsif Input.trigger?(Input::USE)
			if @page == 4
			  pbPlayDecisionSE
			  pbMoveSelection
			  dorefresh = true
			elsif @page == 5
			  pbPlayDecisionSE
			  pbRibbonSelection
			  dorefresh = true
			elsif !@inbattle
			  pbPlayDecisionSE
			  dorefresh = pbOptions
			end
		  elsif Input.trigger?(Input::SPECIAL)
			if @page == 3 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  dorefresh = true
			end
			if @page == 4 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::UP) && @partyindex > 0
			oldindex = @partyindex
			pbGoToPrevious
			if @partyindex != oldindex
			  pbChangePokemon
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
			oldindex = @partyindex
			pbGoToNext
			if @partyindex != oldindex
			  pbChangePokemon
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
			oldpage = @page
			@page -= 1
			@page = 1 if @page < 1
			@page = 5 if @page > 5
			if @page != oldpage   # Move to next page
			  pbSEPlay("GUI summary change page")
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
			oldpage = @page
			@page += 1
			@page = 1 if @page < 1
			@page = 5 if @page > 5
			if @page != oldpage   # Move to next page
			  pbSEPlay("GUI summary change page")
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  end
		  if dorefresh
			disposeContestStats
			drawPage(@page)
		  end
		end
		return @partyindex
	end
	
	alias tdw_contests_summary_move_select drawSelectedMove
	def drawSelectedMove(move_to_learn, selected_move)
		if !@contestpage
			tdw_contests_summary_move_select(move_to_learn, selected_move)
		else
			drawSelectedContestMove(move_to_learn, selected_move)
		end
	end

	def pbMoveSelection
		@sprites["movesel"].visible = true
		@sprites["movesel"].index   = 0
		selmove    = 0
		oldselmove = 0
		switching = false
		drawSelectedMove(nil, @pokemon.moves[selmove])
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  if @sprites["movepresel"].index == @sprites["movesel"].index
			@sprites["movepresel"].z = @sprites["movesel"].z + 1
		  else
			@sprites["movepresel"].z = @sprites["movesel"].z
		  end
		  if Input.trigger?(Input::BACK)
			(switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
			break if !switching
			@sprites["movepresel"].visible = false
			switching = false
		  elsif Input.trigger?(Input::USE)
			pbPlayDecisionSE
			if selmove == Pokemon::MAX_MOVES
			  break if !switching
			  @sprites["movepresel"].visible = false
			  switching = false
			elsif !@pokemon.shadowPokemon?
			  if switching
				tmpmove                    = @pokemon.moves[oldselmove]
				@pokemon.moves[oldselmove] = @pokemon.moves[selmove]
				@pokemon.moves[selmove]    = tmpmove
				@sprites["movepresel"].visible = false
				switching = false
				drawSelectedMove(nil, @pokemon.moves[selmove])
			  else
				@sprites["movepresel"].index   = selmove
				@sprites["movepresel"].visible = true
				oldselmove = selmove
				switching = true
			  end
			end
		  elsif Input.trigger?(Input::UP)
			selmove -= 1
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = @pokemon.numMoves - 1
			end
			selmove = 0 if selmove >= Pokemon::MAX_MOVES
			selmove = @pokemon.numMoves - 1 if selmove < 0
			@sprites["movesel"].index = selmove
			pbPlayCursorSE
			drawSelectedMove(nil, @pokemon.moves[selmove])
		  elsif Input.trigger?(Input::DOWN)
			selmove += 1
			selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			selmove = 0 if selmove >= Pokemon::MAX_MOVES
			selmove = Pokemon::MAX_MOVES if selmove < 0
			@sprites["movesel"].index = selmove
			pbPlayCursorSE
			drawSelectedMove(nil, @pokemon.moves[selmove])
		  elsif Input.trigger?(Input::SPECIAL)
			if @page == 3 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  drawSelectedMove(nil, @pokemon.moves[selmove])
			end
			if @page == 4 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  drawSelectedMove(nil, @pokemon.moves[selmove])
			end
		  end
		end
		@sprites["movesel"].visible = false
	end
	

	def pbChooseMoveToForget(move_to_learn)
		new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
		selmove = 0
		maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  if Input.trigger?(Input::BACK)
			selmove = Pokemon::MAX_MOVES
			pbPlayCloseMenuSE if new_move
			break
		  elsif Input.trigger?(Input::USE)
			pbPlayDecisionSE
			break
		  elsif Input.trigger?(Input::UP)
			selmove -= 1
			selmove = maxmove if selmove < 0
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = @pokemon.numMoves - 1
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move, selected_move)
		  elsif Input.trigger?(Input::DOWN)
			selmove += 1
			selmove = 0 if selmove > maxmove
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = (new_move) ? maxmove : 0
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move, selected_move)
		  elsif Input.trigger?(Input::SPECIAL)
			if $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			  drawSelectedMove(new_move, selected_move)
			end
		  end
		end
		return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
	end
	
	def disposeContestStats
		@sprites["statsgraphbase"]&.dispose
		@sprites["statsgraph"]&.dispose
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
			6.times { |i|
				@sprites["#{arr[i]} bar"]&.dispose
			}
	end

	def pbCreateConditionBars(simple,bargraph)
		pkmn = @pokemon
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough"]
		fea = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough]
		imagepos = []
		xBase = 236
		xBaseAdj = 0
		xBase += xBaseAdj
		yBase = (simple ? 114 : 104)
		if bargraph
			5.times { |i|
				overlay = @sprites["overlay"].bitmap
				pbSetSmallFont(overlay)
				textpos = []
				barBitmap = AnimatedBitmap.new("Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_#{arr[i]}")
				@sprites["#{arr[i]} bar"] = Sprite.new(@viewport)
				@sprites["#{arr[i]} bar"].bitmap = barBitmap.bitmap
				@sprites["#{arr[i]} bar"].src_rect.width = fea[i]
				@sprites["#{arr[i]} bar"].x = xBase + 4
				@sprites["#{arr[i]} bar"].y = yBase + 48 * i
				@sprites["#{arr[i]} bar"].z = 5
				string = _INTL(arr[i])
				string_width = overlay.text_size(string).width
				textpos.push([string, xBase, yBase - 30 + 48 * i, 0, Color.new(96, 96, 112), Color.new(240, 248, 248)])
				pbDrawTextPositions(overlay, textpos)
				pbSetSystemFont(overlay)
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_bg", xBase, yBase + 48 * i])
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", xBase + string_width + 4, @sprites["#{arr[i]} bar"].y - 20]) if fea[i] >= 255
			}
		else
			pentagon_outline_color = Color.new(165, 83, 147)
			pentagon_back_color = Color.white
			pentagon_stat_color = Color.new(71, 226, 191)
			graphX = xBase + 130
			graphY = (simple ? 120 : 104) + 110
			@sprites["statsgraphbase"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
			pbDrawStatsPentagonBase(@sprites["statsgraphbase"], graphX, graphY, 77, pentagon_outline_color, pentagon_back_color)
			@sprites["statsgraph"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
			@sprites["statsgraph"].opacity = 180
			pbDrawStatsPentagon(@sprites["statsgraph"], [fea[0], fea[1], fea[2], fea[3], fea[4]], graphX, graphY, 77, pentagon_stat_color)
			xPos = [334, 436, 398, 270, 232]
			yPos = [100, 159, 284, 284, 159]
			5.times { |i|
				x = xPos[i]
				x += xBaseAdj
				y = yPos[i]
				y += (simple ? 16 : 0)
				imagepos.push(["Graphics/Pictures/Contest/contesttype", x, y, 0, i * 28, 64, 28])
				if fea[i] >= 255
					x = [400, 420, 464, 336, 298][i]
					x += xBaseAdj
					y = [118, 176, 302, 302, 176][i]
					y -= (simple ? 0 : 16)
					imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", x, y])
				end
			}
		end
		pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)
	end
		
end

#====================================================================================
#  Relearner
#====================================================================================

class MoveRelearner_Scene

  alias tdw_contests_relearner_start_scene pbStartScene
  def pbStartScene(pokemon, moves)
    @contestinfo = false
	tdw_contests_relearner_start_scene(pokemon, moves)
  end



  # Processes the scene
  def pbChooseMove
    oldcmd = -1
    pbActivateWindow(@sprites, "commands") {
      loop do
        oldcmd = @sprites["commands"].index
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index != oldcmd
          @sprites["background"].x = 0
          @sprites["background"].y = 78 + ((@sprites["commands"].index - @sprites["commands"].top_item) * 64)
          pbDrawMoveList
        end
        if Input.trigger?(Input::BACK)
          return nil
        elsif Input.trigger?(Input::USE)
          return @moves[@sprites["commands"].index]
		elsif Input.trigger?(Input::SPECIAL)
			if $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestinfo = !@contestinfo
			  pbPlayDecisionSE
			  pbDrawMoveList
			end
        end
      end
    }
  end
end
