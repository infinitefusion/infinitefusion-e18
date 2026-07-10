#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class PokedexTextEntry
  @@Characters=[
    [("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").scan(/./),"[*]"],
    [("0123456789   !@\#$%^&*()   ~`-_+={}[]   :;'\"<>,.?/   ").scan(/./),"[A]"],
  ]
  USEKEYBOARD=true

  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    if USEKEYBOARD
      @sprites["entry"]=Window_TextEntry_Keyboard.new(initialText,
                                                      0,0,400-112,96,helptext,false)
      Input.text_input = true
    else
      @sprites["entry"]=Window_TextEntry.new(initialText,0,0,400,96,helptext,false)
    end
    @sprites["entry"].x=(Graphics.width/2)-(@sprites["entry"].width/2)+32
    @sprites["entry"].viewport=@viewport
    @sprites["entry"].visible=true
    @minlength=minlength
    @maxlength=maxlength
    @symtype=0
    @sprites["entry"].maxlength=maxlength
    if !USEKEYBOARD
      @sprites["entry2"]=Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport=@viewport
      @sprites["entry2"].visible=true
      @sprites["entry2"].x=(Graphics.width/2)-(@sprites["entry2"].width/2)
    end
    if minlength==0
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
        32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    else
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
        32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    end
    @sprites["helpwindow"].letterbyletter=false
    @sprites["helpwindow"].viewport=@viewport
    @sprites["helpwindow"].baseColor = pbColor(:LIGHT_TEXT_MAIN_COLOR)
    @sprites["helpwindow"].shadowColor = pbColor(:LIGHT_TEXT_SHADOW_COLOR)


    case subject
    when 1   # Player
      meta=GameData::Metadata.get_player($Trainer.character_ID)
      if meta
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        filename=pbGetPlayerCharset(meta,1,nil,true)
        @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 38*2 - charheight/4
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        @sprites["subject"]=PokemonIconSprite.new(pokemon,@viewport)
        @sprites["subject"].setOffset(PictureOrigin::Center)
        @sprites["subject"].x=88
        @sprites["subject"].y=54
        @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
        @sprites["gender"].x=430
        @sprites["gender"].y=54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos=[]
        if pokemon.male?
          textpos.push(["♂",0,-6,false,Color.new(0,128,248),Color.new(168,184,184)])
        elsif pokemon.female?
          textpos.push(["♀",0,-6,false,Color.new(248,24,24),Color.new(168,184,184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap,textpos)
      end
    when 3   # NPC
      @sprites["shadow"]=IconSprite.new(0,0,@viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x=33*2
      @sprites["shadow"].y=32*2
      @sprites["subject"]=TrainerWalkingCharSprite.new(pokemon.to_s,@viewport)
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 38*2 - charheight/4
    when 4   # Storage box
      @sprites["subject"]=TrainerWalkingCharSprite.new(nil,@viewport)
      @sprites["subject"].altcharset="Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed=4
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 26*2 - charheight/2
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEntry1
    ret=""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE) && @minlength==0
        ret=""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length>=@minlength
        ret=@sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"].update if @sprites["subject"]
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret=""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"].update if @sprites["subject"]
      if Input.trigger?(Input::USE)
        index=@sprites["entry2"].command
        if index==-3 # Confirm text
          ret=@sprites["entry"].text
          if ret.length<@minlength || ret.length>@maxlength
            pbPlayBuzzerSE()
          else
            pbPlayDecisionSE()
            break
          end
        elsif index==-1 # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        elsif index==-2 # Change character set
          pbPlayDecisionSE()
          @symtype+=1
          @symtype=0 if @symtype>=@@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end