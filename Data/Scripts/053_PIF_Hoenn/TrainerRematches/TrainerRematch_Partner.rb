
COMMON_EVENT_TRAINER_REMATCH_PARTNER = 200
SWITCH_PARTNERED_WITH_NPC_TRAINER = 2049

class Trainer
  attr_accessor :npcPartner
end
def partnerWithTrainer(eventId, mapID, trainer,trainer_key=nil ,common_event=nil)
  common_event = COMMON_EVENT_TRAINER_REMATCH_PARTNER if !common_event
  Kernel.pbAddDependency2(eventId,trainer.trainerName,common_event)
  pbCancelVehicles
  originalTrainer = pbLoadTrainer(trainer.trainerType, trainer.trainerName, 0)
  Events.onTrainerPartyLoad.trigger(nil, originalTrainer)
  for i in trainer.currentTeam
    i.owner = Pokemon::Owner.new_from_trainer(originalTrainer)
    i.calc_stats
  end
  trainer_key = getRebattledTrainerKey(eventId,mapID) if !trainer_key
  $PokemonGlobal.partner = [trainer.trainerType, trainer.trainerName, 0, trainer.currentTeam]
  $Trainer.npcPartner = trainer_key
end

def unpartnerWithTrainer()
  pbRemoveDependencies
  $game_switches[SWITCH_PARTNERED_WITH_NPC_TRAINER]=false
  $Trainer.npcPartner=nil
end

def promptGiveToPartner(caughtPokemon)
  return false if !$Trainer.npcPartner
  return false if $Trainer.npcPartner == BATTLED_TRAINER_WALLY_KEY && $game_switches[SWITCH_WALLY_GAVE_POKEMON]
  return false if $Trainer.npcPartner == BATTLED_TRAINER_WALLY_KEY && $game_switches[SWITCH_DIED_WITH_WALLY]

  if $Trainer.npcPartner == BATTLED_TRAINER_WALLY_KEY
    $game_switches[SWITCH_WALLY_SAW_CAUGHT_POKEMON] = true
    if caughtPokemon.isFusion?
      pbMessage(_INTL("I... I don't think I can handle a fused Pokémon. Can we try to catch a different one?"))
      return
    end
  end

  partnerTrainer = getRebattledTrainerFromKey($Trainer.npcPartner)
  return false if $Trainer.npcPartner == BATTLED_TRAINER_WALLY_KEY && partnerTrainer.currentTeam.length > 0
  return false if !partnerTrainer
    command = pbMessage(_INTL("Would you like to give the newly caught {1} to {2}?",caughtPokemon.name,partnerTrainer.trainerName),
                        [_INTL("Keep"),_INTL("Give to {1}",partnerTrainer.trainerName)], 0)
    case command
    when 0 # Keep
      return
    else
      # Give
      pbMessage(_INTL("You gave the {1} to {2}!",caughtPokemon.name,partnerTrainer.trainerName))
      if partnerTrainer.currentTeam.length == 6
        partnerTrainer.currentTeam[-1] = caughtPokemon
      else
        partnerTrainer.currentTeam << caughtPokemon
      end
      partnerTrainer.increase_friendship(10)
      updateRebattledTrainerWithKey($Trainer.npcPartner,partnerTrainer)
      if $Trainer.npcPartner == BATTLED_TRAINER_WALLY_KEY
        $game_switches[SWITCH_WALLY_GAVE_POKEMON_DIALOGUE]=true
      end
    end
end

def isPartneredWithTrainer(trainer)
  return $Trainer.npcPartner == trainer.trainerKey
end
def isPartneredWithAnyTrainer()
  return $Trainer.npcPartner != nil
end