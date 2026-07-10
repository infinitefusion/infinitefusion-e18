class PokemonGlobalMetadata
  attr_accessor :common_map_entrance_id
  attr_accessor :common_map_entrance_position
end

COMMON_MAPS_KANTO = {
  :POKEMART => {
    id: 357,
    position: [12, 12]
  }
}

COMMON_MAPS_HOENN =
  {
    :POKEMART => {
      id: 24,
      position: [9, 10]
    },
    :POKEMON_CENTER => {
      id: 25,
      position: [10, 10]
    },
    :POKEMON_CENTER_BIRTHDAY => {
      id: 27,
      position: [10, 10]
    },
    :CLOTHING_STORE => {
      id: 94,
      position: [11, 11]
    },
    :CONTEST_HALL => {
      id: 110,
      position: [11, 37]
    }
  }

def enter_common_building(building_id, city)
  $PokemonGlobal.common_map_entrance_id = $game_map.map_id
  $PokemonGlobal.common_map_entrance_position = [$game_player.x, $game_player.y]

  maps_list = Settings::HOENN ? COMMON_MAPS_HOENN : COMMON_MAPS_KANTO
  new_map_data = maps_list[building_id]
  return unless new_map_data
  pbSet(VAR_CURRENT_CITY, city)
  new_map = new_map_data[:id]
  new_position = new_map_data[:position]
  pbFadeOutIn {
    $game_temp.player_new_map_id = new_map
    $game_temp.player_new_x = new_position[0]
    $game_temp.player_new_y = new_position[1]
    $game_temp.player_new_direction = $game_player.direction

    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end

def exit_common_building()
  return unless $PokemonGlobal.common_map_entrance_id && $PokemonGlobal.common_map_entrance_position
  pbFadeOutIn {
    $game_temp.player_new_map_id = $PokemonGlobal.common_map_entrance_id
    $game_temp.player_new_x = $PokemonGlobal.common_map_entrance_position[0]
    $game_temp.player_new_y = $PokemonGlobal.common_map_entrance_position[1]
    $game_temp.player_new_direction = DIRECTION_DOWN
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
  $PokemonGlobal.common_map_entrance_id = nil
  $PokemonGlobal.common_map_entrance_position = nil
  reset_pokemart_variables
end

def enter_pokemon_center(city_symbol)
  pbSetPokemonCenter
  pbSet(VAR_CURRENT_CITY, city_symbol)
  pokemon_center_type = isPlayerBirthDay? ? :POKEMON_CENTER_BIRTHDAY : :POKEMON_CENTER
  enter_common_building(pokemon_center_type, city_symbol)
end

def exit_pokemon_center()
  pbSEPlay(SE_EXIT)
  $PokemonGlobal.common_map_entrance_id = nil
  $PokemonGlobal.common_map_entrance_position = nil
  reset_pokemart_variables
  pbFadeOutIn {
    if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
      pbCancelVehicles
      $game_temp.player_new_map_id = $PokemonGlobal.pokecenterMapId
      $game_temp.player_new_x = $PokemonGlobal.pokecenterX
      $game_temp.player_new_y = $PokemonGlobal.pokecenterY
      $game_temp.player_new_direction = DIRECTION_DOWN

      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      # Home
      $game_temp.player_new_map_id = 9
      $game_temp.player_new_x = 16
      $game_temp.player_new_y = 23
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    end
  }
end

