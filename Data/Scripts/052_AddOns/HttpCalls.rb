def test_http_get
  url = "http://localhost:8080"
  response = HTTPLite.get(url)
  if response[:status] == 200
    p response[:body]
  end
end

def updateHttpSettingsFile
  return if !downloadAllowed?()
  echoln "UPDATING SETTINGS"
  download_file(Settings::HTTP_CONFIGS_FILE_URL, Settings::HTTP_CONFIGS_FILE_PATH,)
end

def updateCreditsFile
  return if !downloadAllowed?()
  download_file(Settings::CREDITS_FILE_URL, Settings::CREDITS_FILE_PATH,)
end

def updateCustomDexFile
  return if !downloadAllowed?()
  download_file(Settings::CUSTOM_DEX_FILE_URL, Settings::CUSTOM_DEX_ENTRIES_PATH,)
end

def createCustomSpriteFolders()
  if !Dir.exist?(Settings::CUSTOM_BATTLERS_FOLDER)
    Dir.mkdir(Settings::CUSTOM_BATTLERS_FOLDER)
  end
  if !Dir.exist?(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED)
    Dir.mkdir(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED)
  end
end

def download_file(url, saveLocation)
  echoln url
  begin
    response = HTTPLite.get(url)
    if response[:status] == 200
      File.open(saveLocation, "wb") do |file|
        file.write(response[:body])
      end
      echoln _INTL("\nDownloaded file {1} to {2}", url, saveLocation)
      return saveLocation
    else
      echoln _INTL("Failed to download file {1}", url)
    end
    return nil
  rescue MKXPError, Errno::ENOENT => error
    echo error
    return nil
  end
end

#Returns:
# A file was downloaded ->true
# A file was not downloaded -> false
# #
#TODO:
# This method bypasses the client-side rate limiting
# MAKE SURE TO ALWAYS CHECK requestRateExceeded? BEFORE CALLING THIS METHOD
# #
def fetch_sprite_from_web(url, destinationPath)
  return false if !downloadAllowed?()
  begin

    response = HTTPLite.get(url)
    if response[:status] == 200
      File.open(destinationPath, "wb") do |file|
        file.write(response[:body])
      end
      echoln "Downloaded #{url} to #{destinationPath}"
      return true
    end
    echoln "Failed to download #{url}"
    return false
  rescue MKXPError => e
    echoln "MKXPError: #{e.message}"
    return false
  rescue Errno::ENOENT => e
    echoln "File Error: #{e.message}"
    return false
  rescue Exception => e
    echoln "Error: #{e.message}"
  end
end

def download_spritesheet(pif_sprite, dest)
  #return nil if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE,Settings::CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW,Settings::CUSTOMSPRITES_RATE_MAX_NB_REQUESTS)
  return nil if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE, 60, 15)
  case pif_sprite.type
  when :AUTOGEN
    return
  when :CUSTOM
    url = Settings::CUSTOM_FUSIONS_SPRITESHEET_TRUE_SIZE_URL + "#{pif_sprite.head_id}/#{pif_sprite.head_id}#{pif_sprite.alt_letter}.png"
  when :BASE
    url = Settings::BASE_POKEMON_SPRITESHEET_TRUE_SIZE_URL + "#{pif_sprite.head_id}.png"
  end
  folder = File.dirname(dest)
  ensure_folder_exists(folder)

  fetchedFromWeb = fetch_sprite_from_web(url, dest)
  return fetchedFromWeb
end

def ensure_folder_exists(folder)
  # Recursively create directories if they don't exist
  unless Dir.exist?(folder)
    parent = File.dirname(folder)
    ensure_folder_exists(parent) unless Dir.exist?(parent)
    Dir.mkdir(folder)
  end
end

