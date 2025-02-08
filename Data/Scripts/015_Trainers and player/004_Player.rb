#===============================================================================
# Trainer class for the player
#===============================================================================
class Player < Trainer
  # @return [Integer] the character ID of the player
  attr_accessor :character_ID
  # @return [Integer] the player's outfit
  attr_accessor :outfit #old - unused

  attr_accessor :skin_tone
  attr_accessor :clothes
  attr_accessor :hat
  attr_accessor :hair
  attr_accessor :hair_color
  attr_accessor :hat_color
  attr_accessor :clothes_color
  attr_accessor :unlocked_clothes
  attr_accessor :unlocked_hats
  attr_accessor :unlocked_hairstyles
  attr_accessor :unlocked_card_backgrounds

  attr_accessor :dyed_hats
  attr_accessor :dyed_clothes


  attr_accessor :last_worn_outfit
  attr_accessor :last_worn_hat

  attr_accessor :surfing_pokemon


  attr_accessor :card_background
  attr_accessor :unlocked_card_backgrounds

  attr_accessor :seen_qmarks_sprite


  # @return [Array<Boolean>] the player's Gym Badges (true if owned)
  attr_accessor :badges
  # @return [Integer] the player's money
  attr_reader   :money
  # @return [Integer] the player's Game Corner coins
  attr_reader   :coins
  # @return [Integer] the player's battle points
  attr_reader   :battle_points
  # @return [Integer] the player's soot
  attr_reader   :soot
  # @return [Pokedex] the player's Pokédex
  attr_reader   :pokedex
  # @return [Boolean] whether the Pokédex has been obtained
  attr_accessor :has_pokedex
  # @return [Boolean] whether the Pokégear has been obtained
  attr_accessor :has_pokegear
  # @return [Boolean] whether the player has running shoes (i.e. can run)
  attr_accessor :has_running_shoes
  # @return [Boolean] whether the creator of the Pokémon Storage System has been seen
  attr_accessor :seen_storage_creator
  # @return [Boolean] whether Mystery Gift can be used from the load screen
  attr_accessor :mystery_gift_unlocked
  # @return [Array<Array>] downloaded Mystery Gift data
  attr_accessor :mystery_gifts
  attr_accessor :beat_league
  attr_accessor :new_game_plus_unlocked
  attr_accessor :new_game_plus
  def trainer_type
    if @trainer_type.is_a?(Integer)
      @trainer_type = GameData::Metadata.get_player(@character_ID || 0)[0]
    end
    return @trainer_type
  end

  # Sets the player's money. It can not exceed {Settings::MAX_MONEY}.
  # @param value [Integer] new money value
  def money=(value)
    validate value => Integer
    @money = value.clamp(0, Settings::MAX_MONEY)
  end

  def last_worn_outfit
    if !@last_worn_outfit
      if pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
        @last_worn_outfit = DEFAULT_OUTFIT_MALE
      else
        @last_worn_outfit = DEFAULT_OUTFIT_FEMALE
      end
    end
    return @last_worn_outfit
  end


  def last_worn_hat
    return @last_worn_hat
  end

  # Sets the player's coins amount. It can not exceed {Settings::MAX_COINS}.
  # @param value [Integer] new coins value
  def coins=(value)
    validate value => Integer
    @coins = value.clamp(0, Settings::MAX_COINS)
  end

  def outfit=(value)
    @outfit=value
  end

  def hat=(value)
    if value.is_a?(Symbol)
      value = HATS[value].id
    end
    @hat=value
    refreshPlayerOutfit()
  end

  def hair=(value)
    if value.is_a?(Symbol)
      value = HAIRSTYLES[value].id
    end
    @hair=value
    refreshPlayerOutfit()
  end

  def clothes=(value)
    if value.is_a?(Symbol)
      value = OUTFITS[value].id
    end
    @clothes=value
    refreshPlayerOutfit()
  end

  def clothes_color=(value)
    echoln value
    echoln @clothes
    echoln $Trainer.dyed_clothes
    echoln caller

    @clothes_color=value
    $Trainer.dyed_clothes= {} if !$Trainer.dyed_clothes
    $Trainer.dyed_clothes[@clothes] = value if value
    refreshPlayerOutfit()
  end
  def hat_color=(value)
    @hat_color=value
    $Trainer.dyed_hats= {} if ! $Trainer.dyed_hats
    $Trainer.dyed_hats[@hat] = value if value
    refreshPlayerOutfit()
  end


  def unlock_clothes(outfitID,silent=false)
    update_global_clothes_list()
    outfit = $PokemonGlobal.clothes_data[outfitID]
    @unlocked_clothes = [] if !@unlocked_clothes
    @unlocked_clothes << outfitID if !@unlocked_clothes.include?(outfitID)

    if !silent
      filename = getTrainerSpriteOutfitFilename(outfitID)
      name= outfit ? outfit.name : outfitID
      unlock_outfit_animation(filename,name)
    end
  end

  def unlock_hat(hatID,silent=false)
    update_global_hats_list()

    hat = $PokemonGlobal.hats_data[hatID]
    @unlocked_hats = [] if !@unlocked_hats
    @unlocked_hats << hatID if !@unlocked_hats.include?(hatID)


    if !silent
      filename = getTrainerSpriteHatFilename(hatID)
      name= hat ? hat.name : hatID
      unlock_outfit_animation(filename,name)
    end
  end

  def unlock_hair(hairID,silent=false)
    update_global_hairstyles_list()

    hairstyle = $PokemonGlobal.hairstyles_data[hairID]
    if hairID.is_a?(Symbol)
      hairID = HAIRSTYLES[hairID].id
    end
    @unlocked_hairstyles = [] if !@unlocked_hairstyles
    @unlocked_hairstyles << hairID if !@unlocked_hairstyles.include?(hairID)

    if !silent
      filename = getTrainerSpriteHairFilename("2_" + hairID)
      name= hairstyle ? hairstyle.name : hairID
      unlock_outfit_animation(filename,name)
    end
  end

  def unlock_outfit_animation(filepath,name,color=2)
    outfit_preview = PictureWindow.new(filepath)
    outfit_preview.x = Graphics.width/4
    musicEffect= "Key item get"
    pbMessage(_INTL("{1} obtained \\C[{2}]{3}\\C[0]!\\me[{4}]",$Trainer.name,color,name,musicEffect))
    outfit_preview.dispose
  end

  def surfing_pokemon=(species)
    @surfing_pokemon = species
  end


  def skin_tone=(value)
    @skin_tone=value
    $scene.reset_player_sprite
    #$scene.spritesetGlobal.playersprite.updateCharacterBitmap
  end

  def beat_league=(value)
    @beat_league = value
  end
  def new_game_plus_unlocked=(value)
    @new_game_plus_unlocked = value
  end
  # Sets the player's Battle Points amount. It can not exceed
  # {Settings::MAX_BATTLE_POINTS}.
  # @param value [Integer] new Battle Points value
  def battle_points=(value)
    validate value => Integer
    @battle_points = value.clamp(0, Settings::MAX_BATTLE_POINTS)
  end

  # Sets the player's soot amount. It can not exceed {Settings::MAX_SOOT}.
  # @param value [Integer] new soot value
  def soot=(value)
    validate value => Integer
    @soot = value.clamp(0, Settings::MAX_SOOT)
  end

  # @return [Integer] the number of Gym Badges owned by the player
  def badge_count
    return @badges.count { |badge| badge == true }
  end


  def new_game_plus=(value)
    @new_game_plus = value
  end
  #=============================================================================

  # (see Pokedex#seen?)
  # Shorthand for +self.pokedex.seen?+.
  def seen?(species)
    return @pokedex.seen?(species)
  end

  # (see Pokedex#owned?)
  # Shorthand for +self.pokedex.owned?+.
  def owned?(species)
    return @pokedex.owned?(species)
  end

  def can_change_outfit()
    return false if isOnPinkanIsland()
    return true
  end

  #=============================================================================

  def initialize(name, trainer_type)
    super
    @character_ID          = -1
    @outfit                = 0
    @hat                   = 0
    @hair                  = 0
    @clothes               = 0
    @hair_color            = 0
    @skin_tone             = 0
    @badges                = [false] * 8
    @money                 = Settings::INITIAL_MONEY
    @coins                 = 0
    @battle_points         = 0
    @soot                  = 0
    @pokedex               = Pokedex.new
    @has_pokedex           = false
    @has_pokegear          = false
    @has_running_shoes     = false
    @seen_storage_creator  = false
    @mystery_gift_unlocked = false
    @mystery_gifts         = []
    @beat_league             =  false
    @new_game_plus_unlocked  =  false
    @new_game_plus         = false
    @surfing_pokemon = nil
    @last_worn_outfit = nil
    @last_worn_hat = nil

    @dyed_hats = {}
    @dyed_clothes = {}


    @card_background = Settings::DEFAULT_TRAINER_CARD_BG
    @unlocked_card_backgrounds = [@card_background]

    @seen_qmarks_sprite = false
  end
end
