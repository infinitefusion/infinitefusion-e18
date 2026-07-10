#Purchasable from pokemart.
CARD_BACKGROUND_DEFAULT_PURCHASABLE = [
  "BLUE",
  "PLAIN_BLUE",
  "GREEN",
  "PLAIN_GREEN",
  "RED",
  "PURPLE",
  "BLACK",
  "BRONZE",
  "SILVER",
  "GOLD",
]

#Purchasable, but not from pokemart.
# a special npc somewhere.
CARD_BACKGROUND_CITY_EXCLUSIVES = {
  "GRAYPOLY" => :PEWTER,

  "HEARTMAIL" => :CERULEAN,
  "MAGIKARP_JUMP" => :CERULEAN,

  "PIKACHU" => :VERMILLION,
  "OMG" => :VERMILLION,

  "SPOOKY_FOREST" => :LAVENDER,

  "EEVEELUTION" => :CELADON,
  "RAINBOWMAIL" => :CELADON,
  "SEWERS" => :CELADON,

  "CACTI" => :FUCHSIA,
  "EEVEE_SLEEP" => :FUCHSIA,

  "GALAXYMAIL" => :SAFFRON,
  "FIGHTING_HANDSHAKE" => :SAFFRON,

  "CINNABAR" => :CINNABAR,

  "SPHEAL_MOON" => :CRIMSON,

  "EEVEE_FLOWERS" => :KNOTISLAND,
  "DESERT_SUNSET" => :KNOTISLAND,
  "ROCKRUFF_EVO" => :KNOTISLAND,

  "TOTODILE_BEACH" => :BOONISLAND,

  "HAMMOCK" => :KINISLAND,

  "SLEEPY_CAMERUPT" => :CHRONOISLAND,

  "ILLUSION" => :GOLDENROD,
  "BABIES" => :GOLDENROD,

  "MUSHROOM_FOREST" => :AZALEA,

  "NATIONAL_PARK" => :VIOLET,
  "ROCKRUFF_FLOWERS" => :VIOLET,

  "CRANIDOS_PARK" => :BLACKTHORN,


  "CAMPFIRE" => :MAHOGANY,
  "MOON_LAKE" => :MAHOGANY,
  "STILL_LIFE" => :MAHOGANY,
  "MOUNTAIN_NIGHT" => :MAHOGANY,


  "SPOOKY_ATTIC" => :ECRUTEAK,
  "UNDERDOG" => :ECRUTEAK,



}

