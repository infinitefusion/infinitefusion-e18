class FusionQuiz

  #
  # Possible difficulties:
  #
  # :REGULAR -> 4 options choice
  #
  # :ADVANCED -> List of all pokemon
  #
  def initialize(difficulty = :REGULAR)
    @sprites = {}


    @previewwindow = nil
    @difficulty = difficulty
    @customs_list = getCustomSpeciesList(true, false)
    @selected_pokemon = nil
    @head_id = nil
    @body_id = nil
    @choices = []
    @abandonned = false
    @score = 0
    @current_streak = 0
    @streak_multiplier = 0.15
  end


  def start_quiz(nb_rounds = 3)
    nb_games_played= pbGet(VAR_STAT_FUSION_QUIZ_NB_TIMES)
    pbSet(VAR_STAT_FUSION_QUIZ_NB_TIMES,nb_games_played+1)

    round_multiplier = 1
    round_multiplier_increase = 0.1

    for i in 1..nb_rounds
      if i == nb_rounds
        pbMessage(_INTL("Get ready! Here comes the final round!"))
      elsif i == 1
        pbMessage(_INTL("Get ready! Here comes the first round!"))
      else
        pbMessage(_INTL("Get ready! Here comes round {1}!", i))
      end
      start_quiz_new_round(round_multiplier)

      rounds_left = nb_rounds - i
      if rounds_left > 0
        pbMessage(_INTL("That's it for round {1}. You've cumulated {2} points so far.", i, @score))
        prompt_next_round = pbMessage(_INTL("Are you ready to move on to the next round?", i), ["Yes", "No"])
        if prompt_next_round != 0
          prompt_quit = pbMessage(_INTL("You still have {1} rounds to go. You'll only keep your points if you finish all {2} rounds. Do you really want to quit now?", rounds_left, nb_rounds), ["Yes", "No"])
          if prompt_quit
            @abandonned = true
            break
          end
        end
        round_multiplier += round_multiplier_increase
      else
        pbMessage(_INTL("This concludes our quiz! You've cumulated {1} points in total.", @score))
        pbMessage("Thanks for playing with us today!")
      end
    end
    end_quiz()
  end

  def end_quiz()
    hide_fusion_picture
    Kernel.pbClearText()
    previous_highest = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    pbSet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE,@score) if @score > previous_highest

    previous_total = pbGet(VAR_STAT_FUSION_QUIZ_TOTAL_PTS)
    pbSet(VAR_STAT_FUSION_QUIZ_TOTAL_PTS,previous_total+@score)
    dispose
  end

  def start_quiz_new_round(round_multiplier = 1)
    if @difficulty == :ADVANCED
      base_points_q1 = 500
      base_points_q1_redemption = 200
      base_points_q2 = 600
      base_points_q2_redemption = 200
      perfect_round_points = 100
    else
      base_points_q1 = 300
      base_points_q1_redemption = 100
      base_points_q2 = 400
      base_points_q2_redemption = 100
      perfect_round_points = 50
    end

    pick_random_pokemon()
    show_fusion_picture(true)
    correct_answers = []

    #OBSCURED
    correct_answers << new_question(calculate_points_awarded(base_points_q1, round_multiplier), "Which Pokémon is this fusion's body?", @body_id, true, true)
    pbMessage("Next question!")
    correct_answers << new_question(calculate_points_awarded(base_points_q2, round_multiplier), "Which Pokémon is this fusion's head?", @head_id, true, true)

    #NON-OBSCURED
    if !correct_answers[0] || !correct_answers[1]
      show_fusion_picture(false)
      pbMessage("Okay, now's your chance to make up for the points you missed!")
      if !correct_answers[0] #1st question redemption
        new_question(calculate_points_awarded(base_points_q1_redemption, round_multiplier), "Which Pokémon is this fusion's body?", @body_id, true, false)
        if !correct_answers[1]
          pbMessage("Next question!")
        end
      end

      if !correct_answers[1] #2nd question redemption
        new_question(calculate_points_awarded(base_points_q2_redemption, round_multiplier), "Which Pokémon is this fusion's head?", @head_id, true, false)
      end
    else
      pbSEPlay("Applause", 80)
      pbMessage(_INTL("Wow! A perfect round! You get {1} more points!", perfect_round_points))
      show_fusion_picture(false, 100)
      pbMessage("Let's see what this Pokémon looked like!")
    end
    current_streak_dialog()
    hide_fusion_picture()

  end

  def calculate_points_awarded(base_points, round_multiplier)
    points = base_points * round_multiplier
    if @current_streak > 0
      current_streak_multiplier = (@current_streak * @streak_multiplier) - @streak_multiplier
      points += points * current_streak_multiplier
      #p (base_points * round_multiplier)
      #p (points * current_streak_multiplier)
    end
    return points
  end

  def new_question(points_value, question, answer_id, should_generate_new_choices, other_chance_later)
    points_value = points_value.to_i
    answer_name = getPokemon(answer_id).real_name
    answered_correctly = give_answer(question, answer_id, should_generate_new_choices)
    award_points(points_value) if answered_correctly
    question_answer_followup_dialog(answered_correctly, answer_name, points_value, other_chance_later)
    return answered_correctly
  end

  def increase_streak
    @current_streak += 1
    refresh_streak_ui()
  end

  def break_streak
    @current_streak = 0
    refresh_streak_ui()
  end

  def refresh_streak_ui()
    shadow_color  = Color.new(160,160,160)
    base_color_low_streak = Color.new(72,72,72)
    base_color_medium_streak = Color.new(213,254,205)
    base_color_high_streak = Color.new(100,232,96)

    streak_color= base_color_low_streak
    streak_color = base_color_medium_streak if @current_streak >= 2
    streak_color = base_color_high_streak if @current_streak >= 4

    message = _INTL("Streak: {1}",@current_streak)
    Kernel.pbClearText()
    Kernel.pbDisplayText(message,420,340,nil,streak_color)
  end

  def award_points(nb_points)
    @score += nb_points
  end

  def question_answer_followup_dialog(answered_correctly, correct_answer, points_awarded_if_win, other_chance_later = false)
    if !other_chance_later
      pbMessage("And the correct answer was...")
      pbMessage("...")
      pbMessage(_INTL("{1}!", correct_answer))
    end

    if answered_correctly
      pbSEPlay("itemlevel", 80)
      increase_streak
      pbMessage("That's a correct answer!")
      pbMessage(_INTL("You're awarded {1} points for your answer. Your current score is {2}", points_awarded_if_win, @score.to_s))
    else
      pbSEPlay("buzzer", 80)
      break_streak
      pbMessage("Unfortunately, that was a wrong answer.")
      pbMessage("But you'll get another chance at it!") if other_chance_later
    end
  end

  def current_streak_dialog()
    return if @current_streak ==0
    streak_base_worth= @difficulty == :REGULAR ? 25 : 100
    if @current_streak % 4 == 0
      extra_points = (@current_streak/4)*streak_base_worth
      if @current_streak >= 8
        pbMessage(_INTL("That's {1} correct answers in a row. You're on a roll!", @current_streak))
      else
        pbMessage(_INTL("That's {1} correct answers in a row. You're doing great!", @current_streak))
      end
      pbMessage(_INTL("Here's {1} extra points for maintaining a streak!",extra_points))
      award_points(extra_points)
    end
  end

  def show_fusion_picture(obscured = false, x = nil, y = nil)
    hide_fusion_picture()
    spriteLoader = BattleSpriteLoader.new
    bitmap = spriteLoader.load_fusion_sprite(@head_id, @body_id)
    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
    @previewwindow = PictureWindow.new(bitmap)
    @previewwindow.y = y ? y : 30
    @previewwindow.x = x ? x : (@difficulty == :ADVANCED ? 275 : 100)
    @previewwindow.z = 100000
    if obscured
      @previewwindow.picture.pbSetColor(255, 255, 255, 200)
    end
  end

  def hide_fusion_picture()
    @previewwindow.dispose if @previewwindow
  end

  def pick_random_pokemon(save_in_variable = 1)
    random_pokemon = getRandomCustomFusion(true, @customs_list)
    @head_id = random_pokemon[0]
    @body_id = random_pokemon[1]
    @selected_pokemon = getSpeciesIdForFusion(@head_id, @body_id)
    pbSet(save_in_variable, @selected_pokemon)
  end

  def give_answer(prompt_message, answer_id, should_generate_new_choices)
    question_answered = false
    answer_pokemon_name = getPokemon(answer_id).real_name
    while !question_answered
      if @difficulty == :ADVANCED
        player_answer = prompt_pick_answer_advanced(prompt_message, answer_id)
      else
        player_answer = prompt_pick_answer_regular(prompt_message, answer_id, should_generate_new_choices)
      end
      confirmed = pbMessage("Is this your final answer?", ["Yes", "No"])
      if confirmed == 0
        question_answered = true
      else
        should_generate_new_choices = false
      end
    end
    return player_answer == answer_pokemon_name
  end

  def get_random_pokemon_from_same_egg_group(pokemon, previous_choices)
    egg_groups = getPokemonEggGroups(pokemon)
    while true
      new_pokemon = rand(1, NB_POKEMON) + 1
      new_pokemon_egg_groups = getPokemonEggGroups(new_pokemon)
      if (egg_groups & new_pokemon_egg_groups).any? && !previous_choices.include?(new_pokemon)
        return new_pokemon
      end
    end
  end

  def prompt_pick_answer_regular(prompt_message, real_answer, should_new_choices)
    commands = should_new_choices ? generate_new_choices(real_answer) : @choices.shuffle
    chosen = pbMessage(prompt_message, commands)
    return commands[chosen]
  end

  def generate_new_choices(real_answer)
    choices = []
    choices << real_answer
    choices << get_random_pokemon_from_same_egg_group(real_answer, choices)
    choices << get_random_pokemon_from_same_egg_group(real_answer, choices)
    choices << get_random_pokemon_from_same_egg_group(real_answer, choices)

    commands = []
    choices.each do |dex_num, i|
      species = getPokemon(dex_num)
      commands.push(species.real_name)
    end
    @choices = commands
    return commands.shuffle
  end

  def prompt_pick_answer_advanced(prompt_message, answer)
    commands = []
    for dex_num in 1..NB_POKEMON
      species = getPokemon(dex_num)
      commands.push([dex_num - 1, species.real_name, species.real_name])
    end
    pbMessage(prompt_message)
    return pbChooseList(commands, 0, nil, 1)
  end

  def get_score
    return @score
  end

  def player_abandonned
    return @abandonned
  end

  def dispose
    @previewwindow.dispose
  end

end
