##=============================================================================
##  Easy Questing System - Refactored with Extensible Mode System
##  Original by M3rein
#   Refactored using by Claude
#   Adapted for Pokemon Infinite Fusion by chardub
##=============================================================================
##  Main entry point for the quest log
##=============================================================================

def pbQuestlog
  ensure_quests_repaired
  loop do
    if $Trainer&.pokenav&.last_opened_quest_mode == :LIST || Settings::KANTO
      ql = Questlog.new
      break unless ql.switch_to_map
      $Trainer&.pokenav&.last_opened_quest_mode = :MAP
    else
      qm = showQuestMap
      break unless qm&.reopen_map
      $Trainer&.pokenav&.last_opened_quest_mode = :LIST
    end
  end
end

def ensure_quests_repaired
  return if $Trainer.quests_repaired
  fix_quest_ids
  $Trainer.quests_repaired = true
end

##=============================================================================
##  QuestSprite - Sprite class for quest list items
##=============================================================================

class QuestSprite < IconSprite
  attr_accessor :quest
end

##=============================================================================
##  QuestMode - Base class for quest filtering modes
##=============================================================================

class QuestCategory
  attr_reader :name, :button_text
  attr_accessor :last_index
  def initialize(name, button_text)
    @name = name
    @button_text = button_text
    @last_index = 0
  end

  # Override this method to define filtering logic
  def filter_quests(all_quests)
    raise NotImplementedError, "Subclasses must implement filter_quests"
  end

  # Override to customize empty message
  def empty_message
    "No quests"
  end

  # Override to customize title
  def title
    @name
  end
end

##=============================================================================
##  Built-in Quest Modes
##=============================================================================


class CompletedQuestMode < QuestCategory
  def initialize
    super("Completed Quests", "Completed")
  end
  def button_path
    return "Graphics/Pictures/eqi/quest_button_complete"
  end

  def filter_quests(all_quests)
    all_quests.select { |q| q.completed }
  end

  def empty_message
    _INTL("No completed quests")
  end
end


class MainQuestMode < QuestCategory
  def initialize
    super("Main Quests", "Main Quests")
  end

  def button_path
    return "Graphics/Pictures/eqi/quest_button_main"
  end
  def filter_quests(all_quests)
    return all_quests.select { |q| !q.completed && q.type == :MAIN_QUEST }
  end

  def empty_message
    _INTL("No ongoing main quests")
  end
end

class SideQuestMode < QuestCategory
  def initialize
    super("Side Quests", "Side Quests")
  end

  def button_path
    return "Graphics/Pictures/eqi/quest_button_side"
  end

  def filter_quests(all_quests)
    return all_quests.select { |q| !q.completed && q.type != :MAIN_QUEST }
  end

  def empty_message
    _INTL("No side quests")
  end
end

# class LocationQuestMode < QuestMode
#   attr_reader :location
#
#   def initialize(location)
#     @location = location
#     super("#{location} Quests", location)
#   end
#
#   def filter_quests(all_quests)
#     return all_quests.select { |q| !q.completed && q.location.include?(@location) }
#   end
#
#   def empty_message
#     _INTL("No quests in {1}", @location)
#   end
# end

##=============================================================================
##  Questlog - Main quest interface controller (Refactored)
##=============================================================================

