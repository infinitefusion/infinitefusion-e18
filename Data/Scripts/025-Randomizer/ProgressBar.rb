#===============================================================================
# Standalone progress bar, reuses the battle Exp bar graphic
#===============================================================================
class ShuffleProgressBar
  MIN_WIDTH = 240
  HEIGHT    = 56
  PADDING   = 12

  def initialize(text=_INTL("Shuffling..."))
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @barBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/overlay_exp")
    @bg = Sprite.new(@viewport)
    @bg.bitmap = Bitmap.new(@barBitmap.width + 4, @barBitmap.height + 4)
    @bg.bitmap.fill_rect(0, 0, @bg.bitmap.width, @bg.bitmap.height, Color.new(0, 0, 0, 160))
    @bg.x = (Graphics.width - @barBitmap.width) / 2 - 40
    @bg.y = Graphics.height - 48
    @bg.z = 998


    @sprite = SpriteWrapper.new(@viewport)
    @sprite.bitmap = @barBitmap.bitmap
    @sprite.src_rect.width = 0
    @sprite.x = ((Graphics.width - @barBitmap.width) / 2) - 100
    @sprite.y = Graphics.height - 46
    @sprite.z = 999

    @text = text
    @textSprite = Sprite.new(@viewport)
    @textSprite.z = 1000
    createTextBitmap(MIN_WIDTH)
    drawProgressText(0)
  end

  def createTextBitmap(width)
    @textSprite.bitmap.dispose if @textSprite.bitmap
    @textSprite.bitmap = Bitmap.new(width, HEIGHT)
    pbSetSystemFont(@textSprite.bitmap)
    @textSprite.x = @sprite.x
    @textSprite.y = @bg.y - HEIGHT
  end

  # progress: float from 0.0 to 1.0
  def progress=(progress)
    progress = 0 if progress < 0
    progress = 1 if progress > 1
    w = progress * @barBitmap.width
    w = ((w / 2).round) * 2
    @sprite.src_rect.width = w
    drawProgressText(progress)
  end

  def drawProgressText(progress)
    return if !@textSprite || @textSprite.disposed?
    pct = sprintf("%.0f%%", progress * 100)

    bmp = @textSprite.bitmap
    textWidth = bmp.text_size(@text).width
    pctWidth  = bmp.text_size(pct).width
    neededWidth = [textWidth, pctWidth].max + PADDING * 2
    neededWidth = MIN_WIDTH if neededWidth < MIN_WIDTH

    if bmp.width != neededWidth
      createTextBitmap(neededWidth)
      bmp = @textSprite.bitmap
    end

    bmp.clear
    textPositions = [
      [@text, PADDING, 0,  :left, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [pct,   PADDING, 24, :left, Color.new(255, 255, 255), Color.new(0, 0, 0)]
    ]
    pbDrawTextPositions(bmp, textPositions)
  end

  def update
    Graphics.update
    Input.update
  end

  def dispose
    @textSprite.bitmap.dispose
    @textSprite.dispose
    @sprite.dispose
    @bg.bitmap.dispose
    @bg.dispose
    @barBitmap.dispose
    @viewport.dispose
  end

  def disposed?
    @viewport.disposed?
  end
end