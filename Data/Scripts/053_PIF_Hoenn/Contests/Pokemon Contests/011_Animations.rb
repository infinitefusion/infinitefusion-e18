#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Animations
#====================================================================================	
class PokemonContestTalent_Scene
	def pbDisplayPokemon(position)
		# Always dispose and recreate, since round order may have changed
		if @sprites["trainersprite#{position}"]
			@sprites["trainersprite#{position}"].dispose
			@sprites.delete("trainersprite#{position}")
		end

		pokemon = @contest.roundOrder[position - 1]
		if pokemon == @contest.pokemonOne
			original_index = 0
		elsif pokemon == @contest.pokemonTwo
			original_index = 1
		elsif pokemon == @contest.pokemonThree
			original_index = 2
		else
			original_index = nil
		end

		if original_index
			appearance = @contest.contestTrainerAppearances[original_index]
			bitmap = generate_front_trainer_sprite_bitmap_from_appearance(appearance)
		else
			bitmap = generate_front_trainer_sprite_bitmap
		end

		@sprites["trainersprite#{position}"] = IconSprite.new(0, 0, @viewport)
		@sprites["trainersprite#{position}"].setBitmapDirectly(bitmap)
		@sprites["trainersprite#{position}"].x = -140
		@sprites["trainersprite#{position}"].y = 24
		@sprites["trainersprite#{position}"].mirror = true
		@sprites["trainersprite#{position}"].z = 50

		@sprites["pokemonsprite#{position}"] = PokemonSprite.new(@viewport)
		@sprites["pokemonsprite#{position}"].setPokemonBitmap(@contest.roundOrder[position-1], true)
		@sprites["pokemonsprite#{position}"].setOffset
		@sprites["pokemonsprite#{position}"].mirror = true
		@sprites["pokemonsprite#{position}"].z = 50
		xPos = ContestSettings::FOCUSUSER_X
		yPos = ContestSettings::FOCUSUSER_Y
		@sprites["pokemonsprite#{position}"].x = xPos
		@sprites["pokemonsprite#{position}"].y = yPos
		10.times {
			@sprites["pokemonsprite#{position}"].x -= 20
			@sprites["trainersprite#{position}"].x += 10
			Graphics.update
			Input.update
			pbUpdateSpriteHash(@sprites)
		}
	end

	def pbDismissPokemon(position)
		10.times {
			@sprites["pokemonsprite#{position}"].x += 20
			@sprites["trainersprite#{position}"].x -= 10
			Graphics.update
			Input.update
			pbUpdateSpriteHash(@sprites)
		}
		@sprites["pokemonsprite#{position}"].dispose
		@sprites.delete("pokemonsprite#{position}")
	end
	
	#=============================================================================
	# Plays a move/common animation
	#=============================================================================	
	def pbPlayAnimation(moveID, atself = false, hitNum=0)
		# animID = find_animation(moveID, 0, hitNum)
		animID = pbFindMoveAnimation(moveID, 0, hitNum)
		return if !animID
		anim = animID[0]
		animations = pbLoadBattleAnimations
		return if !animations
		pbAnimationCore(animations[anim], atself)
	end

	def pbAnimationCore(animation, atself)
		return if !animation
		@briefMessage = false
		userSprite   = @sprites["pokemonsprite#{@currentPosition}"]
		targetSprite = atself ? userSprite : @sprites["opponent"]
		# Remember the original positions of Pokémon sprites
				oldUserX = userSprite.x
				oldUserY = userSprite.y
				oldTargetX = atself ? oldUserX : targetSprite.x
				oldTargetY = atself ? oldUserY : targetSprite.y
				oldUserOx = userSprite.ox
				oldUserOy = userSprite.oy
				oldTargetOx = atself ? oldUserOx : targetSprite.ox
				oldTargetOy = atself ? oldUserOy : targetSprite.oy
		# Create the animation player
		animPlayer = AnimationPlayerXContest.new(animation, userSprite, targetSprite, @viewport, self)
		#animPlayer = PBAnimationPlayerX.new(animation, user, target, self, oppMove)
		# Apply a transformation to the animation based on where the user and target
		# actually are. Get the centres of each sprite.
		userHeight = (userSprite&.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
		if targetSprite
		  targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
		else
		  targetHeight = userHeight
		end
		animPlayer.setLineTransform(
			#Battle::Scene::FOCUSUSER_X, Battle::Scene::FOCUSUSER_Y, Battle::Scene::FOCUSTARGET_X, Battle::Scene::FOCUSTARGET_Y,
			ContestSettings::FOCUSUSER_X, ContestSettings::FOCUSUSER_Y, ContestSettings::FOCUSTARGET_X, ContestSettings::FOCUSTARGET_Y,
		  oldUserX, oldUserY - (userHeight / 2) + 80, oldTargetX, oldTargetY - (targetHeight / 2) + 80
		)
		# Play the animation
		animPlayer.start
		loop do
		  animPlayer.update
		  Graphics.update
		  Input.update
		  pbUpdateSpriteHash(@sprites)    
		  break if animPlayer.animDone?
		end
		animPlayer.dispose
		# Return Pokémon sprites to their original positions
		if userSprite
		  userSprite.x = oldUserX
		  userSprite.y = oldUserY
		  userSprite.ox = oldUserOx
		  userSprite.oy = oldUserOy
		end
		if targetSprite
		  targetSprite.x = oldTargetX
		  targetSprite.y = oldTargetY
		  targetSprite.ox = oldTargetOx
		  targetSprite.oy = oldTargetOy
		end
	end
	
	
	
	#copied directly from Scene_PlayAnimaitons
	# Returns the animation ID to use for a given move/user. Returns nil if that
	# move has no animations defined for it.
	def pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum = 0)
		id_number = GameData::Move.get(moveID).id_number
		noFlip = false
		if (idxUser & 1) == 0
			anim = move2anim[0][id_number]
		else
			anim = move2anim[1][id_number]
			noFlip = true if anim
			anim = move2anim[0][id_number] if !anim
		end
		return [anim + hitNum, noFlip] if anim
		return nil
	end

	# Returns the animation ID to use for a given move. If the move has no
	# animations, tries to use a default move animation depending on the move's
	# type. If that default move animation doesn't exist, trues to use Tackle's
	# move animation. Returns nil if it can't find any of these animations to use.
	def pbFindMoveAnimation(moveID, idxUser, hitNum)
		begin
		  move2anim = pbLoadMoveToAnim
		  # Find actual animation requested (an opponent using the animation first
		  # looks for an OppMove version then a Move version)
		  anim = pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
		  return anim if anim
		  # Actual animation not found, get the default animation for the move's type
		  moveData = GameData::Move.get(moveID)
		  target_data = GameData::Target.get(moveData.target)
		  moveType = moveData.type
		  moveKind = moveData.category
		  moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
		  moveKind += 3 if moveKind == 2 && target_data.num_targets > 0
		  # [one target physical, one target special, user status,
		  #  multiple targets physical, multiple targets special, non-user status]
		  typeDefaultAnim = {
			:NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,  :SWIFT,        :TAILWHIP],
			:FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,         nil,           nil],
			:FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,    :FEATHERDANCE],
			:POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,         :POISONPOWDER],
			:GROUND   => [:SANDTOMB,     :MUDSLAP,      nil,          :EARTHQUAKE, :EARTHPOWER,   :MUDSPORT],
			:ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  nil,           :SANDSTORM],
			:BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,  :STRINGSHOT],
			:GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,         nil,           :CONFUSERAY],
			:STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,           :METALSOUND],
			:FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,   :WILLOWISP],
			:WATER    => [:CRABHAMMER,   :WATERGUN,     :AQUARING,    nil,         :SURF,         :WATERSPORT],
			:GRASS    => [:VINEWHIP,     :MEGADRAIN,    :COTTONGUARD, :RAZORLEAF,  nil,           :SPORE],
			:ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,    :THUNDERWAVE],
			:PSYCHIC  => [:ZENHEADBUTT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE, :MIRACLEEYE],
			:ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,         :POWDERSNOW,   :HAIL],
			:DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,      nil],
			:DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,        :EMBARGO],
			:FAIRY    => [:TACKLE,       :FAIRYWIND,    :MOONLIGHT,   nil,         :SWIFT,        :SWEETKISS]
		  }
		  if typeDefaultAnim[moveType]
			anims = typeDefaultAnim[moveType]
			if GameData::Move.exists?(anims[moveKind])
			  anim = pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
			end
			if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
			  anim = pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
			end
			if !anim && GameData::Move.exists?(anims[2])
			  anim = pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
			end
		  end
		  return anim if anim
		  # Default animation for the move's type not found, use Tackle's animation
		  if GameData::Move.exists?(:TACKLE)
			return pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
		  end
		rescue
		end
		return nil
	end

	
