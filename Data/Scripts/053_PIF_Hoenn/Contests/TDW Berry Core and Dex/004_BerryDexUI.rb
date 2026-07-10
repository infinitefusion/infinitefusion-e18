#===============================================================================
#
#===============================================================================
class Window_Berrydex < Window_DrawableCommand
    def initialize(x, y, width, height, viewport)
        @commands = []
        super(x, y, width, height, viewport)
        @selarrow     = AnimatedBitmap.new("Graphics/Pictures/Berrydex/cursor_list")
        @found        = AnimatedBitmap.new("Graphics/Pictures/Berrydex/icon_found")
        self.baseColor   = Color.new(88, 88, 80)
        self.shadowColor = Color.new(168, 184, 184)
        self.windowskin  = nil
    end
  
    def commands=(value)
        @commands = value
        refresh
    end
  
    def dispose
        @found.dispose
        super
    end
  
    def berry
        return (@commands.length == 0) ? 0 : @commands[self.index][0]
    end
  
    def itemCount
        return @commands.length
    end
  
    def drawItem(index, _count, rect)
      return if index >= self.top_row + self.page_item_max
      rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
      berry     = @commands[index][0]
      indexNumber = @commands[index][2]
      if pbBerryRegistered?(berry)
            if Settings::BERRYDEX_SHOW_NUMBER
                text = sprintf("%02d%s %s", indexNumber, " ", @commands[index][1])
            else
                text = sprintf("%s", @commands[index][1])
            end
            pbCopyBitmap(self.contents, @found.bitmap, rect.x - 6, rect.y + 10)
      else
            if Settings::BERRYDEX_SHOW_NUMBER
                text = sprintf("%02d  ----------", indexNumber)
            else
                text = sprintf("----------")
            end
      end
      pbDrawShadowText(self.contents, rect.x + 36, rect.y + 6, rect.width, rect.height,
                       text, self.baseColor, self.shadowColor)
    end
  
    def refresh
        @item_max = itemCount
        dwidth  = self.width - self.borderX
        dheight = self.height - self.borderY
        self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
        self.contents.clear
        @item_max.times do |i|
            next if i < self.top_item || i > self.top_item + self.page_item_max
            drawItem(i, @item_max, itemRect(i))
        end
        drawCursor(self.index, itemRect(self.index))
    end
  
    def update
        super
        @uparrow.visible   = false
        @downarrow.visible = false
    end
end

