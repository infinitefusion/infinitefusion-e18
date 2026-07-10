def setSpriteSubstitution(pif_sprite)

end

def getSpriteSubstitutionForDex(dex_num)

end


def setSpriteSubstitution(head,body)
end

def set_updated_spritesheets
end

def initialize_alt_sprite_substitutions()
  $PokemonSystem.alt_sprite_substitutions = {} if !$PokemonSystem.alt_sprite_substitutions
  migrate_sprites_substitutions()
end

def get_sprite_substitution_id_for_fusion(head_id, body_id)
  species_symbol = "B#{body_id}H#{head_id}".to_sym
  return get_sprite_substitution_id_from_dex_number(species_symbol)
end

def get_sprite_substitution_id_from_dex_number(species_symbol)
  species = GameData::Species.get(species_symbol)
  if species.is_fusion
    substitution_id = [species.get_head_species,species.get_body_species]
  else
    substitution_id= species.id_number
  end
  return substitution_id
end

def migrate_sprites_substitutions
  return if $game_switches[SWITCH_UPDATED_TO_SPRITESHEETS_SPRITES]
  new_substitutions = {}
  old_number_pokemon = 470
  for dex_number_key in $PokemonSystem.alt_sprite_substitutions.keys
    if $PokemonSystem.alt_sprite_substitutions[dex_number_key].is_a?(String) && can_convert_to_int?(dex_number_key)
      old_dex_number = dex_number_key.to_i
      if old_dex_number > old_number_pokemon #fusion
        body_id = getBodyID(old_dex_number,old_number_pokemon)
        head_id = getHeadID(old_dex_number,body_id,old_number_pokemon)
        new_id = [head_id,body_id]
        type = :CUSTOM
      else
        new_id = old_dex_number
        head_id = old_dex_number
        body_id= nil
        type = :BASE
      end
      file_path = $PokemonSystem.alt_sprite_substitutions[dex_number_key]
      alt_letter =get_alt_letter_from_path(file_path)

      pif_sprite = PIFSprite.new(type,head_id,body_id,alt_letter)
      new_substitutions[new_id] = pif_sprite
    end
  end
  $PokemonSystem.alt_sprite_substitutions = new_substitutions
  $game_switches[SWITCH_UPDATED_TO_SPRITESHEETS_SPRITES] = true
end

def can_convert_to_int?(str)
  Integer(str)
  true
rescue ArgumentError
  false
end

def get_alt_letter_from_path(filename)
    # Remove the extension
    base_name = filename.sub(/\.png$/, '')

    # Check the last character
    last_char = base_name[-1]

    if last_char.match?(/\d/) # Check if the last character is a number
      alt_letter = ""
    else
      # Reverse the base name and capture all letters until the first number
      alt_letter = base_name.reverse[/[a-zA-Z]+/].reverse
    end

    return alt_letter
end