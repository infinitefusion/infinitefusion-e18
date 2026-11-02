PluginManager.register({
                         :name => "Carmaniac's Speech Bubbles",
                         :version => "1.1",
                         :credits => ["Carmaniac", "Avery", "Boonzeet"],
                         :link => "https://reliccastle.com/resources/461/"
                       })

#-------------------------------------------------------------------------------
# Carmaniac's Speech Bubbles for v18
# Updated by Avery
#-------------------------------------------------------------------------------
# To use, call pbCallBub(type, eventID)
#
# Where type is either 1 or 2:
# 1 - floating bubble
# 2 - speech bubble with arrow
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Class modifiers
#-------------------------------------------------------------------------------

class PokemonTemp
  attr_accessor :speechbubble_bubble
  attr_accessor :speechbubble_vp
  attr_accessor :speechbubble_arrow
  attr_accessor :speechbubble_outofrange
  attr_accessor :speechbubble_talking
  attr_accessor :speechbubble_alwaysDown
  attr_accessor :speechbubble_alwaysUp

  attr_accessor :speechbubble_fixed_x
  attr_accessor :speechbubble_fixed_y
  attr_accessor :speechbubble_fixed_w
  attr_accessor :speechbubble_fixed_h
  attr_accessor :speechbubble_fixed_anchor
  attr_accessor :speechbubble_fixed_arrow

  attr_accessor :windowSkin

end

module MessageConfig
  BUBBLETEXTBASE = Color.new(22, 22, 22)
  BUBBLETEXTSHADOW = Color.new(166, 160, 151)
  WindowOpacity = 255
end

#-------------------------------------------------------------------------------
# Function modifiers
#-------------------------------------------------------------------------------

class Window_AdvancedTextPokemon
  def text=(value)
    if value != nil && value != "" && $PokemonTemp.speechbubble_bubble && $PokemonTemp.speechbubble_bubble > 0
      if $PokemonTemp.speechbubble_bubble == 1
        $PokemonTemp.speechbubble_bubble = 0
        resizeToFit2(value, 400, 100)

        @x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
        @y = $game_map.events[$PokemonTemp.speechbubble_talking].screen_y - (32 + @height)

        if @y > (Graphics.height - @height - 2)
          @y = (Graphics.height - @height)
        elsif @y < 2
          @y = 2
        end
        if @x > (Graphics.width - @width - 2)
          @x = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_x - @width)
        elsif @x < 2
          @x = 2
        end
      elsif $PokemonTemp.speechbubble_bubble == 3
        @x = $game_player.x + 32
        @y = $game_player.y + 36
      elsif $PokemonTemp.speechbubble_bubble == 4
        full_w = ($PokemonTemp.speechbubble_fixed_w || 400).to_i
        full_h = ($PokemonTemp.speechbubble_fixed_h || 100).to_i
        fx     = ($PokemonTemp.speechbubble_fixed_x || 0).to_i
        fy     = ($PokemonTemp.speechbubble_fixed_y || 0).to_i

        resizeToFit2(value, full_w, full_h)
        w = self.width.to_i
        h = self.height.to_i
        if $PokemonTemp.speechbubble_fixed_anchor
          new_x = fx - (w / 2)
          new_y = fy - h
        else
          new_x = fx + ((full_w - w) / 2)
          new_y = fy
        end
        new_x = [[new_x, 0].max, [Graphics.width  - w, 0].max].min
        new_y = [[new_y, 0].max, [Graphics.height - h, 0].max].min
        self.x = new_x
        self.y = new_y

        arrow = $PokemonTemp.speechbubble_arrow
        if $PokemonTemp.speechbubble_fixed_arrow && arrow &&
          !arrow.disposed? && arrow.bitmap
          arrow.zoom_x = 2
          arrow.zoom_y = 2
          arrow.x = new_x + w - 12
          arrow.y = new_y + (h / 2) - (arrow.bitmap.height / 2) + 8
          arrow.z = 99999
          arrow.visible = true
        end
      else
        $PokemonTemp.speechbubble_bubble = 0
      end
    end
    setText(value)
  end
end

