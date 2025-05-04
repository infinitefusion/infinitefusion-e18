#
# class AbilitySplashBar < SpriteWrapper
#   def refresh
#     self.bitmap.clear
#     return if !@battler
#     textPos = []
#     textX = (@side==0) ? 10 : self.bitmap.width-8
#     # Draw Pokémon's name
#     textPos.push([_INTL("{1}'s",@battler.name),textX,-4,@side==1,
#                   TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
#     # Draw Pokémon's ability
#     textPos.push([@battler.abilityName,textX,26,@side==1,
#                   TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
#     pbDrawTextPositions(self.bitmap,textPos)
#
#     #2nd ability
#     if $game_switches[SWITCH_DOUBLE_ABILITIES]
#       textPos.push([@battler.ability2Name,textX,26,@side==1,
#                     TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
#       pbDrawTextPositions(self.bitmap,textPos)
#     end
#   end
# end


class AbilitySplashDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar2 = addSprite(@sprites["ability2Bar_#{@side}"]) if @sprites["ability2Bar_#{@side}"]

    dir = (@side==0) ? -1 : 1
    bar.moveDelta(0,8,dir*Graphics.width/2,0)
    bar2.moveDelta(0,8,dir*Graphics.width/2,0) if bar2

    bar.setVisible(8,false)
    bar2.setVisible(8,false) if bar2
  end
end

class PokeBattle_Scene
  def pbShowAbilitySplash(battler,secondAbility=false, abilityName=nil)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    side = battler.index%2
    if secondAbility
      pbHideAbilitySplash(battler) if @sprites["ability2Bar_#{side}"].visible
    else
      pbHideAbilitySplash(battler) if @sprites["abilityBar_#{side}"].visible
    end
    if abilityName
      @sprites["abilityBar_#{side}"].ability_name = abilityName if !secondAbility
      @sprites["ability2Bar_#{side}"].ability_name = abilityName if secondAbility
    end


    @sprites["abilityBar_#{side}"].battler = battler
    @sprites["ability2Bar_#{side}"].battler = battler if @sprites["ability2Bar_#{side}"]

    abilitySplashAnim = AbilitySplashAppearAnimation.new(@sprites,@viewport,side,secondAbility)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end
end

class PokeBattle_Battle

  def pbShowSecondaryAbilitySplash(battler,delay=false,logTrigger=true)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler,true)
    if delay
      Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
    end
  end

  def pbShowPrimaryAbilitySplash(battler,delay=false,logTrigger=true)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler,false)
    if delay
      Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
    end
  end

end



class FusionSelectOptionsScene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)

    options = []
    if shouldSelectNickname
      options << EnumOption.new(_INTL("Nickname"), [_INTL(@pokemon1.name), _INTL(@pokemon2.name)],
                                proc { 0 },
                                proc { |value|
                                  if value ==0
                                    @nickname = @pokemon1.name
                                  else
                                    @nickname = @pokemon2.name
                                  end
                                }, "Select the Pokémon's nickname")
    end

    if @abilityList != nil
      options << EnumOption.new(_INTL("Ability"), [_INTL(getAbilityName(@abilityList[0])), _INTL(getAbilityName(@abilityList[1]))],
                                proc { 0 },
                                proc { |value|
                                  @selectedAbility=@abilityList[value]
                                }, [getAbilityDescription(@abilityList[0]), getAbilityDescription(@abilityList[1])]
      )
    end

    options << EnumOption.new(_INTL("Nature"), [_INTL(getNatureName(@natureList[0])), _INTL(getNatureName(@natureList[1]))],
                              proc { 0 },
                              proc { |value|
                                @selectedNature=@natureList[value]
                              }, [getNatureDescription(@natureList[0]), getNatureDescription(@natureList[1])]
    )
    return options
  end
end

