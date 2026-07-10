#set outfit ids,
#

CLOTHES_NORMAL   = "normal"

CLOTHES_FIGHTING = "fighting"

CLOTHES_FLYING   = "flying"

CLOTHES_POISON   = "deadlypoisondanger"

CLOTHES_GROUND   = "groundcowboy"

CLOTHES_ROCK     = "temp"

CLOTHES_BUG_1      = "bughakama"
CLOTHES_BUG_2      = "bughakamapants"

CLOTHES_GHOST    = "ghostoutfit"

CLOTHES_STEEL_M    = "steelworkerM"
CLOTHES_STEEL_F    = "steelworkerF"

CLOTHES_FIRE     = "fire"

CLOTHES_WATER    = "waterdress"
CLOTHES_WATER_NEUTRAL    = "waterneutral"

CLOTHES_GRASS    = "grassexpert"

CLOTHES_ELECTRIC = "urbanelectric"

CLOTHES_PSYCHIC_M  = "psyshamanm"
CLOTHES_PSYCHIC_F  = "psyshamanf"

CLOTHES_ICE      = "iceoutfit"

CLOTHES_DRAGON   = "dragonconqueror"

CLOTHES_DARK     = "darkoutfit"

CLOTHES_FAIRY_M    = "mikufairym"
CLOTHES_FAIRY_F    = "mikufairyf"




NORMAL_ITEMS   = [:NORMALGEM,:MOOMOOMILK,:POTION,:FULLHEAL,:CHILANBERRY,]
FIGHTING_ITEMS = [:FIGHTINGGEM,:PROTEIN,:CHOPLEBERRY,]
FLYING_ITEMS   = [:FLYINGGEM,:HEALTHWING,:MUSCLEWING,:RESISTWING,:GENIUSWING,:CLEVERWING,:SWIFTWING,:AIRBALLOON,:PRETTYWING,:COBABERRY, ]
POISON_ITEMS   = [:POISONGEM,:ANTIDOTE, :KEBIABERRY, ]
GROUND_ITEMS   = [:GROUNDGEM,:SHUCABERRY, ]
ROCK_ITEMS     = [:ROCKGEM, :STARDUST,:CHARTIBERRY, ]
BUG_ITEMS      = [:BUGGEM,:HONEY,:TANGABERRY, ]
GHOST_ITEMS    = [:GHOSTGEM,:KASIBBERRY,]
STEEL_ITEMS    = [:STEELGEM,:BABIRIBERRY,:METALPOWDER,]
FIRE_ITEMS     = [:FIREGEM,:LAVACOOKIE,:BURNHEAL,:OCCABERRY, ]
WATER_ITEMS    = [:WATERGEM,:HEARTSCALE,:PEARL,:PASSHOBERRY ]
GRASS_ITEMS    = [:GRASSGEM,:LUMBERRY,:ORANBERRY,:SITRUSBERRY,:GRASSYSEED,:ABSORBBULB,:TINYMUSHROOM, :RINDOBERRY, ]
ELECTRIC_ITEMS = [:ELECTRICGEM,:ELECTRICSEED,:PARLYZHEAL,:CELLBATTERY,:WACANBERRY, ]
PSYCHIC_ITEMS  = [:PSYCHICGEM,:PSYCHICSEED, :MENTALHERB, :PAYAPABERRY,]
ICE_ITEMS      = [:ICEGEM,:SNOWBALL,:ICEHEAL,:YACHEBERRY, ]
DRAGON_ITEMS   = [:DRAGONGEM,:HABANBERRY, ]
DARK_ITEMS     = [:DARKGEM,:COLBURBERRY, ]
FAIRY_ITEMS    = [:FAIRYGEM,:MISTYSEED, ]


def isWearingElectricOutfit()
  return (isWearingClothes(CLOTHES_ELECTRIC))
end

def isWearingNormalOutfit()
  return (isWearingClothes(CLOTHES_NORMAL))
end

