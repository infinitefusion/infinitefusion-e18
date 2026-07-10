
def exportTeamForShowdown()
  message = ""
  for pokemon in $Trainer.party
    message << exportFusedPokemonForShowdown(pokemon)
    message << "\n"
  end
  Input.clipboard = message
end

# Output example
# Clefnair (Clefable) @ Life Orb
# Ability: Magic Guard
# Level: 33
# Fusion: Dragonair
# EVs: 252 HP / 252 SpD / 4 Spe
# Modest Nature
# - Dazzling Gleam
# - Dragon Breath
# - Wish
# - Water Pulse
def exportFusedPokemonForShowdown(pokemon)

  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    head_pokemon_species = pokemon.species_data.head_pokemon
    species_name = head_pokemon_species.name
  else
    species_name = pokemon.species_data.real_name
  end

  if pokemon.item
    nameLine = "#{pokemon.name} (#{species_name}) @ #{pokemon.item.name}"
  else
    nameLine = "#{pokemon.name} (#{species_name})"
  end

  abilityLine = _INTL("Ability: {1}", pokemon.ability.name)
  levelLine = _INTL("Level: {1}", pokemon.level)

  fusionLine = ""
  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    body_pokemon_species = pokemon.species_data.body_pokemon
    fusionLine = _INTL("Fusion: {1}\n", body_pokemon_species.name)
  end
  evsLine = calculateEvLineForShowdown(pokemon)
  natureLine = _INTL("{1} Nature",GameData::Nature.get(pokemon.nature).real_name)
  ivsLine = calculateIvLineForShowdown(pokemon)

  move1 = "", move2 = "", move3 = "", move4 = ""
  move1 = "- #{GameData::Move.get(pokemon.moves[0].id).real_name}"  if pokemon.moves[0]
  move2 = "- #{GameData::Move.get(pokemon.moves[1].id).real_name}" if pokemon.moves[1]
  move3 = "- #{GameData::Move.get(pokemon.moves[2].id).real_name}" if pokemon.moves[2]
  move4 = "- #{GameData::Move.get(pokemon.moves[3].id).real_name}" if pokemon.moves[3]

  ret = nameLine + "\n" +
    abilityLine + "\n" +
    levelLine + "\n" +
    fusionLine +
    evsLine + "\n" +
    natureLine + "\n" +
    ivsLine + "\n" +
    move1 + "\n" +
    move2 + "\n" +
    move3 + "\n" +
    move4 + "\n"

  return ret
end

module GameData
  NAT_DEX_MAPPING[NB_POKEMON] = NAT_DEX_MAPPING[NB_POKEMON-2] =  NB_POKEMON-153
  NAT_DEX_MAPPING[NB_POKEMON-1] = NAT_DEX_MAPPING[NB_POKEMON-3] = NB_POKEMON-154
end


def calculateEvLineForShowdown(pokemon)
  evsLine = "EVs: "
  evsLine << _INTL("{1} HP /", pokemon.ev[:HP])
  evsLine << _INTL("{1} Atk / ", pokemon.ev[:ATTACK])
  evsLine << _INTL("{1} Def / ", pokemon.ev[:DEFENSE])
  evsLine << _INTL("{1} SpA / ", pokemon.ev[:SPECIAL_ATTACK])
  evsLine << _INTL("{1} SpD / ", pokemon.ev[:SPECIAL_DEFENSE])
  evsLine << _INTL("{1} Spe / ", pokemon.ev[:SPEED])
  return evsLine
end

def calculateIvLineForShowdown(pokemon)
  ivLine = "IVs: "
  ivLine << _INTL("{1} HP / ", pokemon.iv[:HP])
  ivLine << _INTL("{1} Atk / ", pokemon.iv[:ATTACK])
  ivLine << _INTL("{1} Def / ", pokemon.iv[:DEFENSE])
  ivLine << _INTL("{1} SpA / ", pokemon.iv[:SPECIAL_ATTACK])
  ivLine << _INTL("{1} SpD / ", pokemon.iv[:SPECIAL_DEFENSE])
  ivLine << _INTL("{1} Spe", pokemon.iv[:SPEED])
  return ivLine
end