#purchasable from pokemart after unlocking a
# certain switch
#flag => switch to unlock
CARD_BACKGROUND_UNLOCKABLES = {

  #Unobtainable Pokemon team flags:
  # Move these to the /flags folder if the Pokemon become implemented into the game
  "SHIINOTIC_FLAG" =>  SWITCH_ALOLA_HAIR_COLLECTION,


  "MALAMAR_FLAG" =>  SWITCH_KALOS_HAIR_COLLECTION,
  "MUNNA_FLAG" =>  SWITCH_UNOVA_HAIR_COLLECTION,
  "MUSHARNA_FLAG" =>  SWITCH_UNOVA_HAIR_COLLECTION,

  "NUMEL_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "SEALEO_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "SPHEAL_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "SPINDA_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "SKITTY_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "TROPIUS_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,
  "WINGULL_FLAG" =>  SWITCH_HOENN_HAIR_COLLECTION,


  #Unlockables
  "BLASTOISE" => SWITCH_BEAT_THE_LEAGUE,
  "CHARIZARD" => SWITCH_BEAT_THE_LEAGUE,
  "VENUSAUR" => SWITCH_BEAT_THE_LEAGUE,
  "COMPUTER_HILLS" => SWITCH_BEAT_THE_LEAGUE,
  "GAMEBOY_FUSIONS" => SWITCH_BEAT_THE_LEAGUE,

  "GROUDON" => SWITCH_HOENN_HAIR_COLLECTION,
  "KYOGRE" => SWITCH_HOENN_HAIR_COLLECTION,
  "RAYQUAZA" => SWITCH_HOENN_HAIR_COLLECTION,
  "HOENN_GREETINGS " => SWITCH_HOENN_HAIR_COLLECTION,
  "RUBY" => SWITCH_HOENN_HAIR_COLLECTION,
  "SAPPHIRE" => SWITCH_HOENN_HAIR_COLLECTION,
  "EMERALD" => SWITCH_HOENN_HAIR_COLLECTION,
  "BARS-BOACH" => SWITCH_HOENN_HAIR_COLLECTION,
  "RIVALS" => SWITCH_HOENN_HAIR_COLLECTION,


  "WEATHER_WAR" => SWITCH_BEAT_MT_SILVER,
  "HOENN_STARTERS" => SWITCH_BEAT_MT_SILVER,
  "GROUDON_FUSION" => SWITCH_BEAT_MT_SILVER ,
  "KYOGRE_FUSION" => SWITCH_BEAT_MT_SILVER ,
  "HOENN_CREDITS" => SWITCH_BEAT_MT_SILVER ,
  "CYNTHIA" => SWITCH_BEAT_MT_SILVER ,
  "TIME_GEAR" => SWITCH_BEAT_MT_SILVER ,
  "RAYQUAZA_PATTERN" => SWITCH_BEAT_MT_SILVER,

  "ARCEUS_COSMIC_STEPS" => SWITCH_FINISHED_ARCEUS_EVENT ,
  "ARCEUS_SILVALLY" => SWITCH_FINISHED_ARCEUS_EVENT ,
  "ARCEUS_SYMBOL" => SWITCH_FINISHED_ARCEUS_EVENT ,


  "RESHIRAM" => SWITCH_UNOVA_HAIR_COLLECTION,
  "ZEKROM" => SWITCH_UNOVA_HAIR_COLLECTION,
  "MUNNA_PATTERN" => SWITCH_UNOVA_HAIR_COLLECTION,


  "ZYGARDE_PATTERN" => SWITCH_KALOS_HAIR_COLLECTION,

  "DUEL" => SWITCH_PALDEA_HAIR_COLLECTION,
  "AKALA_ISLAND" => SWITCH_ALOLA_HAIR_COLLECTION,


  "DARKRAI" => SWITCH_CAUGHT_DARKRAI,
  "MOONLIGHT_BALL" => SWITCH_CAUGHT_MELOETTA,
  "DIANCIE_CARBINK" => SWITCH_PINKAN_FINISHED,

  "ROCKET_LOGO" => SWITCH_FINISHED_ROCKET_QUESTS_CERULEAN,
  "MEOWTH_ROCKET" => SWITCH_FINISHED_ROCKET_QUESTS_CELADON,
  "ROCKET_JAMES_INKAY" => SWITCH_PINKAN_FINISHED,

  "BOULDERBADGE" => SWITCH_GOT_BADGE_1,
  "CASCADEBADGE" => SWITCH_GOT_BADGE_2,
  "THUNDERBADGE" => SWITCH_GOT_BADGE_3,
  "RAINBOWBADGE" => SWITCH_GOT_BADGE_4,
  "SOULBADGE" => SWITCH_GOT_BADGE_5,
  "MARSHBADGE" => SWITCH_GOT_BADGE_6,
  "VOLCANOBADGE" => SWITCH_GOT_BADGE_7,
  "EARTHBADGE" => SWITCH_GOT_BADGE_8,
  "PLAINBADGE" => SWITCH_GOT_BADGE_9,
  "HIVEBADGE" => SWITCH_GOT_BADGE_10,
  "ZEPHYRBADGE" => SWITCH_GOT_BADGE_11,
  "RISINGBADGE" => SWITCH_GOT_BADGE_12,
  "FOGBADGE" => SWITCH_GOT_BADGE_13,
  "GLACIERBADGE" => SWITCH_GOT_BADGE_14,
  "STORMBADGE" => SWITCH_GOT_BADGE_15,
  "MINERALBADGE" => SWITCH_GOT_BADGE_16,
}

def unlock_card_background(id)
  $Trainer.unlocked_card_backgrounds = [] if !$Trainer.unlocked_card_backgrounds
  $Trainer.unlocked_card_backgrounds << id
end

def getDisplayedName(card_id)
  return card_id.downcase.gsub('_', ' ').gsub('flags/', 'Team ').split.map(&:capitalize).join(' ')
end