#Returns: The local path of the downloaded sprite
# def download_sprite(base_path, head_id, body_id, saveLocation = "Graphics/temp", alt_letter = "")
#   return nil if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE,Settings::CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW,Settings::CUSTOMSPRITES_RATE_MAX_NB_REQUESTS)
#   filename = "#{head_id}.#{body_id}#{alt_letter}.png"
#   filename = "#{head_id}#{alt_letter}.png" if !body_id #unfused
#
#   #check if it's in the Custom sprites list if it's a fusion
#   if head_id && body_id
#     return nil if !custom_exists(filename)
#   end
#
#   begin
#     head_id = head_id.to_s
#     body_id = body_id.to_s
#
#     downloaded_file_name = _INTL("{1}/{2}.{3}{4}.png", saveLocation, head_id, body_id, alt_letter)
#     if !body_id || body_id == ""
#       downloaded_file_name = _INTL("{1}{2}{3}.png", saveLocation, head_id, alt_letter)
#     end
#
#     return downloaded_file_name if pbResolveBitmap(downloaded_file_name)
#
#     url = _INTL(base_path, head_id, body_id)
#     if !body_id
#       url = _INTL(base_path, head_id)
#     end
#     if fetch_sprite_from_web(url,downloaded_file_name)
#       return downloaded_file_name
#     end
#     return nil
#   rescue MKXPError => e
#     echoln "MKXPError: #{e.message}"
#     return nil
#   rescue Errno::ENOENT => e
#     echoln "File Error: #{e.message}"
#     return nil
#   end
# end

def custom_exists(target_file)
  file_path = Settings::CUSTOM_SPRITES_FILE_PATH

  # Read the file and store its lines in an array, removing newlines
  file_list = File.readlines(file_path, chomp: true)
  # Perform binary search
  low = 0
  high = file_list.length - 1
  while low <= high
    mid = (low + high) / 2
    case file_list[mid] <=> target_file
    when 0
      return true # Found the target file
    when -1
      low = mid + 1 # Target is in the upper half
    when 1
      high = mid - 1 # Target is in the lower half
    end
  end
  return false # Target file not found
end

#
# Autogens are no longer downloaded from the web. Instead, the game comes with spritesheets, from which
# it extracts the sprites and puts them in individual files (for faster loading)
#
def download_autogen_sprite(head_id, body_id)
  #return nil if !downloadAllowed?()
  #template_url = Settings::AUTOGEN_SPRITES_REPO_URL + "{1}/{1}.{2}.png"

  destPath = _INTL("{1}{2}", Settings::BATTLERS_FOLDER, head_id)

  autogenExtracter = AutogenExtracter.new
  return autogenExtracter.extract_bitmap_to_file(PIFSprite.new(:AUTOGEN, head_id, body_id), destPath)

  # url = _INTL(template_url, head_id, body_id)
  # sprite = download_sprite(url, head_id, body_id, destPath)
  # return sprite if sprite
  # return nil
end

def download_custom_sprite(head_id, body_id, alt_letter = "")
  return nil unless downloadAllowed?()
  #url = getDownloadableCustomSpritesUrl() + "{1}.{2}{3}.png"
  destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
  spriteExtracter = CustomSpriteExtracter.new
  sprite_path = spriteExtracter.extract_bitmap_to_file(head_id, body_id, alt_letter, destPath)
  echoln sprite_path
  return sprite_path

  # if !Dir.exist?(destPath)
  #   Dir.mkdir(destPath)
  # end
  # sprite = download_sprite(_INTL(url, head_id, body_id,alt_letter), head_id, body_id, destPath, alt_letter)
  # return sprite if sprite
  # return nil
end

# def download_custom_sprite(head_id, body_id, spriteformBody_suffix = "", spriteformHead_suffix = "", alt_letter="")
#   head_id = (head_id.to_s) + spriteformHead_suffix.to_s
#   body_id = (body_id.to_s) + spriteformBody_suffix.to_s
#   return nil if !downloadAllowed?()
#   url = getDownloadableCustomSpritesUrl() + "{1}.{2}{3}.png"
#   destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
#   if !Dir.exist?(destPath)
#     Dir.mkdir(destPath)
#   end
#   sprite = download_sprite(_INTL(url, head_id, body_id,alt_letter), head_id, body_id, destPath, alt_letter)
#   return sprite if sprite
#   return nil
# end

