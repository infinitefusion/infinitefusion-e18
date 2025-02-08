
module Settings
  LATEST_GAME_RELEASE = "6.4.0"

  SHINY_POKEMON_CHANCE = 16
  DISCORD_URL = "https://discord.com/invite/infinitefusion"
  WIKI_URL = "https://infinitefusion.fandom.com/"
  STARTUP_MESSAGES = ""
  
  CREDITS_FILE_URL = "https://infinitefusion.net/Sprite Credits.csv"

  SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/CUSTOM_SPRITES"
  BASE_SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/BASE_SPRITES"


  VERSION_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/VERSION"
  CUSTOM_DEX_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/dex.json"

  # CUSTOM SPRITES
  AUTOGEN_SPRITES_REPO_URL = ""
  CUSTOM_SPRITES_REPO_URL = ""
  CUSTOM_SPRITES_NEW_URL = ""
  BASE_POKEMON_SPRITES_REPO_URL = ""
  BASE_POKEMON_ALT_SPRITES_REPO_URL = ""
  BASE_POKEMON_ALT_SPRITES_NEW_URL = ""

  BASE_POKEMON_SPRITESHEET_URL = "https://infinitefusion.net/spritesheets/spritesheets_base/"		#legacy
  CUSTOM_FUSIONS_SPRITESHEET_URL = "https://infinitefusion.net/spritesheets/spritesheets_custom/"	#legacy
  BASE_POKEMON_SPRITESHEET_RESIZED_URL = "https://infinitefusion.net/spritesheets_resized/spritesheets_base/"		#legacy
  CUSTOM_FUSIONS_SPRITESHEET_RESIZED_URL = "https://infinitefusion.net/spritesheets_resized/spritesheets_custom/"	#legacy
 
  BASE_POKEMON_SPRITESHEET_TRUE_SIZE_URL = "https://infinitefusion.net/customsprites/spritesheets/spritesheets_base/"
  CUSTOM_FUSIONS_SPRITESHEET_TRUE_SIZE_URL = "https://infinitefusion.net/customsprites/spritesheets/spritesheets_custom/"
  
  CUSTOMSPRITES_RATE_MAX_NB_REQUESTS = 5  #Nb. requests allowed in each time window
  CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  MAX_NB_SPRITES_TO_DOWNLOAD_AT_ONCE =5

  #POKEDEX ENTRIES

  AI_ENTRIES_URL = "https://infinitefusion.net/dex/"
  AI_ENTRIES_RATE_MAX_NB_REQUESTS = 10  #Nb. requests allowed in each time window
  AI_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  AI_ENTRIES_RATE_LOG_FILE = 'Data/pokedex/rate_limit.log'  # Path to the log file

  #Spritepack
  NEWEST_SPRITEPACK_MONTH = 1
  NEWEST_SPRITEPACK_YEAR = 2025


end
