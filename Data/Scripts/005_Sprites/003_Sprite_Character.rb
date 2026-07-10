class BushBitmap
  def initialize(bitmap, isTile, depth)
    @bitmaps = []
    @bitmap = bitmap
    @isTile = isTile
    @isBitmap = @bitmap.is_a?(Bitmap)
    @depth = depth
    @manual_refresh = false
  end

  def dispose
    @bitmaps.each { |b| b.dispose if b }
  end

  def bitmap
    thisBitmap = (@isBitmap) ? @bitmap : @bitmap.bitmap
    current = (@isBitmap) ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current] = pbBushDepthTile(thisBitmap, @depth)
      else
        @bitmaps[current] = pbBushDepthBitmap(thisBitmap, @depth)
      end
    end
    return @bitmaps[current]
  end

  def pbBushDepthBitmap(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height / 4
    cy = charheight - depth - 2
    for i in 0...4
      y = i * charheight
      if cy >= 0
        ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
        ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
      end
      ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    end
    return ret
  end

  def pbBushDepthTile(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height
    cy = charheight - depth - 2
    y = charheight
    if cy >= 0
      ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
      ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
    end
    ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    return ret
  end
end

def event_is_trainer(event)
  return $game_map.events[event.id] && event.name[/trainer\((\d+)\)/i]
end

class Sprite_Character < RPG::Sprite
  attr_accessor :character
  attr_accessor :pending_bitmap
  attr_accessor :bitmap_override
  attr_accessor :charbitmap

  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    if darknessEffectOnCurrentMap()
      if @character.is_a?(Game_Event)
        $game_map.events[@character.id].erase if event_is_trainer(@character)
      end
    end

    @oldbushdepth = 0
    @spriteoffset = false
    if Settings::USE_REFLECTIONS && (!character || character == $game_player || (character.name[/reflection/i] rescue false))
      @reflection = Sprite_Reflection.new(self, viewport)
    end
    @surfbase = Sprite_SurfBase.new(self, character, viewport) if character == $game_player
    if @character && @character != $game_player
      checkModifySpriteGraphics(@character) if @character.active?
    end
    if @character && @character.character_name == "000"
      @character.character_name=""
    end
    update
  end

  def event_is_active?(game_event)
    return !game_event.event.page.nil?
  end

  def checkModifySpriteGraphics(character)
    return if character.is_a?(Game_Player)
    return if character.is_a?(OverworldPokemonEvent)
    return unless character.name
    if TYPE_EXPERTS_APPEARANCES.keys.include?(character.name.to_sym)
      typeExpert = character.name.to_sym
      setSpriteToAppearance(TYPE_EXPERTS_APPEARANCES[typeExpert])
    end
  end

  def setSpriteToStaticAppearance(file_path)
    begin
      new_bitmap = AnimatedBitmap.new(file_path)
      @bitmap_override = new_bitmap
      updateBitmap
    rescue
    end
  end
  def setSpriteToAppearance(trainerAppearance)
    #return if !@charbitmap || !@charbitmap.bitmap
    begin
      new_bitmap = AnimatedBitmap.new(getBaseOverworldSpriteFilename()) #@charbitmap
      new_bitmap.bitmap = generateNPCClothedBitmapStatic(trainerAppearance)
      @bitmap_override = new_bitmap
      updateBitmap
    rescue
    end
  end

  def clearBitmapOverride()
    @bitmap_override = nil
    updateBitmap
  end

  def setSurfingPokemon(pokemonSpecies)
    @surfingPokemon = pokemonSpecies
    @surfbase.setPokemon(pokemonSpecies) if @surfbase
  end

  def groundY
    return @character.screen_y_ground
  end

  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
  end

  def dispose
    @bushbitmap.dispose if @bushbitmap
    @bushbitmap = nil
    @charbitmap.dispose if @charbitmap
    @charbitmap = nil
    @reflection.dispose if @reflection
    @reflection = nil
    @surfbase.dispose if @surfbase
    @surfbase = nil
    super
  end

  def updateBitmap
    return if @manual_refresh
    @manual_refresh = true
  end


  def pbLoadOutfitBitmap(outfitFileName)
    # Construct the file path for the outfit bitmap based on the given value
    #outfitFileName = sprintf("Graphics/Outfits/%s", value)

    # Attempt to load the outfit bitmap
    begin
      outfitBitmap = RPG::Cache.load_bitmap("", outfitFileName)
      return outfitBitmap
    rescue
      return nil
    end
  end

  def generateClothedBitmap()
    return
  end

  def applyDayNightTone()
    if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
      self.tone.set(0, 0, 0, 0)
    else
      pbDayNightTint(self)
    end
  end

  def updateCharacterBitmap
    checkModifySpriteGraphics(@character)
    return AnimatedBitmap.new('Graphics/Characters/' + @character_name, @character_hue)
  end

  def should_update?
    return true if @manual_refresh
    return false if !@character
    @tile_id        != @character.tile_id ||
      @character_name != @character.character_name ||
      @character_hue  != @character.character_hue ||
      @oldbushdepth   != @character.bush_depth
  end

  def refreshOutfit()
    self.pending_bitmap = getClothedPlayerSprite(true)
  end

  def update
    if self.pending_bitmap
      self.bitmap = self.pending_bitmap
      self.pending_bitmap = nil
    end
    return unless @character
    return if @character.is_a?(Game_Event) && !@character.should_update?
    super
    if should_update?
      unless self.is_a?(Sprite_Player)
        @shadow.visible = self.visible if @shadow
      end

      @manual_refresh = false
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      @oldbushdepth = @character.bush_depth
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                      @character_hue, @character.width, @character.height)
        @charbitmapAnimated = false
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        @spriteoffset = false
        @cw = Game_Map::TILE_WIDTH * @character.width
        @ch = Game_Map::TILE_HEIGHT * @character.height
        self.src_rect.set(0, 0, @cw, @ch)
        self.ox = @cw / 2
        self.oy = @ch
        @character.sprite_size = [@cw, @ch]
      else
        @charbitmap.dispose if @charbitmap

        @charbitmap = updateCharacterBitmap()
        @charbitmap = @bitmap_override.clone if @bitmap_override

        RPG::Cache.retain('Graphics/Characters/', @character_name, @character_hue) if @character == $game_player
        @charbitmapAnimated = true
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        #@spriteoffset = @character_name[/offset/i]
        if @character == $game_player
          @spriteoffset = @character_name[/fish/i] || @character_name[/dive/i] || @character_name[/surf/i]
        end
        @cw = @charbitmap.width / 4 if !@charbitmap.disposed?
        @ch = @charbitmap.height / 4 if !@charbitmap.disposed?
        self.ox = @cw / 2
        @character.sprite_size = [@cw, @ch]
      end
      @manual_refresh = false
    end
    @charbitmap.update if @charbitmapAnimated
    bushdepth = @character.bush_depth if @character
    if bushdepth == 0
      if @character == $game_player
        self.bitmap = getClothedPlayerSprite() #generateClothedBitmap()
      else
        self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
      end
    else
      @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
      self.bitmap = @bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
      self.oy -= @character.bob_height
    end
    if self.visible
      applyDayNightTone()
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    #    self.zoom_x     = Game_Map::TILE_WIDTH / 32.0
    #    self.zoom_y     = Game_Map::TILE_HEIGHT / 32.0
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    #    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    @reflection.update if @reflection
    @surfbase.update if @surfbase
  end
end
# frozen_string_literal: true

