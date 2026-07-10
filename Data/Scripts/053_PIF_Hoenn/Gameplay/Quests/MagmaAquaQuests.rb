################
#### AQUA     ##
################

def build_aqua_song(event_id1, event_id2)
  chorus = _INTL("Oh! \\wt[10]Hey!\\wt[10]\\wt[10] Aqua!\\wt[10] We're Team Aqua!")
  add_aqua_song_segment(chorus)
  segment1 = build_aqua_song_pt1(event_id1, event_id2, chorus)
  build_aqua_song_pt2(event_id1, event_id2)
  add_aqua_song_segment(chorus)
  # add_aqua_song_segment(segment1)
  build_aqua_song_pt3(event_id1, event_id2)

end

def build_aqua_song_pt1(event_id1, event_id2, chorus)
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Let's see, this is what we have so far."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("The start of the song goes like this..."))

  #~~~~~ Singing ~~~~~~
  segment_1_incomplete = _INTL("Cool as...\\wt[20]\\ts[1]Something...\\n\\ts[4]\\wt[10]Graceful like... \\wt[20]\\ts[1]Something else...")
  add_aqua_song_segment(segment_1_incomplete)
  sing_aqua_song
  pbWait(10)
  #~~~~~~~~~~~

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Yeah... That's all we have so far."))

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("So uh... What's something that's icy cool?"))

    helpText = _INTL("Cool as...")
    word1 = pbEnterText(helpText, 2, 16)

    pbCallBubDown(2, event_id1) # Left
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Cool as {1}...?", word1), commands) == 0
  end

  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("Hmmm..."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Not bad! That might be the one."))
  pbWait(10)

  #~~~~~ Singing ~~~~~~
  pbSet(VAR_AQUA_SONG, [])
  add_aqua_song_segment(chorus)
  segment_1_incomplete2 = _INTL("Cool as {1}!\\wt[10]\\nGraceful like...\\wt[20]\\ts[1]Something...", word1)
  add_aqua_song_segment(segment_1_incomplete2)
  sing_aqua_song
  pbWait(10)
  #~~~~~~~~~~~

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Uh... Graceful like what?"))
    helpText = _INTL("Graceful like...")
    word2 = pbEnterText(helpText, 2, 16)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Cool as {1}!\\nGraceful like {2}!", word1, word2), commands) == 0
  end

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("That sounds pretty good, right?"))

  pbSet(VAR_AQUA_SONG, [])
  add_aqua_song_segment(chorus)
  segment_1_complete = _INTL("Cool as {1}!\\n\\wt[10]Graceful like {2}!", word1, word2)
  add_aqua_song_segment(segment_1_complete)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Okay... On to the next part!"))

  return segment_1_complete
end

def build_aqua_song_pt2(event_id1, event_id2)
  cmd_goals = _INTL("Our goals")
  cmd_style = _INTL("Our style")
  cmd_strength = _INTL("Our strength")
  commands = [cmd_goals, cmd_style, cmd_strength]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("So... What should the next line of the song be about?"), commands)
    pbCallBubDown(2, event_id1) # Left
    pbMessage(_INTL("Okay... What do you think of this?"))
    case commands[choice]
    when cmd_goals
      segment1 = _INTL("\\ts[4]\\C[1]Life depends on the sea, ya see\\n\\wt[5]We gotta ex\\wt[2]pand \\wt[2]it \\wt[2]to be free")
    when cmd_style
      segment1 = _INTL("\\ts[4]\\C[1]With our cool bandanas, we rule\\n\\wt[5]Our style will \\wt[6]make you drool")
    when cmd_strength
      segment1 = _INTL("\\ts[4]\\C[1]Our power is deep as the blue\\n\\wt[5]There's nothing\\wt[5] Team Aqua can't do")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment1, commands_confirm) == 0
  end
  add_aqua_song_segment(segment1)

  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("Yeah, this rules!"))
  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("The next line should talk about something that inspires us."))
  cmd_leader = _INTL("Archie")
  cmd_land = _INTL("The ocean")
  cmd_pokemon = _INTL("Pokémon")
  commands = [cmd_leader, cmd_land, cmd_pokemon]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("What should we sing about?"), commands)
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Hmm... How about this?"))
    case commands[choice]
    when cmd_leader
      segment2 = _INTL("\\ts[4]\\C[1]Archie's a captain bold\\n\\wt[5]His legend is \\ts[2]yet un\\wt[5]told")
    when cmd_land
      segment2 = _INTL("\\ts[4]\\C[1]The ocean is our home\\n\\wt[5]We sail through \\ts[2]salt and \\wt[5]foam")
    when cmd_pokemon
      segment2 = _INTL("\\ts[4]\\C[1]Water Pokémon by our side\\n\\wt[5]We always surf the \\ts[2]\\wt[5]tide")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment2, commands_confirm) == 0
  end
  add_aqua_song_segment(segment2)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("I'm feeling it!"))
