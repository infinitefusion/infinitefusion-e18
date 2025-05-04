#===============================================================================
#
#===============================================================================
class PokemonTrainerCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    setCardBackground()

    is_postgame = $game_switches[SWITCH_BEAT_THE_LEAGUE]
    overlay_version = is_postgame ? "overlay_postgame" : "overlay"

    addBackgroundPlane(@sprites, "highlights", "Trainer Card/#{overlay_version}", @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336, 112, @viewport)
    @sprites["trainer"].setBitmapDirectly(generate_front_trainer_sprite_bitmap())

    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - 128) / 2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height - 128)
    @sprites["trainer"].z = 2
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def setCardBackground()
    background_img = $Trainer.card_background ? $Trainer.card_background : "BLUE"
    background_img_path = "Graphics/Pictures/Trainer Card/backgrounds/#{background_img}"
    cardexists = pbResolveBitmap(sprintf(background_img_path))
    @sprites["card"] = IconSprite.new(0, 0, @viewport)

    if cardexists
      @sprites["card"].setBitmap(background_img_path) if cardexists
    else
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card")
    end
    @sprites["card"].z=-100
  end

  def promptSwapBackground()
    $Trainer.unlocked_card_backgrounds = [] if !$Trainer.unlocked_card_backgrounds
    if $Trainer.unlocked_card_backgrounds.length >= 1
      if pbConfirmMessage("Swap your current Trainer Card background")
        chosen = pbListScreen("Trainer card", TrainerCardBackgroundLister.new($Trainer.unlocked_card_backgrounds))
        echoln chosen
        if chosen
          $Trainer.card_background = chosen
          pbSEPlay("GUI trainer card open")
          setCardBackground()
        end
      end
    else
      pbMessage("You can purchase new Trainer Card backgrounds at PokéMarts!")
    end
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor = Color.new(72, 72, 72)
    shadowColor = Color.new(160, 160, 160)
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
                      pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                      $PokemonGlobal.startTime.day,
                      $PokemonGlobal.startTime.year)
    textPositions = [
      [_INTL("Name"), 34, 58, 0, baseColor, shadowColor],
      [$Trainer.name, 302, 58, 1, baseColor, shadowColor],
      [_INTL("ID No."), 332, 58, 0, baseColor, shadowColor],
      [sprintf("%05d", $Trainer.public_ID), 468, 58, 1, baseColor, shadowColor],
      [_INTL("Money"), 34, 106, 0, baseColor, shadowColor],
      [_INTL("${1}", $Trainer.money.to_s_formatted), 302, 106, 1, baseColor, shadowColor],
      [_INTL("Pokédex"), 34, 154, 0, baseColor, shadowColor],
      [sprintf("%d/%d", $Trainer.pokedex.owned_count, $Trainer.pokedex.seen_count), 302, 154, 1, baseColor, shadowColor],
      [_INTL("Time"), 34, 202, 0, baseColor, shadowColor],
      [time, 302, 202, 1, baseColor, shadowColor],
      [_INTL("Started"), 34, 250, 0, baseColor, shadowColor],
      [starttime, 302, 250, 1, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay, textPositions)
    x = 72
    imagePositions = []
    postgame = $game_switches[SWITCH_BEAT_THE_LEAGUE]
    numberOfBadgesDisplayed = postgame ? 16 : 8
    for i in 0...numberOfBadgesDisplayed
      badgeRow = i < 8 ? 0 : 1
      if $Trainer.badges[i]
        if i == 8
          x = 72
        end
        badge_graphic_x = badgeRow == 0 ? i * 32 : (i - 8) * 32
        badge_graphic_y = badgeRow * 32
        y = getBadgeDisplayHeight(postgame, i)
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges", x, y, badge_graphic_x, badge_graphic_y, 32, 32])
      end
      x += 48
    end
    pbDrawImagePositions(overlay, imagePositions)
  end

  def getBadgeDisplayHeight(postgame, i)
    if postgame
      if i < 8
        y = 310
      else
        y = 344
      end
    else
      y = 312
    end
    return y
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        promptSwapBackground()
      end
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
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
class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end
