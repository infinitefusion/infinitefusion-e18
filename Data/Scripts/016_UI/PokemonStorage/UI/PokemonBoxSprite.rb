#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites
  attr_accessor :filterProc
  attr_reader :boxnumber
  def initialize(storage, boxnumber, viewport = nil, fusionsEnabled = true, filter = nil)
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @pokemonsprites = []
    @filterProc = filter
    for i in 0...PokemonBox::BOX_SIZE
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber, i]
      @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
      @pokemonsprites[i].apply_filter(@filterProc)
    end
    @contents = BitmapWrapper.new(324, 296)
    self.bitmap = @contents
    self.x = 184
    self.y = 18
    @fusions_enabled = fusionsEnabled
    refresh
  end

  def setFilterProc(filter)
    @filterProc=filter
  end

  def disableFusions()
    #@fusions_enabled = false
    @filterProc = proc { |pokemon| pokemon&.isFusion? == false }
    refreshAllBoxSprites()
  end

  def enableFusions()
    @filterProc = nil
   # @fusions_enabled = true
    refreshAllBoxSprites()
  end

  def isFusionEnabled
    return @fusions_enabled
  end

  def dispose
    if !disposed?
      for i in 0...PokemonBox::BOX_SIZE
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @boxbitmap.dispose
      @contents.dispose
      super
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...PokemonBox::BOX_SIZE
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg != @storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || (curbg.is_a?(String) && curbg.length == 0)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
      else
        if curbg.is_a?(String) && curbg[/^box(\d+)$/]
          curbg = $~[1].to_i
          @storage[@boxnumber].background = curbg
        end
        @bg = curbg
      end
      if !@storage.isAvailableWallpaper?(@bg)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
        @storage[@boxnumber].background = @bg
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/Wallpapers/box_#{@bg}")
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites[index].refresh
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      update
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    update
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 324, 296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      xval = 162 - (widthval / 2)
      pbDrawShadowText(@contents, xval, 8, widthval, 32,
                       boxname, Color.new(248, 248, 248), Color.new(40, 48, 48))
      @refreshBox = false
    end
    yval = self.y + 30
    for j in 0...PokemonBox::BOX_HEIGHT
      xval = self.x + 10
      for k in 0...PokemonBox::BOX_WIDTH
        sprite = @pokemonsprites[j * PokemonBox::BOX_WIDTH + k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.x = xval
          sprite.y = yval
          sprite.z = 1
        end
        xval += 48
      end
      yval += 48
    end
  end

  #@filterProc is called on the @pokemon object of each BoxIcon.
  # If true, full opacity, selectable, otherwise, low opacity, not selectable
  def refreshAllBoxSprites()
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].refresh
        @pokemonsprites[i].apply_filter(@filterProc)
      end
      # spriteLoader.preload_sprite_from_pokemon(@pokemonsprites[i].pokemon) if @pokemonsprites[i].pokemon
    end
  end

  def update
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
        #@pokemonsprites[i].apply_filter(@filterProc)
      end
    end
  end
end
