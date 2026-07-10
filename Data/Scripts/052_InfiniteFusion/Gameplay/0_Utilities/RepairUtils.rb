###################
##  CONVERTER     #
###################
def convertAllPokemon()
  Kernel.pbMessage(_INTL("The game has detected that your previous savefile was from an earlier build of the game."))
  Kernel.pbMessage(_INTL("In order to play this version, your Pokémon need to be converted to their new Pokédex numbers. "))
  Kernel.pbMessage(_INTL("If you were playing Randomized mode, the trainers and wild Pokémon will also need to be reshuffled."))


  if (Kernel.pbConfirmMessage(_INTL("Convert your Pokémon?")))

    #get previous version
    msgwindow = Kernel.pbCreateMessageWindow(nil)
    msgwindow.text = _INTL("What is the last version of the game you played?")
    choice = Kernel.pbShowCommands(msgwindow, [
      _INTL("4.7        (September 2020)"),
      _INTL("4.5-4.6.2        (2019-2020)"),
      _INTL("4.2-4.4           (2019)"),
      _INTL("4.0-4.1           (2018-2019)"),
      _INTL("3.x or earlier (2015-2018)")], -1)
    case choice
    when 0
      prev_total = 381
    when 1
      prev_total = 351
    when 2
      prev_total = 315
    when 3
      prev_total = 275
    when 4
      prev_total = 151
    else
      prev_total = 381
    end
    Kernel.pbDisposeMessageWindow(msgwindow)

    pbEachPokemon { |poke, box|
      if poke.species >= NB_POKEMON
        pf = poke.species
        pBody = (pf / prev_total).round
        pHead = pf - (prev_total * pBody)

        #   Kernel.pbMessage("pbod {1} pHead {2}, species: {3})",pBody,pHead,pf)

        prev_max_value = (prev_total * prev_total) + prev_total
        if pf >= prev_max_value
          newSpecies = convertTripleFusion(pf, prev_max_value)
          if newSpecies == nil
            boxname = box == -1 ? "Party" : box
            Kernel.pbMessage(_INTL("Invalid Pokémon detected in box {1}:\n num. {2}, {3} (lv. {4})", boxname, pf, poke.name, poke.level))
            if (Kernel.pbConfirmMessage(_INTL("Delete Pokémon and continue?")))
              poke = nil
              next
            else
              Kernel.pbMessage(_INTL("Conversion cancelled. Please restart the game."))
              Graphics.freeze
            end
          end
        end

        newSpecies = pBody * NB_POKEMON + pHead
        poke.species = newSpecies
      end
    }
    Kernel.initRandomTypeArray()
    if $game_switches[SWITCH_RANDOM_TRAINERS] #randomized trainers
      Kernel.pbShuffleTrainers()
    end
    if $game_switches[956] #randomized pokemon
      range = pbGet(197) == nil ? 25 : pbGet(197)
      Kernel.pbShuffleDex(range, 1)
    end

  end

end

def convertTripleFusion(species, prev_max_value)
  if prev_max_value == (351 * 351) + 351
    case species
    when 123553
      return 145543
    when 123554
      return 145544
    when 123555
      return 145545
    when 123556
      return 145546
    when 123557
      return 145547
    when 123558
      return 145548
    else
      return nil
    end
  end
  return nil
end


def convertTrainers()
  if ($game_switches[SWITCH_RANDOM_TRAINERS])
    Kernel.pbShuffleTrainers()
  end
end

def convertAllPokemonManually()

  if (Kernel.pbConfirmMessage(_INTL("When you last played the game, where there any gen 2 Pokémon?")))
    #4.0
    prev_total = 315
  else
    #3.0
    prev_total = 151
  end
  convertPokemon(prev_total)
end

def convertPokemon(prev_total = 275)
  pbEachPokemon { |poke, box|
    if poke.species >= NB_POKEMON
      pf = poke.species
      pBody = (pf / prev_total).round
      pHead = pf - (prev_total * pBody)

      newSpecies = pBody * NB_POKEMON + pHead
      poke.species = newSpecies
    end
  }
end

def fixMissedHMs()
  # Flash
  if $PokemonBag.pbQuantity(:HM08) < 1 && $PokemonGlobal.questRewardsObtained.include?(:HM08)
    pbReceiveItem(:HM08)
  end

  # Cut
  if $PokemonBag.pbQuantity(:HM01) < 1 && $game_switches[SWITCH_SS_ANNE_DEPARTED]
    pbReceiveItem(:HM01)
  end

  # Strength
  if $PokemonBag.pbQuantity(:HM04) < 1 && $game_switches[SWITCH_SNORLAX_GONE_ROUTE_12]
    pbReceiveItem(:HM04)
  end

  # Surf
  if $PokemonBag.pbQuantity(:HM03) < 1 && $game_self_switches[[107, 1, "A"]]
    pbReceiveItem(:HM03)
  end

  # Teleport
  if $PokemonBag.pbQuantity(:HM07) < 1 && $game_switches[SWITCH_TELEPORT_NPC]
    pbReceiveItem(:HM07)
  end

  # Fly
  if $PokemonBag.pbQuantity(:HM02) < 1 && $game_self_switches[[439, 1, "B"]]
    pbReceiveItem(:HM02)
  end

  # Waterfall
  if $PokemonBag.pbQuantity(:HM05) < 1 && $game_switches[SWITCH_GOT_WATERFALL]
    pbReceiveItem(:HM05)
  end

  # Dive
  if $PokemonBag.pbQuantity(:HM06) < 1 && $game_switches[SWITCH_GOT_DIVE]
    pbReceiveItem(:HM06)
  end

  # Rock Climb
  if $PokemonBag.pbQuantity(:HM10) < 1 && $game_switches[SWITCH_GOT_ROCK_CLIMB]
    pbReceiveItem(:HM10)
  end
