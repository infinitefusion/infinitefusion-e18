class HallOfFameSimple_Scene < HallOfFame_Scene

  #Hardcoded for Hoenn Pt.1
  NB_QUESTS_AVAILABLE = 20  #Doesn't count main quests or unavailable quests.
  NB_TEAM_QUESTS_AVAILABLE = 7
  NB_QUESTS_PRODUCER = 7

  TOTAL_NPC_TRAINERS = 101  #Includes rival, wally, gym leaders, but not non-rematchable trainers like team magma, move tutors, etc.

  ANIMATION = true
  ENTRYMUSIC = "part1_end"

  def getHallOfFameBackground
    return "Graphics/Pictures/HallOfFame/hoenn_part1"
  end

  def saveHallEntry
    for i in 0...$Trainer.party.length
      @hallEntry.push($Trainer.party[i].clone) if !$Trainer.party[i].egg? || ALLOWEGGS
    end
  end
  def pbUpdateAnimation
    if @battlerIndex <= @hallEntry.size
      if @xmovement[@battlerIndex] != 0 || @ymovement[@battlerIndex] != 0
        spriteIndex = (@battlerIndex < @hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex += 1
        if @battlerIndex <= @hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the
          # ENTRYWAITTIME and goes to the next battler
          # @hallEntry[@battlerIndex - 1].play_cry
          # writePokemonData(@hallEntry[@battlerIndex - 1])
          # (ENTRYWAITTIME * Graphics.frame_rate / 20).times do
          #   Graphics.update
          #   Input.update
          #   pbUpdate
          # end
          if @battlerIndex < @hallEntry.size # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex, OPACITY)
            @sprites["overlay"].bitmap.clear
          else
            # Show the welcome message and preparates the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            createTrainerBattler
            (ENTRYWAITTIME * 2 * Graphics.frame_rate / 20).times do
              moveSprite(-1)
              Graphics.update
              Input.update
              pbUpdate
            end

            writeInfo
            while !(waitForInput)
              Graphics.update
              Input.update
              pbUpdate
            end
            setPokemonSpritesOpacity(-1, OPACITY) # if !@singlerow
          end
        end
      end
    elsif @battlerIndex > @hallEntry.size
      # Write the trainer data and fade
      writeTrainerData
      while !(waitForInput)
        Graphics.update
        Input.update
        pbUpdate
      end
      fadeSpeed = ((Math.log(2 ** 12) - Math.log(FINALFADESPEED)) / Math.log(2)).floor
      pbBGMFade((2 ** fadeSpeed).to_f / 20) if @useMusic
      slowFadeOut(@sprites, fadeSpeed) { pbUpdate }
      @alreadyFadedInEnd = true
      @battlerIndex += 1
    end
  end


  def pbStartSceneEntry
    @singlerow = true
    pbStartScene
    @useMusic = (ENTRYMUSIC && ENTRYMUSIC != "")
    pbBGMPlay(ENTRYMUSIC) if @useMusic
    saveHallEntry
    @xmovement = Array.new(@hallEntry.size, 0)
    @ymovement = Array.new(@hallEntry.size, 0)
    createBattlers(false)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def writeTrainerData
    lefttext = _INTL("<ac>PIF2 (Part 1) - Completion                                   </ac>")
    lefttext += _INTL("{1} ({2})<br>", getCurrentGameMode, getDisplayDifficulty)
    lefttext += _INTL("Pokédex:<r>{1} / {2}<br>", $Trainer.pokedex.owned_count, NB_POKEMON)
    lefttext += _INTL("Side Quests:<r>{1}<br>", getSidequestsStats())
    lefttext += _INTL("Hats Unlocked:<r>{1} / {2}<br>", $Trainer.unlocked_hats.length, $PokemonGlobal.hats_data.length)
    lefttext += _INTL("Clothes Unlocked:<r>{1} / {2}<br>", $Trainer.unlocked_clothes.length, $PokemonGlobal.clothes_data.length)
    nb_friends = listNPCFriends().length
    lefttext += _INTL("Trainers Befriended:<r>{1}/{2}<br>", nb_friends,TOTAL_NPC_TRAINERS)

    for n in 0...@hallEntry.size
      if @sprites["pokemon#{n}"]
        @sprites["pokemon#{n}"].y += 136
        @sprites["pokemon#{n}"].opacity = 255
      end
    end
    @sprites["trainer"].y += 136 if @sprites["trainer"]

    @sprites["hallbars"].visible = false if @sprites["hallbars"]
    @sprites["overlay"].bitmap.clear if @sprites["overlay"]
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].opacity=200
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
    #@sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
  end



  def writeWelcome
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pbDrawTextPositions(overlay, [[_INTL("Pokémon Infinite Fusion 2: Hoenn"),
                                   Graphics.width / 2, Graphics.height - 80, 2, BASECOLOR, SHADOWCOLOR]])
    pbDrawTextPositions(overlay, [[_INTL("Part 1"),
                                   Graphics.width / 2, Graphics.height - 50, 2, BASECOLOR, SHADOWCOLOR]])
  end
  def writeInfo
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pbDrawTextPositions(overlay, [[_INTL("Pokémon Infinite Fusion 2: Hoenn (Part 1)"),
                                   Graphics.width / 2, Graphics.height - 80, 2, BASECOLOR, SHADOWCOLOR]])
    writeDate(overlay, 120, Graphics.height - 50)
    writeGameMode(overlay, (Graphics.width / 2) + 100, Graphics.height - 50)
  end

  #List every battled trainer that is at at least 1 heart
  def listNPCFriends
    fixRivalsFriendship
    friends_list = []
    $PokemonGlobal.battledTrainers.each do |id, trainer|
      friends_list << id if trainer.friendship_level >= 1
    end
    return friends_list
  end

  #set rival friendships if not already set (for older versions compatibility)
  def fixRivalsFriendship
    rival =  getRebattledTrainerFromKey(BATTLED_TRAINER_RIVAL_KEY)
    wally = getRebattledTrainerFromKey(BATTLED_TRAINER_WALLY_KEY)
    if rival.friendship_level == 0
      rival.friendship_level = 2
      $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival
    end
    if wally.friendship_level == 0
      wally.friendship_level = 1
      $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY] = wally
    end
  end

  def getSidequestsStats
    nb_completed = get_completed_quests(false,false).length
    nb_total = NB_QUESTS_AVAILABLE + NB_QUESTS_PRODUCER + NB_TEAM_QUESTS_AVAILABLE
    message = _INTL("{1} / {2}",nb_completed, nb_total)
    return message
  end

end



def pbHallOfFameSimple
  scene = HallOfFameSimple_Scene.new
  screen = HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end