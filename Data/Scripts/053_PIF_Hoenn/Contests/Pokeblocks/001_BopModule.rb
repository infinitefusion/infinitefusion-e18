module BopModule
	#------------#
	# Set bitmap #
	#------------#
	# Image
	# def create_sprite(spritename,filename,vp,dir="")
		# @sprites["#{spritename}"] = Sprite.new(vp)
		# folder = "Berry Blender"
		# file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		# @sprites["#{spritename}"].bitmap = Bitmap.new(file)
	# end
	# def set_sprite(spritename,filename,dir="")
		# folder = "Berry Blender"
		# file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		# @sprites["#{spritename}"].bitmap = Bitmap.new(file)
	# end
	# Set ox, oy
	def set_oxoy_sprite(spritename,ox,oy)
		@sprites["#{spritename}"].ox = ox
		@sprites["#{spritename}"].oy = oy
	end
	# Set x, y
	def set_xy_sprite(spritename,x,y)
		@sprites["#{spritename}"].x = x
		@sprites["#{spritename}"].y = y
	end
	# Set zoom
	def set_zoom_sprite(spritename,zoom_x,zoom_y)
		@sprites["#{spritename}"].zoom_x = zoom_x
		@sprites["#{spritename}"].zoom_y = zoom_y
	end
	# Set visible
	def set_visible_sprite(spritename,vsb=false)
		@sprites["#{spritename}"].visible = vsb
	end
	# Set angle
	def set_angle_sprite(spritename,angle)
		@sprites["#{spritename}"].angle = angle
	end
	# Set src
	# width, height
	def set_src_wh_sprite(spritename,w,h)
		@sprites["#{spritename}"].src_rect.width = w
		@sprites["#{spritename}"].src_rect.height = h
	end
	# x, y
	def set_src_xy_sprite(spritename,x,y)
		@sprites["#{spritename}"].src_rect.x = x
		@sprites["#{spritename}"].src_rect.y = y
	end

end