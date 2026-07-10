#===============================================================================
#
#===============================================================================
class PokemonJukebox_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    @sprites["background"] = IconSprite.new(0,0,@viewport)
    if isDarkMode
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_dark")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
    @sprites["ui"] = IconSprite.new(0,0,@viewport)
    @sprites["ui"].setBitmap("Graphics/Pictures/jukeboxbg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Jukebox"),2,-18,128,64,@viewport)

    if isDarkMode
      @sprites["header"].baseColor   = pbColor(:LIGHT_TEXT_MAIN_COLOR)
      @sprites["header"].shadowColor = pbColor(:LIGHT_TEXT_SHADOW_COLOR)
    else
      @sprites["header"].baseColor   = pbColor(:DARK_TEXT_MAIN_COLOR)
      @sprites["header"].shadowColor = pbColor(:DARK_TEXT_SHADOW_COLOR)
    end

    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(@commands,
       94,92,324,224,@viewport)
    @sprites["commands"].windowskin = nil

    @sprites["commands"].baseColor   = pbColor(:DARK_TEXT_MAIN_COLOR)
    @sprites["commands"].shadowColor = pbColor(:DARK_TEXT_SHADOW_COLOR)

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands,newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
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
class PokemonJukeboxScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMarch   = -1
    cmdLullaby = -1
    cmdOak     = -1
    cmdCustom  = -1
    commands[cmdCustom = commands.length]  = _INTL("Play Music")
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        pbPlayCloseMenuSE
        break
      elsif cmdCustom>=0 && cmd==cmdCustom
        pbPlayDecisionSE
        files = getMusicList
        @scene.pbSetCommands(files,0)
        loop do
          cmd2 = @scene.pbScene
          if cmd2<0
            pbPlayCancelSE
            break
          elsif cmd2==0
            pbPlayDecisionSE
            pbBGMPlay($game_map.bgm)
            $game_system.setDefaultBGM(nil)
            $PokemonMap.whiteFluteUsed = false if $PokemonMap
            $PokemonMap.blackFluteUsed = false if $PokemonMap
          else
            pbPlayDecisionSE
            $game_system.bgm_stop
            bgm_name = files[cmd2]
            pbBGMPlay(bgm_name)
            $game_system.setDefaultBGM(bgm_name)
            $PokemonMap.whiteFluteUsed = false if $PokemonMap
            $PokemonMap.blackFluteUsed = false if $PokemonMap
          end
        end
        @scene.pbSetCommands(nil,cmdCustom)
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end




  def getFolderMusic
    files = []
    Dir.chdir("Audio/BGM/") {
      Dir.glob("*.mp3") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.MP3") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.ogg") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.OGG") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.wav") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.WAV") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.mid") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.MID") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.midi") { |f| files.push(File.basename(f, ".*")) }
      Dir.glob("*.MIDI") { |f| files.push(File.basename(f, ".*")) }
    }
    return files
  end
  def getMusicList
    folder_music = getFolderMusic
    encountered_music_list = $PokemonSystem.encountered_music
    available_music =  [_INTL("(Default)")]
    encountered_music_list.each do |track|
      available_music << track if folder_music.include?(track)
    end
    return available_music
  end
end