# def download_custom_sprite_filename(filename)
#   head_id = (head_id.to_s) + spriteformHead_suffix.to_s
#   body_id = (body_id.to_s) + spriteformBody_suffix.to_s
#   return nil if !downloadAllowed?()
#   url = getDownloadableCustomSpritesUrl() + "{1}.{2}{3}.png"
#   destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
#   if !Dir.exist?(destPath)
#     Dir.mkdir(destPath)
#   end
#   sprite = download_sprite(_INTL(url, head_id, body_id,alt_letter), head_id, body_id, destPath, alt_letter)
#   return sprite if sprite
#   return nil
# end

# #todo refactor & put custom base sprites in same folder as fusion sprites
# def download_unfused_main_sprite(dex_num, alt_letter="")
#   base_url = alt_letter == "" ? Settings::BASE_POKEMON_SPRITES_REPO_URL : getDownloadableBaseSpritesUrl()
#   filename = _INTL("{1}{2}.png",dex_num,alt_letter)
#   url = base_url + filename
#
#   echoln url
#   destPath =  Settings::CUSTOM_BASE_SPRITES_FOLDER
#   sprite = download_sprite(url, dex_num, nil, destPath,alt_letter)
#
#   return sprite if sprite
#   return nil
# end

# def download_all_unfused_alt_sprites(dex_num)
#   base_url = getDownloadableBaseSpritesUrl() + "{1}"
#   extension = ".png"
#   destPath = _INTL("{1}", Settings::CUSTOM_BASE_SPRITES_FOLDER)
#   if !Dir.exist?(destPath)
#     Dir.mkdir(destPath)
#   end
#   alt_url = _INTL(base_url, dex_num) + extension
#   download_sprite(alt_url, dex_num, nil, destPath)
#   alphabet = ('a'..'z').to_a + ('aa'..'az').to_a
#   alphabet.each do |letter|
#     alt_url = _INTL(base_url, dex_num) + letter + extension
#     sprite = download_sprite(alt_url, dex_num, nil, destPath, letter)
#     return if !sprite
#   end
# end

# def download_all_unfused_alt_sprites(dex_num)
#   template_url = getDownloadableBaseSpritesUrl()
#   baseUrl = _INTL(template_url,dex_num)
#   destDirectory = _INTL("{1}", Settings::CUSTOM_BASE_SPRITES_FOLDER)
#     if !Dir.exist?(destDirectory)
#       Dir.mkdir(destDirectory)
#     end
#     sprites_alt_map = map_alt_sprite_letters_for_pokemon(dex_num.to_s)
#     # Sorting the sprite keys by their status in order of priority: "main", "temp", "alt"
#     sprite_letters_to_download = sprites_alt_map.keys.sort_by do |key|
#       case sprites_alt_map[key]
#       when "main" then 0
#       when "temp" then 1
#       when "alt" then 2
#       else 3 # Catch-all for any undefined statuses, if any
#       end
#     end
#
#     nb_sprites_downloaded = 0
#     sprites_processed=0
#
#   sprite_letters_to_download.each do |letter|
#     sprites_processed+=1
#     echoln sprites_processed
#     echoln nb_sprites_downloaded
#
#     break if nb_sprites_downloaded > Settings::MAX_NB_SPRITES_TO_DOWNLOAD_AT_ONCE
#
#       filename = "#{dex_num}#{letter}.png"
#       url = baseUrl  + filename
#       destPath = destDirectory + "/" + filename
#       next if pbResolveBitmap(destPath)
#       downloaded_new_sprite= fetch_sprite_from_web(url,destPath)
#       if downloaded_new_sprite
#         nb_sprites_downloaded += 1
#         break if requestRateExceeded?(Settings::CUSTOMSPRITES_RATE_LOG_FILE,Settings::CUSTOMSPRITES_ENTRIES_RATE_TIME_WINDOW,Settings::CUSTOMSPRITES_RATE_MAX_NB_REQUESTS)
#       end
#
#     end
#   end

# def download_all_alt_sprites(head_id, body_id)
#   base_url = "#{getDownloadableCustomSpritesUrl()}{1}.{2}"
#   extension = ".png"
#   destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
#   if !Dir.exist?(destPath)
#     Dir.mkdir(destPath)
#   end
#   sprite_letters_to_download = list_all_sprites_letters_head_body(head_id,body_id)
#   sprite_letters_to_download.each do |letter|
#     alt_url = base_url + letter + extension
#     download_sprite(alt_url, head_id, body_id, destPath, letter)
#   end
# end

