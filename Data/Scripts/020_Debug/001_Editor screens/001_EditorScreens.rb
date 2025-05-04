

#===

#===============================================================================
# Metadata editor
#===============================================================================
def pbMetadataScreen(map_id = 0)
  loop do
    map_id = pbListScreen(_INTL("SET METADATA"), MapLister.new(map_id, true))
    break if map_id < 0
    pbEditMetadata(map_id)
  end
end

def pbEditMetadata(map_id = 0)
  mapinfos = pbLoadMapInfos
  data = []
  if map_id == 0   # Global metadata
    map_name = _INTL("Global Metadata")
    metadata = GameData::Metadata.get
    properties = GameData::Metadata.editor_properties
  else   # Map metadata
    map_name = mapinfos[map_id].name
    metadata = GameData::MapMetadata.try_get(map_id)
    metadata = GameData::Metadata.new({}) if !metadata
    properties = GameData::MapMetadata.editor_properties
  end
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(map_name, data, properties, true)
    if map_id == 0   # Global metadata
      # Construct metadata hash
      metadata_hash = {
        :id                 => map_id,
        :home               => data[0],
        :wild_battle_BGM    => data[1],
        :trainer_battle_BGM => data[2],
        :wild_victory_ME    => data[3],
        :trainer_victory_ME => data[4],
        :wild_capture_ME    => data[5],
        :surf_BGM           => data[6],
        :bicycle_BGM        => data[7],
        :player_A           => data[8],
        :player_B           => data[9],
        :player_C           => data[10],
        :player_D           => data[11],
        :player_E           => data[12],
        :player_F           => data[13],
        :player_G           => data[14],
        :player_H           => data[15]
      }
      # Add metadata's data to records
      GameData::Metadata.register(metadata_hash)
      GameData::Metadata.save
    else   # Map metadata
      # Construct metadata hash
      metadata_hash = {
        :id                   => map_id,
        :outdoor_map          => data[0],
        :announce_location    => data[1],
        :can_bicycle          => data[2],
        :always_bicycle       => data[3],
        :teleport_destination => data[4],
        :weather              => data[5],
        :town_map_position    => data[6],
        :dive_map_id          => data[7],
        :dark_map             => data[8],
        :safari_map           => data[9],
        :snap_edges           => data[10],
        :random_dungeon       => data[11],
        :battle_background    => data[12],
        :wild_battle_BGM      => data[13],
        :trainer_battle_BGM   => data[14],
        :wild_victory_ME      => data[15],
        :trainer_victory_ME   => data[16],
        :wild_capture_ME      => data[17],
        :town_map_size        => data[18],
        :battle_environment   => data[19]
      }
      # Add metadata's data to records
      GameData::MapMetadata.register(metadata_hash)
      GameData::MapMetadata.save
    end
    Compiler.write_metadata
  end
end






#===============================================================================
# Regional Dexes editor
#===============================================================================
def pbRegionalDexEditor(dex)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmd_window = pbListWindow([])
  info = Window_AdvancedTextPokemon.newWithSize(
     _INTL("Z+Up/Down: Rearrange entries\nZ+Right: Insert new entry\nZ+Left: Delete entry\nD: Clear entry"),
     Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport)
  info.z = 2
  dex.compact!
  ret = dex.clone
  commands = []
  refresh_list = true
  cmd = [0, 0]   # [action, index in list]
  loop do
    # Populate commands
    if refresh_list
      loop do
        break if dex.length == 0 || dex[-1]
        dex.slice!(-1)
      end
      commands = []
      dex.each_with_index do |species, i|
        text = (species) ? GameData::Species.get(species).real_name : "----------"
        commands.push(sprintf("%03d: %s", i + 1, text))
      end
      commands.push(sprintf("%03d: ----------", commands.length + 1))
      cmd[1] = [cmd[1], commands.length - 1].min
      refresh_list = false
    end
    # Choose to do something
    cmd = pbCommands3(cmd_window, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap entry up
      if cmd[1] < dex.length - 1
        dex[cmd[1] + 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] + 1]
        refresh_list = true
      end
     when 2   # Swap entry down
      if cmd[1] > 0
        dex[cmd[1] - 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] - 1]
        refresh_list = true
      end
    when 3   # Delete spot
      if cmd[1] < dex.length
        dex.delete_at(cmd[1])
        refresh_list = true
      end
    when 4   # Insert spot
      if cmd[1] < dex.length
        dex.insert(cmd[1], nil)
        refresh_list = true
      end
    when 5   # Clear spot
      if dex[cmd[1]]
        dex[cmd[1]] = nil
        refresh_list = true
      end
    when 0
      if cmd[1] >= 0   # Edit entry
        case pbMessage(_INTL("\\ts[]Do what with this entry?"),
           [_INTL("Change species"), _INTL("Clear"), _INTL("Insert entry"), _INTL("Delete entry"), _INTL("Cancel")], 5)
        when 0   # Change species
          species = pbChooseSpeciesList(dex[cmd[1]])
          if species
            dex[cmd[1]] = species
            dex.each_with_index { |s, i| dex[i] = nil if i != cmd[1] && s == species }
            refresh_list = true
          end
        when 1   # Clear spot
          if dex[cmd[1]]
            dex[cmd[1]] = nil
            refresh_list = true
          end
        when 2   # Insert spot
          if cmd[1] < dex.length
            dex.insert(cmd[1], nil)
            refresh_list = true
          end
        when 3   # Delete spot
          if cmd[1] < dex.length
            dex.delete_at(cmd[1])
            refresh_list = true
          end
        end
      else   # Cancel
        case pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
        when 0   # Save all changes to Dex
          dex.slice!(-1) while !dex[-1]
          ret = dex
          break
        when 1   # Just quit
          break
        end
      end
    end
  end
  info.dispose
  cmd_window.dispose
  viewport.dispose
  ret.compact!
  return ret
