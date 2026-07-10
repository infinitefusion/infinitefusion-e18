# frozen_string_literal: true

CITIES_MAP_IDS = {
  :LITTLEROOT => 9,
  :OLDALE => 8,
  :PETALBURG => 7,
  :RUSTBORO => 47,
  :DEWFORD => 51,
  :SLATEPORT => 6,
  :MAUVILLE => 0,
  :VERDANTURF => 0,
  :FALLARBOR => 0,
  :LAVARIDGE => 0,
  :FORTREE => 0,
  :LILYCOVE => 0,
  :MOSSDEEP => 0,
  :SOOTOPOLIS => 0,
  :PACIFIDLOG => 0,
  :EVERGRANDE => 0,
  :BATTLEFRONTIER => 0,

}

# Necessary dor setting the various events within the pokemart map, uses the numbers as wondertrade
def get_city_numerical_id_hoenn(city_sym)
  current_city_numerical = {
    :LITTLEROOT => 1,
    :OLDALE => 2,
    :PETALBURG => 3,
    :RUSTBORO => 4,
    :DEWFORD => 5,
    :SLATEPORT => 6,
    :MAUVILLE => 7,
    :VERDANTURF => 8,
    :FALLARBOR => 9,
    :LAVARIDGE => 10,
    :FORTREE => 11,
    :LILYCOVE => 12,
    :MOSSDEEP => 13,
    :SOOTOPOLIS => 14,
    :PACIFIDLOG => 15,
    :EVERGRANDE => 16
  }
  return current_city_numerical[city_sym]
end

if Settings::GAME_ID == :IF_HOENN
  POKEMART_MAP_ID = 24
  POKEMART_DOOR_POS = [9, 10]
end

# city -> Symbol
# def enter_pokemart(city)
#   pbSet(VAR_CURRENT_MART, city)
#   pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, get_city_numerical_id(city))
#   echoln get_city_numerical_id(city)
#   pbFadeOutIn {
#     $game_temp.player_new_map_id = POKEMART_MAP_ID
#     $game_temp.player_new_x = POKEMART_DOOR_POS[0]
#     $game_temp.player_new_y = POKEMART_DOOR_POS[1]
#     $scene.transfer_player(true)
#     $game_map.autoplay
#     $game_map.refresh
#   }
# end



def inCity?(city_symbol)
  return pbGet(VAR_CURRENT_CITY) == city_symbol
end