end

def fixFinishedRocketQuests()
  fix_broken_TR_quests()

  var_tr_missions_cerulean = 288

  switch_tr_mission_cerulean_4 = 1116
  switch_tr_mission_celadon_1 = 1084
  switch_tr_mission_celadon_2 = 1086
  switch_tr_mission_celadon_3 = 1088
  switch_tr_mission_celadon_4 = 1110
  switch_pinkan_done = 1119

  nb_cerulean_missions = pbGet(var_tr_missions_cerulean)

  finishTRQuest("tr_cerulean_1", :SUCCESS, true) if nb_cerulean_missions >= 1 && !pbCompletedQuest?("tr_cerulean_1")
  echoln pbCompletedQuest?("tr_cerulean_1")
  finishTRQuest("tr_cerulean_2", :SUCCESS, true) if nb_cerulean_missions >= 2 && !pbCompletedQuest?("tr_cerulean_2")
  finishTRQuest("tr_cerulean_3", :SUCCESS, true) if nb_cerulean_missions >= 3 && !pbCompletedQuest?("tr_cerulean_3")
  finishTRQuest("tr_cerulean_4", :SUCCESS, true) if $game_switches[switch_tr_mission_cerulean_4] && !pbCompletedQuest?("tr_cerulean_4")

  finishTRQuest("tr_celadon_1", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_1] && !pbCompletedQuest?("tr_celadon_1")
  finishTRQuest("tr_celadon_2", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_2] && !pbCompletedQuest?("tr_celadon_2")
  finishTRQuest("tr_celadon_3", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_3] && !pbCompletedQuest?("tr_celadon_3")
  finishTRQuest("tr_celadon_4", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_4] && !pbCompletedQuest?("tr_celadon_4")

  finishTRQuest("tr_pinkan", :SUCCESS, true) if $game_switches[switch_pinkan_done] && !pbCompletedQuest?("tr_pinkan")
end

def fix_broken_TR_quests()
  for trainer_quest in $Trainer.quests
    if trainer_quest.id == 0 # tr quests were all set to ID 0 instead of their real ID in v 6.4.0
      for rocket_quest_id in TR_QUESTS.keys
        rocket_quest = TR_QUESTS[rocket_quest_id]
        next if !rocket_quest
        if trainer_quest.name == rocket_quest.name
          trainer_quest.id = rocket_quest_id
        end
      end
    end
  end
end

def fix_missing_infinite_splicers
  return unless Settings::KANTO
  obtained_infinite_splicers = $game_switches[275]
  obtained_upgraded_infinite_splicers = $game_self_switches[[703,4,"A"]]
  if obtained_infinite_splicers && pbQuantity(:INFINITESPLICERS) <= 0 && pbQuantity(:INFINITESPLICERS2) <= 0
    pbReceiveItem(:INFINITESPLICERS)
  end
  if obtained_upgraded_infinite_splicers && pbQuantity(:INFINITESPLICERS2) <= 0
    pbReceiveItem(:INFINITESPLICERS2)
  end
end


#Called from the fix game npc common event.
# Would be nice to migrate all the stuff in there over here

SWITCH_HOENN_GOT_POKEBALLS = 2018
SWITCH_HOENN_BEAT_RIVAL_RT_110 = 2116
def fixStuff
  if Settings::HOENN
    if $game_switches[SWITCH_HOENN_GOT_POKEBALLS]
      $Trainer.install_app(:QUESTS) unless $Trainer.pokenav.has_app(:QUESTS)
      $Trainer.install_app(:MAP) unless $Trainer.pokenav.has_app(:MAP)
      $Trainer.install_app(:DAYNIGHT) unless $Trainer.pokenav.has_app(:DAYNIGHT)
      $Trainer.install_app(:REARRANGE) unless $Trainer.pokenav.has_app(:REARRANGE)
      $Trainer.install_app(:CONTACTS) unless $Trainer.pokenav.has_app(:CONTACTS)
    end
    if $game_switches[SWITCH_HOENN_BEAT_RIVAL_RT_110]
      $Trainer.install_app(:POKERADAR) unless $Trainer.pokenav.has_app(:POKERADAR)
    end


    if $game_variables[1033].is_a?(String)  #graffiti/trick house variable mixup
      $game_variables[1033] = 0
    end
  end



  $PokemonGlobal.sliding=false
  $game_player.walk_anime=true
  $game_player.direction_fix=false

  PokemonSelection.restore
  $game_system.menu_disabled=false
  clear_all_images
  Kernel.initRandomTypeArray

  #fixMissedHMs
  # todo: make a hoenn version of missed HMs

  $game_switches[SWITCH_CANNOT_CATCH_POKEMON] = false
  $game_switches[SWITCH_AQUA_CAMP] = false
  restoreDefaultCharacterSprite
  Graphics.update
  Input.update
  pbUpdateSceneMap
end