def pbRepositionMessageWindow(msgwindow, linecount = 2)
  msgwindow.height = 32 * linecount + msgwindow.borderY
  msgwindow.y = (Graphics.height) - (msgwindow.height)
  in_battle = $game_temp && $game_temp.in_battle && !$scene.respond_to?("update_basic")
  if $PokemonTemp.speechbubble_bubble == 4
    msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
    msgwindow.width = $PokemonTemp.speechbubble_fixed_w || 400
    msgwindow.height = $PokemonTemp.speechbubble_fixed_h || 100
    unless $PokemonTemp.speechbubble_fixed_anchor
      msgwindow.x = $PokemonTemp.speechbubble_fixed_x || 0
      msgwindow.y = $PokemonTemp.speechbubble_fixed_y || 0
    end
  elsif in_battle
    msgwindow.y = 0
  elsif $game_system && $game_system.respond_to?("message_position")
    case $game_system.message_position
    when 0 # up
      msgwindow.y = 0
    when 1 # middle
      msgwindow.y = (Graphics.height / 2) - (msgwindow.height / 2)
    when 2
      if $PokemonTemp.speechbubble_bubble == 1 || $PokemonTemp.speechbubble_bubble == 3
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 100
        msgwindow.width = 400
      elsif $PokemonTemp.speechbubble_bubble == 2
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 102
        msgwindow.width = Graphics.width
        if ($game_player.direction == DIRECTION_UP && !$PokemonTemp.speechbubble_alwaysDown) || $PokemonTemp.speechbubble_alwaysUp
          $PokemonTemp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280)
          msgwindow.y = 6
        else
          $PokemonTemp.speechbubble_vp = Viewport.new(0, 6 + msgwindow.height, Graphics.width, 280)
          msgwindow.y = (Graphics.height - msgwindow.height) - 6
          if $PokemonTemp.speechbubble_outofrange == true && !$PokemonTemp.speechbubble_alwaysDown
            msgwindow.y = 6
          end
        end
      else
        msgwindow.height = 102
        msgwindow.y = Graphics.height - msgwindow.height - 6
      end
    end
  end
  if $game_system && $game_system.respond_to?("message_frame")
    if $game_system.message_frame != 0
      msgwindow.opacity = 0
    end
  end
  if $game_message
    case $game_message.background
    when 1 # dim
      msgwindow.opacity = 0
    when 2 # transparent
      msgwindow.opacity = 0
    end
  end
end

def pbCreateMessageWindow(viewport = nil, skin = nil)
  arrow = nil
  if $PokemonTemp.speechbubble_bubble == 2 && $game_map.events[$PokemonTemp.speechbubble_talking] != nil # Message window set to floating bubble.
    if ($game_player.direction == DIRECTION_UP && (!$PokemonTemp.speechbubble_alwaysDown) || $PokemonTemp.speechbubble_alwaysUp) # Player facing up, message window top.
      $PokemonTemp.speechbubble_vp = Viewport.new(0, 104, Graphics.width, 280)
      $PokemonTemp.speechbubble_vp.z = 999999
      arrow = Sprite.new($PokemonTemp.speechbubble_vp)
      arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x - Graphics.width
      arrow.y = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_y - Graphics.height) - 136
      arrow.z = 999999
      arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow4")
      arrow.zoom_x = 2
      arrow.zoom_y = 2
      if arrow.x < -230
        arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
        arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
      end
    else
      # Player facing left, down, right, message window bottom.
      $PokemonTemp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280)
      $PokemonTemp.speechbubble_vp.z = 999999
      arrow = Sprite.new($PokemonTemp.speechbubble_vp)
      arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
      arrow.y = $game_map.events[$PokemonTemp.speechbubble_talking].screen_y
      arrow.z = 999999
      arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow1")
      if arrow.y >= Graphics.height - 120 # Change arrow direction.
        $PokemonTemp.speechbubble_outofrange = true
        $PokemonTemp.speechbubble_vp.rect.y += 104
        arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x - Graphics.width
        arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow4")
        arrow.y = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_y - Graphics.height) - 136
        if arrow.x < -250
          arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
          arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
        end
        if arrow.x >= 256
          arrow.x -= 15 # = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x-Graphics.width
          arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
        end
      else
        $PokemonTemp.speechbubble_outofrange = false
      end
      arrow.zoom_x = 2
      arrow.zoom_y = 2
    end
  end

  # Battle bubble arrow (type 4)
  if $PokemonTemp.speechbubble_bubble == 4 &&
    $PokemonTemp.speechbubble_fixed_arrow
    arrow = Sprite.new
    arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/ArrowBattle")
    arrow.z = 100000
    arrow.visible = false
  end
  arrow.bitmap = nil if $PokemonTemp.speechbubble_bubble == 2 && $PokemonTemp.speechbubble_outofrange && arrow

  $PokemonTemp.speechbubble_arrow = arrow
  msgwindow = Window_AdvancedTextPokemon.new("")
  if !viewport
    msgwindow.z = 99999
  else
    msgwindow.viewport = viewport
  end
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WindowOpacity
  pbBottomLeftLines(msgwindow, 2)
  $game_temp.message_window_showing = true if $game_temp
  $game_message.visible = true if $game_message
  skin = MessageConfig.pbGetSpeechFrame() if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing = false if $game_temp
  $game_message.visible = false if $game_message
  msgwindow.dispose
  $PokemonTemp.speechbubble_arrow.dispose if $PokemonTemp.speechbubble_arrow
  $PokemonTemp.speechbubble_vp.dispose if $PokemonTemp.speechbubble_vp
  $PokemonTemp.speechbubble_bubble = nil
  $PokemonTemp.speechbubble_arrow = nil
  $PokemonTemp.speechbubble_fixed_arrow = false