#===============================================================================
# Berrydex main screen
#===============================================================================
class PokemonBerrydex_Scene
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene
        @sliderbitmap       = AnimatedBitmap.new("Graphics/Pictures/Berrydex/icon_slider")
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        addBackgroundPlane(@sprites, "background", "Berrydex/bg_list", @viewport)
        @sprites["berrydex"] = Window_Berrydex.new(206, 30, 276, 364, @viewport)
        @sprites["itemicon"] = BerrydexItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
        @sprites["itemicon"].setOffset(PictureOrigin::Center)
        @sprites["itemicon"].item = nil
        @sprites["itemicon"].x = 112
        @sprites["itemicon"].y = 196
        @sprites["unknownicon"] = IconSprite.new(48, Graphics.height - 48, @viewport)
        @sprites["unknownicon"].setBitmap("Graphics/Pictures/Berrydex/unknown")
        @sprites["unknownicon"].ox = 24
        @sprites["unknownicon"].oy = 24
        @sprites["unknownicon"].x = 112
        @sprites["unknownicon"].y = 196
        @sprites["unknownicon"].visible = false
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)

        unless $PokemonGlobal.berrydexIndex
            $PokemonGlobal.berrydexIndex = []
            $PokemonGlobal.berrydexIndex[0] = 0
        end
        pbRefreshDexList($PokemonGlobal.berrydexIndex[0])
        pbDeactivateWindows(@sprites)
        pbFadeInAndShow(@sprites)
    end
  
    def pbEndScene
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @sliderbitmap.dispose
        @viewport.dispose
    end
      
    def pbGetDexList
        list = pbLoadBerryDexes[0]
        ret = []
        list.each_with_index do |berry, i|
            next if !berry
            berry_data = GameData::BerryData.try_get(berry)
            berry_item = GameData::Item.try_get(berry_data.id)
            color  = berry_data.color
            flavor = berry_data.flavor
            smoothness  = berry_data.smoothness
            #ret.push([berry.id, berry_item.name, i + 1, color, flavor, smoothness])
            ret.push([berry.id, berry_item.name, i + 1])
        end
        return ret
    end
  
    def pbRefreshDexList(index = 0)
        dexlist = pbGetDexList
        # Remove unseen species from the end of the list
        i = dexlist.length - 1
        loop do
            break if i < 0 || !dexlist[i] || pbBerryRegistered?(dexlist[i][0])
            dexlist[i] = nil
            i -= 1
        end
        dexlist.compact!
        # Sort species in ascending order by Dex number
        dexlist.sort! { |a, b| a[2] <=> b[2] }
        @dexlist = dexlist
        @sprites["berrydex"].commands = @dexlist
        @sprites["berrydex"].index    = index
        @sprites["berrydex"].refresh
        @sprites["background"].setBitmap("Graphics/Pictures/Berrydex/bg_list")
        pbRefresh
    end
  
    def pbRefresh
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      base   = Color.new(88, 88, 80)
      shadow = Color.new(168, 184, 184)
      iconberry = @sprites["berrydex"].berry
      iconberry = nil if !pbBerryRegistered?(iconberry)
      # Write various bits of text
      dexname = _INTL("BerryDex")
      textpos = [
        [dexname, Graphics.width / 2, -4, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)]
      ]
      textpos.push([GameData::Item.get(iconberry).name, 112, 46, 2, base, shadow]) if iconberry
      textpos.push([_INTL("Gathered:"), 42, 302, 0, base, shadow])
      textpos.push([pbBerryDexCount.to_s, 182, 302, 1, base, shadow])
      textpos.push([_INTL("Planted:"), 42, 334, 0, base, shadow])
      textpos.push([$Trainer.stats.berries_planted.to_s, 182, 334, 1, base, shadow])
      # Draw all text
      pbDrawTextPositions(overlay, textpos)
      # Set Pokémon sprite
      setIconBitmap(iconberry)
      # Draw slider arrows
      itemlist = @sprites["berrydex"]
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
          height = [boxheight - 8 - 16 - (i * 16), 16].min
          overlay.blt(468, y + 8 + (i * 16), @sliderbitmap.bitmap, Rect.new(40, 8, 40, height))
          i += 1
        end
        overlay.blt(468, y + boxheight - 16, @sliderbitmap.bitmap, Rect.new(40, 24, 40, 16))
      end
    end
  
    def setIconBitmap(berry)
        if berry
            @sprites["itemicon"].item = berry
            @sprites["itemicon"].visible = true
            @sprites["unknownicon"].visible = false
        else
            @sprites["itemicon"].item = nil
            @sprites["itemicon"].visible = false
            @sprites["unknownicon"].visible = true
        end
    end
    
    def pbDexEntry(index)
        oldsprites = pbFadeOutAndHide(@sprites)
        scene = BerrydexInfo_Scene.new
        screen = BerrydexInfoScreen.new(scene)
        ret = screen.pbStartScreen(@dexlist, index)
        pbRefreshDexList($PokemonGlobal.berrydexIndex[0])
        $PokemonGlobal.berrydexIndex[0] = ret
        @sprites["berrydex"].index = ret
        @sprites["berrydex"].refresh
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
    end
    
    def pbBerrydex
        pbActivateWindow(@sprites, "berrydex") {
            loop do
                Graphics.update
                Input.update
                oldindex = @sprites["berrydex"].index
                pbUpdate
                if oldindex != @sprites["berrydex"].index
                    $PokemonGlobal.berrydexIndex[0] = @sprites["berrydex"].index
                    pbRefresh
                end
                if Input.trigger?(Input::BACK)
                    pbPlayCloseMenuSE
                    break
                elsif Input.trigger?(Input::USE)
                    if pbBerryRegistered?(@sprites["berrydex"].berry)
                    pbPlayDecisionSE
                    pbDexEntry(@sprites["berrydex"].index)
                    end
                end
            end
        }
    end
end

