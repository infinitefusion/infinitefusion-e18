# Auto Multi Save by http404error
# For Pokemon Essentials v19.1


# Description:
#   Adds multiple save slots and the abliity to auto-save.
#   Included is code to autosave every 30 overworld steps. Feel free to edit or delete it (it's right at the top).
#   On the Load screen you can use the left and right buttons while "Continue" is selected to cycle through files.
#   When saving, you can quickly save to the same slot you loaded from, or pick another slot.
#   Battle Challenges are NOT supported.

# Customization:
#   I recommend altering your pause menu to quit to the title screen or load screen instead of exiting entirely.
#     -> For instance, just change the menu text to "Quit to Title" and change `$scene = nil` to `$scene = pbCallTitle`.
#   Call Game.auto_save whenever you want.
#     -> Autosaving during an event script will correctly resume event execution when you load the game.
#     -> I haven't investigated if it might be possible to autosave on closing the window with the X or Alt-F4 yet.
#   You can rename the slots to your liking, or change how many there are.
#   In some cases, you might want to remove the option to save to a different slot than the one you loaded from.

# Notes:
#   On the first Load, the old Game.rxdata will be copied to the first slot in MANUAL_SLOTS. It won't have a known save time though.
#   The interface to `Game.save` has been changed.
#   Due to the slots, alters the save backup system in the case of save corruption/crashes - backups will be named Backup000.rxdata and so on.
#   Heavily modifies the SaveData module and Save and Load screens. This may cause incompatibility with some other plugins or custom game code.
#   Not everything here has been tested extensively, only what applies to normal usage of my game. Please let me know if you run into any problems.

# Future development ideas:
#   There isn't currently support for unlimited slots but it wouldn't be too hard.
#   Letting the user name their slots seems cool.
#   It would be nice if there was a sliding animation for switching files on that load screen. :)
#   It would be nice if the file select arrows used nicer animated graphics, kind of like the Bag.
#   Maybe auto-save slots should act like a queue instead of cycling around.

# Autosave every 30 steps
# Events.onStepTaken += proc {
#   $Trainer.autosave_steps = 0 if !$Trainer.autosave_steps
#   $Trainer.autosave_steps += 1
#   if $Trainer.autosave_steps >= 30
#     echo("Autosaving...")
#     $Trainer.autosave_steps = 0
#     Game.auto_save
#     echoln("done.")
#   end
# }

class PokemonSystem
  attr_accessor :current_game_version
end

def onLoadExistingGame()
  migrateOldSavesToCharacterCustomization()
  clear_all_images()
  loadDateSpecificChanges()
  checkGameVersionUpdate()
  $PokemonSystem.overworld_encounters = false if Settings::KANTO
end

def checkGameVersionUpdate
  if $PokemonSystem.current_game_version != Settings::GAME_VERSION_NUMBER
    echoln "invalidating cache!"
    invalidate_sprite_cache
    $PokemonSystem.current_game_version = Settings::GAME_VERSION_NUMBER
  end
end

def invalidate_sprite_cache
  spritesLoader = BattleSpriteLoader.new
  spritesLoader.clear_sprites_cache(:CUSTOM)
  spritesLoader.clear_sprites_cache(:BASE)
end

def loadDateSpecificChanges()
  current_date = Time.new
  if (current_date.day == 1 && current_date.month == 4)
    $Trainer.hat2=HAT_CLOWN if $Trainer.unlocked_hats.include?(HAT_CLOWN)
  end
end

def onStartingNewGame()
  set_starting_options
end

def set_starting_options
  if Settings::HOENN
    $PokemonSystem.overworld_encounters= true
    $PokemonSystem.use_generated_dex_entries=true
    $PokemonGlobal.runningShoes=true
  end
  if $PokemonSystem.obtained_transfer_box
    addPokemonStorageTransferBox
  end

end

def migrateOldSavesToCharacterCustomization()
  if !$Trainer.unlocked_clothes
    $Trainer.unlocked_clothes = [DEFAULT_OUTFIT_MALE,
                                 DEFAULT_OUTFIT_FEMALE,
                                 STARTING_OUTFIT]
  end
  if !$Trainer.unlocked_hats
    $Trainer.unlocked_hats = [DEFAULT_OUTFIT_MALE, DEFAULT_OUTFIT_FEMALE]
  end
  if !$Trainer.unlocked_hairstyles
    $Trainer.unlocked_hairstyles = [DEFAULT_OUTFIT_MALE, DEFAULT_OUTFIT_FEMALE]
  end

  if !$Trainer.clothes || !$Trainer.hair #|| !$Trainer.hat
    setupStartingOutfit()
  end
end