end

def pbCallBubUp(status = 0, value = 0)
  pbCallBub(status, value, false, true)
end

def pbCallBubDown(status = 0, value = 0)
  pbCallBub(status, value, true, false)
end

# always_down, always_up is not ideal but used everywhere in game so too late to change
def pbCallBub(status = 0, event_id = 0, always_down = false, always_up = false)
  begin
    if status < 3
      if event_id.is_a?(Integer)
        char = $game_map.events[event_id]
        $PokemonTemp.speechbubble_talking = char ? char.id : event_id
      else
        $PokemonTemp.speechbubble_talking = get_character(event_id).id
      end
    end
    $PokemonTemp.speechbubble_bubble = status
    $PokemonTemp.speechbubble_alwaysDown = always_down
    $PokemonTemp.speechbubble_alwaysUp = always_up
  rescue
    return
  end
end

def pbCallBubOverBattler(battler, width = 300, height = 100, offset_x = 40, offset_y = 60)
  sprite = battler.battle.scene.sprites["pokemon_#{battler.index}"]
  if !sprite
    echoln "pbCallBubOverBattler: no sprite for index #{battler.index}"
    return pbCallBubFixed(100, 70, width, height)
  end
  x = sprite.x + offset_x
  y = sprite.y - sprite.height + offset_y
  pbCallBubFixed(x.to_i, y.to_i, width, height)
  $PokemonTemp.speechbubble_fixed_anchor = true
end


def pbCallBubFixed(x, y, width = 400, height = 100, arrow = false)
  $PokemonTemp.speechbubble_bubble       = 4
  $PokemonTemp.speechbubble_fixed_x      = x
  $PokemonTemp.speechbubble_fixed_y      = y
  $PokemonTemp.speechbubble_fixed_w      = width
  $PokemonTemp.speechbubble_fixed_h      = height
  $PokemonTemp.speechbubble_fixed_anchor = false
  $PokemonTemp.speechbubble_fixed_arrow  = arrow
  $PokemonTemp.speechbubble_alwaysDown   = false
  $PokemonTemp.speechbubble_alwaysUp     = false
end

def setSign(type = :NORMAL)
  case type
  when :NORMAL
    setWindowSkin("sign_normal")
  when :WOOD
    setWindowSkin("sign_wood")
  when :WALL
    setWindowSkin("sign_wall")
  when :GREEN
    setWindowSkin("sign_green")
  end
end

def setWindowSkin(skin)
  $PokemonTemp.windowSkin = skin
end