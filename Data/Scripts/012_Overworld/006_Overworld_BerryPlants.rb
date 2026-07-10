Events.onSpritesetCreate += proc { |_sender, e|
  spriteset = e[0]
  viewport = e[1]
  map = spriteset.map
  for i in map.events.keys
    if map.events[i].name[/berryplant/i]
      spriteset.addUserSprite(BerryPlantMoistureSprite.new(map.events[i], map, viewport))
      spriteset.addUserSprite(BerryPlantSprite.new(map.events[i], map, viewport))
    end
  end
}

class BerryPlantMoistureSprite
  def initialize(event, map, viewport = nil)
    @event = event
    @map = map
    @light = IconSprite.new(0, 0, viewport)
    @light.ox = 16
    @light.oy = 24
    @oldmoisture = -1 # -1=none, 0=dry, 1=damp, 2=wet
    updateGraphic
    @disposed = false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def updateGraphic
    case @oldmoisture
    when -1 then @light.setBitmap("")
    when 0 then @light.setBitmap("Graphics/Characters/berrytreeDry")
    when 1 then @light.setBitmap("Graphics/Characters/berrytreeDamp")
    when 2 then @light.setBitmap("Graphics/Characters/berrytreeWet")
    end
  end

  def update
    return if !@light || !@event
    newmoisture = -1
    if @event.variable && @event.variable.length > 6 && @event.variable[1]
      # Berry was planted, show moisture patch
      newmoisture = (@event.variable[4] > 50) ? 2 : (@event.variable[4] > 0) ? 1 : 0
    end
    if @oldmoisture != newmoisture
      @oldmoisture = newmoisture
      updateGraphic
    end
    @light.update
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    pbDayNightTint(@light)
  end
end

