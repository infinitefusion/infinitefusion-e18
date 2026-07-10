class TripleFusion <  Pokemon
  attr_reader :species1
  attr_reader :species2
  attr_reader :species3

  def initialize(species1, species2,species3, level, owner = $Trainer, withMoves = true, recheck_form = true)
    @species1=species1
    @species2=species2
    @species3=species3

    @species1_data = GameData::Species.get(@species1)
    @species2_data = GameData::Species.get(@species2)
    @species3_data = GameData::Species.get(@species3)

    @species_name = generate_triple_fusion_name()

    super(:ZAPMOLTICUNO,level,owner,withMoves,recheck_form)
  end



  def types
    return [@species1_data.type1, @species2_data.type1,@species3_data.type1]
  end

  def baseStats
    ret = {}
    GameData::Stat.each_main do |s|
      stat1 = @species1_data.base_stats[s.id]
      stat2 = @species2_data.base_stats[s.id]
      stat3 = @species3_data.base_stats[s.id]

      ret[s.id] = (stat1 + stat2 + stat3) / 3
    end
    return ret
  end

  def name
    return (nicknamed?) ? @name : @species_name
  end

  def speciesName
    return @species_name
  end

  def generate_triple_fusion_name()
    part1 = split_string_with_syllables(@species1_data.name)[0]
    part2 = split_string_with_syllables(@species2_data.name)[1]
    part3 = split_string_with_syllables(@species3_data.name)[2]
    return "#{part1}#{part2}#{part3}".capitalize!
  end


  def split_string_with_syllables(name)
    syllable_pattern = /[bcdfghjklmnpqrstvwxyz]*[aeiou]+[bcdfghjklmnpqrstvwxyz]*/
    syllables = name.downcase.scan(syllable_pattern)
    first_syllable= syllables.first
    last_syllable = syllables.last
    if syllables.length > 1
      middle_syllable = syllables[1]
    else
      middle_syllable = first_syllable.downcase
    end

    last_syllable.nil? ? first_syllable : last_syllable
    return [first_syllable,middle_syllable,last_syllable]

  end

  def ability_id
    if !@ability
      abil_index = ability_index
      if !@ability # Natural ability or no hidden ability defined
        chosen_poke_for_ability= rand(1..3)
        if chosen_poke_for_ability == 1
          @ability = @species1_data.abilities[abil_index] || @species1_data.abilities[0]
        elsif chosen_poke_for_ability == 2
          @ability = @species2_data.abilities[abil_index] || @species2_data.abilities[0]
        else
          @ability = @species3_data.abilities[abil_index] || @species3_data.abilities[0]
        end

      end
    end
    return @ability
  end


end