#===============================================================================
#
#===============================================================================
module SaveData
  # You can rename these slots or change the amount of them
  # They change the actual save file names though, so it would take some extra work to use the translation system on them.
  AUTO_SLOTS = [
    'Auto 1',
    'Auto 2'
  ]
  MANUAL_SLOTS = [
    'File A',
    'File B',
    'File C',
    'File D',
    'File E',
    'File F',
    'File G',
    'File H'
  ]

  # For compatibility with games saved without this plugin
  OLD_SAVE_SLOT = 'Game'

  SAVE_DIR = if File.directory?(System.data_directory)
               System.data_directory
             else
               '.'
             end

  def self.each_slot
    (AUTO_SLOTS + MANUAL_SLOTS).each { |f| yield f }
  end

  def self.get_full_path(file)
    return "#{SAVE_DIR}/#{file}.rxdata"
  end

  def self.get_backup_file_path
    backup_file = "Backup000"
    while File.file?(self.get_full_path(backup_file))
      backup_file.next!
    end
    return self.get_full_path(backup_file)
  end

  # Given a list of save file names and a file name in it, return the next file after it which exists
  # If no other file exists, will just return the same file again
  def self.get_next_slot(file_list, file)
    old_index = file_list.find_index(file)
    ordered_list = file_list.rotate(old_index + 1)
    ordered_list.each do |f|
      return f if File.file?(self.get_full_path(f))
    end
    # should never reach here since the original file should always exist
    return file
  end

  # See self.get_next_slot
  def self.get_prev_slot(file_list, file)
    return self.get_next_slot(file_list.reverse, file)
  end

  # Returns nil if there are no saves
  # Returns the first save if there's a tie for newest
  # Old saves from previous version don't store their saved time, so are treated as very old
  def self.get_newest_save_slot
    newest_time = Time.at(0) # the Epoch
    newest_slot = nil
    self.each_slot do |file_slot|
      full_path = self.get_full_path(file_slot)
      next if !File.file?(full_path)
      begin
        temp_save_data = self.read_from_file(full_path)
      rescue
        next
      end

      save_time = temp_save_data[:player].last_time_saved || Time.at(1)
      if save_time > newest_time
        newest_time = save_time
        newest_slot = file_slot
      end
    end
    # Port old save
    if newest_slot.nil? && File.file?(self.get_full_path(OLD_SAVE_SLOT))
      file_copy(self.get_full_path(OLD_SAVE_SLOT), self.get_full_path(MANUAL_SLOTS[0]))
      return MANUAL_SLOTS[0]
    end
    return newest_slot
  end

  # @return [Boolean] whether any save file exists
  def self.exists?
    self.each_slot do |slot|
      full_path = SaveData.get_full_path(slot)
      return true if File.file?(full_path)
    end
    return false
  end

  # This is used in a hidden function (ctrl+down+cancel on title screen) or if the save file is corrupt
  # Pass nil to delete everything, or a file path to just delete that one
  # @raise [Error::ENOENT]
  def self.delete_file(file_path = nil)
    if file_path
      File.delete(file_path) if File.file?(file_path)
    else
      self.each_slot do |slot|
        full_path = self.get_full_path(slot)
        File.delete(full_path) if File.file?(full_path)
      end
    end
  end

  # Moves a save file from the old Saved Games folder to the new
  # location specified by {MANUAL_SLOTS[0]}. Does nothing if a save file
  # already exists in {MANUAL_SLOTS[0]}.
  def self.move_old_windows_save
    return if self.exists?
    game_title = System.game_title.gsub(/[^\w ]/, '_')
    home = ENV['HOME'] || ENV['HOMEPATH']
    return if home.nil?
    old_location = File.join(home, 'Saved Games', game_title)
    return unless File.directory?(old_location)
    old_file = File.join(old_location, 'Game.rxdata')
    return unless File.file?(old_file)
    File.move(old_file, MANUAL_SLOTS[0])
  end

  # Runs all possible conversions on the given save data.
  # Saves a backup before running conversions.
  # @param save_data [Hash] save data to run conversions on
  # @return [Boolean] whether conversions were run
  def self.run_conversions(save_data)
    validate save_data => Hash
    conversions_to_run = self.get_conversions(save_data)
    return false if conversions_to_run.none?
    File.open(SaveData.get_backup_file_path, 'wb') { |f| Marshal.dump(save_data, f) }
    echoln "Backed up save to #{SaveData.get_backup_file_path}"
    echoln "Running #{conversions_to_run.length} conversions..."
    conversions_to_run.each do |conversion|
      echo "#{conversion.title}..."
      conversion.run(save_data)
      echoln ' done.'
    end
    echoln '' if conversions_to_run.length > 0
    save_data[:essentials_version] = Essentials::VERSION
    save_data[:game_version] = Settings::GAME_VERSION_NUMBER
    return true
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene


  def pbChoose(commands, continue_idx)
    @sprites["cmdwindow"].commands = commands
    @language_option_selected = false unless defined?(@language_option_selected)
    loop do
      Graphics.update
      Input.update

      if @language_option_selected
        result = pbUpdateLanguageOption(continue_idx, commands)
        return result if result
        next
      end

      if @sprites["cmdwindow"].index == continue_idx && Input.trigger?(Input::UP) && @show_language_option
        pbPlayCursorSE
        pbEnterLanguageOption(continue_idx)
        next
      end
      pbUpdate
      if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
      elsif @sprites["cmdwindow"].index == continue_idx
        @sprites["leftarrow"].visible = true
        @sprites["rightarrow"].visible = true
        if Input.trigger?(Input::LEFT)
          return -3
        elsif Input.trigger?(Input::RIGHT)
          return -2
        end
      else
        @sprites["leftarrow"].visible = false
        @sprites["rightarrow"].visible = false
      end
    end
  end

  # Called when the player presses UP while on Continue, to enter language-icon mode.
  def pbEnterLanguageOption(continue_idx)
    @language_option_selected = true
    @sprites["cmdwindow"].active = false
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"].visible = false
    @sprites["panel#{continue_idx}"].selected = false if @sprites["panel#{continue_idx}"]
    @sprites["panel#{continue_idx}"].pbRefresh if @sprites["panel#{continue_idx}"]
    pbUpdate
  end

  # Handles input while language-icon mode is active.
  # Returns -4 if the player confirmed (caller should return this from pbChoose).
  # Returns nil otherwise (caller should just `next` the loop).
  def pbUpdateLanguageOption(continue_idx, commands)
    @sprites["langicon"].bitmap = Bitmap.new(ICON_LANGUAGE_SELECTED) rescue nil

    if Input.trigger?(Input::DOWN)
      pbPlayCursorSE
      @language_option_selected = false
      @sprites["langicon"].bitmap = Bitmap.new(ICON_LANGUAGE) rescue nil
      @sprites["cmdwindow"].active = true
      @sprites["panel#{continue_idx}"].selected = true if @sprites["panel#{continue_idx}"]
      @sprites["panel#{continue_idx}"].pbRefresh if @sprites["panel#{continue_idx}"]
      return nil
    elsif Input.trigger?(Input::UP)
      pbPlayCursorSE
      @language_option_selected = false
      @sprites["langicon"].bitmap = Bitmap.new(ICON_LANGUAGE) rescue nil
      last_index = commands.length - 1
      oldi = @sprites["cmdwindow"].index
      @sprites["cmdwindow"].index = last_index
      @sprites["cmdwindow"].active = true
      pbSelectPanel(oldi, last_index)
      return nil
    elsif Input.trigger?(Input::USE)
      @language_option_selected = false
      return -4
    end

    pbUpdate
    return nil
  end

  ICON_LANGUAGE = "Graphics/Icons/mainMenu/LANGUAGE"
  ICON_LANGUAGE_SELECTED = "Graphics/Icons/mainMenu/LANGUAGE_sel"

  def pbStartScene(commands, show_continue, trainer, frame_count, map_id)

    @commands = commands
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)

    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = 10
    @sprites["leftarrow"].y = 140
    @sprites["leftarrow"].play

    #@sprites["leftarrow"].visible=true

    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = 460
    @sprites["rightarrow"].y = 140
    @sprites["rightarrow"].play
    #@sprites["rightarrow"].visible=true

    y = 16 * 2
    for i in 0...commands.length
      @sprites["panel#{i}"] = PokemonLoadPanel.new(i, commands[i],
                                                   (show_continue) ? (i == 0) : false, trainer, frame_count, map_id, @viewport)
      @sprites["panel#{i}"].x = 24 * 2
      @sprites["panel#{i}"].y = y
      @sprites["panel#{i}"].pbRefresh
      y += (show_continue && i == 0) ? 112 * 2 : 24 * 2
    end
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible = false


    @show_language_option =  Settings::LANGUAGES[Settings::GAME_ID].length >= 2
    @language_option_selected= false
    if @show_language_option
      @sprites["langicon"] = Sprite.new(@viewport)
      @sprites["langicon"].bitmap = Bitmap.new(ICON_LANGUAGE)
      @sprites["langicon"].x=12
      @sprites["langicon"].y = 4
    end
  end

