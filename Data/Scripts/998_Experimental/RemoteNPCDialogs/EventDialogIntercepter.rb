#===============================================================================
# ** Game_Temp extensions
#===============================================================================
class Game_Temp
  attr_accessor :talking_npc_id          # Current NPC being spoken to
  attr_accessor :dialog_context        # Stores accumulated dialog per NPC
  attr_accessor :active_event_finalizer # Proc to run when event is fully finished
end

#===============================================================================
# ** Utility
#===============================================================================
def getNPCContextKey(event_id)
  "map_#{$game_map.map_id}_#{event_id}"
end

def add_npc_context(event_id, value, is_player_response=false)
  npc_context_key = getNPCContextKey(event_id)
  npc_context = $game_temp.dialog_context[npc_context_key] || []

  actor = is_player_response ? "Player" : "NPC"
  value = "#{actor}: #{value}"
  npc_context << value unless npc_context.include?(value)
  $game_temp.dialog_context[npc_context_key] = npc_context
end

def get_npc_context(event_id)
  npc_context_key = getNPCContextKey(event_id)
  return $game_temp.dialog_context[npc_context_key] if npc_context_key
end

#===============================================================================
# ** Window_AdvancedTextPokemon extensions
#    Intercepts text display to save dialog context, and runs finalizer when done
#===============================================================================
class Window_AdvancedTextPokemon
  alias _remoteNPCDialog_setText_original setText
  def setText(value)
    _remoteNPCDialog_setText_original(value)
    return unless Settings::REMOTE_NPC_DIALOG
    return if value.nil? || value.empty? || !$PokemonTemp.speechbubble_bubble

    # Initialize dialog_context if needed
    $game_temp.dialog_context ||= {}

    event_id = $game_temp.talking_npc_id
    return unless event_id

    add_npc_context(event_id, value, false)
    echoln $game_temp.dialog_context
  end

  alias _remoteNPCDialog_dispose_original dispose
  def dispose
    _remoteNPCDialog_dispose_original
  end
end

#===============================================================================
# ** Interpreter extensions
#    Sets up active_event_finalizer when an event starts
#===============================================================================
class Interpreter
  alias _remoteNPCDialog_setup setup
  def setup(list, event_id, map_id = nil)
    _remoteNPCDialog_setup(list, event_id, map_id)
    return unless Settings::REMOTE_NPC_DIALOG

    if event_id > 0 && map_id
      return unless $game_map.events[@event_id]
      return unless $game_map.events[@event_id].trigger
      return unless $game_map.events[@event_id].trigger < 3
      $game_temp.talking_npc_id = event_id
      return unless $game_temp.talking_npc_id
      # Prepare finalizer for end-of-event
      $game_temp.active_event_finalizer = Proc.new {
        extraDialogPrompt(event_id)
        $game_temp.talking_npc_id = nil
      }
    end
  end

  alias _remoteNPCDialog_command_end command_end
  def command_end
    _remoteNPCDialog_command_end
    # Run finalizer once when the event’s interpreter finishes
    return unless @event_id == $game_temp.talking_npc_id

    if $game_temp.active_event_finalizer
      $game_temp.active_event_finalizer.call
      $game_temp.active_event_finalizer = nil
    end
  end
end



def extraDialogPrompt(event_id)
  return unless Settings::REMOTE_NPC_DIALOG
  return unless $game_temp.dialog_context
  npc_context_key = getNPCContextKey(event_id)
  npc_context = $game_temp.dialog_context[npc_context_key]
  return unless npc_context

  cmd_leave = _INTL("See ya!")
  cmd_talk = _INTL("Say something")
  commands = [cmd_leave, cmd_talk]
  choice = optionsMenu(commands)

  case commands[choice]
  when cmd_talk
    text = pbEnterText(_INTL("What do you want to say?"),0,100)
    add_npc_context(event_id, text, true)
    response = getRemoteNPCResponse(event_id)
    add_npc_context(event_id, response, false)
    extraDialogPrompt(event_id)
  else
  end
end