def isWearingFightingOutfit()
  return (isWearingClothes(CLOTHES_FIGHTING))
end

def isWearingFlyingOutfit()
  return (isWearingClothes(CLOTHES_FLYING))
end

def isWearingPoisonOutfit()
  return (isWearingClothes(CLOTHES_POISON))
end

def isWearingGroundOutfit()
  return (isWearingClothes(CLOTHES_GROUND))
end

def isWearingRockOutfit()
  return (isWearingClothes(CLOTHES_ROCK))
end

def isWearingBugOutfit()
  return ((isWearingClothes(CLOTHES_BUG_1) || isWearingClothes(CLOTHES_BUG_2)))
end

def isWearingGhostOutfit()
  return (isWearingClothes(CLOTHES_GHOST))
end

def isWearingSteelOutfit()
  return ((isWearingClothes(CLOTHES_STEEL_M) || isWearingClothes(CLOTHES_STEEL_F)))
end

def isWearingFireOutfit()
  return (isWearingClothes(CLOTHES_FIRE))
end

def isWearingWaterOutfit()
  return (isWearingClothes(CLOTHES_WATER) || isWearingClothes(CLOTHES_WATER_NEUTRAL))
end

def isWearingGrassOutfit()
  return (isWearingClothes(CLOTHES_GRASS))
end

def isWearingPsychicOutfit()
  return ((isWearingClothes(CLOTHES_PSYCHIC_M) || isWearingClothes(CLOTHES_PSYCHIC_F)))
end

def isWearingIceOutfit()
  return (isWearingClothes(CLOTHES_ICE))
end

def isWearingDragonOutfit()
  return (isWearingClothes(CLOTHES_DRAGON))
end

def isWearingDarkOutfit()
  return (isWearingClothes(CLOTHES_DARK))
end

def isWearingFairyOutfit()
  return ((isWearingClothes(CLOTHES_FAIRY_M) || isWearingClothes(CLOTHES_FAIRY_F)))
end


def isWearingNurseOutfit()
  return (isWearingClothes(CLOTHES_NURSE))
end

def nurseOutfitHeal
  if isWearingNurseOutfit()
    $Trainer.party.each do |pokemon|
      next if pokemon.fainted?
      new_hp = pokemon.hp + (pokemon.totalhp/16)
      if new_hp > pokemon.totalhp
        pokemon.hp=pokemon.totalhp
      else
        pokemon.hp=new_hp
      end
    end
  end
end

def pickUpTypeItemSetBonus()
  return if rand(10) != 0
  items_list = if isWearingElectricOutfit()
                 ELECTRIC_ITEMS
               elsif isWearingNormalOutfit()
                 NORMAL_ITEMS
               elsif isWearingFightingOutfit()
                 FIGHTING_ITEMS
               elsif isWearingFlyingOutfit()
                 FLYING_ITEMS
               elsif isWearingPoisonOutfit()
                 POISON_ITEMS
               elsif isWearingGroundOutfit()
                 GROUND_ITEMS
               elsif isWearingRockOutfit()
                 ROCK_ITEMS
               elsif isWearingBugOutfit()
                 BUG_ITEMS
               elsif isWearingGhostOutfit()
                 GHOST_ITEMS
               elsif isWearingSteelOutfit()
                 STEEL_ITEMS
               elsif isWearingFireOutfit()
                 FIRE_ITEMS
               elsif isWearingWaterOutfit()
                 WATER_ITEMS
               elsif isWearingGrassOutfit()
                 GRASS_ITEMS
               elsif isWearingPsychicOutfit()
                 PSYCHIC_ITEMS
               elsif isWearingIceOutfit()
                 ICE_ITEMS
               elsif isWearingDragonOutfit()
                 DRAGON_ITEMS
               elsif isWearingDarkOutfit()
                 DARK_ITEMS
               elsif isWearingFairyOutfit()
                 FAIRY_ITEMS
               else
                 []
               end
  if !items_list.empty?
    Kernel.pbItemBall(items_list.sample)
  end
end