class Questlog
  attr_reader :switch_to_map
  # Scene constants
  SCENE_MAIN = 0
  SCENE_LIST = 1
  SCENE_DETAIL = 2

  # UI constants
  MAX_VISIBLE_QUESTS = 6
  FADE_SPEED = 32
  ANIMATION_FRAMES = 12
  CHAR_ANIMATION_INTERVAL = 6

  def initialize(open_quest: nil, from_map: false)
    @from_map = from_map
    @switch_to_map = false
    initialize_data
    initialize_modes
    initialize_viewport

    if open_quest
      create_sprites(false)
      setup_open_quest(open_quest)
    else
      create_sprites(false)
      animate_intro
    end
    main_loop
    cleanup
  end

  private

  ##---------------------------------------------------------------------------
  ##  Initialization
  ##---------------------------------------------------------------------------

  def setup_open_quest(quest)
    @skip_menu = true

    # Find which mode contains this quest
    @current_mode = @modes.find { |mode| mode.filter_quests($Trainer.quests).include?(quest) }

    # Fall back to first mode if not found (e.g. completed quests shown via direct open)
    @current_mode ||= @modes.first

    @filtered_quests = @current_mode.filter_quests($Trainer.quests)
    @quest_list_menu_index = @filtered_quests.index(quest) || 0
    @box = 0

    # Jump straight to detail view
    @scene = SCENE_DETAIL
    create_detail_background
    create_character_sprite("char", quest, 62, 130)
    draw_quest_details(quest)
    animate_detail_in
  end

  def initialize_data
    $Trainer.quests = [] if $Trainer.quests.nil?

    @page = 0
    @main_menu_index = 0
    @quest_list_menu_index = 0
    @scene = SCENE_MAIN
    @current_mode = nil
    @box = 0          # Visible quest index (0-5)
    @frame = 0
    @filtered_quests = []

    @scroll_timer = 12   # Cooldown counter for holding up/down
    @scroll_delay = 6   # Frames to wait before repeating movement

    fix_broken_TR_quests
  end

  def initialize_modes
    # Register all available modes here
    @modes = []
    @modes << MainQuestMode.new if Settings::HOENN
    @modes << SideQuestMode.new
    @modes << CompletedQuestMode.new

    # You can dynamically add location-based modes:
    # @modes << LocationQuestMode.new("Cerulean City")
    # @modes << LocationQuestMode.new("Viridian Forest")
  end

  def initialize_viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100002
    @sprites = {}
  end

  def create_sprites(main_page = true)
    create_main_bitmap
    create_background
    create_mode_buttons #if main_page
    draw_main_text
  end

  def create_main_bitmap
    @sprites["main"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["main"].z = 1
    @sprites["main"].opacity = 0
    @main = @sprites["main"].bitmap
    pbSetSystemFont(@main)
  end

  def create_background
    @sprites["bg0"] = IconSprite.new(0, 0, @viewport)
    bg_path = isDarkMode ?
                "Graphics/Pictures/Pokegear/bg_dark" :
                "Graphics/Pictures/Pokegear/bg"
    @sprites["bg0"].setBitmap(bg_path)
    @sprites["bg0"].opacity = 0
  end

  def create_mode_buttons
    default_button_path = "Graphics/Pictures/eqi/quest_button"
    @modes.size.times do |i|
      @sprites["btn#{i}"] = IconSprite.new(0, 0, @viewport)
      button_path = @modes[i].button_path
      if button_path
        @sprites["btn#{i}"].setBitmap(button_path)
      else
        @sprites["btn#{i}"].setBitmap(default_button_path)
      end
      @sprites["btn#{i}"].x = 84
      @sprites["btn#{i}"].y = 130 + 56 * i
      @sprites["btn#{i}"].src_rect.height = (@sprites["btn#{i}"].bitmap.height / 2).round
      @sprites["btn#{i}"].src_rect.y = i == 0 ? (@sprites["btn#{i}"].bitmap.height / 2).round : 0
      @sprites["btn#{i}"].opacity = 0
    end
  end

  def draw_main_text
    pbDrawOutlineText(@main, -160, 8, 512, 384, _INTL("Quest Log"),
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    if can_switch_mode?
      pbDrawOutlineText(@main, 160, 8, 512, 384, _INTL("L/R : MAP"),
                        Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    end


      # Draw button labels and quest counts
    @modes.each_with_index do |mode, i|
      quest_count = mode.filter_quests($Trainer.quests).size
      y_pos = 142 + (56 * i)
      pbDrawOutlineText(@main, 0, y_pos, 512, 384,
                        _INTL("{1}: {2}", mode.button_text, quest_count),
                        Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    end
  end

  def animate_intro
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"]&.opacity += FADE_SPEED if i < 8

      # Fade in all mode buttons
      @modes.size.times do |j|
        @sprites["btn#{j}"]&.opacity += FADE_SPEED if i > 3
      end

      @sprites["main"]&.opacity += 64 if i > 7
    end
  end

  ##---------------------------------------------------------------------------
  ##  Main Loop
  ##---------------------------------------------------------------------------

  def main_loop
    @frame = 0

    loop do
      @frame += 1
      Graphics.update
      Input.update

      break if handle_input
      @frame = 0 if @frame == 18
    end
  end

  def handle_input
    case @scene
    when SCENE_MAIN
      return handle_main_input
    when SCENE_LIST
      return handle_list_input
    when SCENE_DETAIL
      return handle_detail_input
    end
    return false
  end

  def handle_main_input
    if (Input.trigger?(Input::L) || Input.trigger?(Input::R)) && can_switch_mode?
      @switch_to_map = true
      pbSEPlay("GUI storage show party panel")
      $Trainer&.pokenav&.last_opened_quest_mode = :MAP
      return true
    end
    return true if Input.trigger?(Input::B)

    if Input.trigger?(Input::C)
      show_quest_list(@main_menu_index)
    end
    if @scroll_timer > 0
      @scroll_timer -= 1
    else
      if Input.press?(Input::DOWN)
        switch_button(:DOWN)
        @scroll_timer = @scroll_delay
      elsif Input.press?(Input::UP)
        switch_button(:UP)
        @scroll_timer = @scroll_delay
      end
    end

    false
  end

  def can_switch_mode?
    return Settings::HOENN && (@scene != SCENE_DETAIL)
  end

  def handle_list_input
    if (Input.trigger?(Input::L) || Input.trigger?(Input::R)) && can_switch_mode?
      @switch_to_map = true
      return true
    end
    if Input.trigger?(Input::B)
      return_to_main
    elsif Input.trigger?(Input::C)
      show_quest_detail
    else
      handle_scroll_input
    end
    animate_arrows
    return false
  end

  def handle_scroll_input
    # Only scroll when timer allows
    if @scroll_timer > 0
      @scroll_timer -= 1
      return
    end

    if Input.press?(Input::DOWN)
      move_selection(:DOWN)
      @scroll_timer = @scroll_delay
    elsif Input.press?(Input::UP)
      move_selection(:UP)
      @scroll_timer = @scroll_delay
    end
  end


  def handle_detail_input
    if Input.trigger?(Input::B)
      return true
    end
    animate_character if [6, 12, 18].include?(@frame)
    return false
  end

  ##---------------------------------------------------------------------------
  ##  Navigation
  ##---------------------------------------------------------------------------

  def update_button_selection(index, selected)
    return unless @sprites["btn#{index}"]
    height = (@sprites["btn#{index}"].bitmap.height / 2).round
    @sprites["btn#{index}"].src_rect.y = selected ? height : 0
  end

  def switch_button(dir)
    max_index = @modes.size - 1
    if dir == :DOWN
      return if @main_menu_index >= max_index
      update_button_selection(@main_menu_index, false)
      @main_menu_index += 1
      update_button_selection(@main_menu_index, true)
    else
      return if @main_menu_index <= 0
      update_button_selection(@main_menu_index, false)
      @main_menu_index -= 1
      update_button_selection(@main_menu_index, true)
    end
  end


  def move_selection(dir)
    return if @filtered_quests.empty?

    if dir == :DOWN
      return if @quest_list_menu_index == @filtered_quests.size - 1

      deselect_current_quest
      @quest_list_menu_index += 1
      @box += 1
      @box = 5 if @box > 5
      select_current_quest

      refresh_quest_list if @box == 5
    else
      return if @quest_list_menu_index == 0

      deselect_current_quest
      @quest_list_menu_index -= 1
      @box -= 1
      @box = 0 if @box < 0
      select_current_quest

      refresh_quest_list if @box == 0
    end

    #pbWait(4)
  end

  def deselect_current_quest
    @sprites["quest#{@box}"].src_rect.y = 0 if @sprites["quest#{@box}"]
  end

  def select_current_quest
    if @sprites["quest#{@box}"]
      @sprites["quest#{@box}"].src_rect.y = (@sprites["quest#{@box}"].bitmap.height / 2).round
    end
  end

  ##---------------------------------------------------------------------------
  ##  Scene Transitions
  ##---------------------------------------------------------------------------

  def return_to_main
    pbWait(1)
    dispose_quest_list_sprites
    fade_to_main
    reset_list_state
    redraw_main_screen
    animate_main_return
  end

  def fade_to_main
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      fade_sprites_out(i)
    end

    dispose_list_sprites
    clear_bitmaps
  end

  def fade_sprites_out(index)
    @sprites["main"].opacity -= FADE_SPEED if @sprites["main"]
    @sprites["bg0"].opacity += FADE_SPEED if @sprites["bg0"].opacity < 255

    if index > 3
      @sprites["bg1"].opacity -= FADE_SPEED if @sprites["bg1"]
      @sprites["bg2"].opacity -= FADE_SPEED if @sprites["bg2"]
      @sprites["pager"].opacity -= FADE_SPEED if @sprites["pager"]
      @sprites["pager2"].opacity -= FADE_SPEED if @sprites["pager2"]
    end

    @sprites["char"].opacity -= FADE_SPEED if @sprites["char"]
    @sprites["char2"].opacity -= FADE_SPEED if @sprites["char2"]
    @sprites["text"].opacity -= FADE_SPEED if @sprites["text"]
    @sprites["up"].opacity -= FADE_SPEED if @sprites["up"]
    @sprites["down"].opacity -= FADE_SPEED if @sprites["down"]

    fade_quest_sprites
  end

  def fade_quest_sprites
    MAX_VISIBLE_QUESTS.times do |i|
      @sprites["quest#{i}"].opacity -= FADE_SPEED if @sprites["quest#{i}"]
    end
  end

  def dispose_list_sprites
    @sprites["up"].dispose if @sprites["up"]
    @sprites["down"].dispose if @sprites["down"]
  end

  def clear_bitmaps
    @main.clear if @main
    @text.clear if @text
    @text2.clear if @text2
  end

  def reset_list_state
    @scene = SCENE_MAIN
  end

  def redraw_main_screen
    pbDrawOutlineText(@main, 0, 2, 512, 384, _INTL("Quest Log"),
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    @modes.each_with_index do |mode, i|
      quest_count = mode.filter_quests($Trainer.quests).size
      y_pos = 142 + (56 * i)
      pbDrawOutlineText(@main, 0, y_pos, 512, 384,
                        _INTL("{1}: {2}", mode.button_text, quest_count),
                        Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    end
  end

  def animate_main_return
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED if i < 8

      @modes.size.times do |j|
        @sprites["btn#{j}"].opacity += FADE_SPEED if i > 3
      end

      @sprites["main"].opacity += 48 if i > 5
    end
  end

  ##---------------------------------------------------------------------------
  ##  Quest List Display
  ##---------------------------------------------------------------------------

  def show_quest_list(mode_index)
    pbWait(2)
    @scene = SCENE_LIST
    @current_mode = @modes[mode_index]

    @quest_list_menu_index = @current_mode.last_index
    @box = [@quest_list_menu_index, MAX_VISIBLE_QUESTS - 1].min
    @filtered_quests = @current_mode.filter_quests($Trainer.quests)

    create_arrow_sprites
    fade_to_list
    clear_bitmaps
    display_quest_list
  end


  def create_arrow_sprites
    @sprites["up"] = create_arrow(36, false)
    @sprites["down"] = create_arrow(360, true)
    @sprites["down"].visible = @filtered_quests.size > MAX_VISIBLE_QUESTS
    @sprites["down"].opacity = 0
  end

  def create_arrow(y_pos, flip)
    arrow = IconSprite.new(0, 0, @viewport)
    arrow.setBitmap("Graphics/Pictures/EQI/quest_arrow")
    arrow.zoom_x = 1.25
    arrow.zoom_y = 1.25
    arrow.x = Graphics.width / 2 + (flip ? 21 : 0)
    arrow.y = y_pos
    arrow.z = 2
    arrow.angle = flip ? 180 : 0
    arrow.visible = false
    arrow
  end

  def fade_to_list
    10.times do |i|
      Graphics.update

      if i > 1
        @modes.size.times do |j|
          @sprites["btn#{j}"].opacity -= FADE_SPEED
        end
        @sprites["main"].opacity -= FADE_SPEED
        fade_detail_sprites
      end
    end
  end

  def fade_detail_sprites
    @sprites["bg1"].opacity -= FADE_SPEED if @sprites["bg1"]
    @sprites["bg2"].opacity -= FADE_SPEED if @sprites["bg2"]
    @sprites["pager"].opacity -= FADE_SPEED if @sprites["pager"]
    @sprites["pager2"].opacity -= FADE_SPEED if @sprites["pager2"]
    @sprites["char"].opacity -= FADE_SPEED if @sprites["char"]
    @sprites["char2"].opacity -= FADE_SPEED if @sprites["char2"]
    @sprites["text"].opacity -= FADE_SPEED if @sprites["text"]
    @sprites["text2"].opacity -= FADE_SPEED if @sprites["text2"]
  end

  def display_quest_list
    [@filtered_quests.size, MAX_VISIBLE_QUESTS].min.times do |i|
      create_quest_sprite(i, @filtered_quests[i])
      draw_quest_name_on_main(i, @filtered_quests[i])
    end

    if @filtered_quests.empty?
      pbDrawOutlineText(@main, 0, 175, 512, 384, @current_mode.empty_message,
                        pbColor(:WHITE), pbColor(:BLACK), 1)
    end

    pbDrawOutlineText(@main, 0, 2, 512, 384, @current_mode.title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    animate_quest_list
  end

  def create_quest_sprite(index, quest)
    sprite_key = "quest#{index}"
    @sprites[sprite_key] = QuestSprite.new(0, 0, @viewport)
    sprite = @sprites[sprite_key]
    sprite.setBitmap("Graphics/Pictures/EQI/quest_button")
    sprite.quest = quest
    sprite.x = 94
    sprite.y = 42 + 52 * index
    sprite.src_rect.height = (sprite.bitmap.height / 2).round
    sprite.src_rect.y = (sprite.bitmap.height / 2).round if index == @quest_list_menu_index
    sprite.opacity = 0

    draw_quest_name_on_main(index, quest)
    set_quest_list_sprite(index,quest)
  end


  def draw_quest_name_on_main(index, quest)
    y_pos = get_cell_y_position(index)
    pbDrawOutlineText(@main, 11, y_pos, 512, 384,
                      quest.name,
                      quest.default_color,
                      Color.new(0, 0, 0),
                      1)
  end

  def get_cell_y_position(index)
    56 + (52 * index)
  end

  def animate_quest_list
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["main"].opacity += FADE_SPEED if i < 8
      @sprites["down"].opacity += FADE_SPEED if i > 3

      [@filtered_quests.size, MAX_VISIBLE_QUESTS].min.times do |j|
        @sprites["quest#{j}"].opacity += FADE_SPEED if i > 3
        @sprites["quest_icon#{j}"].opacity += FADE_SPEED if i > 3  # Fade in icon
      end
    end
  end

  def set_quest_list_sprite(index, quest)
    quest_button = @sprites["quest#{index}"]
    icon_key = "quest_icon#{index}"

    if @sprites[icon_key]
      sprite = @sprites[icon_key]
      sprite.setBitmap("Graphics/Characters/#{quest.sprite}")
      sprite.x = quest_button.x - 64
      sprite.y = quest_button.y - 20
      sprite.src_rect.width = (sprite.bitmap.width / 4).round
      sprite.src_rect.height = (sprite.bitmap.height / 4).round
      sprite.src_rect.x = 0
      sprite.src_rect.y = 0
      sprite.visible = true
    else
      create_character_sprite(icon_key, quest, quest_button.x - 64, quest_button.y - 20)
    end
  end



  def refresh_quest_list
    @main.clear if @main

    MAX_VISIBLE_QUESTS.times do |i|
      quest_index = @quest_list_menu_index - @box + i
      next if quest_index < 0 || quest_index >= @filtered_quests.size

      quest = @filtered_quests[quest_index]

      # Update the quest button
      sprite = @sprites["quest#{i}"]
      sprite.quest = quest if sprite
      sprite.src_rect.y = (i == @box ? (sprite.bitmap.height / 2).round : 0) if sprite

      draw_quest_name_on_main(i, quest)
      set_quest_list_sprite(i, quest)
    end

    # Update arrow visibility
    @sprites["up"].visible = @quest_list_menu_index > 0
    @sprites["down"].visible = @quest_list_menu_index < @filtered_quests.size - 1

    # Redraw the title
    pbDrawOutlineText(@main, 0, 2, 512, 384, @current_mode.title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
  end



  ##---------------------------------------------------------------------------
  ##  Quest Detail Display
  ##---------------------------------------------------------------------------

  def dispose_quest_list_sprites
    MAX_VISIBLE_QUESTS.times do |i|
      if @sprites["quest#{i}"]
        @sprites["quest#{i}"].dispose
        @sprites.delete("quest#{i}")
      end
      if @sprites["quest_icon#{i}"]
        @sprites["quest_icon#{i}"].dispose
        @sprites.delete("quest_icon#{i}")
      end
    end
  end

  def show_quest_detail
    return if @filtered_quests.empty?
    @current_mode.last_index = @quest_list_menu_index

    dispose_quest_list_sprites
    quest = @filtered_quests[@quest_list_menu_index]
    pbWait(1)

    @scene = SCENE_DETAIL
    create_detail_background
    fade_to_detail
    create_character_sprite("char", quest, 62, 130)
    draw_quest_details(quest)
    animate_detail_in
  end


  def create_detail_background
    @sprites["bg1"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg1"].setBitmap("Graphics/Pictures/EQI/quest_page1")
    @sprites["bg1"].opacity = 0

    @sprites["pager"] = IconSprite.new(0, 0, @viewport)
    @sprites["pager"].setBitmap("Graphics/Pictures/EQI/quest_pager")
    @sprites["pager"].x = 442
    @sprites["pager"].y = 3
    @sprites["pager"].z = 1
    @sprites["pager"].opacity = 0
  end

  def fade_to_detail
    8.times do
      Graphics.update
      @sprites["up"]&.opacity -= FADE_SPEED
      @sprites["down"]&.opacity -= FADE_SPEED
      @sprites["main"]&.opacity -= FADE_SPEED
      @sprites["bg1"]&.opacity += FADE_SPEED if @sprites["bg1"]
      @sprites["pager"]&.opacity = 0 if @sprites["pager"]
      @sprites["char"]&.opacity -= FADE_SPEED if @sprites["char"]

      fade_quest_list_sprites
    end

    @sprites["up"]&.dispose
    @sprites["down"]&.dispose
  end

  def fade_quest_list_sprites
    MAX_VISIBLE_QUESTS.times do |i|
      @sprites["quest#{i}"].opacity -= FADE_SPEED if @sprites["quest#{i}"]
    end
  end

  def create_character_sprite(spriteId,quest,x,y, max_height=nil)
    @sprites[spriteId] = IconSprite.new(0, 0, @viewport)
    @sprites[spriteId].setBitmap("Graphics/Characters/#{quest.sprite}")
    @sprites[spriteId].x = x
    @sprites[spriteId].y = y
    @sprites[spriteId].src_rect.height = max_height ? max_height : (@sprites[spriteId].bitmap.height / 4).round
    @sprites[spriteId].src_rect.width = (@sprites[spriteId].bitmap.width / 4).round
    @sprites[spriteId].opacity = 0
  end

  def draw_quest_details(quest)
    @main.clear if @main
    @text.clear if @text
    @text2.clear if @text2

    pbDrawOutlineText(@main, 188, 54, 512, 384, quest.name,
                      Color.new(255, 172, 115), Color.new(0, 0, 0))
    drawTextExMulti(@main, 188, 84, 318, 8, quest.desc,
                    Color.new(255, 255, 255), Color.new(0, 0, 0))
    pbDrawOutlineText(@main, 188, 330, 512, 384, quest.location,
                      Color.new(255, 172, 115), Color.new(0, 0, 0))


    draw_completion_status(quest)
  end

  def draw_completion_status(quest)
    if quest.completed
      pbDrawOutlineText(@main, 8, 315, 512, 384, _INTL("Completed"),
                        pbColor(:LIGHTBLUE), Color.new(0, 0, 0))
    else
      pbDrawOutlineText(@main, 8, 315, 512, 384, _INTL("Not Completed"),
                        pbColor(:LIGHTRED), Color.new(0, 0, 0))
    end
  end

  def animate_detail_in
    10.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED
      @sprites["main"].opacity += FADE_SPEED
      @sprites["bg1"].opacity += FADE_SPEED if @sprites["bg1"]
      @sprites["char"].opacity += FADE_SPEED if i > 1
    end
  end

  ##---------------------------------------------------------------------------
  ##  Animations
  ##---------------------------------------------------------------------------

  def animate_arrows
    return unless @sprites["up"] && !@sprites["up"].disposed?
    return unless @sprites["down"] && !@sprites["down"].disposed?

    if [2, 4, 14, 16].include?(@frame)
      @sprites["up"].y -= 1
      @sprites["down"].y -= 1
    elsif [6, 8, 10, 12].include?(@frame)
      @sprites["up"].y += 1
      @sprites["down"].y += 1
    end
  end

  def animate_character
    ["char", "char2"].each do |char_key|
      next unless @sprites[char_key]

      sprite = @sprites[char_key]
      sprite.src_rect.x += (sprite.bitmap.width / 4).round
      sprite.src_rect.x = 0 if sprite.src_rect.x >= sprite.bitmap.width
    end
  end

  ##---------------------------------------------------------------------------
  ##  Cleanup
  ##---------------------------------------------------------------------------

  def cleanup
    if @switch_to_map
      showBlk(1)  # instant black
    else
      ANIMATION_FRAMES.times do |i|
        Graphics.update
        @sprites["bg0"].opacity -= FADE_SPEED if @sprites["bg0"] && i > 3
        @sprites["bg1"].opacity -= FADE_SPEED if @sprites["bg1"] && i > 3
        @sprites["pager"].opacity -= FADE_SPEED if @sprites["pager"] && i > 3
        @modes.size.times do |j|
          @sprites["btn#{j}"].opacity -= FADE_SPEED if @sprites["btn#{j}"]
        end

        @sprites["main"].opacity -= FADE_SPEED if @sprites["main"]
        @sprites["char"].opacity -= 40 if @sprites["char"]
        @sprites["char2"].opacity -= 40 if @sprites["char2"]
      end
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbWait(1)
  end
end