# frozen_string_literal: true

class PokemonGlobalMetadata
  #Map that keeps track of all the npc trainers the player has battled
  # [map_id,event_id] =>BattledTrainer
  attr_accessor :battledTrainers
end

TIME_FOR_RANDOM_EVENTS = 60#3600 #1 hour


## Extend pbTrainerBattle to call postTrainerBattleAction at the end of every trainer battle
alias original_pbTrainerBattle pbTrainerBattle


def pbTrainerBattle(trainerID, trainerName,endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0,
                    canLose=false, outcomeVar=1,
                    name_override = nil, trainer_type_overide = nil,
                    event_id = nil, map_id = nil)
  trainer_data = GameData::Trainer.get(trainerID,trainerName,trainerPartyID)
  displayPreBattleText(trainer_data)
  map_id = $game_map.map_id
  result = original_pbTrainerBattle(trainerID, trainerName, endSpeech,doubleBattle,trainerPartyID,
                                    canLose, outcomeVar,name_override,trainer_type_overide,event_id,map_id)
  updateRematchableTrainer(trainerID, trainerName, trainerPartyID, event_id, nil, map_id) if Settings::GAME_ID == :IF_HOENN
  return result
end


def displayPreBattleText(trainer_data)
  if trainer_data.battleText && !trainer_data.battleText.empty? && @event_id
    messages = trainer_data.battle_text.split("<br>")

    messages.each do |msg|
      msg = msg.gsub("<PLAYER_NAME>", $Trainer.name)
      pbCallBub(2,@event_id)
      pbMessage(msg)
    end
  end
end

# Important: Use this instead of pbDoubleBattle and pbTripleBattle so that the trainers are rematchable!
# trainers_array is an array of 2 or 3 arrays defining a trainer like such
# [:TRAINER_CLASS, "Name", eventId]
# e.g.
# [[:TWIN_1,"Gina",12],[:TWIN_2, "Mia", 13]]
def pbMultiTrainerBattle(trainers_array,canLose=false, outcomeVar=1)
  battle_size = trainers_array.size
  if $Trainer.party.size < battle_size
    battle_size = $Trainer.party.size
  end

  case battle_size
  when 1
    trainer_id =  trainers_array[0][0]
    trainer_name =  trainers_array[0][1]
    return pbTrainerBattle(trainer_id,trainer_name)
  when 2
    trainer_1 =  trainers_array[0]
    trainer_1_id = trainer_1[0]
    trainer_1_name = trainer_1[1]
    trainer_1_event = trainer_1[2]

    trainer_2 =  trainers_array[1]
    trainer_2_id = trainer_2[0]
    trainer_2_name = trainer_2[1]
    trainer_2_event = trainer_2[2]

    trainer1_data = GameData::Trainer.get(trainer_1_id,trainer_1_name,0)
    displayPreBattleText(trainer1_data)
    result= pbDoubleTrainerBattle(trainer_1_id,trainer_1_name,0,nil,
                                 trainer_2_id,trainer_2_name,0,nil,
                                 canLose,outcomeVar)
    if Settings::GAME_ID == :IF_HOENN
      updateRematchableTrainer(trainer_1_id, trainer_1_name, 0, trainer_1_event, trainer_2_event)
      updateRematchableTrainer(trainer_2_id, trainer_2_name, 0, trainer_2_event, trainer_1_event)
    end
    return result
  when 3
    trainer_1 =  trainers_array[0]
    trainer_1_id = trainer_1[0]
    trainer_1_name = trainer_1[1]
    trainer_1_event = trainer_1[2]

    trainer_2 =  trainers_array[1]
    trainer_2_id = trainer_2[0]
    trainer_2_name = trainer_2[1]
    trainer_2_event = trainer_2[2]

    trainer_3 =  trainers_array[2]
    trainer_3_id = trainer_3[0]
    trainer_3_name = trainer_3[1]
    trainer_3_event = trainer_3[2]

    result= pbTripleTrainerBattle(trainer_1_id,trainer_1_name,0,nil,
                                  trainer_2_id,trainer_2_name,0,nil,
                                  trainer_3_id,trainer_3_name,0,nil,
                                  canLose,outcomeVar)
    if Settings::GAME_ID == :IF_HOENN
      updateRematchableTrainer(trainer_1_id, trainer_1_name, 0, trainer_1_event)
      updateRematchableTrainer(trainer_2_id, trainer_2_name, 0, trainer_2_event)
      updateRematchableTrainer(trainer_3_id, trainer_3_name, 0, trainer_3_event)
    end
    return result
  end
end



def updateRematchableTrainer(trainerID, trainerName, trainerVersion, event_id=nil, linked_event=nil, map_id = nil)
  event_id = @event_id unless event_id
  map_id = $game_map.map_id unless map_id
  trainer = registerBattledTrainer(event_id,map_id,trainerID,trainerName,trainerVersion,linked_event)
  makeRebattledTrainerTeamGainExp(trainer)
end


#Do NOT call this alone. Rebattlable trainers are always intialized after
# defeating them.
# Having a rematchable trainer that is not registered will cause crashes.
def registerBattledTrainer(event_id, mapId, trainerType, trainerName, trainerVersion=0, linked_event=nil)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  return if $PokemonGlobal.battledTrainers.has_key?(key)
  trainer = BattledTrainer.new(trainerType, trainerName, trainerVersion,key)
  trainer.setLinkedTrainer(linked_event) if linked_event
  trainer.setOverworldSprite(getOverworldSprite(event_id,mapId))
  trainer.setLocation(getMapName(mapId))
  trainer.location_map_id = mapId
  $PokemonGlobal.battledTrainers[key] = trainer
  echoln "Registered rematchable trainer #{key}"
  return trainer
end


def getOverworldSprite(event_id,mapId)
  current_map = $game_map.map_id
  if mapId == current_map
    event = $game_map.events[event_id]
  else
    map = $MapFactory.getMap(mapId,false)
    event = map&.events[event_id]
  end
  if event
    return event.character_name
  end
  return ""
end
def unregisterBattledTrainer(event_id, mapId)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  if  $PokemonGlobal.battledTrainers.has_key?(key)
    $PokemonGlobal.battledTrainers[key] =nil
    echoln "Unregistered Battled Trainer #{key}"
  else
    echoln "Could not unregister Battled Trainer #{key}"
  end
end

def resetTrainerRebattle(event_id, map_id)
  trainer = getRebattledTrainer(event_id,map_id)

  trainerType = trainer.trainerType
  trainerName = trainer.trainerName

  unregisterBattledTrainer(event_id,map_id)
  registerBattledTrainer(event_id,map_id,trainerType,trainerName)
end

def updateRebattledTrainer(updated_trainer)
  key = updated_trainer.trainerKey
  updateRebattledTrainerWithKey(key,updated_trainer)
end

def updateRebattledTrainerWithKey(key,updated_trainer)
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[key] = updated_trainer
end

def getRebattledTrainerKey(event_id, map_id)
  return [event_id,map_id]
end

def getRebattledTrainerFromKey(key)
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  return $PokemonGlobal.battledTrainers[key]
end
def getRebattledTrainer(event_id,map_id)
  key = getRebattledTrainerKey(event_id, map_id)
  return getRebattledTrainerFromKey(key)
end

