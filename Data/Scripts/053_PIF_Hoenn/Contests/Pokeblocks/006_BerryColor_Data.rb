module GameData
  class PokeblockColor
    attr_reader :id
	attr_reader :sort_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        	= hash[:id]
      @sort_number 	= hash[:sort_number]
      @real_name 	= hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this body color
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::PokeblockColor.register({
  :id   		=> :Red,
  :sort_number 	=> 1,
  :name 		=> _INTL("Red")
})

GameData::PokeblockColor.register({
  :id   		=> :Blue,
  :sort_number 	=> 2,
  :name 		=> _INTL("Blue")
})

GameData::PokeblockColor.register({
  :id   		=> :Pink,
  :sort_number 	=> 3,
  :name 		=> _INTL("Pink")
})

GameData::PokeblockColor.register({
  :id   		=> :Green,
  :sort_number 	=> 4,
  :name 		=> _INTL("Green")
})

GameData::PokeblockColor.register({
  :id   		=> :Yellow,
  :sort_number 	=> 5,
  :name 		=> _INTL("Yellow")
})

GameData::PokeblockColor.register({
  :id   		=> :Purple,
  :sort_number 	=> 6,
  :name 		=> _INTL("Purple")
})

GameData::PokeblockColor.register({
  :id   		=> :Indigo,
  :sort_number 	=> 7,
  :name 		=> _INTL("Indigo")
})

GameData::PokeblockColor.register({
  :id   		=> :Brown,
  :sort_number 	=> 8,
  :name 		=> _INTL("Brown")
})

GameData::PokeblockColor.register({
  :id   		=> :LiteBlue,
  :sort_number 	=> 9,
  :name 		=> _INTL("LiteBlue")
})

GameData::PokeblockColor.register({
  :id   		=> :Olive,
  :sort_number 	=> 10,
  :name 		=> _INTL("Olive")
})

GameData::PokeblockColor.register({
  :id   		=> :Gold,
  :sort_number 	=> 11,
  :name 		=> _INTL("Gold")
})

GameData::PokeblockColor.register({
  :id   		=> :Gray,
  :sort_number 	=> 12,
  :name 		=> _INTL("Gray")
})

GameData::PokeblockColor.register({
  :id   		=> :White,
  :sort_number 	=> 13,
  :name 		=> _INTL("White")
})

GameData::PokeblockColor.register({
  :id   		=> :Black,
  :sort_number 	=> 99,
  :name 		=> _INTL("Black")
})

GameData::PokeblockColor.register({
  :id   		=> :Rainbow,
  :sort_number 	=> 15,
  :name 		=> _INTL("Rainbow")
})