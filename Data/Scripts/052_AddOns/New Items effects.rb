ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  if useLantern()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:LANTERN, proc { |item|
  Kernel.pbMessage(_INTL("#{$Trainer.name} used the lantern."))
  if useLantern()
    next 1
  else
    next 0
  end
})

def useLantern()
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed? || $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("It's already illuminated..."))
    return false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the area!"))
  darkness.radius += 176
  $PokemonGlobal.flashUsed = true
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMapd
    darkness.radius += 4
  end
  return true
end

ItemHandlers::UseFromBag.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

def useTeleporter()
  if HiddenMoveHandlers.triggerCanUseMove(:TELEPORT, 0, true)
    Kernel.pbMessage(_INTL("Teleport to where?", $Trainer.name))
    ret = pbBetterRegionMap(-1, true, true)
    return false unless ret
    ###############################################
    if ret
      $PokemonTemp.flydata = ret
    end
    # scene = PokemonRegionMapScene.new(-1, false)
    # screen = PokemonRegionMap.new(scene)
    # ret = screen.pbStartFlyScreen
    # if ret
    #   $PokemonTemp.flydata = ret
    # end
  end

  if !$PokemonTemp.flydata
    return false
  else
    Kernel.pbMessage(_INTL("{1} used the teleporter!", $Trainer.name))
    pbFadeOutIn(99999) {
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id = $PokemonTemp.flydata[0]
      $game_temp.player_new_x = $PokemonTemp.flydata[1]
      $game_temp.player_new_y = $PokemonTemp.flydata[2]
      $PokemonTemp.flydata = nil
      $game_temp.player_new_direction = 2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
    return true
  end
end

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed?
    Kernel.pbMessage(_INTL("The cave is already illuminated."))
    next false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the area!"))
  $PokemonGlobal.flashUsed = true
  darkness.radius += 176
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += 4
  end
  next true
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

# NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:COFFEE, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:COFFEE, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.egg?
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.eggsteps = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseFromBag.add(:DEBUGGER, proc { |item|
  Kernel.pbMessage(_INTL("[{1}]The debugger should ONLY be used if you are stuck somewhere because of a glitch.", Settings::GAME_VERSION_NUMBER))
  if Kernel.pbConfirmMessageSerious(_INTL("Innapropriate use of this item can lead to unwanted effects and make the game unplayable. Do you want to continue?"))
    $game_player.cancelMoveRoute()
    Kernel.pbStartOver(false)
    pbCommonEvent(COMMON_EVENT_FIX_GAME)
    Kernel.pbMessage(_INTL("Please report the glitch on the game's Discord, in the #bug-reports channel."))
    openUrlInBrowser(Settings::DISCORD_URL)
    next 1
  else
    next 0
  end
})

def useSleepingBag()
  currentSecondsValue = pbGet(UnrealTime::EXTRA_SECONDS)
  choices = ["1 hour", "6 hours", "12 hours", "24 hours", "Cancel"]
  choice = Kernel.pbMessage("Sleep for how long?", choices, choices.length)
  echoln choice
  return 0 if choice == choices.length - 1
  oldDay = getDayOfTheWeek()
  timeAdded = 0
  case choice
  when 0
    timeAdded = 3600
  when 1
    timeAdded = 21600
  when 2
    timeAdded = 43200
  when 3
    timeAdded = 86400
  end
  pbSet(UnrealTime::EXTRA_SECONDS, currentSecondsValue + timeAdded)
  pbSEPlay("Sleep", 100)
  pbFadeOutIn {
    Kernel.pbMessage(_INTL("{1} slept for a while...", $Trainer.name))
  }
  time = pbGetTimeNow.strftime("%I:%M %p")
  newDay = getDayOfTheWeek()
  if newDay != oldDay
    Kernel.pbMessage(_INTL("The current time is now {1} on {2}.", time, newDay.downcase.capitalize))
  else
    Kernel.pbMessage(_INTL("The current time is now {1}.", time))
  end
  return 1
end

ItemHandlers::UseFromBag.add(:SLEEPINGBAG, proc { |item|
  mapMetadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !mapMetadata || !mapMetadata.outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here..."))
    next 0
  end
  next useSleepingBag()
})

ItemHandlers::UseInField.add(:SLEEPINGBAG, proc { |item|
  mapMetadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !mapMetadata || !mapMetadata.outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here..."))
    next 0
  end
  next useSleepingBag()
})

ItemHandlers::UseFromBag.add(:ROCKETUNIFORM, proc { |item|
  next useRocketUniform()
})

ItemHandlers::UseInField.add(:ROCKETUNIFORM, proc { |item|
  next useRocketUniform()
})

ItemHandlers::UseFromBag.add(:FAVORITEOUTFIT, proc { |item|
  next useFavoriteOutfit()
})

ItemHandlers::UseInField.add(:FAVORITEOUTFIT, proc { |item|
  next useFavoriteOutfit()
})

ItemHandlers::UseInField.add(:EMERGENCYWHISTLE, proc { |item|
  if isOnPinkanIsland()
    pbCommonEvent(COMMON_EVENT_PINKAN_WHISTLE)
    $scene.reset_map(true)
    updatePinkanBerryDisplay()
    next 1
  end
  next 0
})

ItemHandlers::UseFromBag.add(:EMERGENCYWHISTLE, proc { |item|
  if isOnPinkanIsland()
    pbCommonEvent(COMMON_EVENT_PINKAN_WHISTLE)
    $scene.reset_map(true)
    updatePinkanBerryDisplay()
    next 1
  end
  next 0
})

ItemHandlers::UseFromBag.add(:ODDKEYSTONE, proc { |item|
  TOTAL_SPIRITS_NEEDED = 108
  nbSpirits = pbGet(VAR_ODDKEYSTONE_NB)
  if nbSpirits == 107
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("Voices can be heard whispering from it..."))
    Kernel.pbMessage(_INTL("Just... one... more..."))
  elsif nbSpirits < TOTAL_SPIRITS_NEEDED
    nbNeeded = TOTAL_SPIRITS_NEEDED - nbSpirits
    Kernel.pbMessage(_INTL("Voices can be heard whispering from the Odd Keystone..."))
    Kernel.pbMessage(_INTL("Bring... us... {1}... spirits", nbNeeded.to_s))
  else
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("It seems as if some poweful energy is trying to escape from it."))
    if (Kernel.pbMessage("Let it out?", ["No", "Yes"], 0)) == 1
      pbWildBattle(:SPIRITOMB, 27)
      pbSet(VAR_ODDKEYSTONE_NB, 0)
    end
    next 1
  end
})

