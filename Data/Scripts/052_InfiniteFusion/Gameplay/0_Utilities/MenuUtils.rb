def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!", $Trainer.name, badgeName))
end

def pbSpendMoney(amount,showMessage=false,msgwindow=nil, goldwindow=nil)
  pbReceiveMoney(0- amount,showMessage,msgwindow,goldwindow,)
end
def pbReceiveMoney(amount, showMessage=true, msgwindow=nil, goldwindow=nil)
  msgwindow  = pbCreateMessageWindow(nil)      unless msgwindow
  goldwindow = pbDisplayGoldWindow(msgwindow)  unless goldwindow

  if showMessage
    if amount >= 0
      pbMessage(_INTL("{1} received ${2}!", $Trainer.name, amount.to_s_formatted))
    else
      pbMessage(_INTL("{1} spent ${2}!", $Trainer.name, amount.abs.to_s_formatted))
    end
  end

  # Show current money initial pause
  15.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  oldMoney    = $Trainer.money
  targetMoney = oldMoney + amount
  step        = [(amount.abs / 15), 1].max
  current     = oldMoney

  # Count up/down animation
  while (amount >= 0 ? current < targetMoney : current > targetMoney)
    current += (amount >= 0 ? step : -step)
    current = targetMoney if (amount >= 0 ? current > targetMoney : current < targetMoney)

    color = amount >= 0 ? "00FF00" : "FF0000"
    sign  = amount >= 0 ? "+" : "-"
    goldwindow.text = "Money:\n<ar>$#{current.to_s_formatted}</ar>\n<ar><c3=#{color}>#{sign}$#{amount.abs.to_s_formatted}</c3></ar>"
    goldwindow.text = "Money:\n<ar>$#{current.to_s_formatted}</ar>\n<ar><c3=#{color}>#{sign}$#{amount.abs.to_s_formatted}</c3></ar>"
    goldwindow.resizeToFit(goldwindow.text, Graphics.width)
    goldwindow.width = 160 if goldwindow.width <= 160


    pbSEPlay("Mart buy item") if (amount >= 0 ? current < targetMoney : current > targetMoney)
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  $Trainer.money = targetMoney

  # Final display text
  goldwindow.text = "Money:\n<ar>$#{targetMoney.to_s_formatted}</ar>"

  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.width = 160 if goldwindow.width <= 160

  # Show final balance pause
  20.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  goldwindow.dispose
  pbDisposeMessageWindow(msgwindow)
end

def pbSpendCosmeticMoney(amount,showMessage=false,msgwindow=nil, goldwindow=nil)
  pbReceiveCosmeticsMoney(0- amount,showMessage,msgwindow,goldwindow,)
end
def pbReceiveCosmeticsMoney(amount, showMessage=true, msgwindow=nil, goldwindow=nil)
  msgwindow  = pbCreateMessageWindow(nil)          unless msgwindow
  goldwindow = pbDisplayCosmeticsMoneyWindow(msgwindow) unless goldwindow

  if showMessage
    if amount >= 0
      pbMessage(_INTL("{1} received {2} {3}!", $Trainer.name, amount.to_s_formatted, COSMETIC_CURRENCY_NAME))
    else
      pbMessage(_INTL("{1} spent {2} {3}!", $Trainer.name, amount.abs.to_s_formatted, COSMETIC_CURRENCY_NAME))
    end
  end

  # Show current cosmetic money initial pause
  15.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  oldMoney    = $Trainer.cosmetics_money || 0
  targetMoney = oldMoney + amount
  step        = [(amount.abs / 15), 1].max
  current     = oldMoney

  # Count up/down animation
  while (amount >= 0 ? current < targetMoney : current > targetMoney)
    current += (amount >= 0 ? step : -step)
    current = targetMoney if (amount >= 0 ? current > targetMoney : current < targetMoney)

    color   = amount >= 0 ? "00FF00" : "FF0000"
    sign    = amount >= 0 ? "+" : "-"
    goldwindow.text = _INTL(
      "{1}:\n<ar>{2}</ar>\n<ar><c3={3}>{4} {5}</c3></ar>",
      COSMETIC_CURRENCY_NAME,
      current.to_s_formatted,
      color,
      sign,
      amount.abs.to_s_formatted
    )

    pbSEPlay("Mart buy item") if amount >= 0 ? current < targetMoney : current > targetMoney
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  $Trainer.cosmetics_money = targetMoney

  # Final display text
  goldwindow.text = _INTL(
    "{1}:\n<ar>{2}</ar>",
    COSMETIC_CURRENCY_NAME,
    targetMoney.to_s_formatted
  )

  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.width = 160 if goldwindow.width <= 160

  # Show final balance pause
  20.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  goldwindow.dispose
  pbDisposeMessageWindow(msgwindow)
