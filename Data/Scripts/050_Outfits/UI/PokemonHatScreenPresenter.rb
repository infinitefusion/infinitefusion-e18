class PokemonHatPresenter
  PIXELS_PER_MOVEMENT = 4

  def initialize(view, pokemon)
    @view = view
    @pokemon = pokemon
    @hatFilename = "Graphics/Characters/player/hat/trainer/hat_trainer_1"
    @sprites = {}

    @x_pos = pokemon.hat_x ? pokemon.hat_x : 0
    @y_pos = pokemon.hat_y ? pokemon.hat_y : 0
    @hat_mirrored_horizontal = pokemon.hat_mirrored_horizontal ? pokemon.hat_mirrored_horizontal : false
    @hat_mirrored_vertical = pokemon.hat_mirrored_vertical ? pokemon.hat_mirrored_vertical : false
    @hat_id = pokemon.hat ? pokemon.hat : 1
    @viewport = nil
    @previewwindow = nil

    @original_pokemon_bitmap = nil

    @min_x, @max_x = -64, 88
    @min_y, @max_y = -120, 120  # Safe symmetric range

    @hatBitmapWrapper = AnimatedBitmap.new(@hatFilename, 0) if pbResolveBitmap(@hatFilename)
    @hatBitmapWrapper.mirror_horizontally if @hatBitmapWrapper &&  @hat_mirrored_horizontal
    @hatBitmapWrapper.mirror_vertically if @hatBitmapWrapper && @hat_mirrored_vertical
  end

  def pbStartScreen
    @view.init_window(self)
    cancel if !select_hat()
    if position_hat()
      updatePokemonHatPosition()
    else
      cancel
    end
    @view.hide_move_arrows
    @view.hide_select_arrows
    @view.dispose_window()
  end

  def updatePokemonHatPosition()
    @pokemon.hat = @hat_id
    @pokemon.hat_mirrored_horizontal=@hat_mirrored_horizontal
    @pokemon.hat_mirrored_vertical=@hat_mirrored_vertical
    @pokemon.hat_x = @x_pos
    @pokemon.hat_y = @y_pos
  end

  def cancel
    @pokemon.hat = nil
  end

  def select_hat
    selector = OutfitSelector.new
    @view.display_select_arrows
    outfit_type_path = get_hats_sets_list_path()
    @pokemon.hat = 0 if !@pokemon.hat
    loop do
      Graphics.update
      Input.update
      @hat_id = selector.selectNextOutfit(@hat_id, 1, selector.hats_list, [], false, "hat",$Trainer.unlocked_hats,false) if Input.trigger?(Input::RIGHT)
      @hat_id = selector.selectNextOutfit(@hat_id, -1, selector.hats_list, [], false, "hat",$Trainer.unlocked_hats,false) if Input.trigger?(Input::LEFT)
      flipHatVertically if Input.trigger?(Input::JUMPUP)
      flipHatHorizontally if Input.trigger?(Input::JUMPDOWN)
      resetHatPosition if Input.trigger?(Input::SPECIAL)
      break if Input.trigger?(Input::USE)
      return false if Input.trigger?(Input::BACK)
      @view.update()
    end
    updatePokemonHatPosition
    @view.hide_select_arrows

  end

  def position_hat
    @view.display_move_arrows

    loop do
      Graphics.update
      Input.update
      @x_pos += PIXELS_PER_MOVEMENT if Input.repeat?(Input::RIGHT) && @x_pos < @max_x
      @x_pos -= PIXELS_PER_MOVEMENT if Input.repeat?(Input::LEFT) && @x_pos > @min_x
      @y_pos += PIXELS_PER_MOVEMENT if Input.repeat?(Input::DOWN) && @y_pos < @max_y
      @y_pos -= PIXELS_PER_MOVEMENT if Input.repeat?(Input::UP) && @y_pos > @min_y
      flipHatHorizontally if Input.trigger?(Input::JUMPDOWN)
      flipHatVertically if Input.trigger?(Input::JUMPUP)
      resetHatPosition if Input.trigger?(Input::SPECIAL)

      break if Input.trigger?(Input::USE)
      return false if Input.trigger?(Input::BACK)
      @view.update()
    end
    resetHatVisualFlip
    @view.hide_move_arrows
    return true
  end

  #Let the sprite display stuff handle the actual flipping
  def resetHatVisualFlip
    return unless @hatBitmapWrapper
    @hatBitmapWrapper.mirror_horizontally if @hat_mirrored_horizontal
    @hatBitmapWrapper.mirror_vertically if @hat_mirrored_vertical
  end


  def flipHatHorizontally()
    return unless @hatBitmapWrapper
    @hat_mirrored_horizontal = !@hat_mirrored_horizontal
    pbSEPlay("GUI storage pick up")
    @hatBitmapWrapper.mirror_horizontally
    pbWait(8)
  end


  def flipHatVertically()
    return unless @hatBitmapWrapper
    pbSEPlay("GUI storage pick up")
    @hat_mirrored_vertical = !@hat_mirrored_vertical
    @hatBitmapWrapper.mirror_vertically

    # Compensate for visual shift after vertical flip
    hat_height = @hatBitmapWrapper.bitmap.height
    offset = hat_height - 40

    if @hat_mirrored_vertical
      @y_pos -= offset
    else
      @y_pos += offset
    end
    @y_pos = [[@y_pos, @min_y].max, @max_y].min
    pbWait(8)
  end

  def resetHatPosition
    if pbConfirmMessage(_INTL("Reset hat position?"))
      pbSEPlay("GUI naming tab swap end")
      @x_pos=0
      @y_pos=0
      @hatBitmapWrapper.mirror_horizontally if @hat_mirrored_horizontal
      @hatBitmapWrapper.mirror_vertically if @hat_mirrored_vertical
      @hat_mirrored_horizontal = false
      @hat_mirrored_vertical = false
    end
  end

  def initialize_bitmap()
    spriteLoader = BattleSpriteLoader.new

    if $PokemonSystem.random_sprites
      @original_pokemon_bitmap = spriteLoader.load_pif_sprite_pokemon(@pokemon)
    else
      if @pokemon.isTripleFusion?
        #todo
      elsif @pokemon.isFusion?
        @original_pokemon_bitmap = spriteLoader.load_fusion_sprite(@pokemon.head_id(),@pokemon.body_id())
      else
        @original_pokemon_bitmap = spriteLoader.load_base_sprite(@pokemon.id_number)
      end
    end

    @original_pokemon_bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
  end

  def getPokemonHatBitmap()
    @hatFilename = getTrainerSpriteHatFilename(@hat_id)
    @hatBitmapWrapper = AnimatedBitmap.new(@hatFilename, 0) if pbResolveBitmap(@hatFilename)
    pokemon_bitmap = @original_pokemon_bitmap.bitmap.clone
    pokemon_bitmap.blt(@x_pos, @y_pos, @hatBitmapWrapper.bitmap, @hatBitmapWrapper.bitmap.rect) if @hatBitmapWrapper
    return pokemon_bitmap
  end

end
