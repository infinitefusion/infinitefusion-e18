class BattleSpriteLoader
  def initialize
    @download_allowed = true
  end

  def load_pif_sprite_directly(pif_sprite)
    if pif_sprite.local_path && pbResolveBitmap(pif_sprite.local_path)
      return AnimatedBitmap.new(pif_sprite.local_path)
    end
    extractor = get_sprite_extractor_instance(pif_sprite.type)
    return extractor.load_sprite(pif_sprite)
  end

  #random alt
  def load_pif_sprite(pif_sprite)
    case pif_sprite.type
    when :CUSTOM, :AUTOGEN
      load_fusion_sprite(pif_sprite.head_id, pif_sprite.body_id)
    when :BASE
      load_base_sprite(pif_sprite.head_id)
    end
  end

  # Only preloads if the pokemon's sprite has been assigned an alt letter
  def preload_sprite_from_pokemon(pokemon)
    return if !pokemon
    substitution_id = get_sprite_substitution_id_from_dex_number(pokemon.species)
    # echoln substitution_id
    # echoln $PokemonGlobal.alt_sprite_substitutions
    pif_sprite = $PokemonGlobal.alt_sprite_substitutions[substitution_id] if $PokemonGlobal
    if !pif_sprite
      pif_sprite = get_pif_sprite_from_species(pokemon.species)
    end
    preload(pif_sprite)
  end

  #loads a sprite into cache without actually returning it
  # Does not download spritesheet
  def preload(pif_sprite)
    echoln "preloading"
    previous_download_allowed = @download_allowed
    @download_allowed = false
    load_pif_sprite(pif_sprite)
    @download_allowed = previous_download_allowed
  end

  def clear_sprites_cache(type)
    extractor = get_sprite_extractor_instance(type)
    extractor.clear_cache
  end

  def load_from_dex_number(dex_number)
    if dex_number > NB_POKEMON
      if dex_number > ZAPMOLCUNO_NB #Triple Fusion
        return load_triple_fusion_sprite(dex_number)
      else
        #Regular fusion
        body_id = getBodyID(dex_number)
        head_id = getHeadID(dex_number, body_id)
        return load_fusion_sprite(head_id, body_id)
      end
    else
      #base pokemon
      return load_base_sprite(dex_number)
    end
  end

  def obtain_fusion_pif_sprite(head_id,body_id)
    substitution_id = get_sprite_substitution_id_for_fusion(head_id, body_id)
    pif_sprite = $PokemonGlobal.alt_sprite_substitutions[substitution_id] if $PokemonGlobal
    pif_sprite.dump_info if pif_sprite
    if !pif_sprite
      pif_sprite = select_new_pif_fusion_sprite(head_id, body_id)
      local_path = check_for_local_sprite(pif_sprite)
      if local_path
        pif_sprite.local_path = local_path
        pif_sprite.type = :CUSTOM
      end
      substitution_id = get_sprite_substitution_id_for_fusion(head_id, body_id)
      $PokemonGlobal.alt_sprite_substitutions[substitution_id] = pif_sprite if $PokemonGlobal
    end
    return pif_sprite
  end


  def load_fusion_sprite(head_id, body_id)
    pif_sprite = obtain_fusion_pif_sprite(head_id,body_id)
    if pif_sprite.local_path
      return AnimatedBitmap.new(pif_sprite.local_path)
    end
    extractor = get_sprite_extractor_instance(pif_sprite.type)
    loaded_sprite = extractor.load_sprite(pif_sprite, @download_allowed)
    if !loaded_sprite
      loaded_sprite = handle_unloaded_sprites(extractor,pif_sprite)
    end
    return loaded_sprite
  end

  def load_base_sprite(dex_number)
    substitution_id = get_sprite_substitution_id_from_dex_number(dex_number)
    pif_sprite = $PokemonGlobal.alt_sprite_substitutions[substitution_id] if $PokemonGlobal
    if !pif_sprite
      pif_sprite = select_new_pif_base_sprite(dex_number)
      $PokemonGlobal.alt_sprite_substitutions[substitution_id] = pif_sprite if $PokemonGlobal
    end
    if pif_sprite.local_path
      return AnimatedBitmap.new(pif_sprite.local_path)
    end
    extractor = get_sprite_extractor_instance(pif_sprite.type)
    loaded_sprite = extractor.load_sprite(pif_sprite)
    if !loaded_sprite
      loaded_sprite = handle_unloaded_sprites(extractor,pif_sprite)
    end
    return loaded_sprite
  end

  def handle_unloaded_sprites(extractor,pif_sprite)
    if(extractor.is_a?(CustomSpriteExtracter)) #Custom failed to load, load an autogen (which should always be there)
      new_extractor = get_sprite_extractor_instance(:AUTOGEN)
      return new_extractor.load_sprite(pif_sprite)
    else
      #If autogen or base sprite aren't able to load a sprite then we have nothing else to load -> show a ? instead.
      return AnimatedBitmap.new(Settings::DEFAULT_SPRITE_PATH)
    end
  end


    #Always loaded from local individual sprites
  def load_triple_fusion_sprite(dex_number)
    sprite_path = getSpecialSpriteName(dex_number)
    return AnimatedBitmap.new(sprite_path)
  end

  def get_sprite_extractor_instance(type)
    case type
    when :AUTOGEN
      return AutogenExtracter.instance
    when :CUSTOM
      return CustomSpriteExtracter.instance
    when :BASE
      return BaseSpriteExtracter.instance
    else
      raise ArgumentError, "Unknown sprite type: #{type}"
    end
  end

  def check_for_local_sprite(pif_sprite)
    return pif_sprite.local_path if pif_sprite.local_path
    if pif_sprite.type == :BASE
      sprite_path = "#{Settings::CUSTOM_BASE_SPRITES_FOLDER}#{pif_sprite.head_id}#{pif_sprite.alt_letter}.png"
    else
      sprite_path = "#{Settings::CUSTOM_BATTLERS_FOLDER_INDEXED}#{pif_sprite.head_id}/#{pif_sprite.head_id}.#{pif_sprite.body_id}#{pif_sprite.alt_letter}.png"
    end
    return pbResolveBitmap(sprite_path)
  end

  def get_pif_sprite_from_species(species)
    species = GameData::Species.get(species)
    head_id = species.get_head_species
    body_id = species.get_body_species

    substitution_id = get_sprite_substitution_id_for_fusion(head_id, body_id)
    pif_sprite = $PokemonGlobal.alt_sprite_substitutions[substitution_id] if $PokemonGlobal
    return pif_sprite if pif_sprite
    if species.id_number <= NB_POKEMON #base pokemon
      return select_new_pif_base_sprite(head_id)
    else #isFusion
      return select_new_pif_fusion_sprite(head_id, body_id)
    end
  end

  #
  # Flow:
  # #   if none found, look for custom sprite in custom spritesheet (download if can't find spritesheet or new spritepack released)
  #   if  none found, load from autogen spritesheet

  def select_new_pif_fusion_sprite(head_id, body_id)
    species_symbol = "B#{body_id}H#{head_id}".to_sym
    spritename = get_fusion_spritename(head_id,body_id)
    customSpritesList = $game_temp.custom_sprites_list[species_symbol]
    alt_letter = ""
    if customSpritesList
      alt_letter = get_random_alt_letter_for_custom(head_id,body_id,true)
      type = :CUSTOM
      type = :AUTOGEN if !alt_letter
    else
      type = :AUTOGEN
    end
    if $PokemonTemp.forced_alt_sprites && $PokemonTemp.forced_alt_sprites.include?(spritename)
      alt_letter = $PokemonTemp.forced_alt_sprites[spritename]
    end
    return PIFSprite.new(type, head_id, body_id, alt_letter)
  end

  def select_new_pif_base_sprite(dex_number)
    random_alt = get_random_alt_letter_for_unfused(dex_number, true) #nil if no main
    random_alt = "" if !random_alt
    return PIFSprite.new(:BASE, dex_number, nil, random_alt)
  end

  def getSpecialSpriteName(dexNum)
    base_path = "Graphics/Battlers/special/"
    case dexNum
    when Settings::ZAPMOLCUNO_NB
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 1
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 2
      return sprintf(base_path + "243.244.245")
    when Settings::ZAPMOLCUNO_NB + 3
      return sprintf(base_path +"340.341.342")
    when Settings::ZAPMOLCUNO_NB + 4
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 5
      return sprintf(base_path +"349.350.351")
    when Settings::ZAPMOLCUNO_NB + 6
      return sprintf(base_path +"151.251.381")
    when Settings::ZAPMOLCUNO_NB + 11
      return sprintf(base_path +"150.348.380")
      #starters
    when Settings::ZAPMOLCUNO_NB + 7
      return sprintf(base_path +"3.6.9")
    when Settings::ZAPMOLCUNO_NB + 8
      return sprintf(base_path +"154.157.160")
    when Settings::ZAPMOLCUNO_NB + 9
      return sprintf(base_path +"278.281.284")
    when Settings::ZAPMOLCUNO_NB + 10
      return sprintf(base_path +"318.321.324")
      #starters prevos
    when Settings::ZAPMOLCUNO_NB + 12
      return sprintf(base_path +"1.4.7")
    when Settings::ZAPMOLCUNO_NB + 13
      return sprintf(base_path +"2.5.8")
    when Settings::ZAPMOLCUNO_NB + 14
      return sprintf(base_path +"152.155.158")
    when Settings::ZAPMOLCUNO_NB + 15
      return sprintf(base_path +"153.156.159")
    when Settings::ZAPMOLCUNO_NB + 16
      return sprintf(base_path +"276.279.282")
    when Settings::ZAPMOLCUNO_NB + 17
      return sprintf(base_path +"277.280.283")
    when Settings::ZAPMOLCUNO_NB + 18
      return sprintf(base_path +"316.319.322")
    when Settings::ZAPMOLCUNO_NB + 19
      return sprintf(base_path +"317.320.323")
    when Settings::ZAPMOLCUNO_NB + 20 #birdBoss Left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 21 #birdBoss middle
      return sprintf(base_path + "144.145.146")
    when Settings::ZAPMOLCUNO_NB + 22 #birdBoss right
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 23 #sinnohboss left
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 24 #sinnohboss middle
      return sprintf(base_path +"343.344.345")
    when Settings::ZAPMOLCUNO_NB + 25 #sinnohboss right
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 25 #cardboard
      return sprintf(base_path +"invisible")
    when Settings::ZAPMOLCUNO_NB + 26 #cardboard
      return sprintf(base_path + "cardboard")
    when Settings::ZAPMOLCUNO_NB + 27 #Triple regi
      return sprintf(base_path + "447.448.449")
      #Triple Kalos 1
    when Settings::ZAPMOLCUNO_NB + 28
      return sprintf(base_path + "479.482.485")
    when Settings::ZAPMOLCUNO_NB + 29
      return sprintf(base_path + "480.483.486")
    when Settings::ZAPMOLCUNO_NB + 30
      return sprintf(base_path + "481.484.487")
    else
      return sprintf(base_path + "000")
    end
  end
end
