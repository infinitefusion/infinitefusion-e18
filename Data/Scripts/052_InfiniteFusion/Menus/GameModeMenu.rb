def select_game_mode
  game_mode = nil

  is_ru = (getCurrentLanguage == :RUSSIAN || (defined?($PokemonSystem) && $PokemonSystem && $PokemonSystem.language == 1))
  cmd_mode_classic = is_ru ? "Классика" : _INTL("Classic")
  cmd_mode_remix = is_ru ? "Ремикс-режим" : _INTL("Remix Mode")
  cmd_mode_random = is_ru ? "Рандомизатор" : _INTL("Randomized Mode")
  cmd_mode_legendary = is_ru ? "Легендарный режим" : _INTL("Legendary Mode")
  cmd_mode_expert = is_ru ? "Режим эксперта" : _INTL("Expert Mode")  #Disabled - Moved to experimental options

  commands = []
  commands << cmd_mode_classic
  commands << cmd_mode_remix if Settings::KANTO
  if Settings::KANTO
    commands << cmd_mode_random
  else
    commands << cmd_mode_random if $Trainer.new_game_plus_unlocked
  end
  commands << cmd_mode_legendary if Settings::KANTO && $Trainer.new_game_plus_unlocked
  echoln $Trainer.new_game_plus_unlocked
  commands_choose_mode = []

  prompt_title = is_ru ? "В какой режим вы хотите сыграть?" : _INTL("Which mode would you like to play?")
  until game_mode
    chosen_index = pbMessage(prompt_title, commands)
    case commands[chosen_index]
    when cmd_mode_classic
      commands_choose_mode = is_ru ? ["Назад", "Играть в Классический режим"] : [_INTL("Back"),_INTL("Play Classic Mode")]
      desc = is_ru ? "\\C[1]Классический\\C[0] — стандартный режим игры. Все команды тренеров и встречи основаны на оригинальных играх. Все покемоны доступны." : _INTL("\\C[1]Classic\\C[0] is the default game mode. All of the player teams and encounters are based on the original games. Every Pokémon is still available.")
      confirmed_index = pbMessage(desc, commands_choose_mode)
      game_mode = :CLASSIC if confirmed_index == 1
    when cmd_mode_remix
      commands_choose_mode = is_ru ? ["Назад", "Играть в Ремикс-режим"] : [_INTL("Back"),_INTL("Play Remix Mode")]
      desc = is_ru ? "\\C[1]Ремикс-режим\\C[0] — фанатский режим, изменяющий команды тренеров и диких покемонов, чтобы показать больше существ из новых поколений." : _INTL("\\C[1]Remix mode\\C[0] is a special mode made by some members of the community that changes all of the trainer teams and wild encounters to showcase more Pokémon from the newer generations.")
      confirmed_index = pbMessage(desc, commands_choose_mode)
      game_mode = :REMIX if confirmed_index == 1
    when cmd_mode_random
      commands_choose_mode = is_ru ? ["Назад", "Играть в Рандомизатор"] : [_INTL("Back"),_INTL("Play Randomized Mode")]
      desc = is_ru ? "В режиме \\C[1]Рандомизатора\\C[0] все тренеры, дикие покемоны и предметы могут быть случайными. Вы сможете тонко настроить параметры генерации." : _INTL("In \\C[1]Randomized mode\\C[0] all of the trainers, wild encounters and items can be randomized. You'll get to customize exactly how you want everything to be randomized.")
      confirmed_index = pbMessage(desc, commands_choose_mode)
      game_mode = :RANDOMIZED if confirmed_index == 1
    when cmd_mode_legendary
      commands_choose_mode = is_ru ? ["Назад", "Играть в Легендарный режим"] : [_INTL("Back"),_INTL("Play Legendary Mode")]
      desc = is_ru ? "В \\C[1]Легендарном режиме\\C[0] покемоны каждого тренера объединены с легендарными покемонами. Вы также начинаете с яйцами легендарных покемонов в ПК." : _INTL("In \\C[1]Legendary mode\\C[0], every trainer Pokémon gets fused with a legendary Pokémon. You also start with an egg of every legendary Pokémon in your PC and get a legendary starter.")
      confirmed_index = pbMessage(desc, commands_choose_mode)
      game_mode = :LEGENDARY if confirmed_index == 1
    when cmd_mode_expert
      commands_choose_mode = is_ru ? ["Назад", "Играть в Режим эксперта"] : [_INTL("Back"),_INTL("Play Expert Mode")]
      desc = is_ru ? "\\C[1]Режим эксперта\\C[0] похож на классический, но команды тренеров усилены до предела. Только для опытных игроков!" : _INTL("\\C[1]Expert mode\\C[0] mode is similar to Classic mode, but it changes all of the trainer teams to make them as challenging as possible. This is for veteran Pokémon trainers only!")
      confirmed_index = pbMessage(desc, commands_choose_mode)
      game_mode = :EXPERT if confirmed_index == 1
    end
  end
  apply_game_mode(game_mode)
  return game_mode
end

def apply_game_mode(game_mode)
  case game_mode
  when :REMIX
    $game_switches[SWITCH_MODERN_MODE] = true
  when :RANDOMIZED
    $game_switches[SWITCH_RANDOMIZED_MODE_INTRO]=true
    pbSet(VAR_CURRENT_GYM_TYPE,-1)
  when :LEGENDARY
    initializeLegendaryMode
  when :EXPERT
    $game_switches[SWITCH_EXPERT_MODE] = true
  end
end
