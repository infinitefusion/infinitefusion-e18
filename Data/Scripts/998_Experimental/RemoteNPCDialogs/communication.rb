# Npc context an array of dialogues in order
# ex: ["NPC: hello, I'm an NPC"], ["Player: Hello!"]
def getRemoteNPCResponse(event_id)
  npc_event = $game_map.events[event_id]
  npc_context = get_npc_context(event_id) # ["NPC: Hello...", "Player: ..."]
  npc_sprite_name = npc_event.character_name
  current_location = getMapName($game_map.map_id)

  rematchable_trainer = getRebattledTrainer(event_id, $game_map.map_id)
  trainer_dialogs = {}
  if rematchable_trainer
    trainer_data = GameData::Trainer.try_get(rematchable_trainer.trainerType, rematchable_trainer.trainerName, 0)
    trainer_dialogs = {
      TRAINER_CLASS: rematchable_trainer.trainerType,
      TRAINER_NAME: rematchable_trainer.trainerName,

      CATCH: trainer_data.preRematchText_caught,
      EVOLVE: trainer_data.preRematchText_evolved,
      FUSE: trainer_data.preRematchText_fused,
      UNFUSE: trainer_data.preRematchText_unfused,
      REVERSE: trainer_data.preRematchText_reversed,
      GIFT: trainer_data.preRematchText_gift }

  end

  # Build state params
  state_params = {
    context: npc_context,
    sprite: npc_sprite_name,
    location: current_location,
    trainer_dialogs: trainer_dialogs
  }

  # Convert into JSON-safe form (like battle code does)
  safe_params = convert_to_json_safe(state_params)
  json_data = JSON.generate(safe_params)

  # Send to your remote dialogue server
  response = pbPostToString(Settings::REMOTE_NPC_DIALOG_SERVER_URL, { "npc_state" => json_data }, 10)
  response = clean_json_string(response)

  echoln "npc sprite name: #{npc_sprite_name}"
  echoln "current location: #{current_location}"
  echoln "[Remote NPC] Sent state: #{json_data}"
  echoln "[Remote NPC] Got response: #{response}"

  pbCallBub(2, event_id)
  pbMessage(response)
  return response
end
