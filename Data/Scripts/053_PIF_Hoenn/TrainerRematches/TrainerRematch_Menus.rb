




#####
# Util methods
#####



####
# Methods to be called from events
####

FRIENDSHIP_LEVEL_FOR_TRADE = 1

#actionType :
# :BATTLE
# :TRADE
# :PARTNER
def doPostBattleAction(actionType,trainer, double_allowed=true)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  unless trainer
    trainer = getRebattledTrainer(event.id,map_id)
  end
  trainer.clear_previous_random_events()

  return if !trainer
  case actionType
  when :BATTLE
    trainer,player_won = generateTrainerRematch(trainer,double_allowed)
  when :TRADE
    trainer = doNPCTrainerTrade(trainer)
  when :PARTNER
    partnerWithTrainer(event.id,map_id,trainer)
  end
  updateRebattledTrainer(trainer)

end

def setTrainerFriendship(trainer)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(trainer.friendship)
  number = pbMessageChooseNumber(_INTL("Friendship (0-100)?"),params)
  trainer.friendship = number
  trainer.increase_friendship(0)
  return trainer
end

#party: array of pokemon team
# [[:SPECIES,level], ... ]
#
#def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil,custom_appearance=nil)
def postBattleActionsMenu(trainer=nil, event_id=nil)
  rematchCommand = _INTL("Rematch")

  rematchSingleCommand = _INTL("Rematch (Single)")
  rematchDoubleCommand = _INTL("Rematch (Double)")

  viewTeamCommand = _INTL("View Team")

  tradeCommand = _INTL("Trade Offer")
  partnerCommand = _INTL("Partner up")
  cancelCommand = _INTL("See ya!")

  updateTeamDebugCommand = _INTL("(Debug) Simulate random event")
  resetTrainerDebugCommand = _INTL("(Debug) Reset trainer")
  setFriendshipDebugCommand = _INTL("(Debug) Set Friendship")
  printTrainerTeamDebugCommand = _INTL("(Debug) Print team")
  printTrainerInventoryCommand = _INTL("(Debug) Print inventory")

  unless trainer
    event = pbMapInterpreter.get_character(0)
    map_id = $game_map.map_id if map_id.nil?
    trainer = getRebattledTrainer(event.id,map_id)
  end
  return unless trainer
  options = []
  if trainer.getLinkedTrainer
    options << rematchSingleCommand if trainer.friendship_level >=1
    options << rematchDoubleCommand
  else
    options << rematchCommand
  end
  options << tradeCommand if trainer.friendship_level >= FRIENDSHIP_LEVEL_FOR_TRADE
  #options << partnerCommand if trainer.friendship_level >= 3
  options << viewTeamCommand
  options << updateTeamDebugCommand if $DEBUG
  options << resetTrainerDebugCommand if $DEBUG
  options << setFriendshipDebugCommand if $DEBUG
  options << printTrainerTeamDebugCommand if $DEBUG
  options << printTrainerInventoryCommand if $DEBUG

  options << cancelCommand
  trainer = applyTrainerRandomEvents(trainer) if trainer.nb_rematches >=1
  showPrerematchDialog(trainer,event_id)
  choice = optionsMenu(options,options.find_index(cancelCommand),options.find_index(cancelCommand))
  case options[choice]
  when rematchCommand
    doPostBattleAction(:BATTLE,trainer)
    trainer.inventory = [] unless trainer.inventory
    try_find_item(trainer)
    try_give_gift(trainer,event_id)
    trainer.process_party_pokemon_held_items
  when viewTeamCommand
    pbFadeOutIn {
      screen = ContactsAppInfoPageScreen.new
      screen.view_trainer_team(trainer.id)
    }
  when rematchSingleCommand
    doPostBattleAction(:BATTLE,trainer,false)
  when rematchDoubleCommand
    doPostBattleAction(:BATTLE,trainer,true)
  when tradeCommand
    doPostBattleAction(:TRADE,trainer)
  when partnerCommand
    doPostBattleAction(:PARTNER,trainer)
  when updateTeamDebugCommand
    echoln("")
    echoln "---------------"
    makeRebattledTrainerTeamGainExp(trainer,true)
    evolveRebattledTrainerPokemon(trainer)
    applyTrainerRandomEvents(trainer)
  when resetTrainerDebugCommand
    resetTrainerRebattle(event.id,map_id)
  when setFriendshipDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    trainer = setTrainerFriendship(trainer)
    updateRebattledTrainer(trainer)
  when printTrainerTeamDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    printNPCTrainerCurrentTeam(trainer)
  when printTrainerInventoryCommand
    trainer = getRebattledTrainer(event.id,map_id)
    echoln trainer.inventory
  when cancelCommand
  else
    $PokemonGlobal.nextBattleBack=nil
    return
  end
  $PokemonGlobal.nextBattleBack=nil
end

def try_find_item(trainer)
  if should_find_item(trainer)
    item = find_random_trainer_item(trainer)
    trainer.inventory = [] unless trainer.inventory
    trainer.inventory << item
    updateRebattledTrainer(trainer)
  end
end
def try_give_gift(trainer,event_id=nil)
  if should_give_item(trainer)
    item = select_gift_item(trainer)
    return unless item
    if trainer.inventory.include?(item)
      index = trainer.inventory.index(item)
      trainer.inventory.delete_at(index) if index
      updateRebattledTrainer(trainer)
    end
    showGiftDialog(trainer,event_id)
    pbReceiveItem(item)
    return true
  end
  return false
end

#leave event_type empty for random
# Used in quest, called from event
def forceRandomRematchEventOnTrainer(event_type=nil)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  while !trainer.has_pending_action
    trainer = applyTrainerRandomEvents(trainer,event_type)
  end
  updateRebattledTrainer(trainer)
end

def forceTrainerFriendshipOnTrainer(friendship=0)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer.friendship = friendship
  trainer.increase_friendship(0)
  updateRebattledTrainer(trainer)
end
