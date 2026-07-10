#===============================================================
#  Berry Blender Commands
#===============================================================
def pbBerryBlender(playerCount=0,specificNames=nil,forceFail=false)
	if PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
		return pbBerryBlenderSimple
	end
	if !$PokemonBag.hasAnyBerry?
		pbMessage(_INTL("You don't have any berries!"))
		return false
	end
	ret = false
	pbFadeOutIn {
		scene = BerryBlender_Scene.new
		screen = BerryBlender_Screen.new(scene)
		ret = screen.pbStartScreen(playerCount,specificNames,forceFail)
	}
	return ret
end

def pbBerryBlenderSimple
	if !$PokemonBag.hasAnyBerry?
		pbMessage(_INTL("You don't have any berries!"))
		return false
	end
	ret = false
	pbFadeOutIn {
		scene = SimpleBerryBlender_Scene.new
		screen = SimpleBerryBlender_Screen.new(scene)
		ret = screen.pbStartScreen
	}
	return ret
end

#===============================================================================
# Berry Blender Scene
#=============================================================================== 

class BerryBlender_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(playerCount,specificNames,forceFail)
	@play = true
    @scene.pbStartScene(playerCount,specificNames,forceFail)
    while @play
		@play = @scene.pbScene
		@scene.pbRestartScene if @play
	end
    @scene.pbEndScene
    return true
  end
end

