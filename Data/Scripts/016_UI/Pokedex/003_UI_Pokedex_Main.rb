#===============================================================================
#
#===============================================================================
class Window_Pokedex < Window_DrawableCommand
  def initialize(x, y, width, height, viewport)
    @commands = []
    super(x, y, width, height, viewport)
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_list")
    @pokeballOwn = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_own")

    icon_seen_path = "Graphics/Pictures/Pokedex/icon_seen"
    if isDarkMode
      icon_seen_path_dark = icon_seen_path + "_dark"
      icon_seen_path = icon_seen_path_dark if pbResolveBitmap(icon_seen_path_dark)
    end
    @pokeballSeen = AnimatedBitmap.new(icon_seen_path)
    @allow_arrows_jump = true
    self.baseColor = Color.new(88, 88, 80)
    self.shadowColor = Color.new(168, 184, 184)

    if isDarkMode
      self.baseColor, self.shadowColor = self.shadowColor, self.baseColor
    end

    self.windowskin = nil
  end

  def commands=(value)
    @commands = value
    refresh
  end

  def dispose
    @pokeballOwn.dispose
    @pokeballSeen.dispose
    super
  end

  def species
    if self.index > @commands.size - 1
      self.index = 0
    end
    current_position = self.index
    return (@commands.length == 0) ? 0 : @commands[current_position][0]
  end

  def itemCount
    return @commands.length
  end

  def drawItem(index, _count, rect)
    return if index >= self.top_row + self.page_item_max
    rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
    species = @commands[index][0]
    indexNumber = @commands[index][4]
    indexNumber -= 1 if @commands[index][5]
    if $Trainer.seen?(species)
      if $Trainer.owned?(species)
        pbCopyBitmap(self.contents, @pokeballOwn.bitmap, rect.x - 6, rect.y + 8)
      else
        pbCopyBitmap(self.contents, @pokeballSeen.bitmap, rect.x - 6, rect.y + 8)
      end
      text = sprintf("%03d%s %s", indexNumber, " ", @commands[index][1])
    else
      text = sprintf("%03d  ----------", indexNumber)
    end
    pbDrawShadowText(self.contents, rect.x + 36, rect.y + 6, rect.width, rect.height,
                     text, self.baseColor, self.shadowColor)
  end

  def refresh
    @item_max = itemCount
    dwidth = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i < self.top_item || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def update
    super
    @uparrow.visible = false
    @downarrow.visible = false
  end
end