def useFavoriteOutfit()
  cmd_switch = isWearingFavoriteOutfit() ? "Take off favorite outfit" : "Switch to favorite outfit"
  cmd_mark_favorite = "Mark current outfit as favorite"
  cmd_cancel = "Cancel"

  options = [cmd_switch, cmd_mark_favorite, cmd_cancel]
  choice = optionsMenu(options)
  if options[choice] == cmd_switch
    switchToFavoriteOutfit()
  elsif options[choice] == cmd_mark_favorite
    pbSEPlay("shiny", 80, 100)
    $Trainer.favorite_clothes= $Trainer.clothes
    $Trainer.favorite_hat = $Trainer.hat
    $Trainer.favorite_hat2=$Trainer.hat2
    pbMessage(_INTL("Your favorite outfit was updated!"))
  end
end

def switchToFavoriteOutfit()
  if !$Trainer.favorite_clothes && !$Trainer.favorite_hat && !$Trainer.favorite_hat2
    pbMessage(_INTL("You can mark clothes and hats as your favorites in the outfits menu and use this to quickly switch to them!"))
    return 0
  end

  if isWearingFavoriteOutfit()
    if (Kernel.pbConfirmMessage("Remove your favorite outfit?"))
      last_worn_clothes_is_favorite = $Trainer.last_worn_outfit == $Trainer.favorite_clothes
      last_worn_hat_is_favorite = $Trainer.last_worn_hat == $Trainer.favorite_hat
      last_worn_hat2_is_favorite = $Trainer.last_worn_hat2 == $Trainer.favorite_hat2
      if (last_worn_clothes_is_favorite && last_worn_hat_is_favorite && last_worn_hat2_is_favorite)
        $Trainer.last_worn_outfit = getDefaultClothes()
      end
      playOutfitChangeAnimation()
      putOnClothes($Trainer.last_worn_outfit, true) #if $Trainer.favorite_clothes
      putOnHat($Trainer.last_worn_hat, true,false) #if $Trainer.favorite_hat
      putOnHat($Trainer.last_worn_hat2, true,true) #if $Trainer.favorite_hat2

    else
      return 0
    end

  else
    if (Kernel.pbConfirmMessage("Put on your favorite outfit?"))
      echoln "favorite clothes: #{$Trainer.favorite_clothes}, favorite hat: #{$Trainer.favorite_hat}, favorite hat2: #{$Trainer.favorite_hat2}"

      playOutfitChangeAnimation()
      putOnClothes($Trainer.favorite_clothes, true) if $Trainer.favorite_clothes
      putOnHat($Trainer.favorite_hat, true, false) if $Trainer.favorite_hat
      putOnHat($Trainer.favorite_hat2, true, true) if $Trainer.favorite_hat2
    else
      return 0
    end
  end
end

def useRocketUniform()
  return 0 if !$game_switches[SWITCH_JOINED_TEAM_ROCKET]
  if isWearingTeamRocketOutfit()
    if (Kernel.pbConfirmMessage("Remove the Team Rocket uniform?"))
      if ($Trainer.last_worn_outfit == CLOTHES_TEAM_ROCKET_MALE || $Trainer.last_worn_outfit == CLOTHES_TEAM_ROCKET_FEMALE) && $Trainer.last_worn_hat == HAT_TEAM_ROCKET
        $Trainer.last_worn_outfit = getDefaultClothes()
      end
      playOutfitChangeAnimation()
      putOnClothes($Trainer.last_worn_outfit, true)
      putOnHat($Trainer.last_worn_hat, true)
    else
      return 0
    end
  else
    if (Kernel.pbConfirmMessage("Put on the Team Rocket uniform?"))
      playOutfitChangeAnimation()
      gender = pbGet(VAR_TRAINER_GENDER)
      if gender == GENDER_MALE
        putOnClothes(CLOTHES_TEAM_ROCKET_MALE, true)
      else
        putOnClothes(CLOTHES_TEAM_ROCKET_FEMALE, true)
      end
      putOnHat(HAT_TEAM_ROCKET, true)
      #$scene.reset_map(true)
    end
  end
  return 1