end

class AnimationPlayerXContest
	attr_accessor :looping

	MAX_SPRITES = 60
	def initialize(animation,usersprite,targetsprite,vp,scene=nil,oppMove=false,inEditor=false)
		#targetsprite = usersprite if usersprite && !targetsprite #TDW Added
		@animation     = animation
		@user          = nil
		@usersprite    = usersprite
		@targetsprite  = targetsprite
		@userbitmap    = (@usersprite && @usersprite.bitmap) ? @usersprite.bitmap : nil # not to be disposed
		@targetbitmap  = (@targetsprite && @targetsprite.bitmap) ? @targetsprite.bitmap : nil # not to be disposed
		@scene         = scene
		@viewport      = vp
		@inEditor      = inEditor
		@looping       = false
		@animbitmap    = nil   # Animation sheet graphic
		@frame         = -1
		@framesPerTick = [Graphics.frame_rate/20,1].max   # 20 ticks per second
		@srcLine       = nil
		@dstLine       = nil
		@userOrig      = getSpriteCenter(@usersprite)
		@targetOrig    = getSpriteCenter(@targetsprite)
		@oldbg         = []
		@oldfo         = []
		initializeSprites
	end
	
	def initializeSprites
		# Create animation sprites (0=user's sprite, 1=target's sprite)
		@animsprites = []
		@animsprites[0] = @usersprite
		@animsprites[1] = @targetsprite
		(2...MAX_SPRITES).each do |i|
		  @animsprites[i] = Sprite.new(@viewport)
		  @animsprites[i].bitmap  = nil
		  @animsprites[i].visible = false
		end
		# Create background colour sprite
		@bgColor = ColoredPlane.new(Color.new(0, 0, 0), @viewport)
		@bgColor.z       = 5
		@bgColor.opacity = 0
		@bgColor.refresh
		# Create background graphic sprite
		@bgGraphic = AnimatedPlane.new(@viewport)
		@bgGraphic.setBitmap(nil)
		@bgGraphic.z       = 5
		@bgGraphic.opacity = 0
		@bgGraphic.refresh
		# Create foreground colour sprite
		@foColor = ColoredPlane.new(Color.new(0, 0, 0), @viewport)
		@foColor.z       = 85
		@foColor.opacity = 0
		@foColor.refresh
		# Create foreground graphic sprite
		@foGraphic = AnimatedPlane.new(@viewport)
		@foGraphic.setBitmap(nil)
		@foGraphic.z       = 85
		@foGraphic.opacity = 0
		@foGraphic.refresh
	end	
		
	def dispose
		@animbitmap&.dispose
		(2...MAX_SPRITES).each do |i|
			@animsprites[i]&.dispose
		end
		@bgGraphic.dispose
		@bgColor.dispose
		@foGraphic.dispose
		@foColor.dispose
	end		
	
	def start
		@frame = 0
	end		
		
	def animDone?
		return @frame<0
	end	
	
	def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
		@srcLine = [x1,y1,x2,y2]
		@dstLine = [x3,y3,x4,y4]
	end	
		
	def update
		return if @frame < 0
		animFrame = @frame / @framesPerTick

		# Loop or end the animation if the animation has reached the end
		if animFrame >= @animation.length
		  @frame = (@looping) ? 0 : -1
		  if @frame < 0
			@animbitmap&.dispose
			@animbitmap = nil
			return
		  end
		end
		# Load the animation's spritesheet and assign it to all the sprites.
		if !@animbitmap || @animbitmap.disposed?
		  @animbitmap = AnimatedBitmap.new("Graphics/Animations/" + @animation.graphic,
										   @animation.hue).deanimate
		  MAX_SPRITES.times do |i|
			@animsprites[i].bitmap = @animbitmap if @animsprites[i]
		  end
		end
		# Update background and foreground graphics
		@bgGraphic.update
		@bgColor.update
		@foGraphic.update
		@foColor.update

		# Update all the sprites to depict the animation's next frame
		if @framesPerTick == 1 || (@frame % @framesPerTick) == 0
		  thisframe = @animation[animFrame]
		  # Make all cel sprites invisible
		  MAX_SPRITES.times do |i|
			@animsprites[i].visible = false if @animsprites[i]
		  end
		  # Set each cel sprite acoordingly
		  thisframe.length.times do |i|
			cel = thisframe[i]
			next if !cel
			sprite = @animsprites[i]
			next if !sprite
			# Set cel sprite's graphic
			case cel[AnimFrame::PATTERN]
			when -1
			  sprite.bitmap = @userbitmap
			when -2
			  sprite.bitmap = @targetbitmap
			else
			  sprite.bitmap = @animbitmap
			end
			cel[AnimFrame::MIRROR] = 1
			# Apply settings to the cel sprite
			pbSpriteSetAnimFrame(sprite, cel, @usersprite, @targetsprite)
			case cel[AnimFrame::FOCUS]
			# when 1   # Focused on target
				# sprite.x = cel[AnimFrame::X] - 304
				# sprite.y = cel[AnimFrame::Y] - 16
			# when 2   # Focused on user
				# sprite.x = cel[AnimFrame::X] + 139
				# sprite.y = cel[AnimFrame::Y] - 48
			when 1   # Focused on target
			  sprite.x = cel[AnimFrame::X] + @targetOrig[0] - ContestSettings::FOCUSTARGET_X #+ ContestSettings::FOCUSTARGET_X
			  sprite.y = cel[AnimFrame::Y] + @targetOrig[1] - ContestSettings::FOCUSTARGET_Y #+ ContestSettings::FOCUSTARGET_Y
			when 2   # Focused on user
			  sprite.x = cel[AnimFrame::X] + @userOrig[0] - ContestSettings::FOCUSUSER_X #+ ContestSettings::FOCUSUSER_X
			  sprite.y = cel[AnimFrame::Y] + @userOrig[1] - ContestSettings::FOCUSUSER_Y #+ ContestSettings::FOCUSUSER_Y
			when 3   # Focused on user and target
			  next if !@srcLine || !@dstLine
			  point = transformPoint(@srcLine[0], @srcLine[1], @srcLine[2], @srcLine[3],
									 @dstLine[0], @dstLine[1], @dstLine[2], @dstLine[3],
									 sprite.x, sprite.y)
			  sprite.x = point[0]
			  sprite.y = point[1]
			  if isReversed(@srcLine[0], @srcLine[2], @dstLine[0], @dstLine[2]) &&
				 cel[AnimFrame::PATTERN] >= 0
				# Reverse direction
				sprite.mirror = !sprite.mirror
			  end
			end		
			sprite.x += 64 if @inEditor
			sprite.y += 64 if @inEditor	
			
			# For things that move the sprite, make it so it gets mirrored (like for Take Down or Protect)
			if cel[AnimFrame::FOCUS] == 1 || cel[AnimFrame::FOCUS] == 2
				origDistance = sprite.x - (cel[AnimFrame::FOCUS] == 1 ? @targetOrig[0] : @userOrig[0])
				sprite.x -= origDistance*2
			end
			
		  end
		  # Play timings
		  @animation.playTiming(animFrame, @bgGraphic, @bgColor, @foGraphic, @foColor, @oldbg, @oldfo, @user)
		end
		@frame += 1
	end	