end

def pbAppendEvoToFamilyArray(species, array, seenarray)
  return if seenarray[species]
  array.push(species)
  seenarray[species] = true
  evos = GameData::Species.get(species).get_evolutions
  if evos.length > 0
    evos.sort! { |a, b| GameData::Species.get(a[0]).id_number <=> GameData::Species.get(b[0]).id_number }
    subarray = []
    for i in evos
      pbAppendEvoToFamilyArray(i[0], subarray, seenarray)
    end
    array.push(subarray) if subarray.length > 0
  end
end

def pbGetEvoFamilies
  seen = []
  ret = []
  GameData::Species.each do |sp|
    next if sp.form > 0
    species = sp.get_baby_species
    next if seen[species]
    subret = []
    pbAppendEvoToFamilyArray(species, subret, seen)
    ret.push(subret.flatten) if subret.length > 0
  end
  return ret
end

def pbEvoFamiliesToStrings
  ret = []
  families = pbGetEvoFamilies
  for fam in 0...families.length
    string = ""
    for p in 0...families[fam].length
      if p>=3
        string += " + #{families[fam].length - 3} more"
        break
      end
      string += "/" if p > 0
      string += GameData::Species.get(families[fam][p]).name
    end
    ret[fam] = string
  end
  return ret
end



#===============================================================================
# Battle animations rearranger
#===============================================================================
def pbAnimationsOrganiser
  list = pbLoadBattleAnimations
  if !list || !list[0]
    pbMessage(_INTL("No animations exist."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(_INTL("Animations Organiser"),
     Graphics.width / 2, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  info = Window_AdvancedTextPokemon.newWithSize(_INTL("Z+Up/Down: Swap\nZ+Left: Delete\nZ+Right: Insert"),
     Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport)
  info.z = 2
  commands = []
  refreshlist = true; oldsel = -1
  cmd = [0,0]
  loop do
    if refreshlist
      commands = []
      for i in 0...list.length
        commands.push(sprintf("%d: %s",i,(list[i]) ? list[i].name : "???"))
      end
    end
    refreshlist = false; oldsel = -1
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    if cmd[0]==1   # Swap animation up
      if cmd[1]>=0 && cmd[1]<commands.length-1
        list[cmd[1]+1],list[cmd[1]] = list[cmd[1]],list[cmd[1]+1]
        refreshlist = true
      end
    elsif cmd[0]==2   # Swap animation down
      if cmd[1]>0
        list[cmd[1]-1],list[cmd[1]] = list[cmd[1]],list[cmd[1]-1]
        refreshlist = true
      end
    elsif cmd[0]==3   # Delete spot
      list.delete_at(cmd[1])
      cmd[1] = [cmd[1],list.length-1].min
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==4   # Insert spot
      list.insert(cmd[1],PBAnimation.new)
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==0
      cmd2 = pbMessage(_INTL("Save changes?"),
          [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd2==0 || cmd2==1
        if cmd2==0
          # Save animations here
          save_data(list,"Data/PkmnAnimations.rxdata")
          $PokemonTemp.battleAnims = nil
          pbMessage(_INTL("Data saved."))
        end
        break
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end