end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    @selected_file = SaveData.get_newest_save_slot
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    begin
      save_data = SaveData.read_from_file(file_path)
    rescue
      save_data = try_load_backup(file_path)
    end
    unless SaveData.valid?(save_data)
      save_data = try_load_backup(file_path)
    end
    return save_data
  end

  def try_load_backup(file_path)
    file_name = File.basename(file_path, ".rxdata")   # e.g. "File A"
    save_folder = File.dirname(file_path)
    backup_dir = File.join(save_folder, "backups", file_name)

    echoln file_path
    unless Dir.exist?(backup_dir)
      self.prompt_save_deletion(file_path)
      return {}
    end

    backups = Dir.children(backup_dir).select { |f|
      f.start_with?(file_name + "_") && f.end_with?(".rxdata")
    }

    echoln backups
    echoln file_name + "_"

    if backups.empty?
      self.prompt_save_deletion(file_path)
      return {}
    end

    # Sort by numeric timestamp
    backups.sort_by! do |fname|
      timestamp = fname.sub(/^#{Regexp.escape(file_name)}_/, "").sub(/\.rxdata$/, "")
      timestamp.to_i
    end

    latest = backups.last
    timestamp_str = latest.sub(/^#{Regexp.escape(file_name)}_/, "").sub(/\.rxdata$/, "")

    # Convert numeric timestamp to readable date (custom formatting)
    if timestamp_str.length >= 12
      year   = timestamp_str[0,4]
      month  = timestamp_str[4,2]
      day    = timestamp_str[6,2]
      hour   = timestamp_str[8,2]
      minute = timestamp_str[10,2]
      formatted_time = "#{year}-#{month}-#{day} #{hour}:#{minute}"
    else
      formatted_time = timestamp_str
    end

    pbMessage(_INTL(
                "The save file is corrupt. The most recent backup will be loaded instead.\n" +
                  "\\C[2]{1}\\C[0]\nBackup date: \\C[3]{2}",
                latest, formatted_time
              ))

    latest_backup = File.join(backup_dir, latest)
    return load_save_file(latest_backup)
  end


  def formatSaveDate(str)
    year   = str[0,4]
    month  = str[4,2]
    day    = str[6,2]
    hour   = str[8,2]
    minute = str[10,2]
    return "#{year}-#{month}-#{day} #{hour}:#{minute}"
  end


  # Called if save file is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion(file_path)
    pbMessage(_INTL("A save file is corrupt, or is incompatible with this game."))
    self.delete_save_data(file_path) if pbConfirmMessageSerious(
      _INTL("No backup was found. Do you want to delete that save file? The game will exit afterwards either way.")
    )
    exit
  end

  # nil deletes all, otherwise just the given file
  def delete_save_data(file_path = nil)
    begin
      SaveData.delete_file(file_path)
      pbMessage(_INTL("The save data was deleted."))
    rescue SystemCallError
      pbMessage(_INTL("The save data could not be deleted."))
    end
  end



  #So that the options menu is set on the correct difficulty on older saves
  def ensureCorrectDifficulty()
    $Trainer.selected_difficulty = 1 #normal
    $Trainer.selected_difficulty = 0 if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
    $Trainer.selected_difficulty = 2 if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    $Trainer.lowest_difficulty = $Trainer.selected_difficulty if !$Trainer.lowest_difficulty
  end

  def setGameMode()
    $Trainer.game_mode = 0 #classic
    $Trainer.game_mode = 2 if $game_switches[SWITCH_MODERN_MODE]
    $Trainer.game_mode = 3 if $game_switches[SWITCH_EXPERT_MODE]
    $Trainer.game_mode = 4 if $game_switches[SWITCH_SINGLE_POKEMON_MODE]
    $Trainer.game_mode = 1 if $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE]
    $Trainer.game_mode = 5 if $game_switches[ENABLED_DEBUG_MODE_AT_LEAST_ONCE]
  end



  def pbStartLoadScreen
    updateHttpSettingsFile
    updateCustomDexFile
    newer_version = find_newer_available_version
    if newer_version
      pbMessage(_INTL("Version {1} is now available! Please use the game's installer to download the newest version. Check the Discord for more information.", newer_version))
    end

    if Settings::STARTUP_MESSAGES_KANTO != "" && Settings::KANTO
      pbMessage(_INTL(Settings::STARTUP_MESSAGES_KANTO))
    end
    if Settings::STARTUP_MESSAGES_HOENN != "" && Settings::HOENN
      pbMessage(_INTL(Settings::STARTUP_MESSAGES_HOENN))
    end

    if ($game_temp.unimportedSprites && $game_temp.unimportedSprites.size > 0)
      handleReplaceExistingSprites()
    end
    if ($game_temp.nb_imported_sprites && $game_temp.nb_imported_sprites > 0)
      pbMessage(_INTL("{1} new custom sprites were imported into the game", $game_temp.nb_imported_sprites.to_s))
    end
    checkEnableSpritesDownload

    $game_temp.nb_imported_sprites = nil
    copyKeybindings()
    save_file_list = SaveData::AUTO_SLOTS + SaveData::MANUAL_SLOTS
    first_time = true
    loop do
      # Outer loop is used for switching save files
      if @selected_file
        @save_data = load_save_file(SaveData.get_full_path(@selected_file))
      else
        @save_data = {}
      end
      commands = []
      cmd_continue = -1
      cmd_new_game = -1
      cmd_options = -1
      cmd_language = -1
      cmd_mystery_gift = -1
      cmd_debug = -1
      cmd_savefile = -1
      cmd_quit = -1
      cmd_lang_icon = -4
      show_continue = !@save_data.empty?
      new_game_plus = show_continue && (@save_data[:player].new_game_plus_unlocked || $DEBUG)

      if show_continue
        commands[cmd_continue = commands.length] = "#{@selected_file}"
        #if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
        #end
      end

      commands[cmd_new_game = commands.length] = _INTL("New Game")
      if new_game_plus
        commands[cmd_new_game_plus = commands.length] = _INTL("New Game +")
      end
      commands[cmd_options = commands.length] = _INTL("Options")
      #commands[cmd_language = commands.length] = _INTL("Language") if Settings::LANGUAGES[Settings::GAME_ID].length >= 2

      cmd_links = {}

      # if Settings::HOENN && new_game_plus && !Settings::FEEDBACK_FORM_URL.empty?
      #   cmd_links[commands.length] = Settings::FEEDBACK_FORM_URL
      #   commands[commands.length] = _INTL("Game Feedback Form")
      # end

      Settings::MAIN_MENU_LINKS.each do |key, value|
        cmd_links[commands.length] = value
        commands[commands.length] = _INTL(key)
      end

      # commands[cmd_discord = commands.length] = _INTL("Discord")
      # commands[cmd_wiki = commands.length] = _INTL("Wiki")
      commands[cmd_savefile = commands.length] = _INTL("Savefile management") if show_continue
      commands[cmd_debug = commands.length] = _INTL("Debug") if $DEBUG
      commands[cmd_quit = commands.length] = _INTL("Quit Game")
      cmd_left = -3
      cmd_right = -2

      map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
      @scene.pbStartScene(commands, show_continue, @save_data[:player],
                          @save_data[:frame_count] || 0, map_id)
      @scene.pbSetParty(@save_data[:player]) if show_continue
      if first_time
        @scene.pbStartScene2
        pbBGMPlay("pokemon_go_map") if Settings::HOENN
        first_time = false
      else
        @scene.pbUpdate
      end
      loop do
        # Inner loop is used for going to other menus and back and stuff (vanilla)
        command = @scene.pbChoose(commands, cmd_continue)
        pbPlayDecisionSE if command != cmd_quit

        case command
        when cmd_continue
          @scene.pbEndScene
          Game.load(@save_data)
          $game_switches[SWITCH_V5_1] = true
          check_for_spritepack_update()
          ensureCorrectDifficulty()
          setGameMode()
          initialize_alt_sprite_substitutions()
          $PokemonGlobal.autogen_sprites_cache = {}
          preload_party(@save_data[:player])
          return
        when cmd_new_game
          @scene.pbEndScene
          Game.start_new(new_game_plus)
          initialize_alt_sprite_substitutions()
          @save_data[:player].new_game_plus_unlocked=new_game_plus if @save_data[:player]
          return
        when cmd_new_game_plus
          @scene.pbEndScene
          Game.start_new(true,@save_data[:bag], @save_data[:storage_system], @save_data[:player])
          initialize_alt_sprite_substitutions()
          @save_data[:player].new_game_plus_unlocked = true
          return
        when cmd_mystery_gift
          pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
        when cmd_options
          pbFadeOutIn do
            scene = PokemonGameOption_Scene.new
            screen = PokemonOptionScreen.new(scene)
            screen.pbStartScreen(true)
          end
        when cmd_lang_icon
          @scene.pbEndScene
          $PokemonSystem.language = pbChooseLanguage
          MessageConfig.pbResetSystemFontName
          pbLoadMessages('Data/' + Settings::LANGUAGES[Settings::GAME_ID][$PokemonSystem.language][1])
          if show_continue
            @save_data[:pokemon_system] = $PokemonSystem
            File.open(SaveData.get_full_path(@selected_file), 'wb') { |file| Marshal.dump(@save_data, file) }
          end
          $scene = pbCallTitle
          return
        when cmd_savefile
          save_data_to_load = savefileOptions(SaveData.get_full_path(@selected_file))
          if save_data_to_load
            @scene.pbEndScene
            Game.load(save_data_to_load)
            return
          end
        when cmd_debug
          pbFadeOutIn { pbDebugMenu(false) }
        when cmd_quit
          pbPlayCloseMenuSE
          @scene.pbEndScene
          $scene = nil
          return
        when cmd_left
          @scene.pbCloseScene
          @selected_file = SaveData.get_prev_slot(save_file_list, @selected_file)
          break # to outer loop
        when cmd_right
          @scene.pbCloseScene
          @selected_file = SaveData.get_next_slot(save_file_list, @selected_file)
          break # to outer loop
        else
          if cmd_links.key?(command)
            openUrlInBrowser(cmd_links[command])
          else
            pbPlayBuzzerSE
          end
        end
      end
    end
  end

  def savefileOptions(selected_file)
    cmd_cancel = _INTL("Cancel")
    cmd_loadBackup = _INTL("Load an older backup")
    cmd_delete = _INTL("Delete this savefile")
    commands = [cmd_cancel, cmd_loadBackup, cmd_delete]
    choice = optionsMenu(commands,0)
    case commands[choice]
    when cmd_loadBackup
      echoln selected_file
      return load_specific_backup(selected_file)
    when cmd_delete
      delete_savefile_menu(selected_file)
      return nil
    end
  end

  def delete_savefile_menu(selected_file)
    file_name=  File.basename(selected_file)
    pbMessage(_INTL("\\C[2]WARNING: You are trying to delete {1}.",file_name))
    if pbConfirmMessageSerious(_INTL("\\C[2]This operation cannot be undone. Do you still wish to continue?"))
      confirm_text = pbEnterText(_INTL("Type DELETE to continue."),0,10)
      if confirm_text == "DELETE"
        self.delete_save_data(selected_file)
        pbMessage(_INTL("The game will now close automatically."))
        exit
      else
        pbMessage(_INTL("The savefile was NOT deleted."))
      end
    end
  end

  def load_specific_backup(file_path)
    file_name = File.basename(file_path, ".rxdata")
    save_folder = File.dirname(file_path)
    backup_dir = File.join(save_folder, "backups", file_name)

    unless Dir.exist?(backup_dir)
      pbMessage(_INTL("No backup folder found for this save file."))
      return nil
    end

    backups = Dir.children(backup_dir).select { |f|
      f.start_with?(file_name + "_") && f.end_with?(".rxdata")
    }

    if backups.empty?
      pbMessage(_INTL("No backups found for this save file."))
      return nil
    end

    # Sort by timestamp, newest first
    backups.sort_by! do |fname|
      timestamp = fname.sub(/^#{Regexp.escape(file_name)}_/, "").sub(/\.rxdata$/, "")
      timestamp.to_i
    end.reverse!

    # Build menu options
    backup_options = backups.map do |fname|
      timestamp_str = fname.sub(/^#{Regexp.escape(file_name)}_/, "").sub(/\.rxdata$/, "")
      timestamp_str.length >= 12 ? formatSaveDate(timestamp_str) : timestamp_str
    end
    backup_options << _INTL("Cancel")

    choice = optionsMenu(backup_options, backup_options.length - 1)

    # Cancelled or out of range
    return nil if choice < 0 || choice >= backups.length

    chosen_file = backups[choice]
    chosen_date = backup_options[choice]

    return nil unless pbConfirmMessage(_INTL("Load the backup from {1}?", chosen_date))

    backup_path = File.join(backup_dir, chosen_file)
    save_data = SaveData.read_from_file(backup_path) rescue nil

    unless SaveData.valid?(save_data)
      pbMessage(_INTL("This backup appears to be corrupt and could not be loaded."))
      return nil
    end

    return save_data
  end


end

#===============================================================================
#
#===============================================================================
class PokemonSave_Scene
  def pbUpdateSlotInfo(slottext)
    pbDisposeSprite(@sprites, "slotinfo")
    @sprites["slotinfo"] = Window_AdvancedTextPokemon.new(slottext)
    @sprites["slotinfo"].viewport = @viewport
    @sprites["slotinfo"].x = 0
    @sprites["slotinfo"].y = 160
    @sprites["slotinfo"].width = 228 if @sprites["slotinfo"].width < 228
    @sprites["slotinfo"].visible = true
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSaveScreen
  def doSave(slot)
    if Game.save(slot)
      pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
      return true
    else
      pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
      return false
    end
  end

  # Return true if pause menu should close after this is done (if the game was saved successfully)
  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if !$Trainer.save_slot
      # New Game - must select slot
      ret = slotSelect
    else
      choices = [
        _INTL("Save to #{$Trainer.save_slot}"),
        _INTL("Save to another slot"),
        _INTL("Don't save")
      ]
      opt = pbMessage(_INTL("Would you like to save the game?"), choices, 3)
      if opt == 0
        pbSEPlay('GUI save choice')
        ret = doSave($Trainer.save_slot)
      elsif opt == 1
        pbPlayDecisionSE
        ret = slotSelect
      else
        pbPlayCancelSE
      end
    end
    @scene.pbEndScreen
    return ret
  end

  # Call this to open the slot select screen
  # Returns true if the game was saved, otherwise false
  def slotSelect
    ret = false
    choices = SaveData::MANUAL_SLOTS
    choice_info = SaveData::MANUAL_SLOTS.map { |s| getSaveInfoBoxContents(s) }
    index = slotSelectCommands(choices, choice_info)
    if index >= 0
      slot = SaveData::MANUAL_SLOTS[index]
      # Confirm if slot not empty
      if !File.file?(SaveData.get_full_path(slot)) ||
        pbConfirmMessageSerious(_INTL("Are you sure you want to overwrite the save in {1}?",slot)) # If the slot names were changed this grammar might need adjustment.
        pbSEPlay('GUI save choice')
        ret = doSave(slot)
      end
    end
    pbPlayCloseMenuSE if !ret
    return ret
  end

  # Handles the UI for the save slot select screen. Returns the index of the chosen slot, or -1.
  # Based on pbShowCommands
  def slotSelectCommands(choices, choice_info, defaultCmd = 0)
    msgwindow = Window_AdvancedTextPokemon.new(_INTL("Which slot to save in?"))
    msgwindow.z = 99999
    msgwindow.visible = true
    msgwindow.letterbyletter = true
    msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
    pbBottomLeftLines(msgwindow, 2)
    $game_temp.message_window_showing = true if $game_temp
    msgwindow.setSkin(MessageConfig.pbGetSpeechFrame)

    cmdwindow = Window_CommandPokemonEx.new(choices)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    cmdwindow.index = defaultCmd
    command = 0
    loop do
      @scene.pbUpdateSlotInfo(choice_info[cmdwindow.index])
      Graphics.update
      Input.update
      cmdwindow.update
      msgwindow.update if msgwindow
      if Input.trigger?(Input::BACK)
        command = -1
        break
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    msgwindow.dispose
    $game_temp.message_window_showing = false if $game_temp
    Input.update
    return ret
  end

  # Show the player some data about their currently selected save slot for quick identification
  # This doesn't use player gender for coloring, unlike the default save window
  def getSaveInfoBoxContents(slot)
    full_path = SaveData.get_full_path(slot)
    if !File.file?(full_path)
      return _INTL("<ac><c3=3050C8,D0D0C8>(empty)</c3></ac>")
    end
    temp_save_data = SaveData.read_from_file(full_path)

    # Last save time
    time = temp_save_data[:player].last_time_saved
    if time
      date_str = time.strftime(_INTL("%x"))
      time_str = time.strftime(_INTL("%I:%M%p"))
      datetime_str = "#{date_str}<r>#{time_str}<br>"
    else
      datetime_str = _INTL("<ac>(old save)</ac>")
    end

    # Map name
    map_str = pbGetMapNameFromId(temp_save_data[:map_factory].map.map_id)

    # Elapsed time
    totalsec = (temp_save_data[:frame_count] || 0) / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    if hour > 0
      elapsed_str = _INTL("Time<r>{1}h {2}m<br>", hour, min)
    else
      elapsed_str = _INTL("Time<r>{1}m<br>", min)
    end

    return "<c3=3050C8,D0D0C8>#{datetime_str}</c3>" + # blue
      "<ac><c3=209808,90F090>#{map_str}</c3></ac>" + # green
      "#{elapsed_str}"
  end
end

#===============================================================================
#
#===============================================================================
module Game
  # Fix New Game bug (if you saved during an event script)
  # This fix is from Essentials v20.1 Hotfixes 1.0.5
  def self.start_new(ngp_unlocked=false,ngp_bag = nil, ngp_storage = nil, ngp_trainer = nil)
    if $game_map && $game_map.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $PokemonTemp.begunNewGame = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
    #
    # if ngp_bag != nil
    #   $PokemonBag = ngp_clean_item_data(ngp_bag)
    # end
    if ngp_storage != nil
      $PokemonStorage = ngp_clean_pc_data(ngp_storage, ngp_trainer.party)
    end
    if ngp_trainer
      $Trainer.unlocked_hats = ngp_trainer.unlocked_hats
      $Trainer.unlocked_clothes = ngp_trainer.unlocked_clothes

      if Settings::HOENN
        $Trainer.pokenav = Pokenav.new
        $Trainer.pokenav&.installed_apps = ngp_trainer.pokenav&.installed_apps
      end
    end
    $Trainer.new_game_plus_unlocked = ngp_unlocked
  end

  # Loads bootup data from save file (if it exists) or creates bootup data (if
  # it doesn't).
  def self.set_up_system
    SaveData.move_old_windows_save if System.platform[/Windows/]
    save_slot = SaveData.get_newest_save_slot
    if save_slot
      save_data = SaveData.read_from_file(SaveData.get_full_path(save_slot))
    else
      save_data = {}
    end
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if Settings::LANGUAGES[Settings::GAME_ID].length >= 2
      $PokemonSystem.language = pbChooseLanguage if save_data.empty?

      available_languages = Settings::LANGUAGES[Settings::GAME_ID]
      $PokemonSystem.language = 0 if $PokemonSystem.language > available_languages.length-1
      pbLoadMessages('Data/' + available_languages[$PokemonSystem.language][1])
    end
  end

  def self.backup_savefile(save_path, slot)
    begin
    backup_dir = File.join(File.dirname(save_path), "backups")
    Dir.mkdir(backup_dir) if !Dir.exist?(backup_dir)

    backup_slot_dir = File.join(File.dirname(save_path), "backups/#{slot}")
    Dir.mkdir(backup_slot_dir) if !Dir.exist?(backup_slot_dir)

    # Manage rolling backups
    if File.exist?(save_path)
      # Generate a timestamped backup name
      timestamp = Time.now.strftime(_INTL("%Y%m%d%H%M%S"))
      backup_file = File.join(backup_slot_dir, "#{slot}_#{timestamp}.rxdata")

      # Copy the save file manually
      File.open(save_path, 'rb') do |source|
        File.open(backup_file, 'wb') do |dest|
          dest.write(source.read)
        end
      end

      # Clean up old backups
      backups = Dir.get(backup_slot_dir, "*.rxdata")
      # Keep only the latest N backups
      if backups.length > Settings::SAVEFILE_NB_BACKUPS
        excess_backups = backups[0...(backups.length - Settings::SAVEFILE_NB_BACKUPS)]
        echoln excess_backups
        excess_backups.each { |old_backup| File.delete(old_backup) }
      end
    end
    rescue => e
      echoln ("There was an error while creating a backup savefile.")
      echoln("Error: #{e.message}")
    end
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(slot = nil, auto = false, safe: false)
    slot = $Trainer.save_slot if slot.nil?
    return false if slot.nil?

    file_path = SaveData.get_full_path(slot)
    self.backup_savefile(file_path, slot)

    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    $Trainer.save_slot = slot unless auto
    $Trainer.last_time_saved = Time.now
    begin
      SaveData.save_to_file(file_path)
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end

  # Overwrites the first empty autosave slot, otherwise the oldest existing autosave
  def self.auto_save
    oldest_time = nil
    oldest_slot = nil
    SaveData::AUTO_SLOTS.each do |slot|
      full_path = SaveData.get_full_path(slot)
      if !File.file?(full_path)
        oldest_slot = slot
        break
      end
      temp_save_data = SaveData.read_from_file(full_path)
      save_time = temp_save_data[:player].last_time_saved || Time.at(1)
      if oldest_time.nil? || save_time < oldest_time
        oldest_time = save_time
        oldest_slot = slot
      end
    end
    self.save(oldest_slot, true)
  end
end

#===============================================================================
#
#===============================================================================

# Lol who needs the FileUtils gem?
# This is the implementation from the original pbEmergencySave.
def file_copy(src, dst)
  File.open(src, 'rb') do |r|
    File.open(dst, 'wb') do |w|
      while s = r.read(4096)
        w.write s
      end
    end
  end
end

# When I needed extra data fields in the save file I put them in Player because it seemed easier than figuring out
# how to make a save file conversion, and I prefer to maintain backwards compatibility.
class Player
  attr_accessor :last_time_saved
  attr_accessor :save_slot
  attr_accessor :autosave_steps
end

def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("The script is taking too long. The game will restart."))
  return if !$Trainer
  return if !$Trainer.save_slot
  current_file = SaveData.get_full_path($Trainer.save_slot)
  backup_file = SaveData.get_backup_file_path
  file_copy(current_file, backup_file)
  if Game.save
    pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game] The previous save file has been backed up.\\wtnp[30]"))
  else
    pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
  end
  $scene = oldscene
end
