#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre. Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5. Music can
# now be defined. Credits can't be skipped during their first play.
#
## New Edit 25/3/2020 by Maruno.
# Scroll speed is now independent of frame rate. Now supports non-integer values
# for SCROLL_SPEED.
#
## New Edit 21/8/2020 by Marin.
# Now automatically inserts the credits from the plugins that have been
# registered through the PluginManager module.
#==============================================================================
class Scene_Credits
  # Backgrounds to show in credits. Found in Graphics/Titles/ folder
  BACKGROUNDS_LIST_HOENN = [
    "Graphics/Battlebacks/battlebg/ocean_night",
    "Graphics/Battlebacks/battlebg/ocean",
    "Graphics/Battlebacks/battlebg/oceanicmuseum",
    "Graphics/Battlebacks/battlebg/oceanseaweed_eve",
    "Graphics/Battlebacks/battlebg/oceanseaweed_night",
    "Graphics/Battlebacks/battlebg/oceanseaweed",
    "Graphics/Battlebacks/battlebg/ocean_eve",
    "Graphics/Battlebacks/battlebg/mauvilletunnel",
    "Graphics/Battlebacks/battlebg/pond",
    "Graphics/Battlebacks/battlebg/pond_night",
    "Graphics/Battlebacks/battlebg/pond_eve",
    "Graphics/Battlebacks/battlebg/field_night",
    "Graphics/Battlebacks/battlebg/field",
    "Graphics/Battlebacks/battlebg/cyclingroad_eve",
    "Graphics/Battlebacks/battlebg/cyclingroad_night",
    "Graphics/Battlebacks/battlebg/cyclingroad",
    "Graphics/Battlebacks/battlebg/cave_eve",
    "Graphics/Battlebacks/battlebg/cave_night",
    "Graphics/Battlebacks/battlebg/cave-granite_night",
    "Graphics/Battlebacks/battlebg/cave-granite",
    "Graphics/Battlebacks/battlebg/cave",
    "Graphics/Battlebacks/battlebg/beach_eve",
    "Graphics/Battlebacks/battlebg/beach_night",
    "Graphics/Battlebacks/battlebg/beachspecial_night",
    "Graphics/Battlebacks/battlebg/beach",
    "Graphics/Battlebacks/battlebg/field_eve",
    "Graphics/Battlebacks/battlebg/cave.png",
    "Graphics/Battlebacks/battlebg/beach_eve.png",
    "Graphics/Battlebacks/battlebg/beach_night.png",
    "Graphics/Battlebacks/battlebg/beach.png",
    "Graphics/Battlebacks/battlebg/field_eve.png",
    "Graphics/Battlebacks/battlebg/mangroves.png",
    "Graphics/Battlebacks/battlebg/mangroves_eve.png",
    "Graphics/Battlebacks/battlebg/mangroves_night.png",
    "Graphics/Battlebacks/battlebg/beach.png",
    "Graphics/Battlebacks/battlebg/beach.png",
    "Graphics/Battlebacks/battlebg/mountain.png",
    "Graphics/Battlebacks/battlebg/mountain_eve.png",
    "Graphics/Battlebacks/battlebg/mountain_night.png",
    "Graphics/Battlebacks/battlebg/forest.png",
    "Graphics/Battlebacks/battlebg/forest_night.png",
    "Graphics/Battlebacks/battlebg/forest_eve.png",
    "Graphics/Battlebacks/battlebg/gym_2.png",
    "Graphics/Battlebacks/battlebg/gym_3.png",

  #"Graphics/Titles/bg_back"
  ]
  BACKGROUNDS_LIST_KANTO = [""]

  BGM = "Credits"
  KANTO_SCROLL_SPEED = 70 # Pixels per second , ajuster pour fitter avec la musique
  HOENN_SCROLL_SPEED = 52

  SECONDS_PER_BACKGROUND = 8
  SECONDS_PER_POKEMON_SPRITE = 6
  TEXT_OUTLINE_COLOR = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR = Color.new(0, 0, 0, 100)

  TEXT_TITLE_COLOR = Color.new(154, 216, 8)
  TEXT_TITLE_OUTLINE_COLOR = Color.new(0, 100, 0, 255)

  NB_SPRITES_TO_PRELOAD = 25

  TOTAL_NB_FRAMES = 4000 # set manually, depends on music length

  FUSION_SPRITES_MAX_OPACITY = 200
  NB_FRAMES_AT_MAX_OPACITY = 30

  def main
    endCredits() if $PokemonSystem.on_mobile

    @counter = 0.0
    @bg_index = 0
    @bitmap_height = Graphics.height
    @trim = Graphics.height / 10
    @realOY = -(Graphics.height - @trim)
    @customSpritesList = getSpritesList()
    if Settings::KANTO
      @scroll_speed = KANTO_SCROLL_SPEED
      @bg_list = BACKGROUNDS_LIST_KANTO
    else
      @scroll_speed = HOENN_SCROLL_SPEED
      @bg_list = BACKGROUNDS_LIST_HOENN
    end
    @bg_queue = @bg_list.shuffle

    @bg_transitioning = :fade_in
    @bg_transition_timer = 0.0

    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << pcred[0] + "\n"
        i = 1
        until i >= pcred.size
          plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << name + "\n" }
      end
      plugin_credits << "\n"
    end
    credits_version = Settings::KANTO ? CREDIT_KANTO : CREDIT_HOENN
    credits_version.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credits_version.gsub!(/{SPRITER_CREDITS}/, format_names_for_game_credits())
    credits_version.gsub!(/{CC_CREDITS}/, format_character_customization_names_for_game_credits(50))
    credit_lines = credits_version.split(/\n/)

    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    text_viewport.z = 99999

    # Single @bg creation — zoom and drift applied immediately
    @bg = IconSprite.new(0, 0)
    @bg.setBitmap(@bg_queue.shift)   # Pop first image off the queue
    @bg.opacity = 0
    setup_bg_zoom_and_drift(@bg)

    @pokemon_sprite = IconSprite.new(0, 0)
    @pokemon_sprite.z = @bg.z + 1
    @pokemon_sprite.setBitmap(@bg_queue[0] || @bg_list[0])  # placeholder bitmap
    @pokemon_sprite.opacity = 0

    @credit_sprites = []
    @total_height = credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
    for i in 0...num_bitmaps
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height)
      pbSetSystemFont(credit_bitmap)
      for j in 0...lines_per_bitmap
        line = credit_lines[i * lines_per_bitmap + j]
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1 # Centre align
        linewidth = Graphics.width
        for k in 0...line.length
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + Graphics.width / 2
            align = (k == 0) ? 2 : 0
            linewidth = Graphics.width / 2 - 20
          end

          # Strip <title> tag if present; use title color for the fill pass
          text_to_draw = line[k]
          is_title = false
          if text_to_draw =~ /\A<title>(.*)\z/m
            is_title = true
            text_to_draw = $1
          end

          base_color = is_title ? TEXT_TITLE_COLOR : TEXT_BASE_COLOR
          outline_color = is_title ? TEXT_TITLE_OUTLINE_COLOR : TEXT_OUTLINE_COLOR

          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos, j * 32 + 4, linewidth, 32, text_to_draw, align)
          credit_bitmap.font.color = outline_color
          credit_bitmap.draw_text(xpos + 2, j * 32 - 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos, j * 32 - 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos - 2, j * 32 - 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos + 2, j * 32, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos - 2, j * 32, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos + 2, j * 32 + 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos, j * 32 + 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.draw_text(xpos - 2, j * 32 + 2, linewidth, 32, text_to_draw, align)
          credit_bitmap.font.color = base_color
          credit_bitmap.draw_text(xpos, j * 32, linewidth, 32, text_to_draw, align)
        end
      end
      credit_sprite = Sprite.new(text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z = 9998
      credit_sprite.oy = @realOY - @bitmap_height * i
      @credit_sprites[i] = credit_sprite
    end

    #-------------------------------
    # Setup
    #-------------------------------
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition(20)
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    pbBGMFade(2.0)
    Graphics.freeze
    viewport.color = Color.new(0, 0, 0, 255) # Ensure screen is black
    Graphics.transition(20, "fadetoblack")
    @pokemon_sprite.dispose
    @bg.dispose
    @credit_sprites.each { |s| s.dispose if s }
    text_viewport.dispose
    viewport.dispose
    $PokemonGlobal.creditsPlayed = true
    pbBGMPlay(previousBGM)
  end

  def setup_pokemon_drift
    # Copy background velocity exactly so pokemon moves with the background
    @pokemon_drift_vx = @drift_vx
    @pokemon_drift_vy = @drift_vy
    @pokemon_drift_x = @pokemon_sprite.x.to_f
    @pokemon_drift_y = @pokemon_sprite.y.to_f
  end
  def setup_bg_zoom_and_drift(sprite)
    zoom = 1.5
    sprite.zoom_x = zoom
    sprite.zoom_y = zoom

    sprite.x = -(Graphics.width / 2)
    sprite.y = -(Graphics.height / 2) + 180

    speed = 16.0
    angle = rand * 2 * Math::PI
    @drift_vx = Math.cos(angle) * speed
    @drift_vy = Math.sin(angle) * speed

    @drift_x = sprite.x.to_f
    @drift_y = sprite.y.to_f
  end

  # def getSpritesList()
  #   spritesList = []
  #   $PokemonSystem.alt_sprite_substitutions.each_value do |value|
  #     if value.is_a?(PIFSprite)
  #       spritesList << value
  #     end
  #   end
  #
  #   selected_spritesList = spritesList.sample(NB_SPRITES_TO_PRELOAD)
  #   spriteLoader = BattleSpriteLoader.new
  #   for sprite in selected_spritesList
  #     spriteLoader.preload(sprite)
  #   end
  #
  #   return selected_spritesList
  # end

  def getSpritesList()
    spriteLoader = BattleSpriteLoader.new
    seen_pairs = []

    fusions = $Trainer.pokedex.list_seen_fusions
    fusions.each_with_index do |bodies, head_id|
      next if bodies.nil? || head_id == 0
      bodies.each_with_index do |seen, body_id|
        next if body_id == 0
        seen_pairs << [head_id, body_id] if seen == true
      end
    end

    return [] if seen_pairs.empty?

    sample_size = [NB_SPRITES_TO_PRELOAD, seen_pairs.size].min
    chosen_pairs = seen_pairs.sample(sample_size)

    chosen_pairs.map do |head_id, body_id|
      head_species = GameData::Species.get(head_id).species
      body_species = GameData::Species.get(body_id).species
      sprite = spriteLoader.obtain_pif_sprite(
        GameData::Species.get(fusionOf(head_species, body_species))
      )
      spriteLoader.preload(sprite)
      sprite
    end
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::USE) && $PokemonGlobal.creditsPlayed
      endCredits
      return true
    end
    return false
  end

  def endCredits
    $scene = Scene_Map.new
    pbBGMFade(1.0)
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

  def update
    delta = Graphics.delta_s
    @counter += delta
    @bg_transition_timer += delta

    fade_duration = 0.8   # seconds to fade out or in
    hold_duration = SECONDS_PER_BACKGROUND - (fade_duration * 2)

    case @bg_transitioning
    when :fade_in
      progress = [@bg_transition_timer / fade_duration, 1.0].min
      @bg.opacity = (progress * 200).to_i  # max opacity 200 for subtle look
      if @bg_transition_timer >= fade_duration
        @bg_transitioning = :hold
        @bg_transition_timer = 0.0
      end

    when :hold
      @bg.opacity = 200
      if @bg_transition_timer >= hold_duration
        @bg_transitioning = :fade_out
        @bg_transition_timer = 0.0
      end

    when :fade_out
      progress = [@bg_transition_timer / fade_duration, 1.0].min
      @bg.opacity = (200 * (1.0 - progress)).to_i
      if @bg_transition_timer >= fade_duration
        # Refill and reshuffle only once the queue is fully exhausted
        if @bg_queue.empty?
          @bg_queue = @bg_list.shuffle
        end
        @bg.setBitmap(@bg_queue.shift)
        setup_bg_zoom_and_drift(@bg)
        @bg_transitioning = :fade_in
        @bg_transition_timer = 0.0
      end
    end

    # Apply drift to background
    @drift_x += @drift_vx * delta
    @drift_y += @drift_vy * delta
    new_bg_x = @drift_x.round
    new_bg_y = @drift_y.round
    if @bg.x != new_bg_x || @bg.y != new_bg_y
      @bg.x = new_bg_x
      @bg.y = new_bg_y
    end

    # Apply drift to Pokémon sprite
    # if @pokemon_drift_vx
    #   @pokemon_drift_x += @pokemon_drift_vx * delta
    #   @pokemon_drift_y += @pokemon_drift_vy * delta
    #   new_pk_x = @pokemon_drift_x.round
    #   new_pk_y = @pokemon_drift_y.round
    #   if @pokemon_sprite.x != new_pk_x || @pokemon_sprite.y != new_pk_y
    #     @pokemon_sprite.x = new_pk_x
    #     @pokemon_sprite.y = new_pk_y
    #   end
    # end

    # --- Pokemon sprite counter init ---
    @sprites_counter = 0 if !@sprites_counter
    @frames_counter = 0 if !@frames_counter
    @frames_counter += 1

    stopShowingSprites = @frames_counter >= (TOTAL_NB_FRAMES - 300)
    pbBGSStop if @frames_counter > TOTAL_NB_FRAMES

    spriteLoader = BattleSpriteLoader.new

    # Pokémon Sprite Overlay
    @pokemon_cycle_timer = 0.0 if !@pokemon_cycle_timer
    @pokemon_cycle_timer += delta
    if @pokemon_cycle_timer >= SECONDS_PER_POKEMON_SPRITE
      @pokemon_cycle_timer -= SECONDS_PER_POKEMON_SPRITE
      if @customSpritesList.length > 0 && !stopShowingSprites
        @sprites_counter = 0
        randomSprite = @customSpritesList.sample
        @customSpritesList.delete(randomSprite)
        @pokemon_sprite.setBitmapDirectly(spriteLoader.load_random_alt_for_pif_sprite(randomSprite))
        @pokemon_sprite.x = rand(0..300)
        @pokemon_sprite.y = rand(0..200)
        @pokemon_sprite.opacity = 50
        @fadingIn = true
        setup_pokemon_drift
      end
    end

    # Handle Pokémon Sprite Fading (unchanged)
    if @fadingIn
      if @pokemon_sprite.opacity < FUSION_SPRITES_MAX_OPACITY
        @pokemon_sprite.opacity += 5
      else
        @fadingIn = false
      end
    else
      @sprites_counter += 1
      if @sprites_counter >= NB_FRAMES_AT_MAX_OPACITY
        @pokemon_sprite.opacity -= 3
      end
    end

    return if cancel?
    return if last?

    # Scroll the text
    @realOY += @scroll_speed * delta
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - @bitmap_height * i }
  end
end
