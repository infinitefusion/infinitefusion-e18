module GameData
  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is known by a symbol or an ID number.
  #=============================================================================
  module ClassMethods
    def register(hash)
      self::DATA[hash[:id]] = self::DATA[hash[:id_number]] = self.new(hash)
    end

    # @param other [Symbol, self, String, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String, Integer]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)

      if self == GameData::Species
        return !get(other).nil?
      end

      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String, Integer]

      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)

      #B1H1 - old format (still supported)
      if other.to_s.match?(/\AB\d+H\d+\z/)
        species = GameData::FusedSpecies.new(other)
        return species
      end

      if other.to_s.include?("/")
        species = GameData::FusedSpecies.new(other)
        return species
      end

      if other.is_a?(Integer) && self == GameData::Species
        if other > NB_POKEMON
          body_id = getBodyID(other)
          head_id = getHeadID(other, body_id)
          pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
          return GameData::FusedSpecies.new(pokemon_id)
        end
      end

      if !self::DATA.has_key?(other)
        if self == GameData::Item
          return self::get(:UNKNOWN)
        else
          return self::get(:PIKACHU)
        end
      end
      return self::DATA[other]
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)

      if other.to_s.match?(/\AB\d+H\d+\z/) #old format (still supported)
        species = GameData::FusedSpecies.new(other)
        return species
      end

      if other.to_s.include?("_x_") #new format
        species = GameData::FusedSpecies.new(other)
        return species
      end

      if other.is_a?(Integer) && self == GameData::Species
        if other > NB_POKEMON
          body_id = getBodyID(other)
          head_id = getHeadID(other, body_id)
          pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
          return GameData::FusedSpecies.new(pokemon_id)
        end
      end

      #      if other.is_a?(Integer)
      #        p "Please switch to symbols, thanks."
      #      end
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in order of their id_number.
    def each
      keys = self::DATA.keys.sort { |a, b| self::DATA[a].id_number <=> self::DATA[b].id_number }
      keys.each { |key| yield self::DATA[key] if !key.is_a?(Integer) }
    end



    def load
      filename = "Data/#{self::DATA_FILENAME}"
      raw = File.open(filename, "rb") { |f| f.read }
      begin
        const_set(:DATA, Marshal.load(Encryption.xor(raw)))
      rescue TypeError, ArgumentError => e
        echoln "Encrypted load failed for #{filename}: #{e.message}, trying plain..."
        begin
          const_set(:DATA, Marshal.load(raw))
        rescue => e2
          echoln "Plain load also failed for #{filename}: #{e2.message}"
        end
      end
    end
    def save
      raw = Marshal.dump(self::DATA)
      File.open("Data/#{self::DATA_FILENAME}", "wb") { |f| f.write(Encryption.xor(raw)) }
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by a symbol.
  #=============================================================================
  module ClassMethodsSymbols
    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [Symbol, self, String]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    # @param other [Symbol, self, String]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in alphabetical order.
    def each
      keys = self::DATA.keys.sort { |a, b| self::DATA[a].real_name <=> self::DATA[b].real_name }
      keys.each { |key| yield self::DATA[key] }
    end

    def load
      filename = "Data/#{self::DATA_FILENAME}"
      raw = File.open(filename, "rb") { |f| f.read }
      begin
        const_set(:DATA, Marshal.load(Encryption.xor(raw)))
      rescue TypeError, ArgumentError => e
        echoln "Encrypted load failed for #{filename}: #{e.message}, trying plain..."
        begin
          const_set(:DATA, Marshal.load(raw))
        rescue => e2
          echoln "Plain load also failed for #{filename}: #{e2.message}"
        end
      end
    end
    def save
      raw = Marshal.dump(self::DATA)
      File.open("Data/#{self::DATA_FILENAME}", "wb") { |f| f.write(Encryption.xor(raw)) }
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by an ID number.
  #=============================================================================
  module ClassMethodsIDNumbers
    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [self, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [self, Integer]
      other = other.id if other.is_a?(self)
      return !self::DATA[other].nil?
    end

    # @param other [self, Integer]
    # @return [self]
    def get(other)
      validate other => [self, Integer]
      return other if other.is_a?(self)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    def try_get(other)
      return nil if other.nil?
      validate other => [self, Integer]
      return other if other.is_a?(self)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in numberical order.
    def each
      keys = self::DATA.keys.sort
      keys.each { |key| yield self::DATA[key] }
    end

    def load
      filename = "Data/#{self::DATA_FILENAME}"
      raw = File.open(filename, "rb") { |f| f.read }
      begin
        const_set(:DATA, Marshal.load(Encryption.xor(raw)))
      rescue TypeError, ArgumentError => e
        echoln "Encrypted load failed for #{filename}: #{e.message}, trying plain..."
        begin
          const_set(:DATA, Marshal.load(raw))
        rescue => e2
          echoln "Plain load also failed for #{filename}: #{e2.message}"
        end
      end
    end
    def save
      raw = Marshal.dump(self::DATA)
      File.open("Data/#{self::DATA_FILENAME}", "wb") { |f| f.write(Encryption.xor(raw)) }
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common instance methods
  # (called by thing.method) that analyse the data of a particular thing which
  # the instance represents.
  #=============================================================================
  module InstanceMethods
    # @param other [Symbol, self.class, String, Integer]
    # @return [Boolean] whether other represents the same thing as this thing
    def ==(other)
      return false if other.nil?
      if other.is_a?(Symbol)
        return @id == other
      elsif other.is_a?(self.class)
        return @id == other.id
      elsif other.is_a?(String)
        return @id_number == other.to_sym
      elsif other.is_a?(Integer)
        return @id_number == other
      end
      return false
    end
  end

  #=============================================================================
  # A bulk loader method for all data stored in .dat files in the Data folder.
  #=============================================================================
  def self.load_all
    Type.load
    Ability.load
    Move.load
    Item.load
    BerryPlant.load
    Species.load
    Ribbon.load
    Encounter.load
    EncounterModern.load
    EncounterRandom.load
    TrainerType.load
    Trainer.load
    TrainerModern.load
    TrainerExpert.load
    Metadata.load
    MapMetadata.load
  end
end
