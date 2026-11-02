def get_constellation_variable(pokemon)
  case pokemon
  when :IVYSAUR;
    return VAR_CONSTELLATION_IVYSAUR
  when :WARTORTLE;
    return VAR_CONSTELLATION_WARTORTLE
  when :ARCANINE;
    return VAR_CONSTELLATION_ARCANINE
  when :MACHOKE;
    return VAR_CONSTELLATION_MACHOKE
  when :RAPIDASH;
    return VAR_CONSTELLATION_RAPIDASH
  when :GYARADOS;
    return VAR_CONSTELLATION_GYARADOS
  when :ARTICUNO;
    return VAR_CONSTELLATION_ARTICUNO
  when :MEW;
    return VAR_CONSTELLATION_MEW
    # when :POLITOED;   return  VAR_CONSTELLATION_POLITOED
    # when :URSARING;   return  VAR_CONSTELLATION_URSARING
    # when :LUGIA;      return  VAR_CONSTELLATION_LUGIA
    # when :HOOH;       return  VAR_CONSTELLATION_HOOH
    # when :CELEBI;     return  VAR_CONSTELLATION_CELEBI
     when :SLAKING;    return  VAR_CONSTELLATION_SLAKING
     when :JIRACHI;    return  VAR_CONSTELLATION_JIRACHI
    # when :TYRANTRUM;  return  VAR_CONSTELLATION_TYRANTRUM
     when :SHARPEDO;   return  VAR_CONSTELLATION_SHARPEDO
    # when :ARCEUS;     return  VAR_CONSTELLATION_ARCEUS
  end
end

def constellation_add_star(pokemon)
  star_variables = get_constellation_variable(pokemon)

  pbSEPlay("GUI trainer card open", 80)
  nb_stars = pbGet(star_variables)
  pbSet(star_variables, nb_stars + 1)
end

def clear_all_images()
  for i in 1..99
    # echoln i.to_s + " : " + $game_screen.pictures[i].name
    $game_screen.pictures[i].erase
  end
end