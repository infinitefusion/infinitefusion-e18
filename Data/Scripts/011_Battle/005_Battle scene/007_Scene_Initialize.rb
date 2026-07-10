class PokeBattle_Scene
  #=============================================================================
  # Create the battle scene and its elements
  #=============================================================================
  def initialize
    @battle = nil
    @abortable = false
    @aborted = false
    @battleEnd = false
    @animations = []
    @frameCounter = 0
  end

  # Called whenever the battle begins.
  def pbStartBattle(battle)
    @battle = battle
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @lastCmd = Array.new(@battle.battlers.length, 0)
    @lastMove = Array.new(@battle.battlers.length, 0)
    pbInitSprites
    pbBattleIntroAnimation
  end

  def pbInitSprites
    @sprites = {}
    # The background image and each side's base graphic
    pbCreateBackdropSprites
    # Create message box graphic
    messageBox = pbAddSprite("messageBox", 0, Graphics.height - 96,
                             "Graphics/Pictures/Battle/overlay_message", @viewport)
    messageBox.z = 195
    # Create message window (displays the message)
    msgWindow = Window_AdvancedTextPokemon.newWithSize("",
                                                       16, Graphics.height - 96 + 2, Graphics.width - 32, 96, @viewport)
    msgWindow.z = 200
    msgWindow.opacity = 0

    base_color = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
    shadow_color = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR

    if isDarkMode
      base_color, shadow_color = shadow_color, base_color
    end
    msgWindow.baseColor = base_color
    msgWindow.shadowColor = shadow_color

    msgWindow.letterbyletter = true
    @sprites["messageWindow"] = msgWindow
    # Create command window
    @sprites["commandWindow"] = CommandMenuDisplay.new(@viewport, 200,base_color,shadow_color)
    # Create fight window
    @sprites["fightWindow"] = FightMenuDisplay.new(@viewport, 200)
    # Create targeting window
    @sprites["targetWindow"] = TargetMenuDisplay.new(@viewport, 200, @battle.sideSizes)
    pbShowWindow(MESSAGE_BOX)
    # The party lineup graphics (bar and balls) for both sides
    for side in 0...2
      partyBar = pbAddSprite("partyBar_#{side}", 0, 0,
                             "Graphics/Pictures/Battle/overlay_lineup", @viewport)
      partyBar.z = 120
      partyBar.mirror = true if side == 0 # Player's lineup bar only
      partyBar.visible = false
      for i in 0...PokeBattle_SceneConstants::NUM_BALLS
        ball = pbAddSprite("partyBall_#{side}_#{i}", 0, 0, nil, @viewport)
        ball.z = 121
        ball.visible = false
      end
      # Ability splash bars
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @sprites["abilityBar_#{side}"] = AbilitySplashBar.new(side, @viewport)
      end
    end
    # Player's and partner trainer's back sprite
    @battle.player.each_with_index do |p, i|
      pbCreateTrainerBackSprite(i, p.trainer_type, @battle.player.length)
    end
    # Opposing trainer(s) sprites
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |p, i|
        pbCreateTrainerFrontSprite(i, p.trainer_type, @battle.opponent.length, p.sprite_override, p.custom_appearance)
      end
    end
    # Data boxes and Pokémon sprites
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"] = PokemonDataBox.new(b, @battle.pbSideSize(i), @viewport)
      pbCreatePokemonSprite(i)
    end
    # Wild battle, so set up the Pokémon sprite(s) accordingly
    if @battle.wildBattle?
      @battle.pbParty(1).each_with_index do |pkmn, i|
        index = i * 2 + 1
        pbChangePokemon(index, pkmn)
        pkmnSprite = @sprites["pokemon_#{index}"]
        pkmnSprite.tone = Tone.new(-80, -80, -80)
        pkmnSprite.visible = true
      end
    end
  end

  def getBackdropTimeSuffix()
    @battle.time = 2 if darknessEffectOnCurrentMap()
    case @battle.time
    when 1 then
      time = "eve"
    when 2 then
      time = "night"
    end
    return time
  end

  def getBackdropBasePath(type)
    case type
    when :BACKGROUND then
      base_path = "Graphics/Battlebacks/battlebg/"
    when :ENEMYBASE then
      base_path = "Graphics/Battlebacks/base/"
    when :PLAYERBASE then
      base_path = "Graphics/Battlebacks/base/"
    when :MESSAGE then
      base_path = "Graphics/Battlebacks/message/"
    end
    return base_path
  end

  def getBackdropSpriteFullPath(filename, backdrop_type)
    time = getBackdropTimeSuffix()
    base_path = getBackdropBasePath(backdrop_type)
    default_name = base_path + filename
    echoln default_name

    time_adjusted_name = "#{base_path}#{filename}_#{time}"
    if pbResolveBitmap(time_adjusted_name)
      return time_adjusted_name
    end
    return default_name
  end


  def apply_backdrop_graphics(battleBG,playerBase,enemyBase,messageBG)
    bg = pbAddSprite("battle_bg", 0, 0, battleBG, @viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2", -Graphics.width, 0, battleBG, @viewport)
    bg.z = 0
    bg.mirror = true
    for side in 0...2
      baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}", baseX, baseY,
                         (side == 0) ? playerBase : enemyBase, @viewport)
      player_side = side == 0
      if player_side
        base.zoom_x = 1.5
        base.zoom_y = 1.5
         base.x -= 50
         base.y+= 70
      end
      base.z = 1
      if base.bitmap
        base.ox = base.bitmap.width / 2
        base.oy = (side == 0) ? base.bitmap.height : base.bitmap.height / 2
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg", 0, Graphics.height - 96, messageBG, @viewport)
    cmdBarBG.z = 180
  end

  DEFAULT_BACKGROUND_NAME = "indoora"
  DEFAULT_MESSAGE_NAME = "default_message"
  def pbCreateBackdropSprites
    background_name = @battle.backdrop ? @battle.backdrop.downcase : DEFAULT_BACKGROUND_NAME
    simplified_name = background_name.downcase.split("-")[0]

    battlebase_name = @battle.backdropBase ? @battle.backdropBase.downcase : simplified_name
    message_name = background_name + "_message"

    #To avoid duplicating files too much, some backgrounds have a common prefix separated by -
    # Ex: city-rustboro
    # Will use the full name (city-rustboro) for the background, but "city" for the bases


    battleBG =getBackdropSpriteFullPath(background_name, :BACKGROUND)
    playerBase =getBackdropSpriteFullPath(battlebase_name, :PLAYERBASE)
    enemyBase =getBackdropSpriteFullPath(battlebase_name, :ENEMYBASE)
    messageBG =getBackdropSpriteFullPath(simplified_name, :MESSAGE)
    if !pbResolveBitmap(messageBG)
      messageBG = "Graphics/Battlebacks/message/default_message"
    end
    apply_backdrop_graphics(battleBG,playerBase,enemyBase,messageBG)
  end

  def pbCreateTrainerBackSprite(idxTrainer, trainerType, numTrainers = 1)


    #trainer = pbAddSprite("player_#{idxTrainer + 1}", spriteX, spriteY, trainerFile, @viewport)
    #
    if idxTrainer == 0 # Player's sprite
      x = 100
      y = 410

      sprite = IconSprite.new(x,y,@viewport)

      allowEasterEggPokeball = pbInSafari? #Never allow except in Safari Zone - add more conditions if needed
      sprite.setBitmapDirectly(generate_front_trainer_sprite_bitmap(allowEasterEggPokeball))
      sprite.zoom_x=2
      sprite.zoom_y=2
      sprite.z=100 + idxTrainer

      sprite.mirror =true
       @sprites["player_#{idxTrainer + 1}"] = sprite
    else
      x = 200
      y = 380
      # Partner trainer's sprite
      trainerFile = GameData::TrainerType.front_sprite_filename(trainerType)
      echoln ""
      echoln "-------"
      echoln trainerFile

      trainer_sprite = IconSprite.new(x,y,@viewport)
      trainer_sprite.setBitmap(trainerFile)
      trainer_sprite.zoom_x=2
      trainer_sprite.zoom_y=2
      trainer_sprite.z = 30 + idxTrainer
      trainer_sprite.mirror =true
      if trainer_sprite.bitmap.width > trainer_sprite.bitmap.height * 2
        trainer_sprite.src_rect.x = 0
        trainer_sprite.src_rect.width = trainer_sprite.bitmap.width / 5
      end
      trainer_sprite.ox = trainer_sprite.src_rect.width / 2
      trainer_sprite.oy = trainer_sprite.bitmap.height

      @sprites["player_#{idxTrainer + 1}"] = trainer_sprite

      #
      #
      # trainer.z = 30 + idxTrainer
      # if trainer.bitmap.width > trainer.bitmap.height * 2
      #   trainer.src_rect.x = 0
      #   trainer.src_rect.width = trainer.bitmap.width / 5
      # end
      # trainer.ox = trainer.src_rect.width / 2
      # trainer.oy = trainer.bitmap.height

    end
    # spriteX, spriteY = PokeBattle_SceneConstants.pbTrainerPosition(0, idxTrainer, numTrainers)
    # trainer = pbAddSprite("player_#{idxTrainer + 1}", spriteX, spriteY, trainerFile, @viewport)
    # return if !trainer.bitmap
    # # Alter position of sprite
    # trainer.z = 30 + idxTrainer
    # if trainer.bitmap.width > trainer.bitmap.height * 2
    #   trainer.src_rect.x = 0
    #   trainer.src_rect.width = trainer.bitmap.width / 5
    # end
    # trainer.ox = trainer.src_rect.width / 2
    # trainer.oy = trainer.bitmap.height
  end

  def pbCreateTrainerFrontSprite(idxTrainer, trainerType, numTrainers = 1, sprite_override = nil, custom_appearance=nil)
    trainerFile = GameData::TrainerType.front_sprite_filename(trainerType)
    trainerFile = sprite_override if sprite_override

    spriteX, spriteY = PokeBattle_SceneConstants.pbTrainerPosition(1, idxTrainer, numTrainers)
    trainer = pbAddSprite("trainer_#{idxTrainer + 1}", spriteX, spriteY, trainerFile, @viewport)
    spriteOverrideBitmap = setTrainerSpriteOverrides(trainerType)
    trainer.bitmap = spriteOverrideBitmap if spriteOverrideBitmap
    trainer.bitmap = generate_front_trainer_sprite_bitmap_from_appearance(custom_appearance,false).bitmap if custom_appearance
    return if !trainer.bitmap
    # Alter position of sprite
    trainer.z = 7 + idxTrainer
    trainer.ox = trainer.src_rect.width / 2
    trainer.oy = trainer.bitmap.height
  end

  def setTrainerSpriteOverrides(trainer_type)
    if TYPE_EXPERTS_APPEARANCES.keys.include?(trainer_type)
      return generate_front_trainer_sprite_bitmap_from_appearance(TYPE_EXPERTS_APPEARANCES[trainer_type],false).bitmap
    end
  end

  def pbCreatePokemonSprite(idxBattler)
    sideSize = @battle.pbSideSize(idxBattler)
    batSprite = PokemonBattlerSprite.new(@viewport, sideSize, idxBattler, @animations)
    @sprites["pokemon_#{idxBattler}"] = batSprite
    shaSprite = PokemonBattlerShadowSprite.new(@viewport, sideSize, idxBattler)
    shaSprite.visible = false
    @sprites["shadow_#{idxBattler}"] = shaSprite
  end
end