#format: [1.1.png, 1.2.png, etc.]
# https://api.github.com/repos/infinitefusion/contents/sprites/CustomBattlers
#   repo = "Aegide/custom-fusion-sprites"
#   folder = "CustomBattlers"
#

# def fetch_online_custom_sprites
#   page_start =1
#   page_end =2
#
#   repo = "infinitefusion/sprites"
#   folder = "CustomBattlers"
#   api_url = "https://api.github.com/repos/#{repo}/contents/#{folder}"
#
#   files = []
#   page = page_start
#
#   File.open(Settings::CUSTOM_SPRITES_FILE_PATH, "wb") do |csv|
#     loop do
#       break if page > page_end
#       response = HTTPLite.get(api_url, {'page' => page.to_s})
#       response_files = HTTPLite::JSON.parse(response[:body])
#       break if response_files.empty?
#       response_files.each do |file|
#         csv << [file['name']].to_s
#         csv << "\n"
#       end
#       page += 1
#     end
#   end
#
#
#   write_custom_sprites_csv(files)
# end

# Too many file to get everything without getting
# rate limited by github, so instead we're getting the
# files list from a  csv file that will be manually updated
# with each new spritepack

def updateOnlineCustomSpritesFile
  return if !downloadAllowed?()
  echoln "UPDATING CUSTOM SPRITE LISTS"
  download_file(Settings::SPRITES_FILE_URL, Settings::CUSTOM_SPRITES_FILE_PATH)
  download_file(Settings::BASE_SPRITES_FILE_URL, Settings::BASE_SPRITES_FILE_PATH)
end

def list_online_custom_sprites(updateList = false)
  sprites_list = []
  File.foreach(Settings::CUSTOM_SPRITES_FILE_PATH) do |line|
    sprites_list << line
  end
  return sprites_list
end

GAME_VERSION_FORMAT_REGEX = /\A\d+(\.\d+)*\z/

def fetch_latest_game_version
  begin
    # download_file(Settings::VERSION_FILE_URL, Settings::VERSION_FILE_PATH)
    # version_file = File.open(Settings::VERSION_FILE_PATH, "r")
    # version = version_file.first
    # version_file.close
    version = Settings::LATEST_GAME_RELEASE

    version_format_valid = version.match(GAME_VERSION_FORMAT_REGEX)

    return version if version_format_valid
    return nil
  rescue MKXPError, Errno::ENOENT => error
    echo error
    return nil
  end

end

# update_log_file: keep to true when trying to make an actual request
# set to false if just checking
def requestRateExceeded?(logFile, timeWindow, maxRequests, update_log_file = true)
  # Read or initialize the request log
  if File.exist?(logFile)
    log_data = File.read(logFile).split("\n")
    request_timestamps = log_data.map(&:to_i)
  else
    request_timestamps = []
  end

  current_time = Time.now.to_i

  # Remove old timestamps that are outside the time window
  request_timestamps.reject! { |timestamp| (current_time - timestamp) > timeWindow }

  # Update the log with the current request
  request_timestamps << current_time

  # Write the updated log back to the file
  if update_log_file
    File.write(logFile, request_timestamps.join("\n"))
    echoln "Rate limiting: Current: #{request_timestamps.size}, Max: #{maxRequests}"
  end
  rateLimitExceeded = request_timestamps.size > maxRequests
  return rateLimitExceeded
end

# def getDownloadableCustomSpritesUrl()
#   if Settings::USE_NEW_URL_FOR_CUSTOM_SPRITES
#     return Settings::CUSTOM_SPRITES_NEW_URL
#   end
#   return Settings::CUSTOM_SPRITES_REPO_URL
# end

# def getDownloadableBaseSpritesUrl()
#   if Settings::USE_NEW_URL_FOR_BASE_SPRITES
#     return Settings::BASE_POKEMON_ALT_SPRITES_NEW_URL
#   end
#   return Settings::BASE_POKEMON_ALT_SPRITES_REPO_URL
# end