end

def build_aqua_song_pt3(event_id1, event_id2)
  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Now we only need an ending line. Do you have something in mind?"))
    helpText = _INTL("The song's final line...")
    line = pbEnterText(helpText, 2, 50)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("{1}... ?", line), commands) == 0
  end
  add_aqua_song_segment(line)
end

def sing_aqua_song
  pbMEPlay("aqua_theme_song")
  pbWait(160) # Wait for intro
  lyrics = pbGet(VAR_AQUA_SONG)
  lyrics = [] unless lyrics.is_a?(Array)
  for line in lyrics
    pbMEPlay("aqua_theme_song")
    line = "\\ts[2]\\C[1]#{line}\\wtnp[12]"
    pbCallBub(3)
    pbMessage(line)
  end
  pbMEStop
end

def add_aqua_song_segment(text)
  current_song = pbGet(VAR_AQUA_SONG)
  current_song = [] unless current_song.is_a?(Array)
  current_song << text
  pbSet(VAR_AQUA_SONG, current_song)
end

################
#### MAGMA     ##
################

def build_magma_song(event_id1, event_id2)
  chorus = _INTL("Ma\\wt[10]gma!\\n\\wt[5]Team Ma\\wt[10]gma!")
  add_magma_song_segment(chorus)
  segment1 = build_magma_song_pt1(event_id1, event_id2, chorus)
  build_magma_song_pt2(event_id1, event_id2)
  add_magma_song_segment(chorus)
  # add_magma_song_segment(segment1)
  build_magma_song_pt3(event_id1, event_id2)

end

def build_magma_song_pt1(event_id1, event_id2, chorus)
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Let's see, this is what we have so far."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("The start of the song goes like this..."))

  #~~~~~ Singing ~~~~~~
  segment_1_incomplete = _INTL("Hot as...\\wt[20]\\ts[1]Something...\\ts[4]\\wt[10]\\nFierce like...\\wt[20]\\ts[1]Something else...")
  add_magma_song_segment(segment_1_incomplete)
  sing_magma_song
  pbWait(10)
  #~~~~~~~~~~~

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Yeah... That's all we have so far."))

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("So uh... What's something that's burning hot?"))

    helpText = _INTL("Hot as...")
    word1 = pbEnterText(helpText, 2, 16)

    pbCallBubDown(2, event_id1) # Left
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Hot as {1}...?", word1), commands) == 0
  end

  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("Hmmm..."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("I like it! Let's go with this!"))
  pbWait(10)

  #~~~~~ Singing ~~~~~~
  pbSet(VAR_MAGMA_SONG, [])
  add_magma_song_segment(chorus)
  segment_1_incomplete2 = _INTL("Hot as {1}!\\wt[10]\\nFierce like...\\wt[20]\\ts[1]Something...", word1)
  add_magma_song_segment(segment_1_incomplete2)
  sing_magma_song
  pbWait(10)
  #~~~~~~~~~~~

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Uh... Fierce like what?"))
    helpText = _INTL("Fierce like...")
    word2 = pbEnterText(helpText, 2, 16)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Hot as {1}! Fierce like {2}!", word1, word2), commands) == 0
  end

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("It has a nice ring to it, don't you think?"))

  pbSet(VAR_MAGMA_SONG, [])
  add_magma_song_segment(chorus)
  segment_1_complete = _INTL("Hot as {1}!\\wt[10]\\nFierce like {2}!", word1, word2)
  add_magma_song_segment(segment_1_complete)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Okay... On to the next part!"))

  return segment_1_complete
end

