class PokemonTemp
  attr_accessor :fuse_count_today
  attr_accessor :unfuse_count_today
end

def checkFuseChallenges(head_pokemon, body_pokemon)
  case $PokemonTemp.fuse_count_today
  when 1
    $Trainer.complete_challenge(:fuse_1_pokemon)
  when 2
    $Trainer.complete_challenge(:fuse_2_pokemon)
  when 5
    $Trainer.complete_challenge(:fuse_5_pokemon)
  end

  echoln head_pokemon.species
  echoln body_pokemon.species
  echoln head_pokemon.species == body_pokemon.species
  if head_pokemon.species == body_pokemon.species
    $Trainer.complete_challenge(:fuse_same_species)
  end

  species_data_head = GameData::Species.get(head_pokemon.species)
  species_data_body = GameData::Species.get(body_pokemon.species)
  for type in species_data_head&.types
    if species_data_body.hasType?(type)
      $Trainer.complete_challenge(:fuse_same_type)
    end
  end
end

def checkUnfuseChallenges(unfused_pokemon)
  case $PokemonTemp.unfuse_count_today
  when 1
    $Trainer.complete_challenge(:unfuse_1_pokemon)
  when 2
    $Trainer.complete_challenge(:unfuse_2_pokemon)
  when 5
    $Trainer.complete_challenge(:unfuse_5_pokemon)
  end
end