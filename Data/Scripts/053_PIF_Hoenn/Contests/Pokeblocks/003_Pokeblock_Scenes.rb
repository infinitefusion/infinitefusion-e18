
#===============================================================================
# Pokeblock Case Scene
#=============================================================================== 

class PokeblockCase_Scene
	BASE_COLOR     = Color.new(88, 88, 80)
	SHADOW_COLOR   = Color.new(168, 184, 184)
	SIMPLE 		   = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
	NO_SHEEN	   = PokeblockSettings::DONT_USE_SHEEN
	ITEMSVISIBLE   = 10
	
	def pbStartScene
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
		@pokeblocks = $Trainer.pokeblocks
		#@sliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_slider")
		@sprites = {}
		@sprites["background"] = IconSprite.new(0, 0, @viewport)		
		@sprites["blocklist"] = Window_PokeblockCase.new(@pokeblocks, 210, -2, 314, 68 + (ITEMSVISIBLE * 32))
		@sprites["blocklist"].viewport    = @viewport
		@sprites["blocklist"].index       = 0
		@sprites["blocklist"].baseColor   = BASE_COLOR
		@sprites["blocklist"].shadowColor = SHADOW_COLOR
		@sprites["blockinfo"] = BitmapSprite.new(212, 116, @viewport)
		pbSetSystemFont(@sprites["blockinfo"].bitmap)
		@sprites["blockinfo"].x = 6 #Graphics.width-218
		@sprites["blockinfo"].y = Graphics.height-122
		@sprites["blockicon"] = BitmapSprite.new(48, 48, @viewport)
		@sprites["blockicon"].x = 164
		@sprites["blockicon"].y = 198
		@sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
		@sprites["overlay"].z=1000
		pbSetSystemFont(@sprites["overlay"].bitmap)
		pbDrawTextPositions(@sprites["overlay"].bitmap,[["Pokéblock Case",115,16,2,BASE_COLOR,SHADOW_COLOR]])
		@sprites["blocktext"] = Window_UnformattedTextPokemon.newWithSize(
		  "", 72, 272, Graphics.width - 72 - 24, 128, @viewport
		)
		@sprites["blocktext"].baseColor   = BASE_COLOR
		@sprites["blocktext"].shadowColor = SHADOW_COLOR
		@sprites["blocktext"].visible     = true
		@sprites["blocktext"].windowskin  = nil
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
		@sprites["helpwindow"].visible  = false
		@sprites["helpwindow"].viewport = @viewport
		@sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
		@sprites["msgwindow"].visible  = false
		@sprites["msgwindow"].viewport = @viewport
		@sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
		@sprites["uparrow"].x = 356
		@sprites["uparrow"].y = 0
		@sprites["uparrow"].z = 999
		@sprites["uparrow"].play
		@sprites["uparrow"].visible = false
		@sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
		@sprites["downarrow"].x = 356
		@sprites["downarrow"].y = 348
		@sprites["downarrow"].z = 999
		@sprites["downarrow"].play
		@sprites["downarrow"].visible = false
		pbBottomLeftLines(@sprites["helpwindow"], 1)
		pbDeactivateWindows(@sprites)
		pbRefresh
		pbFadeInAndShow(@sprites)
	end

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		#@sliderbitmap.dispose
		@viewport.dispose
	end

	def pbDisplay(msg, brief = false)
		UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
	end

	def pbConfirm(msg)
		UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
	end

	def pbShowCommands(helptext, commands, index = 0)
		return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
	end

	def pbRefresh
		# Set the background image
		@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Pokeblock/UI Pokeblock/pokeblock_background"))
		pbDrawImagePositions(@sprites["background"].bitmap,[["Graphics/Pictures/Pokeblock/UI Pokeblock/pokeblock_bg_lv",Graphics.width-50,0]]) if !SIMPLE
		# Refresh the item window
		@sprites["blocklist"].refresh
		# Refresh more things
		pbRefreshIndexChanged
	end

	def pbRefreshIndexChanged
		itemlist = @sprites["blocklist"]
		@sprites["uparrow"].visible   = itemlist.top_row > 0
		@sprites["downarrow"].visible = itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
		pbDrawBlockInfo(itemlist.item)
	end
	
	def pbDrawBlockInfo(block)
		bitmap = @sprites["blockinfo"].bitmap
		bitmap.clear
		imagepos = []
		textpos = []
		arr = ["Red", "Blue", "Pink", "Green", "Yellow"]
		arr2 = ["Spicy", "Dry", "Sweet", "Bitter", "Sour"]
		5.times { |i|	
			x = i < 3 ? 8 : 104
			y = 2 + (i % 3) * 32
			imagepos.push(["Graphics/Pictures/Pokeblock/Blocks/"+arr[i],x,y+12]) if block.flavor[i] > 0 if block
			textpos.push([arr2[i],x+20,y-2,0,BASE_COLOR,SHADOW_COLOR])
		}
		x = 110
		y = 80
		smooth = block ? block.smoothness : ""
		textpos.push(["Feel: #{smooth}",x,y,0,BASE_COLOR,SHADOW_COLOR]) if !SIMPLE && !NO_SHEEN
		pbDrawImagePositions(bitmap,imagepos)
		pbDrawTextPositions(bitmap,textpos)
		
		item = @sprites["blockicon"].bitmap
		item.clear
		imagepos.push(["Graphics/Pictures/Pokeblock/Blocks/Block_"+GameData::PokeblockColor.get(block.color).name+(block.plus ? "_Plus" : ""),0,0]) if block
		pbDrawImagePositions(item,imagepos)
	end

	# Called when the item screen wants an item to be chosen from the screen
	def pbChooseItem
		@sprites["helpwindow"].visible = false
		itemwindow = @sprites["blocklist"]
		swapinitialpos = -1
		pbActivateWindow(@sprites, "blocklist") {
			loop do
				oldindex = itemwindow.index
				Graphics.update
				Input.update
				pbUpdate
				if itemwindow.index != oldindex
					pbRefresh
				end
				if Input.trigger?(Input::BACK)   # Cancel the item screen
					pbPlayCloseMenuSE
					return nil
				elsif Input.trigger?(Input::USE)   # Choose selected item
					(itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
					return itemwindow.item
				end
			end
		}
	end

end

class PokeblockCase_Screen
	def initialize(scene)
		@scene = scene
		@pokeblocks = $Trainer.pokeblocks
	end

	def pbStartScreen
		@scene.pbStartScene
		item = nil
		
		loop do
			item = @scene.pbChooseItem
			break if !item
			cmdUse      = -1
			cmdToss     = -1
			cmdDebug    = -1
			commands = []
			# Generate command list
			commands[cmdUse = commands.length]    = _INTL("Use")
			commands[cmdToss = commands.length]   = _INTL("Toss")
			commands[cmdDebug = commands.length]  = _INTL("Debug") if $DEBUG
			commands[commands.length]             = _INTL("Cancel")
			# Show commands generated above
			itemname = item.name
			command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
			if cmdUse >= 0 && command == cmdUse   # Use item
				ret = pbFeedPokeblock(item, @scene)
				# ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
				break if ret == 2   # End screen
				@scene.pbRefresh
				next
			elsif cmdToss >= 0 && command == cmdToss   # Toss item
				# qty = @bag.quantity(item)
				# if qty > 1
				  # helptext = _INTL("Toss out how many {1}?", itm.name_plural)
				  # qty = @scene.pbChooseNumber(helptext, qty)
				# end
				# if qty > 0
				  # itemname = itm.name_plural if qty > 1
				  # if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
					# pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
					# qty.times { @bag.remove(item) }
					# @scene.pbRefresh
				  # end
				# end
				if pbConfirm(_INTL("Is it OK to throw away the {1}?", itemname))
					pbDisplay(_INTL("Threw away the {1}.", itemname))
					#@pokeblocks.remove(item)
					pbRemovePokeblock(item)
					@scene.pbRefresh
				end
			elsif cmdDebug >= 0 && command == cmdDebug   # Debug
				command = 0
				loop do
				  command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
												  [_INTL("Change flavor"),_INTL("Change feel"),
												   _INTL("Cancel")], command)
				  case command
				  ### Cancel ###
				  when -1, 2
					break
				  ### Change flavor ###
				  when 0
					flavor = item.flavor
					fNames = ["Spicy", "Dry", "Sweet", "Bitter", "Sour"]
					flavor.each_with_index { |f,i|
						params = ChooseNumberParams.new
						params.setRange(0, 99)
						params.setDefaultValue(f)
						value = pbMessageChooseNumber(
						  _INTL("Choose new {1} value (max. 99).", fNames[i]), params
						) { @scene.pbUpdate }
						item.flavor[i] = value
					}
					item.level = item.flavor.max
					@scene.pbRefresh
				  ### Change feel ###
				  when 1
					feel = item.smoothness
					params = ChooseNumberParams.new
					params.setRange(0, 255)
					params.setDefaultValue(feel)
					item.smoothness = pbMessageChooseNumber(
						  _INTL("Choose new Feel value (max. 255)."), params
						) { @scene.pbUpdate }
					@scene.pbRefresh
				  end
				end
			end
		end		
		@scene.pbEndScene
		return item
	end

	def pbDisplay(text)
		@scene.pbDisplay(text)
	end

	def pbConfirm(text)
		return @scene.pbConfirm(text)
	end

	# UI logic for the item screen for choosing an item.
	def pbChooseItemScreen(proc = nil)
		oldlastpocket = @bag.last_viewed_pocket
		oldchoices = @bag.last_pocket_selections.clone
		@bag.reset_last_selections if proc
		@scene.pbStartScene(@bag, true, proc)
		item = @scene.pbChooseItem
		@scene.pbEndScene
		@bag.last_viewed_pocket = oldlastpocket
		@bag.last_pocket_selections = oldchoices
		return item
	end
	
