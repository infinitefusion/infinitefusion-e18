class Game_Temp
  attr_accessor :choose_number_window
end

class ExpExtraction
  attr_accessor :exp_to_extract
  attr_accessor :nb_candies

  attr_reader :valid_exp
  attr_reader :max_value
  attr_reader :full_price

  BASE_PRICE = 1000
  LOSS_PER_CANDY = 50
  def initialize(pokemon, unit_price)
    @pokemon = pokemon
    @unit_price = unit_price
    @exp_to_extract = 0
    @nb_candies = (@exp_to_extract / 1000).floor
    @full_price = BASE_PRICE + @unit_price * @nb_candies
    @total_exp = pokemon.exp_gained_with_player

    pokemon.exp_gained_with_player = 0 if !pokemon.exp_gained_with_player
    @valid_exp = [pokemon.exp_gained_with_player,pokemon.exp].min
    @max_value = @valid_exp / 1000.floor

    update_text

  end

  def update(nb_candies)
    return if nb_candies == @nb_candies
    @nb_candies = nb_candies
    @exp_to_extract = @nb_candies * 1000

    @nb_candies = (@exp_to_extract / 1000).floor
    @full_price = calculate_price

    update_text
  end

  def calculate_price # todo: scale exponentially with bigger numbers
    return BASE_PRICE + @unit_price * @nb_candies
  end

  def update_text
    Kernel.pbClearNumber()
    Kernel.pbClearText()
    return if @max_value < 1
    Kernel.pbDisplayText(_INTL("Exp to extract:"), 80, 100,)
    Kernel.pbDisplayText("#{@exp_to_extract} / #{@valid_exp}", 120, 130,)

    Kernel.pbDisplayText(_INTL("Price:"), 40, 170,)
    Kernel.pbDisplayText("$#{@full_price}", 80, 200,)
  end

  def dispose
    Kernel.pbClearText()
    Kernel.pbClearNumber()
    $game_temp.choose_number_window = nil
  end
end

# nbCandiesVariable: variable in which to store the nb. of candies obtained.
# The event does a little animation before giving out the candies.
#
def extractExpFromPokemon(pokemon, unitPrice, nbCandiesVariable = 1)

  expExtraction = ExpExtraction.new(pokemon, unitPrice)
  if expExtraction.max_value < 1
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("Oh, I'm sorry, but this Pokémon does not have enough Exp. available for the procedure."))
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("Keep in mind that only the Exp. that was obtained with a Trainer can be safely extracted. Any Exp. it gained as a wild Pokémon is no good!"))
    return false
  end

  update_proc = proc {
    cmdwindow = $game_temp.choose_number_window
    if cmdwindow
      current_number = cmdwindow.number
      expExtraction.update(current_number)
    end
  }

  params = ChooseNumberParams.new
  params.setRange(0, expExtraction.max_value)
  params.setDefaultValue(1)
  params.setCancelValue(0)

  value = pbMessageChooseNumber(_INTL("\\GHow many \\C[1]Exp. Candies\\C[0] to extract?"), params, &update_proc)
  new_exp = pokemon.exp - expExtraction.exp_to_extract
  new_exp -= ExpExtraction::LOSS_PER_CANDY*expExtraction.nb_candies
  new_exp -= expExtraction.nb_candies


  new_exp = 0 if new_exp < 0
  nb_candies = expExtraction.nb_candies

  new_level = pokemon.calculate_level_at_exp(new_exp)
  expExtraction.dispose
  if expExtraction.nb_candies <= 0 || value <=0 #value:0 means that it was cancelled
    return false
  end

  if $Trainer.money < expExtraction.full_price
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("Oh, I'm sorry, but you don't have enough money to afford the procedure. You might want to try a smaller extraction."))
    return false
  end

  pbCallBubDown(2, @event_id)
  if pbConfirmMessage(_INTL("Your {1} will go from \\C[1]Level {2}\\C[0] to \\C[1]Level {3}\\C[0] after all the Exp. Candies are extracted. Do you still want to continue?", pokemon.name, pokemon.level, new_level))
    exp_to_extract = expExtraction.exp_to_extract + ExpExtraction::LOSS_PER_CANDY*expExtraction.nb_candies
    removeExp(pokemon, exp_to_extract)
    pbSet(nbCandiesVariable, nb_candies)
    $Trainer.money -= expExtraction.full_price
  else
    return false
  end

end

def removeExp(pokemon, exp_to_remove)
  pokemon.exp_gained_with_player = 0 unless pokemon.exp_gained_with_player
  pokemon.exp_gained_with_player -= exp_to_remove
  pokemon.exp_gained_with_player = 0 if pokemon.exp_gained_with_player < 0

  if pokemon.exp_gained_since_fused && pokemon.exp_gained_with_player > 0
    pokemon.exp_gained_since_fused -= exp_to_remove
    if pokemon.exp_gained_since_fused < 0
      pokemon.exp_when_fused_head = 0 unless pokemon.exp_when_fused_head
      pokemon.exp_when_fused_body = 0 unless pokemon.exp_when_fused_body

      difference = pokemon.exp_gained_since_fused.abs
      pokemon.exp_gained_since_fused = 0
      pokemon.exp_when_fused_head -= difference / 2
      pokemon.exp_when_fused_body -= difference / 2

      pokemon.exp_when_fused_head = 0 if pokemon.exp_when_fused_head < 0
      pokemon.exp_when_fused_body = 0 if pokemon.exp_when_fused_body < 0
    end
    pokemon.exp_gained_since_fused = 0 if pokemon.exp_gained_since_fused < 0
  end

  pokemon.exp -= exp_to_remove
  pokemon.exp = 0 if pokemon.exp < 0
  pokemon.calc_stats
end