class BerryPlantSprite
  def initialize(event, map, _viewport)
    @event = event
    @map = map
    @oldstage = 0
    @disposed = false
    berryData = event.variable
    return if !berryData
    @oldstage = berryData[0]
    @event.character_name = ""
    berryData = updatePlantDetails(berryData)
    setGraphic(berryData, true) # Set the event's graphic
    @event.setVariable(berryData) # Set new berry data
  end

  def dispose
    @event = nil
    @map = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def update # Constantly updates, used only to immediately
    berryData = @event.variable # change sprite when planting/picking berries
    if berryData
      berryData = updatePlantDetails(berryData) if berryData.length > 6
      setGraphic(berryData)
      @event.setVariable(berryData)
    end
  end

  def updatePlantDetails(berryData)
    return berryData if berryData[0] == 0
    berryvalues = GameData::BerryPlant.get(berryData[1])
    timeperstage = berryvalues.hours_per_stage * 3600
    timenow = pbGetTimeNow
    if berryData.length > 6
      # Gen 4 growth mechanisms
      # Check time elapsed since last check
      timeDiff = (timenow.to_i - berryData[3]) # in seconds
      return berryData if timeDiff <= 0
      berryData[3] = timenow.to_i # last updated now
      # Mulch modifiers
      dryingrate = berryvalues.drying_per_hour
      maxreplants = GameData::BerryPlant::NUMBER_OF_REPLANTS
      ripestages = 4
      case berryData[7]
      when :STABLEMULCH #berries grow faster
        timeperstage = (timeperstage * 0.75).to_i
        dryingrate = (dryingrate * 1.5).ceil
      when :GROWTHMULCH #berries grow much faster
        timeperstage = (timeperstage * 0.50).to_i
        dryingrate = (dryingrate * 1.5).ceil
      when :DAMPMULCH #drying rate is slower
        timeperstage = (timeperstage * 1.25).to_i
        dryingrate = (dryingrate * 0.5).floor
      when :GOOEYMULCH  #drying rate is much slower
        timeperstage = (timeperstage * 1.25).to_i
        dryingrate = (dryingrate * 0.25).floor
      #when :RICHMULCH  #Increases yield - implemented in pbBerryPlant

      end

      #Auto replant mechanics - Disabled
      # Cycle through all replants since last check
      # loop do
      #   secondsalive = berryData[2]
      #   growinglife = (berryData[5] > 0) ? 3 : 4 # number of growing stages
      #   numlifestages = growinglife + ripestages # number of growing + ripe stages
      #   # Should replant itself?
      #   if secondsalive + timeDiff >= timeperstage * numlifestages
      #     # Should replant
      #     # if berryData[5] >= maxreplants # Too many replants
      #     #   return [0, 0, 0, 0, 0, 0, 0, 0]
      #     # end
      #     # Replant
      #     berryData[0] = 2 # replants start in sprouting stage
      #     berryData[2] = 0 # seconds alive
      #     berryData[5] += 1 # add to replant count
      #     berryData[6] = 0 # yield penalty
      #     timeDiff -= (timeperstage * numlifestages - secondsalive)
      #   else
      #     break
      #   end
      # end

      secondsalive = berryData[2]
      growinglife  = (berryData[5] > 0) ? 3 : 4
      numlifestages = growinglife + ripestages
      maxlife = timeperstage * numlifestages

      if secondsalive + timeDiff >= maxlife
        berryData[2] = maxlife
        timeDiff = 0
      end



      # Update current stage and dampness
      if berryData[0] > 0
        # Advance growth stage
        oldlifetime = berryData[2]
        newlifetime = oldlifetime + timeDiff
        if berryData[0] < 5
          berryData[0] = 1 + (newlifetime / timeperstage).floor
          berryData[0] += 1 if berryData[5] > 0 # replants start at stage 2
          berryData[0] = 5 if berryData[0] > 5
        end
        # Update the "seconds alive" counter
        berryData[2] = newlifetime
        # Reduce dampness, apply yield penalty if dry
        growinglife = (berryData[5] > 0) ? 3 : 4 # number of growing stages
        oldhourtick = (oldlifetime / 3600).floor
        newhourtick = (([newlifetime, timeperstage * growinglife].min) / 3600).floor
        (newhourtick - oldhourtick).times do
          if berryData[4] > 0
            berryData[4] = [berryData[4] - dryingrate, 0].max
          else
            berryData[6] += 1
          end
        end
      end
    else
      # Gen 3 growth mechanics
      loop do
        if berryData[0] > 0 && berryData[0] < 5
          levels = 0
          # Advance time
          timeDiff = (timenow.to_i - berryData[3]) # in seconds
          if timeDiff >= timeperstage
            levels += 1
            if timeDiff >= timeperstage * 2
              levels += 1
              if timeDiff >= timeperstage * 3
                levels += 1
                if timeDiff >= timeperstage * 4
                  levels += 1
                end
              end
            end
          end
          levels = 5 - berryData[0] if levels > 5 - berryData[0]
          break if levels == 0
          berryData[2] = false # not watered this stage
          berryData[3] += levels * timeperstage # add to time existed
          berryData[0] += levels # increase growth stage
          berryData[0] = 5 if berryData[0] > 5
        end
        if berryData[0] >= 5
          # Advance time
          timeDiff = (timenow.to_i - berryData[3]) # in seconds
          if timeDiff >= timeperstage * 4 # ripe for 4 times as long as a stage
            # Replant
            berryData[0] = 2 # replants start at stage 2
            berryData[2] = false # not watered this stage
            berryData[3] += timeperstage * 4 # add to time existed
            berryData[4] = 0 # reset total waterings count
            berryData[5] += 1 # add to replanted count
            if berryData[5] > GameData::BerryPlant::NUMBER_OF_REPLANTS # Too many replants
              berryData = [0, 0, false, 0, 0, 0]
              break
            end
          else
            break
          end
        end
      end
      # If raining, automatically water the plant
      if berryData[0] > 0 && berryData[0] < 5 && $game_screen &&
        GameData::Weather.get($game_screen.weather_type).category == :Rain ||
        GameData::Weather.get($game_screen.weather_type).category == :Storm ||
        GameData::Weather.get($game_screen.weather_type).category == :HeavyRain ||

        if berryData[2] == false
          berryData[2] = true
          berryData[4] += 1
        end
      end
    end
    return berryData
  end

  def setGraphic(berryData, fullcheck = false)
    return if !berryData || (@oldstage == berryData[0] && !fullcheck)
    case berryData[0]
    when 0
      @event.character_name = ""
    when 1
      @event.character_name = "berrytreeplanted" # Common to all berries
      @event.turn_down
    else
      filename = sprintf("berrytree_%s", GameData::Item.get(berryData[1]).id.to_s)
      if pbResolveBitmap("Graphics/Characters/" + filename)
        @event.character_name = filename
        case berryData[0]
        when 2 then @event.turn_down # X sprouted
        when 3 then @event.turn_left # X taller
        when 4 then @event.turn_right # X flowering
        when 5 then @event.turn_up # X berries
        end
      else
        @event.character_name = "Object ball"
      end
      # if @oldstage != berryData[0] && berryData.length > 6 # Gen 4 growth mechanisms
      #   $scene.spriteset.addUserAnimation(Settings::PLANT_SPARKLE_ANIMATION_ID, @event.x, @event.y, false, 1) if $scene.spriteset
      # end
    end
    @oldstage = berryData[0]
  end
