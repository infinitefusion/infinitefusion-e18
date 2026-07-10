def select_game_mode
  game_mode = nil

  cmd_mode_classic = _INTL("Classic")
  cmd_mode_remix = _INTL("Remix Mode")
  cmd_mode_random = _INTL("Randomized Mode")
  cmd_mode_legendary = _INTL("Legendary Mode")
  cmd_mode_expert = _INTL("Expert Mode")  #Disabled - Moved to experimental options

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

  until game_mode
    chosen_index = pbMessage(_INTL("Which mode would you like to play?"),commands)
    case commands[chosen_index]
    when cmd_mode_classic
      commands_choose_mode = [_INTL("Back"),_INTL("Play Classic Mode")]
      confirmed_index = pbMessage(_INTL("\\C[1]Classic\\C[0] is the default game mode. All of the player teams and encounters are based on the original games. Every Pokémon is still available."),commands_choose_mode)
      game_mode = :CLASSIC if confirmed_index ==1
    when cmd_mode_remix
      commands_choose_mode = [_INTL("Back"),_INTL("Play Remix Mode")]
      confirmed_index = pbMessage(_INTL("\\C[1]Remix mode\\C[0] is a special mode made by some members of the community that changes all of the trainer teams and wild encounters to showcase more Pokémon from the newer generations."),commands_choose_mode)
      game_mode = :REMIX if confirmed_index ==1
    when cmd_mode_random
      commands_choose_mode = [_INTL("Back"),_INTL("Play Randomized Mode")]
      confirmed_index = pbMessage(_INTL("In \\C[1]Randomized mode\\C[0] all of the trainers, wild encounters and items can be randomized. You'll get to customize exactly how you want everything to be randomized."),commands_choose_mode)
      game_mode = :RANDOMIZED if confirmed_index ==1
    when cmd_mode_legendary
      commands_choose_mode = [_INTL("Back"),_INTL("Play Legendary Mode")]
      confirmed_index = pbMessage(_INTL("In \\C[1]Legendary mode\\C[0], every trainer Pokémon gets fused with a legendary Pokémon. You also start with an egg of every legendary Pokémon in your PC and get a legendary starter."),commands_choose_mode)
      game_mode = :LEGENDARY if confirmed_index ==1
    when cmd_mode_expert
      commands_choose_mode = [_INTL("Back"),_INTL("Play Expert Mode")]
      confirmed_index = pbMessage(_INTL("\\C[1]Expert mode\\C[0] mode is similar to Classic mode, but it changes all of the trainer teams to make them as challenging as possible. This is for veteran Pokémon trainers only!"),commands_choose_mode)
      game_mode = :EXPERT if confirmed_index ==1
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