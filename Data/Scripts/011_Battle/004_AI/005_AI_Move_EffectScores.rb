class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    case move.function
      #---------------------------------------------------------------------------
    when MoveFunctions::NO_ADDITIONAL_EFFECT   # No extra effect
      #---------------------------------------------------------------------------
    when MoveFunctions::NO_EFFECT # Splash, Counterfeit
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
      #---------------------------------------------------------------------------
    when MoveFunctions::STRUGGLE   # Struggle
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_SLEEP # Spore, Sing, Hypnosis, Sleep Powder, Dark Void...
      if target.pbCanSleep?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score -= 30 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.mediumSkill
          if target.pbHasMoveFunction?(MoveFunctions::HIT_ONLY_WHILE_ASLEEP,MoveFunctions::RANDOM_MOVE_WHILE_ASLEEP)   # Snore, Sleep Talk
            score -= 50
          end
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_DROWSY #Yawn
      if target.effects[PBEffects::Yawn]>0 || !target.pbCanSleep?(user,false)
        score -= 90 if skill>=PBTrainerAI.mediumSkill
      else
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?(MoveFunctions::HIT_ONLY_WHILE_ASLEEP,MoveFunctions::RANDOM_MOVE_WHILE_ASLEEP)   # Snore, Sleep Talk
            score -= 50
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_POISON, MoveFunctions::INFLICT_BAD_POISON, MoveFunctions::HIT_TWICE_POISON # Sludge Bomb, Poison Jab, Gunk Shot, Smog, Poison Gas... / Toxic, Poison Fang / Twineedle
      if target.pbCanPoison?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if target.hp<=target.totalhp/4
          score += 50 if target.hp<=target.totalhp/8
          score -= 40 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
          score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_PARALYSIS, MoveFunctions::INFLICT_PARALYSIS_THUNDER, MoveFunctions::PARALYZE_OR_FLINCH, MoveFunctions::TWO_TURN_FREEZE_SHOCK # Thunderbolt, Thunder Wave, Body Slam, Glare, Stun Spore... / Thunder (weather affects accuracy) / Thunder Fang / Freeze Shock
      if target.pbCanParalyze?(user,false) &&
        !(skill>=PBTrainerAI.mediumSkill &&
          move.id == :THUNDERWAVE &&
          Effectiveness.ineffective?(pbCalcTypeMod(move.type,user,target)))
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_BURN, MoveFunctions::BURN_OR_FLINCH, MoveFunctions::TWO_TURN_ICE_BURN # Flamethrower, Fire Blast, Will-O-Wisp, Scald, Ember... / Fire Fang / Ice Burn
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_FREEZE, MoveFunctions::INFLICT_FREEZE_BLIZZARD, MoveFunctions::FREEZE_OR_FLINCH # Ice Beam, Ice Punch, Powder Snow / Blizzard (perfect accuracy in hail) / Ice Fang
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FLINCH # Bite, Air Slash, Iron Head, Headbutt, Rock Slide...
      score += 30
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
          target.effects[PBEffects::Substitute]==0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FLINCH_MINIMIZE_BOOST # Stomp, Steamroller, Dragon Rush
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
          target.effects[PBEffects::Substitute]==0
      end
      score += 30 if target.effects[PBEffects::Minimize]
      #---------------------------------------------------------------------------
    when MoveFunctions::HIT_ONLY_WHILE_ASLEEP # Snore
      if user.asleep?
        score += 100   # Because it can only be used while asleep
        if skill>=PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
            target.effects[PBEffects::Substitute]==0
        end
      else
        score = 0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FLINCH_FIRST_TURN_ONLY # Fake Out
      if user.turnCount==0
        if skill>=PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
            target.effects[PBEffects::Substitute]==0
        end
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_CONFUSION, MoveFunctions::INFLICT_CONFUSION_CHATTER, MoveFunctions::INFLICT_CONFUSION_HURRICANE # Psybeam, Confusion, Confuse Ray, Supersonic, Water Pulse... / Chatter / Hurricane (weather affects accuracy)
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::INFLICT_ATTRACT # Attract
      canattract = true
      agender = user.gender
      ogender = target.gender
      if agender==2 || ogender==2 || agender==ogender
        score -= 90; canattract = false
      elsif target.effects[PBEffects::Attract]>=0
        score -= 80; canattract = false
      elsif skill>=PBTrainerAI.bestSkill && target.hasActiveAbility?(:OBLIVIOUS)
        score -= 80; canattract = false
      end
      if skill>=PBTrainerAI.highSkill
        if canattract && target.hasActiveItem?(:DESTINYKNOT) &&
          user.pbCanAttract?(target,false)
          score -= 30
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BURN_FREEZE_OR_PARALYZE #Tri Attack
      score += 30 if target.status == :NONE
      #---------------------------------------------------------------------------
    when MoveFunctions::CURE_USER_STATUS #Refresh
      case user.status
      when :POISON
        score += 40
        if skill>=PBTrainerAI.mediumSkill
          if user.hp<user.totalhp/8
            score += 60
          elsif skill>=PBTrainerAI.highSkill &&
            user.hp<(user.effects[PBEffects::Toxic]+1)*user.totalhp/16
            score += 60
          end
        end
      when :BURN, :PARALYSIS
        score += 40
      else
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CURE_PARTY_STATUS # Aromatherapy, Heal Bell
      statuses = 0
      @battle.pbParty(user.index).each do |pkmn|
        statuses += 1 if pkmn && pkmn.status != :NONE
      end
      if statuses==0
        score -= 80
      else
        score += 20*statuses
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SAFEGUARD # Safeguard
      if user.pbOwnSide.effects[PBEffects::Safeguard]>0
        score -= 80
      elsif user.status != :NONE
        score -= 40
      else
        score += 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TRANSFER_STATUS # Psycho Shift
      if user.status == :NONE
        score -= 90
      else
        score += 40
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATTACK_UP_1 # Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score -= user.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEFENSE_UP_1, MoveFunctions::USER_DEFENSE_UP_1_CURL, MoveFunctions::TWO_TURN_SKULL_BASH # Harden, Withdraw, Steel Wing / Defense Curl / Skull Bash
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score -= user.stages[:DEFENSE]*20
        end
      else
        score += 20 if user.stages[:DEFENSE]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SPEED_UP_1 # Flame Charge
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score -= user.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[:SPEED]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_UP_1 # Charge Beam, Fiery Dance
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score -= user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_DEF_UP_1_CHARGE # Charge
      foundMove = false
      user.eachMove do |m|
        next if m.type != :ELECTRIC || !m.damagingMove?
        foundMove = true
        break
      end
      score += 20 if foundMove
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_DEFENSE)
          score -= 90
        else
          score -= user.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 20 if user.stages[:SPECIAL_DEFENSE]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_EVASION_UP_1 # Double Team
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score -= user.stages[:EVASION]*10
        end
      else
        score += 20 if user.stages[:EVASION]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_CRIT_RATE_UP # Focus Energy
      if move.statusMove?
        if user.effects[PBEffects::FocusEnergy]>=2
          score -= 80
        else
          score += 30
        end
      else
        score += 30 if user.effects[PBEffects::FocusEnergy]<2
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_DEF_UP_1 # Bulk Up
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:DEFENSE)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:DEFENSE]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_DEF_ACC_UP_1 # Coil
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:DEFENSE) &&
        user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:ACCURACY]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_SPEED_UP_1 # Dragon Dance
      score += 40 if user.turnCount==0   # Dragon Dance tends to be popular
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 20 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_SP_ATK_UP_1, MoveFunctions::USER_ATK_SP_ATK_UP_1_SUN # Work Up / Growth (doubled in sun)
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:SPECIAL_ATTACK)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPECIAL_ATTACK]*10
        if skill>=PBTrainerAI.mediumSkill
          hasDamagingAttack = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingAttack = true
            break
          end
          if hasDamagingAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if move.function==MoveFunctions::USER_ATK_SP_ATK_UP_1_SUN   # Growth
          score += 20 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_ACC_UP_1 # Hone Claws
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:ACCURACY]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEF_SP_DEF_UP_1 # Cosmic Power, Defend Order
      if user.statStageAtMax?(:DEFENSE) &&
        user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_SP_DEF_SPEED_UP_1 # Quiver Dance
      if user.statStageAtMax?(:SPEED) &&
        user.statStageAtMax?(:SPECIAL_ATTACK) &&
        user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed && aspeed*2>ospeed
            score += 20
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_SP_DEF_UP_1 # Calm Mind
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
        user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score += 40 if user.turnCount==0   # Calm Mind tends to be popular
        score -= user.stages[:SPECIAL_ATTACK]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ALL_STATS_UP_1 # Ancient Power, Ominous Wind, Silver Wind
      GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] < 0 }
      if skill>=PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATTACK_UP_2 # Swords Dance
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEFENSE_UP_2 # Acid Armor, Barrier, Iron Defense
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:DEFENSE]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SPEED_UP_2, MoveFunctions::USER_SPEED_UP_2_LOSE_WEIGHT # Agility, Rock Polish / Autotomize
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score -= user.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPEED]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_UP_2 # Nasty Plot
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_DEF_UP_2 # Amnesia
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPECIAL_DEFENSE]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_EVASION_UP_2_MINIMIZE # Minimize
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:EVASION]*10
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:EVASION]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SHELL_SMASH # Shell Smash
      score -= user.stages[:ATTACK]*20
      score -= user.stages[:SPEED]*20
      score -= user.stages[:SPECIAL_ATTACK]*20
      score += user.stages[:DEFENSE]*10
      score += user.stages[:SPECIAL_DEFENSE]*10
      if skill>=PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SPEED_UP_2_ATTACK_UP_1 # Shift Gear
      if user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 30 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RAISE_RANDOM_STAT_2 # Acupressure
      avgStat = 0; canChangeStat = false
      GameData::Stat.each_battle do |s|
        next if target.statStageAtMax?(s.id)
        avgStat -= target.stages[s.id]
        canChangeStat = true
      end
      if canChangeStat
        avgStat = avgStat/2 if avgStat<0   # More chance of getting even better
        score += avgStat*10
      else
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEFENSE_UP_3 # Cotton Guard
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:DEFENSE]*30
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if user.stages[:DEFENSE]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_UP_3 # Tail Glow
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_ATTACK]*30
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_BELLY_DRUM # Belly Drum
      if user.statStageAtMax?(:ATTACK) ||
        user.hp<=user.totalhp/2
        score -= 100
      else
        score += (6-user.stages[:ATTACK])*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 40
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_ATK_DEF_DOWN_1 # Superpower
      avg =  user.stages[:ATTACK]*10
      avg += user.stages[:DEFENSE]*10
      score += avg/2
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEF_SP_DEF_DOWN_1 # Close Combat, Dragon Ascent
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEF_SP_DEF_SPEED_DOWN_1 # V-create
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPEED]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += (avg/3).floor
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SPEED_DOWN_1 # Hammer Arm, Ice Hammer
      score += user.stages[:SPEED]*10
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_SP_ATK_DOWN_2 # Draco Meteor, Overheat, Leaf Storm, Psycho Boost, Fleur Cannon
      score += user.stages[:SPECIAL_ATTACK]*10
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_ATK_UP_1_CONFUSE # Flatter
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:SPECIAL_ATTACK]<0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATTACK_UP_2_CONFUSE  #Swagger
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:ATTACK]<0
        score += 40 if user.ability == :PRANKSTER
        score += 30 if user.pbHasMove?(:FOULPLAY)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATTACK_DOWN_1 # Growl, Play Rough, Lunge, Baby-Doll Eyes, Aurora Beam...
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ATTACK,user)
          score -= 90
        else
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if target.stages[:ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_DEFENSE_DOWN_1 # Leer, Tail Whip, Crunch, Iron Tail, Rock Smash...
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:DEFENSE,user)
          score -= 90
        else
          score += target.stages[:DEFENSE]*20
        end
      else
        score += 20 if target.stages[:DEFENSE]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SPEED_DOWN_1 # Icy Wind, Bulldoze, Mud Shot, Rock Tomb, Bubble Beam...
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPEED,user)
          score -= 90
        else
          score += target.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[:SPEED]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_ATK_DOWN_1 # Moonblast, Snarl, Struggle Bug, Mystical Fire, Mist Ball
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
          score -= 90
        else
          score += user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_DEF_DOWN_1 # Psychic, Shadow Ball, Energy Ball, Earth Power, Bug Buzz...
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
          score -= 90
        else
          score += target.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 20 if target.stages[:SPECIAL_DEFENSE]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ACCURACY_DOWN_1 # Smokescreen, Sand Attack, Mud-Slap, Flash, Octazooka...
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ACCURACY,user)
          score -= 90
        else
          score += target.stages[:ACCURACY]*10
        end
      else
        score += 20 if target.stages[:ACCURACY]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_EVASION_DOWN # Sweet Scent
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:EVASION,user)
          score -= 90
        else
          score += target.stages[:EVASION]*10
        end
      else
        score += 20 if target.stages[:EVASION]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_EVASION_DOWN_CLEAR_FIELD # Defog
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:EVASION,user)
          score -= 90
        else
          score += target.stages[:EVASION]*10
        end
      else
        score += 20 if target.stages[:EVASION]>0
      end
      score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
        target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
        target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
        target.pbOwnSide.effects[PBEffects::Mist]>0 ||
        target.pbOwnSide.effects[PBEffects::Safeguard]>0
      score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
        target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
        target.pbOwnSide.effects[PBEffects::StealthRock]
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATK_DEF_DOWN_1 # Tickle
      avg =  target.stages[:ATTACK]*10
      avg += target.stages[:DEFENSE]*10
      score += avg/2
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATTACK_DOWN_2 # Charm, Feather Dance
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ATTACK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_DEFENSE_DOWN_2 # Screech
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:DEFENSE,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:DEFENSE]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SPEED_DOWN_2 # String Shot, Cotton Spore, Scary Face
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPEED,user)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score += target.stages[:SPEED]*20
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if target.stages[:SPEED]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_ATK_DOWN_2_GENDER # Captivate
      if user.gender==2 || target.gender==2 || user.gender==target.gender ||
        target.hasActiveAbility?(:OBLIVIOUS)
        score -= 90
      elsif move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:SPECIAL_ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_DEF_DOWN_2 # Fake Tears, Acid Spray, Seed Flare, Metal Sound
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:SPECIAL_DEFENSE]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RESET_TARGET_STAT_STAGES # Clear Smog
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        avg = 0; anyChange = false
        GameData::Stat.each_battle do |s|
          next if target.stages[s.id]==0
          avg += target.stages[s.id]
          anyChange = true
        end
        if anyChange
          score += avg*10
        else
          score -= 90
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RESET_ALL_STAT_STAGES # Haze
      if skill>=PBTrainerAI.mediumSkill
        stages = 0
        @battle.eachBattler do |b|
          totalStages = 0
          GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
          if b.opposes?(user)
            stages += totalStages
          else
            stages -= totalStages
          end
        end
        score += stages*10
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_ATTACK_STAGES # Power Swap
      if skill>=PBTrainerAI.mediumSkill
        aatk = user.stages[:ATTACK]
        aspa = user.stages[:SPECIAL_ATTACK]
        oatk = target.stages[:ATTACK]
        ospa = target.stages[:SPECIAL_ATTACK]
        if aatk>=oatk && aspa>=ospa
          score -= 80
        else
          score += (oatk-aatk)*10
          score += (ospa-aspa)*10
        end
      else
        score -= 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_DEFENSE_STAGES # Guard Swap
      if skill>=PBTrainerAI.mediumSkill
        adef = user.stages[:DEFENSE]
        aspd = user.stages[:SPECIAL_DEFENSE]
        odef = target.stages[:DEFENSE]
        ospd = target.stages[:SPECIAL_DEFENSE]
        if adef>=odef && aspd>=ospd
          score -= 80
        else
          score += (odef-adef)*10
          score += (ospd-aspd)*10
        end
      else
        score -= 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_ALL_STAGES # Heart Swap
      if skill>=PBTrainerAI.mediumSkill
        userStages = 0; targetStages = 0
        GameData::Stat.each_battle do |s|
          userStages   += user.stages[s.id]
          targetStages += target.stages[s.id]
        end
        score += (targetStages-userStages)*10
      else
        score -= 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::COPY_TARGET_STAGES # Psych Up
      if skill>=PBTrainerAI.mediumSkill
        equal = true
        GameData::Stat.each_battle do |s|
          stagediff = target.stages[s.id] - user.stages[s.id]
          score += stagediff*10
          equal = false if stagediff!=0
        end
        score -= 80 if equal
      else
        score -= 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::PREVENT_STAT_DROPS # Mist
      score -= 80 if user.pbOwnSide.effects[PBEffects::Mist]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_USER_ATK_DEF # Power Trick
      if skill>=PBTrainerAI.mediumSkill
        aatk = pbRoughStat(user,:ATTACK,skill)
        adef = pbRoughStat(user,:DEFENSE,skill)
        if aatk==adef ||
          user.effects[PBEffects::PowerTrick]   # No flip-flopping
          score -= 90
        elsif adef>aatk   # Prefer a higher Attack
          score += 30
        else
          score -= 30
        end
      else
        score -= 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AVERAGE_ATTACK_STATS # Power Split
      if skill>=PBTrainerAI.mediumSkill
        aatk   = pbRoughStat(user,:ATTACK,skill)
        aspatk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        oatk   = pbRoughStat(target,:ATTACK,skill)
        ospatk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
        if aatk<oatk && aspatk<ospatk
          score += 50
        elsif aatk+aspatk<oatk+ospatk
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AVERAGE_DEFENSE_STATS # Guard Split
      if skill>=PBTrainerAI.mediumSkill
        adef   = pbRoughStat(user,:DEFENSE,skill)
        aspdef = pbRoughStat(user,:SPECIAL_DEFENSE,skill)
        odef   = pbRoughStat(target,:DEFENSE,skill)
        ospdef = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
        if adef<odef && aspdef<ospdef
          score += 50
        elsif adef+aspdef<odef+ospdef
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AVERAGE_HP # Pain Split
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp>=(user.hp+target.hp)/2
        score -= 90
      else
        score += 40
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TAILWIND # Tailwind
      score -= 90 if user.pbOwnSide.effects[PBEffects::Tailwind]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::MIMIC # Mimic
      moveBlacklist = [
        MoveFunctions::STRUGGLE,   # Struggle
        MoveFunctions::INFLICT_CONFUSION_CHATTER,   # Chatter
        MoveFunctions::MIMIC,   # Mimic
        MoveFunctions::SKETCH,   # Sketch
        MoveFunctions::METRONOME    # Metronome
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
          lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90
          break
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SKETCH # Sketch
      moveBlacklist = [
        MoveFunctions::STRUGGLE,   # Struggle
        MoveFunctions::INFLICT_CONFUSION_CHATTER,   # Chatter
        MoveFunctions::SKETCH    # Sketch
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
          lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90   # User already knows the move that will be Sketched
          break
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CHANGE_TYPE_TO_MOVE # Conversion
      if !user.canChangeType?
        score -= 90
      else
        has_possible_type = false
        user.eachMoveWithIndex do |m,i|
          break if Settings::MECHANICS_GENERATION >= 6 && i>0
          next if GameData::Type.get(m.type).pseudo_type
          next if user.pbHasType?(m.type)
          has_possible_type = true
          break
        end
        score -= 90 if !has_possible_type
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CHANGE_TYPE_TO_RESIST # Conversion 2
      if !user.canChangeType?
        score -= 90
      elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
        GameData::Type.get(target.lastMoveUsedType).pseudo_type
        score -= 90
      else
        aType = nil
        target.eachMove do |m|
          next if m.id!=target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if !aType
          score -= 90
        else
          has_possible_type = false
          GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
              !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            has_possible_type = true
            break
          end
          score -= 90 if !has_possible_type
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CHANGE_TYPE_BY_ENVIRONMENT # Camouflage
      if !user.canChangeType?
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        new_type = nil
        case @battle.field.terrain
        when :Electric
          new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
        when :Grassy
          new_type = :GRASS if GameData::Type.exists?(:GRASS)
        when :Misty
          new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
        when :Psychic
          new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        end
        if !new_type
          envtypes = {
            :None        => :NORMAL,
            :Grass       => :GRASS,
            :TallGrass   => :GRASS,
            :MovingWater => :WATER,
            :StillWater  => :WATER,
            :Puddle      => :WATER,
            :Underwater  => :WATER,
            :Cave        => :ROCK,
            :Rock        => :GROUND,
            :Sand        => :GROUND,
            :Forest      => :BUG,
            :ForestGrass => :BUG,
            :Snow        => :ICE,
            :Ice         => :ICE,
            :Volcano     => :FIRE,
            :Graveyard   => :GHOST,
            :Sky         => :FLYING,
            :Space       => :DRAGON,
            :UltraSpace  => :PSYCHIC
          }
          new_type = envtypes[@battle.environment]
          new_type = nil if !GameData::Type.exists?(new_type)
          new_type ||= :NORMAL
        end
        score -= 90 if !user.pbHasOtherType?(new_type)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_BECOMES_WATER # Soak
      if target.effects[PBEffects::Substitute]>0 || !target.canChangeType?
        score -= 90
      elsif !target.pbHasOtherType?(:WATER)
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::COPY_TARGET_TYPE # Reflect Type
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
        user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ABILITY_SIMPLE # Simple Beam
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability)
          score -= 90
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ABILITY_INSOMNIA # Worry Seed
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :INSOMNIA].include?(target.ability_id)
          score -= 90
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_COPY_TARGET_ABILITY # Role Play
      score -= 40   # don't prefer this move
      if skill>=PBTrainerAI.mediumSkill
        if !target.ability || user.ability==target.ability ||
          [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
          [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
           :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
          score -= 90
        end
      end
      if skill>=PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_COPY_USER_ABILITY # Entrainment
      score -= 40   # don't prefer this move
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if !user.ability || user.ability==target.ability ||
          [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
          [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
           :TRACE, :ZENMODE].include?(user.ability_id)
          score -= 90
        end
        if skill>=PBTrainerAI.highSkill
          if user.ability == :TRUANT && user.opposes?(target)
            score += 90
          elsif user.ability == :SLOWSTART && user.opposes?(target)
            score += 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_ABILITIES # Skill Swap
      score -= 40 # don't prefer this move
      if skill >= PBTrainerAI.mediumSkill
        if (!user.ability && !target.ability) ||
          user.ability == target.ability ||
          [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
          [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
          score -= 90
        end
      end

      hindering_abilities = [:TRUANT, :SLOWSTART]

      if skill >= PBTrainerAI.highSkill
        # opponent already has hindering ability: don't swap
        if hindering_abilities.include?(target.ability.id) && user.opposes?(target)
          score -= 90
          # user has hindering ability: immediately swap
        elsif hindering_abilities.include?(user.ability.id) && user.opposes?(target)
          score += 90
        end

        #Special cases
        if user.ability != user.original_ability  #Don't re-use the move
          score -= 180
        elsif user.ability.id == :NORMALIZE && user.pbHasType?(:GHOST)          #TODO: generalize this
          score += 90

        end
      end

      #---------------------------------------------------------------------------
    when MoveFunctions::NEGATE_TARGET_ABILITY # Gastro Acid
      if target.effects[PBEffects::Substitute]>0 ||
        target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill>=PBTrainerAI.highSkill
        score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TRANSFORM # Transform
      score -= 70
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_20 # Sonic Boom
      if target.hp<=20
        score += 80
      elsif target.level>=25
        score -= 60   # Not useful against high-level Pokemon
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_40 # Dragon Rage
      score += 80 if target.hp<=40
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_HALF_TARGET_HP # Super Fang, Nature's Madness
      score -= 50
      score += target.hp*100/target.totalhp
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_USER_LEVEL # Seismic Toss, Night Shade
      score += 80 if target.hp<=user.level
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_MATCH_USER_HP # Endeavor
      if user.hp>=target.hp
        score -= 90
      elsif user.hp<target.hp/2
        score += 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FIXED_DAMAGE_RANDOM_LEVEL # Psywave
      score += 30 if target.hp<=user.level
      #---------------------------------------------------------------------------
    when MoveFunctions::ONE_HIT_KO # Fissure, Sheer Cold, Guillotine, Horn Drill
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level>user.level
      #---------------------------------------------------------------------------
    when MoveFunctions::COUNTER_PHYSICAL # Counter
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack*1.5<spatk
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.physical?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::COUNTER_SPECIAL # Mirror Coat
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack>spatk*1.5
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.special?
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::COUNTER_LAST_DAMAGE # Metal Burst
      score -= 90 if target.effects[PBEffects::HyperBeam]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::DAMAGE_TARGET_ALLY # Flame Burst
      target.eachAlly do |b|
        next if !b.near?(target)
        score += 10
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_VS_DIVE # Surf
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_VS_DIG # Earthquake
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_VS_FLYING_GUST # Gust
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_VS_FLYING_TWISTER # Twister (also flinches)
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
          target.effects[PBEffects::Substitute]==0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_AFTER_FUSION_FLARE # Fusion Bolt
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_AFTER_FUSION_BOLT # Fusion Flare
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_POISONED # Venoshock
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_PARALYZED # Smelling Salts
      score -= 20 if target.status == :PARALYSIS   # Will cure status
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_ASLEEP # Wake-Up Slap
      score -= 20 if target.status == :SLEEP &&   # Will cure status
        target.statusCount > 1
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_USER_STATUS # Facade
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_TARGET_STATUS # Hex
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_TARGET_HALF_HP # Brine
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_USER_HIT # Revenge, Avalanche
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_TARGET_DAMAGED # Assurance
      score += 20 if @battle.pbOpposingBattlerCount(user)>1
      #---------------------------------------------------------------------------
    when MoveFunctions::ROUND # Round
      if skill>=PBTrainerAI.mediumSkill
        user.eachAlly do |b|
          next if !b.pbHasMove?(move.id)
          score += 20
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_TARGET_MOVED # Payback
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_ALLY_FAINTED # Retaliate
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_NO_ITEM # Acrobatics
      #---------------------------------------------------------------------------
    when MoveFunctions::WEATHER_BALL # Weather Ball
      #---------------------------------------------------------------------------
    when MoveFunctions::PURSUIT # Pursuit
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_HAPPINESS # Return
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_LOW_HAPPINESS # Frustration
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_USER_HP # Eruption, Water Spout
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_TARGET_HP # Crush Grip, Wring Out
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_SPEED_DIFF_SLOWER # Gyro Ball
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_USER_STAT_BOOSTS # Power Trip, Stored Power
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_TARGET_STAT_BOOSTS # Punishment
      #---------------------------------------------------------------------------
    when MoveFunctions::HIDDEN_POWER # Hidden Power
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_DOUBLES_CONSECUTIVE # Fury Cutter
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_CONSECUTIVE_TURNS # Echoed Voice
      #---------------------------------------------------------------------------
    when MoveFunctions::RAGE # Rage
      score += 25 if user.effects[PBEffects::Rage]
      #---------------------------------------------------------------------------
    when MoveFunctions::PRESENT # Present
      #---------------------------------------------------------------------------
    when MoveFunctions::MAGNITUDE # Magnitude
      #---------------------------------------------------------------------------
    when MoveFunctions::NATURAL_GIFT # Natural Gift
      score -= 90 if !user.item || !user.item.is_berry? || !user.itemActive?
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_LOW_PP # Trump Card
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_LOW_USER_HP # Flail, Reversal
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_SPEED_DIFF_FASTER # Electro Ball
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_TARGET_WEIGHT # Low Kick, Grass Knot
      #---------------------------------------------------------------------------
    when MoveFunctions::POWER_BY_WEIGHT_DIFF # Heat Crash, Heavy Slam
      #---------------------------------------------------------------------------
    when MoveFunctions::HELPING_HAND # Helping Hand
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        score += 30
        break
      end
      score -= 90 if !hasAlly
      #---------------------------------------------------------------------------
    when MoveFunctions::MUD_SPORT # Mud Sport
      score -= 90 if user.effects[PBEffects::MudSport]
      #---------------------------------------------------------------------------
    when MoveFunctions::WATER_SPORT # Water Sport
      score -= 90 if user.effects[PBEffects::WaterSport]
      #---------------------------------------------------------------------------
    when MoveFunctions::TYPE_BY_HELD_ITEM # Judgment, Multi-Attack, Techno Blast
      #---------------------------------------------------------------------------
    when MoveFunctions::ALWAYS_CRITICAL_HIT # Frost Breath, Storm Throw
      #---------------------------------------------------------------------------
    when MoveFunctions::LUCKY_CHANT # Lucky Chant
      score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::REFLECT # Reflect
      score -= 90 if user.pbOwnSide.effects[PBEffects::Reflect]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::LIGHT_SCREEN # Light Screen
      score -= 90 if user.pbOwnSide.effects[PBEffects::LightScreen]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::SECRET_POWER # Secret Power
      #---------------------------------------------------------------------------
    when MoveFunctions::ALWAYS_HITS # Swift, Aerial Ace, Aura Sphere, Shock Wave, Magical Leaf...
      #---------------------------------------------------------------------------
    when MoveFunctions::LOCK_ON # Lock-On, Mind Reader
      score -= 90 if target.effects[PBEffects::Substitute]>0
      score -= 90 if user.effects[PBEffects::LockOn]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::FORESIGHT # Foresight, Odor Sleuth
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::MIRACLE_EYE # Miracle Eye
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::IGNORE_DEFENSE_STAGES # Chip Away, Darkest Lariat, Sacred Sword
      #---------------------------------------------------------------------------
    when MoveFunctions::PROTECT # Protect, Detect
      if user.effects[PBEffects::ProtectRate]>1 ||
        target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::QUICK_GUARD # Quick Guard
      #---------------------------------------------------------------------------
    when MoveFunctions::WIDE_GUARD # Wide Guard
      #---------------------------------------------------------------------------
    when MoveFunctions::FEINT # Feint
      #---------------------------------------------------------------------------
    when MoveFunctions::MIRROR_MOVE # Mirror Move
      score -= 40
      if skill>=PBTrainerAI.highSkill
        score -= 100 if !target.lastRegularMoveUsed ||
          !GameData::Move.get(target.lastRegularMoveUsed).flags[/e/]   # Not copyable by Mirror Move
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::COPYCAT # Copycat
      #---------------------------------------------------------------------------
    when MoveFunctions::ME_FIRST # Me First
      #---------------------------------------------------------------------------
    when MoveFunctions::MAGIC_COAT # Magic Coat
      #---------------------------------------------------------------------------
    when MoveFunctions::SNATCH # Snatch
      #---------------------------------------------------------------------------
    when MoveFunctions::NATURE_POWER # Nature Power
      #---------------------------------------------------------------------------
    when MoveFunctions::RANDOM_MOVE_WHILE_ASLEEP # Sleep Talk
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score = 0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::ASSIST # Assist
      #---------------------------------------------------------------------------
    when MoveFunctions::METRONOME # Metronome
      #---------------------------------------------------------------------------
    when MoveFunctions::TORMENT # Torment
      score -= 90 if target.effects[PBEffects::Torment]
      #---------------------------------------------------------------------------
    when MoveFunctions::IMPRISON # Imprison
      score -= 90 if user.effects[PBEffects::Imprison]
      #---------------------------------------------------------------------------
    when MoveFunctions::DISABLE # Disable
      score -= 90 if target.effects[PBEffects::Disable]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::TAUNT # Taunt
      score -= 90 if target.effects[PBEffects::Taunt]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_BLOCK # Heal Block
      score -= 90 if target.effects[PBEffects::HealBlock]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::ENCORE # Encore
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if target.effects[PBEffects::Encore]>0
        score -= 90
      elsif aspeed>ospeed
        if !target.lastRegularMoveUsed
          score -= 90
        else
          moveData = GameData::Move.get(target.lastRegularMoveUsed)
          if moveData.category == 2 &&   # Status move
            [:User, :BothSides].include?(moveData.target)
            score += 60
          elsif moveData.category != 2 &&   # Damaging move
            moveData.target == :NearOther &&
            Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
            score += 60
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HIT_TWICE # Double Kick, Dual Chop, Bonemerang, Double Hit, Gear Grind
      #---------------------------------------------------------------------------
    when MoveFunctions::HIT_THREE_TIMES_POWER_UP # Triple Kick
      #---------------------------------------------------------------------------
    when MoveFunctions::HIT_2_TO_5_TIMES # Fury Attack, Bullet Seed, Rock Blast, Icicle Spear, Pin Missile...
      #---------------------------------------------------------------------------
    when MoveFunctions::BEAT_UP # Beat Up
      #---------------------------------------------------------------------------
    when MoveFunctions::RECHARGE_NEXT_TURN # Hyper Beam, Giga Impact, Blast Burn, Frenzy Plant, Hydro Cannon...
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_RAZOR_WIND # Razor Wind
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_SOLAR_BEAM # Solar Beam, Solar Blade
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_SKY_ATTACK # Sky Attack
      score += 20 if user.effects[PBEffects::FocusEnergy]>0
      if skill>=PBTrainerAI.highSkill
        score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
          target.effects[PBEffects::Substitute]==0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_FLY # Fly
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_DIG # Dig
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_DIVE # Dive
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_BOUNCE # Bounce
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_SHADOW_FORCE # Shadow Force
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_SKY_DROP # Sky Drop
      #---------------------------------------------------------------------------
    when MoveFunctions::TRAP_TARGET # Bind, Wrap, Clamp, Fire Spin, Magma Storm, Sand Tomb, Infestation
      score += 40 if target.effects[PBEffects::Trapping]==0
      #---------------------------------------------------------------------------
    when MoveFunctions::TRAP_TARGET_WHIRLPOOL # Whirlpool
      score += 40 if target.effects[PBEffects::Trapping]==0
      #---------------------------------------------------------------------------
    when MoveFunctions::UPROAR # Uproar
      #---------------------------------------------------------------------------
    when MoveFunctions::RAMPAGE_THEN_CONFUSE # Outrage, Petal Dance, Thrash
      #---------------------------------------------------------------------------
    when MoveFunctions::ROLLOUT # Rollout, Ice Ball
      #---------------------------------------------------------------------------
    when MoveFunctions::BIDE # Bide
      if user.hp<=user.totalhp/4
        score -= 90
      elsif user.hp<=user.totalhp/2
        score -= 50
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_USER_HALF, MoveFunctions::HEAL_USER_HALF_ROOST # Recover, Slack Off, Soft-Boiled, Milk Drink, Heal Order / Roost
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WISH # Wish
      score -= 90 if @battle.positions[user.index].effects[PBEffects::Wish]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_USER_BY_WEATHER # Moonlight, Morning Sun, Synthesis
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        case @battle.pbWeather
        when :Sun, :HarshSun
          score += 30
        when :None
        else
          score -= 30
        end
        score += 50
        score -= user.hp*100/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::REST # Rest
      if user.hp==user.totalhp || !user.pbCanSleep?(user,false,nil,true)
        score -= 90
      else
        score += 70
        score -= user.hp*140/user.totalhp
        score += 30 if user.status != :NONE
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AQUA_RING # Aqua Ring
      score -= 90 if user.effects[PBEffects::AquaRing]
      #---------------------------------------------------------------------------
    when MoveFunctions::INGRAIN # Ingrain
      score -= 90 if user.effects[PBEffects::Ingrain]
      #---------------------------------------------------------------------------
    when MoveFunctions::LEECH_SEED # Leech Seed
      if target.effects[PBEffects::LeechSeed]>=0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill && target.pbHasType?(:GRASS)
        score -= 90
      else
        score += 60 if user.turnCount==0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DRAIN_HALF_DAMAGE # Absorb, Giga Drain, Drain Punch, Horn Leech, Leech Life...
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DREAM_EATER # Dream Eater
      if !target.asleep?
        score -= 100
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_TARGET_HALF # Heal Pulse
      if user.opposes?(target)
        score -= 100
      else
        score += 60 if target.hp<target.totalhp/2 && target.effects[PBEffects::Substitute]==0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_FAINTS_EXPLODE # Explosion, Self-Destruct
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= user.hp*100/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FINAL_GAMBIT # Final Gambit
      #---------------------------------------------------------------------------
    when MoveFunctions::MEMENTO # Memento
      if !target.pbCanLowerStatStage?(:ATTACK,user) &&
        !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 100
      else
        score += target.stages[:ATTACK]*10
        score += target.stages[:SPECIAL_ATTACK]*10
        score -= user.hp*100/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HEALING_WISH, MoveFunctions::LUNAR_DANCE # Healing Wish / Lunar Dance
      score -= 70
      #---------------------------------------------------------------------------
    when MoveFunctions::PERISH_SONG # Perish Song
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 90
      else
        score -= 90 if target.effects[PBEffects::PerishSong]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::GRUDGE # Grudge
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
      #---------------------------------------------------------------------------
    when MoveFunctions::DESTINY_BOND # Destiny Bond
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
      #---------------------------------------------------------------------------
    when MoveFunctions::ENDURE # Endure
      score -= 25 if user.hp>user.totalhp/2
      if skill>=PBTrainerAI.mediumSkill
        score -= 90 if user.effects[PBEffects::ProtectRate]>1
        score -= 90 if target.effects[PBEffects::HyperBeam]>0
      else
        score -= user.effects[PBEffects::ProtectRate]*40
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::NON_LETHAL_HIT # False Swipe, Hold Back
      if target.hp==1
        score -= 90
      elsif target.hp<=target.totalhp/8
        score -= 60
      elsif target.hp<=target.totalhp/4
        score -= 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TELEPORT # Teleport
      score -= 100 if @battle.trainerBattle?
      #---------------------------------------------------------------------------
    when MoveFunctions::FORCE_SWITCH_STATUS # Roar, Whirlwind
      if target.effects[PBEffects::Ingrain] ||
        (skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score -= 90
      else
        ch = 0
        @battle.pbParty(target.index).each_with_index do |pkmn,i|
          ch += 1 if @battle.pbCanSwitchLax?(target.index,i)
        end
        score -= 90 if ch==0
      end
      if score>20
        score += 50 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FORCE_SWITCH_DAMAGE # Dragon Tail, Circle Throw
      if !target.effects[PBEffects::Ingrain] &&
        !(skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BATON_PASS # Baton Pass
      if !@battle.pbCanChooseNonActive?(user.index)
        score -= 80
      else
        score -= 40 if user.effects[PBEffects::Confusion]>0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total<=0 || user.turnCount==0
          score -= 60
        else
          score += total*10
          # special case: user has no damaging moves
          hasDamagingMove = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingMove = true
            break
          end
          score += 75 if !hasDamagingMove
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWITCH_OUT_AFTER_HIT # U-turn, Volt Switch
      #---------------------------------------------------------------------------
    when MoveFunctions::PREVENT_ESCAPE # Mean Look, Block, Spider Web, Anchor Shot, Spirit Shackle...
      score -= 90 if target.effects[PBEffects::MeanLook]>=0
      #---------------------------------------------------------------------------
    when MoveFunctions::KNOCK_OFF # Knock Off
      if skill>=PBTrainerAI.highSkill
        score += 20 if target.item
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::STEAL_ITEM # Thief, Covet
      if skill>=PBTrainerAI.highSkill
        if !user.item && target.item
          score += 40
        else
          score -= 90
        end
      else
        score -= 80
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SWAP_ITEMS # Trick, Switcheroo
      if !user.item && !target.item
        score -= 90
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                 :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
        score += 50
      elsif !user.item && target.item
        score -= 30 if user.lastMoveUsed &&
          GameData::Move.get(user.lastMoveUsed).function_code == MoveFunctions::SWAP_ITEMS   # Trick/Switcheroo
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BESTOW # Bestow
      if !user.item || target.item
        score -= 90
      else
        if user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
          score += 50
        else
          score -= 80
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::EAT_TARGET_BERRY, MoveFunctions::DESTROY_TARGET_BERRY # Bug Bite, Pluck / Incinerate
      if target.effects[PBEffects::Substitute]==0
        if skill>=PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RECYCLE # Recycle
      if !user.recycleItem || user.item
        score -= 80
      elsif user.recycleItem
        score += 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FLING # Fling
      if !user.item || !user.itemActive? ||
        user.unlosableItem?(user.item) || user.item.is_poke_ball?
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::EMBARGO # Embargo
      score -= 90 if target.effects[PBEffects::Embargo]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::MAGIC_ROOM # Magic Room
      if @battle.field.effects[PBEffects::MagicRoom]>0
        score -= 90
      else
        score += 30 if !user.item && target.item
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RECOIL_QUARTER # Take Down, Submission, Wild Charge, Head Charge
      score -= 25
      #---------------------------------------------------------------------------
    when MoveFunctions::RECOIL_THIRD # Double-Edge, Brave Bird, Wood Hammer
      score -= 30
      #---------------------------------------------------------------------------
    when MoveFunctions::RECOIL_HALF # Head Smash, Light of Ruin
      score -= 40
      #---------------------------------------------------------------------------
    when MoveFunctions::RECOIL_THIRD_PARALYZE # Volt Tackle
      score -= 30
      if target.pbCanParalyze?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RECOIL_THIRD_BURN # Flare Blitz
      score -= 30
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WEATHER_SUN # Sunny Day
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
        @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Sun
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :FIRE
          score += 20
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WEATHER_RAIN # Rain Dance
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
        @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Rain
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :WATER
          score += 20
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WEATHER_SANDSTORM # Sandstorm
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
        @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Sandstorm
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WEATHER_HAIL # Hail
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
        @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Hail
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HAZARD_SPIKES # Spikes
      if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [40,26,13][user.pbOpposingSide.effects[PBEffects::Spikes]]
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HAZARD_TOXIC_SPIKES # Toxic Spikes
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 8*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [26,13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HAZARD_STEALTH_ROCK # Stealth Rock
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::PLEDGE_GRASS # Grass Pledge
      #---------------------------------------------------------------------------
    when MoveFunctions::PLEDGE_FIRE # Fire Pledge
      #---------------------------------------------------------------------------
    when MoveFunctions::PLEDGE_WATER # Water Pledge
      #---------------------------------------------------------------------------
    when MoveFunctions::PAY_DAY # Pay Day
      #---------------------------------------------------------------------------
    when MoveFunctions::BREAK_SCREENS # Brick Break, Psychic Fangs
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::CRASH_DAMAGE_ON_MISS # Jump Kick, High Jump Kick
      score += 10*(user.stages[:ACCURACY]-target.stages[:EVASION])
      #---------------------------------------------------------------------------
    when MoveFunctions::SUBSTITUTE # Substitute
      if user.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp<=user.totalhp/4
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CURSE # Curse
      if user.pbHasType?(:GHOST)
        if target.effects[PBEffects::Curse]
          score -= 90
        elsif user.hp<=user.totalhp/2
          if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
            score -= 90
          else
            score -= 50
            score -= 30 if @battle.switchStyle
          end
        end
      else
        avg  = user.stages[:SPEED]*10
        avg -= user.stages[:ATTACK]*10
        avg -= user.stages[:DEFENSE]*10
        score += avg/3
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SPITE # Spite
      score -= 40
      #---------------------------------------------------------------------------
    when MoveFunctions::NIGHTMARE # Nightmare
      if target.effects[PBEffects::Nightmare] ||
        target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif !target.asleep?
        score -= 90
      else
        score -= 90 if target.statusCount<=1
        score += 50 if target.statusCount>3
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::RAPID_SPIN # Rapid Spin
      score += 30 if user.effects[PBEffects::Trapping]>0
      score += 30 if user.effects[PBEffects::LeechSeed]>=0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DELAYED_ATTACK # Future Sight, Doom Desire
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::STOCKPILE # Stockpile
      avg = 0
      avg -= user.stages[:DEFENSE]*10
      avg -= user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
      if user.effects[PBEffects::Stockpile]>=3
        score -= 80
      else
        # More preferable if user also has Spit Up/Swallow
        score += 20 if user.pbHasMoveFunction?(MoveFunctions::SPIT_UP,MoveFunctions::SWALLOW)   # Spit Up, Swallow
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SPIT_UP # Spit Up
      score -= 100 if user.effects[PBEffects::Stockpile]==0
      #---------------------------------------------------------------------------
    when MoveFunctions::SWALLOW # Swallow
      if user.effects[PBEffects::Stockpile]==0
        score -= 90
      elsif user.hp==user.totalhp
        score -= 90
      else
        mult = [0,25,50,100][user.effects[PBEffects::Stockpile]]
        score += mult
        score -= user.hp*mult*2/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FAILS_IF_USER_HIT # Focus Punch
      score += 50 if target.effects[PBEffects::HyperBeam]>0
      score -= 35 if target.hp<=target.totalhp/2   # If target is weak, no
      score -= 70 if target.hp<=target.totalhp/4   # need to risk this move
      #---------------------------------------------------------------------------
    when MoveFunctions::FAILS_IF_TARGET_NOT_ATTACKING # Sucker Punch
      #---------------------------------------------------------------------------
    when MoveFunctions::REDIRECT_ATTACKS_TO_USER # Follow Me, Rage Powder
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
      #---------------------------------------------------------------------------
    when MoveFunctions::GRAVITY # Gravity
      if @battle.field.effects[PBEffects::Gravity]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        score -= 30
        score -= 20 if user.effects[PBEffects::SkyDrop]>=0
        score -= 20 if user.effects[PBEffects::MagnetRise]>0
        score -= 20 if user.effects[PBEffects::Telekinesis]>0
        score -= 20 if user.pbHasType?(:FLYING)
        score -= 20 if user.hasActiveAbility?(:LEVITATE)
        score -= 20 if user.hasActiveItem?(:AIRBALLOON)
        score += 20 if target.effects[PBEffects::SkyDrop]>=0
        score += 20 if target.effects[PBEffects::MagnetRise]>0
        score += 20 if target.effects[PBEffects::Telekinesis]>0
        score += 20 if target.inTwoTurnAttack?(MoveFunctions::TWO_TURN_FLY,MoveFunctions::TWO_TURN_BOUNCE,MoveFunctions::TWO_TURN_SKY_DROP)   # Fly, Bounce, Sky Drop
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::MAGNET_RISE # Magnet Rise
      if user.effects[PBEffects::MagnetRise]>0 ||
        user.effects[PBEffects::Ingrain] ||
        user.effects[PBEffects::SmackDown]
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TELEKINESIS # Telekinesis
      if target.effects[PBEffects::Telekinesis]>0 ||
        target.effects[PBEffects::Ingrain] ||
        target.effects[PBEffects::SmackDown]
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HITS_FLYING_TARGETS # Sky Uppercut
      #---------------------------------------------------------------------------
    when MoveFunctions::GROUND_TARGET # Smack Down, Thousand Arrows
      if skill>=PBTrainerAI.mediumSkill
        score += 20 if target.effects[PBEffects::MagnetRise]>0
        score += 20 if target.effects[PBEffects::Telekinesis]>0
        score += 20 if target.inTwoTurnAttack?(MoveFunctions::TWO_TURN_FLY,MoveFunctions::TWO_TURN_BOUNCE)   # Fly, Bounce
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AFTER_YOU # After You
      #---------------------------------------------------------------------------
    when MoveFunctions::QUASH # Quash
      #---------------------------------------------------------------------------
    when MoveFunctions::TRICK_ROOM # Trick Room
      #---------------------------------------------------------------------------
    when MoveFunctions::ALLY_SWITCH # Ally Switch
      #---------------------------------------------------------------------------
    when MoveFunctions::USE_TARGET_ATTACK # Foul Play
      #---------------------------------------------------------------------------
    when MoveFunctions::USE_TARGET_DEFENSE # Psyshock, Psystrike, Secret Sword
      #---------------------------------------------------------------------------
    when MoveFunctions::DAMAGE_SAME_TYPE_ONLY # Synchronoise
      if !target.pbHasType?(user.type1) &&
        !target.pbHasType?(user.type2)
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::WONDER_ROOM # Wonder Room
      #---------------------------------------------------------------------------
    when MoveFunctions::LAST_RESORT # Last Resort
      #---------------------------------------------------------------------------
    when "126" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      #---------------------------------------------------------------------------
    when "127" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if target.pbCanParalyze?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      end
      #---------------------------------------------------------------------------
    when "128" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
      #---------------------------------------------------------------------------
    when "129" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
      #---------------------------------------------------------------------------
    when "12A" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90
        end
      end
      #---------------------------------------------------------------------------
    when "12B" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if !target.pbCanLowerStatStage?(:DEFENSE,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:DEFENSE]*20
      end
      #---------------------------------------------------------------------------
    when "12C" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if !target.pbCanLowerStatStage?(:EVASION,user)
        score -= 90
      else
        score += target.stages[:EVASION]*15
      end
      #---------------------------------------------------------------------------
    when "12D" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      #---------------------------------------------------------------------------
    when "12E" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp>=target.totalhp/2
      score -= 20 if user.hp<user.hp/2
      #---------------------------------------------------------------------------
    when "12F" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      score -= 110 if target.effects[PBEffects::MeanLook]>=0
      #---------------------------------------------------------------------------
    when "130" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      score -= 40
      #---------------------------------------------------------------------------
    when "131" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
        @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :ShadowSky
        score -= 90
      end
      #---------------------------------------------------------------------------
    when "132" # Shadow move (no constant defined)
      score += 20   # Shadow moves are more preferable
      if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
        target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
        target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
        target.pbOwnSide.effects[PBEffects::Safeguard]>0
        score += 30
        score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
          user.pbOwnSide.effects[PBEffects::Reflect]>0 ||
          user.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
          user.pbOwnSide.effects[PBEffects::Safeguard]>0
      else
        score -= 110
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HOLD_HANDS, MoveFunctions::CELEBRATE # Hold Hands / Celebrate
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
      #---------------------------------------------------------------------------
    when MoveFunctions::FREEZE_SUPER_EFFECTIVE_WATER # Freeze-Dry
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEFENSE_UP_2_DIAMOND_STORM # Diamond Storm
      score += 20 if user.stages[:DEFENSE]<0
      #---------------------------------------------------------------------------
    when MoveFunctions::MAGNETIC_FLUX # Magnetic Flux
      hasEffect = user.statStageAtMax?(:DEFENSE) &&
        user.statStageAtMax?(:SPECIAL_DEFENSE)
      user.eachAlly do |b|
        next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
        hasEffect = true
        score -= b.stages[:DEFENSE]*10
        score -= b.stages[:SPECIAL_DEFENSE]*10
      end
      if hasEffect
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      else
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::AROMATIC_MIST # Aromatic Mist
      if target.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= target.stages[:SPECIAL_DEFENSE]*10
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATTACK_DOWN_1_NEVER_MISS # Play Nice
      if !target.pbCanLowerStatStage?(:ATTACK,user)
        score -= 90
      else
        score += target.stages[:ATTACK]*20
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_ATK_SP_ATK_DOWN_1 # Noble Roar, Tearful Look
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
      #---------------------------------------------------------------------------
    when MoveFunctions::HYPERSPACE_FURY # Hyperspace Fury
      if !user.isSpecies?(:HOOPA) || user.form!=1
        score -= 100
      else
        score += 20 if target.stages[:DEFENSE]>0
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_ATK_DOWN_1_NEVER_MISS # Confide
      score += 20 if target.stages[:SPECIAL_ATTACK]>0
      #---------------------------------------------------------------------------
    when MoveFunctions::TARGET_SP_ATK_DOWN_2_PLAIN # Eerie Impulse
      if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:SPECIAL_ATTACK]*20
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::ROTOTILLER # Rototiller
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.airborne? &&
          (!b.statStageAtMax?(:ATTACK) || !b.statStageAtMax?(:SPECIAL_ATTACK))
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:ATTACK]*10
            score -= user.stages[:SPECIAL_ATTACK]*10
          end
        end
      end
      score -= 95 if count==0
      #---------------------------------------------------------------------------
    when MoveFunctions::FLOWER_SHIELD # Flower Shield
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:DEFENSE]*10
          end
        end
      end
      score -= 95 if count==0
      #---------------------------------------------------------------------------
    when MoveFunctions::VENOM_DRENCH # Venom Drench
      count=0
      @battle.eachBattler do |b|
        if b.poisoned? &&
          (!b.statStageAtMin?(:ATTACK) ||
            !b.statStageAtMin?(:SPECIAL_ATTACK) ||
            !b.statStageAtMin?(:SPEED))
          count += 1
          if user.opposes?(b)
            score += user.stages[:ATTACK]*10
            score += user.stages[:SPECIAL_ATTACK]*10
            score += user.stages[:SPEED]*10
          else
            score -= 20
          end
        end
      end
      score -= 95 if count==0
      #---------------------------------------------------------------------------
    when MoveFunctions::TOPSY_TURVY # Topsy-Turvy
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        numpos = 0; numneg = 0
        GameData::Stat.each_battle do |s|
          numpos += target.stages[s.id] if target.stages[s.id] > 0
          numneg += target.stages[s.id] if target.stages[s.id] < 0
        end
        if numpos!=0 || numneg!=0
          score += (numpos-numneg)*10
        else
          score -= 95
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::ADD_GHOST_TYPE # Trick-or-Treat
      score -= 90 if target.pbHasType?(:GHOST)
      #---------------------------------------------------------------------------
    when MoveFunctions::ADD_GRASS_TYPE # Forest's Curse
      score -= 90 if target.pbHasType?(:GRASS)
      #---------------------------------------------------------------------------
    when MoveFunctions::FLYING_PRESS # Flying Press
      #---------------------------------------------------------------------------
    when MoveFunctions::ELECTRIFY # Electrify
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      score -= 90 if aspeed>ospeed
      #---------------------------------------------------------------------------
    when MoveFunctions::ION_DELUGE # Ion Deluge, Plasma Fists
      #---------------------------------------------------------------------------
    when MoveFunctions::HYPERSPACE_HOLE # Hyperspace Hole
      #---------------------------------------------------------------------------
    when MoveFunctions::POWDER # Powder
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if aspeed>ospeed
        score -= 90
      else
        score += 30 if target.pbHasMoveType?(:FIRE)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::MAT_BLOCK # Mat Block
      if user.turnCount==0
        score += 30
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::CRAFTY_SHIELD # Crafty Shield
      #---------------------------------------------------------------------------
    when MoveFunctions::KINGS_SHIELD, MoveFunctions::SPIKY_SHIELD # King's Shield / Spiky Shield
      if user.effects[PBEffects::ProtectRate]>1 ||
        target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::TWO_TURN_PHANTOM_FORCE # Phantom Force
      #---------------------------------------------------------------------------
    when MoveFunctions::GEOMANCY # Geomancy
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
        user.statStageAtMax?(:SPECIAL_DEFENSE) &&
        user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK]*10   # Only *10 instead of *20
        score -= user.stages[:SPECIAL_DEFENSE]*10   # because two-turn attack
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecialAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecialAttack = true
            break
          end
          if hasSpecialAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 30 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DRAIN_THREE_QUARTERS_DAMAGE # Draining Kiss, Oblivion Wing
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 80
      else
        score += 40 if user.hp<=user.totalhp/2
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::FELL_STINGER # Fell Stinger
      score += 20 if !user.statStageAtMax?(:ATTACK) && target.hp<=target.totalhp/4
      #---------------------------------------------------------------------------
    when MoveFunctions::PARTING_SHOT # Parting Shot
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
      #---------------------------------------------------------------------------
    when MoveFunctions::FAIRY_LOCK # Fairy Lock
      #---------------------------------------------------------------------------
    when MoveFunctions::HAZARD_STICKY_WEB # Sticky Web
      score -= 95 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
      #---------------------------------------------------------------------------
    when MoveFunctions::TERRAIN_ELECTRIC # Electric Terrain
      #---------------------------------------------------------------------------
    when MoveFunctions::TERRAIN_GRASSY # Grassy Terrain
      #---------------------------------------------------------------------------
    when MoveFunctions::TERRAIN_MISTY # Misty Terrain
      #---------------------------------------------------------------------------
    when MoveFunctions::HAPPY_HOUR # Happy Hour
      score -= 90
      #---------------------------------------------------------------------------
    when MoveFunctions::BELCH # Belch
      score -= 90 if !user.belched?
      #---------------------------------------------------------------------------
    when MoveFunctions::TOXIC_THREAD # Toxic Thread
      if !target.pbCanPoison?(user,false) && !target.pbCanLowerStatStage?(:SPEED,user)
        score -= 90
      else
        if target.pbCanPoison?(user,false)
          score += 30
          if skill>=PBTrainerAI.mediumSkill
            score += 30 if target.hp<=target.totalhp/4
            score += 50 if target.hp<=target.totalhp/8
            score -= 40 if target.effects[PBEffects::Yawn]>0
          end
          if skill>=PBTrainerAI.highSkill
            score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
            score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
            score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
          end
        end
        if target.pbCanLowerStatStage?(:SPEED,user)
          score += target.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SPARKLING_ARIA # Sparkling Aria
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      else
        score += 40 if target.status == :BURN
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::PURIFY # Purify
      if target.status == :NONE
        score -= 90
      elsif user.hp==user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp-user.hp)*50/user.totalhp
        score -= 30 if target.opposes?(user)
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::GEAR_UP # Gear Up
      hasEffect = user.statStageAtMax?(:ATTACK) &&
        user.statStageAtMax?(:SPECIAL_ATTACK)
      user.eachAlly do |b|
        next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
        hasEffect = true
        score -= b.stages[:ATTACK]*10
        score -= b.stages[:SPECIAL_ATTACK]*10
      end
      if hasEffect
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPECIAL_ATTACK]*10
      else
        score -= 90
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SPECTRAL_THIEF # Spectral Thief
      numStages = 0
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        numStages += target.stages[s.id]
      end
      score += numStages*20
      #---------------------------------------------------------------------------
    when MoveFunctions::LASER_FOCUS # Laser Focus
      if user.effects[PBEffects::LaserFocus]>0
        score -= 90
      else
        score += 40
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::USER_DEFENSE_DOWN_1 # Clanging Scales
      score += user.stages[:DEFENSE]*10
      #---------------------------------------------------------------------------
    when MoveFunctions::STRENGTH_SAP # Strength Sap
      if target.statStageAtMin?(:ATTACK)
        score -= 90
      else
        if target.pbCanLowerStatStage?(:ATTACK,user)
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
        score += (user.totalhp-user.hp)*50/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SPEED_SWAP # Speed Swap
      if skill>=PBTrainerAI.mediumSkill
        if user.speed>target.speed
          score += 50
        else
          score -= 70
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BURN_UP # Burn Up
      score -= 90 if !user.pbHasType?(:FIRE)
      #---------------------------------------------------------------------------
    when MoveFunctions::IGNORE_ABILITIES # Moongeist Beam, Sunsteel Strike
      #---------------------------------------------------------------------------
    when MoveFunctions::PHOTON_GEYSER # Photon Geyser
      #---------------------------------------------------------------------------
    when MoveFunctions::CORE_ENFORCER # Core Enforcer
      if skill>=PBTrainerAI.mediumSkill
        userSpeed   = pbRoughStat(user,:SPEED,skill)
        targetSpeed = pbRoughStat(target,:SPEED,skill)
        if userSpeed<targetSpeed
          score += 30
        end
      else
        score += 30
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::DOUBLE_POWER_IF_LAST_MOVE_FAILED # Stomping Tantrum
      #---------------------------------------------------------------------------
    when MoveFunctions::AURORA_VEIL # Aurora Veil
      if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || @battle.pbWeather != :Hail
        score -= 90
      else
        score += 40
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BANEFUL_BUNKER # Baneful Bunker
      if user.effects[PBEffects::ProtectRate]>1 ||
        target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
        score += 20   # Because of possible poisoning
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::REVELATION_DANCE # Revelation Dance
      #---------------------------------------------------------------------------
    when MoveFunctions::SPOTLIGHT # Spotlight
      hasAlly = false
      target.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
      #---------------------------------------------------------------------------
    when MoveFunctions::INSTRUCT # Instruct
      if skill>=PBTrainerAI.mediumSkill
        if !target.lastRegularMoveUsed ||
          !target.pbHasMove?(target.lastRegularMoveUsed) ||
          target.usingMultiTurnAttack?
          score -= 90
        else
          # Without lots of code here to determine good/bad moves and relative
          # speeds, using this move is likely to just be a waste of a turn
          score -= 50
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::THROAT_CHOP # Throat Chop
      if target.effects[PBEffects::ThroatChop]==0 && skill>=PBTrainerAI.highSkill
        hasSoundMove = false
        user.eachMove do |m|
          next if !m.soundMove?
          hasSoundMove = true
          break
        end
        score += 40 if hasSoundMove
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_USER_HALF_SANDSTORM_BOOST # Shore Up
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        score += 30 if @battle.pbWeather == :Sandstorm
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::HEAL_TARGET_HALF_GRASSY_BOOST # Floral Healing
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if @battle.field.terrain == :Grassy
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::POLLEN_PUFF # Pollen Puff
      if !target.opposes?(user)
        if target.hp==target.totalhp || (skill>=PBTrainerAI.mediumSkill && !target.canHeal?)
          score -= 90
        else
          score += 50
          score -= target.hp*100/target.totalhp
        end
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::MIND_BLOWN # Mind Blown
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= (user.totalhp-user.hp)*75/user.totalhp
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::SHELL_TRAP # Shell Trap
      if skill>=PBTrainerAI.mediumSkill
        hasPhysicalAttack = false
        target.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score -= 80 if !hasPhysicalAttack
      end
      #---------------------------------------------------------------------------
    when MoveFunctions::BEAK_BLAST # Beak Blast
      score += 20   # Because of possible burning
      #---------------------------------------------------------------------------
    when MoveFunctions::TERRAIN_PSYCHIC # Psychic Terrain
      #---------------------------------------------------------------------------
    when MoveFunctions::FAILS_AFTER_FIRST_TURN # First Impression
      score -= 90 if user.turnCount > 0
      #---------------------------------------------------------------------------
    when MoveFunctions::HIT_TWICE_FLINCH # Double Iron Bash
      score += 30 if target.effects[PBEffects::Minimize]
      #---------------------------------------------------------------------------
    end

    if @battle.favored_moves.include?(move.id)
      score+= 90
      score += 50 if score <= 100
    end
    return score
  end
end