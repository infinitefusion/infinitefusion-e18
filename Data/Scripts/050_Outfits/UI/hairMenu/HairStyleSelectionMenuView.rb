class HairStyleSelectionMenuView
  attr_accessor :name_sprite
  attr_accessor :viewport
  attr_accessor :sprites
  attr_accessor :textValues


  OPTIONS_START_Y = 66
  CURSOR_Y_MARGIN = 50
  CURSOR_X_MARGIN = 76

  CHECKMARK_Y_MARGIN = 20
  CHECKMARK_WIDTH = 50

  OPTIONS_LABEL_X = 50


  OPTIONS_LABEL_WIDTH = 100

  OPTIONS_VALUE_X = 194
  SELECTOR_X = 120
  SELECTOR_STAGGER_OFFSET=26


  ARROW_LEFT_X_POSITION = 75
  ARROW_RIGHT_X_POSITION = 275
  ARROWS_Y_OFFSET = 10#20

  CONFIRM_X = 296
  CONFIRM_Y= 322

  STAGGER_OFFSET_1 = 26
  STAGGER_OFFSET_2 = 50



  def initialize
    @presenter = HairstyleSelectionMenuPresenter.new(self)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {}
    @textValues={}
    @max_index=5
  end

  def init_graphics()
    @sprites["bg"] = IconSprite.new(@viewport)
    #@sprites["bg"].setBitmap("Graphics/Pictures/trainer_application_form")
    @sprites["bg"].setBitmap("")


    @sprites["select"] = IconSprite.new(@viewport)
    @sprites["select"].setBitmap("Graphics/Pictures/cc_selection_box")
    @sprites["select"].x = get_cursor_x_position(0)#OPTIONS_LABEL_X + OPTIONS_LABEL_WIDTH + CURSOR_X_MARGIN
    @sprites["select"].y = OPTIONS_START_Y
    @sprites["select"].visible = true

    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = ARROW_LEFT_X_POSITION
    @sprites["leftarrow"].y = 0
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play


    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = ARROW_RIGHT_X_POSITION
    @sprites["rightarrow"].y = 0
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
  end

  def setMaxIndex(maxIndex)
    @max_index=maxIndex
  end

  def init_labels()
    Kernel.pbDisplayText("Confirm", (CONFIRM_X+CURSOR_X_MARGIN), CONFIRM_Y)
  end



  def start
    init_graphics()
    init_labels()
    @presenter.main()
  end

  def get_cursor_y_position(index)
    return CONFIRM_Y if index == @max_index
    return index * CURSOR_Y_MARGIN + OPTIONS_START_Y
  end

  def get_cursor_x_position(index)
    return CONFIRM_X if index == @max_index
    return SELECTOR_X + getTextBoxStaggerOffset(index)
  end

  def get_value_x_position(index)
    return (OPTIONS_VALUE_X + getTextBoxStaggerOffset(index))
  end

  def getTextBoxStaggerOffset(index)
    case index
    when 1
      return STAGGER_OFFSET_1
    when 2
      return STAGGER_OFFSET_2
    when 3
      return STAGGER_OFFSET_1
    end
    return 0
  end




  def showSideArrows(y_index)
    y_position = get_cursor_y_position(y_index)

    @sprites["rightarrow"].y=y_position+ARROWS_Y_OFFSET
    @sprites["leftarrow"].y=y_position+ARROWS_Y_OFFSET

    @sprites["leftarrow"].x=getTextBoxStaggerOffset(y_index)+ARROW_LEFT_X_POSITION
    @sprites["rightarrow"].x= getTextBoxStaggerOffset(y_index)+ARROW_RIGHT_X_POSITION

    @sprites["rightarrow"].visible=true
    @sprites["leftarrow"].visible=true
  end

  def hideSideArrows()
    @sprites["rightarrow"].visible=false
    @sprites["leftarrow"].visible=false
  end

  def displayText(spriteId,text,y_index)
    @textValues[spriteId].dispose if @textValues[spriteId]
    yposition = get_cursor_y_position(y_index)
    xposition = get_value_x_position(y_index)

    baseColor= baseColor ? baseColor : Color.new(72,72,72)
    shadowColor= shadowColor ? shadowColor : Color.new(160,160,160)
    @textValues[spriteId] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    text1=_INTL(text)
    textPosition=[
      [text1,xposition,yposition,2,baseColor,shadowColor],
    ]
    pbSetSystemFont(@textValues[spriteId].bitmap)
    pbDrawTextPositions(@textValues[spriteId].bitmap,textPosition)

  end


  def updateGraphics()
    Graphics.update
    Input.update
    if @sprites
      @sprites["rightarrow"].update
      @sprites["leftarrow"].update
    end
  end
end