end


def promptCaughtPokemonAction(pokemon)
  pickedOption = false
  return pbStorePokemon(pokemon) if !$Trainer.party_full?
  return promptKeepOrRelease(pokemon) if isOnPinkanIsland() && !$game_switches[SWITCH_PINKAN_FINISHED]
  while !pickedOption
    cmd_swap = _INTL("Add to your party")
    cmd_fuse = _INTL("Fuse in party")
    cmd_pc = _INTL("Store to PC")

    options = []
    options << cmd_swap
    if !pokemon.isFusion? && playerHasFusionItems && hasUnfusedPokemonInParty(false)
      options << cmd_fuse
    end
    options << cmd_pc

    command = pbMessage(_INTL("\\ts[]Your team is full!"), options, options.length)
    case options[command]
    when cmd_swap
      if swapCaughtPokemon(pokemon)
        pickedOption = true
      end
    when cmd_fuse
      if fuseCaughtPokemon(pokemon)
        pickedOption = true
      end
    else
      # STORE
      pbStorePokemon(pokemon)
      pickedOption = true
    end
  end
end

def promptKeepOrRelease(pokemon)
  pickedOption = false
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Release a party member"), _INTL("Release this {1}",pokemon.name),], 2)
    case command
    when 0 # SWAP
      if swapReleaseCaughtPokemon(pokemon)
        pickedOption = true
      end
    else
      pickedOption = true
    end
  end
end

def fuseCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                             proc { |poke|
                               !poke.egg? &&
                                 !(poke.isFusion? rescue false) &&
                                 poke.hp > 0

                             })
  partyPosition = pbGet(1)
  return false if partyPosition == -1
  splicerItem = selectSplicer()
  return unless splicerItem

  selected = $Trainer.party[partyPosition].clone
  selectedHead, fusion_pif_sprite = selectFusion(caughtPokemon,selected)
  return false unless selectedHead && fusion_pif_sprite
  if (pbConfirmMessage(_INTL("Fuse the newly obtained {1} with {2}?", caughtPokemon.name, selected.name)))
    if selectedHead == caughtPokemon
      pbRemovePokemonAt(partyPosition)
      pbAddPokemonSilent(caughtPokemon)
      pbFuse(caughtPokemon, selected, splicerItem, fusion_pif_sprite)
    else
      actualPartyPokemon = $Trainer.party[partyPosition]  # real reference, not clone
      pbFuse(actualPartyPokemon, caughtPokemon, splicerItem, fusion_pif_sprite)
    end
    $PokemonBag.pbDeleteItem(splicerItem) if splicerItem == :DNASPLICERS || splicerItem == :SUPERSPLICERS
    return true
  end
  return false
end

# def pbChoosePokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false)
def swapCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  $PokemonStorage.pbStoreCaught($Trainer.party[index])
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def swapReleaseCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  releasedPokemon = $Trainer.party[index]
  pbMessage(_INTL("{1} was released.",releasedPokemon.name))
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def select_any_pokemon()
  commands = []
  for dex_num in 1..NB_POKEMON
    species = getPokemon(dex_num)
    commands.push([dex_num - 1, species.real_name, species.id])
  end
  return pbChooseList(commands, 0, nil, 1)
end



# chosen pokemon is returned with this format:
#[[boxID, boxPosition],pokemon]

def pbChoosePokemonPC(positionVariableNumber, pokemonVarNumber, ableProc = nil)
  chosen = nil
  pokemon = nil

    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.setFilter(ableProc) if ableProc
      chosen = screen.choosePokemon
      pokemon = $PokemonStorage[chosen[0]][chosen[1]] if chosen
      scene.pbCloseBox
    }
  pbSet(positionVariableNumber, chosen)
  pbSet(pokemonVarNumber, pokemon)
end

def set_player_birthday
  date = selectDate(_INTL("Your birthday is on"))
  $Trainer.birth_day = date.day
  $Trainer.birth_month = date.month
end

