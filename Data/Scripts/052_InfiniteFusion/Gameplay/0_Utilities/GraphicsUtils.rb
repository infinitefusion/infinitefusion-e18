def pbPokemonIconFile(pokemon)
  bitmapFileName = pbCheckPokemonIconFiles(pokemon.species, pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(speciesID, egg = false, dna = false)
  if egg
    bitmapFileName = sprintf("Graphics/Icons/iconEgg")
    return pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = "Graphics/Pokemon/Icons/#{speciesID}"
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  ret = pbResolveBitmap("Graphics/Icons/iconDNA.png")
  return ret if ret
  return pbResolveBitmap("Graphics/Icons/iconDNA.png")
end

def addShinyStarsToGraphicsArray(imageArray, xPos, yPos, shinyBody, shinyHead, debugShiny, radarShiny, srcx = nil, srcy = nil, width = nil, height = nil,
                                 showSecondStarUnder = false, showSecondStarAbove = false)
    if debugShiny == true
    color = debugShiny ? Color.new(0, 0, 0, 255) : nil
  end
  if radarShiny == true
    color = radarShiny ? Color.new(0, 0, 255, 255) : nil
  end
  imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
  if shinyBody && shinyHead
    if showSecondStarUnder
      yPos += 15
    elsif showSecondStarAbove
      yPos -= 15
    else
      xPos -= 15
    end
    imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
  end
  # if onlyOutline
  #   imageArray.push(["Graphics/Pictures/shiny_black",xPos,yPos,srcx,srcy,width,height,color])
  # end

end

def pbBitmap(path)
  resolved_path = pbResolveBitmap(path)
  if !resolved_path.nil?
    bmp = RPG::Cache.load_bitmap_path(resolved_path)
    bmp.storedPath = resolved_path
  else
    p "Image located at '#{path}' was not found!" if $DEBUG
    bmp = Bitmap.new(1, 1)
  end
  return bmp
end

# if need to play animation from event route
def playAnimation(animationId, x = nil, y = nil)
  return if !$scene.is_a?(Scene_Map)
  x = @event.x unless x
  y = @event.y unless y
  $scene.spriteset.addUserAnimation(animationId, x, y, true)
end

#Shows a picture, centered in the middle of the screen in a new viewport
# Returns the viewport. Use viewport.dispose to get rid of the picture
def showPicture(path,x,y,viewport_x=(Graphics.width / 4), viewport_y=0)
  begin
    echoln path
    viewport = Viewport.new(viewport_x, viewport_y, Graphics.width, Graphics.height)
    sprite = Sprite.new(viewport)

    bitmap = AnimatedBitmap.new(path) if pbResolveBitmap(path)

    sprite.bitmap = bitmap.bitmap
    sprite.x = x
    sprite.y = y

    viewport.z = 99999
    return viewport
  rescue
  end
end