#===============================================================================
# Berrydex entry screen
#===============================================================================
class BerrydexInfo_Scene
    def pbStartScene(dexlist, index)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @dexlist = dexlist
        @index   = index
        @page = 1
        @berry = @dexlist[@index][0]
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["itemicon"] = BerrydexItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
        @sprites["itemicon"].setOffset(PictureOrigin::Center)
        @sprites["itemicon"].item = nil
        @sprites["itemicon"].x = 144
        @sprites["itemicon"].y = 134
        @sprites["berry_plant_dirt"] = IconSprite.new(84, 176, @viewport)
        @sprites["berry_plant_dirt"].setBitmap(_INTL("Graphics/Pictures/Berrydex/plant_dirt"))
        @sprites["berry_plant_dirt"].zoom_x = @sprites["berry_plant_dirt"].zoom_y = 2
        @sprites["berry_plant_dirt"].visible = false
        @sprites["berry_plant"] = IconSprite.new(112, 108, @viewport)
        @sprites["berry_plant"].visible = false
        # if PluginManager.installed?("TDW Berry Planting Improvements","1.2") && pbBerryPreferredWeatherEnabled?
        #     @sprites["weather_box"] = IconSprite.new(12, 268, @viewport)
        #     @sprites["weather_box"].setBitmap(_INTL("Graphics/Pictures/Berrydex/preferred_weather_box"))
        #     @sprites["weather_box"].visible = false
        # end
        @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
        @sprites["uparrow"].x = 242
        @sprites["uparrow"].y = 268
        @sprites["uparrow"].play
        @sprites["uparrow"].visible = false
        @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
        @sprites["downarrow"].x = 242
        @sprites["downarrow"].y = 348
        @sprites["downarrow"].play
        @sprites["downarrow"].visible = false
        @sprites["circled_spicy"] = IconSprite.new(356, 92, @viewport)
        @sprites["circled_spicy"].setBitmap(_INTL("Graphics/Pictures/Berrydex/flavor_selected"))
        @sprites["circled_spicy"].visible = false
        @sprites["circled_dry"] = IconSprite.new(420, 146, @viewport)
        @sprites["circled_dry"].setBitmap(_INTL("Graphics/Pictures/Berrydex/flavor_selected"))
        @sprites["circled_dry"].visible = false
        @sprites["circled_sweet"] = IconSprite.new(398, 212, @viewport)
        @sprites["circled_sweet"].setBitmap(_INTL("Graphics/Pictures/Berrydex/flavor_selected"))
        @sprites["circled_sweet"].visible = false
        @sprites["circled_bitter"] = IconSprite.new(314, 212, @viewport)
        @sprites["circled_bitter"].setBitmap(_INTL("Graphics/Pictures/Berrydex/flavor_selected"))
        @sprites["circled_bitter"].visible = false
        @sprites["circled_sour"] = IconSprite.new(292, 146, @viewport)
        @sprites["circled_sour"].setBitmap(_INTL("Graphics/Pictures/Berrydex/flavor_selected"))
        @sprites["circled_sour"].visible = false

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        drawPage(@page)
        pbFadeInAndShow(@sprites) { pbUpdate }
    end
  
    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)  
    end
  
    def drawPage(page)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        # Make certain sprites visible
        @sprites["itemicon"].item = @berry
        @sprites["itemicon"].visible    = (@page == 1)
        @sprites["berry_plant"].visible = (@page == 2)
        @sprites["berry_plant_dirt"].visible = (@page == 2)
        @sprites["weather_box"]&.visible = (@page == 2)
        # Draw page-specific information
        case page
        when 1 then drawPageInfo
        when 2 then drawPagePlant
        # when 3 then drawPageForms
        end
    end
  
    def drawPageInfo
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Berrydex/bg_info"))
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        # Show the found icon
        imagepos.push(["Graphics/Pictures/Berrydex/icon_found", 16, 44])
        # Write various bits of text
        indexText = "??"
        if @dexlist[@index][2] > 0
            indexNumber = @dexlist[@index][2]
            indexText = sprintf("%02d", indexNumber)
        end
        textpos = [
            [_INTL("{1}{2} {3}", indexText, " ", berry_item.name),
            50, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
        ]
        textpos.push([_INTL("Size"), 64, 188, 0, base, shadow])
        textpos.push([_INTL("Firm"), 64, 220, 0, base, shadow])

        size = berry_data.size
        if System.user_language[3..4] == "US"   # If the user is in the United States
            inches = (size / 2.54).round(1)
            textpos.push([_ISPRINTF("{1:.1f}\"", inches), 210, 188, 1, base, shadow])
        else
            textpos.push([_ISPRINTF("{1:.1f} cm", size), 220, 188, 1, base, shadow])
        end
        firmness = berry_data.firmness
        textpos.push([firmness, 244, 220, 1, base, shadow])
        max_flavor = berry_data.flavor.values.max
        berry_data.flavor.each { |key, value|
            if value >= max_flavor
                @sprites["circled_#{key.downcase}"].visible = true
            else    
                @sprites["circled_#{key.downcase}"].visible = false
            end
        }
        drawTextEx(overlay, 40, 278, Graphics.width - (40 * 2), 3,   # overlay, x, y, width, num lines
                berry_data.description, base, shadow)

        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end
 
    def drawPagePlant
        plant_sprite_width= 128
        plant_sprite_height = 256

        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Berrydex/bg_plant"))
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        plant_data = GameData::BerryPlant.try_get(berry_data.id)
        @sprites["circled_spicy"].visible = false
        @sprites["circled_dry"].visible = false
        @sprites["circled_sweet"].visible = false
        @sprites["circled_bitter"].visible = false
        @sprites["circled_sour"].visible = false
        # Show the found icon
        imagepos.push(["Graphics/Pictures/Berrydex/icon_found", 16, 44])
        # Write various bits of text
        indexText = "??"
        if @dexlist[@index][2] > 0
            indexNumber = @dexlist[@index][2]
            indexText = sprintf("%02d", indexNumber)
        end
        textpos = [
            [_INTL("{1}{2} {3}", indexText, " ", berry_item.name),
            50, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
        ]

        filename = sprintf("berrytree_%s", berry_item.id.to_s)
        if pbResolveBitmap("Graphics/Characters/" + filename)
            @sprites["berry_plant"].setBitmap("Graphics/Characters/" + filename)
            @sprites["berry_plant"].src_rect.x = 0
            @sprites["berry_plant"].src_rect.y = plant_sprite_height*3/4
            @sprites["berry_plant"].src_rect.width = plant_sprite_width/4#@sprites["berry_plant"].width/4
            @sprites["berry_plant"].src_rect.height = plant_sprite_height/4#@sprites["berry_plant"].height/4
            @sprites["berry_plant"].zoom_x = @sprites["berry_plant"].zoom_y = 2
            @sprites["berry_plant"].visible = true
        else
            @sprites["berry_plant"].visible = false
        end

        textpos.push([_INTL("Growth Time"), 286, 138, 0, base, shadow])
        textpos.push([_INTL("Harvest"), 286, 172, 0, base, shadow])
        textpos.push([_INTL("Dry Rate"), 286, 206, 0, base, shadow])

        time = plant_data.hours_per_stage * 4
        textpos.push([_ISPRINTF("{1:d} hrs", time), 498, 138, 1, base, shadow])

        harvest = [plant_data.minimum_yield,plant_data.maximum_yield]
        textpos.push([_ISPRINTF("{1:d} - {2:d}", harvest[0], harvest[1]), 498, 172, 1, base, shadow])

        dry = pbGetDryRateName(plant_data.drying_per_hour)
        textpos.push([dry, 498, 206, 1, base, shadow])

        if @sprites["weather_box"]
            weather = berry_data.preferred_weather
            if weather.length > 0
                @sprites["weather_box"].visible = true
                weather_text = ""
                weather.each_with_index do |w, i|
                    w = GameData::Weather.get(w)
                    weather_text += ", " if i > 0
                    weather_text += w.real_name
                end
                textpos.push([_INTL("Preferred Weather"), Graphics.width/2, 278, 2, base, shadow])
                textpos.push([weather_text, Graphics.width/2, 320, 2, base, shadow])
            else
                @sprites["weather_box"].visible = false
            end
        end

        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end

    def pbGetDryRateName(rate)
        Settings::BERRYDEX_DRY_RATE_CATEGORIES.each do |i|
            return i[0] if rate.between?(i[1],i[2])
        end
        return _INTL("???")
    end

    def pbGoToPrevious
        newindex = @index
        while newindex > 0
            newindex -= 1
            if pbBerryRegistered?(@dexlist[newindex][0])
                @index = newindex
                break
            end
        end
    end
  
    def pbGoToNext
        newindex = @index
        while newindex < @dexlist.length - 1
            newindex += 1
            if pbBerryRegistered?(@dexlist[newindex][0])
                @index = newindex
                break
            end
        end
    end
    
    def pbScene
        loop do
            Graphics.update
            Input.update
            pbUpdate
            dorefresh = false
            if Input.trigger?(Input::ACTION)
                pbSEStop
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
                case @page
                when 1   # Info
                    dorefresh = true
                when 2   # Plant
                    dorefresh = true
                end 
            elsif Input.trigger?(Input::UP)
                oldindex = @index
                pbGoToPrevious
                if @index != oldindex
                    @berry = @dexlist[@index][0]
                    pbSEStop
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.trigger?(Input::DOWN)
                oldindex = @index
                pbGoToNext
                if @index != oldindex
                    @berry = @dexlist[@index][0]
                    pbSEStop
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.trigger?(Input::LEFT)
              oldpage = @page
              @page -= 1
              @page = 1 if @page < 1
              @page = 2 if @page > 2
              if @page != oldpage
                pbPlayCursorSE
                dorefresh = true
              end
            elsif Input.trigger?(Input::RIGHT)
              oldpage = @page
              @page += 1
              @page = 1 if @page < 1
              @page = 2 if @page > 2
              if @page != oldpage
                pbPlayCursorSE
                dorefresh = true
              end
            end
            if dorefresh
                drawPage(@page)
            end
        end
        return @index
    end
  
end
  
class BerrydexInfoScreen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen(dexlist, index)
        @scene.pbStartScene(dexlist, index)
        ret = @scene.pbScene
        @scene.pbEndScene
        return ret   # Index of last viewed in dexlist
    end
  
    def pbStartSceneSingle(berry)   # For use from an item's command list
        dexnum = pbGetBerrydexNumber(berry)
        dexlist = [[berry, GameData::Item.get(berry).name, dexnum, 0]]
        @scene.pbStartScene(dexlist, 0)
        @scene.pbScene
        @scene.pbEndScene
    end
end

#===============================================================================
#
#===============================================================================
class PokemonBerrydexScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
      @scene.pbStartScene
      @scene.pbBerrydex
      @scene.pbEndScene
    end
  end

#===============================================================================
# Berrydex Item icon
#===============================================================================
class BerrydexItemIconSprite < Sprite
    attr_reader :item
    attr_reader :tag_icon
  
    def initialize(x, y, item, viewport = nil)
        super(viewport)
        @bitmap = nil
        @tag_icon = false
        self.x = x
        self.y = y
        @forceitemchange = true
        self.item = item
        @forceitemchange = false
    end
  
    def dispose
        @bitmap&.dispose
        super
    end
  
    def width
        return 0 if !self.bitmap || self.bitmap.disposed?
        return self.bitmap.width
    end
  
    def height
        return (self.bitmap && !self.bitmap.disposed?) ? self.bitmap.height : 0
    end
  
    def setOffset(offset = PictureOrigin::Center)
        @offset = offset
        changeOrigin
    end
  
    def changeOrigin
        @offset = PictureOrigin::Center if !@offset
        case @offset
        when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
            self.oy = 0
        when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
            self.oy = self.height / 2
        when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
            self.oy = self.height
        end
        case @offset
        when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
            self.ox = 0
        when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
            self.ox = self.width / 2
        when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
            self.ox = self.width
        end
    end
  
    def item=(value)
        return if @item == value && !@forceitemchange
        @item = value
        @bitmap&.dispose
        @bitmap = nil
        if @item
            if Settings::BERRYDEX_USE_TAG_ICONS && pbResolveBitmap("Graphics/Pictures/Berrydex/Tag Icons/" + value.to_s)
                @bitmap = AnimatedBitmap.new("Graphics/Pictures/Berrydex/Tag Icons/" + value.to_s)
                self.bitmap = @bitmap.bitmap
                self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
            else
                @bitmap = AnimatedBitmap.new(GameData::Item.icon_filename(@item))
                self.bitmap = @bitmap.bitmap
                self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
            end
        else
            self.bitmap = nil
        end
        changeOrigin
    end
  end

#===============================================================================
#
#===============================================================================
class PokemonGlobalMetadata
    attr_accessor :berrydexIndex

    alias tdw_berry_dex_ui_global_init initialize
    def initialize
        tdw_berry_dex_ui_global_init
        @berrydexIndex = []
        @berrydexIndex[0] = 0
    end
end