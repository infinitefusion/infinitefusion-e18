class OutfitSelector
  attr_reader :clothes_list
  attr_reader :hats_list
  attr_reader :hairstyles_list

  def initialize()
    @clothes_list = parse_clothes_folder()
    @hats_list = parse_hats_folder()
    @hairstyles_list =parse_hairstyles_folder()
  end


  def parse_clothes_folder
    return list_folders(get_clothes_sets_list_path())
  end

  def parse_hats_folder
    return list_folders(get_hats_sets_list_path())
  end

  def parse_hairstyle_types_folder
    return list_folders(get_hair_sets_list_path())
  end

  def generate_hats_choice(baseOptions=true,additionalIds=[],additionalTags=[],filterOutTags=[])
    list = []
    list += additionalIds
    list += search_hats(additionalTags)
    if baseOptions
      list += get_hats_base_options()
      list += search_hats(get_regional_sets_tags())
    end
    return list
  end

  def generate_clothes_choice(baseOptions=true,additionalIds=[],additionalTags=[],filterOutTags=[])
    list = []
    list += additionalIds
    list += search_clothes(additionalTags)
    if baseOptions
      list += get_clothes_base_options()
      list += search_clothes(get_regional_sets_tags())
    end
    return list
  end

  def generate_hairstyle_choice(baseOptions=true,additionalIds=[],additionalTags=[],filterOutTags=[])
    list = []
    list += additionalIds
    list += search_hairstyles(additionalTags)
    if baseOptions
      list += get_hairstyle_salon_base_options()
      list += search_hairstyles(get_regional_sets_tags())
    end
    list << HAIR_BALD if Settings::KANTO
    return list
  end

  def get_regional_sets_tags()
    regional_tags = []
    regional_tags << "kanto" if $game_switches[SWITCH_KANTO_HAIR_COLLECTION]
    regional_tags << "johto" if $game_switches[SWITCH_JOHTO_HAIR_COLLECTION]
    regional_tags << "hoenn" if $game_switches[SWITCH_HOENN_HAIR_COLLECTION]
    regional_tags << "sinnoh" if $game_switches[SWITCH_SINNOH_HAIR_COLLECTION]
    regional_tags << "unova" if $game_switches[SWITCH_UNOVA_HAIR_COLLECTION]
    regional_tags << "kalos" if $game_switches[SWITCH_KALOS_HAIR_COLLECTION]
    regional_tags << "alola" if $game_switches[SWITCH_ALOLA_HAIR_COLLECTION]
    regional_tags << "galar" if $game_switches[SWITCH_GALAR_HAIR_COLLECTION]
    regional_tags << "paldea" if $game_switches[SWITCH_PALDEA_HAIR_COLLECTION]
    return regional_tags
  end

  def get_hairstyle_salon_base_options()
    return search_hairstyles(["default"])
  end

  def get_clothes_base_options()
    return search_clothes(["default"])
  end

  def get_hats_base_options()
    return search_hats(["default"])
  end

  def parse_hairstyles_folder
    hairstyle_types= list_folders(get_hair_sets_list_path())
    max_versions_number = 10
    list= []
    for hairstyle in hairstyle_types
      for i in 1..max_versions_number
        type = i.to_s + "_" + hairstyle
        filePath = getOverworldHairFilename(type)
        if pbResolveBitmap(filePath)
          list << type
        end
      end
    end
    return list
  end

  def list_folders(path)
    entries= Dir.entries(path)
    return entries.select { |entry| File.directory?(File.join(path, entry)) && entry != '.' && entry != '..' }
  end


  def filter_unlocked_outfits(outfits_list,unlocked_outfits)
    available_outfits = []
    outfits_list.each do |outfit|
      available_outfits << outfit if unlocked_outfits.include?(outfit)
    end
    return available_outfits
  end


  def selectNextOutfit(currentOutfit, incr, outfits_list, versions = [], allowNone = true, prefix_filter = nil,unlockedOutfits=[],everythingUnlocked=false)
    available_outfits = []
    available_outfits = outfits_list if everythingUnlocked
    available_outfits << "" if allowNone
    available_outfits += filter_unlocked_outfits(outfits_list,unlockedOutfits) if !everythingUnlocked
    #available_outfits += list_available_outfits(directory, versions, unlockedOutfits, prefix_filter) #unlockedOutfits = nil for all outfits unlocked
    last_outfit = available_outfits[-1]

    current_outfit_index = get_current_outfit_position(currentOutfit, available_outfits)
    next_outfit_index = current_outfit_index +incr

    nextOutfit = available_outfits[next_outfit_index]
    nextOutfit = last_outfit if next_outfit_index < 0

    nextOutfit = available_outfits[0] if next_outfit_index >= available_outfits.length()

    return nextOutfit if available_outfits.include?(nextOutfit)
    return currentOutfit
  end

  def changeToNextClothes(incr,all_unlocked=false)
    $Trainer.unlocked_clothes = [] if !$Trainer.unlocked_clothes


    currentOutfit = $Trainer.clothes
    currentOutfit = 0 if !currentOutfit
    nextOutfit = selectNextOutfit(currentOutfit, incr, @clothes_list, [], false,nil,$Trainer.unlocked_clothes,all_unlocked)
    $Trainer.clothes = nextOutfit
    $Trainer.clothes_color = 0
    echoln $Trainer.clothes

  end

  def changeToNextHat(incr,all_unlocked=false)
    $Trainer.unlocked_hats = [] if !$Trainer.unlocked_hats

    currentHat = $Trainer.hat
    currentHat = 0 if !currentHat
    nextOutfit = selectNextOutfit(currentHat, incr, @hats_list, [], true, "hat",$Trainer.unlocked_hats,all_unlocked)
    $Trainer.hat = nextOutfit
    $Trainer.hat_color = 0
    echoln $Trainer.hat

  end

  def changeToNextHairstyle(incr,all_unlocked=false)
    $Trainer.unlocked_hairstyles = [] if !$Trainer.unlocked_hairstyles

    currentHair = $Trainer.hair
    currentHair = 0 if !currentHair
    nextOutfit = selectNextOutfit(currentHair, incr, @hairstyles_list, ["a", "b", "c", "d"], true,nil,$Trainer.unlocked_hairstyles,all_unlocked)
    $Trainer.hair_color = 0
    $Trainer.hair = nextOutfit
    echoln $Trainer.hair

  end


end
