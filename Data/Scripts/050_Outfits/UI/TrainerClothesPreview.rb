class TrainerClothesPreview
  attr_writer :pokeball, :clothes, :hat, :hair, :skin_tone, :hair_color, :hat_color, :clothes_color

  def initialize(x = 0, y = 0, windowed = true, pokeball = nil)
    @playerBitmap = nil
    @playerSprite = nil
    @x_pos = x
    @y_pos = y
    @windowed = windowed

    @pokeball = pokeball
    resetOutfits()
  end

  def resetOutfits()
    @clothes = $Trainer.clothes
    @hat = $Trainer.hat
    @hair = $Trainer.hair
    @skin_tone = $Trainer.skin_tone
    @hair_color = $Trainer.hair_color
    @hat_color = $Trainer.hat_color
    @clothes_color = $Trainer.clothes_color
  end

  def show()
    @playerBitmap = generate_front_trainer_sprite_bitmap(false,
                                                         @pokeball,
                                                         @clothes, @hat, @hair,
                                                         @skin_tone,
                                                         @hair_color, @hat_color, @clothes_color)
    initialize_preview()
  end

  def updatePreview()
    erase()
    show()
  end

  def initialize_preview()
    @playerSprite = PictureWindow.new(@playerBitmap)
    @playerSprite.opacity = 0 if !@windowed

    @playerSprite.x = @x_pos
    @playerSprite.y = @y_pos
    @playerSprite.z = 9999
    @playerSprite.update
  end

  def erase()
    @playerSprite.dispose if @playerSprite
  end

end