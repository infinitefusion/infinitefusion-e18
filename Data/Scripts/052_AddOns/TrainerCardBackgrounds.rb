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
  "EEVEELUTION" => :CELADON,
  "GALAXYMAIL" => :SAFFRON,
  "HEARTMAIL" => :CERULEAN,
  "PIKACHU" => :VERMILLION,
  "RAINBOWMAIL" => :CELADON,
}

#purchasable from pokemart after unlocking a
# certain switch
#flag => switch to unlock
CARD_BACKGROUND_UNLOCKABLES = {
  "BLASTOISE" => SWITCH_BEAT_THE_LEAGUE,
  "CHARIZARD" => SWITCH_BEAT_THE_LEAGUE,
  "VENUSAUR" => SWITCH_BEAT_THE_LEAGUE,

  "GROUDON" => SWITCH_HOENN_HAIR_COLLECTION,
  "KYOGRE" => SWITCH_HOENN_HAIR_COLLECTION,
  "RAYQUAZA" => SWITCH_HOENN_HAIR_COLLECTION,

  "RESHIRAM" => SWITCH_UNOVA_HAIR_COLLECTION,
  "ZEKROM" => SWITCH_UNOVA_HAIR_COLLECTION,

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
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  for card in CARD_BACKGROUND_DEFAULT_PURCHASABLE
    purchasable_cards << card if !$Trainer.unlocked_card_backgrounds.include?(card)
  end
  for card in CARD_BACKGROUND_UNLOCKABLES.keys
    purchasable_cards << card if $game_switches[CARD_BACKGROUND_UNLOCKABLES[card]] && !$Trainer.unlocked_card_backgrounds.include?(card)
  end
  for card in CARD_BACKGROUND_CITY_EXCLUSIVES.keys
    purchasable_cards << card if current_city == CARD_BACKGROUND_CITY_EXCLUSIVES[card]
  end

  if purchasable_cards.length <= 0
    pbMessage("There are no more Trainer Card backgrounds available for purchase!")
    return
  end

  commands = []
  index = 0
  for card in purchasable_cards
    index += 1
    name = getDisplayedName(card)
    commands.push([index, name, card])
  end
  pbMessage("\\GWhich background would you like to purchase?")
  chosen = pbListScreen("Trainer card", TrainerCardBackgroundLister.new(purchasable_cards))
  echoln chosen
  if chosen != nil
    name = getDisplayedName(chosen)
    if pbConfirmMessage("\\GPurchase the \\C[1]#{name} Trainer Card background\\C[0] for $#{price.to_s}?")
      if $Trainer.money < price
        pbSEPlay("GUI sel buzzer", 80)
        pbMessage("\\G\\C[2]Insufficient funds")
        return false
      end
      pbSEPlay("Mart buy item")
      $Trainer.money -= price
      unlock_card_background(chosen)
      pbSEPlay("Item get")
      pbMessage("\\GYou purchased the #{name} Trainer Card background!")
      if pbConfirmMessage("Would you like to swap your current Trainer Card for the newly purchased one?")
        pbSEPlay("GUI trainer card open")
        $Trainer.card_background = chosen
      else
        pbMessage("You can swap the background at anytime when viewing your Trainer Card.")
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
    @commands << "Cancel"
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