#===============================================================================
#  Item Handlers
#===============================================================================

ItemHandlers::UseInField.add(:POKEBLOCKCASE, proc { |item|
	next pbPokeblockCase
})

ItemHandlers::UseInField.add(:POKEBLOCKKIT, proc { |item|
	next pbPokeblockKit
})

ItemHandlers::UseInField.add(:POKEBLOCKCONDITION, proc { |item|
	next pbPokeblockCondition
})


#===============================================================================
# Misc Commands
#===============================================================================

class PokemonBag
	def hasAnyBerry?
		GameData::Item.each { |i|
			return true if GameData::Item.get(i.id).is_berry? && $PokemonBag.pbQuantity(i.id)>0
		}
		return false
	end
end

#===============================================================================
#  Pokeblock Commands
#===============================================================================

def pbCreatePokeblock(color,flavor,plus=false,feel=0)
	pokeblock = Pokeblock.new(color,flavor,feel,plus)
	return pokeblock
end

def pbGainPokeblock(pokeblock)
	$Trainer.gainPokeblock(pokeblock)
end

def pbRemovePokeblock(block,qty=1)
	pokeblocks = $Trainer.pokeblocks
	return true if qty == 0
	ret = false
	pokeblocks.each_with_index do |block_slot, i|
		next if !block_slot || block_slot != block
		pokeblocks[i] = nil
		ret = true
		break
	end
	pokeblocks.compact!
	return ret
end

def pbGiveSimplePokeblock(color = nil,qty = 1,plus = nil) #Really for Debugging only
	qty.times { |i|
		clr = (color != nil ? color : ["Red","Blue","Pink","Green","Yellow","Rainbow"].sample)
		p = plus != nil ? plus : (rand(3)==0 ? true : false)
		val = (p ? 15 : 5)
		pkblk = nil
		case clr
		when "Red" || :Red
			pkblk = Pokeblock.new(:Red,[val,0,0,0,0],15,p)
		when "Blue" || :Blue
			pkblk = Pokeblock.new(:Blue,[0,val,0,0,0],15,p)
		when "Pink" || :Pink
			pkblk = Pokeblock.new(:Pink,[0,0,val,0,0],15,p)
		when "Green" || :Green
			pkblk = Pokeblock.new(:Green,[0,0,0,val,0],15,p)
		when "Yellow" || :Yellow
			pkblk = Pokeblock.new(:Yellow,[0,0,0,0,val],15,p)
		when "Rainbow" || :Rainbow
			pkblk = Pokeblock.new(:Rainbow,[val,val,val,val,val],40,p)
		end
		pbGainPokeblock(pkblk)
	}
end

def pbFeedPokeblock(pokeblock,oldScene=nil)
	if $Trainer.pokemon_count == 0
		pbMessage(_INTL("There is no Pokémon."))
		return 0
    end
	ret = false
	ret = pbPokeblockCondition(pokeblock,oldScene)
	return ret
end

def pbPokeblockCase
	if !$Trainer.hasPokeblocks?
		pbMessage(_INTL("You don't have any Pokéblocks!"))
		return false
	end
	pbFadeOutIn {
		scene = PokeblockCase_Scene.new
		screen = PokeblockCase_Screen.new(scene)
		ret = screen.pbStartScreen
	}
end

def pbPokeblockCondition(pokeblock=nil,oldScene=nil)
	ret = 0
	pbFadeOutIn {
		scene = PokeblockCondition_Scene.new(pokeblock,$Trainer.able_party)
		screen = PokeblockCondition_Screen.new(scene,$Trainer.able_party)
		ret = screen.pbStartScreen(pokeblock)
		oldScene&.pbRefresh
	}
	return ret
end

def pbPokeblockKit
	pbFadeOutIn {
		scene = PokeblockKit_Scene.new
		screen = PokeblockKit_Screen.new(scene)
		ret = screen.pbStartScreen
	}
end

#===============================================================================
# BerryPoffin Module
#===============================================================================

module BerryPoffin
	module_function

	def pbPickBerryForBlender
	  berry = nil
	  pbFadeOutIn {
		scene = PokemonBag_Scene.new
		screen = PokemonBagScreen.new(scene, $PokemonBag)
		berry = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_berry? })
	  }
	  return nil if !berry
	  berry = GameData::Item.get(berry).id
		$PokemonBag.pbDeleteItem(berry, 1)
	  return berry
	end

	def pbPickBerryForBlenderSimple
	  berries = nil
	  pbFadeOutIn {
		scene = MultiBerrySelection_Scene.new
		screen = MultiBerrySelectionScreen.new(scene, $PokemonBag)
		berries = screen.pbStartScreen(proc { |item| GameData::Item.get(item).pocket == PokeblockSettings::BERRY_POCKET_OF_BAG &&
			GameData::Item.get(item).is_berry? })

	  }
	  return nil if !berries || berries.empty?
	  berries.each { |b| b=GameData::Item.get(b).id; $PokemonBag.pbDeleteItem(b, 1) }
	  return berries
	end

	def averageSmoothness(berries)
	    if !berries.is_a?(Array)
			return GameData::BerryData.get(berries).smoothness
        end
		sum = 0
		berries.each{ |i|
			sum += GameData::BerryData.get(i).smoothness
		}
		average = sum/berries.size - berries.size
		average = 99 if average>=99
		return average
	end

	def nature(nature, flavorArray)
		like = dislike = nil
		PokeblockSettings::NATURE_FLAVOR_PREFERENCES["Likes"].each_with_index { |value,index|
			break like = index if value.include?(nature)
		}
		PokeblockSettings::NATURE_FLAVOR_PREFERENCES["Dislikes"].each_with_index { |value,index|
			break dislike = index if value.include?(nature)
		}
		flavorArray[like] *= 1.1 if like
		flavorArray[dislike] *= 0.9 if dislike
		return flavorArray.map { |i| i.round }
	end

end

#===============================================================================
# Debug Menu Options
#===============================================================================
#
# MenuHandlers.add(:debug_menu, :contest_menu, {
#   "name"        => _INTL("Pokeblock/Contest Options..."),
#   "parent"      => :main,
#   "description" => _INTL("Control Pokeblocks, Contest Options, etc."),
#   "always_show" => false
# })
#
# MenuHandlers.add(:debug_menu, :pokeblock_Menu, {
#   "name"        => _INTL("Pokeblocks..."),
#   "parent"      => :contest_menu,
#   "description" => _INTL("Manipulate Pokeblocks"),
#   "always_show" => false
# })
#
# MenuHandlers.add(:debug_menu, :give_pokeblock, {
#   "name"        => _INTL("Give Pokeblocks"),
#   "parent"      => :pokeblock_Menu,
#   "description" => _INTL("Give the player simple Pokeblocks"),
#   "effect"      => proc {
#     cmd = 0
#     cmds = [_INTL("Rainbow"),_INTL("Red"),_INTL("Blue"),_INTL("Pink"),_INTL("Green"),_INTL("Yellow"),_INTL("Random")]
#     loop do
# 	  color = pbShowCommands(nil, cmds, -1, cmd)
# 	  break if color < 0
# 	  color = color == 6 ? nil : cmds[color]
# 	  plus = pbConfirmMessage("Make +?")
#       params = ChooseNumberParams.new
#       params.setRange(1, 99)
#       params.setInitialValue(1)
#       params.setCancelValue(1)
# 	  qty = pbMessageChooseNumber("Give how many?",params)
# 	  pbGiveSimplePokeblock(color,qty,plus)
#       pbMessage(_INTL("Pokeblocks given"))
#     end
#   }
# })