#===============================================================================
# Pokémon icons
#===============================================================================
class PokemonBoxIcon < IconSprite
  attr_accessor :pokemon

  def initialize(pokemon, viewport = nil)
    super(0, 0, viewport)
    @pokemon = pokemon
    @release = Interpolator.new
    @startRelease = false
    @enabled=true
    refresh
  end

  def releasing?
    return @release.tweening?
  end

  def useRegularIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return true if dexNum <= Settings::NB_POKEMON
    return false if $game_variables == nil
    return true if $game_variables[VAR_FUSION_ICON_STYLE] != 0
    bitmapFileName = sprintf("Graphics/Icons/icon%03d", dexNum)
    return true if pbResolveBitmap(bitmapFileName)
    return false
  end

  def createFusionIcon(species, spriteform_head = nil, spriteform_body = nil)
    bodyPoke_number = getBodyID(species)
    headPoke_number = getHeadID(species, bodyPoke_number)

    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    icon1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke, spriteform_head))
    icon2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke, spriteform_body))

    dexNum = getDexNumberForSpecies(species)
    ensureFusionIconExists
    bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
    headPokeFileName = GameData::Species.icon_filename(headPoke, spriteform_head)
    bitmapPath = sprintf("%s.png", bitmapFileName)
    generated_new_icon = generateFusionIcon(headPokeFileName, bitmapPath)
    result_icon = generated_new_icon ? AnimatedBitmap.new(bitmapPath) : icon1

    for i in 0..icon1.width - 1
      for j in ((icon1.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)..icon1.height - 1
        temp = icon2.bitmap.get_pixel(i, j)
        result_icon.bitmap.set_pixel(i, j, temp)
      end
    end
    return result_icon
  end

  def release
    self.ox = self.src_rect.width / 2 # 32
    self.oy = self.src_rect.height / 2 # 32
    self.x += self.src_rect.width / 2 # 32
    self.y += self.src_rect.height / 2 # 32
    @release.tween(self, [
      [Interpolator::ZOOM_X, 0],
      [Interpolator::ZOOM_Y, 0],
      [Interpolator::OPACITY, 0]
    ], 100)
    @startRelease = true
  end

  # def refresh(fusion_enabled = true, filter_proc = nil)
  #   return if !@pokemon
  #   if useRegularIcon(@pokemon.species) || @pokemon.egg?
  #     self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon))
  #   else
  #     self.setBitmapDirectly(createFusionIcon(@pokemon.species, @pokemon.spriteform_head, @pokemon.spriteform_body))
  #     if fusion_enabled
  #       self.visible = true
  #     else
  #       self.opacity = false
  #     end
  #   end
  #   self.src_rect = Rect.new(0, 0, self.bitmap.height, self.bitmap.height)
  # end

  def update
    super
    @release.update
    self.color = Color.new(0, 0, 0, 0)
    dispose if @startRelease && !releasing?
  end
end









