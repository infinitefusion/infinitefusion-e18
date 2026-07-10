class Game_Temp
  attr_accessor :unimportedSprites
  attr_accessor :nb_imported_sprites
  attr_accessor :loading_screen
  attr_accessor :custom_sprites_list
  attr_accessor :base_sprites_list
  attr_accessor :forced_alt_sprites
  attr_accessor :transfer_box_autosave
  attr_accessor :moving_furniture
  attr_accessor :moving_furniture_oldPlayerPosition
  attr_accessor :moving_furniture_oldItemPosition
  attr_accessor :original_direction   #generic - for if we need to save a direction for whatever reason
  attr_accessor :starter_options
  attr_accessor :time_trial_bumps

  alias pokemonEssentials_GameTemp_original_initialize initialize
  def initialize
    pokemonEssentials_GameTemp_original_initialize
    @custom_sprites_list    ={}
    @base_sprites_list    ={}
    @base_sprites_list    ={}
    @moving_furniture    = nil
    @original_direction = nil
    @time_trial_bumps = 0
  end
end
