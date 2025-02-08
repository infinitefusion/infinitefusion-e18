#===============================================================================
#  New animated Title Screens for Pokemon Essentials
#    by Luka S.J.
#
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the style selected
#===============================================================================
###SCRIPTEDIT1
# Config value for selecting title screen style
SCREENSTYLE = 1
# 1 - FR/LG
# 2 - R/S/E

class Scene_Intro

  alias main_old main

  def playIntroCinematic
    intro_frames_path = "Graphics\\Pictures\\Intro\\INTRO-%03d"
    intro_bgm = "INTRO_music_cries"
    intro_movie = Movie.new(intro_frames_path,intro_bgm,230,true)
    intro_movie.playInViewPort(@viewport)
  end

  def main
    Graphics.transition(0)
    # Cycles through the intro pictures
    @skip = false


    playIntroCinematic
    # Selects title screen style
    @screen = GenOneStyle.new
    # Plays the title screen intro (is skippable)
    @screen.intro
    # Creates/updates the main title screen loop
    self.update
    Graphics.freeze
  end

  def update
    ret = 0
    loop do
      @screen.update
      Graphics.update
      Input.update
      if continueKeyPressed?
        ret = 2
        break
      end
    end
    case ret
    when 1
      closeSplashDelete(scene, args)
    when 2
      closeTitle
    end
  end

  def closeTitle
    # Play Pokemon cry
    pbSEPlay("Absorb2", 100, 100)
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    #clearTempFolder
    # initializes load screen
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def closeTitleDelete
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes delete screen
    sscene = PokemonLoadScene.new
    sscreen = PokemonLoad.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  # def cyclePics(pics)
  #   sprite=Sprite.new
  #   sprite.opacity=0
  #   for i in 0...pics.length
  #     bitmap=pbBitmap("Graphics/Titles/#{pics[i]}")
  #     sprite.bitmap=bitmap
  #     15.times do
  #       sprite.opacity+=17
  #       pbWait(1)
  #     end
  #     wait(32)
  #     15.times do
  #       sprite.opacity-=17
  #       pbWait(1)
  #     end
  #   end
  #   sprite.dispose
  # end

  def disposeTitle
    @screen.dispose
  end

  def wait(frames)
    return if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip = true if continueKeyPressed?()
    end
  end
end

def continueKeyPressed?()
  return Input.trigger?(Input::USE) ||
    Input.trigger?(Input::ACTION) ||
    Input.trigger?(Input::BACK) ||
    Input.trigger?(Input::SPECIAL)