end

class Window_PokeblockCase < Window_DrawableCommand
	attr_accessor :sorting
	SIMPLE 		   = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
	NO_SHEEN	   = PokeblockSettings::DONT_USE_SHEEN

	def initialize(list, x, y, width, height)
		@list        = list
		@sorting = false
		super(x, y, width, height)
		@selarrow  = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor")
		self.windowskin = nil
	end

	def page_row_max; return PokeblockCase_Scene::ITEMSVISIBLE; end
	def page_item_max; return PokeblockCase_Scene::ITEMSVISIBLE; end

	def item
		item = @list[self.index]
		return item ? item : nil
	end

	def itemCount
		return @list.length + 1
	end

	def itemRect(item)
		if item < 0 || item >= @item_max || item < self.top_item - 1 ||
			item > self.top_item + self.page_item_max
			return Rect.new(0, 0, 0, 0)
		else
			cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
			x = item % @column_max * (cursor_width + @column_spacing)
			y = (item / @column_max * @row_height) - @virtualOy
			return Rect.new(x, y, cursor_width, @row_height)
		end
	end

	def drawCursor(index, rect)
		if self.index == index
			bmp = (@sorting) ? @swaparrow.bitmap : @selarrow.bitmap
			pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
		end
	end

	def drawItem(index, _count, rect)
		textpos = []
		rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
		if index == self.itemCount - 1
			textpos.push([_INTL("CLOSE CASE"), rect.x, rect.y + 2, false, self.baseColor, self.shadowColor])
		else
			item = @list[index]
			baseColor   = self.baseColor
			shadowColor = self.shadowColor
			textpos.push(
				[item.name, rect.x, rect.y + 2, false, baseColor, shadowColor]
			)
			if item.level && !SIMPLE
				level = item.level.to_s
				xLvl = rect.x + rect.width - self.contents.text_size(level).width - 16
				textpos.push([level, xLvl, rect.y + 2, false, baseColor, shadowColor])
			end

			# qty = 1 #@list[index][1]
			# qtytext = _ISPRINTF("x{1: 3d}", qty)
			# xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
			# textpos.push([qtytext, xQty, rect.y + 2, false, baseColor, shadowColor])
		end
		pbDrawTextPositions(self.contents, textpos)
	end	

	def refresh
		@item_max = itemCount
		self.update_cursor_rect
		dwidth  = self.width - self.borderX
		dheight = self.height - self.borderY
		self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
		self.contents.clear
		@item_max.times do |i|
			next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
			drawItem(i, @item_max, itemRect(i))
		end
		drawCursor(self.index, itemRect(self.index))
	end

	def update
		super
		@uparrow.visible   = false
		@downarrow.visible = false
	end