class BerryBlender_Scene
	include BopModule
	MAX_SPEED = 5

	def pbStartScene(playerCount,specificNames,forceFail)
		# Viewport
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		# Values
		# Set number to define player, quantity of players
		@playerCount = playerCount
		@forceFail = forceFail
		#sprites
		@sprites = {}
		# Set name
		@name = []
		@name << $Trainer.name
		if playerCount != 0 && playerCount != 4
			a = 0
			playerCount.times { 
				if specificNames && specificNames[a]
					@name << specificNames[a]
				else
					@name << PokeblockSettings::NPC_DEFAULT_NAMES[a].sample
				end
				a += 1
			} 
		elsif playerCount == 4
			if specificNames && specificNames[0]
				@name << specificNames[0]
			else
				@name << PokeblockSettings::NPC_DEFAULT_NAMES[3].sample
			end
		end
		# Store berry
		@berry = []
		# Set speed of circle
		@speed  = MAX_SPEED
		@frames = 0
		# Set frame to increase angle
		@frames_rate = 0
		@old_frames_rate = Graphics.frame_rate
		# Speed to define PokeBlock
		@speedTxt = 7.0
		@notPress = @playerCount == 0 ? 400 : 100 * @playerCount
		@maxSpeed = 0
		# Count good, miss, perfect
		@count = {}
		@showFeature = {}
		@pressCheck  = []
		@name.each { |name|
			@count[name] = { perfect: 0, good: 0, miss: 0 }
			@showFeature[name] = { perfect: [], good: [], miss: [] }
			# Use to check if player press (AI)
			@pressCheck << false
		}
		@showEffect = false
		@trigger_effect = {}
		10.times { |i| @trigger_effect[i] = [false, 0] }
		# Result (show result)
		@result = false
		@checkall = false
		@showPage = 0
		# Set name of flavor after playing
		@flavorGet = []
		# Set order
		@order = nil
		@orderNum = []
		# Fade
		@fade = false
		@countFade = 0
		# Finish
		@exit = false	
	end
	
	def pbRestartScene
		@restarted = true
		@sprites = {}
		# Store berry
		@berry = []
		# Set speed of circle
		@speed  = MAX_SPEED
		@frames = 0
		# Set frame to increase angle
		@frames_rate = 0
		@old_frames_rate = Graphics.frame_rate
		# Speed to define PokeBlock
		@speedTxt = 7.0
		@notPress = @playerCount == 0 ? 400 : 100 * @playerCount
		@maxSpeed = 0
		# Count good, miss, perfect
		@count = {}
		@showFeature = {}
		@pressCheck  = []
		@name.each { |name|
			@count[name] = { perfect: 0, good: 0, miss: 0 }
			@showFeature[name] = { perfect: [], good: [], miss: [] }
			# Use to check if player press (AI)
			@pressCheck << false
		}
		@showEffect = false
		@trigger_effect = {}
		10.times { |i| @trigger_effect[i] = [false, 0] }
		# Result (show result)
		@result = false
		@checkall = false
		@showPage = 0
		# Set name of flavor after playing
		@flavorGet = []
		# Set order
		@order = nil
		@orderNum = []
		# Fade
		@fade = false
		@countFade = 0
		# Finish
		@exit = false	
	end
	
	def pbScene
		# Create
		create_scene
		# Draw name and animation
		draw_name
		# Fade
		pbFadeInAndShow(@sprites) { update } if !@restarted
		# Choose berry
		notplay = false
		berry   = nil
		if @restarted then @restarted = nil;
		else
			pbMessage(_INTL("Starting up the Berry Blender...")) 
			pbMessage(_INTL("Please select a berry from your bag to put in the Berry Blender."))
		end
		loop do
			berry = BerryPoffin.pbPickBerryForBlender
			if berry.nil? || berry == 0
				notplay = !pbConfirmMessage(_INTL("Do you want to choose a berry?"))
				break if notplay
			else
				break
			end
		end
		return if notplay
		# Set berry
		@berry << berry
		@berry.concat(getAIBerries(berry,@playerCount))
		# Animation berry
		@berry.each_with_index { |b, i| animationBerry(b, i) }
		# Zoom
		zoom_circle_before_start
		# Count
		count_and_start
		loop do
			update_ingame
			break if @exit
			# Fade
			fade_out if @countFade == 2
			# Update
			update_main
			# Draw text
			draw_main
			# Input
			set_input
			# Increase frames
			@frames += 1
		end
		return true if $PokemonBag.hasAnyBerry? && pbConfirmMessage(_INTL("Would you like to blend another berry?"))
		return false
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { update }
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
		
	def getAIBerries(playerBerry,playerCount)
		return [] if playerCount == 0
		arr = []
		if PokeblockSettings::NPC_USE_RANDOM_BERRIES
			if playerCount == 4
				arr << PokeblockSettings::BERRY_MASTER_BERRIES.sample
			else
				playerCount.times { arr << GameData::BerryData.keys.sample }
			end
		else
			if playerCount == 4 #Berry Master
				case playerBerry
				#General Cases
				when :CHERIBERRY,:ENIGMABERRY,:LEPPABERRY,:FIGYBERRY,:RAZZBERRY,:POMEGBERRY,:TAMATOBERRY,
						:OCCABERRY,:CHOPLEBERRY,:TANGABERRY,:BABIRIBERRY,:LIECHIBERRY,:LANSATBERRY
					arr.push(:SPELONBERRY)
				when :CHESTOBERRY,:ORANBERRY,:WIKIBERRY,:BLUKBERRY,:KELPSYBERRY,:CORNNBERRY,:PASSHOBERRY,
						:KEBIABERRY,:CHARTIBERRY,:CHILANBERRY,:GANLONBERRY,:MICLEBERRY,:KEEBERRY,:STARFBERRY
					arr.push(:PAMTREBERRY)
				when :PECHABERRY,:PERSIMBERRY,:MAGOBERRY,:NANABBERRY,:QUALOTBERRY,:MAGOSTBERRY,:WACANBERRY,
						:SHUCABERRY,:KASIBBERRY,:SALACBERRY,:CUSTAPBERRY,:ROSELIBERRY
					arr.push(:WATMELBERRY)
				when :RAWSTBERRY,:LUMBERRY,:AGUAVBERRY,:WEPEARBERRY,:HONDEWBERRY,:RABUTABERRY,:RINDOBERRY,
						:COBABERRY,:HABANBERRY,:PETAYABERRY,:JABOCABERRY,:MARANGABERRY
					arr.push(:DURINBERRY)
				when :ASPEARBERRY,:SITRUSBERRY,:IAPAPABERRY,:PINAPBERRY,:GREPABERRY,:NOMELBERRY,:YACHEBERRY,
						:COLBURBERRY,:APICOTBERRY,:ROWAPBERRY
					arr.push(:BELUEBERRY)
				#Special Cases
				when :SPELONBERRY
					arr.push(:TAMATOBERRY)
				when :PAMTREBERRY
					arr.push(:CORNNBERRY)
				when :WATMELBERRY
					arr.push(:MAGOSTBERRY)
				when :DURINBERRY
					arr.push(:RABUTABERRY)
				when :BELUEBERRY
					arr.push(:NOMELBERRY)
				end
			else
				case playerBerry
				#General Cases
				when :LEPPABERRY,:FIGYBERRY,:RAZZBERRY,:POMEGBERRY,:TAMATOBERRY,:SPELONBERRY,
						:OCCABERRY,:CHOPLEBERRY,:TANGABERRY,:BABIRIBERRY,:LIECHIBERRY,:LANSATBERRY,:ENIGMABERRY
					arr.push(:CHERIBERRY,:PECHABERRY,:RAWSTBERRY)
				when :ORANBERRY,:WIKIBERRY,:BLUKBERRY,:KELPSYBERRY,:CORNNBERRY,:PAMTREBERRY,
						:PASSHOBERRY,:KEBIABERRY,:CHARTIBERRY,:CHILANBERRY,:GANLONBERRY,:MICLEBERRY,:KEEBERRY,:STARFBERRY
					arr.push(:CHESTOBERRY,:RAWSTBERRY,:ASPEARBERRY)
				when :PERSIMBERRY,:MAGOBERRY,:NANABBERRY,:QUALOTBERRY,:MAGOSTBERRY,:WATMELBERRY,
						:WACANBERRY,:SHUCABERRY,:KASIBBERRY,:SALACBERRY,:CUSTAPBERRY,:ROSELIBERRY
					arr.push(:PECHABERRY,:ASPEARBERRY,:CHERIBERRY)
				when :LUMBERRY,:AGUAVBERRY,:WEPEARBERRY,:HONDEWBERRY,:RABUTABERRY,:DURINBERRY,
						:RINDOBERRY,:COBABERRY,:HABANBERRY,:PETAYABERRY,:JABOCABERRY,:MARANGABERRY
					arr.push(:RAWSTBERRY,:CHERIBERRY,:CHESTOBERRY)
				when :SITRUSBERRY,:IAPAPABERRY,:PINAPBERRY,:GREPABERRY,:NOMELBERRY,:BELUEBERRY,
						:YACHEBERRY,:COLBURBERRY,:APICOTBERRY,:ROWAPBERRY
					arr.push(:ASPEARBERRY,:CHESTOBERRY,:PECHABERRY)
				#Special Cases
				when :CHERIBERRY
					arr.push(:ASPEARBERRY,:RAWSTBERRY,:PECHABERRY)
				when :CHESTOBERRY
					arr.push(:CHERIBERRY,:ASPEARBERRY,:RAWSTBERRY)
				when :PECHABERRY
					arr.push(:CHESTOBERRY,:CHERIBERRY,:ASPEARBERRY)
				when :RAWSTBERRY
					arr.push(:PECHABERRY,:CHESTOBERRY,:CHERIBERRY)
				when :ASPEARBERRY
					arr.push(:RAWSTBERRY,:PECHABERRY,:CHESTOBERRY)
				end
			end
		end 
		arr.pop if playerCount == 2
		arr.pop(2) if playerCount == 1
		return arr
	end
	
	#------------#
	# Set bitmap #
	#------------#
	# Image
	def create_sprite(spritename,filename,vp,dir="")
		@sprites["#{spritename}"] = Sprite.new(vp)
		folder = "Pokeblock/UI Berry Blender"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	def set_sprite(spritename,filename,dir="")
		folder = "Pokeblock/UI Berry Blender"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	#------#
	# Text #
	#------#
	# Draw
	def create_sprite_2(spritename,vp)
		@sprites["#{spritename}"] = Sprite.new(vp)
		@sprites["#{spritename}"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
	end
	# Write
	def drawTxt(bitmap,textpos,fontsize=nil,font=nil,width=0,pw=false,height=0,ph=false,clearbm=true)
		# Sprite
		bitmap = @sprites["#{bitmap}"].bitmap
		bitmap.clear if clearbm
		# Set font, size
		(font!=nil)? (bitmap.font.name=font) : pbSetSystemFont(bitmap)
		bitmap.font.size = fontsize if !fontsize.nil?
		textpos.each { |i|
			if pw
				i[1] += width==0 ? 0 : width==1 ? bitmap.text_size(i[0]).width/2 : bitmap.text_size(i[0]).width
			else
				i[1] -= width==0 ? 0 : width==1 ? bitmap.text_size(i[0]).width/2 : bitmap.text_size(i[0]).width
			end
			if ph
				i[2] += height==0 ? 0 : height==1 ? bitmap.text_size(i[0]).height/2 : bitmap.text_size(i[0]).height
			else
				i[2] -= height==0 ? 0 : height==1 ? bitmap.text_size(i[0]).height/2 : bitmap.text_size(i[0]).height
			end
		}
		pbDrawTextPositions(bitmap,textpos)
	end
	# Clear
	def clearTxt(bitmap)
		@sprites["#{bitmap}"].bitmap.clear
	end
	#------------------------------------------------------------------------------#
	# Set SE for input
	#------------------------------------------------------------------------------#
	def checkInput(name,exact=false)
		if exact
			if Input.triggerex?(name)
				(name==:X)? pbPlayCloseMenuSE : pbPlayDecisionSE
				return true
			end
		else
			if Input.trigger?(name)
				(name==Input::BACK)? pbPlayCloseMenuSE : pbPlayDecisionSE if @showPage != 0
				return true
			end
		end
		return false
	end
	#--------------#
	# Update
	#--------------#
	# Dispose
	def dispose(id=nil)
	  (id.nil?)? pbDisposeSpriteHash(@sprites) : pbDisposeSprite(@sprites,id)
	end
	# Update (just script)
	def update
	  pbUpdateSpriteHash(@sprites)
	end
	# Update
	def update_ingame
	  Graphics.update
	  Input.update
	  pbUpdateSpriteHash(@sprites)
	end
	#--------------#
	# Create scene #
	#--------------#
	def create_scene
		# Create scene
		create_sprite("behind", "Behind", @viewport)
		# Create time bar
		create_sprite("time bar", "Time", @viewport)
		x = 188 - @sprites["time bar"].bitmap.width
		y = 5
		set_xy_sprite("time bar", x, y)
		# Last is player and special
		arr = ["OnePlayer", "TwoPlayers", "ThreePlayers", "FourPlayers", "TwoPlayers"]
		create_sprite("scene", arr[@playerCount], @viewport)
		# Name text (playing)
		create_sprite_2("name text", @viewport)
		# Speed text (playing)
		create_sprite_2("speed text", @viewport)
		# Create circle
		create_sprite("circle", "Circle", @viewport)
		ox = @sprites["circle"].bitmap.width / 2
		oy = @sprites["circle"].bitmap.height / 2
		set_oxoy_sprite("circle", ox, oy)
		x = Graphics.width / 2
		y = Graphics.height / 2
		set_xy_sprite("circle", x, y)
		set_zoom_sprite("circle", 3, 3)
		set_visible_sprite("circle")
		# Create number
		create_sprite("number icon", "3", @viewport)
		ox = @sprites["number icon"].bitmap.width / 2
		oy = @sprites["number icon"].bitmap.height / 2
		set_oxoy_sprite("number icon", ox, oy)
		set_xy_sprite("number icon", x, y)
		set_visible_sprite("number icon")
		# Start (image)
		create_sprite("start icon", "Start", @viewport)
		ox = @sprites["start icon"].bitmap.width / 2
		oy = @sprites["start icon"].bitmap.height / 2
		set_oxoy_sprite("start icon", ox, oy)
		set_xy_sprite("start icon", x, y)
		set_visible_sprite("start icon")
		# Effect
		draw_effect
		# Result (scene)
		create_sprite("result scene", "Results", @viewport)
		set_visible_sprite("result scene")
		# Text
		create_sprite_2("result text", @viewport)
		create_sprite_2("result icon text", @viewport)
	end

	#----------------#
	# Zoom in circle #
	#----------------#
	def zoom_circle_before_start
		set_visible_sprite("circle", true)
		num = 0.5
		4.times { |i|
			update_ingame
			@sprites["circle"].zoom_x -= num
			@sprites["circle"].zoom_y -= num
		}
		pbSEPlay("Battle catch click",100,100)
	end

	#----------------#
	# Count to start #
	#----------------#
	def count_and_start
		number = 2
		pbWait(40)
		set_visible_sprite("number icon", true)
		pbSEPlay("Berry Blender Countdown", 100, 100)
		pbWait(40)
		2.times { |i|
			update_ingame
			set_sprite("number icon", "#{number}")
			pbSEPlay("Berry Blender Countdown", 100, 100)
			pbWait(40)
			number -= 1
		}
		set_visible_sprite("number icon")
		set_visible_sprite("start icon", true)
		pbSEPlay("Berry Blender Start", 100, 100)
		pbWait(40)
		set_visible_sprite("start icon")
	end

	#---------------------------------#
	# Set feature perfect, good, miss #
	#---------------------------------#
	# pos: define player
	# angle: angle to define position of bitmap
	def angle_circle(method, angle, pos=0)
		case method
		# Perfect
		when :perfect
			# Increase feature
			@count[@name[pos]][:perfect] += 1
			# Update speed
			update_speed_increse(6)
			# Show effect
			@showEffect = true
			# Update time bar
			update_time_bar(6)
			# Draw bitmap
			draw_perfect_good_miss(angle, 0, pos)
			pbSEPlay("Berry Blender Perfect", 100, 100)
		# Good
		when :good
			# Increase feature
			@count[@name[pos]][:good] += 1
			# Update speed
			update_speed_increse(2)
			# Update time bar
			update_time_bar(3)
			# Draw bitmap
			draw_perfect_good_miss(angle, 1, pos)
			pbSEPlay("Berry Blender Good", 100, 100)
		# Miss
		when :miss
			# Increase feature
			@count[@name[pos]][:miss] += 1
			# Update speed
			update_speed_decrease(3)
			# Draw bitmap
			draw_perfect_good_miss(angle, 2, pos)
			pbSEPlay("Berry Blender Miss", 100, 100)
		end
	end

	# Draw bitmap #
	FEATURE_VISIBLE_FALSE = 5
	def draw_perfect_good_miss(angle, feature=0, pos=0)
		arr  = ["Perfect", "Good", "Miss"]
		name = feature == 0 ? :perfect : feature == 1 ? :good : :miss
		spritename = "#{arr[feature]} #{@count[@name[pos]][name]}"
		return if @sprites[spritename]
		create_sprite(spritename, arr[feature], @viewport)
		ox = @sprites[spritename].bitmap.width / 2
		oy = @sprites[spritename].bitmap.height / 2
		set_oxoy_sprite(spritename, ox, oy)
		x = angle == 40 || angle == 140 ? 186 : 326
		y = angle == 40 || angle == 320 ? 113 : 271
		set_xy_sprite(spritename, x, y)
		@showFeature[@name[pos]][name] << FEATURE_VISIBLE_FALSE
	end

	# Draw effect when press perfect #
	def draw_effect
		2.times { |j|
			10.times { |i|
				create_sprite("effect #{j} #{i}", "Effect_#{j+1}", @viewport)
				ox = @sprites["effect #{j} #{i}"].bitmap.width / 2
				oy = @sprites["effect #{j} #{i}"].bitmap.height / 2
				set_oxoy_sprite("effect #{j} #{i}", ox, oy)
				set_visible_sprite("effect #{j} #{i}")
			}
		}
	end

	#------#
	# Fade #
	#------#
	def fade_in
		return if @fade
		numFrames = (Graphics.frame_rate*0.4).floor
	alphaDiff = (255.0/numFrames).ceil
		(0..numFrames).each { |i|
			@viewport.color = Color.new(0, 0, 0, i * alphaDiff)
			pbWait(1)
		}
		@fade = true
	end

	def fade_out
		return unless @fade
		numFrames = (Graphics.frame_rate*0.4).floor
	alphaDiff = (255.0/numFrames).ceil
		(0..numFrames).each { |i|
			@viewport.color = Color.new(0, 0, 0, (numFrames - i) * alphaDiff)
			pbWait(1)
		}
		@fade = false
	end
	#===============================================================
	#  4 - Update
	#===============================================================

	def update_main
		update_circle
		update_features
		update_effect
		update_speedTxt
		update_time_bar_auto
		if @result
			set_visible_sprite("result scene", true)
			# Draw result
			draw_result
			return if @countFade == 2
			# Increase count
			@countFade += 1
		end
	end

	#-------------#
	# Turn circle #
	#-------------#
	def update_circle
		# Increase speed
		if @result
			if @frames_rate > 0
				@frames_rate -= 3
				@frames_rate  = 0 if @frames_rate < 0
				# Update angle
				update_angle_circle
			else
				Graphics.frame_rate = @old_frames_rate
			end
			return
		end
		# Update angle
		update_angle_circle
	end

	def update_angle_circle
		return if @frames % @speed != 0
		Graphics.frame_rate = @old_frames_rate + @frames_rate
		# Update circle sprite
		@sprites["circle"].angle += 10
		@sprites["circle"].angle %= 360
	end

	# Use when player press perfect, good or miss
	def update_speed_increse(num)
		@speed -= num
		@speed  = 1 if @speed < 1
		@frames_rate = update_speed(true, @frames_rate, num) if @speed == 1
		@frames_rate = 120 - @old_frames_rate if @old_frames_rate + @frames_rate > 120
		# Update @speedTxt
		update_speedTxt_press(true, num)
		@notPress = @playerCount == 0 ? 400 : 100 * @playerCount
	end

	def update_speed_decrease(num)
		if @frames_rate == 0
			@speed += num
			@speed  = MAX_SPEED if @speed >= MAX_SPEED
		else
			@frames_rate = update_speed(false, @frames_rate, num)
			@frames_rate = 0 if @frames_rate < 0
		end
		# Update @speedTxt
		update_speedTxt_press(false, num)
		@notPress = @playerCount == 0 ? 400 : 100 * @playerCount
	end
	
	def update_speed(plus, realnum, num)
		return 0 if @speed != 1
		sum = @old_frames_rate + @frames_rate
		if sum >= 100 && sum <= 120
			plus ? (realnum += num) : (realnum -= num * 1.5)
		elsif sum >= 80 && sum < 100
			plus ? (realnum += (num * 1.3)) : (realnum -= num * 1.7)
		elsif sum >= 40 && sum < 80
			plus ? (realnum += (num * 1.7)) : (realnum -= num * 1.9)
		else
			plus ? (realnum += (num * 2.0)) : (realnum -= num * 2.0)
		end
		return realnum.round(2)
	end

	#-----------------------------------#
	# Speed text (speed to define item) #
	#-----------------------------------#
	def update_speedTxt_press(plus, num)
		if @speed.between?(2, MAX_SPEED-1)
			@speedTxt += 0.5
			@speedTxt  = 12 if @speedTxt > 12
		end
		@speedTxt = update_speed(plus, @speedTxt, num)
		@speedTxt = 7.0 if @speedTxt < 7
		@speedTxt = 110 if @speedTxt > 110
	end

	def update_speedTxt
		return if @result
		# Check if player doesn't play
		@notPress -= 1
		@notPress  = 0 if @notPress < 0
		# Save max speed
		@maxSpeed = [@maxSpeed, @speedTxt].max
		return if @notPress > 0
		@speedTxt -= 1
		@speedTxt  = 7.0 if @speedTxt < 7
		@frames_rate -= 1
		@frames_rate  = 0 if @frames_rate < 0
		@speed += 1 if @frames_rate == 0
		@speed  = MAX_SPEED if @speed >= MAX_SPEED
	end

	#--------#
	# Effect #
	#--------#
	def update_effect
		if @result
			2.times { |j|
				10.times { |i| set_visible_sprite("effect #{j} #{i}") }
			}
		else
			@trigger_effect.each { |k, v|
				next unless @trigger_effect[k][0]
				@trigger_effect[k][1] += 1
				one = @old_frames_rate
				two = @old_frames_rate + @frames_rate
				next if @trigger_effect[k][1] <= two * 5 / two
				2.times { |i| set_visible_sprite("effect #{i} #{k}") }
				@trigger_effect[k] = [false, 0]
			}
			return unless @showEffect
			random1 = rand(10)
			@showEffect = false
			return if @trigger_effect[random1][0]
			2.times { |i|
				x = rand(Graphics.width)
				y = rand(Graphics.height)
				set_xy_sprite("effect #{i} #{random1}", x, y)
				set_visible_sprite("effect #{i} #{random1}", true)
			}
			@trigger_effect[random1][0] = true
		end
	end

	#-------------------------------#
	# Features: perfect, good, miss #
	#-------------------------------#
	def update_features
		return if @checkall
		@showFeature.each { |k, v|
			arr = [:perfect, :good, :miss]
			arr.each_with_index { |name, i| v[name] = @result ? update_dispose_all_features(v[name], i, k) : update_small_features(v[name], i, k) }
		}
		@checkall = true if @result
	end

	def update_small_features(arr, feature, nameplayer)
		return [] if arr.size == 0
		arr2 = ["Perfect", "Good", "Miss"]
		name = feature == 0 ? :perfect : feature == 1 ? :good : :miss
		arr.each_with_index { |a, i|
			spritename = "#{arr2[feature]} #{@count[nameplayer][name]}"
			arr[i] -= 1
			arr[i]  = 0 if a < 0
			dispose(spritename) if a == 1
		}
		return arr
	end

	def update_dispose_all_features(arr, feature, nameplayer)
		return [] if arr.size == 0
		arr2 = ["Perfect", "Good", "Miss"]
		name = feature == 0 ? :perfect : feature == 1 ? :good : :miss
		arr.each_with_index { |a, i|
			spritename = "#{arr2[feature]} #{@count[nameplayer][name]}"
			dispose(spritename) if !@sprites[spritename].nil?
		}
	end

	#-------------#
	# Update time #
	#-------------#
	def update_time_bar(num)
		return if @result
		if @sprites["time bar"].x + num > 188
			@sprites["time bar"].x = 188
			# Store result
			set_order_result
			# Fade
			fade_in
			@result = true
			return
		end
		@sprites["time bar"].x += num
	end

	def update_time_bar_auto = update_time_bar(0.5)

	#===============================================================
	#  5 - Set Input
	#===============================================================

	def set_input
		player_press
		press_AI_top_right
		press_AI_bottom_left
		press_AI_bottom_right
		press_AI_special
	end

	#-------------#
	# Player play #
	#-------------#
	def player_press
		@exit = true if checkInput(Input::BACK) && @showPage == 1
		return unless checkInput(Input::USE)
		if @result
			@showPage == 0 ? (@showPage = 1) : (@exit = true)
			return
		end
		angle = @sprites["circle"].angle
		angle = 40 if $DEBUG && Input.press?(Input::CTRL)
		angle = 30 if $DEBUG && Input.press?(:G)
		angle = 20 if $DEBUG && Input.press?(:M)
		case angle
		when 40 then angle_circle(:perfect, 40)
		when 30,50 then angle_circle(:good, 40)
		else angle_circle(:miss, 40)
		end
	end

	#------------------------#
	# Set AI play, not input #
	#------------------------#
	def press_AI_normal(num, angle)
		return if @result
		return if @playerCount < num || @playerCount == 4
		if @sprites["circle"].angle != angle
			@pressCheck[num] = false
			return
		end
		return if @pressCheck[num]
		random = rand(6)
		case random
		when 0 then angle_circle(:perfect, angle, num)
		when 1 then angle_circle(:good, angle, num)
		when 2, 3 then angle_circle(:miss, angle, num)
		end
		@pressCheck[num] = true
	end

	def press_AI_top_right = press_AI_normal(1, 320)

	def press_AI_bottom_left = press_AI_normal(2, 140)

	def press_AI_bottom_right = press_AI_normal(3, 220)

	def press_AI_special
		return if @result
		return if @playerCount != 4
		if @sprites["circle"].angle != 320
			@pressCheck[1] = false
			return
		end
		return if @pressCheck[1]
		random = rand(5)
		case random
		when 0, 1 then angle_circle(:perfect, 320, 1)
		when 2, 3 then angle_circle(:good, 320, 1)
		end
		@pressCheck[1] = true
	end

	#===============================================================
	#  6 - Draw Text
	#===============================================================
	BASE_COLOR = MessageConfig::DARK_TEXT_MAIN_COLOR
	SHADOW_COLOR = MessageConfig::DARK_TEXT_SHADOW_COLOR
	
	def draw_name
		text = []
		time = @playerCount != 4 ? (@playerCount + 1) : 2
		time.times { |i|
			string = @name[i]
			x = 15 + 358 * (i % 2) + 5
			y = 113 - 10 + 11 + 115 * (i / 2)
			text << [string, x, y, 0, BASE_COLOR, SHADOW_COLOR]
		}
		drawTxt("name text", text)
	end

	#-----------#
	# Draw text #
	#-----------#
	def draw_main
		draw_speed
		draw_result
	end

	def draw_speed
		clearTxt("speed text")
		return if @result
		text = []
		string = "#{@speedTxt}"
		x = 210 + 46
		y = 330
		text << [string, x, y, 2, BASE_COLOR, SHADOW_COLOR]
		drawTxt("speed text", text, 20)
		#drawTxt("speed text", text, 20,nil,100,true)
	end

	def draw_result
		clearTxt("result text")
		return unless @result
		clearTxt("name text")
		# Draw bitmap
		draw_bitmap_features_text
		# Draw name, berry
		draw_players_text
	end

	def draw_bitmap_features_text
		clearTxt("result icon text")
		return if @showPage == 1
		arr = ["Perfect","Good","Miss"]
		bitmap = @sprites["result icon text"].bitmap
		imgpos = []
		arr.each_with_index { |a, i| imgpos << [ "Graphics/Pictures/Pokeblock/UI Berry Blender/#{a}", 240 + 80 * i, 90 + 4, 0, 0, -1, -1 ] }
		pbDrawImagePositions(bitmap, imgpos)
	end

	def draw_players_text
		bitmap = @sprites["result text"].bitmap
		maxy = 0
		text = []
		# Max speed
		string = "Max speed: #{@maxSpeed}"
		x = (Graphics.width - bitmap.text_size(string).width) / 2
		y = 48 + 6
		text << [string, x, y, 0, BASE_COLOR, SHADOW_COLOR]
		# Order
		@order.each_with_index { |order, i|
			string = "#{@orderNum[i]}. #{order[0][0]}"
			x = 5
			y = 130 + (20 + 26) * i
			maxy = y if maxy < y
			text << [string, x, y, 0, BASE_COLOR, SHADOW_COLOR]
			if @showPage == 1
				string = GameData::Item.get(order[0][1]).name
				x = 240
				text << [string, x, y, 0, BASE_COLOR, SHADOW_COLOR]
			end
			next if @showPage != 0
			order[0][2].each_with_index { |a, j|
				string = "#{a}"
				x = 240 + 16 + 80 * j
				text << [string, x, y, 2, BASE_COLOR, SHADOW_COLOR]
			}
		}
		# Flavor name
		flavorName = @flavorGet[0]
		flavorLevel = @flavorGet[1]
		flavorFeel = @flavorGet[2]
		string = "You got a #{flavorName} Pokéblock"
		string2 = "Lv. #{flavorLevel}   Feel #{flavorFeel}"
		#x = (Graphics.width - bitmap.text_size(string).width) / 2
		x = Graphics.width/2
		y = maxy + 40
		text << [string, x, y, 2, BASE_COLOR, SHADOW_COLOR]
		text << [string2, x, y+32, 2, BASE_COLOR, SHADOW_COLOR]
		drawTxt("result text", text)
	end
		
	#===============================================================
	#  7 - Result
	#===============================================================

	def set_order_result
		hash = {}
		@name.each_with_index { |name, i|
			arr1 = [name, @berry[i], []]
			arr2 = [:perfect, :good, :miss]
			sum  = 0
			arr2.each_with_index { |a, i|
				arr1[2] << @count[name][a]
				sum +=
					if i != 2
						10 ** (4 - i * 2) * @count[name][a]
					else
						- @count[name][a]
					end
			}
			hash[arr1] = sum
		}
		hash  = hash.sort_by(&:last).reverse.to_h
		num   = 0
		value = hash.values
		value.each_with_index { |v, i|
			num += 1
			if i == 0
				@orderNum << num
			else
				if value[i] == value[i-1]
					@orderNum[i] = @orderNum[i-1]
					num -= 1
				else
					@orderNum << num
				end
			end
		}
		@order = hash
		# Store in global
		store_in_global_result
	end

	def store_in_global_result
		sheen = BerryPoffin.averageSmoothness(@berry)
		if @berry.uniq.size != @berry.size || @forceFail
			# Black
			store_flavor_global_black(sheen)
		else
			flavor = []
			plus = false
			@berry.each { |berry| flavor << GameData::BerryData.get(berry).calculatedFlavor[1]}
			sum = [0, 0, 0, 0, 0]
			flavor.each { |fla|
				fla.each_with_index { |f, i| sum[i] += f }
			}
			negatives = 0
			sum.each do |x| negatives += 1 if x < 0 end
			sum.map! { |s| (s - negatives) }
			sum.map! { |s| s <= 0 ? 0 : s }
			vitess = @maxSpeed == 110 ? 1.33 : (@maxSpeed / 333 + 1).round(2)
			sum.map! { |s| s * vitess }
			sum.map! { |s| s.round }
			# Set global
			positive = sum.select { |s| s > 0 }
			level    = positive.max
			positionofmax = sum.index(level)
			flavorplus50  = sum.select { |s| s > 50 }.size > 0
			case positive.size
			when 0 then store_flavor_global_black(sheen)
			# 1 flavor
			when 1
				if flavorplus50
					name = "Gold"
				else
					arr  = ["Red", "Blue", "Pink", "Green", "Yellow"]
					name = arr[positionofmax]
				end
			# 2 flavors
			when 2
				if flavorplus50
					name = "Gold"
				else
					arr = ["Purple", "Indigo", "Brown", "Lite Blue", "Olive"]
					name = arr[positionofmax]
				end
			# Gray
			when 3 then name = "Gray"
			# White
			when 4, 5 then name = "White"
			end
			return if positive.size == 0
			newBlock = Pokeblock.new(name.to_sym,sum,sheen,plus)
			pbGainPokeblock(newBlock)
			# Set Result Display
			@flavorGet = [newBlock.color_name,newBlock.level,newBlock.smoothness]
		end
	end

	# Black flavor
	def store_flavor_global_black(sheen)
		arr  = []
		fake = []
		loop do
			random = rand(5)
			fake << random
			if fake.size == 3
				fake = [] if fake.uniq.size != fake.size
				break if fake.size == 3
			end
		end
		5.times { |i|
			if fake.include?(i)
				arr[i] = 2
				fake.delete(i)
			else
				arr << 0
			end
		}
		newBlock = Pokeblock.new(:Black,arr,sheen)
		pbGainPokeblock(newBlock)
		# Set Result Display
		@flavorGet = [newBlock.color_name,newBlock.level,newBlock.smoothness]
	end

	#===============================================================
	#  8 - Berry Animation
	#===============================================================
	
	# Pos = position of player's berry -> 0: Player, 1: AI-1, 2: AI-2, 3: AI-3, 
	def animationBerry(berrynumber, pos=0)
		if !@sprites["berry #{pos}"]
			begin
				filename = GameData::Item.icon_filename(berrynumber)
			rescue 
				p "You have an error when choosing berry"
				Kernel.exit!
			end
			@sprites["berry #{pos}"] = Sprite.new(@viewport)
			@sprites["berry #{pos}"].bitmap = Bitmap.new(filename)
			ox = @sprites["berry #{pos}"].bitmap.width/2
			oy = @sprites["berry #{pos}"].bitmap.height/2
			set_oxoy_sprite("berry #{pos}",ox,oy)
			x = Graphics.width / 2 + (pos==0 || pos==2 ? -Graphics.height/2 : Graphics.height/2)
			y = pos==0 || pos==1 ? 0 : Graphics.height
			set_xy_sprite("berry #{pos}",x,y)
			x0 = x
			y0 = y
		end
		t = 0
		loop do
			Graphics.update
			update
			if pos==0 || pos==1
				break if @sprites["berry #{pos}"].y >= (Graphics.height/2-10)
			else
				break if @sprites["berry #{pos}"].y <= (Graphics.height/2+10)
			end
			r = Graphics.height/4*Math.sqrt(2)
			t += 0.05
			case pos
			when 0
				x =  r*(1-Math.cos(t))
				y =  r*(t-Math.sin(t))
			when 1
				x = -r*(1-Math.cos(t))
				y =  r*(t-Math.sin(t))
			when 2
				x =  r*(t-Math.sin(t))
				y = -r*(1-Math.cos(t))
			when 3
				x = -r*(t-Math.sin(t))
				y = -r*(1-Math.cos(t))
			end
			x += x0
			y += y0
			set_xy_sprite("berry #{pos}", x, y)
		end
		dispose("berry #{pos}")
	end	
	
end

#===============================================================================
# Simple Berry Blender Scene
#=============================================================================== 

class SimpleBerryBlender_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
	@play = true
    @scene.pbStartScene
    while @play
		@play = @scene.pbScene
		@scene.pbRestartScene if @play
	end
    @scene.pbEndScene
    return true
  end
end

class SimpleBerryBlender_Scene
	include BopModule
	MAX_SPEED = 5

	def pbStartScene
		# Viewport
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		# Values
		# Set number to define player, quantity of players
		@playerCount = 0
		#sprites
		@sprites = {}
		# Store berry
		@berry = []
		# Set speed of circle
		@speed  = MAX_SPEED
		@frames = 0
		# Set frame to increase angle
		@frames_rate = 0
		@old_frames_rate = Graphics.frame_rate
		# Result (show result)
		@result = false
		@checkall = false
		@showPage = 0
		# Set name of flavor after playing
		@flavorGet = []
		# Set order
		@order = nil
		@orderNum = []
		# Fade
		@fade = false
		@countFade = 0
		# Finish
		@exit = false	
	end
	
	def pbRestartScene
		@restarted = true
		@sprites = {}
		# Store berry
		@berry = []
		# Set speed of circle
		@speed  = MAX_SPEED
		@frames = 0
		# Set frame to increase angle
		@frames_rate = 0
		@old_frames_rate = Graphics.frame_rate
		# Result (show result)
		@result = false
		@checkall = false
		@showPage = 0
		# Set name of flavor after playing
		@flavorGet = []
		# Set order
		@order = nil
		@orderNum = []
		# Fade
		@fade = false
		@countFade = 0
		# Finish
		@exit = false	
	end
	
	def pbScene
		# Create
		create_scene
		# Fade
		pbFadeInAndShow(@sprites) { update } if !@restarted
		# Choose berry
		notplay = false
		@berries   = nil
		if @restarted then @restarted = nil;
		else
			pbMessage(_INTL("Starting up the Berry Blender...")) 
			pbMessage(_INTL("Please select some berries from your bag to put in the Berry Blender."))
		end
		loop do
			@berries = BerryPoffin.pbPickBerryForBlenderSimple
			break notplay = true if @berries.nil? || @berries.empty?
			break
		end
		return if notplay
		# Animation berry
		animationBerry(@berries)
		# Zoom
		zoom_circle_before_start
		loop do
			update_ingame
			break if @exit
			# Fade
			fade_out if @countFade == 2
			# Update
			update_main
			# Increase frames
			@frames += 1
			@result = true if @frames >=80 && @sprites["circle"].angle == 0
		end
		results = pbCalculateSimplePokeblock(@berries)
		results.each { |pb| pbGainPokeblock(pb) }
		pbMessage(_INTL("You created {1} {2} Pokéblocks{3}!",results.length,results[0].color_name,(results[0].plus ? " +" : "")))
		return true if $PokemonBag.hasAnyBerry? && pbConfirmMessage(_INTL("Would you like to blend more berries?"))
		return false
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { update }
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbCalculateSimplePokeblock(berries)
		probability = 0
		posColors = []
		@berries.each { |berry| 
			data = GameData::BerryData.get(berry.id)
			probability += data.plusProbability
			posColors.push(data.block_color)
		}
		color = nil
		uniqColors = posColors.uniq
		if uniqColors.length >=4 then color = :Rainbow;
		elsif uniqColors.length == 1 then color = uniqColors[0]; 
		elsif uniqColors.length == posColors.length then color = posColors.sample;
		else
			c = []
			uniqColors.each { |color| 
				next c.push(color) if c.empty? || posColors.count(color) == posColors.count(c[0])
				c[0] = color if posColors.count(color) > posColors.count(c[0])
			}
			color = c.sample
		end
		plus = rand(100)<probability
		flavor = [0,0,0,0,0]
		fVal = (plus ? 15 : 5 )
		case color
		when :Rainbow then flavor = [fVal,fVal,fVal,fVal,fVal]
		when :Red then flavor[0] = fVal
		when :Blue then flavor[1] = fVal
		when :Pink then flavor[2] = fVal
		when :Green then flavor[3] = fVal
		when :Yellow then flavor[4] = fVal
		end
		results = []
		qty = berries.length
		qty.times { results.push(Pokeblock.new(color,flavor,0,plus)) }	
		return results
	end
	
	#------------#
	# Set bitmap #
	#------------#
	# Image
	def create_sprite(spritename,filename,vp,dir="")
		@sprites["#{spritename}"] = Sprite.new(vp)
		folder = "Pokeblock/UI Berry Blender"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	def set_sprite(spritename,filename,dir="")
		folder = "Pokeblock/UI Berry Blender"
		file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
		@sprites["#{spritename}"].bitmap = Bitmap.new(file)
	end
	#--------------#
	# Update
	#--------------#
	# Dispose
	def dispose(id=nil)
	  (id.nil?)? pbDisposeSpriteHash(@sprites) : pbDisposeSprite(@sprites,id)
	end
	# Update (just script)
	def update
	  pbUpdateSpriteHash(@sprites)
	end
	# Update
	def update_ingame
	  Graphics.update
	  Input.update
	  pbUpdateSpriteHash(@sprites)
	end
	#--------------#
	# Create scene #
	#--------------#
	def create_scene
		# Create scene
		create_sprite("behind", "SimpleBackground", @viewport)
		create_sprite("scene", "Simple", @viewport)
		# Create circle
		create_sprite("circle", "CircleSimple", @viewport)
		ox = @sprites["circle"].bitmap.width / 2
		oy = @sprites["circle"].bitmap.height / 2
		set_oxoy_sprite("circle", ox, oy)
		x = Graphics.width / 2
		y = Graphics.height / 2
		set_xy_sprite("circle", x, y)
		set_zoom_sprite("circle", 3, 3)
		set_visible_sprite("circle")
	end

	#----------------#
	# Zoom in circle #
	#----------------#
	def zoom_circle_before_start
		set_visible_sprite("circle", true)
		num = 0.5
		4.times { |i|
			update_ingame
			@sprites["circle"].zoom_x -= num
			@sprites["circle"].zoom_y -= num
		}
		pbSEPlay("Battle catch click",100,100)
	end


	def fade_out
		return unless @fade
		numFrames = (Graphics.frame_rate*0.4).floor
	alphaDiff = (255.0/numFrames).ceil
		(0..numFrames).each { |i|
			@viewport.color = Color.new(0, 0, 0, (numFrames - i) * alphaDiff)
			pbWait(1)
		}
		@fade = false
	end
	#===============================================================
	#  4 - Update
	#===============================================================

	def update_main
		update_circle
		if @result
			return if @countFade == 2
			# Increase count
			@countFade += 1
		end
	end

	#-------------#
	# Turn circle #
	#-------------#
	def update_circle
		# Increase speed
		if @result
			Graphics.frame_rate = @old_frames_rate
			@exit = true
			return
		end
		# Update angle
		update_angle_circle
	end

	def update_angle_circle
		return if @frames % @speed != 0
		Graphics.frame_rate = @old_frames_rate*2
		# Update circle sprite
		@sprites["circle"].angle += 10
		@sprites["circle"].angle %= 360
	end


	#===============================================================
	#  8 - Berry Animation
	#===============================================================
	
	def animationBerry(berries)
		b=[true,true,true,true]; x0=[]; y0=[]; d=[rand(10),rand(10),rand(10),rand(10)]
		berries.each_with_index { |berry,pos|
			if !@sprites["berry #{pos}"]
				begin
					filename = GameData::Item.icon_filename(berry)
				rescue 
					p "You have an error when choosing berry"
					Kernel.exit!
				end
				@sprites["berry #{pos}"] = Sprite.new(@viewport)
				@sprites["berry #{pos}"].bitmap = Bitmap.new(filename)
				@sprites["berry #{pos}"].visible = false
				ox = @sprites["berry #{pos}"].bitmap.width/2
				oy = @sprites["berry #{pos}"].bitmap.height/2
				set_oxoy_sprite("berry #{pos}",ox,oy)
				x = Graphics.width / 2 + (pos==0 || pos==2 ? -Graphics.height/2 : Graphics.height/2)
				y = pos==0 || pos==1 ? 0 : Graphics.height
				set_xy_sprite("berry #{pos}",x,y)
				b[pos]=false
				x0[pos] = x
				y0[pos] = y
			end
		}
		t = time = 0
		loop do
			Graphics.update
			update
			r = Graphics.height/4*Math.sqrt(2)
			t += 0.05
			time += 1
			cos = Math.cos(t)
			sin = Math.sin(t)
			if @sprites["berry 0"] && !b[0] && time>d[0]
				@sprites["berry 0"].visible = true
				@sprites["berry 0"].x =  r*(1-cos) + x0[0]
				@sprites["berry 0"].y =  r*(t-sin) + y0[0]
				if @sprites["berry 0"].y >= (Graphics.height/2-10)
					b[0] = true; @sprites["berry 0"].visible = false; end
			end
			if @sprites["berry 1"] && !b[1] && time>d[1]
				@sprites["berry 1"].visible = true
				@sprites["berry 1"].x = -r*(1-cos) + x0[1]
				@sprites["berry 1"].y =  r*(t-sin) + y0[1]
				if @sprites["berry 1"].y >= (Graphics.height/2-10)
					b[1] = true; @sprites["berry 1"].visible = false; end
			end
			if @sprites["berry 2"] && !b[2] && time>d[2]
				@sprites["berry 2"].visible = true
				@sprites["berry 2"].x =  r*(t-sin) + x0[2]
				@sprites["berry 2"].y = -r*(1-cos) + y0[2]
				if @sprites["berry 2"].y <= (Graphics.height/2+10)
					b[2] = true; @sprites["berry 2"].visible = false; end
			end
			if @sprites["berry 3"] && !b[3] && time>d[3]
				@sprites["berry 3"].visible = true
				@sprites["berry 3"].x = -r*(t-sin) + x0[3]
				@sprites["berry 3"].y = -r*(1-cos) + y0[3]
				if @sprites["berry 3"].y <= (Graphics.height/2+10)
					b[3] = true; @sprites["berry 3"].visible = false; end
			end
			break if (b[0]&&b[1]&&b[2]&&b[3])
		end
		dispose("berry 0"); dispose("berry 1"); dispose("berry 2"); dispose("berry 3");
	end	
	
end