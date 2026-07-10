def showQuestMap
  QuestMap.new
end

class QuestMap < BetterRegionMap
  attr_reader :reopen_map
  QUEST_SIDE_ICON_PATH = "Graphics/Pictures/map/quest_icon"
  QUEST_MAIN_ICON_PATH = "Graphics/Pictures/map/quest_icon_main"
  QUEST_AQUA_ICON_PATH = "Graphics/Pictures/map/quest_icon_aqua"
  QUEST_MAGMA_ICON_PATH = "Graphics/Pictures/map/quest_icon_magma"
  QUEST_ROCKET_ICON_PATH = "Graphics/Pictures/map/quest_icon_rocket"
  QUEST_COMPLETED_ICON_PATH = "Graphics/Pictures/map/quest_icon_completed"

  def initialize
    @quests = {}
    @spots = {}
    @popup = nil
    @snapping = false
    @previous_position = [0, 0]
    @show_completed=false
    @show_in_progress =true
    super(nil, false, false, false, nil, nil, false)
  end

  def after_init_graphics
    @window["player"].visible = false
  end

  def init_cursor_position(x, y)
    super(x, y)
    on_hover(*getPlayerPosition)
  end

  def initialize_quests_locations(show_in_progress, show_completed)
    $Trainer.quests.each do |quest|
      next if quest.completed && !show_completed
      next if !quest.completed && !show_in_progress

      position = [0, 0] # default
      if quest.location_map_id
        position = getTownMapFlyCoordinates(quest.location_map_id)
      else
        if DEFAULT_QUEST_MAP_LOCATIONS.include?(quest.id)
          position = getTownMapFlyCoordinates(DEFAULT_QUEST_MAP_LOCATIONS[quest.id])
        end
      end
      quests_at_location = @quests[position]
      quests_at_location = [] if quests_at_location.nil?
      quests_at_location << quest
      @quests[position] = quests_at_location
      @spots[position] = quests_at_location # Unused, but the map checks positions in there to see if it should snap to a new location
    end
  end

  def add_map_icons
    initialize_quests_locations(true, false)
    @quests.each_key do |position|
      quests_list = @quests[position]

      if quests_list.all?(&:completed)
        add_map_icon_at_position(position, position, QUEST_COMPLETED_ICON_PATH)
        next
      end

      icon_path = QUEST_SIDE_ICON_PATH
      has_rocket = false
      has_magma  = false
      has_aqua   = false

      quests_list.each do |quest|
        case quest.type
        when :MAIN_QUEST
          icon_path = QUEST_MAIN_ICON_PATH
          break
        when :ROCKET_QUEST then has_rocket = true
        when :MAGMA_QUEST  then has_magma  = true
        when :AQUA_QUEST   then has_aqua   = true
        end
      end

      unless icon_path == QUEST_MAIN_ICON_PATH
        if    has_rocket then icon_path = QUEST_ROCKET_ICON_PATH
        elsif has_magma  then icon_path = QUEST_MAGMA_ICON_PATH
        elsif has_aqua   then icon_path = QUEST_AQUA_ICON_PATH
        end
      end

      add_map_icon_at_position(position, position, icon_path)
    end
  end

  def on_hover(x, y)
    quests_at_pos = @quests[[x, y]]
    if quests_at_pos && !quests_at_pos.empty?
      snap_to_position(x, y)
      show_popup(quests_at_pos)
    else
      hide_popup
    end
  end

  def on_start_moving
  end

  def on_stop_moving
    return if @snapping
    x = $PokemonGlobal.regionMapSel[0]
    y = $PokemonGlobal.regionMapSel[1]
    if @quests.has_key?([x, y])
      on_hover(x, y)
      return
    end

    nearby_quest = find_quest_near_coordinates(x, y, 2)
    if nearby_quest
      @snapping = true
      new_x, new_y = nearby_quest
      if [new_x, new_y] != @position_before_moving
        snap_to_position(new_x, new_y)
        on_hover(new_x, new_y)
      end
      @snapping = false
    end
  end

  def find_quest_near_coordinates(current_x, current_y, radius)
    closest = nil
    min_distance = Float::INFINITY
    for new_x in current_x - radius..current_x + radius
      for new_y in current_y - radius..current_y + radius
        if @quests.has_key?([new_x, new_y])
          distance = Math.sqrt((new_x - current_x) ** 2 + (new_y - current_y) ** 2)
          if distance < min_distance
            min_distance = distance
            closest = [new_x, new_y]
          end
        end
      end
    end
    return closest
  end

  def on_click(x, y)
    return unless @popup
    quest = @popup.run
    if quest
      @popup = nil
      @sprites.visible = false
      @window.visible = false
      Questlog.new(open_quest: quest, from_map: true)
      @sprites.visible = true
      @window.visible = true
      @viewport.visible = true
      @viewport2.visible = true
      @mapvp.visible = true
      @mapoverlayvp.visible = true
      Graphics.update
      x, y = $PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]
      on_hover(x, y)
      #@popup&.set_selected(true)
      @popup&.refresh
    end
  end

  def show_popup(quests)
    return unless @sprites["cursor"]
    return if @popup&.quests == quests #popup already active
    return if @popup && @popup.panel_active
    location_name = get_current_location_name
    hide_popup
    on_right_half = @sprites["cursor"].x > (Graphics.width / 2)
    @popup = QuestMapPopup.new(quests, on_right_half, @viewport2, location_name)
    pbWait(4)
  end

  def should_exit_confirm?
    return false
  end

  def on_exit_main
    @reopen_map = false
    if @switch_to_questlog
      @switch_to_questlog = false
      @reopen_map = true
    end
  end

  def should_exit_cancel?
    return true if @switch_to_questlog
    return false if @popup && @popup.panel_active
    return Input.trigger?(Input::B)
  end

  def on_update
    if Input.trigger?(Input::L) || Input.trigger?(Input::R)
      pbSEPlay("GUI storage show party panel")
      $Trainer.pokenav.last_opened_quest_mode = :LIST
      @switch_to_questlog = true
    end
  end


  def hide_popup
    return unless @popup
    @popup.animate_out
    @popup.dispose
    @popup = nil
  end

  def dispose
    hide_popup
    super
  end

  def update_text_at_location(location)
    current_position = [$PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]]
    quests_at_location = @quests[current_position]
    nb_quests_at_position = 0
    nb_quests_at_position = @quests[current_position].length if quests_at_location
    text = ""
    text = pbGetMessageFromHash(MessageTypes::PlaceNames, location[2]) if location

    nb_quests_text = ""
    if nb_quests_at_position > 1
      nb_quests_text = _INTL("{1} quests in progress", nb_quests_at_position)
    elsif nb_quests_at_position > 0
      nb_quests_text = _INTL("{1} quest in progress", nb_quests_at_position)
    end
    @sprites["txt"].draw([
                           [_INTL("Quest Log"), 24, -8, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [_INTL("L/R : LIST"), 360, -8, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [text, 16, 344, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [nb_quests_text, 496, 344, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                         ], true)
  end

  def open_quest_detail(quest)
    dispose
    Questlog.new(open_quest: quest)
  end
end


#For quests recorded before QuestMap existed, so that they don't show up at [0,0]
DEFAULT_QUEST_MAP_LOCATIONS = {

  # Main quests
  "main_dad"        => MAP_PETALBURG,
  "main_wally"      => MAP_PETALBURG,

  "main_gym_1"      => MAP_RUSTBORO,
  "main_gym_2"      => MAP_DEWFORD,
  "main_gym_3"      => MAP_MAUVILLE,
  "main_gym_4"      => MAP_LAVARIDGE,
  "main_gym_5"      => MAP_PETALBURG,
  "main_gym_6"      => MAP_FORTREE,
  "main_gym_7"      => MAP_MOSSDEEP,
  "main_gym_8"      => MAP_SOOTOPOLIS,

  "main_league"     => MAP_LEAGUE,

  "main_stolen_parts"   => MAP_RUSTBORO,
  "main_steven_letter"  => MAP_DEWFORD,
  "main_devon_parts"    => MAP_SLATEPORT,

  "slateport_team_aqua" => MAP_AQUA_CAMP,
  "slateport_team_magma"=> MAP_MAGMA_CAMP,

  "evergrande_trumpet"  => MAP_EVERGRANDE,

  "route_102_rematch"     => MAP_ROUTE_102,
  "route104_rivalWeather" => MAP_ROUTE_104,
  "route104_oricorio"     => MAP_ROUTE_104,
  "route104_oricorio_forms" => MAP_ROUTE_104,
  "route104_allergic"     => MAP_ROUTE_104,
  "route109_tanning"      => MAP_ROUTE_109,
  "route109_seahouse"     => MAP_ROUTE_109,
  "route109_beachball"    => MAP_ROUTE_109,
  "route110_bike"         => MAP_ROUTE_110,
  "route111_winstrate"    => MAP_ROUTE_111,
  "route115_secretBase"   => MAP_ROUTE_115,
  "route116_glasses"      => MAP_ROUTE_116,

  # Town/City quests
  "petalburg_berry"       => MAP_PETALBURG,
  "rustboro_whismur"      => MAP_RUSTBORO,
  "rustboro_shiny"        => MAP_RUSTBORO,
  "rustboro_trash"        => MAP_RUSTBORO,
  "rustboro_fusion"       => MAP_RUSTBORO,
  "dewford_fishing"       => MAP_DEWFORD,
  "mauville_quests_1"     => MAP_MAUVILLE,
  "mauville_quests_2"     => MAP_MAUVILLE,
  "mauville_quests_3"     => MAP_MAUVILLE,
  "mauville_quests_4"     => MAP_MAUVILLE,
  "mauville_quests_5"     => MAP_MAUVILLE,
  "mauville_quests_6"     => MAP_MAUVILLE,
  "mauville_quests_7"     => MAP_MAUVILLE,
  "verdanturf_shroomish"  => MAP_VERDANTURF,
  "verdanturf_nurse"      => MAP_VERDANTURF,

  # Dungeon/Area quests
  "petalburgwoods_spores" => MAP_PETALBURG_WOODS,
  "rusturf_trumpet"       => MAP_RUSTURF_TUNNEL,

  # Team Magma quests
  "magma_camp_attack"     => MAP_MAGMA_CAMP,
  "magma_slugma_eggs"     => MAP_MAGMA_CAMP,
  "magma_help_grunts"     => MAP_MAGMA_CAMP,
  "magma_numel"           => MAP_MAGMA_CAMP,
  "magma_graffiti"        => MAP_MAGMA_CAMP,
  "magma_song"            => MAP_MAGMA_CAMP,

  # Team Aqua quests
  "aqua_camp_attack"      => MAP_AQUA_CAMP,
  "aqua_wailmer_eggs"     => MAP_AQUA_CAMP,
  "aqua_help_grunts"      => MAP_AQUA_CAMP,
  "aqua_carvanha"         => MAP_AQUA_CAMP,
  "aqua_graffiti"         => MAP_AQUA_CAMP,
  "aqua_song"             => MAP_AQUA_CAMP,

  # Mauville team quests
  "mauville_magma"        => MAP_MAUVILLE,
  "mauville_aqua"         => MAP_MAUVILLE,
}
