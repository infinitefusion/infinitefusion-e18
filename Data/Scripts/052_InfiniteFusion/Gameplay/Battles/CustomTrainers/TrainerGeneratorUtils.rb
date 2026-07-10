
def pick_trainer_sprite(spriter_name)
  possible_types = "abcd"
  trainer_type_index = select_number_from_seed(spriter_name,0,3)
  path = "Graphics/Trainers/trainer116#{possible_types[trainer_type_index].to_s}"
  return path
end

def select_number_from_seed(seed, min_value, max_value)
  hash = 137
  seed.each_byte do |byte|
    hash = ((hash << 5) + hash) + byte
  end
  srand(hash)
  selected_number = rand(min_value..max_value)
  selected_number
end

def pick_spriter_losing_dialog(spriter_name)
  possible_dialogs = [
    _INTL("Oh... I lost..."),
    _INTL("I did my best!"),
    _INTL("You're too strong!"),
    _INTL("You win!"),
    _INTL("What a fight!"),
    _INTL("That was fun!"),
    _INTL("Ohh, that's too bad"),
    _INTL("I should've sprited some stronger Pokémon!"),
    _INTL("So much for that!"),
    _INTL("Should've seen that coming!"),
    _INTL("I can't believe it!"),
    _INTL("What a surprise!")
  ]
  index = select_number_from_seed(spriter_name,0,possible_dialogs.size-1)
  return possible_dialogs[index]
end