end
#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle

  def initialize
    #Kernel.pbDisplayText("Keybindings: F1", 80, 0, 99999)
    #Kernel.pbDisplayText("Version " + Settings::GAME_VERSION_NUMBER, 254, 308, 99999)


    @maxPoke = 140 #1st gen, pas de legend la premiere fois, graduellement plus de poke
    @customPokeList = getCustomSpeciesList(false)
    #Get random Pokemon (1st gen orandPokenly, pas de legend la prmeiere fois)

    random_fusion = getRandomFusionForIntro()
    random_fusion_body = random_fusion.body_id
    random_fusion_head = random_fusion.head_id

    # if randpoke_body && randpoke_head
    #   path_s1 = get_unfused_sprite_path(randpoke_body,true)
    #   path_s2 = get_unfused_sprite_path(randpoke_head,true)
    #   path_f = get_fusion_sprite_path(randpoke_body, randpoke_head,true)

      @prevPoke1 = random_fusion_body
      @prevPoke2 = random_fusion_head
    #end
    @spriteLoader = BattleSpriteLoader.new

    @selector_pos = 0 #1: left, 0:right

    # sound file for playing the title screen BGM
    bgm = "Pokemon Red-Blue Opening"
    @skip = false
    # speed of the effect movement
    @speed = 16
    @opacity = 17
    @disposed = false

    @currentFrame = 0
    # calculates after how many frames the game will reset
    #@totalFrames=getPlayTime("Audio/BGM/#{bgm}")*Graphics.frame_rate
    @totalFrames = 10 * Graphics.frame_rate

    pbBGMPlay(bgm)

    # creates all the necessary graphics
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @sprites = {}

    @sprites["bars"] = Sprite.new(@viewport)
    @sprites["bars"].bitmap = pbBitmap("Graphics/Titles/gen1_bars")
    @sprites["bars"].x = Graphics.width
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen1_bg")
    @sprites["bg"].x = -Graphics.width

    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap("Graphics/Titles/PokemonInfiniteFusionLogo_Main_25")
    @sprites["logo"].tone = Tone.new(255, 255, 255, 255)
    @sprites["logo"].x = (Graphics.width/2)-125
    @sprites["logo"].y = 0

    @sprites["logo"].opacity = 0
    @sprites["logo"].z = 9999

    @sprites["logo_bg"] = Sprite.new(@viewport)
    @sprites["logo_bg"].bitmap = pbBitmap("Graphics/Titles/PokemonInfiniteFusionLogo_Back_25")
    @sprites["logo_bg"].tone = Tone.new(255, 255, 255, 255)
    @sprites["logo_bg"].x = (Graphics.width/2)-125
    @sprites["logo_bg"].y = 0

    @sprites["logo_bg"].opacity = 0

    #@sprites["bg2"]=Sprite.new(@viewport)
    #@sprites["bg2"].bitmap=pbBitmap("Graphics/Titles/gen1_bg_litup")
    #@sprites["bg2"].opacity=0

    @sprites["start"]=Sprite.new(@viewport)
    @sprites["start"].bitmap=pbBitmap("Graphics/Titles/intro_pressKey2")
    @sprites["start"].x=125
    @sprites["start"].y=350
    @sprites["start"].opacity=0


    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen1_effect")
    @sprites["effect"].opacity = 155
    @sprites["effect"].visible = false

    @sprites["selector"] = Sprite.new(@viewport)
    @sprites["selector"].bitmap = pbBitmap("Graphics/Titles/selector")
    @sprites["selector"].x = 0
    @sprites["selector"].y = 200
    @sprites["selector"].opacity = 0

    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = @spriteLoader.load_base_sprite(random_fusion_body).bitmap
    @sprites["poke"].x = 400
    @sprites["poke"].y = 100

    @sprites["2poke"] = Sprite.new(@viewport)
    @sprites["2poke"].bitmap = @spriteLoader.load_base_sprite(random_fusion_head).bitmap
    @sprites["2poke"].x = -150
    @sprites["2poke"].y = 100

    @sprites["fpoke"] = Sprite.new(@viewport)

    fusedPoke = @spriteLoader.load_pif_sprite(random_fusion)
    if fusedPoke
      @sprites["fpoke"].bitmap = fusedPoke.bitmap
    end
    @sprites["fpoke"].x = 125
    @sprites["fpoke"].y = 100
    @sprites["fpoke"].z = 999
    @sprites["fpoke"].opacity = 0

    @sprites["fpoke"].z = 999

    @sprites["poke"].tone = Tone.new(0, 0, 0, 255)
    @sprites["poke"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport)
    # @sprites["poke2"].bitmap = pbBitmap("Graphics/Battlers/21364")
    @sprites["poke2"].tone = Tone.new(255, 255, 255, 255)
    @sprites["poke2"].src_rect.set(0, Graphics.height, Graphics.width, 48)
    @sprites["poke2"].y = Graphics.height
    @sprites["poke2"].y = 125
    @sprites["poke2"].z = 999

    @sprites["2poke"].tone = Tone.new(0, 0, 0, 255)
    @sprites["2poke"].opacity = 0
    @sprites["2poke2"] = Sprite.new(@viewport)
    @sprites["2poke2"].bitmap = pbBitmap("Graphics/Battlers/special/000")
    @sprites["2poke2"].tone = Tone.new(255, 255, 255, 255)
    @sprites["2poke2"].src_rect.set(0, Graphics.height, Graphics.width, 48)
    @sprites["2poke2"].y = Graphics.height
    @sprites["2poke2"].y = 125
    @sprites["2poke2"].z = 999

    @sprites["star"] = Sprite.new(@viewport)
    @sprites["star"].bitmap = pbBitmap("Graphics/Pictures/darkness")
    @sprites["star"].opacity = 0
    @sprites["star"].x = -50
    @sprites["star"].y = 0

  end

  def intro
    wait(16)
    16.times do
    end
    wait(32)
    64.times do

      @sprites["2poke"].opacity += 4
      @sprites["poke"].opacity += 4
      wait(1)
    end
    8.times do
      @sprites["bg"].x += 64
      wait(1)
    end
    wait(8)
    8.times do
      @sprites["bars"].x -= 64
      wait(1)
    end
    wait(8)
    showUIElements()



    @sprites["poke"].tone = Tone.new(0, 0, 0, 0)
    @sprites["2poke"].tone = Tone.new(0, 0, 0, 0)

    @sprites["effect"].visible = false
    c = 255.0
    16.times do
      @sprites["poke2"].opacity -= 255.0 / 16
      @sprites["2poke2"].opacity -= 255.0 / 16

      c -= 255.0 / 16
      @sprites["logo"].tone = Tone.new(c, c, c)
      @sprites["logo_bg"].tone = Tone.new(c, c, c)
      @sprites["effect"].ox += @speed

      wait(1)
    end
  end

  def showUIElements()
    @sprites["logo"].opacity = 255
    @sprites["logo_bg"].opacity = 255
    @sprites["poke2"].opacity = 255
    @sprites["2poke2"].opacity = 255
    @sprites["start"].opacity = 200

    Kernel.pbDisplayText("v." + Settings::GAME_VERSION_NUMBER, 455, 5, 99999,pbColor(:WHITE),pbColor(:INVISIBLE))
  end


  TONE_INCR = 15

  def makeShineEffect()
    newColor = @sprites["poke"].tone.red + TONE_INCR
    newTone = Tone.new(newColor, newColor, newColor, 0)
    @sprites["poke"].tone = newTone
    @sprites["2poke"].tone = newTone
  end

  def introloop
    @sprites["star"].opacity = 0
    @sprites["poke"].opacity = 255
    @sprites["2poke"].opacity = 255
    @sprites["fpoke"].opacity = 0
    @sprites["poke"].x = @sprites["poke"].x - 1
    @sprites["2poke"].x = @sprites["2poke"].x + 1

  end

  def update_selector_position()
    if Input.press?(Input::RIGHT) || Input.press?(Input::LEFT)
      if Input.press?(Input::RIGHT)
        @selector_pos = 0
        @sprites["selector"].opacity = 100
      elsif Input.press?(Input::LEFT)
        @selector_pos = 1
        @sprites["selector"].opacity = 100
      end
    else
      @sprites["selector"].opacity=0
    end

    if @selector_pos == 0
      @sprites["selector"].x = @sprites["poke"].x
    else
      @sprites["selector"].x = @sprites["2poke"].x
    end
  end

  def update
    @sprites["effect"].ox += @speed
    @currentFrame += 1
    @skip = false

    if @sprites["poke"].x < 175 #150
      makeShineEffect()
    end
    #update_selector_position()
    if @sprites["poke"].x > @sprites["2poke"].x
      @sprites["poke"].x = @sprites["poke"].x - 1
      @sprites["2poke"].x = @sprites["2poke"].x + 1
      #@sprites["effect"].opacity-=1
      #@sprites["bg"].opacity-=1
      #@sprites["bg2"].opacity+=3
    end

    if @sprites["poke"].x <= @sprites["2poke"].x
      @sprites["poke"].opacity = 0
      @sprites["2poke"].opacity = 0
      #16.times do
      @sprites["fpoke"].opacity = 255
      @sprites["selector"].opacity = 0
      #wait(1)
      #end
      @sprites["poke"].x = 400
      @sprites["poke"].tone = Tone.new(0, 0, 0, 0)

      @sprites["2poke"].x = -150
      @sprites["2poke"].tone = Tone.new(0, 0, 0, 0)

      if @maxPoke < NB_POKEMON - 1
        @maxPoke += 5 #-1 pour que ca arrive pile. tant pis pour kyurem
      end
      random_fusion = getRandomFusionForIntro()
      random_fusion_body = random_fusion.body_id
      random_fusion_head = random_fusion.head_id

      @prevPoke1 = random_fusion_body
      @prevPoke2 = random_fusion_head

      @sprites["poke"].bitmap = @spriteLoader.load_base_sprite(random_fusion_body).bitmap
      @sprites["2poke"].bitmap = @spriteLoader.load_base_sprite(random_fusion_head).bitmap

      wait(150)
      fusedPoke = @spriteLoader.load_pif_sprite(random_fusion)
      if fusedPoke
        @sprites["fpoke"].bitmap = fusedPoke.bitmap
      end
    end

    @sprites["fpoke"].opacity -= 10
    @sprites["effect"].ox += @speed


    updatePressStartAnimation(@currentFrame)

    if @currentFrame >= @totalFrames
      introloop
    end
  end


  PRESS_START_OPACITY_DIFF=2
  PRESS_START_ANIMATION_TIME=60
  def updatePressStartAnimation(currentFrame)
    return if @sprites["start"].opacity==0
    @start_opacity_diff=PRESS_START_OPACITY_DIFF if !@start_opacity_diff
    @sprites["start"].opacity += @start_opacity_diff
    @sprites["logo_bg"].opacity -= @start_opacity_diff

    if currentFrame % PRESS_START_ANIMATION_TIME == 0
      if @start_opacity_diff <0
        @start_opacity_diff = PRESS_START_OPACITY_DIFF
      else
        @start_opacity_diff = 0 - PRESS_START_OPACITY_DIFF
      end
    end
  end
  #new version
  # def getFusedPath(randpoke1, randpoke2)
  #   # path = rand(2) == 0 ? get_fusion_sprite_path(randpoke_body, randpoke_head,true) : get_fusion_sprite_path(randpoke_head, randpoke_body,true)
  #   path = get_fusion_sprite_path(randpoke2, randpoke1,true)
  #
  #   #allow download here because  intentional
  #   if Input.press?(Input::RIGHT)
  #     path = get_fusion_sprite_path(randpoke2, randpoke1)
  #   elsif Input.press?(Input::LEFT)
  #     path = get_fusion_sprite_path(randpoke1, randpoke2)
  #   end
  #   return path
  # end

end

# def getFusedPatho(randpoke1s, randpoke2s)
#   path = rand(2) == 0 ? "Graphics/Battlers/" + randpoke1s + "/" + randpoke1s + "." + randpoke2s : "Graphics/Battlers/" + randpoke2s + "/" + randpoke2s + "." + randpoke1s
#   if Input.press?(Input::RIGHT)
#     path = "Graphics/Battlers/" + randpoke2s + "/" + randpoke2s + "." + randpoke1s
#   elsif Input.press?(Input::LEFT)
#     path = "Graphics/Battlers/" + randpoke1s + "/" + randpoke1s + "." + randpoke2s
#   end
#   return path
# end

def dispose
  Kernel.pbClearText()
  pbFadeOutAndHide(@sprites)
  pbDisposeSpriteHash(@sprites)
  @viewport.dispose
  @disposed = true
end

def disposed?
  return @disposed
end

def wait(frames)
  return if @skip
  frames.times do
    @currentFrame += 1
    updatePressStartAnimation(@currentFrame)
    @sprites["effect"].ox += @speed
    Graphics.update
    Input.update
    if continueKeyPressed?
      @skip = true
      return
    end
  end
end


