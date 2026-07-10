#===============================================================================
#
#===============================================================================
class Game_Temp
  attr_accessor :pokenav_last_index
end


class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_reader :selected
  attr_reader :held
  attr_accessor :rearranging
  def initialize(command,x,y,viewport=nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]
    @selected = false
    @cursor = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button")
    @contents = BitmapWrapper.new(@cursor.width, @cursor.height)
    @held = false
    @base_x = x
    @base_y = y
    @rearranging = false
    @wobble_phase = rand * Math::PI * 2
    self.bitmap = @contents
    self.x = x
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @cursor.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel!=val
  end

  def held=(val)
    old = @held
    @held = val
    refresh if old != val
  end

  def set_command(command)
    @image = command[0]
    @name  = command[1]
    refresh
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @cursor.width, @cursor.height / 2)
    rect.y = @cursor.height / 2 if @selected
    self.bitmap.blt(0, 0, @cursor.bitmap, rect)
    if @held
      self.opacity = 200
      self.y -= 6
    else
      self.opacity = 255
    end
    imagepos = [
      [sprintf("Graphics/Pictures/Pokegear/icon_%s", @image), 0, 0]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)

    self.x = @base_x
    self.y = @base_y
    self.y -= 6 if @held
  end

  def update_wobble
    return unless @rearranging && !@held
    wobble = Math.sin(@wobble_phase) * 0.2  #amplitude
    self.x = @base_x + wobble
    self.y = @base_y
    wobble_speed = 0.3 + rand * 0.2   #
    @wobble_phase += wobble_speed
  end



end

#===============================================================================
#
#===============================================================================
class PokemonPokegear_Scene
  attr_accessor :exiting

  GRID_COLUMNS = 4
  GRID_X_START = 72
  GRID_Y_START = 120
  GRID_X_GAP   = 96
  GRID_Y_GAP   = 72

  def pbUpdate
    return if @exiting
    for i in 0...@commands.length
      button = @sprites["button#{i}"]
      button.rearranging = @rearranging
      button.selected    = (i == @index)
      button.held        = (@rearranging && i == @held_index)
      button.update_wobble
    end
    return unless @commands && @commands[@index]
    # Draw selected app name
    name_sprite = @sprites["appName"]
    name_sprite.bitmap.clear
    text = @commands[@index][1]
    pbDrawTextPositions(
      name_sprite.bitmap,
      [[text, Graphics.width / 2, -4, 2,
        Color.new(248,248,248), Color.new(40,40,40)]]
    )

    pbUpdateSpriteHash(@sprites)
  end



  def pbStartScene(commands)
    @commands = commands
    @index = 0
    @held_index
    @rearranging = false

    if $game_temp.pokenav_last_index
      @index = $game_temp.pokenav_last_index
    end
    $game_temp.pokenav_last_index = @index
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)

    reloadBackground
    @sprites["UI"] = IconSprite.new(0,0,@viewport)
    @sprites["UI"].setBitmap("Graphics/Pictures/Pokegear/ui_mainMenu")

    for i in 0...@commands.length
      col = i % GRID_COLUMNS
      row = i / GRID_COLUMNS
      x = GRID_X_START + (col * GRID_X_GAP)
      y = GRID_Y_START + (row * GRID_Y_GAP)
      @sprites["button#{i}"] = PokegearButton.new(@commands[i], x, y, @viewport)
    end
    @sprites["appName"] = BitmapSprite.new(Graphics.width, 48, @viewport)
    @sprites["appName"].y = Graphics.height - 48
    pbSetSystemFont(@sprites["appName"].bitmap)


    @sprites["pokenavIcon"] = AnimatedSprite.new("Graphics/Pictures/Pokegear/pokenav_icon", 8,32,32,4,@viewport)
    @sprites["pokenavIcon"].zoom_x = 2
    @sprites["pokenavIcon"].zoom_y = 2
    @sprites["pokenavIcon"].z = 10
    @sprites["pokenavIcon"].x = 400
    @sprites["pokenavIcon"].y = 16
    @sprites["pokenavIcon"].start

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def reloadBackground
    if isDarkMode
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_dark")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK) || @exiting
        if @rearranging
          pbPlayCloseMenuSE
          @rearranging = false
        else
          pbPlayCloseMenuSE
          break
        end

      elsif Input.trigger?(Input::USE)
        if @rearranging
          swap_apps
        else
          pbPlayDecisionSE
          ret = @index
          break
        end
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        col = grid_col(@index)
        if col > 0
          @index -= 1
        end
        $game_temp.pokenav_last_index = @index

      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        col = grid_col(@index)
        if col < GRID_COLUMNS - 1 && @index + 1 < @commands.length
          @index += 1
        end
        $game_temp.pokenav_last_index = @index

      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE
        new_index = @index - GRID_COLUMNS
        if new_index >= 0
          @index = new_index
        end
        $game_temp.pokenav_last_index = @index

      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        new_index = @index + GRID_COLUMNS
        if new_index < @commands.length
          @index = new_index
        end
        $game_temp.pokenav_last_index = @index
      end
    end
    return ret
  end

  def swap_apps
    if @held_index
      pbSEPlay("GUI storage put down")
      apps = $Trainer.pokenav.installed_apps
      apps[@index], apps[@held_index] =
        apps[@held_index], apps[@index]

      refresh_buttons
      @held_index = nil
    else
      pbSEPlay("GUI storage pick up")
      @held_index = @index
    end
  end


  def refresh_buttons
    @commands = []
    $Trainer.pokenav.installed_apps.each do |app|
      @commands << [app.to_s, Pokenav::AVAILABLE_APPS[app]]
    end

    @commands.each_with_index do |cmd, i|
      @sprites["button#{i}"].set_command(cmd)
    end
  end


  # def refresh_apps
  #
  # end
  def rearrange_order
    pbSEPlay("GUI naming tab swap start")
    @rearranging = true
  end
  def grid_row(index)
    return index / GRID_COLUMNS
  end

  def grid_col(index)
    return index % GRID_COLUMNS
  end


  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMap     = -1
    cmdPhone   = -1
    cmdJukebox = -1
    commands[cmdMap = commands.length]     = ["map",_INTL("Map")]
    if $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length>0
      commands[cmdPhone = commands.length] = ["phone",_INTL("Phone")]
    end
    commands[cmdJukebox = commands.length] = ["jukebox",_INTL("Jukebox")]
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        break
      elsif cmdMap>=0 && cmd==cmdMap
        pbShowMap(-1,false)
      elsif cmdPhone>=0 && cmd==cmdPhone
        pbFadeOutIn {
          PokemonPhoneScene.new.start
        }
      elsif cmdJukebox>=0 && cmd==cmdJukebox
        pbFadeOutIn {
          scene = PokemonJukebox_Scene.new
          screen = PokemonJukeboxScreen.new(scene)
          screen.pbStartScreen
        }
      end
    end
    @scene.pbEndScene
  end
end
