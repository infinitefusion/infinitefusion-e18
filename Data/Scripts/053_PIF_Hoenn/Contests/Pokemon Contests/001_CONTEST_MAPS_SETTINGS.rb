#====================================================================================
#  Contests Map Settings
#====================================================================================

module ContestSettings

#====================================================================================
#============================ Default Lobby Definitions =============================
#====================================================================================
	#--------------------------------------------------------------------------------
	# In contest lobby maps, this is the Event ID that represents the Front Desk
	# Event. By default, it's 1.
	#--------------------------------------------------------------------------------
	FRONT_DESK_GUIDE_EVENT 		= 1
	
	#--------------------------------------------------------------------------------
	# In contest lobby maps, this array is a list of Event IDs that represent the 
	# doors of the front desk. These will toggle Self Switch A as to appear opening.
	# By default, it's [2, 3]
	#--------------------------------------------------------------------------------
	FRONT_DESK_DOOR_EVENTS 		= [2, 3]
	
	#--------------------------------------------------------------------------------
	# Define the default lobby map for contests. By default, it's 33.
	#--------------------------------------------------------------------------------
	DEFAULT_LOBBY_MAP_ID 		= 110
	
	#--------------------------------------------------------------------------------
	# Define the default return coordinates for contests. It's set up in the
	# following way: [Lobby Map ID, x, y, facing direction] 
	# 	- Lobby Map ID: Recommend to just set to DEFAULT_LOBBY_MAP_ID
	# 	- x : the x coordinate of the Lobby Map you will return to after a contest.
	# 	- y : the y coordinate of the Lobby Map you will return to after a contest.
	# 	- facing direction: the direction to face after a contest. Directions are:
	#						2=down,4=left,6=right,8=up
	# By default, it's [DEFAULT_LOBBY_MAP_ID, 1, 2, 2]
	#--------------------------------------------------------------------------------
	DEFAULT_RETURN_COORDINATES 	= [DEFAULT_LOBBY_MAP_ID, 11, 44, DIRECTION_UP] # [Lobby Map ID, x, y, facing direction] directions: 2=down,4=left,6=right,8=up

	#--------------------------------------------------------------------------------
	# Define the return coordinates for each contest based on rank and category.
	# If you are using only one lobby for all contests, you can leave this as is as
	# it will use the DEFAULT_RETURN_COORDINATES.
	# If you will use different buildings for different categories and/or rank,
	# define coordinates here.
	# Replace nil with a coordinate array: [Lobby Map ID, x, y, facing direction] 
	# 	- Lobby Map ID: Map ID for the lobby for this category/rank
	# 	- x : the x coordinate of the Lobby Map you will return to after the contest.
	# 	- y : the y coordinate of the Lobby Map you will return to after the contest.
	# 	- facing direction: the direction to face after the contest. Directions are:
	#						2=down,4=left,6=right,8=up
	#--------------------------------------------------------------------------------
	LOBBY_MAP_COORDINATES = [
		[nil,nil,nil,nil,nil], # Normal: Cool, Beauty, Cute, Smart, Tough
		[nil,nil,nil,nil,nil], # Super: Cool, Beauty, Cute, Smart, Tough
		[nil,nil,nil,nil,nil], # Hyper: Cool, Beauty, Cute, Smart, Tough
		[nil,nil,nil,nil,nil] # Master: Cool, Beauty, Cute, Smart, Tough
	]
#====================================================================================
#============================= Contest Room Definitions =============================
#====================================================================================
	#--------------------------------------------------------------------------------
	# The following are Event IDs that represent different NPCs in a Contest Room.
	#--------------------------------------------------------------------------------
	# TRAINER_NPC_ONE_EVENT 		= 3 # Default is 1
	# TRAINER_NPC_TWO_EVENT 		= 4 # Default is 2
	# TRAINER_NPC_THREE_EVENT 	= 5 # Default is 3
#JUDGE_EVENT 				= 4 # Default is 4
#	MC_EVENT 					= 5 # Default is 5
	CROWD_EVENT_START 			= 6 # All event IDs after this number; # Default is 6
	
	#--------------------------------------------------------------------------------
	# The following is the Animation ID that represents the heart animation that
	# NPCs will show when judging a Pokemon in the Introduction Round of a contest.
	#--------------------------------------------------------------------------------
	HEART_ANIMATION_ID 			= 35
	
	#--------------------------------------------------------------------------------
	# Define the Map ID and starting coordinates for each contest room based on rank
	# and category. If you are using only one room for each individual rank, you can 
	# leave this as is as.
	# If you will use different rooms for different categories of each rank (such as
	# to make the decor colors match the category), define coordinates here.
	# Replace nil with a coordinate array: [Map ID, x, y] 
	# 	- Map ID: Map ID for the room for this category/rank
	# 	- x : the x coordinate where you will start the contest. You should usually
	#		  keep this as 12
	# 	- y : the y coordinate where you will start the contest. You should usually
	#		  keep this as 9
	#--------------------------------------------------------------------------------
	ROOM_MAP_COORDINATES = [ 
		[[110,13,21],nil,nil,nil,nil], # Normal: Cool(default), Beauty, Cute, Smart, Tough
		[[110,38,21],nil,nil,nil,nil], # Super: Cool(default), Beauty, Cute, Smart, Tough
		[[110,63,21],nil,nil,nil,nil], # Hyper: Cool(default), Beauty, Cute, Smart, Tough
		[[110,48,44],nil,nil,nil,nil] # Master: Cool(default), Beauty, Cute, Smart, Tough
	]
	
end