end

def useDreamMirror
  visitedMap = $PokemonGlobal.visitedMaps[pbGet(226)]
  map_name = visitedMap ? Kernel.getMapName(pbGet(226)).to_s : "an unknown location"

  Kernel.pbMessage(_INTL("You peeked into the Dream Mirror..."))

  Kernel.pbMessage(_INTL("You can see a faint glimpse of {1} in the reflection.", map_name))
end

def useStrangePlant
  if darknessEffectOnCurrentMap()
    Kernel.pbMessage(_INTL("The strange plant appears to be glowing."))
    $scene.spriteset.addUserSprite(LightEffect_GlowPlant.new($game_player))
  else
    Kernel.pbMessage(_INTL("It had no effect"))
  end

end

# DREAMMIRROR
ItemHandlers::UseFromBag.add(:DREAMMIRROR, proc { |item|
  useDreamMirror
  next 1
})

ItemHandlers::UseInField.add(:DREAMMIRROR, proc { |item|
  useDreamMirror
  next 1
})

# STRANGE PLANT
ItemHandlers::UseFromBag.add(:STRANGEPLANT, proc { |item|
  useStrangePlant()
  next 1
})

ItemHandlers::UseInField.add(:STRANGEPLANT, proc { |item|
  useStrangePlant()
  next 1
})

ItemHandlers::UseFromBag.add(:MAGICBOOTS, proc { |item|
  if $DEBUG
    if Kernel.pbConfirmMessageSerious(_INTL("Take off the Magic Boots?"))
      $DEBUG = false
    end
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Put on the Magic Boots?"))
      Kernel.pbMessage(_INTL("Debug mode is now active."))
      $game_switches[ENABLED_DEBUG_MODE_AT_LEAST_ONCE] = true # got debug mode (for compatibility)
      $DEBUG = true
    end
  end
  next 1
})

def pbForceEvo(pokemon)
  newspecies = getEvolvedSpecies(pokemon)
  return false if newspecies == -1
  if newspecies > 0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
  return true
end

def getEvolvedSpecies(pokemon)
  return pbCheckEvolutionEx(pokemon) { |pokemon, evonib, level, poke|
    next pbMiniCheckEvolution(pokemon, evonib, level, poke, true)
  }
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseInField.add(:DNASPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next 3 if fusion_success
  next false
})

ItemHandlers::UseInField.add(:SUPERSPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next 3 if fusion_success
  next false
})

ItemHandlers::UseInField.add(:INFINITESPLICERS, proc { |item|
  fusion_success = useSplicerFromField(item)
  next true if fusion_success
  next false
})

ItemHandlers::UseInField.add(:INFINITESPLICERS2, proc { |item|
  fusion_success = useSplicerFromField(item)
  next true if fusion_success
  next false
})

def isSuperSplicersMechanics(item)
  return [:SUPERSPLICERS, :INFINITESPLICERS2].include?(item)
end

def useSplicerFromField(item)
  scene = PokemonParty_Scene.new
  scene.pbStartScene($Trainer.party, "Select a Pokémon")
  screen = PokemonPartyScreen.new(scene, $Trainer.party)
  chosen = screen.pbChoosePokemon("Select a Pokémon")
  pokemon = $Trainer.party[chosen]
  fusion_success = pbDNASplicing(pokemon, scene, item)
  screen.pbEndScene
  scene.dispose
  return fusion_success
end

ItemHandlers::UseOnPokemon.add(:DNAREVERSER, proc { |item, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    reverseFusion(pokemon)
    scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
    scene.pbRefresh
    next true
  end

  next false
})

def reverseFusion(pokemon)
  body = getBasePokemonID(pokemon.species, true)
  head = getBasePokemonID(pokemon.species, false)
  newspecies = (head) * Settings::NB_POKEMON + body

  body_exp = pokemon.exp_when_fused_body
  head_exp = pokemon.exp_when_fused_head

  pokemon.exp_when_fused_body = head_exp
  pokemon.exp_when_fused_head = body_exp

  pokemon.head_shiny, pokemon.body_shiny = pokemon.body_shiny, pokemon.head_shiny
  # play animation
  pbFadeOutInWithMusic(99999) {
    fus = PokemonEvolutionScene.new
    fus.pbStartScreen(pokemon, newspecies, true)
    fus.pbEvolution(false, true)
    fus.pbEndScreen
  }
end

