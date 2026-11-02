# available channels
# :RANDOM
# :NEWS
# :WEATHER

TV_CHANNEL_CHANCES = {
  NEWS: 3,
  WEATHER: 3,
  TREND: 1
}

def showTVText(channel = :RANDOM)
  if channel == :RANDOM
    channel = select_random_channel
  end

  case channel
  when :NEWS
    pbTVNews()
  when :WEATHER
    pbMessage(_INTL("It's the weather channel! Let's see how things are looking out today."))
    pbWeatherMap()
  when :TREND
    getTVTrendMessages()
  end
end


SWITCH_REPORTER_AT_PETALBURG = 2026
SWITCH_REPORTER_PETALBURG_INTERVIEWED = 2027

VAR_REPORTER_Q1 = 1006
VAR_REPORTER_Q2 = 1007
VAR_REPORTER_Q3 = 1008
VAR_REPORTER_Q4 = 1009
VAR_REPORTER_Q5 = 1010

def select_random_channel
  available_channels = TV_CHANNEL_CHANCES.dup
  available_channels.delete(:TREND) unless pbGet(VAR_TRENDY_PHRASE).is_a?(String)

  channel_picks = []
  for channel in available_channels.keys
    channel = channel
    chances = TV_CHANNEL_CHANCES[channel]
    for i in 0..chances
      channel_picks << channel
    end
  end
  return channel_picks.sample
end



def getTVTrendMessages()
  current_phrase = pbGet(VAR_TRENDY_PHRASE)
  vowels =["A","E","I","O","U"]
  if vowels.include?(current_phrase[0])
    adverb = _INTL("an")
  else
    adverb = _INTL("a")
  end

  pbMessage(_INTL("It's the trend-watcher network channel!"))
  pbMessage(_INTL("\"Everybody's talking about it, {1} has been all the rage all around the region!\"", current_phrase))
  pbMessage(_INTL("\"Nobody knows where it's started, but {1} is all that the younger people are talking about these days.\"", current_phrase))
  case rand(3)
  when 0
    pbMessage(_INTL("\"Where can someone get their hands on {1} {2}? We'll continue our investigation to find out!'\"", adverb, current_phrase))
  when 1
    pbMessage(_INTL("\"Experts say that {1} may just be the next big thing! Stay tuned for updates!\"", current_phrase))
  when 2
    pbMessage(_INTL("\"Some say that {1} just a fad, but others seem to think it's here to stay! Stay tuned for updates!\"", current_phrase))
  end
end

#       pbMessage(_INTL("\"\""))


def pbTVNews()
  if $game_switches[SWITCH_REPORTER_AT_PETALBURG]
    pbMessage(_INTL("It's showing the local news. There's a berry-growing contest going on in Petalburg Town!"))
  else
    return pbMessage(_INTL("It's a rerun of PokéChef Deluxe. Nothing important on the news right now."))
  end
end

