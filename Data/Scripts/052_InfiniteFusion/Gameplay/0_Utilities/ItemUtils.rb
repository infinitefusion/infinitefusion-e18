def Kernel.getPlateType(item)
  return :FIGHTING if item == PBItems::FISTPLATE
  return :FLYING if item == PBItems::SKYPLATE
  return :POISON if item == PBItems::TOXICPLATE
  return :GROUND if item == PBItems::EARTHPLATE
  return :ROCK if item == PBItems::STONEPLATE
  return :BUG if item == PBItems::INSECTPLATE
  return :GHOST if item == PBItems::SPOOKYPLATE
  return :STEEL if item == PBItems::IRONPLATE
  return :FIRE if item == PBItems::FLAMEPLATE
  return :WATER if item == PBItems::SPLASHPLATE
  return :GRASS if item == PBItems::MEADOWPLATE
  return :ELECTRIC if item == PBItems::ZAPPLATE
  return :PSYCHIC if item == PBItems::MINDPLATE
  return :ICE if item == PBItems::ICICLEPLATE
  return :DRAGON if item == PBItems::DRACOPLATE
  return :DARK if item == PBItems::DREADPLATE
  return :FAIRY if item == PBItems::PIXIEPLATE
  return -1
end

def Kernel.listPlatesInBag()
  list = []
  list << PBItems::FISTPLATE if $PokemonBag.pbQuantity(:FISTPLATE) >= 1
  list << PBItems::SKYPLATE if $PokemonBag.pbQuantity(:SKYPLATE) >= 1
  list << PBItems::TOXICPLATE if $PokemonBag.pbQuantity(:TOXICPLATE) >= 1
  list << PBItems::EARTHPLATE if $PokemonBag.pbQuantity(:EARTHPLATE) >= 1
  list << PBItems::STONEPLATE if $PokemonBag.pbQuantity(:STONEPLATE) >= 1
  list << PBItems::INSECTPLATE if $PokemonBag.pbQuantity(:INSECTPLATE) >= 1
  list << PBItems::SPOOKYPLATE if $PokemonBag.pbQuantity(:SPOOKYPLATE) >= 1
  list << PBItems::IRONPLATE if $PokemonBag.pbQuantity(:IRONPLATE) >= 1
  list << PBItems::FLAMEPLATE if $PokemonBag.pbQuantity(:FLAMEPLATE) >= 1
  list << PBItems::SPLASHPLATE if $PokemonBag.pbQuantity(:SPLASHPLATE) >= 1
  list << PBItems::MEADOWPLATE if $PokemonBag.pbQuantity(:MEADOWPLATE) >= 1
  list << PBItems::ZAPPLATE if $PokemonBag.pbQuantity(:ZAPPLATE) >= 1
  list << PBItems::MINDPLATE if $PokemonBag.pbQuantity(:MINDPLATE) >= 1
  list << PBItems::ICICLEPLATE if $PokemonBag.pbQuantity(:ICICLEPLATE) >= 1
  list << PBItems::DRACOPLATE if $PokemonBag.pbQuantity(:DRACOPLATE) >= 1
  list << PBItems::DREADPLATE if $PokemonBag.pbQuantity(:DREADPLATE) >= 1
  list << PBItems::PIXIEPLATE if $PokemonBag.pbQuantity(:PIXIEPLATE) >= 1
  return list
end

def getArceusPlateType(heldItem)
  return :NORMAL if heldItem == nil
  case heldItem
  when :FISTPLATE
    return :FIGHTING
  when :SKYPLATE
    return :FLYING
  when :TOXICPLATE
    return :POISON
  when :EARTHPLATE
    return :GROUND
  when :STONEPLATE
    return :ROCK
  when :INSECTPLATE
    return :BUG
  when :SPOOKYPLATE
    return :GHOST
  when :IRONPLATE
    return :STEEL
  when :FLAMEPLATE
    return :FIRE
  when :SPLASHPLATE
    return :WATER
  when :MEADOWPLATE
    return :GRASS
  when :ZAPPLATE
    return :ELECTRIC
  when :MINDPLATE
    return :PSYCHIC
  when :ICICLEPLATE
    return :ICE
  when :DRACOPLATE
    return :DRAGON
  when :DREADPLATE
    return :DARK
  when :PIXIEPLATE
    return :FAIRY
  else
    return :NORMAL
  end
end

def hasFishingRod()
  return hasItem?(:OLDROD) || hasItem?(:GOODROD) || hasItem?(:SUPERROD)
end


def list_all_item_names()
  names = []
  GameData::Item.list_all.each do |item|
    names << item[1].name
  end
  return names
end

def hasItem?(item)
  return $PokemonBag.pbQuantity(item) >= 1
end