ItemHandlers::UseOnPokemon.add(:INFINITEREVERSERS, proc { |item, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * Settings::NB_POKEMON + body

    body_exp = pokemon.exp_when_fused_body
    head_exp = pokemon.exp_when_fused_head

    pokemon.exp_when_fused_body = head_exp
    pokemon.exp_when_fused_head = body_exp

    # play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

#
# def pbDNASplicing(pokemon, scene, supersplicers = false, superSplicer = false)
#   if (pokemon.species <= NB_POKEMON)
#     if pokemon.fused != nil
#       if $Trainer.party.length >= 6
#         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
#         return false
#       else
#         $Trainer.party[$Trainer.party.length] = pokemon.fused
#         pokemon.fused = nil
#         pokemon.form = 0
#         scene.pbHardRefresh
#         scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
#         return true
#       end
#     else
#       chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
#       if chosen >= 0
#         poke2 = $Trainer.party[chosen]
#         if (poke2.species <= NB_POKEMON) && poke2 != pokemon
#           #check if fainted
#           if pokemon.hp == 0 || poke2.hp == 0
#             scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
#             return false
#           end
#           if pbFuse(pokemon, poke2, supersplicers)
#             pbRemovePokemonAt(chosen)
#           end
#         elsif pokemon == poke2
#           scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
#           return false
#         else
#           scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
#           return false
#
#         end
#
#       else
#         return false
#       end
#     end
#   else
#     return true if pbUnfuse(pokemon, scene, supersplicers)
#
#     #unfuse
#   end
# end
#
# def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
#   #pcPosition nil   : unfusing from party
#   #pcPosition [x,x] : unfusing from pc
#   #
#
#   if (pokemon.obtain_method == 2 || pokemon.ot != $Trainer.name) # && !canunfuse
#     scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
#     return false
#   else
#     if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
#       if pokemon.species > (NB_POKEMON * NB_POKEMON) + NB_POKEMON #triple fusion
#         scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
#         return false
#       elsif $Trainer.party.length >= 6 && !pcPosition
#         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
#         return false
#       else
#         scene.pbDisplay(_INTL("Unfusing ... "))
#         scene.pbDisplay(_INTL(" ... "))
#         scene.pbDisplay(_INTL(" ... "))
#
#         bodyPoke = getBasePokemonID(pokemon.species, true)
#         headPoke = getBasePokemonID(pokemon.species, false)
#
#
#         if pokemon.exp_when_fused_head == nil || pokemon.exp_when_fused_body == nil
#           new_level = calculateUnfuseLevelOldMethod(pokemon, supersplicers)
#           body_level = new_level
#           head_level = new_level
#           poke1 = Pokemon.new(bodyPoke, body_level)
#           poke2 = Pokemon.new(headPoke, head_level)
#         else
#           exp_body = pokemon.exp_when_fused_body + pokemon.exp_gained_since_fused
#           exp_head = pokemon.exp_when_fused_head + pokemon.exp_gained_since_fused
#
#           poke1 = Pokemon.new(bodyPoke, pokemon.level)
#           poke2 = Pokemon.new(headPoke, pokemon.level)
#           poke1.exp = exp_body
#           poke2.exp = exp_head
#         end
#
#         #poke1 = PokeBattle_Pokemon.new(bodyPoke, lev, $Trainer)
#         #poke2 = PokeBattle_Pokemon.new(headPoke, lev, $Trainer)
#
#         if pcPosition == nil
#           box = pcPosition[0]
#           index = pcPosition[1]
#           $PokemonStorage.pbStoreToBox(poke2, box, index)
#         else
#           Kernel.pbAddPokemonSilent(poke2, poke2.level)
#         end
#         #On ajoute l'autre dans le pokedex aussi
#         $Trainer.seen[poke1.species] = true
#         $Trainer.owned[poke1.species] = true
#         $Trainer.seen[poke2.species] = true
#         $Trainer.owned[poke2.species] = true
#
#         pokemon.species = poke1.species
#         pokemon.level = poke1.level
#         pokemon.name = poke1.name
#         pokemon.moves = poke1.moves
#         pokemon.obtain_method = 0
#         poke1.obtain_method = 0
#
#         #scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
#         scene.pbHardRefresh
#         scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
#         return true
#       end
#     end
#   end
# end

def calculateUnfuseLevelOldMethod(pokemon, supersplicers)
  if pokemon.level > 1
    if supersplicers
      lev = pokemon.level * 0.9
    else
      lev = pokemon.obtain_method == 2 ? pokemon.level * 0.65 : pokemon.level * 0.75
    end
  else
    lev = 1
  end
  return lev.floor
end

def drawFusionPreviewText(viewport, text, x, y)
  label_base_color = Color.new(248, 248, 248)
  label_shadow_color = Color.new(104, 104, 104)
  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap
  textpos = [[text, x, y, 0, label_base_color, label_shadow_color]]
  pbDrawTextPositions(overlay, textpos)
end

def drawPokemonType(pokemon_id, x_pos = 192, y_pos = 264)
  width = 66

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 1000001

  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap

  pokemon = GameData::Species.get(pokemon_id)
  typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
  type1_number = GameData::Type.get(pokemon.type1).id_number
  type2_number = GameData::Type.get(pokemon.type2).id_number
  type1rect = Rect.new(0, type1_number * 28, 64, 28)
  type2rect = Rect.new(0, type2_number * 28, 64, 28)
  if pokemon.type1 == pokemon.type2
    overlay.blt(x_pos + (width / 2), y_pos, typebitmap.bitmap, type1rect)
  else
    overlay.blt(x_pos, y_pos, typebitmap.bitmap, type1rect)
    overlay.blt(x_pos + width, y_pos, typebitmap.bitmap, type2rect)
  end
  return viewport
end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item
  if it1 != nil
    $PokemonBag.pbStoreItem(it1, 1)
  end
  if it2 != nil
    $PokemonBag.pbStoreItem(it2, 1)
  end
  pokemon.item = nil
  poke2.item = nil
end

# A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
#
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    # if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    # else
    # pokemon.moves[move].dmgup+=1
    # pokemon.moves[move].damage +=5
    # pokemon.moves[move].accuracy -=5

    # movename=PBMoves.getName(pokemon.moves[move].id)
    # scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    # next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    # end
  end
})

