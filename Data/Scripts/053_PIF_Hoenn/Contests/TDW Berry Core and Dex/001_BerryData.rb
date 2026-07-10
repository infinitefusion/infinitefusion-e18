#===============================================================================
# Data
#=============================================================================== 
module GameData
    class BerryData
        attr_reader :id
        # attr_reader :dex_number
        attr_reader :size
        attr_reader :firmness
        attr_reader :flavor
        attr_reader :smoothness
        attr_reader :color
        attr_reader :block_color
        attr_reader :description
        attr_reader :preferred_weather
    
        DATA = {}
        DATA_FILENAME = "berry_data.dat"
    
        SCHEMA = {
            # "DexNumber" 	    => [:dex_number, "i"],
            "Size"              => [:size, "f"],
            "Firmness"          => [:firmness, "q"],
            "Flavor" 		    => [:flavor, "uuuuu"],
            "Smoothness" 	    => [:smoothness, "u"],
            "Color"      	    => [:color, "e", :BerryColor],
            "BlockColor"	    => [:block_color, "e", :BerryColor],
            "Description"       => [:description, "q"],
            "PreferredWeather"	=> [:preferred_weather, "*e", :Weather]
        }
  
        extend ClassMethodsSymbols
        include InstanceMethods
    
        def initialize(hash)
            @id              	= hash[:id]
            # @dex_number        	= hash[:dex_number]
            @size              	= hash[:size] || 0.0
            @firmness           = hash[:firmness] || "???"
            @flavor 			= hash[:flavor] || {}
            @smoothness 		= hash[:smoothness] || 20
            @color 			    = hash[:color] || :Red
            @block_color 		= hash[:block_color] || @color 
            @description        = hash[:description] || "???"
            @preferred_weather  = hash[:preferred_weather] || []
        end
        
        # def dex; return @dex_number; end
        def size; return @size; end
        def spicy; return @flavor["Spicy"]; end
        def dry; return @flavor["Dry"]; end
        def sweet; return @flavor["Sweet"]; end
        def bitter; return @flavor["Bitter"]; end
        def sour; return @flavor["Sour"]; end
        def smooth; return @smoothness; end
        def color_name; return GameData::BerryColor.get(@color).name; end
        def block_color_name; return GameData::BerryColor.get(@block_color).name; end

        def description
            return pbGetMessageFromHash(MessageTypes::BerryDexDescriptions, @description)
        end
        def firmness
             return pbGetMessageFromHash(MessageTypes::BerryDexFirmness, @firmness)
        end
  
        def calculatedFlavor
            posArr = [spicy,dry,sweet,bitter,sour]
            negArr = posArr.clone
            negArr.push(negArr.shift)
            compArr = []
            5.times { |i|
                compArr.push(posArr[i] - negArr[i])
            }
            return [posArr,compArr]
        end
      
        def plusProbability # NOTE: TODO When generalizing and fixing pokeblock script, remove this and make sure is kept in pokeblock BerryData
            prob = [1,5,15,25,40,100]
            PokeblockSettings::SIMPLE_POKEBLOCK_PLUS_PROBABILITY.each_with_index { |(key,value),index|
                return prob[index] if value.include?(self.id)			
            }
            return 1
        end
    end
    
    GameData.singleton_class.send(:alias_method, :berry_core_data_loadall, :load_all)
    def self.load_all
        berry_core_data_loadall
        BerryData.load
    end
  end

module MessageTypes
	BerryDexDescriptions    = 45
	BerryDexFirmness        = 46
end