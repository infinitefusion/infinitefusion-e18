DEFAULT_AMBIENT_VOLUME = 40


Events.onStepTakenFieldMovement += proc { |_sender, e|
  next unless Settings::EXPERIMENTAL_FEATURES
  event = e[0]
  next unless event == $game_player
  nearby_ambient_sounds = scan_for_ambient_sounds
  if nearby_ambient_sounds.size > 0
    sound, volume = nearby_ambient_sounds.min_by { |sound, volume| volume }
    pbBGSPlay(sound, volume)
  else
    pbBGSFade(2)
    restore_weather_ambient_sounds
  end
}

AMBIENT_SOUND_SCAN_RADIUS = 5
AMBIENT_SOUND_SCAN_OFFSETS = (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).flat_map { |dx|
  (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).map { |dy| [dx, dy, dx.abs + dy.abs] }
}.select { |_dx, _dy, dist| dist <= AMBIENT_SOUND_SCAN_RADIUS }
                                                                                    .sort_by { |_dx, _dy, dist| dist }
                                                                                    .freeze

def scan_for_ambient_sounds
  map = $MapFactory.getMapNoAdd($game_map.map_id)
  return [] if !map

  px = $game_player.x
  py = $game_player.y
  best_sound = nil
  best_priority = nil
  best_distance = nil

  AMBIENT_SOUND_SCAN_OFFSETS.each do |dx, dy, distance|
    terrain_tag = map.terrain_tag(px + dx, py + dy, true)
    next unless terrain_tag&.ambient_sound
    priority = terrain_tag.ambient_sound_priority

    next if best_priority && best_priority >= priority

    best_sound = terrain_tag.ambient_sound
    best_priority = priority
    best_distance = distance
  end

  return [] if best_sound.nil?
  return [[best_sound, calculate_ambient_sound_volume(best_distance)]]
end

def calculate_ambient_sound_volume(distance_from_player)
  return DEFAULT_AMBIENT_VOLUME - (5 * distance_from_player)
end


def calculate_distance_from_player(x, y)
  dx = (x - $game_player.x).abs
  dy = (y - $game_player.y).abs
  return dx + dy
end