##New "stones"
# ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
# #
# ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

# easter egg for evolving shellder into slowbro's tail
ItemHandlers::UseOnPokemon.add(:SLOWPOKETAIL, proc { |item, pokemon, scene|
  echoln pokemon.species
  next false if pokemon.species != :SHELLDER
  pbFadeOutInWithMusic(99999) {
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, :B90H80)
    evo.pbEvolution(false)
    evo.pbEndScreen
    scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 }) if scene.pbHasAnnotations?
    scene.pbRefresh
  }
  next true

})
#
# ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
ItemHandlers::UseOnPokemon.add(:POISONMUSHROOM, proc { |item, pkmn, scene|
  if pkmn.status != :POISON
    pkmn.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pkmn.name))
  end
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:POISONMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  if battler.status != :POISON
    battler.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pokemon.name))
  end
  pbBattleHPItem(pokemon, battler, 10, scene)
})

ItemHandlers::UseOnPokemon.add(:TINYMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:TINYMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BIGMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BIGMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BALMMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 999, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BALMMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 999, scene)
})

#
# #TRACKER (for roaming legendaries)
# ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
#   if Settings::ROAMING_SPECIES.length == 0
#     Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
#   else
#     text = "\\l[8]"
#     min = $game_switches[350] ? 0 : 1
#     for i in min...Settings::ROAMING_SPECIES.length
#       poke = Settings::ROAMING_SPECIES[i]
#       next if poke == PBSPecies::FEEBAS
#       if $game_switches[poke[2]]
#         status = $PokemonGlobal.roamPokemon[i]
#         if status == true
#           if $PokemonGlobal.roamPokemonCaught[i]
#             text += _INTL("{1} has been caught.",
#                           PBSpecies.getName(getID(PBSpecies, poke[0])))
#           else
#             text += _INTL("{1} has been defeated.",
#                           PBSpecies.getName(getID(PBSpecies, poke[0])))
#           end
#         else
#           curmap = $PokemonGlobal.roamPosition[i]
#           if curmap
#             mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
#
#             if curmap == $game_map.map_id
#               text += _INTL("Beep beep! {1} appears to be nearby!",
#                             PBSpecies.getName(getID(PBSpecies, poke[0])))
#             else
#               text += _INTL("{1} is roaming around {3}",
#                             PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
#                             mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
#             end
#           else
#             text += _INTL("{1} is roaming in an unknown area.",
#                           PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
#           end
#         end
#       else
#         #text+=_INTL("{1} does not appear to be roaming.",
#         #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
#       end
#       text += "\n" if i < Settings::ROAMING_SPECIES.length - 1
#     end
#     Kernel.pbMessage(text)
#   end
# })

####EXP. ALL
# Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

# ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, poke, scene|
#   abilityList = poke.getAbilityList
#   abil1 = 0; abil2 = 0
#   for i in abilityList
#     abil1 = i[0] if i[1] == 0
#     abil2 = i[1] if i[1] == 1
#   end
#   if poke.abilityIndex() >= 2 || abil1 == abil2
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   if Kernel.pbConfirmMessage(_INTL("Do you want to change {1}'s ability?",
#                                    poke.name))
#
#     if poke.abilityIndex() == 0
#       poke.setAbility(1)
#     else
#       poke.setAbility(0)
#     end
#     scene.pbDisplay(_INTL("{1}'s ability was changed!", poke.name))
#     next true
#   end
#   next false
#
# })

# NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.egg?
    if pokemon.steps_to_hatch <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.steps_to_hatch = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR_NORMAL, proc { |item, pokemon, scene|
  if pokemon.egg?
    steps = pokemon.steps_to_hatch
    steps = (steps / 1.5).ceil
    # steps -= 2000 / (pokemon.nbIncubatorsUsed + 1).ceil
    if steps <= 1
      pokemon.steps_to_hatch = 1
    else
      pokemon.steps_to_hatch = steps
    end
    scene.pbDisplay(_INTL("Incubating..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("The egg is closer to hatching!"))

    # if pokemon.steps_to_hatch <= 1
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("The egg is ready to hatch!"))
    #   next false
    # else
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   if pokemon.nbIncubatorsUsed >= 10
    #     scene.pbDisplay(_INTL("The egg is a bit closer to hatching"))
    #   else
    #     scene.pbDisplay(_INTL("The egg is closer to hatching"))
    #   end
    #   pokemon.incrIncubator()
    #   next true
    # end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

def pbForceEvo(pokemon)
  evolutions = getEvolvedSpecies(pokemon)
  return false if evolutions.empty?
  # if multiple evolutions, pick a random one
  #(format of returned value is [[speciesNum, level]])
  newspecies = evolutions[rand(evolutions.length - 1)][0]
  return false if newspecies == nil
  evo = PokemonEvolutionScene.new
  evo.pbStartScreen(pokemon, newspecies)
  evo.pbEvolution
  evo.pbEndScreen
  return true
end

# format of returned value is [[speciesNum, evolutionMethod],[speciesNum, evolutionMethod],etc.]
def getEvolvedSpecies(pokemon)
  return GameData::Species.get(pokemon.species).get_evolutions(true)
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS2, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
  next false
})

def getPokemonPositionInParty(pokemon)
  for i in 0..$Trainer.party.length
    if $Trainer.party[i] == pokemon
      return i
    end
  end
  return -1
end

# don't remember why there's two Supersplicers arguments.... probably a mistake
def pbDNASplicing(pokemon, scene, item = :DNASPLICERS)
  is_supersplicer = isSuperSplicersMechanics(item)

  playingBGM = $game_system.getPlayingBGM
  dexNumber = pokemon.species_data.id_number
  if (pokemon.species_data.id_number <= NB_POKEMON)
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        return false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.form = 0
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        return true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if (poke2.species_data.id_number <= NB_POKEMON) && poke2 != pokemon
          # check if fainted

          if pokemon.egg? || poke2.egg?
            scene.pbDisplay(_INTL("It's impossible to fuse an egg!"))
            return false
          end
          if pokemon.hp == 0 || poke2.hp == 0
            scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
            return false
          end

          selectedHead = selectFusion(pokemon, poke2, is_supersplicer)
          if selectedHead == -1 # cancelled
            return false
          end
          if selectedHead == nil # can't fuse (egg, etc.)
            scene.pbDisplay(_INTL("It won't have any effect."))
            return false
          end
          selectedBase = selectedHead == pokemon ? poke2 : pokemon

          firstOptionSelected = selectedHead == pokemon
          if !firstOptionSelected
            chosen = getPokemonPositionInParty(pokemon)
            if chosen == -1
              scene.pbDisplay(_INTL("There was an error..."))
              return false
            end
          end

          if (Kernel.pbConfirmMessage(_INTL("Fuse {1} and {2}?", selectedHead.name, selectedBase.name)))
            pbFuse(selectedHead, selectedBase, item)
            pbRemovePokemonAt(chosen)
            scene.pbHardRefresh
            pbBGMPlay(playingBGM)
            return true
          end

        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
          return false
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
          return false
        end
      else
        return false
      end
    end
  else
    # UNFUSE
    return true if pbUnfuse(pokemon, scene, is_supersplicer)
  end
end

def selectFusion(pokemon, poke2, supersplicers = false)
  return nil if !pokemon.is_a?(Pokemon) || !poke2.is_a?(Pokemon)
  return nil if pokemon.egg? || poke2.egg?

  selectorWindow = FusionPreviewScreen.new(poke2, pokemon, supersplicers) # PictureWindow.new(picturePath)
  selectedHead = selectorWindow.getSelection
  selectorWindow.dispose
  return selectedHead
end

# firstOptionSelected= selectedHead == pokemon
# selectedBody = selectedHead == pokemon ? poke2 : pokemon
# newid = (selectedBody.species_data.id_number) * NB_POKEMON + selectedHead.species_data.id_number

# def pbFuse(pokemon, poke2, supersplicers = false)
#   newid = (pokemon.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number
#   previewwindow = FusionPreviewScreen.new(pokemon, poke2)#PictureWindow.new(picturePath)
#
#   if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?", newid)))
#     previewwindow.dispose
#     fus = PokemonFusionScene.new
#     if (fus.pbStartScreen(pokemon, poke2, newid))
#       returnItemsToBag(pokemon, poke2)
#       fus.pbFusionScreen(false, supersplicers)
#       $game_variables[126] += 1 #fuse counter
#       fus.pbEndScreen
#       return true
#     end
#   else
#     previewwindow.dispose
#     return false
#   end
# end

def pbFuse(pokemon_body, pokemon_head, splicer_item)
  use_supersplicers_mechanics = isSuperSplicersMechanics(splicer_item)

  newid = (pokemon_body.species_data.id_number) * NB_POKEMON + pokemon_head.species_data.id_number
  fus = PokemonFusionScene.new

  if (fus.pbStartScreen(pokemon_body, pokemon_head, newid, splicer_item))
    returnItemsToBag(pokemon_body, pokemon_head)
    fus.pbFusionScreen(false, use_supersplicers_mechanics)
    $game_variables[VAR_FUSE_COUNTER] += 1 # fuse counter
    fus.pbEndScreen
    return true
  end
end

# Todo: refactor this, holy shit this is a mess
def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
  if pokemon.species_data.id_number > (NB_POKEMON * NB_POKEMON) + NB_POKEMON # triple fusion
    scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
    return false
  end

  pokemon.spriteform_body = nil
  pokemon.spriteform_head = nil

  bodyPoke = getBasePokemonID(pokemon.species_data.id_number, true)
  headPoke = getBasePokemonID(pokemon.species_data.id_number, false)

  if (pokemon.foreign?($Trainer)) # && !canunfuse
    scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
    return false
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
      keepInParty = 0
      if $Trainer.party.length >= 6 && !pcPosition

        message = "Your party is full! Keep which Pokémon in party?"
        message = "Your party is full! Keep which Pokémon in party? The other will be released." if isOnPinkanIsland()
        scene.pbDisplay(_INTL(message))
        selectPokemonMessage = "Select a Pokémon to keep in your party."
        selectPokemonMessage = "Select a Pokémon to keep in your party. The other will be released" if isOnPinkanIsland()
        choice = Kernel.pbMessage(selectPokemonMessage, [_INTL("{1}", PBSpecies.getName(bodyPoke)), _INTL("{1}", PBSpecies.getName(headPoke)), "Cancel"], 2)
        if choice == 2
          return false
        else
          keepInParty = choice
        end
      end

      scene.pbDisplay(_INTL("Unfusing ... "))
      scene.pbDisplay(_INTL(" ... "))
      scene.pbDisplay(_INTL(" ... "))

      if pokemon.exp_when_fused_head == nil || pokemon.exp_when_fused_body == nil
        new_level = calculateUnfuseLevelOldMethod(pokemon, supersplicers)
        body_level = new_level
        head_level = new_level
        poke1 = Pokemon.new(bodyPoke, body_level)
        poke2 = Pokemon.new(headPoke, head_level)
      else
        exp_body = pokemon.exp_when_fused_body + pokemon.exp_gained_since_fused
        exp_head = pokemon.exp_when_fused_head + pokemon.exp_gained_since_fused

        poke1 = Pokemon.new(bodyPoke, pokemon.level)
        poke2 = Pokemon.new(headPoke, pokemon.level)
        poke1.exp = exp_body
        poke2.exp = exp_head
      end
      body_level = poke1.level
      head_level = poke2.level

      pokemon.exp_gained_since_fused = 0
      pokemon.exp_when_fused_head = nil
      pokemon.exp_when_fused_body = nil

      if pokemon.shiny?
        pokemon.shiny = false
        if pokemon.bodyShiny? && pokemon.headShiny?
          pokemon.shiny = true
          poke2.shiny = true
          pokemon.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
          poke2.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        elsif pokemon.bodyShiny?
          pokemon.shiny = true
          poke2.shiny = false
          pokemon.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        elsif pokemon.headShiny?
          poke2.shiny = true
          pokemon.shiny = false
          poke2.natural_shiny = true if pokemon.natural_shiny && !pokemon.debug_shiny
        else
          # shiny was obtained already fused
          if rand(2) == 0
            pokemon.shiny = true
          else
            poke2.shiny = true
          end
        end
      end

      pokemon.ability_index = pokemon.body_original_ability_index if pokemon.body_original_ability_index
      poke2.ability_index = pokemon.head_original_ability_index if pokemon.head_original_ability_index

      pokemon.ability2_index = nil
      pokemon.ability2 = nil
      poke2.ability2_index = nil
      poke2.ability2 = nil

      pokemon.debug_shiny = true if pokemon.debug_shiny && pokemon.body_shiny
      poke2.debug_shiny = true if pokemon.debug_shiny && poke2.head_shiny

      pokemon.body_shiny = false
      pokemon.head_shiny = false

      if !pokemon.shiny?
        pokemon.debug_shiny = false
      end
      if !poke2.shiny?
        poke2.debug_shiny = false
      end

      if $Trainer.party.length >= 6
        if (keepInParty == 0)
          if isOnPinkanIsland()
            scene.pbDisplay(_INTL("{1} was released.", poke2.name))
          else
            $PokemonStorage.pbStoreCaught(poke2)
            scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
          end
        else
          poke2 = Pokemon.new(bodyPoke, body_level)
          poke1 = Pokemon.new(headPoke, head_level)

          # Fusing from PC
          if pcPosition != nil
            box = pcPosition[0]
            index = pcPosition[1]
            # todo: store at next available position from current position
            $PokemonStorage.pbStoreCaught(poke2)
          else
            # Fusing from party
            if isOnPinkanIsland()
              scene.pbDisplay(_INTL("{1} was released.", poke2.name))
            else
              $PokemonStorage.pbStoreCaught(poke2)
              scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
            end
          end
        end
      else
        if pcPosition != nil
          box = pcPosition[0]
          index = pcPosition[1]
          # todo: store at next available position from current position
          $PokemonStorage.pbStoreCaught(poke2)
        else
          Kernel.pbAddPokemonSilent(poke2, poke2.level)
        end
      end

      # On ajoute les poke au pokedex
      $Trainer.pokedex.set_seen(poke1.species)
      $Trainer.pokedex.set_owned(poke1.species)
      $Trainer.pokedex.set_seen(poke2.species)
      $Trainer.pokedex.set_owned(poke2.species)

      pokemon.species = poke1.species
      pokemon.level = poke1.level
      pokemon.name = poke1.name
      pokemon.moves = poke1.moves
      pokemon.obtain_method = 0
      poke1.obtain_method = 0

      # scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
      return true
    end
  end
end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, item)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item

  $PokemonBag.pbStoreItem(it1, 1) if it1 != nil
  $PokemonBag.pbStoreItem(it2, 1) if it2 != nil

  pokemon.item = nil
  poke2.item = nil
end

# A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
#
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    # if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    # else
    # pokemon.moves[move].dmgup+=1
    # pokemon.moves[move].damage +=5
    # pokemon.moves[move].accuracy -=5

    # movename=PBMoves.getName(pokemon.moves[move].id)
    # scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    # next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    # end
  end
})

