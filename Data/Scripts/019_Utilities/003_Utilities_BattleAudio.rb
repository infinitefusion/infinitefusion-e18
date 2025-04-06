# Remove file type endings from audio files if present
def trimFileType(file)
  file_types = [".mp3",".wav",".ogg"]

  file_types.each {|type|
    file = file.chomp(type)
  }

  return file
end

def getSpecificGenOrRandomBGMPath(type, attachName="", fallback="", attachNameFallback="")
  selected_music_option = $PokemonSystem.musicstyle
  available_music = Dir.children("Audio/BGM/Types/"+type)
  available_music_type = available_music

  if available_music.length
    genIndicator = ""

    if selected_music_option == "random"
      genIndicator = $PokemonGlobal.nextRandomGenIndicator
    else
      # Get generation indicator from BATTLE_MUSIC_STYLES
      Settings::BATTLE_MUSIC_STYLES.each_with_index do |desc, i|
        if desc[:SettingId] == selected_music_option
          genIndicator = desc[:Indicator]
        end
      end
    end

    available_music_type = available_music.find_all {|bgm| (bgm.upcase).include?(genIndicator.upcase) }
  end

  amount_songs = available_music_type.length

  if amount_songs == 1
    audio_file = attachName+"Types/"+type+"/"+trimFileType(available_music_type[0])

    return audio_file
  elsif amount_songs > 1
    # Get random song of the gen
    audio_file = attachName+"Types/"+type+"/"+trimFileType(available_music_type[rand(amount_songs)])

    return audio_file
  end

  return pbStringToAudioFile(fallback) if fallback && fallback!="" && attachNameFallback == ""

  if fallback && fallback!=""
    audio = pbStringToAudioFile(fallback)
    audio.name = attachNameFallback+audio.name
    return audio 
  end

  return
end

#===============================================================================
# Load various wild battle music
#===============================================================================
def pbGetWildBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret = nil

  # Check map metadata
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  music = (map_metadata) ? map_metadata.wild_battle_BGM : nil
  ret = pbStringToAudioFile(music) if music && music != ""
  return ret if ret

  ret = getSpecificGenOrRandomBGMPath("Wild", "", GameData::Metadata.get.wild_battle_BGM)
  return ret if ret

  return pbStringToAudioFile("Battle wild")
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret = getSpecificGenOrRandomBGMPath("Wild_Victory", "", Settings::WILD_VICTORY_MUSIC, "../../Audio/ME/")
  return ret
end

def pbGetWildCaptureME
  if $PokemonGlobal.nextBattleCaptureME
    return $PokemonGlobal.nextBattleCaptureME.clone
  end
  ret = nil
  # Check map metadata
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  music = (map_metadata) ? map_metadata.wild_capture_ME : nil
  ret = pbStringToAudioFile(music) if music && music != ""
  return ret if ret
  
  # Check global metadata
  music = GameData::Metadata.get.wild_capture_ME
  ret = pbStringToAudioFile(music) if music && music!=""
  return ret if ret

  ret = getSpecificGenOrRandomBGMPath("Capture", "../../Audio/BGM/", "Battle capture success", "../../Audio/ME/")
  return ret
end

#===============================================================================
# Load/play various trainer battle music
#===============================================================================
def pbPlayTrainerIntroME(trainer_type)
  trainer_type_data = GameData::TrainerType.get(trainer_type)
  return if nil_or_empty?(trainer_type_data.intro_ME)
  bgm = pbStringToAudioFile(trainer_type_data.intro_ME)
  pbMEPlay(bgm)
end

def pbGetTrainerBattleBGM(trainer)   # can be a Player, NPCTrainer or an array of them
  music = nil
  ret = nil
  trainerarray = (trainer.is_a?(Array)) ? trainer : [trainer]

  if trainerarray.length == 1
    # Add New Folders to this array (Case sensitive)
    special_interaction_types = ["Leader", "Rival", "Elite", "Champion"]

    special_interaction_types.each {|type|
      if trainerarray[0].trainer_type.to_s.include?(type.upcase)
        music = getSpecificGenOrRandomBGMPath(type)
        ret = pbStringToAudioFile(music) if music && music!=""
        return ret if ret
      end
    }
  end

  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end

  trainerarray.each do |t|
    trainer_type_data = GameData::TrainerType.get(t.trainer_type)
    music = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
  end
  ret = pbStringToAudioFile(music) if music && music!=""
  return ret if ret

  # Check map metadata
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
  ret = pbStringToAudioFile(music) if music && music != ""
  return ret if ret
  
  ret = getSpecificGenOrRandomBGMPath("Trainer", "", GameData::Metadata.get.trainer_battle_BGM)
  return ret if ret

  return pbStringToAudioFile("Battle trainer")
end

def pbGetTrainerBattleBGMFromType(trainertype)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  trainer_type_data = GameData::TrainerType.get(trainertype)
  ret = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
  if !ret
    # Check map metadata
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    music = (map_metadata) ? map_metadata.trainer_battle_BGM : nil
    ret = pbStringToAudioFile(music) if music && music != ""
  end
  if !ret
    # Check global metadata
    music = GameData::Metadata.get.trainer_battle_BGM
    ret = pbStringToAudioFile(music) if music && music!=""
  end
  ret = pbStringToAudioFile("Battle trainer") if !ret
  return ret
end

def is_trainer_type(trainer, type)
  return trainer.trainer_type.to_s.include?(type)
end

def pbGetTrainerVictoryME(trainer)   # can be a Player, NPCTrainer or an array of them
  begin
    if trainer.is_a?(Array)
      npcTrainer=trainer[0]
    else
      npcTrainer=trainer
    end

    # Early exit if no special trainer
    if !is_trainer_type(npcTrainer, "CHAMPION") && !is_trainer_type(npcTrainer, "ELITE") && !is_trainer_type(npcTrainer, "LEADER") && !is_trainer_type(npcTrainer, "RIVAL")
      if $PokemonGlobal.nextBattleME
        return $PokemonGlobal.nextBattleME.clone
      end
  
      return getSpecificGenOrRandomBGMPath("Trainer_Victory", "", Settings::TRAINER_VICTORY_MUSIC, "../../Audio/ME/")
    end

    case npcTrainer
    when -> (trainer) { is_trainer_type(trainer, "CHAMPION") }
      ret = getSpecificGenOrRandomBGMPath("Champion_Victory")
      return ret if ret
      ret = getSpecificGenOrRandomBGMPath("Elite_Victory")
      return ret if ret
      ret = getSpecificGenOrRandomBGMPath("Leader_Victory")
      return ret if ret
    when -> (trainer) { is_trainer_type(trainer, "ELITE") }
      ret = getSpecificGenOrRandomBGMPath("Elite_Victory")
      return ret if ret
      ret = getSpecificGenOrRandomBGMPath("Leader_Victory")
      return ret if ret
    when -> (trainer) { is_trainer_type(trainer, "LEADER") }
      ret = getSpecificGenOrRandomBGMPath("Leader_Victory")
      return ret if ret
    when -> (trainer) { is_trainer_type(trainer, "RIVAL") }
      ret = getSpecificGenOrRandomBGMPath("Rival_Victory")
      return ret if ret
    end

    return getSpecificGenOrRandomBGMPath("Trainer_Victory", "", Settings::TRAINER_VICTORY_MUSIC, "../../Audio/ME/")
  rescue
    ret = pbStringToAudioFile(Settings::TRAINER_VICTORY_MUSIC)
    ret.name = "../../Audio/ME/"+ret.name
    return ret
  end
end
