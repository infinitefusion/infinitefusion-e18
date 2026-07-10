class Sprite_Player < Sprite_Character
  ACRO_BIKE_RAMP_POSITION_OFFSET = 16
  ACRO_BIKE_TRICK_POSITION_OFFSET = 4

  def initialize(viewport, character = nil)
    super
    @viewport = viewport
    @outfit_bitmap = nil
    # @hat_bitmap = nil
    # @hat2_bitmap = nil

    hatFilename = ""
    hairFilename = ""
    @hat = Sprite_Hat.new(self, hatFilename, @character_name, @viewport, 3)
    @hat2 = Sprite_Hat.new(self, hatFilename, @character_name, @viewport, 2)
    @hair = Sprite_Hair.new(self, hairFilename, @character_name, @viewport)
    @bicycle = Sprite_Bicycle.new(self,"", @character_name, @viewport)

    @previous_skinTone = 0

    @current_bitmap = nil
    @previous_action = nil
    echoln "init playa"
    getClothedPlayerSprite(true)
  end


  def updateCharacterBitmap
    skinTone = $Trainer.skin_tone ? $Trainer.skin_tone : 0
    baseBitmapFilename = getBaseOverworldSpriteFilename(@character_name, skinTone)
    if !pbResolveBitmap(baseBitmapFilename)
      baseBitmapFilename = Settings::PLAYER_GRAPHICS_FOLDER + @character_name
    end
    AnimatedBitmap.new(baseBitmapFilename, @character_hue)
  end

  def applyDayNightTone
    super
    pbDayNightTint(@hat.sprite) if @hat && @hat.sprite.bitmap
    pbDayNightTint(@hat2.sprite) if @hat2 && @hat2.sprite.bitmap
    pbDayNightTint(@hair.sprite) if @hair && @hair.sprite.bitmap
    pbDayNightTint(@bicycle.sprite) if @bicycle && @bicycle.sprite.bitmap
  end

  def opacity=(value)
    super
    @hat.sprite.opacity = value if @hat && @hat.sprite.bitmap
    @hat2.sprite.opacity = value if @hat2 && @hat2.sprite.bitmap
    @hair.sprite.opacity = value if @hair && @hair.sprite.bitmap
    @bicycle.sprite.opacity = value if @bicycle && @bicycle.sprite.bitmap
  end

  def biking?
    @character_name.to_s.include?("bike")
  end

  def getClothedPlayerSprite(forceUpdate = false)
    if @previous_action != @character_name || forceUpdate
      @current_bitmap = generateClothedBitmap
    end
    @previous_action = @character_name
    return @current_bitmap
  end

  def generateClothedBitmap()
    @charbitmap.bitmap.clone # nekkid sprite
    baseBitmap = @charbitmap.bitmap.clone # nekkid sprite

    if $game_player.hasGraphicsOverride? && @character_name != "fish"
      @hair.update(@character_name, "", 0) if @hair
      @hat.update(@character_name, "", 0) if @hat
      @hat2.update(@character_name, "", 0) if @hat2
      @bicycle.update(@character_name, "", 0) if @bicycle
      return baseBitmap
    end

    outfitFilename = getOverworldOutfitFilename($Trainer.clothes, @character_name) #
    outfitFilename = getOverworldOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK) if !pbResolveBitmap(outfitFilename)
    hairFilename = getOverworldHairFilename($Trainer.hair)
    hatFilename = getOverworldHatFilename($Trainer.hat)
    hat2Filename = getOverworldHatFilename($Trainer.hat2)


    bicycleFilename = get_bicycle_filename

    hair_color_shift = $Trainer.hair_color
    hat_color_shift = $Trainer.hat_color
    hat2_color_shift = $Trainer.hat2_color

    clothes_color_shift = $Trainer.clothes_color

    hair_color_shift = 0 if !hair_color_shift
    hat_color_shift = 0 if !hat_color_shift
    hat2_color_shift = 0 if !hat2_color_shift

    clothes_color_shift = 0 if !clothes_color_shift
    bicycle_color_shift = $Trainer.bike_color || 0

    @hair.update(@character_name, hairFilename, hair_color_shift) if @hair
    @hat.update(@character_name, hatFilename, hat_color_shift) if @hat
    @hat2.update(@character_name, hat2Filename, hat2_color_shift) if @hat2
    @bicycle.update(@character_name, bicycleFilename, bicycle_color_shift) if @bicycle

    if !pbResolveBitmap(outfitFilename)
      raise "No temp clothes graphics available"
    end

    outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift) if pbResolveBitmap(outfitFilename)
    baseBitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect) if outfitBitmap
    @previous_action = @character_name
    return baseBitmap
  end

  def get_bicycle_filename
    if biking?
      bicycleFilename = getOverworldBicycleFilename
    else
      bicycleFilename = ""
    end
    return bicycleFilename
  end

  # When the player needs to be positioned differently relative to its normal position
  def apply_global_player_offsets
    if $PokemonGlobal.bicycle
      if $PokemonGlobal.acroBike
        self.y -= ACRO_BIKE_RAMP_POSITION_OFFSET
      end
      if $PokemonGlobal.bike_trick
        self.y -= ACRO_BIKE_TRICK_POSITION_OFFSET
      end
    end
  end

  def update
    super
    apply_global_player_offsets

    @hair.animate(@character_name) if @hair
    @hat.animate(@character_name) if @hat
    @hat2.animate(@character_name) if @hat2
    @bicycle.animate(@character_name) if @bicycle

    if $game_map.scrolling?
      @hat.adjustPositionForScreenScrolling if @hat
      @hat2.adjustPositionForScreenScrolling if @hat2
      @hair.adjustPositionForScreenScrolling if @hair
      @bicycle.adjustPositionForScreenScrolling if @bicycle
    end



    if Settings::GAME_ID == :IF_HOENN && $PokemonGlobal.diving
      self.z = -4
      @hat.adjust_layer if @hat
      @hat2.adjust_layer if @hat2
      @hair.adjust_layer if @hair
      @bicycle.adjust_layer if @bicycle
    end
  end

  def dispose
    super
    @hat.dispose if @hat
    @hat2.dispose if @hat2
    @hair.dispose if @hair
    @bicycle.dispose if @bicycle
  end

  def pbLoadOutfitBitmap(outfitFileName)
    begin
      outfitBitmap = RPG::Cache.load_bitmap("", outfitFileName)
      return outfitBitmap
    rescue
      return nil
    end
  end
end