def build_magma_song_pt2(event_id1, event_id2)
  cmd_goals = _INTL("Our goals")
  cmd_style = _INTL("Our style")
  cmd_strength = _INTL("Our strength")
  commands = [cmd_goals, cmd_style, cmd_strength]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("So... What should the next line of the song be about?"), commands)
    pbCallBubDown(2, event_id1) # Left
    pbMessage(_INTL("Okay... How's this?"))
    case commands[choice]
    when cmd_goals
      segment1 = _INTL("\\ts[4]\\C[2]Land is the cradle of all\\n\\wt[5]We must ex\\wt[2]pand \\wt[2]its \\wt[2]sprawl")
    when cmd_style
      segment1 = _INTL("\\ts[4]\\C[2]Our uniforms are sleek\\n\\wt[5]Our style is \\wt[6]unique")
    when cmd_strength
      segment1 = _INTL("\\ts[4]\\C[2]No one can match our power\\n\\wt[5]We grow stronger \\wt[2]by \\wt[2]the \\wt[2]hour")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment1, commands_confirm) == 0
  end
  add_magma_song_segment(segment1)

  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("That's pretty good!"))
  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("The next line should talk about something that inspires us."))
  cmd_leader = _INTL("Maxie")
  cmd_land = _INTL("The land")
  cmd_pokemon = _INTL("Pokémon")
  commands = [cmd_leader, cmd_land, cmd_pokemon]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("What should we sing about?"), commands)
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Hmm... How about this?"))
    case commands[choice]
    when cmd_leader
      segment2 = _INTL("\\ts[4]\\C[2]Ma\\wt[2]xie's a visionary \\wt[5]\\nHis \\ts[2]intellect is \\wt[5]le\\wt[2]gen\\wt[2]da\\wt[4]ry")
    when cmd_land
      segment2 = _INTL("\\ts[4]\\C[2]The land is our domain\\wt[5]\\n\\ts[2]Magma flows \\wt[2]through \\wt[2]our \\wt[2]veins")
    when cmd_pokemon
      segment2 = _INTL("\\ts[4]\\C[2]Land Po\\wt[2]ké\\wt[2]mon by our side\\wt[5]\\nThe oceans \\ts[2]will soon sub\\wt[5]side")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment2, commands_confirm) == 0
  end
  add_magma_song_segment(segment2)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Oh yeah that's pretty good."))
end

def build_magma_song_pt3(event_id1, event_id2)
  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Now we only need an ending line. Do you have something in mind?"))
    helpText = _INTL("The song's final line...")
    line = pbEnterText(helpText, 2, 50)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("{1}... ?", line), commands) == 0
  end
  add_magma_song_segment(line)
end

def sing_magma_song
  pbMEPlay("magma_theme_song")
  lyrics = pbGet(VAR_MAGMA_SONG)
  lyrics = [] unless lyrics.is_a?(Array)
  for line in lyrics
    pbMEPlay("magma_theme_song")
    line = "\\ts[3]\\C[2]#{line}\\wtnp[20]"
    pbCallBub(3)
    pbMessage(line)
  end
  pbMEStop
end

def add_magma_song_segment(text)
  current_song = pbGet(VAR_MAGMA_SONG)
  current_song = [] unless current_song.is_a?(Array)
  current_song << text
  pbSet(VAR_MAGMA_SONG, current_song)
end

################################
def aquaCarvanhaQuestValidPokemon?(pokemon)
  valid_species = isPartPokemon(pokemon, :ZUBAT) || isPartPokemon(pokemon, :GOLBAT) || isPartPokemon(pokemon, :CROBAT) ||
    isPartPokemon(pokemon, :GEODUDE) || isPartPokemon(pokemon, :GRAVELER) || isPartPokemon(pokemon, :GOLEM)
  is_water_type = pokemon.hasType?(:WATER)
  echoln "#{pokemon.species}: valid species: #{valid_species}, waterType: #{is_water_type}"
  return valid_species && is_water_type
end

# Check that there's 2 ZUBAT and 1 GEODUDE in party
def aquaCarvanhaPostValidation()
  echoln pbGet(5)
  nb_zubat = 0
  nb_geodude = 0
  target_nb_zubat = 2
  target_nb_geodude = 1
  $Trainer.party.each do |pokemon|
    nb_zubat += 1 if isPartPokemon(pokemon, :ZUBAT) || isPartPokemon(pokemon, :GOLBAT) || isPartPokemon(pokemon, :CROBAT)
    nb_geodude += 1 if isPartPokemon(pokemon, :GEODUDE) || isPartPokemon(pokemon, :GRAVELER) || isPartPokemon(pokemon, :GOLEM)
  end
  return nb_zubat == target_nb_zubat && nb_geodude == target_nb_geodude
end