end

# todo: return whether the player has any mulch items
def canFertilize?
  return $PokemonBag.pbHasItem?(:GROWTHMULCH) ||
    $PokemonBag.pbHasItem?(:DAMPMULCH) ||
    $PokemonBag.pbHasItem?(:GOOEYMULCH) ||
    $PokemonBag.pbHasItem?(:STABLEMULCH) ||
    $PokemonBag.pbHasItem?(:RICHMULCH)
end

def pbBerryPlant
  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  if !berryData
    if Settings::NEW_BERRY_PLANTS
      berryData = [0, nil, 0, 0, 0, 0, 0, 0]
    else
      berryData = [0, nil, false, 0, 0, 0]
    end
  end
  # Stop the event turning towards the player
  case berryData[0]
  when 1 then thisEvent.turn_down # X planted
  when 2 then thisEvent.turn_down # X sprouted
  when 3 then thisEvent.turn_left # X taller
  when 4 then thisEvent.turn_right # X flowering
  when 5 then thisEvent.turn_up # X berries
  end
  watering = [:SPRAYDUCK, :SQUIRTBOTTLE, :WAILMERPAIL, :SPRINKLOTAD]
  berry = berryData[1]
  case berryData[0]
  when 0 # empty
    if Settings::NEW_BERRY_PLANTS
      # Gen 4 planting mechanics
      if !berryData[7] || berryData[7] == 0 # No mulch used yet
        cmd_fertilize = _INTL("Fertilize")
        cmd_plant = _INTL("Plant")
        cmd_cancel = _INTL("Exit")

        commands = []
        commands << cmd_fertilize if canFertilize?
        commands << cmd_plant
        commands << cmd_cancel

        cmd = pbMessage(_INTL("It's soft, earthy soil."), commands, -1)
        if commands[cmd] == cmd_fertilize # Fertilize
          ret = 0
          pbFadeOutIn {
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, $PokemonBag)
            ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_mulch? })
          }
          if ret
            if GameData::Item.get(ret).is_mulch?
              berryData[7] = ret
              pbMessage(_INTL("The {1} was scattered on the soil.\1", GameData::Item.get(ret).name))
              $PokemonBag.pbDeleteItem(ret)

              if pbConfirmMessage(_INTL("Want to plant a Berry?"))
                pbFadeOutIn {
                  scene = PokemonBag_Scene.new
                  screen = PokemonBagScreen.new(scene, $PokemonBag)
                  berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_berry? })
                }
                if berry
                  timenow = pbGetTimeNow
                  berryData[0] = 1 # growth stage (1-5)
                  berryData[1] = berry # item ID of planted berry
                  berryData[2] = 0 # seconds alive
                  berryData[3] = timenow.to_i # time of last checkup (now)
                  berryData[4] = 100 # dampness value
                  berryData[5] = 0 # number of replants
                  berryData[6] = 0 # yield penalty
                  $PokemonBag.pbDeleteItem(berry, 1)
                  pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                                  GameData::Item.get(berry).name))
                  $Trainer.stats.berries_planted = 0 unless $Trainer.stats.berries_planted
                  $Trainer.stats.berries_planted +=1
                end
              end
              interp.setVariable(berryData)
            else
              pbMessage(_INTL("That won't fertilize the soil!"))
            end
            return
          end
        elsif commands[cmd] == cmd_plant # Plant Berry
          pbFadeOutIn {
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, $PokemonBag)
            berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_berry? })
          }
          if berry
            timenow = pbGetTimeNow
            berryData[0] = 1 # growth stage (1-5)
            berryData[1] = berry # item ID of planted berry
            berryData[2] = 0 # seconds alive
            berryData[3] = timenow.to_i # time of last checkup (now)
            berryData[4] = 100 # dampness value
            berryData[5] = 0 # number of replants
            berryData[6] = 0 # yield penalty
            $PokemonBag.pbDeleteItem(berry, 1)
            pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                            GameData::Item.get(berry).name))
            $Trainer.stats.berries_planted = 0 unless $Trainer.stats.berries_planted
            $Trainer.stats.berries_planted +=1
            interp.setVariable(berryData)
          end
          return
        end
      else
        pbMessage(_INTL("{1} has been laid down.\1", GameData::Item.get(berryData[7]).name))
        if pbConfirmMessage(_INTL("Want to plant a Berry?"))
          pbFadeOutIn {
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, $PokemonBag)
            berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_berry? })
          }
          if berry
            timenow = pbGetTimeNow
            berryData[0] = 1 # growth stage (1-5)
            berryData[1] = berry # item ID of planted berry
            berryData[2] = 0 # seconds alive
            berryData[3] = timenow.to_i # time of last checkup (now)
            berryData[4] = 100 # dampness value
            berryData[5] = 0 # number of replants
            berryData[6] = 0 # yield penalty
            $PokemonBag.pbDeleteItem(berry, 1)
            pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                            GameData::Item.get(berry).name))
            $Trainer.stats.berries_planted = 0 unless $Trainer.stats.berries_planted
            $Trainer.stats.berries_planted +=1
            interp.setVariable(berryData)
          end
          return
        end
      end
    end
    # else
    #   # Gen 3 planting mechanics
    #   if pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
    #     pbFadeOutIn {
    #       scene = PokemonBag_Scene.new
    #       screen = PokemonBagScreen.new(scene, $PokemonBag)
    #       berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_berry? })
    #     }
    #     if berry
    #       timenow = pbGetTimeNow
    #       berryData[0] = 1 # growth stage (1-5)
    #       berryData[1] = berry # item ID of planted berry
    #       berryData[2] = false # watered in this stage?
    #       berryData[3] = timenow.to_i # time planted
    #       berryData[4] = 0 # total waterings
    #       berryData[5] = 0 # number of replants
    #       berryData[6] = nil; berryData[7] = nil; berryData.compact! # for compatibility
    #       $PokemonBag.pbDeleteItem(berry, 1)
    #       pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.",
    #                       $Trainer.name, GameData::Item.get(berry).name))
    #       interp.setVariable(berryData)
    #     end
    #     return
    #   end
    # end
  when 1 # X planted
    berry_name = GameData::Item.get(berry).name
    preposition = ["A","E","I","O","U"].include?(berry_name[0]) ? "An" : "A"
    pbMessage(_INTL("{1} {2} was planted here.", preposition, berry_name))
  when 2 # X sprouted
    pbMessage(_INTL("The {1} has sprouted.", GameData::Item.get(berry).name))
    unless hasHat?(HAT_SPROUT)
      obtainHat(HAT_SPROUT) if rand(10) == 0
    end
  when 3 # X taller
    pbMessage(_INTL("The {1} plant is growing bigger.", GameData::Item.get(berry).name))
  when 4 # X flowering
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("This {1} plant is in bloom!", GameData::Item.get(berry).name))
    else
      case berryData[4]
      when 4
        pbMessage(_INTL("This {1} plant is in fabulous bloom!", GameData::Item.get(berry).name))
      when 3
        pbMessage(_INTL("This {1} plant is blooming very beautifully!", GameData::Item.get(berry).name))
      when 2
        pbMessage(_INTL("This {1} plant is blooming prettily!", GameData::Item.get(berry).name))
      when 1
        pbMessage(_INTL("This {1} plant is blooming cutely!", GameData::Item.get(berry).name))
      else
        pbMessage(_INTL("This {1} plant is in bloom!", GameData::Item.get(berry).name))
      end
    end
  when 5 # X berries
    berryvalues = GameData::BerryPlant.get(berryData[1])
    # Get berry yield (berrycount)
    berrycount = 1
    if berryData.length > 6
      # Gen 4 berry yield calculation
      berrycount = [berryvalues.maximum_yield - berryData[6], berryvalues.minimum_yield].max
      berrycount = (berrycount * 1.5).ceil if berryData[7] == :RICHMULCH
    else
      # Gen 3 berry yield calculation
      if berryData[4] > 0
        berrycount = (berryvalues.maximum_yield - berryvalues.minimum_yield) * (berryData[4] - 1)
        berrycount += rand(1 + berryvalues.maximum_yield - berryvalues.minimum_yield)
        berrycount = (berrycount / 4) + berryvalues.minimum_yield
      else
        berrycount = berryvalues.minimum_yield
      end
    end
    item = GameData::Item.get(berry)
    itemname = (berrycount > 1) ? item.name_plural : item.name
    pocket = item.pocket
    if berrycount > 1
      message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", berrycount, itemname)
    else
      message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", itemname)
    end
    if pbConfirmMessage(message)
      if !$PokemonBag.pbCanStore?(berry, berrycount)
        pbMessage(_INTL("Too bad...\nThe Bag is full..."))
        return
      end

      pbMEPlay("Berry Obtained")
      $PokemonBag.pbStoreItem(berry, berrycount)
      if berrycount > 1
        pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[10]", berrycount, itemname))
      else
        pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[10]", itemname))
      end
      pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
                      $Trainer.name, itemname, pocket, PokemonBag.pocketNames()[pocket]))
      if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("The soil returned to its soft and earthy state."))
        berryData = [0, nil, 0, 0, 0, 0, 0, 0]
      else
        pbMessage(_INTL("The soil returned to its soft and loamy state."))
        berryData = [0, nil, false, 0, 0, 0]
      end
      interp.setVariable(berryData)
    end
  end
  case berryData[0]
  when 1, 2, 3, 4
    for i in watering
      next if !GameData::Item.exists?(i) || !$PokemonBag.pbHasItem?(i)
      if pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?", GameData::Item.get(i).name))
        if berryData.length > 6
          # Gen 4 berry watering mechanics
          berryData[4] = 100
        else
          # Gen 3 berry watering mechanics
          if berryData[2] == false
            berryData[4] += 1
            berryData[2] = true
          end
        end
        interp.setVariable(berryData)
        pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $Trainer.name))
        if Settings::NEW_BERRY_PLANTS
          pbMessage(_INTL("There! All happy!"))
        else
          pbMessage(_INTL("The plant seemed to be delighted."))
        end
      end
      break
    end
  end
end

def pbPickBerry(berry, qty = 1)
  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  berry = GameData::Item.get(berry)
  itemname = (qty > 1) ? berry.name_plural : berry.name
  if qty > 1
    message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", qty, itemname)
  else
    message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", itemname)
  end
  if pbConfirmMessage(message)
    if !$PokemonBag.pbCanStore?(berry, qty)
      pbMessage(_INTL("Too bad...\nThe Bag is full..."))
      return
    end
    $PokemonBag.pbStoreItem(berry, qty)
    pbMEPlay("Berry Obtained")
    if qty > 1
      pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[10]", qty, itemname))
    else
      pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[10]", itemname))
    end
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
                    $Trainer.name, itemname, pocket, PokemonBag.pocketNames()[pocket]))
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("The soil returned to its soft and earthy state."))
      berryData = [0, nil, 0, 0, 0, 0, 0, 0]
    else
      pbMessage(_INTL("The soil returned to its soft and loamy state."))
      berryData = [0, nil, false, 0, 0, 0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id, "A", true)

    if berry == :ORANBERRY && !hasHat?(HAT_ORAN)
      obtainHat(HAT_ORAN)
    end
  end
end