def purchaseCardBackground(price = 1000)
  $Trainer.unlocked_card_backgrounds = [] if ! $Trainer.unlocked_card_backgrounds
  purchasable_cards = []
  current_city = pbGet(VAR_CURRENT_CITY)
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  for card in CARD_BACKGROUND_CITY_EXCLUSIVES.keys
    purchasable_cards << card if current_city == CARD_BACKGROUND_CITY_EXCLUSIVES[card] && !$Trainer.unlocked_card_backgrounds.include?(card)
  end
  for card in CARD_BACKGROUND_DEFAULT_PURCHASABLE
    purchasable_cards << card if !$Trainer.unlocked_card_backgrounds.include?(card)
  end
  for card in CARD_BACKGROUND_UNLOCKABLES.keys
    purchasable_cards << card if $game_switches[CARD_BACKGROUND_UNLOCKABLES[card]] && !$Trainer.unlocked_card_backgrounds.include?(card)
  end

  echoln $Trainer.unlocked_card_backgrounds

  if purchasable_cards.length <= 0
    pbMessage(_INTL("There are no more Trainer Card backgrounds available for purchase!"))
    return
  end

  commands = []
  index = 0
  for card in purchasable_cards
    index += 1
    name = getDisplayedName(card)
    commands.push([index, name, card])
  end
  pbMessage(_INTL("\\GWhich background would you like to purchase?"))
  chosen = pbListScreen(_INTL("Trainer card"), TrainerCardBackgroundLister.new(purchasable_cards))
  echoln chosen
  if chosen != nil
    name = getDisplayedName(chosen)
    if pbConfirmMessage(_INTL("\\GPurchase the \\C[1]{1} Trainer Card background\\C[0] for ${2}?", name, price.to_s))
      if $Trainer.money < price
        pbSEPlay("GUI sel buzzer", 80)
        pbMessage(_INTL("\\G\\C[2]Insufficient funds"))
        return false
      end
      pbSEPlay("Mart buy item")
      $Trainer.money -= price
      unlock_card_background(chosen)
      pbMEPlay("Item get")
      pbMessage(_INTL("\\GYou purchased the {1} Trainer Card background!", name))
      if pbConfirmMessage(_INTL("Would you like to swap your current Trainer Card for the newly purchased one?"))
        pbSEPlay("GUI trainer card open")
        $Trainer.card_background = chosen
      else
        pbMessage(_INTL("You can swap the background at anytime when viewing your Trainer Card."))
      end
      echoln $Trainer.unlocked_card_backgrounds
      return true
    end
  else
    pbSEPlay("computerclose")
  end
end

class TrainerCardBackgroundLister
  BASE_TRAINER_CARD_PATH = "Graphics/Pictures/Trainer Card/backgrounds"

  def initialize(cardsList)
    @sprite = SpriteWrapper.new
    @sprite.bitmap = nil
    @sprite.x = 250
    @sprite.y = 100
    @sprite.z = -2
    @sprite.zoom_x = 0.5
    @sprite.zoom_y = 0.5

    @frame = SpriteWrapper.new
    @frame.bitmap = AnimatedBitmap.new("Graphics/Pictures/Trainer Card/overlay").bitmap
    @frame.x = 250
    @frame.y = 100
    @frame.z = -2
    @frame.zoom_x = 0.5
    @frame.zoom_y = 0.5

    @commands = []
    @cardsList = cardsList
    @index = 0
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
    @frame.bitmap.dispose if @sprite.bitmap
    @frame.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
    @frame.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    for i in 0...@cardsList.length
      card_id = @cardsList[i]
      card_name = getDisplayedName(@cardsList[i])
      @commands.push(card_name)
    end
    @commands << _INTL("Cancel")
    return @commands
  end

  def value(index)
    return nil if index < 0
    return nil if index == @commands.length
    return @cardsList[index]
  end

  def refresh(index)
    return if index >= @cardsList.length
    return if index < 0
    @sprite.bitmap.dispose if @sprite.bitmap
    card_id = @cardsList[index]
    trainer_card_path = "#{BASE_TRAINER_CARD_PATH}/#{card_id}"
    echoln index
    echoln @cardsList.length
    @sprite.bitmap = AnimatedBitmap.new(trainer_card_path).bitmap
    #sprite.ox = @sprite.bitmap.width/2 if @sprite.bitmap
    #@sprite.oy = @sprite.bitmap.height/2 if @sprite
  end
end
