# todo: Also do trainer class specific items.
# e.g. Rich boy can give luxury ball
#

TRAINER_REMATCH_GIFTS = {
  # 2 tiers of gift.
  # common, rare
  # Odds depend on friendship level
  #
  # [[Tier 1], [Tier 2]]
  :NORMAL => [[:CHILANBERRY, :POTION, :FULLHEAL],
              [:HPUP, :PPUP]],
  :FIGHTING => [[:CHOPLEBERRY,],
                [:IRON, :CALCIUM]],
  :FLYING => [[:COBABERRY, :PRETTYWING,],
              [:RAZORFANG]],
  :POISON => [[:KEBIABERRY, :ANTIDOTE],
              [:POISONBARB,],
              []],
  :GROUND => [[:SHUCABERRY,],
              [:SOFTSAND,]],
  :ROCK => [[:CHARTIBERRY, :HARDSTONE],
            [:STARDUST, :PROTECTOR]],
  :BUG => [[:TANGABERRY, :HONEY],
           [:BIGMUSHROOM]],
  :GHOST => [[:KASIBBERRY,],
             [:REAPERCLOTH]],
  :STEEL => [[:BABIRIBERRY,],
             [:METALCOAT, :METALPOWDER, :IRON]],
  :FIRE => [[:BURNHEAL, :OCCABERRY],
            [:FIRESTONE, :LAVACOOKIE]],
  :WATER => [[:PASSHOBERRY, :HEARTSCALE, :LUREBALL],
             [:PEARL, :WATERSTONE]],
  :GRASS => [[:RINDOBERRY, :TINYMUSHROOM],
             [:LEAFSTONE]],
  :ELECTRIC => [[:PARLYZHEAL, :WACANBERRY],
                [:THUNDERSTONE]],
  :PSYCHIC => [[:PAYAPABERRY],
               [:MENTALHERB]],
  :ICE => [[:YACHEBERRY, :ICEHEAL],
           [:ICESTONE, :SNOWBALL]],
  :DRAGON => [[:HABANBERRY],
              [:DRAGONSCALE]],
  :DARK => [[:COLBURBERRY],
            [:RAZORCLAW]],
  :FAIRY => [[:ROSELIBERRY],
             [:WHIPPEDDREAM, :MOONSTONE]],

  :ANY => [:DNASPLICERS, :DNAREVERSER, :REPEL, :POTION, :SUPERPOTION, :GREATBALL, :FRESHWATER]
}

TRAINER_REMATCH_SPECIFIC_GIFTS = {
  :RICHBOY => [[:LUXURYBALL], [:NUGGET]],
  :LADY => [[:LUXURYBALL], [:NUGGET]],
  :GENTLEMAN => [[:LUXURYBALL], [:NUGGET]],

  :HIKER => [[:TINYMUSHROOM, :REPEL], [:BIGMUSHROOM]],
  :CRUSHGIRL => [[:XSPEED], [:CARBOS]],
  :BLACKBELT => [[:XATTACK], [:PROTEIN]],
  :NURSE => [[:HEALBALL, :SUPERPOTION], [:FULLRESTORE]],

  :ROCKER => [[:PARLYZHEAL], [:THUNDERSTONE]],
  :SAILOR => [[:LUREBALL], [:PEARL, :WATERSTONE]],
  :FISHERMAN => [[:LUREBALL], [:PEARL, :WATERSTONE]],
  :AROMALADY => [[:PINKNECTAR, :REDNECTAR, :YELLOWNECTAR, :BLUENECTAR], [:LEAFSTONE]],
  :TRIATHLETE_BIKE_F => [[:FRESHWATER], [:FRESHWATER]],
  :TRIATHLETE_BIKE_M => [[:FRESHWATER], [:FRESHWATER]],
}

def should_find_item(trainer)
  base_rate = 30 # percent
  return rand(100) < base_rate
end

def should_give_item(trainer)
  return false unless trainer.friendship_level >= 2
  return false if trainer.inventory.empty?
  base_rate = 30 # percent
  item_chances = base_rate + (trainer.friendship / 10).floor
  return rand(100) < item_chances
end

def find_random_trainer_item(trainer)
  rare_item_chances = 5 + (trainer.friendship / 5).floor
  chance_trainer_class_item = 40

  giving_rare_item = rand(100) < rare_item_chances
  typed_items = TRAINER_REMATCH_GIFTS[trainer.favorite_type]

  items_list = typed_items
  items_list[0] += trainer.inventory

  if TRAINER_REMATCH_SPECIFIC_GIFTS.has_key?(trainer.trainerType) && rand(100) < chance_trainer_class_item
    items_list = TRAINER_REMATCH_GIFTS[trainer.trainerType] if TRAINER_REMATCH_GIFTS[trainer.trainerType]
  end
  if giving_rare_item
    return items_list[1].sample
  else
    items = items_list[0] + TRAINER_REMATCH_GIFTS[:ANY]
    return items.sample
  end
end

def select_gift_item(trainer)
  return nil unless trainer.inventory
  return trainer.inventory.sample
end