#===============================================================================
#
#===============================================================================
class PokedexSearchSelectionSprite < SpriteWrapper
  attr_reader :index
  attr_accessor :cmds
  attr_accessor :minmax

  def initialize(viewport = nil)
    super(viewport)
    @selbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_search")
    self.bitmap = @selbitmap.bitmap
    self.mode = -1
    @index = 0
    refresh
  end

  def dispose
    @selbitmap.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def mode=(value)
    @mode = value
    case @mode
    when 0 # Order
      @xstart = 46; @ystart = 128
      @xgap = 236; @ygap = 64
      @cols = 2
    when 1 # Name
      @xstart = 78; @ystart = 114
      @xgap = 52; @ygap = 52
      @cols = 7
    when 2 # Type
      @xstart = 8; @ystart = 104
      @xgap = 124; @ygap = 44
      @cols = 4
    when 3, 4 # Height, weight
      @xstart = 44; @ystart = 110
      @xgap = 8; @ygap = 112
    when 5 # Color
      @xstart = 62; @ystart = 114
      @xgap = 132; @ygap = 52
      @cols = 3
    when 6 # Shape
      @xstart = 82; @ystart = 116
      @xgap = 70; @ygap = 70
      @cols = 5
    end
  end

  def refresh
    # Size and position cursor
    if @mode == -1 # Main search screen
      case @index
      when 0 # Order
        self.src_rect.y = 0; self.src_rect.height = 44
      when 1, 5 # Name, color
        self.src_rect.y = 44; self.src_rect.height = 44
      when 2 # Type
        self.src_rect.y = 88; self.src_rect.height = 44
      when 3, 4 # Height, weight
        self.src_rect.y = 132; self.src_rect.height = 44
      when 6 # Form
        self.src_rect.y = 176; self.src_rect.height = 68
      else
        # Reset/start/cancel
        self.src_rect.y = 244; self.src_rect.height = 40
      end
      case @index
      when 0 # Order
        self.x = 252; self.y = 52
      when 1, 2, 3, 4 # Name, type, height, weight
        self.x = 114; self.y = 110 + (@index - 1) * 52
      when 5 # Color
        self.x = 382; self.y = 110
      when 6 # Shape
        self.x = 420; self.y = 214
      when 7, 8, 9 # Reset, start, cancel
        self.x = 4 + (@index - 7) * 176; self.y = 334
      end
    else
      # Parameter screen
      case @index
      when -2, -3 # OK, Cancel
        self.src_rect.y = 244; self.src_rect.height = 40
      else
        case @mode
        when 0 # Order
          self.src_rect.y = 0; self.src_rect.height = 44
        when 1 # Name
          self.src_rect.y = 284; self.src_rect.height = 44
        when 2, 5 # Type, color
          self.src_rect.y = 44; self.src_rect.height = 44
        when 3, 4 # Height, weight
          self.src_rect.y = (@minmax == 1) ? 328 : 424; self.src_rect.height = 96
        when 6 # Shape
          self.src_rect.y = 176; self.src_rect.height = 68
        end
      end
      case @index
      when -1 # Blank option
        if @mode == 3 || @mode == 4 # Height/weight range
          self.x = @xstart + (@cmds + 1) * @xgap * (@minmax % 2)
          self.y = @ystart + @ygap * ((@minmax + 1) % 2)
        else
          self.x = @xstart + (@cols - 1) * @xgap
          self.y = @ystart + (@cmds / @cols).floor * @ygap
        end
      when -2 # OK
        self.x = 4; self.y = 334
      when -3 # Cancel
        self.x = 356; self.y = 334
      else
        case @mode
        when 0, 1, 2, 5, 6 # Order, name, type, color, shape
          if @index >= @cmds
            self.x = @xstart + (@cols - 1) * @xgap
            self.y = @ystart + (@cmds / @cols).floor * @ygap
          else
            self.x = @xstart + (@index % @cols) * @xgap
            self.y = @ystart + (@index / @cols).floor * @ygap
          end
        when 3, 4 # Height, weight
          if @index >= @cmds
            self.x = @xstart + (@cmds + 1) * @xgap * ((@minmax + 1) % 2)
          else
            self.x = @xstart + (@index + 1) * @xgap
          end
          self.y = @ystart + @ygap * ((@minmax + 1) % 2)
        end
      end
    end
  end
end

#===============================================================================
# Pokédex main screen
#===============================================================================
class PokemonPokedex_Scene
  MODENUMERICAL = 0
  MODEATOZ = 1
  MODETALLEST = 2
  MODESMALLEST = 3
  MODEHEAVIEST = 4
  MODELIGHTEST = 5

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(filter_owned = false)
    @filter_owned = filter_owned
    @sliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
    @typebitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_types")
    @shapebitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
    @hwbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
    @selbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchslider")
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "background", "Pokedex/bg_list", @viewport)
=begin
    # Suggestion for changing the background depending on region. You can change
    # the line above with the following:
    if pbGetPokedexRegion==-1   # Using national Pokédex
      addBackgroundPlane(@sprites,"background","Pokedex/bg_national",@viewport)
    elsif pbGetPokedexRegion==0   # Using first regional Pokédex
      addBackgroundPlane(@sprites,"background","Pokedex/bg_regional",@viewport)
    end
