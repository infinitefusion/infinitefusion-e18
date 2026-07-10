def validate_regirock_ice_puzzle(solution)
  for boulder_position in solution
    x = boulder_position[0]
    y = boulder_position[1]
    # echoln ""
    # echoln x.to_s + ", " + y.to_s
    # echoln $game_map.event_at_position(x,y)
    return false if !$game_map.event_at_position(x, y)
  end
  echoln "all boulders in place"
  return true
end

def unpress_all_regirock_steel_switches()
  switch_ids = [75, 77, 76, 67, 74, 68, 73, 72, 70, 69]
  regi_map = 813
  switch_ids.each do |event_id|
    pbSetSelfSwitch(event_id, "A", false, regi_map)
  end
end

def validate_regirock_steel_puzzle()
  expected_pressed_switches = [75, 77, 74, 68, 73, 69]
  expected_unpressed_switches = [76, 67, 72, 70]
  switch_ids = [75, 77, 76, 67,
                74, 68,
                73, 72, 70, 69]

  pressed_switches = []
  unpressed_switches = []
  switch_ids.each do |switch_id|
    is_pressed = pbGetSelfSwitch(switch_id, "A")
    if is_pressed
      pressed_switches << switch_id
    else
      unpressed_switches << switch_id
    end
  end

  for event_id in switch_ids
    is_pressed = pbGetSelfSwitch(event_id, "A")
    return false if !is_pressed && expected_pressed_switches.include?(event_id)
    return false if is_pressed && expected_unpressed_switches.include?(event_id)
  end
  return true
end

def registeel_ice_press_switch(letter)
  order = pbGet(VAR_REGI_PUZZLE_SWITCH_PRESSED)
  solution = "ssBSBGG" # GGSBBss"
  registeel_ice_reset_switches() if !order.is_a?(String)
  order << letter
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, order)
  if order == solution
    echoln "OK"
    pbMEPlay("evolution_start", nil, 130)
  elsif order.length >= solution.length
    registeel_ice_reset_switches()
  end
  echoln order
end

def registeel_ice_reset_switches()
  switches_events = [66, 78, 84, 85, 86, 87, 88]
  switches_events.each do |switch_id|
    pbSetSelfSwitch(switch_id, "A", false)
    echoln "reset" + switch_id.to_s
  end
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, "")
end

def regirock_steel_move_boulder()

  switches_position = [
    [16, 21], [18, 21], [20, 21], [22, 21],
    [16, 23], [22, 23],
    [16, 25], [18, 25], [20, 25], [22, 25]
  ]
  boulder_event = get_self
  old_x = boulder_event.x
  old_y = boulder_event.y
  stepped_off_switch = switches_position.find { |position| position[0] == old_x && position[1] == old_y }

  pbPushThisBoulder()
  boulder_event = get_self

  if stepped_off_switch
    switch_event = $game_map.get_event_at_position(old_x, old_y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door", nil, 80)
    pbSetSelfSwitch(switch_event.id, "A", false) if switch_event
  end

  stepped_on_switch = switches_position.find { |position| position[0] == boulder_event.x && position[1] == boulder_event.y }
  if stepped_on_switch
    switch_event = $game_map.get_event_at_position(boulder_event.x, boulder_event.y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door")
    pbSetSelfSwitch(switch_event.id, "A", true) if switch_event
  end
end
