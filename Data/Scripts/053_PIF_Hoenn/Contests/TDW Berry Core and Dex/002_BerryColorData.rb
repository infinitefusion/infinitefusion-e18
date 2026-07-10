#===============================================================================
# Data
#=============================================================================== 

module GameData
    class BerryColor
        attr_reader :id
        attr_reader :real_name
        attr_reader :base_color
        attr_reader :shadow_color
    
        DATA = {}
    
        extend ClassMethodsSymbols
        include InstanceMethods
    
        def self.load; end
        def self.save; end
    
        def initialize(hash)
            @id        	= hash[:id]
            @real_name 	= hash[:name] || "Unnamed"
            @base_color 	= hash[:base_color]
            @shadow_color	= hash[:shadow_color]
        end
    
        # @return [String] the translated name of this body color
        def name
            return _INTL(@real_name)
        end
    end
end
  
#===============================================================================
# Definitions
#=============================================================================== 
 
GameData::BerryColor.register({
    :id   => :Red,
    :name => _INTL("Red"),
    :base_color => rgbToColor("E82010"),
    :shadow_color =>  rgbToColor("F8A8B8")
})

GameData::BerryColor.register({
    :id   => :Yellow,
    :name => _INTL("Yellow"),
    :base_color => rgbToColor("E8D020"),
    :shadow_color =>  rgbToColor("F8E888")
})

GameData::BerryColor.register({
    :id   => :Green,
    :name => _INTL("Green"),
    :base_color => rgbToColor("60B048"),
    :shadow_color =>  rgbToColor("B0D090")
})

GameData::BerryColor.register({
    :id   => :Blue,
    :name => _INTL("Blue"),
    :base_color => rgbToColor("0070F8"),
    :shadow_color =>  rgbToColor("78B8E8")
})

GameData::BerryColor.register({
    :id   => :Purple,
    :name => _INTL("Purple"),
    :base_color => rgbToColor("9040E8"),
    :shadow_color =>  rgbToColor("B8A8E0")
})

GameData::BerryColor.register({
    :id   => :Pink,
    :name => _INTL("Pink"),
    :base_color => rgbToColor("D038B8"),
    :shadow_color =>  rgbToColor("E8A0E0")
})