end

#===============================================================================
# Pokeblock Condition Scene
#=============================================================================== 

class PokeblockCondition_Scene
	include BopModule
	BASE_COLOR     = Color.new(248, 248, 248)
	SHADOW_COLOR   = Color.new(104, 104, 104)
	PENTAGON_OUTLINE_COLOR = Color.new(165,83,147)
	PENTAGON_BACK_COLOR = pbColor(:WHITE)
	PENTAGON_STAT_COLOR = Color.new(71,226,191)
	SIMPLE 		   = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
	NO_SHEEN	   = PokeblockSettings::DONT_USE_SHEEN
	
	def initialize(block,party)
		@block = block
		@party = party
	end
	
	def pbStartScene
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@index = 0
		pbCreateConditionBars
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["pokemon"] = PokemonSprite.new(@viewport)
		@sprites["pokemon"].setOffset(PictureOrigin::Center)
		@sprites["pokemon"].x = 104
		@sprites["pokemon"].y = 206
		@sprites["pokemon"].setPokemonBitmap(@party[@index])
		@sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
		pbSetSystemFont(@sprites["overlay"].bitmap)	
		@sprites["statsgraphbase"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport) if !useBarGraph
		pbDrawStatsPentagonBase(@sprites["statsgraphbase"],236+130,((SIMPLE || NO_SHEEN) ? 126 : 104)+110,77,PENTAGON_OUTLINE_COLOR,PENTAGON_BACK_COLOR) if !useBarGraph
		@sprites["statsgraph"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
		@sprites["statsgraph"].opacity = 180
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
		@sprites["helpwindow"].visible  = false
		@sprites["helpwindow"].viewport = @viewport
		@sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
		@sprites["msgwindow"].visible  = false
		@sprites["msgwindow"].viewport = @viewport	
		pbBottomLeftLines(@sprites["helpwindow"], 1)
		pbDeactivateWindows(@sprites)
		pbRefresh
		pbFadeInAndShow(@sprites)
		@party[@index].play_cry
	end

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end

	def pbChoosePokemon
		@sprites["helpwindow"].visible = false
		oldindex = @index
		loop do
			Graphics.update
			Input.update
			pbUpdate
			dorefresh = false
			if Input.trigger?(Input::BACK)   # Cancel the item screen
				pbPlayCloseMenuSE
				return nil
			elsif Input.trigger?(Input::USE)   # Choose selected item
				if !@block
					pbPlayCloseMenuSE
					return nil
				end
				if @party[@index].sheen >= 255 
					pbMessage(_INTL("{1} can't eat anymore.", @party[@index].name))
				elsif (SIMPLE || NO_SHEEN) && @party[@index].totalContestStats >= 1275
					pbMessage(_INTL("{1} can't eat anymore Pokéblocks.", @party[@index].name))
				elsif (SIMPLE || NO_SHEEN) && (@block.color == :Red && @party[@index].cool >= 255) || (@block.color == :Blue && @party[@index].beauty >= 255) || 
						(@block.color == :Pink && @party[@index].cute >= 255) || (@block.color == :Green && @party[@index].smart >= 255) || 
						(@block.color == :Yellow && @party[@index].tough >= 255)
					pbMessage(_INTL("{1} can't eat anymore of this type of Pokéblock.", @party[@index].name))
				else
					pbPlayDecisionSE
					return @party[@index]
				end
			elsif Input.trigger?(Input::UP) && @index > 0
				oldindex = @index
				@index -= 1
			elsif Input.trigger?(Input::DOWN) && @index < @party.length - 1
				oldindex = @index
				@index += 1
			end
			if @index != oldindex
				pbChangePokemon
				pbRefresh
				oldindex = @index
			end
		end
	end
		
	def pbAtePokeblock
		pkmn = @party[@index]
		oldf = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]

		# Set animation "Up"
		6.times { |i|
			create_sprite("up animation #{i}", "Up_arrow", @viewport,"UI Pokeblock") if !@sprites["up animation #{i}"]
			if useBarGraph
				x = 496 - @sprites["up animation #{i}"].bitmap.width
				y = 112 - @sprites["up animation #{i}"].bitmap.height + 48 * i + ((SIMPLE || NO_SHEEN) ? 22 : 0)
				set_xy_sprite("up animation #{i}", x, y)
				set_visible_sprite("up animation #{i}")
			else
			xPos = [350,452,414,286,248,496 - @sprites["up animation #{i}"].bitmap.width]
			yPos = [90,148,274,274,148,112 - @sprites["up animation #{i}"].bitmap.height + 48 * i]
				x = xPos[i]
				y = yPos[i] 
				y += ((SIMPLE || NO_SHEEN) ? 22 : 0) if i == 5
				y -= ((SIMPLE || NO_SHEEN) ? 0 : 16) if i < 5
				set_xy_sprite("up animation #{i}", x, y)
				set_visible_sprite("up animation #{i}")
			end
		}
		pbWait(10)
		flavor = BerryPoffin.nature(pkmn.nature.id,@block.flavor)
		feel = @block.smoothness
		pkmn.cool   += pbFlavorValue(flavor[0],pkmn,@block.plus)
		pkmn.beauty += pbFlavorValue(flavor[1],pkmn,@block.plus)
		pkmn.cute   += pbFlavorValue(flavor[2],pkmn,@block.plus)
		pkmn.smart  += pbFlavorValue(flavor[3],pkmn,@block.plus)
		pkmn.tough  += pbFlavorValue(flavor[4],pkmn,@block.plus)
		pkmn.sheen  += feel if !SIMPLE && !NO_SHEEN
		pkmn.cool    = 255 if pkmn.cool   > 255
		pkmn.beauty  = 255 if pkmn.beauty > 255
		pkmn.cute    = 255 if pkmn.cute   > 255
		pkmn.smart   = 255 if pkmn.smart  > 255
		pkmn.tough   = 255 if pkmn.tough  > 255
		pkmn.sheen   = 255 if pkmn.sheen  > 255
		newf = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]
		pbUpdateConditionBars
		# Animation (Up)
		oldf.each_with_index { |f, i|
			next if f == newf[i]
			set_visible_sprite("up animation #{i}", true)
		}
		pbWait(30)
		loop do
			Input.update
			break if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
		end
		6.times { |i| set_visible_sprite("up animation #{i}") }
		pbRemovePokeblock(@block)
		
	end
	
	def pbFlavorValue(fVal,pkmn,plus)
		return fVal if !SIMPLE
		statTotal = pkmn.totalContestStats
		if !plus
			if statTotal >= 1024 then fVal = 2
			elsif statTotal >= 768 then fVal = 3
			elsif statTotal >= 512 then fVal = 4
			elsif statTotal >= 256 then fVal = 6
			end #8
		end
		return fVal
	end

	def pbEndScene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbDisplay(msg, brief = false)
		UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
	end

	def pbConfirm(msg)
		UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
	end

	def pbShowCommands(helptext, commands, index = 0)
		return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
	end

	def pbRefresh
		# Set the background image
		file = "Graphics/Pictures/Pokeblock/UI Pokeblock/condition_background_m" +(useBarGraph ? "" : "_graph")+ ((SIMPLE || NO_SHEEN) ? "_simple" : "")
		@sprites["background"].setBitmap(sprintf(file))
		# Refresh more things
		pbDrawPokemonInfo
	end
	
	def pbCreateConditionBars
		pkmn = @party[@index]
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
		fea = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]
		xBase = 236
		yBase = ((SIMPLE || NO_SHEEN) ? 126 : 104)
		if useBarGraph
			6.times { |i|
				create_sprite("#{arr[i]} bar", "Bar_#{arr[i]}", @viewport, "UI Pokeblock")
				x = xBase - 255
				y = yBase + 48 * i
				set_xy_sprite("#{arr[i]} bar", x, y)
			}
		else
			if !(SIMPLE || NO_SHEEN)
				create_sprite("Sheen bar", "Bar_Sheen", @viewport, "UI Pokeblock")
				x = xBase - 255
				y = yBase + 48 * 5
				set_xy_sprite("Sheen bar", x, y)
			end
		end
	end
	
	def pbUpdateConditionBars
		pkmn = @party[@index]
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
		fea = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]
		xBase = 236
		yBase = ((SIMPLE || NO_SHEEN) ? 126 : 104)
		if useBarGraph
			6.times { |i|
				x = xBase - 255 + fea[i]
				y = yBase + 48 * i
				set_xy_sprite("#{arr[i]} bar", x, y)
			}
		else
			@sprites["statsgraph"].bitmap.clear
			graphY = yBase+110
			pbDrawStatsPentagon(@sprites["statsgraph"],[fea[0],fea[1],fea[2],fea[3],fea[4]],xBase+130,graphY,77,PENTAGON_STAT_COLOR)
			if !(SIMPLE || NO_SHEEN)
				#create_sprite("Sheen bar", "Bar_Sheen", @viewport, "UI Pokeblock")
				x = xBase - 255
				y = yBase + 48 * 5
				set_xy_sprite("Sheen bar", x, y)
			end
		end
	end
	
	def pbDrawPokemonInfo
		overlay = @sprites["overlay"].bitmap
		overlay.clear
		pkmn = @party[@index]
		imagepos = []
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
		fea = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]
		xBase = 236
		yBase = ((SIMPLE || NO_SHEEN) ? 126 : 104)
		if useBarGraph
			6.times { |i|
				x = xBase - 255 + fea[i]
				y = yBase + 48 * i
				set_xy_sprite("#{arr[i]} bar", x, y)
				next if (SIMPLE || NO_SHEEN) && i == 5
				maxAdjust = 0
				maxAdjust = 16 if i == 1
				maxAdjust = 12 if i == 3 || i == 4
				maxAdjust = 8 if i == 5
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", xBase+56+maxAdjust, y-20]) if fea[i] >=255
			}
		else				
			@sprites["statsgraph"].bitmap.clear
			graphY = yBase+110
			pbDrawStatsPentagon(@sprites["statsgraph"],[fea[0],fea[1],fea[2],fea[3],fea[4]],xBase+130,graphY,77,PENTAGON_STAT_COLOR)
			xPos = [400,420,464,336,298]
			yPos = [118,176,302,302,176]
			5.times { |i|
				next if fea[i] <255
				x = xPos[i]
				y = yPos[i] 
				y -= ((SIMPLE || NO_SHEEN) ? 0 : 16)
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", x, y])
			}
			if !(SIMPLE || NO_SHEEN)
				x = xBase - 255 + fea[5]
				y = yBase + 48 * 5
				set_xy_sprite("Sheen bar", x, y)
				maxAdjust = 8
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", xBase+56+maxAdjust, y-20]) if fea[5] >=255
			end
		end
		# Scene pokemon
		# x = 470
		# y = 290
		# Party
		# @party.size.times { |i|
			# create_sprite("ball #{i}", "ball", @viewport)
			# w = @sprites["ball #{i}"].bitmap.width / 2
			# h = @sprites["ball #{i}"].bitmap.height
			# set_src_wh_sprite("ball #{i}", w, h)
			# set_src_xy_sprite("ball #{i}", w * (i == @index ? 1 : 0), 0)
			# set_oxoy_sprite("ball #{i}", w / 2, h / 2)
			# x = 470 + 42 / 2
			# y = 290 - (w + 15) * (@party.size - i)
			# set_xy_sprite("ball #{i}", x, y)
		# }
		# Pokemon
		# Show the Poké Ball containing the Pokémon
		ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", pkmn.poke_ball)
		imagepos.push([ballimage, 14, 60])
		# Show shininess star
		if pkmn.shiny?
		  imagepos.push([sprintf("Graphics/Pictures/shiny"), 2, 134])
		end
		textpos = [
		  [_INTL("CONDITION"), 26, 10, 0, BASE_COLOR, SHADOW_COLOR],
		  [pkmn.name, 46, 52, 0, BASE_COLOR, SHADOW_COLOR],
		  [pkmn.level.to_s, 46, 86, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
		  [_INTL("Nature"), 16, 308, 0, BASE_COLOR, SHADOW_COLOR],
		  [pkmn.nature.name, 16, 342, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)]
		]	
		# Write the gender symbol
		if pkmn.male?
		  textpos.push([_INTL("♂"), 178, 52, 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
		elsif pkmn.female?
		  textpos.push([_INTL("♀"), 178, 52, 0, Color.new(248, 56, 32), Color.new(224, 152, 144)])
		end	
		pbDrawImagePositions(overlay, imagepos)
		pbDrawTextPositions(overlay, textpos)
	end
	
	def pbChangePokemon
		@sprites["pokemon"].setPokemonBitmap(@party[@index])
		pbSEStop
		@party[@index].play_cry
	end

	#------------#
	# Set bitmap #
	#------------#
	# Image
	def create_sprite(spritename,filename,vp,dir="")
		@sprites["#{spritename}"] = Sprite.new(vp)
		folder = "Pokeblock"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	def set_sprite(spritename,filename,dir="")
		folder = "Pokeblock"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	
	def useBarGraph
		return (PluginManager.installed?("Better Bitmaps") ? PokeblockSettings::STATS_BAR_GRAPH : true)
	end
	
end

class PokeblockCondition_Screen
	def initialize(scene,party)
		@scene = scene
		@party = party
	end

	def pbStartScreen(pokeblock)
		@scene.pbStartScene
		@block = pokeblock
		ret = 0
		loop do
			pkmn = @scene.pbChoosePokemon
			break if !pkmn || !@block
			cmdUse		= -1
			commands = []
			# Generate command list
			commands[cmdUse = commands.length]    = _INTL("Yes")
			commands[commands.length]             = _INTL("No")
			pkmnname = pkmn.name
			blockname = @block.name
			command = @scene.pbShowCommands(_INTL("Feed {1} the {2}?", pkmnname, blockname), commands)
			if cmdUse >= 0 && command == cmdUse   # Use item
				pbFadeOutIn {
					scene = PokeblockEat_Scene.new(@block,pkmn)
					screen = PokeblockEat_Screen.new(scene)
					ret = screen.pbStartScreen
				}
				@scene.pbAtePokeblock
				break
			end
		end
		@scene.pbEndScene
		return ret
	end

	def pbDisplay(text)
		@scene.pbDisplay(text)
	end

	def pbConfirm(text)
		return @scene.pbConfirm(text)
	end
	
end

#===============================================================================
# Pokeblock Eat Scene
#=============================================================================== 
class PokeblockEat_Scene
	include BopModule

	def initialize(pokeblock,pokemon)
		@pokeblock = pokeblock
		@pokemon = pokemon
	end

	def pbStartScene
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Pokeblock/UI Pokeblock/eat_scene"))
		#Pokemon
		@sprites["pokemon"] = PokemonSprite.new(@viewport)
		@sprites["pokemon"].setOffset(PictureOrigin::Center)
		# @sprites["pokemon"].x = 104
		# @sprites["pokemon"].y = 206
		@sprites["pokemon"].setPokemonBitmap(@pokemon)
		h = @sprites["pokemon"].bitmap.height
		set_src_wh_sprite("pokemon", h, h)
		set_oxoy_sprite("pokemon", h / 2, h / 2)
		x = h / 2
		y = 120 + 142 / 2
		set_xy_sprite("pokemon", x, y)
		@sprites["pokemon"].mirror = true
		set_visible_sprite("pokemon", true)
		#Pokeblock Case
		create_sprite("pokeblock", "Pokeblock", @viewport, "UI Pokeblock")
		ox = @sprites["pokeblock"].bitmap.width / 2
		oy = @sprites["pokeblock"].bitmap.height / 2
		set_oxoy_sprite("pokeblock", ox, oy)
		x = Graphics.width - ox - 10
		y = 200
		set_xy_sprite("pokeblock", x, y)
		@sprites["pokeblock"].mirror = true
		set_visible_sprite("pokeblock", true)
		@sprites["pokeblock"].z = 1
		#Pokeblock
		create_sprite("flavor eat", @pokeblock.color_name, @viewport,"Blocks")
		set_sprite("flavor eat", @pokeblock.color_name,"Blocks")
		x = @sprites["pokeblock"].x - ox + @sprites["flavor eat"].bitmap.width
		y = @sprites["pokeblock"].y - oy + @sprites["flavor eat"].bitmap.height
		set_xy_sprite("flavor eat", x, y)
		set_visible_sprite("flavor eat", true)
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
		@sprites["helpwindow"].visible  = false
		@sprites["helpwindow"].viewport = @viewport
		@sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
		@sprites["msgwindow"].visible  = false
		@sprites["msgwindow"].viewport = @viewport	
		pbBottomLeftLines(@sprites["helpwindow"], 1)
		pbDeactivateWindows(@sprites)
		#pbRefresh
		pbFadeInAndShow(@sprites)
	end
	
	def pbScene
		angle = 0
		14.times { |i|
			pbUpdateAll
			i < 14 / 2 ? (angle += 2) : (angle -= 2)
			set_angle_sprite("pokeblock", angle)
		}
		# Animation
		t   = 1
		x0  = @sprites["flavor eat"].x
		y0  = @sprites["flavor eat"].y
		div = 90 / 20
		loop do
			Graphics.update
			pbUpdate
			if @sprites["flavor eat"].x > 200
				r  = 35
				t += 0.1
				x  = -r*(t-Math.sin(t))
				y  = -r*(1-Math.cos(t))
				x += x0
				y += y0
				set_xy_sprite("flavor eat", x, y)
				if @sprites["flavor eat"].x.between?(200, 260)
					@sprites["pokemon"].x += div + 5
					@sprites["pokemon"].y -= div
				end
			else
				set_visible_sprite("flavor eat")
				break
			end
		end
		22.times {
			pbUpdateAll
			@sprites["pokemon"].x += div / 2
			@sprites["pokemon"].y += div / 2
		}
		# Cry
		@pokemon.play_cry
		pbMessage(_INTL("{1} ate the {2}!",@pokemon.name,@pokeblock.name))
	
	end

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end

	def pbUpdateAll
		Graphics.update
		Input.update
		pbUpdateSpriteHash(@sprites)
	end

	def pbEndScene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbDisplay(msg, brief = false)
		UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
	end

	# def pbRefresh
		# # Set the background image
		# # Refresh more things

	# end
	
	#------------#
	# Set bitmap #
	#------------#
	# Image
	def create_sprite(spritename,filename,vp,dir="")
		@sprites["#{spritename}"] = Sprite.new(vp)
		folder = "Pokeblock"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	def set_sprite(spritename,filename,dir="")
		folder = "Pokeblock"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end	
	
end

class PokeblockEat_Screen
	def initialize(scene)
		@scene = scene
	end

	def pbStartScreen
		@scene.pbStartScene
		@scene.pbScene
		@scene.pbEndScene
		return 
	end

	def pbDisplay(text)
		@scene.pbDisplay(text)
	end

end

#===============================================================================
# Pokeblock Kit Scene
#=============================================================================== 

class PokeblockKit_Scene

	def pbUpdate
		@commands.length.times do |i|
			@sprites["button#{i}"].selected = (i == @index)
		end
		pbUpdateSpriteHash(@sprites)
	end

	def pbStartScene(commands)
		@commands = commands
		@index = 0
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/Pokeblock/UI Pokeblock/kit_background")
		@commands.length.times do |i|
			@sprites["button#{i}"] = PokeblockKitButton.new(@commands[i], Graphics.width / 2, 0, @viewport)
			button_height = @sprites["button#{i}"].bitmap.height / 2
			@sprites["button#{i}"].y = ((Graphics.height - (@commands.length * button_height)) / 2) + (i * button_height)
		end
		pbFadeInAndShow(@sprites) { pbUpdate }
	end

	def pbScene
		ret = -1
		loop do
			Graphics.update
			Input.update
			pbUpdate
			if Input.trigger?(Input::BACK)
				pbPlayCloseMenuSE
				break
			elsif Input.trigger?(Input::USE)
				pbPlayDecisionSE
				ret = @index
				break
			elsif Input.trigger?(Input::UP)
				pbPlayCursorSE if @commands.length > 1
				@index -= 1
				@index = @commands.length - 1 if @index < 0
			elsif Input.trigger?(Input::DOWN)
				pbPlayCursorSE if @commands.length > 1
				@index += 1
				@index = 0 if @index >= @commands.length
			end
		end
		return ret
	end

	def pbEndScene
		pbFadeOutAndHide(@sprites) { pbUpdate }
		dispose
	end

	def dispose
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

end

class PokeblockKit_Screen
	SIMPLE 		   = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
	def initialize(scene)
		@scene = scene
	end

	def pbStartScreen
		# Get all commands
		command_list = [_INTL("Give Pokéblocks"),_INTL("Make Pokéblocks"),_INTL("View Condition"),_INTL("Put Away Kit")]
		@scene.pbStartScene(command_list)
		# Main loop
		end_scene = false
		loop do
			choice = @scene.pbScene
			if choice < 0 || choice == 3
				end_scene = true
				break
			elsif choice == 0
				pbPokeblockCase
			elsif choice == 1
				if SIMPLE then pbBerryBlenderSimple;
				else pbBerryBlender; end
			elsif choice == 2
				pbPokeblockCondition
			end
		end
		@scene.pbEndScene if end_scene
	end

end

class PokeblockKitButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @name  = command
    @selected = false
    @button = AnimatedBitmap.new("Graphics/Pictures/Pokeblock/UI Pokeblock/kit_button")
    @contents = BitmapWrapper.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
  end
end

#===============================================================================
# Multi Berry Selection Scene
#=============================================================================== 

class MultiBerrySelection_Scene
  ITEMLISTBASECOLOR     = Color.new(88, 88, 80)
  ITEMLISTSHADOWCOLOR   = Color.new(168, 184, 184)
  ITEMTEXTBASECOLOR     = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0, 0, 0)
  ITEMSVISIBLE          = 7

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag, choosing, filterproc)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag        = bag
    @choosing   = choosing
    @filterproc = filterproc
	@selectedBerries = []
    pbRefreshFilter
    if @choosing
      if (@filterlist && @filterlist.length == 0)

      end
    end
    @sliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_slider")
    # @pocketbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_pocket")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["selectedberries"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
	drawSelectedBerryCircles
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["itemlist"] = Window_MultiBerrySelection.new(@bag, @filterlist, self, 168, -8, 314, 40 + 32 + (ITEMSVISIBLE * 32))
    @sprites["itemlist"].viewport    = @viewport
    @sprites["itemlist"].index       = 0
    @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemicon"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    @sprites["berryicon1"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    @sprites["berryicon2"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    @sprites["berryicon3"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    @sprites["berryicon4"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
	@sprites["berryicon1"].visible = @sprites["berryicon2"].visible = @sprites["berryicon3"].visible = @sprites["berryicon4"].visible = false
    @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize(
      "", 72, 272, Graphics.width - 72 - 24, 128, @viewport
    )
    @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtext"].visible     = true
    @sprites["itemtext"].windowskin  = nil
	@sprites["itemcolor"] = BitmapSprite.new(186, 64, @viewport)
	@sprites["itemcolor"].y = 224
    pbSetSystemFont(@sprites["itemcolor"].bitmap)
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbFadeOutScene
    @oldsprites = pbFadeOutAndHide(@sprites)
  end

  def pbFadeInScene
    pbFadeInAndShow(@sprites, @oldsprites)
    @oldsprites = nil
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) if !@oldsprites
    @oldsprites = nil
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @viewport.dispose
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
  end

  def pbShowCommands(helptext, commands, index = 0)
    return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
  end

  def pbRefresh
    # Set the background image
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Pokeblock/UI Berry Blender/SimpleBerrySelection"))
    # Refresh the item window
    @sprites["itemlist"].refresh
    # Refresh more things
	drawSelectedBerries
    pbRefreshIndexChanged
  end
  
  def drawSelectedBerryCircles
	imagepos = []
	4.times { |i| imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/berry_select_circle", 25 + (i%2 != 0 ? 75 : 0), 70 + (i>1 ? 75 : 0)]) }
	pbDrawImagePositions(@sprites["selectedberries"].bitmap, imagepos)
  end
  
  def drawSelectedBerries
	4.times { |i| 
		if @selectedBerries[i]
			iconName = "berryicon#{i+1}"
			@sprites[iconName].item = @selectedBerries[i]
			@sprites[iconName].x = 55 + (i%2 != 0 ? 75 : 0)
			@sprites[iconName].y = 100 + (i>1 ? 75 : 0)
			@sprites[iconName].visible = true
		end
	}
  end

  def pbRefreshIndexChanged
    itemlist = @sprites["itemlist"]
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Draw slider arrows
    showslider = false
    if itemlist.top_row > 0
      overlay.blt(470, 16, @sliderbitmap.bitmap, Rect.new(0, 0, 36, 38))
      showslider = true
    end
    if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
      overlay.blt(470, 228, @sliderbitmap.bitmap, Rect.new(0, 38, 36, 38))
      showslider = true
    end
    # Draw slider box
    if showslider
      sliderheight = 174
      boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 38].max
      y = 54
      y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
      overlay.blt(470, y, @sliderbitmap.bitmap, Rect.new(36, 0, 36, 4))
      i = 0
      while i * 16 < boxheight - 4 - 18
        height = [boxheight - 4 - 18 - (i * 16), 16].min
        overlay.blt(470, y + 4 + (i * 16), @sliderbitmap.bitmap, Rect.new(36, 4, 36, height))
        i += 1
      end
      overlay.blt(470, y + boxheight - 18, @sliderbitmap.bitmap, Rect.new(36, 20, 36, 18))
    end
    # Set the selected item's icon
    @sprites["itemicon"].item = itemlist.item
    # Set the selected item's description
    @sprites["itemtext"].text =
      (itemlist.item) ? GameData::Item.get(itemlist.item).description : _INTL("Close bag.")
    # Set the selected item's color
	@sprites["itemcolor"].bitmap.clear
	pbDrawTextPositions(@sprites["itemcolor"].bitmap, [[(itemlist.item ? GameData::BerryData.get(itemlist.item).block_color_name.to_s : ""),
			92, 16, 2, GameData::BerryColor.get(GameData::BerryData.get(itemlist.item).block_color).base_color, 
			GameData::BerryColor.get(GameData::BerryData.get(itemlist.item).block_color).shadow_color]]) if itemlist.item
  end

  def pbRefreshFilter
    @filterlist = nil
    return if !@choosing
    return if @filterproc.nil?
    @filterlist = []
    (1...@bag.pockets.length).each do |i|
      @bag.pockets[i].length.times do |j|
        @filterlist.push(j) if @filterproc.call(@bag.pockets[i][j][0])
      end
    end
  end

  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemlist"]
    pbActivateWindow(@sprites, "itemlist") {
      loop do
        oldindex = itemwindow.index
        Graphics.update
        Input.update
        pbUpdate
        if itemwindow.index != oldindex
          pbRefresh
        end
		if Input.trigger?(Input::BACK)   # Cancel the item screen
			@selectedBerries.empty? ? pbPlayCloseMenuSE : pbPlayDecisionSE
			return nil
		elsif Input.trigger?(Input::USE)   # Choose selected item
			(itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
			return [itemwindow.item,@bag.pockets[PokeblockSettings::BERRY_POCKET_OF_BAG][@filterlist[itemwindow.index]][1]]
		end
      end
    }
  end
  
  def selectedBerries
	return @selectedBerries
  end
  
  def selectedBerries=(value)
	@selectedBerries=value
  end

end

class MultiBerrySelectionScreen

  def initialize(scene, bag)
    @bag   = bag
    @scene = scene
  end

  def pbStartScreen(proc = nil)
    @scene.pbStartScene(@bag, true, proc)
    item = nil
	ready = false
    loop do
	  if ready
		if @scene.pbConfirm(_INTL("Blend these berries?"))
			break
		elsif @scene.pbConfirm(_INTL("Give up on blending?"))
			@scene.selectedBerries = []
			break
		end
	  end
      item = @scene.pbChooseItem #if !ready
      break if !item && @scene.selectedBerries.empty?
	  if !item 
		if @scene.pbConfirm(@scene.selectedBerries.length == 1 ? _INTL("Blend this berry?") : _INTL("Blend these berries?")) 
			break #@scene.selectedBerries 
		elsif @scene.pbConfirm(_INTL("Give up on blending?"))
			@scene.selectedBerries = []
			break
		end
	  end
      next if !item
	  qty = item[1]
	  item = item[0]
	  itm = GameData::Item.get(item)
	  next pbDisplay(_INTL("You don't have any more of these to throw in.")) if qty - @scene.selectedBerries.count(item) <= 0
      cmdUse      = -1
      commands = []
      # Generate command list
      commands[cmdUse = commands.length]    = _INTL("Throw In")
      commands[commands.length]             = _INTL("Cancel")
      # Show commands generated above
      itemname = itm.name
      command = @scene.pbShowCommands(_INTL("Throw {1} in the blender?", itemname), commands) if !ready
      if cmdUse >= 0 && command == cmdUse   # Use item
		@scene.selectedBerries.push(itm)
        @scene.pbRefresh
		if @scene.selectedBerries.length >= 4
			ready = true
		end
        next
      end
    end
	@scene.pbEndScene
    return @scene.selectedBerries
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  # UI logic for the item screen for choosing an item.
  def pbChooseItemScreen(proc = nil)
    @scene.pbStartScene(@bag, true, proc)
    berries = @scene.pbChooseItem
    @scene.pbEndScene
    return berries
  end

end

class Window_MultiBerrySelection < Window_DrawableCommand

  def initialize(bag, filterlist, scene, x, y, width, height)
    @bag        = bag
    @filterlist = filterlist
    @scene 		= scene
    @sorting = false
    @adapter = PokemonMartAdapter.new
    super(x, y, width, height)
    @selarrow  = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor")
    @swaparrow = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor_swap")
    self.windowskin = nil
  end

  def dispose
    @swaparrow.dispose
    super
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def item
    return nil if @filterlist && !@filterlist[self.index]
    thispocket = @bag.pockets[PokeblockSettings::BERRY_POCKET_OF_BAG]  
    item = thispocket[@filterlist[self.index]]
    return (item) ? item[0] : nil
  end

  def itemCount
    return @filterlist.length + 1
  end

  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    else
      cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = (item / @column_max * @row_height) - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index, rect)
    if self.index == index
      bmp = (@sorting) ? @swaparrow.bitmap : @selarrow.bitmap
      pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
    end
  end

  def drawItem(index, _count, rect)
    textpos = []
    rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
    thispocket = @bag.pockets[PokeblockSettings::BERRY_POCKET_OF_BAG]
    if index == self.itemCount - 1
      textpos.push([_INTL("CLOSE BAG"), rect.x, rect.y + 2, false, self.baseColor, self.shadowColor])
    else
      item = thispocket[@filterlist[index]][0]
      baseColor   = self.baseColor
      shadowColor = self.shadowColor
      if @sorting && index == self.index
        baseColor   = Color.new(224, 0, 0)
        shadowColor = Color.new(248, 144, 144)
      end
      textpos.push(
        [@adapter.getDisplayName(item), rect.x, rect.y + 2, false, baseColor, shadowColor]
      )
        qty = thispocket[@filterlist[index]][1] - @scene.selectedBerries.count(GameData::Item.get(thispocket[@filterlist[index]][0]))
        qtytext = _ISPRINTF("x{1: 3d}", qty)
        xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
        textpos.push([qtytext, xQty, rect.y + 2, false, baseColor, shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end

  def refresh
    @item_max = itemCount
    self.update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end