def selectDate(confirm_text = _INTL("You chose "))
  months_nb_days = {
    :JANUARY => 31,
    :FEBRUARY => 29,
    :MARCH => 31,
    :APRIL => 30,
    :MAY => 31,
    :JUNE => 30,
    :JULY => 31,
    :AUGUST => 31,
    :SEPTEMBER => 30,
    :OCTOBER => 31,
    :NOVEMBER => 30,
    :DECEMBER => 31,
  }
  month_names = {
    :JANUARY => _INTL("January"),
    :FEBRUARY => _INTL("February"),
    :MARCH => _INTL("March"),
    :APRIL => _INTL("April"),
    :MAY => _INTL("May"),
    :JUNE => _INTL("June"),
    :JULY => _INTL("July"),
    :AUGUST => _INTL("August"),
    :SEPTEMBER => _INTL("September"),
    :OCTOBER => _INTL("October"),
    :NOVEMBER => _INTL("November"),
    :DECEMBER => _INTL("December"),
  }

  pbMessage(_INTL("Which month?"))
  selected = false
  while !selected
    chosen_month_index = optionsMenu(month_names.values)
    month = month_names.keys[chosen_month_index]
    nb_days = months_nb_days[month]

    numberParams = ChooseNumberParams.new
    numberParams.setRange(1,nb_days)
    numberParams.setDefaultValue(1)
    chosen_day = pbMessageChooseNumber(_INTL("Which day?"),numberParams)

    chosen_month_name = month_names[month]
    if pbConfirmMessage(_INTL("{1} \\C[1]{2} {3}\\C[0]. Is that correct?",confirm_text, chosen_month_name,chosen_day))
      birthday = Time.new(2000,chosen_month_index+1,chosen_day)
      return birthday
    end
  end

end

# Helper method to wrap text into multiple lines
def wrap_text(text, bitmap, max_width)
  words = text.split(" ")
  lines = []
  line = ""
  words.each do |word|
    test_line = line.empty? ? word : "#{line} #{word}"
    if bitmap.text_size(test_line).width > max_width
      lines << line
      line = word
    else
      line = test_line
    end
  end
  lines << line unless line.empty?
  return lines
end

def pbColor(color)
  # Mix your own colors: http://www.rapidtables.com/web/color/RGB_Color.htm
  return Color.new(0, 0, 0) if color == :BLACK
  return Color.new(255, 255, 255) if color == :WHITE
  return Color.new(255, 115, 115) if color == :LIGHTRED
  return Color.new(245, 11, 11) if color == :RED
  return Color.new(164, 3, 3) if color == :DARKRED
  return Color.new(47, 46, 46) if color == :DARKGREY
  return Color.new(47, 46, 46) if color == :DARKGREY
  return Color.new(100, 92, 92) if color == :LIGHTGREY
  return Color.new(226, 104, 250) if color == :PINK
  return Color.new(243, 154, 154) if color == :PINKTWO
  return Color.new(255, 160, 50) if color == :GOLD
  return Color.new(255, 186, 107) if color == :LIGHTORANGE
  return Color.new(95, 54, 6) if color == :BROWN
  return Color.new(122, 76, 24) if color == :LIGHTBROWN
  return Color.new(255, 246, 152) if color == :LIGHTYELLOW
  return Color.new(242, 222, 42) if color == :YELLOW
  return Color.new(80, 111, 6) if color == :DARKGREEN
  return Color.new(154, 216, 8) if color == :GREEN
  return Color.new(197, 252, 70) if color == :LIGHTGREEN
  return Color.new(74, 146, 91) if color == :FADEDGREEN
  return Color.new(6, 128, 92) if color == :DARKLIGHTBLUE
  return Color.new(18, 235, 170) if color == :LIGHTBLUE
  return Color.new(139, 247, 215) if color == :SUPERLIGHTBLUE
  return Color.new(35, 203, 255) if color == :BLUE
  return Color.new(3, 44, 114) if color == :DARKBLUE
  return Color.new(7, 3, 114) if color == :SUPERDARKBLUE
  return Color.new(63, 6, 121) if color == :DARKPURPLE
  return Color.new(113, 16, 209) if color == :PURPLE
  return Color.new(130, 50, 200) if color == :LIGHTPURPLE
  return Color.new(219, 183, 37) if color == :ORANGE
  return Color.new(255, 255, 255, 0) if color == :INVISIBLE
  return MessageConfig::LIGHT_TEXT_MAIN_COLOR if color == :LIGHT_TEXT_MAIN_COLOR
  return MessageConfig::LIGHT_TEXT_SHADOW_COLOR if color == :LIGHT_TEXT_SHADOW_COLOR
  return MessageConfig::DARK_TEXT_MAIN_COLOR if color == :DARK_TEXT_MAIN_COLOR
  return MessageConfig::DARK_TEXT_SHADOW_COLOR if color == :DARK_TEXT_SHADOW_COLOR
  return Color.new(255, 255, 255)
end


def isDarkMode
  return $Trainer&.pokenav&.darkMode
end
