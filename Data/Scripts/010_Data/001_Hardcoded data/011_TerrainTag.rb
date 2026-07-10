module GameData
  class TerrainTag
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :can_surf
    attr_reader :waterfall # The main part only, not the crest
    attr_reader :waterfall_crest
    attr_reader :can_fish
    attr_reader :can_dive
    attr_reader :deep_bush
    attr_reader :shows_grass_rustle
    attr_reader :land_wild_encounters
    attr_reader :double_wild_encounters
    attr_reader :battle_environment
    attr_reader :ledge
    attr_reader :ice
    attr_reader :bridge
    attr_reader :waterCurrent
    attr_reader :shows_reflections
    attr_reader :must_walk
    attr_reader :ignore_passability

    attr_reader :acroBike


    # oricorio
    attr_reader :flowerRed
    attr_reader :flowerPink
    attr_reader :flowerYellow
    attr_reader :flowerBlue
    attr_reader :flower

    #common objects
    attr_reader :trashcan
    attr_reader :chair

    attr_reader :chair

    attr_reader :sharpedoObstacle
    attr_reader :underwater # only visible when diving

    attr_reader :secretBase_tree
    attr_reader :secretBase_cave
    attr_reader :secretBase_bush

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    # @param other [Symbol, self, String, Integer]
    # @return [self]
    def self.try_get(other)
      return self.get(:None) if other.nil?
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : self.get(:None)
    end

    def self.load; end

    def self.save; end

    def initialize(hash)
      @id = hash[:id]
      @id_number = hash[:id_number]
      @real_name = hash[:id].to_s || "Unnamed"
      @can_surf = hash[:can_surf] || false
      @waterfall = hash[:waterfall] || false
      @waterfall_crest = hash[:waterfall_crest] || false
      @can_fish = hash[:can_fish] || false
      @can_dive = hash[:can_dive] || false
      @deep_bush = hash[:deep_bush] || false
      @shows_grass_rustle = hash[:shows_grass_rustle] || false
      @land_wild_encounters = hash[:land_wild_encounters] || false
      @double_wild_encounters = hash[:double_wild_encounters] || false
      @battle_environment = hash[:battle_environment]
      @ledge = hash[:ledge] || false
      @ice = hash[:ice] || false
      @waterCurrent = hash[:waterCurrent] || false
      @bridge = hash[:bridge] || false
      @shows_reflections = hash[:shows_reflections] || false
      @must_walk = hash[:must_walk] || false
      @ignore_passability = hash[:ignore_passability] || false
      @ignore_passability = hash[:ignore_passability] || false

      @flowerRed = hash[:flowerRed] || false
      @flowerYellow = hash[:flowerYellow] || false
      @flowerPink = hash[:flowerPink] || false
      @flowerBlue = hash[:flowerBlue] || false
      @flower = hash[:flower] || false
      @trashcan = hash[:trashcan] || false

      @acroBike = hash[:acroBike] || false
      @chair = hash[:chair] || false

      @sharpedoObstacle = hash[:chair] || false
      @underwater = hash[:underwater] || false

      @secretBase_tree = hash[:secretBase_tree] || false
      @secretBase_cave = hash[:secretBase_cave] || false
      @secretBase_bush = hash[:secretBase_bush] || false

    end

    def can_surf_freely
      return @can_surf && !@waterfall && !@waterfall_crest
    end

    def can_secret_base
      return false if Settings::GAME_ID != :IF_HOENN
      return @secretBase_tree || @secretBase_cave || @secretBase_bush
    end
  end
end

#===============================================================================

GameData::TerrainTag.register({
                                :id => :None,
                                :id_number => 0
                              })

GameData::TerrainTag.register({
                                :id => :Ledge,
                                :id_number => 1,
                                :ledge => true
                              })

GameData::TerrainTag.register({
                                :id => :Grass,
                                :id_number => 2,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Sand,
                                :id_number => 3,
                                :battle_environment => :Sand
                              })

GameData::TerrainTag.register({
                                :id => :Rock,
                                :id_number => 15,
                                :battle_environment => :Rock
                              })

GameData::TerrainTag.register({
                                :id => :DeepWater,
                                :id_number => 5,
                                :can_surf => true,
                                :can_fish => true,
                                :can_dive => true,
                                :battle_environment => :MovingWater
                              })

