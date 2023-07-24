
module BattleHandlers
  #
  #   Speed calculation
  #

  def self.triggerSpeedCalcAbility(ability, battler, mult)
    ability1 = ability
    ability2 = battler.ability2
    mult = SpeedCalcAbility.trigger(ability1, battler, mult) || mult
    if $game_switches[SWITCH_DOUBLE_ABILITIES]
      mult = SpeedCalcAbility.trigger(ability2, battler, mult) || mult
    end
    return mult
  end

  def self.triggerWeightCalcAbility(ability,battler,w)
    ability1 = ability
    ability2 = battler.ability2
    ret = WeightCalcAbility.trigger(ability1,battler,w) || WeightCalcAbility.trigger(ability2,battler,w)
    return (ret!=nil) ? ret : w
  end




  def self.triggerEOREffectAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2

    EOREffectAbility.trigger(ability1,battler,battle)
    EOREffectAbility.trigger(ability2,battler,battle)
  end

  def self.triggerEORGainItemAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2

    EORGainItemAbility.trigger(ability1,battler,battle)
    EORGainItemAbility.trigger(ability2,battler,battle)
  end

  def self.triggerCertainSwitchingUserAbility(ability,switcher,battle)
    ability1 = ability
    ability2 = switcher.ability2

    ret = CertainSwitchingUserAbility.trigger(ability1,switcher,battle) ||  CertainSwitchingUserAbility.trigger(ability2,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerCertainSwitchingUserAbility(ability,switcher,battle)
    ability1 = ability
    ability2 = switcher.ability2

    ret = CertainSwitchingUserAbility.trigger(ability1,switcher,battle) || CertainSwitchingUserAbility.trigger(ability2,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerTrappingTargetAbility(ability,switcher,bearer,battle)
    ability1 = ability
    ability2 = switcher.ability2
    ret = TrappingTargetAbility.trigger(ability1,switcher,bearer,battle) || TrappingTargetAbility.trigger(ability2,switcher,bearer,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnSwitchIn(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnSwitchIn.trigger(ability1,battler,battle)
    AbilityOnSwitchIn.trigger(ability2,battler,battle)
  end

  def self.triggerAbilityOnSwitchOut(ability,battler,endOfBattle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnSwitchOut.trigger(ability1,battler,endOfBattle)
    AbilityOnSwitchOut.trigger(ability2,battler,endOfBattle)
  end

  def self.triggerAbilityChangeOnBattlerFainting(ability,battler,fainted,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityChangeOnBattlerFainting.trigger(ability1,battler,fainted,battle)
    AbilityChangeOnBattlerFainting.trigger(ability2,battler,fainted,battle)

  end

  def self.triggerAbilityOnBattlerFainting(ability,battler,fainted,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnBattlerFainting.trigger(ability1,battler,fainted,battle)
    AbilityOnBattlerFainting.trigger(ability2,battler,fainted,battle)
  end


  def self.triggerRunFromBattleAbility(ability,battler)
    ability1 = ability
    ability2 = battler.ability2
    ret = RunFromBattleAbility.trigger(ability1,battler) || RunFromBattleAbility.trigger(ability2,battler)
    return (ret!=nil) ? ret : false
  end
  ########
  # FROM HERE
  #

  def self.triggerAbilityOnHPDroppedBelowHalf(ability,user,battle)
    ability1 = ability
    ability2 = user.ability2
    ret = AbilityOnHPDroppedBelowHalf.trigger(ability1,user,battle) || AbilityOnHPDroppedBelowHalf.trigger(ability2,user,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusCheckAbilityNonIgnorable(ability,battler,status)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatusCheckAbilityNonIgnorable.trigger(ability1,battler,status) || StatusCheckAbilityNonIgnorable.trigger(ability2,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAbility(ability,battler,status)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatusImmunityAbility.trigger(ability1,battler,status) || StatusImmunityAbility.trigger(ability2,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAbilityNonIgnorable(ability,battler,status)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatusImmunityAbilityNonIgnorable.trigger(ability1,battler,status) || StatusImmunityAbilityNonIgnorable.trigger(ability2,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatusImmunityAllyAbility(ability,battler,status)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatusImmunityAllyAbility.trigger(ability1,battler,status) || StatusImmunityAllyAbility.trigger(ability2,battler,status)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnStatusInflicted(ability,battler,user,status)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnStatusInflicted.trigger(ability1,battler,user,status)
    AbilityOnStatusInflicted.trigger(ability2,battler,user,status)
  end

  def self.triggerStatusCureAbility(ability,battler)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatusCureAbility.trigger(ability1,battler) || StatusCureAbility.trigger(ability2,battler)
    return (ret!=nil) ? ret : false
  end


  def self.triggerStatLossImmunityAbility(ability,battler,stat,battle,showMessages)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatLossImmunityAbility.trigger(ability1,battler,stat,battle,showMessages) || StatLossImmunityAbility.trigger(ability2,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatLossImmunityAbilityNonIgnorable(ability,battler,stat,battle,showMessages)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatLossImmunityAbilityNonIgnorable.trigger(ability1,battler,stat,battle,showMessages) || StatLossImmunityAbilityNonIgnorable.trigger(ability2,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerStatLossImmunityAllyAbility(ability,bearer,battler,stat,battle,showMessages)
    ability1 = ability
    ability2 = battler.ability2
    ret = StatLossImmunityAllyAbility.trigger(ability1,bearer,battler,stat,battle,showMessages) || StatLossImmunityAllyAbility.trigger(ability2,bearer,battler,stat,battle,showMessages)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnStatGain(ability,battler,stat,user)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnStatGain.trigger(ability1,battler,stat,user)
    AbilityOnStatGain.trigger(ability2,battler,stat,user)
  end

  def self.triggerAbilityOnStatLoss(ability,battler,stat,user)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnStatLoss.trigger(ability1,battler,stat,user)
    AbilityOnStatLoss.trigger(ability2,battler,stat,user)
  end

  #=============================================================================


  def self.triggerPriorityChangeAbility(ability,battler,move,pri)
    ability1 = ability
    ability2 = battler.ability2
    ret = PriorityChangeAbility.trigger(ability1,battler,move,pri) || PriorityChangeAbility.trigger(ability2,battler,move,pri)
    return (ret!=nil) ? ret : pri
  end

  def self.triggerPriorityBracketChangeAbility(ability,battler,subPri,battle)
    ability1 = ability
    ability2 = battler.ability2
    ret = PriorityBracketChangeAbility.trigger(ability1,battler,subPri,battle) || PriorityBracketChangeAbility.trigger(ability2,battler,subPri,battle)
    return (ret!=nil) ? ret : subPri
  end

  def self.triggerPriorityBracketUseAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    PriorityBracketUseAbility.trigger(ability1,battler,battle)
    PriorityBracketUseAbility.trigger(ability2,battler,battle)
  end

  #=============================================================================

  def self.triggerAbilityOnFlinch(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnFlinch.trigger(ability1,battler,battle)
    AbilityOnFlinch.trigger(ability2,battler,battle)
  end

  def self.triggerMoveBlockingAbility(ability,bearer,user,targets,move,battle)
    ability1 = ability
    ability2 = bearer.ability2
    ret = MoveBlockingAbility.trigger(ability1,bearer,user,targets,move,battle) || MoveBlockingAbility.trigger(ability2,bearer,user,targets,move,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerMoveImmunityTargetAbility(ability,user,target,move,type,battle)
    ability1 = ability
    ability2 = user.ability2
    ret = MoveImmunityTargetAbility.trigger(ability1,user,target,move,type,battle) || MoveImmunityTargetAbility.trigger(ability2,user,target,move,type,battle)
    return (ret!=nil) ? ret : false
  end

  #=============================================================================

  def self.triggerMoveBaseTypeModifierAbility(ability,user,move,type)
    ability1 = ability
    ability2 = user.ability2
    ret = MoveBaseTypeModifierAbility.trigger(ability1,user,move,type) || MoveBaseTypeModifierAbility.trigger(ability2,user,move,type)
    return (ret!=nil) ? ret : type
  end

  #=============================================================================

  def self.triggerAccuracyCalcUserAbility(ability,mods,user,target,move,type)
    ability1 = ability
    ability2 = user.ability2
    AccuracyCalcUserAbility.trigger(ability1,mods,user,target,move,type)
    AccuracyCalcUserAbility.trigger(ability2,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcUserAllyAbility(ability,mods,user,target,move,type)
    ability1 = ability
    ability2 = user.ability2
    AccuracyCalcUserAllyAbility.trigger(ability1,mods,user,target,move,type)
    AccuracyCalcUserAllyAbility.trigger(ability2,mods,user,target,move,type)
  end

  def self.triggerAccuracyCalcTargetAbility(ability,mods,user,target,move,type)
    ability1 = ability
    ability2 = user.ability2
    AccuracyCalcTargetAbility.trigger(ability1,mods,user,target,move,type)
    AccuracyCalcTargetAbility.trigger(ability2,mods,user,target,move,type)
  end
  #=============================================================================

  def self.triggerDamageCalcUserAbility(ability,user,target,move,mults,baseDmg,type)
    ability1 = ability
    ability2 = user.ability2
    DamageCalcUserAbility.trigger(ability1,user,target,move,mults,baseDmg,type)
    DamageCalcUserAbility.trigger(ability2,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcUserAllyAbility(ability,user,target,move,mults,baseDmg,type)
    ability1 = ability
    ability2 = target.ability2
    DamageCalcUserAllyAbility.trigger(ability1,user,target,move,mults,baseDmg,type)
    DamageCalcUserAllyAbility.trigger(ability2,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAbility(ability,user,target,move,mults,baseDmg,type)
    ability1 = ability
    ability2 = target.ability2
    DamageCalcTargetAbility.trigger(ability1,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAbility.trigger(ability2,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAbilityNonIgnorable(ability,user,target,move,mults,baseDmg,type)
    ability1 = ability
    ability2 = target.ability2
    DamageCalcTargetAbilityNonIgnorable.trigger(ability1,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAbilityNonIgnorable.trigger(ability2,user,target,move,mults,baseDmg,type)
  end

  def self.triggerDamageCalcTargetAllyAbility(ability,user,target,move,mults,baseDmg,type)
    ability1 = ability
    ability2 = target.ability2
    DamageCalcTargetAllyAbility.trigger(ability1,user,target,move,mults,baseDmg,type)
    DamageCalcTargetAllyAbility.trigger(ability2,user,target,move,mults,baseDmg,type)
  end

  #=============================================================================

  def self.triggerCriticalCalcUserAbility(ability,user,target,c)
    ability1 = ability
    ability2 = user.ability2
    ret = CriticalCalcUserAbility.trigger(ability1,user,target,c) || CriticalCalcUserAbility.trigger(ability2,user,target,c)
    return (ret!=nil) ? ret : c
  end

  def self.triggerCriticalCalcTargetAbility(ability,user,target,c)
    ability1 = ability
    ability2 = target.ability2
    ret = CriticalCalcTargetAbility.trigger(ability1,user,target,c) || CriticalCalcTargetAbility.trigger(ability2,user,target,c)
    return (ret!=nil) ? ret : c
  end
  #=============================================================================

  def self.triggerTargetAbilityOnHit(ability,user,target,move,battle)
    ability1 = ability
    ability2 = target.ability2
    TargetAbilityOnHit.trigger(ability1,user,target,move,battle)
    TargetAbilityOnHit.trigger(ability2,user,target,move,battle)
  end

  def self.triggerUserAbilityOnHit(ability,user,target,move,battle)
    ability1 = ability
    ability2 = user.ability2
    UserAbilityOnHit.trigger(ability1,user,target,move,battle)
    UserAbilityOnHit.trigger(ability2,user,target,move,battle)
  end
  #=============================================================================

  def self.triggerUserAbilityEndOfMove(ability,user,targets,move,battle)
    ability1 = ability
    ability2 = user.ability2
    UserAbilityEndOfMove.trigger(ability1,user,targets,move,battle)
    UserAbilityEndOfMove.trigger(ability2,user,targets,move,battle)
  end

  def self.triggerTargetAbilityAfterMoveUse(ability,target,user,move,switched,battle)
    ability1 = ability
    ability2 = target.ability2
    TargetAbilityAfterMoveUse.trigger(ability1,target,user,move,switched,battle)
    TargetAbilityAfterMoveUse.trigger(ability2,target,user,move,switched,battle)
  end

  #=============================================================================

  def self.triggerEORWeatherAbility(ability,weather,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    EORWeatherAbility.trigger(ability1,weather,battler,battle)
    EORWeatherAbility.trigger(ability2,weather,battler,battle)
  end

  def self.triggerEORHealingAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    EORHealingAbility.trigger(ability1,battler,battle)
    EORHealingAbility.trigger(ability2,battler,battle)
  end

  def self.triggerEOREffectAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    EOREffectAbility.trigger(ability1,battler,battle)
    EOREffectAbility.trigger(ability2,battler,battle)
  end

  def self.triggerEORGainItemAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    EORGainItemAbility.trigger(ability1,battler,battle)
    EORGainItemAbility.trigger(ability2,battler,battle)
  end

end