=end
    addBackgroundPlane(@sprites, "searchbg", "Pokedex/bg_search", @viewport)
    @sprites["searchbg"].visible = false
    @sprites["pokedex"] = Window_Pokedex.new(206, 30, 276, 364, @viewport)
    @sprites["icon"] = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::Center)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["icon"].zoom_y = Settings::FRONTSPRITE_SCALE
    @sprites["icon"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    @sprites["searchcursor"].visible = false
    @searchResults = false
    @searchParams = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @typebitmap.dispose
    @shapebitmap.dispose
    @hwbitmap.dispose
    @selbitmap.dispose
    @searchsliderbitmap.dispose
    @viewport.dispose
  end

  # Gets the region used for displaying Pokédex entries. Species will be listed
  # according to the given region's numbering and the returned region can have
  # any value defined in the town map data file. It is currently set to the
  # return value of pbGetCurrentRegion, and thus will change according to the
  # current map's MapPosition metadata setting.
  def pbGetPokedexRegion
    if Settings::USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region >= $Trainer.pokedex.dexes_count - 1
      return region
    else
      return $PokemonGlobal.pokedexDex # National Dex -1, regional Dexes 0, 1, etc.
    end
  end

  # Determines which index of the array $PokemonGlobal.pokedexIndex to save the
  # "last viewed species" in. All regional dexes come first in order, then the
  # National Dex at the end.
  def pbGetSavePositionIndex
    index = pbGetPokedexRegion
    if index == -1 # National Dex (comes after regional Dex indices)
      index = $Trainer.pokedex.dexes_count - 1
    end
    return index
  end

  def pbCanAddForModeList?(mode, species)
    case mode
    when MODEATOZ
      return $Trainer.seen?(species)
    when MODEHEAVIEST, MODELIGHTEST, MODETALLEST, MODESMALLEST
      return $Trainer.owned?(species)
    end
    return true # For MODENUMERICAL
  end

  # def pbGetDexList
  #   region = pbGetPokedexRegion
  #   regionalSpecies = pbAllRegionalSpecies(region)
  #   if !regionalSpecies || regionalSpecies.length == 0
  #     # If no Regional Dex defined for the given region, use the National Pokédex
  #     regionalSpecies = []
  #     GameData::Species.each { |s| regionalSpecies.push(s.id) if s.form == 0 }
  #   end
  #   shift = Settings::DEXES_WITH_OFFSETS.include?(region)
  #   ret = []
  #   regionalSpecies.each_with_index do |species, i|
  #     next if !species
  #     next if !pbCanAddForModeList?($PokemonGlobal.pokedexMode, species)
  #     species_data = GameData::Species.get(species)
  #     color  = species_data.color
  #     type1  = species_data.type1
  #     type2  = species_data.type2 || type1
  #     shape  = species_data.shape
  #     height = species_data.height
  #     weight = species_data.weight
  #     ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape])
  #   end
  #   return ret
  # end

  def pbGetDexList(filter_owned = false)
    dexlist = []
    regionalSpecies = []
    for i in 1..PBSpecies.maxValue
      regionalSpecies.push(i)
    end
    for i in 1...PBSpecies.maxValue
      nationalSpecies = i
      if $Trainer.seen?(nationalSpecies)
        if !filter_owned || $Trainer.owned?(nationalSpecies)
          species = GameData::Species.get(nationalSpecies)
          dexlist.push([species.id_number, species.name, 0, 0, i + 1, 0])
        end
      end
    end
    return dexlist
  end

  def pbRefreshDexList(index = 0)
    if index == nil
      index = 0
    end
    dexlist = pbGetDexList(@filter_owned)
    case $PokemonGlobal.pokedexMode
    when MODENUMERICAL
      # Hide the Dex number 0 species if unseen
      dexlist[0] = nil if dexlist[0][5] && !$Trainer.seen?(dexlist[0][0])
      # Remove unseen species from the end of the list
      i = dexlist.length - 1
      loop do
        break unless i >= 0
        break if !dexlist[i] || $Trainer.seen?(dexlist[i][0])
        dexlist[i] = nil
        i -= 1
      end
      dexlist.compact!
      # Sort species in ascending order by Regional Dex number
      dexlist.sort! { |a, b| a[4] <=> b[4] }
    when MODEATOZ
      dexlist.sort! { |a, b| (a[1] == b[1]) ? a[4] <=> b[4] : a[1] <=> b[1] }
    when MODEHEAVIEST
      dexlist.sort! { |a, b| (a[3] == b[3]) ? a[4] <=> b[4] : b[3] <=> a[3] }
    when MODELIGHTEST
      dexlist.sort! { |a, b| (a[3] == b[3]) ? a[4] <=> b[4] : a[3] <=> b[3] }
    when MODETALLEST
      dexlist.sort! { |a, b| (a[2] == b[2]) ? a[4] <=> b[4] : b[2] <=> a[2] }
    when MODESMALLEST
      dexlist.sort! { |a, b| (a[2] == b[2]) ? a[4] <=> b[4] : a[2] <=> b[2] }
    end
    @dexlist = dexlist
    @sprites["pokedex"].commands = @dexlist
    @sprites["pokedex"].index = index
    @sprites["pokedex"].refresh
    if @searchResults
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
    end
    pbRefresh
  end

  def pbRefresh
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    if isDarkMode
      base, shadow = shadow, base
    end

    iconspecies = @sprites["pokedex"].species
    iconspecies = nil if !$Trainer.seen?(iconspecies)
    # Write various bits of text
    dexname = _INTL("Pokédex")
    if $Trainer.pokedex.dexes_count > 1
      thisdex = Settings.pokedex_names[pbGetSavePositionIndex]
      if thisdex != nil
        dexname = (thisdex.is_a?(Array)) ? thisdex[0] : thisdex
      end
    end
    textpos = [
      [dexname, Graphics.width / 2, -2, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)]
    ]
    textpos.push([GameData::Species.get(iconspecies).name, 112, 46, 2, base, shadow]) if iconspecies
    if @searchResults
      textpos.push([_INTL("Search results"), 112, 302, 2, base, shadow])
      textpos.push([@dexlist.length.to_s, 112, 334, 2, base, shadow])
    else
      textpos.push([_INTL("Seen:"), 42, 302, 0, base, shadow])
      textpos.push([$Trainer.pokedex.seen_count(pbGetPokedexRegion).to_s, 182, 302, 1, base, shadow])
      textpos.push([_INTL("Owned:"), 42, 334, 0, base, shadow])
      textpos.push([$Trainer.pokedex.owned_count(pbGetPokedexRegion).to_s, 182, 334, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Set Pokémon sprite
    setIconBitmap(iconspecies) if iconspecies
    # Draw slider arrows
    itemlist = @sprites["pokedex"]
    showslider = false
    if itemlist.top_row > 0
      overlay.blt(468, 48, @sliderbitmap.bitmap, Rect.new(0, 0, 40, 30))
      showslider = true
    end
    if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
      overlay.blt(468, 346, @sliderbitmap.bitmap, Rect.new(0, 30, 40, 30))
      showslider = true
    end
    # Draw slider box
    if showslider
      sliderheight = 268
      boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 40].max
      y = 78
      y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
      overlay.blt(468, y, @sliderbitmap.bitmap, Rect.new(40, 0, 40, 8))
      i = 0
      while i * 16 < boxheight - 8 - 16
        height = [boxheight - 8 - 16 - i * 16, 16].min
        overlay.blt(468, y + 8 + i * 16, @sliderbitmap.bitmap, Rect.new(40, 8, 40, height))
        i += 1
      end
      overlay.blt(468, y + boxheight - 16, @sliderbitmap.bitmap, Rect.new(40, 24, 40, 16))
    end
  end

  def setIconBitmap(species)
    @sprites_cache = {} unless @sprites_cache
    if @sprites_cache[species]
      @sprites["icon"].setBitmapDirectly(@sprites_cache[species])
    else
      gender, form = $Trainer.pokedex.last_form_seen(species)
      @sprites["icon"].setSpeciesBitmap(species, gender, form)
      @sprites_cache[species] = @sprites["icon"].bitmap.clone
    end
  end


  def pbDexEntry(index)
    oldsprites = pbFadeOutAndHide(@sprites)
    region = -1
    if !Settings::USE_CURRENT_REGION_DEX
      dexnames = Settings.pokedex_names
      if dexnames[pbGetSavePositionIndex].is_a?(Array)
        region = dexnames[pbGetSavePositionIndex][1]
      end
    end
    scene = PokemonPokedexInfo_Scene.new
    screen = PokemonPokedexInfoScreen.new(scene)
    ret = screen.pbStartScreen(@dexlist, index, region)
    if @searchResults
      dexlist = pbSearchDexList(@searchParams)
      @dexlist = dexlist
      @sprites["pokedex"].commands = @dexlist
      ret = @dexlist.length - 1 if ret >= @dexlist.length
      ret = 0 if ret < 0
    else
      pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
      $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = ret
    end
    @sprites["pokedex"].index = ret
    @sprites["pokedex"].refresh
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
  end


  def pbPokedex()
    pbActivateWindow(@sprites, "pokedex") {
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        if oldindex != @sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbPlayDecisionSE
          pokedexQuickSearch

        elsif Input.trigger?(Input::SPECIAL)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          if @searchResults
            pbPlayCancelSE
            pbCloseSearch
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          if $Trainer.seen?(@sprites["pokedex"].species)
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
        end
      end
    }
  end



end

#===============================================================================
#
#===============================================================================
class PokemonPokedexScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(filter_owned = false)
    @scene.pbStartScene(filter_owned)
    @scene.pbPokedex()
    @scene.pbEndScene
  end
end
