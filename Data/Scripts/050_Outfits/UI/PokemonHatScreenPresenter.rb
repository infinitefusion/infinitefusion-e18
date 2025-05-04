class PokemonHatPresenter
  PIXELS_PER_MOVEMENT = 4

  def initialize(view, pokemon)
    @view = view
    @pokemon = pokemon
    @hatFilename = "Graphics/Characters/player/hat/trainer/hat_trainer_1"
    @sprites = {}

    @x_pos = pokemon.hat_x ? pokemon.hat_x : 0
    @y_pos = pokemon.hat_y ? pokemon.hat_y : 0
    @hat_id = pokemon.hat ? pokemon.hat : 1
    @viewport = nil
    @previewwindow = nil

    @original_pokemon_bitmap = nil
  end

  # def getPicturePath()
  #   if @pokemon.isTripleFusion?
  #     picturePath = GameData::Species::getSpecialSpriteName(@pokemon.species_data.id_number)
  #   elsif @pokemon.isFusion?
  #     picturePath = get_fusion_sprite_path(@pokemon.species_data.head_pokemon.id_number, @pokemon.species_data.body_pokemon.id_number)
  #   else
  #     picturePath = get_unfused_sprite_path(@pokemon.species_data.id_number)
  #   end
  #   echoln picturePath
  #   return picturePath
  # end

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
      break if Input.trigger?(Input::USE)
      return false if Input.trigger?(Input::BACK)
      @view.update()
    end
    @pokemon.hat = @hat_id
    @view.hide_select_arrows

  end

  def position_hat
    @view.display_move_arrows
    min_x, max_x = -64, 88
    min_y, max_y = -20, 140
    loop do
      Graphics.update
      Input.update
      @x_pos += PIXELS_PER_MOVEMENT if Input.repeat?(Input::RIGHT) && @x_pos < max_x
      @x_pos -= PIXELS_PER_MOVEMENT if Input.repeat?(Input::LEFT) && @x_pos > min_x
      @y_pos += PIXELS_PER_MOVEMENT if Input.repeat?(Input::DOWN) && @y_pos < max_y
      @y_pos -= PIXELS_PER_MOVEMENT if Input.repeat?(Input::UP) && @y_pos > min_y
      break if Input.trigger?(Input::USE)
      return false if Input.trigger?(Input::BACK)
      @view.update()
    end
    @view.hide_move_arrows
    return true
  end

  def initialize_bitmap()
    spriteLoader = BattleSpriteLoader.new

    if @pokemon.isTripleFusion?
      #todo
    elsif @pokemon.isFusion?
      @original_pokemon_bitmap = spriteLoader.load_fusion_sprite(@pokemon.head_id(),@pokemon.body_id())
    else
      echoln @pokemon
      echoln @pokemon.species_data
      @original_pokemon_bitmap = spriteLoader.load_base_sprite(@pokemon.id_number)
    end

    # picturePath = getPicturePath()
    # if picturePath
    #   @original_pokemon_bitmap = AnimatedBitmap.new(picturePath)
    # else
    #   @original_pokemon_bitmap = GameData::Species.setAutogenSprite(@pokemon)
    #   #autogen
    # end
    @original_pokemon_bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
  end

  def getPokemonHatBitmap()
    @hatFilename = getTrainerSpriteHatFilename(@hat_id)
    hatBitmapWrapper = AnimatedBitmap.new(@hatFilename, 0) if pbResolveBitmap(@hatFilename)
    pokemon_bitmap = @original_pokemon_bitmap.bitmap.clone
    pokemon_bitmap.blt(@x_pos, @y_pos, hatBitmapWrapper.bitmap, hatBitmapWrapper.bitmap.rect) if hatBitmapWrapper
    return pokemon_bitmap
  end

end
