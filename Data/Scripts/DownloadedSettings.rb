
module Settings
  LATEST_GAME_RELEASE = "6.8.0"

  SHINY_POKEMON_CHANCE = 16
  SNOW_DAY = false
  MEW_OW_ENCOUNTER_CHANCE = 0

  STARTUP_MESSAGES = "Pokémon Infinite Fusion 2 is now available! Download it from the game's Discord!" #Legacy starting PIF1 6.8
  STARTUP_MESSAGES_KANTO = "Pokémon Infinite Fusion 2 is now available! Download it from the game's Discord!"
  STARTUP_MESSAGES_HOENN = ""
  
  MAIN_MENU_LINKS = {
    "Discord" => "https://discord.com/invite/infinitefusion",
    "FAQ" => "https://hackmd.io/@PIF-Staff/PIF-Hoenn-FAQ/",
    "Wiki" => "https://infinitefusion.fandom.com/",
    
  }
  
  FEEDBACK_FORM_URL = "https://forms.gle/1svTMSUMf7ebHdZq7"
  DISCORD_URL = "https://discord.com/invite/infinitefusion"
  WIKI_URL = "https://infinitefusion.fandom.com/"
  
  CREDITS_FILE_URL = "https://infinitefusion.net/customsprites/Sprite_Credits.csv"

  SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/CUSTOM_SPRITES"
  BASE_SPRITES_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pif-downloadables/refs/heads/master/BASE_SPRITES"


  VERSION_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/infinitefusion-e18/main/Data/VERSION"
  CUSTOM_DEX_FILE_URL = "https://raw.githubusercontent.com/infinitefusion/pokedex-entries/main/dex.json"

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

  
  TRANSFER_BOX_DISCLAIMER_MESSAGE = ""

  CUSTOMSPRITES_RATE_MAX_NB_REQUESTS = 15  #Nb. requests allowed in each time window
  CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW = 60    # In seconds
  MAX_NB_SPRITES_TO_DOWNLOAD_AT_ONCE =5

  #POKEDEX ENTRIES

  AI_ENTRIES_URL = "https://infinitefusion.net/dex/"
  AI_ENTRIES_RATE_MAX_NB_REQUESTS = 10  #Nb. requests allowed in each time window
  AI_ENTRIES_RATE_TIME_WINDOW = 120    # In seconds
  AI_ENTRIES_RATE_LOG_FILE = 'Data/pokedex/rate_limit.log'  # Path to the log file

  #Spritepack
  NEWEST_SPRITEPACK_MONTH = 6
  NEWEST_SPRITEPACK_YEAR = 2026
end

module MysteryGift
  URL = "https://download.infinitefusion.net/mystery_gift/MysteryGiftPublic.json"
  PRIVATE_URL = "https://download.infinitefusion.net/mystery_gift/MysteryGiftsPrivate/"
end