GameData::TerrainTag.register({
                                :id => :WaterCurrent,
                                :id_number => 6,
                                :can_surf => true,
                                :can_fish => true,
                                :waterCurrent => true,
                                :battle_environment => :MovingWater
                              })

GameData::TerrainTag.register({
                                :id => :Water,
                                :id_number => 7,
                                :can_surf => true,
                                :can_fish => true,
                                :battle_environment => :MovingWater
                              })

GameData::TerrainTag.register({
                                :id => :Waterfall,
                                :id_number => 8,
                                :can_surf => true,
                                :waterfall => true
                              })

GameData::TerrainTag.register({
                                :id => :WaterfallCrest,
                                :id_number => 9,
                                :can_surf => true,
                                :can_fish => true,
                                :waterfall_crest => true
                              })

GameData::TerrainTag.register({
                                :id => :TallGrass,
                                :id_number => 10,
                                :deep_bush => true,
                                :land_wild_encounters => true,
                                :double_wild_encounters => true,
                                :battle_environment => :TallGrass,
                                :must_walk => true
                              })

GameData::TerrainTag.register({
                                :id => :UnderwaterGrass,
                                :id_number => 11,
                                :underwater => true,
                                :land_wild_encounters => true
                              })

GameData::TerrainTag.register({
                                :id => :Ice,
                                :id_number => 12,
                                :battle_environment => :Ice,
                                :ice => true,
                                :must_walk => true
                              })

GameData::TerrainTag.register({
                                :id => :Neutral,
                                :id_number => 13,
                                :ignore_passability => true
                              })

# NOTE: This is referenced by ID in an Events.onStepTakenFieldMovement proc that
#       adds soot to the Soot Sack if the player walks over one of these tiles.
GameData::TerrainTag.register({
                                :id => :SootGrass,
                                :id_number => 14,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Bridge,
                                :id_number => 4,
                                :bridge => true
                              })

GameData::TerrainTag.register({
                                :id => :Puddle,
                                :id_number => 16,
                                :battle_environment => :Puddle,
                                :shows_reflections => false
                              })

GameData::TerrainTag.register({
                                :id => :FlowerRed,
                                :id_number => 17,
                                :flowerRed => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerYellow,
                                :id_number => 18,
                                :flowerYellow => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerPink,
                                :id_number => 19,
                                :flowerPink => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerBlue,
                                :id_number => 20,
                                :flowerBlue => true,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :FlowerOther,
                                :id_number => 21,
                                :flower => true
                              })
GameData::TerrainTag.register({
                                :id => :Trashcan,
                                :id_number => 22,
                                :trashcan => true
                              })

GameData::TerrainTag.register({
                                :id => :SharpedoObstacle,
                                :id_number => 23,
                                :sharpedoObstacle => true
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt1,
                                :id_number => 24,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt2,
                                :id_number => 25,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :Grass_alt3,
                                :id_number => 26,
                                :shows_grass_rustle => true,
                                :land_wild_encounters => true,
                                :battle_environment => :Grass
                              })

GameData::TerrainTag.register({
                                :id => :StillWater,
                                :id_number => 27,
                                :can_surf => true,
                                :can_fish => true,
                                :battle_environment => :StillWater,
                                :shows_reflections => true
                              })

GameData::TerrainTag.register({
                                :id => :Underwater,
                                :id_number => 28,
                                :battle_environment => :underwater,
                                :underwater => true,
                              })

GameData::TerrainTag.register({
                                :id => :Secretbase_Tree,
                                :id_number => 29,
                                :secretBase_tree => true,
                              })

GameData::TerrainTag.register({
                                :id => :Secretbase_Cave,
                                :id_number => 30,
                                :secretBase_cave => true,
                              })

GameData::TerrainTag.register({
                                :id => :Secretbase_Bush,
                                :id_number => 31,
                                :secretBase_bush => true,
                              })

GameData::TerrainTag.register({
                                :id => :Chair,
                                :id_number => 32,
                                :chair => true
                              })

GameData::TerrainTag.register({
                                :id => :Stairs,
                                :id_number => 33,
                                :must_walk => true
                              })

GameData::TerrainTag.register({
                                :id => :AcroBike,
                                :id_number => 34,
                                :acroBike => true,
                              })