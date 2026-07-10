class Sprite
  # x: The X position of the center
  # y: The Y position of the center
  # width: The width of the pentagon (width / 2 = radius)
  # height: The height of the pentagon
  # color: The outline and fill color of the pentagon
  # y_offset: Defaults to (height / 4.0). The lower this is, the higher up (and
  #           lower down) the corners of the pentagon will be
  # fill: Whether or not to fill the pentagon with the chosen color
  def draw_pentagon(x, y, width, height, color, y_offset = nil, fill = false, outline_color = nil)
    self.bitmap.draw_pentagon(x, y, width, height, color, y_offset, fill, outline_color)
  end
  
  # This simply calls "draw_shape_with_values" but with predefined points
  # for pentagons. 
  def draw_pentagon_with_values(x, y, width, height, color, max_value, values,
                               y_offset = nil, fill = false, outline = true)
    self.bitmap.draw_pentagon_with_values(x, y, width, height, color, max_value,
                                         values, y_offset, fill, outline)
  end
  
end

class Bitmap
  # x: The X position of the center
  # y: The Y position of the center
  # width: The width of the pentagon (width / 2 = radius)
  # height: The height of the pentagon
  # color: The outline and fill color of the pentagon
  # y_offset: Defaults to (height / 4.0). The lower this is, the higher up (and
  #           lower down) the corners of the pentagon will be
  # fill: Whether or not to fill the pentagon with the chosen color
  def draw_pentagon(x, y, width, height, color, y_offset = nil, fill = false, outline_color = nil)
    yp = y_offset || (height / 4.0).floor
	r = (height / 2.0).round
    points = []
    points[0] = Point.new(x, y - (height / 2.0).round) #top, then counterClockwise
	points[4] = Point.new(x+(r*Math.cos(Math.radians(90+1*72))).round,y-(r*Math.sin(Math.radians(90+1*72))).round)
    points[3] = Point.new(x+(r*Math.cos(Math.radians(90+2*72))).round,y-(r*Math.sin(Math.radians(90+2*72))).round)	
    points[2] = Point.new(x+(r*Math.cos(Math.radians(90+3*72))).round,y-(r*Math.sin(Math.radians(90+3*72))).round)	
    points[1] = Point.new(x+(r*Math.cos(Math.radians(90+4*72))).round,y-(r*Math.sin(Math.radians(90+4*72))).round)
	ret = draw_shape(color, points.concat([points[0]]), fill)
	points.each { |p| draw_line(p,Point.new(x,y),outline_color)} if outline_color
    return ret
  end
  
  # This simply calls "draw_shape_with_values" but with predefined points
  # for pentagons.
  def draw_pentagon_with_values(x, y, width, height, color, max_value, values,
                               y_offset = nil, fill = false, outline = true)
    yp = y_offset || (height / 4.0).floor
	r = (height / 2.0).round
    points = []
    points[0] = Point.new(x, y - (height / 2.0).round) #top, then counterClockwise
	points[4] = Point.new(x+(r*Math.cos(Math.radians(90+1*72))).round,y-(r*Math.sin(Math.radians(90+1*72))).round)
    points[3] = Point.new(x+(r*Math.cos(Math.radians(90+2*72))).round,y-(r*Math.sin(Math.radians(90+2*72))).round)	
    points[2] = Point.new(x+(r*Math.cos(Math.radians(90+3*72))).round,y-(r*Math.sin(Math.radians(90+3*72))).round)	
    points[1] = Point.new(x+(r*Math.cos(Math.radians(90+4*72))).round,y-(r*Math.sin(Math.radians(90+4*72))).round)		
	return draw_shape_with_values(color, x, y, points, max_value, values, fill, outline)
  end
  
end

module Math
	module_function
	def radians(degrees)
		return degrees * Math::PI/180
	end
end

def pbDrawStatsPentagonBase(sprite,centerX,centerY,radius,outlineColor,bgdColor)
	sprite.draw_pentagon(centerX,centerY,radius*2,radius*2,outlineColor,nil,true)
	sprite.draw_pentagon(centerX,centerY,radius*2-12,radius*2-12,bgdColor,nil,true,outlineColor)
	# sprite.draw_pentagon_with_values(centerX,centerY,radius*2-12,radius*2-12,chartColor,255,stats,nil,true,false)
end

def pbDrawStatsPentagon(sprite,stats,centerX,centerY,radius,chartColor)
	# sprite.draw_pentagon(centerX,centerY,radius*2,radius*2,outlineColor,nil,true)
	# sprite.draw_pentagon(centerX,centerY,radius*2-12,radius*2-12,bgdColor,nil,true,outlineColor)
	sprite.draw_pentagon_with_values(centerX,centerY,radius*2-12,radius*2-12,chartColor,255,stats,nil,true,false)
end