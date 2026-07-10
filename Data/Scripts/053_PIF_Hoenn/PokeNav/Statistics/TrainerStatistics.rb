class TrainerStatistics
  attr_accessor :pokecenter_heals
  attr_accessor :pokemon_contests_participated_total
  attr_accessor :pokemon_contests_participated_category
  attr_accessor :pokemon_contests_participated_rank
  attr_accessor :pokemon_contests_participated_category_rank
  attr_accessor :pokemon_contests_won_total
  attr_accessor :pokemon_contests_won_category
  attr_accessor :pokemon_contests_won_rank
  attr_accessor :pokemon_contests_won_category_rank

  attr_accessor :berries_planted
  attr_accessor :bike_hops_distance

  def initialize
    @pokecenter_heals = 0
    @nb_trades = 0
    @nb_battles_won = 0
    @nb_battles_lost = 0

    @nb_pokemon_defeated = 0
    @nb_pokemon_surprised = 0
    @berries_planted = 0
    @bike_hops_distance = 0
    initializeContestStats
  end

  def initializeContestStats
    @pokemon_contests_participated_total    ||= 0
    @pokemon_contests_participated_category  ||= [0,0,0,0,0]
    @pokemon_contests_participated_rank     ||= [0,0,0,0]
    @pokemon_contests_participated_category_rank ||= [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
    @pokemon_contests_won_total       ||= 0
    @pokemon_contests_won_category      ||= [0,0,0,0,0]
    @pokemon_contests_won_rank        ||= [0,0,0,0]
    @pokemon_contests_won_category_rank   ||= [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
  end

  def contest_stats_initialized?
    !@pokemon_contests_participated_total.nil?
  end
  def incr_nb_pokemon_surprised
    @nb_pokemon_surprised = 1 unless @nb_pokemon_surprised
    @nb_pokemon_surprised += 1
  end

  def incr_nb_pokemon_defeated
    @nb_pokemon_defeated = 1 unless @nb_pokemon_defeated
    @nb_pokemon_defeated += 1
  end
  def incr_nb_trades
    @nb_trades = 1 unless @nb_trades
    @nb_trades += 1
  end

  def incr_nb_battles_won
    @nb_battles_won = 1 unless @nb_battles_won
    @nb_battles_won += 1
  end

  def incr_nb_battles_lost
    @nb_battles_lost = 1 unless @nb_battles_lost
    @nb_battles_lost += 1
  end

  def incr_nb_bike_hops_steps
    @bike_hops_distance = 1 unless @bike_hops_distance
    @bike_hops_distance += 1
  end

  def nb_fusions
    return $game_variables[VAR_STAT_NB_FUSIONS]
  end
end