class TrainerAppearance
  attr_accessor :skin_color
  attr_accessor :hat
  attr_accessor :clothes
  attr_accessor :hair

  attr_accessor :hair_color
  attr_accessor :clothes_color
  attr_accessor :hat_color

  def initialize(skin_color, hat, clothes, hair, hair_color = 0, clothes_color = 0, hat_color = 0)
    @skin_color = skin_color
    @hat = hat
    @clothes = clothes
    @hair = hair
    @hair_color = hair_color
    @clothes_color = clothes_color
    @hat_color = hat_color
  end
end

def getTypeExpertAppearance(trainer_type)
  return TYPE_EXPERTS_APPEARANCES[trainer_type]
end

TYPE_EXPERTS_APPEARANCES = {
  :TYPE_EXPERT_NORMAL => TrainerAppearance.new(5, "snorlaxhat", "normal", "1_painter", 0, 0, 0), #todo TEAM
  :TYPE_EXPERT_FIGHTING => TrainerAppearance.new(1, "karateHeadband", "fighting", "4_samurai", 0, 0, 0), #OK
  # TYPE_EXPERT_FLYING	=>#TODO NEEDS OUTFIT, LOCATION, TEAM
  :TYPE_EXPERT_POISON => TrainerAppearance.new(5, "parashroom", "deadlypoisondanger", "3_lowbraids", 270, 0, 0), #todo TEAM
  :TYPE_EXPERT_GROUND => TrainerAppearance.new(5, "sandshrewbeanie", "groundcowboy", "3_shortspike", 0, 0, 0), #todo TEAM
  # TYPE_EXPERT_ROCK	=>#TODO NEEDS OUTFIT, LOCATION, TEAM
  :TYPE_EXPERT_BUG => TrainerAppearance.new("0", "bugantenna", "bughakama", "3_hime", 60, 0,), #OK
  #:TYPE_EXPERT_GHOST	=>	TrainerAppearance.new(6,"duskullmask","gothhoodie","4_hime",0,0,0), #NO CLOTHES - DISABLED #TODO NEEDS OUTFIT, TEAM
  :TYPE_EXPERT_STEEL => TrainerAppearance.new(2, "veteranM", "steelworkerF", "4_highpony", 0, 0, 0), #todo TEAM
  :TYPE_EXPERT_FIRE => TrainerAppearance.new(4, "firefigther", "fire", "2_bob", 330, 0, 0), #todo  TEAM
  :TYPE_EXPERT_WATER => TrainerAppearance.new(5, "waterdress", "waterdress", "1_pixie", 180, 0, 0),
  # TYPE_EXPERT_GRASS	=>	TrainerAppearance.new("0","aerodactylSkull","red","","","")	, #TODO NEEDS OUTFIT, LOCATION, TEAM
  :TYPE_EXPERT_ELECTRIC => TrainerAppearance.new(3, "designerheadphones", "urbanelectric", "1_dancer", 10, 0, 0), #OK
  # TYPE_EXPERT_PSYCHIC	=># TODO NEEDS OUTFIT, LOCATION, TEAM
  :TYPE_EXPERT_ICE	=>	TrainerAppearance.new(6,"skierF","iceoutfit","1_wavy",0,0,210),
  :TYPE_EXPERT_DRAGON => TrainerAppearance.new(5, "aerodactylSkull", "dragonconqueror", "2_SpecialLatias", 670, 0, 510), #todo NEEDS LOCATION, TEAM
  # TYPE_EXPERT_DARK	=>  #TODO NEEDS OUTFIT, LOCATION, TEAM
  :TYPE_EXPERT_FAIRY => TrainerAppearance.new(6, "mikufairy", "mikufairyf", "5_mikufairy", 0, 0, 0) #OK
}

TYPE_EXPERT_TRAINERS = {
  :QMARK => ["name", "loseText"],
  :ELECTRIC => ["Ray", "What a shocking turn of events!"],
  :BUG => ["Bea", "I’m bugging out of here!"],
  :FAIRY => ["Luna", "You outshined me!"],
  :DRAGON => ["Draco", "I shall scale back my plans."],
  :FIGHTING => ["Floyd", "I have to throw in the towel."],
  :GROUND => ["Pedro", "I’m buried under this loss."],
  :FIRE => ["Blaze", "I guess I got burned out."],
  :GRASS => ["Ivy", "ou really cut me down to size!"],
  :ICE => ["Crystal", "I’m skating on thin ice!"],
  :ROCK => ["Slate", "Looks like I’ve hit rock bottom..."],
  :WATER => ["Marina", "You really made a splash!"],
  :FLYING => ["Gale", "I guess I’m grounded for now."],
  :DARK => ["Raven", "I’ll slip back into the shadows"],
  :STEEL => ["Silvia", "I guess I was a bit rusty..."],
  :PSYCHIC => ["Carl", "I could not foresee this defeat."],
  :GHOST => ["Evangeline", "I can feel myself disappearing into thin air!"],
  :POISON => ["Marie", "I got a taste of my own medicine!"],
  :NORMAL => ["Tim", "This was anything but normal!"],
}

