BATTLED_TRAINER_SHELLY_KEY = "aqua_shelly"
COMMON_EVENT_SHELLY_TABITHA_FOLLOWING_DIALOGUE = 202

def aqua_shelly_initialize()
  trainer_type = :TEAM_AQUA_EXEC_F
  trainer_name = "Shelly"

  battledTrainer = BattledTrainer.new(trainer_type, trainer_name, 0, BATTLED_TRAINER_SHELLY_KEY)
  battledTrainer.setFavorite(true)
  battledTrainer.setOverworldSprite("NPC_Hoenn_Aqua_Exec_F")
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_SHELLY_KEY] = battledTrainer
  return battledTrainer
end

def aqua_shelly_follow(eventId)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_SHELLY_KEY]
  partnerWithTrainer(eventId, $game_map.map_id, trainer, BATTLED_TRAINER_SHELLY_KEY, COMMON_EVENT_SHELLY_TABITHA_FOLLOWING_DIALOGUE)
end




BATTLED_TRAINER_TABITHA_KEY = "magma_tabitha"
COMMON_EVENT_SHELLY_TABITHA_FOLLOWING_DIALOGUE = 202

def magma_tabitha_initialize()
  trainer_type = :TEAM_MAGMA_EXEC_M
  trainer_name = "Tabitha"

  battledTrainer = BattledTrainer.new(trainer_type, trainer_name, 0, BATTLED_TRAINER_TABITHA_KEY)
  battledTrainer.setFavorite(true)
  battledTrainer.setOverworldSprite("NPC_Hoenn_Magma_Exec_M")
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_TABITHA_KEY] = battledTrainer
  return battledTrainer
end

def magma_tabitha_follow(eventId)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_TABITHA_KEY]
  partnerWithTrainer(eventId, $game_map.map_id, trainer, BATTLED_TRAINER_TABITHA_KEY, COMMON_EVENT_SHELLY_TABITHA_FOLLOWING_DIALOGUE)
end