#pbMessage(_INTL("\"\""))
def berryContestTVNews
  pbMessage(_INTL("\"...I'm currently standing in front of the Berry-growing contest in Petalburg Town. We've interviewed {1}, a local Trainer to get their thoughts on the contest!\"",$Trainer.name))

  second_part = "."
  case $game_variables[VAR_REPORTER_Q1]
  when 0 #First time in contest? Yes
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL(" but they seemed very confident about it!")
    when 1
      second_part = _INTL(" and they seemed to be having fun already!")
    when 2
      second_part = _INTL(" and they understandably seemed a bit nervous!")
    when 2
      second_part = _INTL(" but they didn't really seem very interested in it. Perhaps, they only joined for the prize?")
    end
    pbMessage(_INTL("\"This was {1}'s first time participating {2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"Apparently, their strategy to win is to {1}. We'll see how that pays off for them!\"",$game_variables[VAR_REPORTER_Q3].downcase))
  when 1 #First time in contest? No
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL("They seemed to be enjoying it a great amount!")
    when 1
      second_part = _INTL("It seemed they were still having a lot of fun!")
    when 2
      second_part = _INTL("The novelty wore down a bit for them, but they said they're still having a good time.")
    when 2
      second_part = _INTL("They didn't seem too interested in the contest when I asked them, but they still came back to participate again.")
    end
    pbMessage(_INTL("\"{1} is a returning participant to the contest{2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"According to them, the secret trick to growing Berries is to {1}... Who would've thought!'\"",$game_variables[VAR_REPORTER_Q3].downcase))

  when 2 #First time in contest? Not participating
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL(", it almost seems like they were having even more fun than the contestants themselves.!")
    when 1
      second_part = _INTL(", but they said that it was still fun as a spectator.")
    when 2
      second_part = _INTL(", they just came to check it out of curiosity.")
    when 2
      second_part = _INTL(". They didn't seem too interested in the contest when I asked them, it seems they were just passing by.")
    end
    pbMessage(_INTL("\"{1} said they're not participating in the contest this year{2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"I asked them to sum up the contest in one word and they said \"{1}\", without any hesitation! That really says it all, doesn't it?''\"",$game_variables[VAR_REPORTER_Q3]))
  end
  pbWait(10)
  pbMessage(_INTL("\"This was Gabby, reporting live from Petalburg Town. We'll see you again on our next broadcast!\""))
end


VAR_REPORTER_POKEMON_112 = 976
def trainerSearchRt112
  poke_name = pbGet(VAR_REPORTER_POKEMON_112)
  pbMessage(_INTL("\"...This is Gabby for Trainer Search, We're currently standing at the foot of Mt. Chimney, where local Trainers like to gather.\"",$Trainer.name))
  pbMessage(_INTL("\"We're currently joined by {1}, a young Trainer who bested me in a Pokémon battle.\"",$Trainer.name))
  if poke_name.is_a?(String)
    pbMessage(_INTL("\"Their {1} absolutely wiped the floor with my Pokémon!\"", poke_name))
  end


  player_response_q1 = pbGet(VAR_REPORTER_Q1)
  player_response_q2 = pbGet(VAR_REPORTER_Q2)

  case player_response_q1
  when 0
    pbMessage(_INTL("\"They responded that they were looking for rare Pokémon! Indeed, Mt. Chimney is home to many rare fire-type Pokémon that aren't found anywhere else in the region.\""))
  when 1
    pbMessage(_INTL("\"They said that it was the thrill of exploring that brought them here. Such an adventurous spirit at such a young age!\""))
  when 2
    pbMessage(_INTL("\"They said that they were simply trying to get the other side of the volcano. Of course, Mt. Chimney sits at the center of the region, so Trainers who want to get Fallarbor Town need to cross right through it.\"",$Trainer.name))
  when 3
    pbMessage(_INTL("\"They said they got lost and didn't know where they were! I made sure to point them in the right direction.\""))
  end
  pbMessage(_INTL("\"I then asked {1} what exactly it was that they were expecting to find here in Mt. Chimney and their answer totally floored me!\"",$Trainer.name))
  pbMessage(_INTL("\"They said that they're looking for {1}. How crazy is that!\"",player_response_q2))
  pbMessage(_INTL("\"But it does makes total sense if you think about it!\""))
  pbWait(10)
  pbMessage(_INTL("\"That's all for today. We'll continue our search throughout the region for more Trainers to interview! Thanks for joining me on Trainer Search. This was Gabby, reporting from Mt. Chimney.\""))
end

VAR_REPORTER_POKEMON_118 = 977

def trainerSearchRt118
  poke_name = pbGet(VAR_REPORTER_POKEMON_118)
  pbMessage(_INTL("\"...This is Gabby for Trainer Search, We're currently standing on the beach on Route 118\"",$Trainer.name))
  pbMessage(_INTL("\"We're currently joined by {1}, a young Trainer who bested me in a Pokémon battle.\"",$Trainer.name))
  if poke_name.is_a?(String)
    pbMessage(_INTL("\"My Pokémon stood no chance against their {1}!\"", poke_name))
  end

  player_response_q1 = pbGet(VAR_REPORTER_Q1)
  player_response_q2 = pbGet(VAR_REPORTER_Q2)
  pbMessage(_INTL("\"They seemed to be on their way to Fortree City, so I started by asking them what they were expecting to see on the way there.\"",$Trainer.name))

  case player_response_q1
  when 0
    pbMessage(_INTL("\"They responded that they were looking for rare Pokémon! Indeed, the way to Fortree City is home to many rare tropical Pokémon that aren't found anywhere else in the region.\""))
  when 1
    pbMessage(_INTL("\"As it turns out, they came here to appreciate the beautiful tropical landscapes that the route has to offer.\""))
  when 2
    pbMessage(_INTL("\"Apparently, they were looking for strong Trainers to fight! I'm sure they'll find their match somewhere in this untamed wilderness.\""))
  when 3
    pbMessage(_INTL("\"They seemed worried about all of the plants that grow on this route. Trainers around here have to watch their steps carefully if they want to avoid getting a mean rash!'\""))
  end
  pbMessage(_INTL("\"I then asked {1} what exactly what made them decide to brave the wilderness to go to Fortree City.'\"",$Trainer.name))
  pbMessage(_INTL("\"They said that they're looking for {1}. That sounds about right!\"",player_response_q2))
  pbWait(10)
  pbMessage(_INTL("\"That's all for today. We'll continue our search throughout the region for more Trainers to interview! Thanks for joining me on Trainer Search. This was Gabby, reporting from Mt. Chimney.\""))
end