##New "stones"
# ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

# ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

#
# ItemHandlers::UseOnPokemon.copy(:FIRESTONE,
#    :THUNDERSTONE,:WATERSTONE,:LEAFSTONE,:MOONSTONE,
#    :SUNSTONE,:DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:OVALSTONE,
#    :UPGRADE,:DUBIOUSDISC,:ICESTONE,:MAGNETSTONE)

# Quest log

ItemHandlers::UseFromBag.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
  next 1
})

ItemHandlers::UseInField.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
})

# TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  track_pokemon()
  next true
})
ItemHandlers::UseFromBag.add(:REVEALGLASS, proc { |item|
  track_pokemon()
  next true
})

def getAllCurrentlyRoamingPokemon
  currently_roaming = []
  Settings::ROAMING_SPECIES.each_with_index do |data, i|
    next if !GameData::Species.exists?(data[0])
    next if data[2] > 0 && !$game_switches[data[2]] # Isn't roaming
    next if $PokemonGlobal.roamPokemon[i] == true # Roaming Pokémon has been caught
    currently_roaming << i
  end
  return currently_roaming
end

def track_pokemon()
  currently_roaming = getAllCurrentlyRoamingPokemon()
  echoln currently_roaming
  weather_data = []
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  currently_roaming.each do |roamer_id|
    map_id = $PokemonGlobal.roamPosition[roamer_id]
    map_name = mapinfos[map_id].name
    weather_type = Settings::ROAMING_SPECIES[roamer_id][6]
    case weather_type
    when :Storm
      forecast_msg = _INTL("An unusual \\c[6]thunderstorm\\c[0] has been detected around \\c[6]{1}", map_name)
    when :StrongWinds
      forecast_msg = _INTL("Unusually \\c[9]strong winds\\c[0] have been detected around \\c[9]{1}", map_name)
    when :Sunny
      forecast_msg = _INTL("Unusually \\c[10]harsh sunlight\\c[0] has been detected around \\c[10]{1}", map_name)
    end
    weather_data << forecast_msg if forecast_msg && !weather_data.include?(forecast_msg)
  end
  weather_data << _INTL("No unusual weather patterns have been detected.") if weather_data.empty?
  weather_data.each do |message|
    Kernel.pbMessage(message)
  end

  # nbRoaming = 0
  # if Settings::ROAMING_SPECIES.length == 0
  #   Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
  # else
  #   text = "\\l[8]"
  #   min = $game_switches[350] ? 0 : 1
  #   for i in min...Settings::ROAMING_SPECIES.length
  #     poke = Settings::ROAMING_SPECIES[i]
  #     next if poke[0] == :FEEBAS
  #     if $game_switches[poke[2]]
  #       status = $PokemonGlobal.roamPokemon[i]
  #       if status == true
  #         if $PokemonGlobal.roamPokemonCaught[i]
  #           text += _INTL("{1} has been caught.",
  #                         PBSpecies.getName(getID(PBSpecies, poke[0])))
  #         else
  #           text += _INTL("{1} has been defeated.",
  #                         PBSpecies.getName(getID(PBSpecies, poke[0])))
  #         end
  #       else
  #         nbRoaming += 1
  #         curmap = $PokemonGlobal.roamPosition[i]
  #         if curmap
  #           mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  #
  #           if curmap == $game_map.map_id
  #             text += _INTL("Beep beep! {1} appears to be nearby!",
  #                           PBSpecies.getName(getID(PBSpecies, poke[0])))
  #           else
  #             text += _INTL("{1} is roaming around {3}",
  #                           PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
  #                           mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
  #           end
  #         else
  #           text += _INTL("{1} is roaming in an unknown area.",
  #                         PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
  #         end
  #       end
  #     else
  #       #text+=_INTL("{1} does not appear to be roaming.",
  #       #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
  #     end
  #     #text += "\n" if i < Settings::ROAMING_SPECIES.length - 1
  #   end
  #   if nbRoaming == 0
  #     text = "No Pokémon appears to be roaming at this moment."
  #   end
  #   Kernel.pbMessage(text)
  # end
end

####EXP. ALL
# Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseInField.add(:BOXLINK, proc { |item|
  blacklisted_maps = [
    315, 316, 317, 318, 328, 343, # Elite Four
    776, 777, 778, 779, 780, 781, 782, 783, 784, # Mt. Silver
    722, 723, 724, 720, # Dream sequence
    304, 306, 307 # Victory road
  ]
  if blacklisted_maps.include?($game_map.map_id)
    Kernel.pbMessage("There doesn't seem to be any network coverage here...")
  else
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0) # Boot PC in organize mode
    }
  end
  next 1
})