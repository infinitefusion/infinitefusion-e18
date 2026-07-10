#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click F, #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
                         :name => "Better Fast-forward Mode",
                         :version => "1.1",
                         :credits => "Marin",
                         :link => "https://reliccastle.com/resources/151/"
                       })

# When the user clicks F, it'll pick the next number in this array.
SPEEDUP_STAGES = [1, 2, 3]

def pbAllowSpeedup
  $CanToggle = true
end

def pbDisallowSpeedup
  $CanToggle = false
end

# Default game speed.
$GameSpeed = 0
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    # if $DEBUG && Input.trigger?(Input::AUX1)
    #   spawn_random_overworld_pokemon_group
    # end

    if $CanToggle && Input.trigger?(Input::X)
      $GameSpeed += 1
      $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
    end
    $frame += 1
    if $PokemonSystem && $PokemonSystem.speedup == 1
      speedStage = SPEEDUP_STAGES[$GameSpeed]
    else
      speedStage = 1
      if Input.press?(Input::X) && $CanToggle
        speedStage = self.get_speedup_speed + 1
      end
    end
    return unless $frame % speedStage == 0
    fast_forward_update
    $frame = 0
  end

  #TODO: For compatibility with set controls screen
  # def self.update
  #   if $CanToggle && Input.trigger?(Input::AUX3)
  #     $GameSpeed += 1
  #     $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
  #   end
  #   $frame += 1
  #   if $PokemonSystem && $PokemonSystem.speedup == 1
  #     speedStage = SPEEDUP_STAGES[$GameSpeed]
  #   else
  #     speedStage = 1
  #     if Input.press?(Input::AUX3) && $CanToggle
  #       speedStage = self.get_speedup_speed + 1
  #     end
  #   end
  #   return unless $frame % speedStage == 0
  #   fast_forward_update
  #   $frame = 0
  # end


  def self.get_speedup_speed
    $PokemonSystem.speedup_speed = Settings::DEFAULT_SPEED_UP_SPEED if !$PokemonSystem.speedup_speed || $PokemonSystem.speedup_speed == 0
    $PokemonSystem.speedup_speed_battles = Settings::DEFAULT_SPEED_UP_SPEED if !$PokemonSystem.speedup_speed_battles || $PokemonSystem.speedup_speed_battles == 0

    if $game_temp.in_battle
      return $PokemonSystem.speedup_speed_battles
    else
      return $PokemonSystem.speedup_speed
    end
  end
end