end		

# def pbSpriteSetAnimFrameContest(sprite, frame, user = nil, target = nil, inEditor = false)
	# return if !sprite
	# if !frame
		# sprite.visible  = false
		# sprite.src_rect = Rect.new(0, 0, 1, 1)
		# return
	# end
	# sprite.blend_type = frame[AnimFrame::BLENDTYPE]
	# sprite.angle      = frame[AnimFrame::ANGLE]
	# sprite.mirror     = (frame[AnimFrame::MIRROR] > 0)
	# sprite.opacity    = frame[AnimFrame::OPACITY]
	# sprite.visible    = true
	# if !frame[AnimFrame::VISIBLE] == 1 && inEditor
		# sprite.opacity /= 2
	# else
		# sprite.visible = (frame[AnimFrame::VISIBLE] == 1)
	# end
	# pattern = frame[AnimFrame::PATTERN]
	# if pattern >= 0
		# animwidth = 192
		# sprite.src_rect.set((pattern % 5) * animwidth, (pattern / 5) * animwidth,
							# animwidth, animwidth)
	# else
		# sprite.src_rect.set(0, 0,
							# (sprite.bitmap) ? sprite.bitmap.width : 128,
							# (sprite.bitmap) ? sprite.bitmap.height : 128)
	# end
	# sprite.zoom_x = frame[AnimFrame::ZOOMX] / 100.0
	# sprite.zoom_y = frame[AnimFrame::ZOOMY] / 100.0
	# sprite.color.set(
		# frame[AnimFrame::COLORRED],
		# frame[AnimFrame::COLORGREEN],
		# frame[AnimFrame::COLORBLUE],
		# frame[AnimFrame::COLORALPHA]
	# )
	# sprite.tone.set(
		# frame[AnimFrame::TONERED],
		# frame[AnimFrame::TONEGREEN],
		# frame[AnimFrame::TONEBLUE],
		# frame[AnimFrame::TONEGRAY]
	# )
	# sprite.ox = sprite.src_rect.width / 2
	# sprite.oy = sprite.src_rect.height / 2
	# sprite.x  = frame[AnimFrame::X]
	# sprite.y  = frame[AnimFrame::Y]
	# if sprite != user && sprite != target
		# case frame[AnimFrame::PRIORITY]
		# when 0   # Behind everything
			# sprite.z = 10
		# when 1   # In front of everything
			# sprite.z = 80
		# when 2   # Just behind focus
			# case frame[AnimFrame::FOCUS]
			# when 1   # Focused on target
				# sprite.z = (target) ? target.z - 1 : 20
			# when 2   # Focused on user
				# sprite.z = (user) ? user.z - 1 : 20
			# else     # Focused on user and target, or screen
				# sprite.z = 20
			# end
		# when 3   # Just in front of focus
			# case frame[AnimFrame::FOCUS]
			# when 1   # Focused on target
				# sprite.z = (target) ? target.z + 1 : 80
			# when 2   # Focused on user
				# sprite.z = (user) ? user.z + 1 : 80
			# else     # Focused on user and target, or screen
				# sprite.z = 80
			# end
		# else
			# sprite.z = 80
		# end
	# end
# end