TYPE_EXPERT_REWARDS = {
  :QMARK => [],
  :ELECTRIC => [CLOTHES_ELECTRIC],
  :BUG => [CLOTHES_BUG_1,CLOTHES_BUG_2],
  :FAIRY => [CLOTHES_FAIRY_F,CLOTHES_FAIRY_M],
  :DRAGON => [CLOTHES_DRAGON],
  :FIGHTING => [CLOTHES_FIGHTING],
  :GROUND => [CLOTHES_GROUND],
  :FIRE => [CLOTHES_FIRE],
  :GRASS => [CLOTHES_GRASS],
  :ICE => [CLOTHES_ICE],
  :ROCK => [CLOTHES_ROCK],
  :WATER => [CLOTHES_WATER],
  :FLYING => [CLOTHES_FLYING],
  :DARK => [CLOTHES_DARK],
  :STEEL => [CLOTHES_STEEL_F,CLOTHES_STEEL_M],
  :PSYCHIC => [CLOTHES_PSYCHIC],
  :GHOST => [CLOTHES_GHOST],
  :POISON => [CLOTHES_POISON],
  :NORMAL => [CLOTHES_NORMAL],
}

TOTAL_NB_TYPE_EXPERTS = 12
def type_expert_battle(type_id)
  type = GameData::Type.get(type_id)
  pbCallBub(2, @event_id)
  pbMessage("Ah! Can you feel the energy in here? This place is great for #{type.real_name}-Pokémon!")
  pbCallBub(2, @event_id)
  pbMessage("I'm what you could call an expert on #{type.real_name}-Pokémon. I've grown with them for all of my life.")
  pbCallBub(2, @event_id)
  pbMessage("I'll give you my \\C[5]special outfit\\C[0] if you can defeat my team using only #{type.real_name}-type Pokémon. ")
  pbCallBub(2, @event_id)
  if pbConfirmMessage("Do you think you can handle that?")
    pbCallBub(2, @event_id)
    pbMessage("Select your team! Remember, only #{type.real_name}-type Pokémon are allowed!")

    gym_randomizer_index = GYM_TYPES_CLASSIC.index(type_id)
    echoln gym_randomizer_index
    pbSet(VAR_CURRENT_GYM_TYPE, gym_randomizer_index)
    if PokemonSelection.choose(1, 4, true, true, proc { |poke| poke.hasType?(type_id) })
      #Level is equal to the highest level in player's party
      $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH]=true
      $game_switches[SWITCH_DONT_RANDOMIZE]=true

      pbSet(Settings::OVERRIDE_BATTLE_LEVEL_VALUE_VAR, $Trainer.highest_level_pokemon_in_party)
      trainer_class = "TYPE_EXPERT_#{type_id.to_s}".to_sym
      trainer_name = TYPE_EXPERT_TRAINERS[type_id][0]
      lose_text = TYPE_EXPERT_TRAINERS[type_id][1]
      if pbTrainerBattle(trainer_class, trainer_name, lose_text, false, 0, false)
        pbSet(VAR_TYPE_EXPERTS_BEATEN,pbGet(VAR_TYPE_EXPERTS_BEATEN)+1)
        pbCallBub(2, @event_id)
        pbMessage("Woah! You beat me at my own specialty! ")
        pbCallBub(2, @event_id)
        pbMessage("It's a true testament to your mastery of Pokémon typings!")
        pbCallBub(2, @event_id)
        pbMessage("Well then, I'll keep my word. You can have this very special outfit!")
        for clothes in TYPE_EXPERT_REWARDS[type_id]
          obtainClothes(clothes)
        end
        pbCallBub(2, @event_id)
        pbMessage("When you wear it, you can sometimes find #{type.real_name}-type related items after battles!")
        show_nb_type_experts_defeated()
        PokemonSelection.restore
        $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH]=false
        $game_switches[SWITCH_DONT_RANDOMIZE]=false
        pbSet(VAR_CURRENT_GYM_TYPE, -1)
        return true
      end
    else
      pbCallBub(2, @event_id)
      pbMessage("Remember, you're only allowed to use #{type.real_name}-type Pokémon!")
    end
  end
  PokemonSelection.restore
  $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH]=false
  $game_switches[SWITCH_DONT_RANDOMIZE]=false
  pbSet(VAR_CURRENT_GYM_TYPE, -1)
  return false
end

def show_nb_type_experts_defeated()
  pbMEPlay("Register phone")
  pbCallBub(3)
  Kernel.pbMessage("Type experts defeated: #{pbGet(VAR_TYPE_EXPERTS_BEATEN)}/#{TOTAL_NB_TYPE_EXPERTS}")
end