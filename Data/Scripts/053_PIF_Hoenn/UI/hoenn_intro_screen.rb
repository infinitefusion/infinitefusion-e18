class HoennIntroScreen
  # =========================================================================
  # CONFIG
  # =========================================================================

  SCROLL_LAYERS = [
    [:back, "Graphics/Titles/bg_back", 0],
    [:clouds, "Graphics/Titles/bg_clouds", 0.12],
    [:front, "Graphics/Titles/bg_front", 2.0],
    [:shade, "Graphics/Titles/bg_shade", 0]
  ]

  PRESS_START_OPACITY_DIFF = 2
  PRESS_START_ANIMATION_TIME = 60

  # Fusion config
  FUSION_SCROLL_SPEED = 2
  FUSION_PRELOAD_COUNT = 10
  FUSION_SPAWN_EVERY = 300
  FUSION_Y_RANGE = (50..200)

  # =========================================================================
  # INITIALIZATION
  # =========================================================================
  def initialize
    @bgm = "title_screen"
    @currentFrame = 0
    @scrollLayers = {}
    @scrollSprites = {}
    @fusionSprites = []

    @spriteLoader = BattleSpriteLoader.new
    @fusionBitmapCache = {}

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @sprites = {}
    pbBGMPlay(@bgm)
    setupScrollingLayers
    setupSprites
    setupUI
    preloadFusionSprites
  end

  # =========================================================================
  # SETUP METHODS
  # =========================================================================
  def setupScrollingLayers
    SCROLL_LAYERS.each do |name, file, speed|
      bmp = pbBitmap(file)
      w = bmp.width

      sA = Sprite.new(@viewport)
      sA.bitmap = bmp
      sA.x = 0
      sA.z = 0

      sB = Sprite.new(@viewport)
      sB.bitmap = bmp
      sB.x = w
      sB.z = 0

      @scrollSprites[name] = [sA, sB]
      @scrollLayers[name] = { width: w, speed: speed, posA: 0.0, posB: w.to_f }
    end
  end

  def setupSprites
    @sprites["shimmer1"] = Sprite.new(@viewport)
    @sprites["shimmer1"].bitmap = pbBitmap("Graphics/Titles/bg_shimmer1")

    @sprites["shimmer2"] = Sprite.new(@viewport)
    @sprites["shimmer2"].bitmap = pbBitmap("Graphics/Titles/bg_shimmer2")

    @sprites["shimmer3"] = Sprite.new(@viewport)
    @sprites["shimmer3"].bitmap = pbBitmap("Graphics/Titles/bg_shimmer3")

    @sprites["shimmer4"] = Sprite.new(@viewport)
    @sprites["shimmer4"].bitmap = pbBitmap("Graphics/Titles/bg_shimmer4")
  end

  def setupUI
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/intro_pressKey2")
    @sprites["start"].x = 125
    @sprites["start"].y = 350
    @sprites["start"].opacity = 0
    @sprites["start"].z = 3

    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap("Graphics/Titles/InfiniteFusionHoenn") if Settings::HOENN
    @sprites["logo"].x = (Graphics.width / 2) - 125
    @sprites["logo"].y = 0
    @sprites["logo"].z = 2
  end

  def preloadFusionSprites
    used_fusions = {}
    count = 0

    while count < FUSION_PRELOAD_COUNT
      begin
        fusion = getRandomFusionForIntro()
        next unless fusion
        next if used_fusions[fusion] # ensure uniqueness

        used_fusions[fusion] = true
        bitmap = (@fusionBitmapCache[fusion] ||= @spriteLoader.load_random_alt_for_pif_sprite(fusion).bitmap)

        sprite = Sprite.new(@viewport)
        sprite.bitmap = bitmap
        sprite.z = 1
        sprite.visible = false
        sprite.x = 0
        sprite.y = 0

        @fusionSprites << sprite
        count += 1
      rescue
      end
    end
  end

  # =========================================================================
  # PUBLIC METHODS
  # =========================================================================
  def intro
    showUIElements
  end

  def showUIElements
    @sprites["logo"].opacity = 255
    @sprites["start"].opacity = 200

    begin
      Kernel.pbDisplayText(
        "v." + Settings::HOENN_VERSION_NUMBER,
        455, 5, 99999,
        pbColor(:WHITE),
        pbColor(:INVISIBLE)
      )
    rescue
    end
  end

  def update
    @currentFrame += 1
    updateShimmer
    updatePressStartAnimation
    updateScrollingLayers
    updateFusions
  end

  # =========================================================================
  # SCROLLING BACKGROUNDS
  # =========================================================================
  def updateScrollingLayers
    SCROLL_LAYERS.each { |name, _, _| updateScrollingLayer(name) }
  end

  def updateScrollingLayer(name)
    layer = @scrollLayers[name]
    sA, sB = @scrollSprites[name]
    speed = layer[:speed]
    width = layer[:width]

    # Float positions
    layer[:posA] -= speed
    layer[:posB] -= speed

    # Wrap
    if layer[:posA] <= -width
      layer[:posA] = layer[:posB] + width
    end
    if layer[:posB] <= -width
      layer[:posB] = layer[:posA] + width
    end

    # Assign integer positions to sprites
    sA.x = layer[:posA].round
    sB.x = layer[:posB].round
  end

  # =========================================================================
  # FUSIONS
  # =========================================================================
  def updateFusions
    spawnFusionIfNeeded
    moveAndCleanupFusions
  end

  def spawnFusionIfNeeded
    return unless @currentFrame == 1 || (@currentFrame % FUSION_SPAWN_EVERY).zero?

    hidden_sprites = @fusionSprites.reject { |s| s.visible || s == @lastFusion }
    return if hidden_sprites.empty?

    sprite = hidden_sprites.sample # pick randomly from hidden pool
    sprite.x = Graphics.width + rand(40)
    sprite.y = rand(FUSION_Y_RANGE)
    sprite.visible = true
    @lastFusion = sprite
  end

  def moveAndCleanupFusions
    @fusionSprites.each do |s|
      next unless s.visible
      s.x -= FUSION_SCROLL_SPEED
      s.visible = false if s.x < -s.bitmap.width
    end
  end

  # =========================================================================
  # PRESS START ANIMATION
  # =========================================================================
  def updatePressStartAnimation
    return if @sprites["start"].opacity.zero?

    @start_opacity_diff ||= PRESS_START_OPACITY_DIFF
    @sprites["start"].opacity += @start_opacity_diff

    if (@currentFrame % PRESS_START_ANIMATION_TIME).zero?
      @start_opacity_diff = -@start_opacity_diff
    end
  end

  def updateShimmer
    max_opacity = 200
    cycle_speed = 80.0

    t = (@currentFrame % cycle_speed) / cycle_speed * 4.0
    4.times do |i|
      dist = (t - i).abs
      dist = [dist, (4 - dist)].min
      fade = [[1.0 - dist, 0].max, 1].min
      opacity = (fade * max_opacity).to_i
      @sprites["shimmer#{i+1}"].opacity = opacity
    end
  end


  def dispose
    Kernel.pbClearText()

    # --- Dispose all regular sprites except logo ---
    preserved_sprites = {}
    @sprites.each do |key, sprite|
      if key == "logo"
        preserved_sprites[key] = sprite   # KEEP LOGO
      else
        sprite.dispose
      end
    end
    @sprites = preserved_sprites

    # --- Dispose scroll sprites except :back ---
    @scrollSprites.each do |name, arr|
      next if name == :back
      arr.each(&:dispose)
    end

    # Dispose fusion sprites
    @fusionSprites.each { |s| s.dispose if s && !s.disposed? }
    @fusionSprites.clear

    # Keep only back layer
    @scrollSprites.select! { |k,_| k == :back }

    # Zoom effect will now run with bg_back AND logo still alive
    zoomAndFadeOut

    # --- Dispose the remaining back sprites ---
    @scrollSprites.each_value { |arr| arr.each(&:dispose) }

    # --- Dispose preserved logo sprite ---
    pbDisposeSpriteHash(@sprites)

    @viewport.dispose
    @disposed = true
  end




  def zoomAndFadeOut
    duration = 30   # animation length

    backA, backB = @scrollSprites[:back]

    duration.times do |i|
      t = i.to_f / duration

      # --- ZOOM ON BG_BACK ---
      zoom = 1.0 + t * 0.5
      backA.zoom_x = zoom
      backA.zoom_y = zoom
      backB.zoom_x = zoom
      backB.zoom_y = zoom

      # Prepare center anchors
      backA.ox = backA.bitmap.width / 2
      backA.oy = backA.bitmap.height / 2
      backB.ox = backB.bitmap.width / 2
      backB.oy = backB.bitmap.height / 2

      # --- MOVE DOWN ---
      down_offset = 40 * t
      backA.x = Graphics.width / 2
      backB.x = Graphics.width / 2
      backA.y = Graphics.height / 2 + down_offset
      backB.y = Graphics.height / 2 + down_offset

      Graphics.update
    end
  end





end

