class FusionQuiz
  attr_accessor :silhouette_color
  attr_accessor :windowed
  attr_accessor :picture_offset_x
  attr_accessor :picture_offset_y

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
    @body_choices = []
    @head_choices = []
    @abandonned = false
    @score = 0
    @current_streak = 0
    @streak_multiplier = 0.15

    @silhouette_color = Color.new(255, 255, 255, 200)
    @windowed=true
    @picture_offset_x = 0
    @picture_offset_y = 0

    @score_viewport = nil
    @score_sprite = nil
    @streak_viewport = nil
    @streak_sprite = nil
  end


  def start_quiz(nb_rounds = 3)
    create_score_display
    nb_games_played= pbGet(VAR_STAT_FUSION_QUIZ_NB_TIMES)
    pbSet(VAR_STAT_FUSION_QUIZ_NB_TIMES,nb_games_played+1)

    round_multiplier = 1
    round_multiplier_increase = 0.1

    for i in 1..nb_rounds
      if i == nb_rounds
        pbMessage(_INTL("Get ready! Here comes the final round!\\wtnp[10]"))
      elsif i == 1
        pbMessage(_INTL("Get ready! Here comes the first round!\\wtnp[10]"))
      else
        pbMessage(_INTL("Get ready! Here comes round {1}!\\wtnp[10]", i))
      end
      start_quiz_new_round(round_multiplier)

      rounds_left = nb_rounds - i
      if rounds_left > 0
        pbMessage(_INTL("That's it for round {1}. You've cumulated {2} points so far.\\wtnp[20]", i, @score))
        prompt_next_round = pbMessage(_INTL("Are you ready to move on to the next round?", i), [_INTL("Yes"), _INTL("No")])
        if prompt_next_round != 0
          prompt_quit = pbMessage(_INTL("You still have {1} rounds to go. You'll only keep your points if you finish all {2} rounds. Do you really want to quit now?", rounds_left, nb_rounds), [_INTL("Yes"), _INTL("No")])
          if prompt_quit
            @abandonned = true
            break
          end
        end
        round_multiplier += round_multiplier_increase
      else
        pbMessage(_INTL("This concludes our quiz! You've cumulated {1} points in total.", @score))
        pbMessage(_INTL("Thanks for playing!\\wtnp[20]"))
      end
    end
    end_quiz()
  end

  def create_score_display
    @score_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @score_viewport.z = 99999
    @score_sprite = BitmapSprite.new(200, 32, @score_viewport)
    @score_sprite.x = Graphics.width - 230
    @score_sprite.y = 10
    refresh_score_display

    @streak_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @streak_viewport.z = 99999
    @streak_sprite = BitmapSprite.new(200, 32, @streak_viewport)
    @streak_sprite.x = Graphics.width - 230
    @streak_sprite.y = 42
    refresh_streak_ui
  end

  def refresh_score_display
    return unless @score_sprite
    @score_sprite.bitmap.clear
    pbSetSystemFont(@score_sprite.bitmap)
    text = _INTL("{1}", @score)
    @score_sprite.bitmap.font.color = Color.new(160, 160, 160)
    @score_sprite.bitmap.draw_text(1, 1, 200, 32, text, 2)
    @score_sprite.bitmap.font.color = Color.new(255, 255, 255)
    @score_sprite.bitmap.draw_text(0, 0, 200, 32, text, 2)
  end

  def dispose_score_display
    @score_sprite&.dispose
    @score_viewport&.dispose
    @score_sprite = nil
    @score_viewport = nil
    @streak_sprite&.dispose
    @streak_viewport&.dispose
    @streak_sprite = nil
    @streak_viewport = nil
  end

  def end_quiz()
    dispose_score_display
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
    sprite_loader = BattleSpriteLoader.new
    @pif_sprite = sprite_loader.select_new_pif_fusion_sprite(@head_id,@body_id)
    show_fusion_picture(true)
    correct_answers = []

    #OBSCURED
    correct_answers << new_question(calculate_points_awarded(base_points_q1, round_multiplier), _INTL("Which Pokémon is this fusion's body?"), @body_id, nil, true, :BODY)
    pbMessage(_INTL("Next question!\\wtnp[10]"))
    correct_answers << new_question(calculate_points_awarded(base_points_q2, round_multiplier), _INTL("Which Pokémon is this fusion's head?"), @head_id, nil, true, :HEAD)

    #NON-OBSCURED
    if !correct_answers[0] || !correct_answers[1]
      show_fusion_picture(false)
      pbMessage(_INTL("Okay, now's your chance to make up for the points you missed!\\wtnp[15]"))
      if !correct_answers[0] #1st question redemption
        new_question(calculate_points_awarded(base_points_q1_redemption, round_multiplier), _INTL("Which Pokémon is this fusion's body?"), @body_id, @body_choices, false, :BODY)
        if !correct_answers[1]
          pbMessage(_INTL("Next question!\\wtnp[10]"))
        end
      end

      if !correct_answers[1] #2nd question redemption
        new_question(calculate_points_awarded(base_points_q2_redemption, round_multiplier), _INTL("Which Pokémon is this fusion's head?"), @head_id, @head_choices, false, :HEAD)
      end
    else
      pbSEPlay("Applause", 80)
      pbMessage(_INTL("Wow! A perfect round! You get {1} more points!\\wtnp[15]", perfect_round_points))
      pbMessage(_INTL("Let's see what this Pokémon looked like...\\wtnp[20]"))
      show_fusion_picture(false)
      fusion_name= GameData::Species.get(fusionOf(@head_id,@body_id)).name
      pbMessage(_INTL("It's... \\C[1]{1}\\C[0]!",fusion_name))

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

  def new_question(points_value, question, answer_id, choices, other_chance_later,question_type)
    points_value = points_value.to_i
    answer_name = getPokemon(answer_id).name
    answered_correctly = give_answer(question, answer_id, choices,question_type)
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


  def refresh_streak_ui
    base_color_low_streak    = Color.new(72, 72, 72)
    base_color_medium_streak = Color.new(213, 254, 205)
    base_color_high_streak   = Color.new(100, 232, 96)

    streak_color = base_color_low_streak
    streak_color = base_color_medium_streak if @current_streak >= 2
    streak_color = base_color_high_streak   if @current_streak >= 4

    # Update persistent sprite
    if @streak_sprite
      @streak_sprite.bitmap.clear
      pbSetSystemFont(@streak_sprite.bitmap)
      text = _INTL("Streak: {1}", @current_streak)
      @streak_sprite.bitmap.font.color = Color.new(0, 0, 0)
      @streak_sprite.bitmap.draw_text(1, 1, 200, 32, text, 2)
      @streak_sprite.bitmap.font.color = streak_color
      @streak_sprite.bitmap.draw_text(0, 0, 200, 32, text, 2)
    end
  end



  def award_points(nb_points)
    @score += nb_points
    refresh_score_display
  end

  def question_answer_followup_dialog(answered_correctly, correct_answer, points_awarded_if_win, other_chance_later = false)
    if !other_chance_later
      pbMessage(_INTL("And the correct answer was...\\wtnp[10]"))
      pbMessage(_INTL("...\\wtnp[10]"))
      pbMessage(_INTL("{1}!", correct_answer))
    end

    if answered_correctly
      pbSEPlay("itemlevel", 80)
      increase_streak
      pbMessage(_INTL("That's a correct answer!\\wtnp[10]"))
      pbMessage(_INTL("You're awarded {1} points for your answer. Your current score is {2}.\\wtnp[20]", points_awarded_if_win, @score.to_s))
    else
      pbSEPlay("buzzer", 80)
      break_streak
      pbMessage(_INTL("Unfortunately, that was a wrong answer.\\wtnp[10]"))
      pbMessage(_INTL("But you'll get another chance at it!\\wtnp[15]")) if other_chance_later
    end
  end

  def current_streak_dialog()
    return if @current_streak ==0
    streak_base_worth= @difficulty == :REGULAR ? 25 : 100
    if @current_streak % 4 == 0
      extra_points = (@current_streak/4)*streak_base_worth
      if @current_streak >= 8
        pbMessage(_INTL("That's {1} correct answers in a row. You're on a roll!\\wtnp[20]", @current_streak))
      else
        pbMessage(_INTL("That's {1} correct answers in a row. You're doing great!\\wtnp[20]", @current_streak))
      end
      pbMessage(_INTL("Here's {1} extra points for maintaining a streak!\\wtnp[15]",extra_points))
      award_points(extra_points)
    end
  end

  def show_fusion_picture(obscured = false, x = nil, y = nil)
    hide_fusion_picture()
    spriteLoader = BattleSpriteLoader.new
    bitmap = spriteLoader.load_pif_sprite_directly(@pif_sprite)
    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
    @previewwindow = PictureWindow.new(bitmap)
    @previewwindow.opacity = 0 unless @windowed
    @previewwindow.y = y ? y : 30
    @previewwindow.y += @picture_offset_y
    @previewwindow.x = x ? x : (@difficulty == :ADVANCED ? 275 : 100)
    @previewwindow.x += @picture_offset_x
    @previewwindow.z = 100000
    if obscured
      @previewwindow.picture.pbSetColorValue(@silhouette_color)
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

  def give_answer(prompt_message, answer_id, choices,question_type=:BODY)
    question_answered = false
    answer_pokemon_name = getPokemon(answer_id).name
    choices = generate_new_choices(answer_id,question_type) unless choices
    while !question_answered
      if @difficulty == :ADVANCED
        player_answer = prompt_pick_answer_advanced(prompt_message, answer_id)
      else
        player_answer = prompt_pick_answer_regular(prompt_message, answer_id, choices,question_type)
      end
      confirmed = pbMessage(_INTL("Is this your final answer?"), [_INTL("Yes"), _INTL("No")])
      if confirmed == 0
        question_answered = true
      end
    end
    return player_answer == answer_pokemon_name
  end

  def get_random_pokemon_from_same_egg_group(pokemon, amount_required)
    pokemon = ::GameData::Species.get(pokemon)
    egg_groups = getPokemonEggGroups(pokemon)

    # Get a list all pokemon in the same egg group
    matching_egg_group = []
    for num in 1..NB_POKEMON-4
      next if pokemon.id_number == num
      next if matching_egg_group.include?(num)
      new_pokemon = ::GameData::Species.get(num)
      new_pokemon_egg_groups = getPokemonEggGroups(new_pokemon)
      matching_egg_group << num if (egg_groups & new_pokemon_egg_groups).any?
    end

    # Select random pokemon from the list
    matching_egg_group.shuffle!
    choices = []
    for index in 1..amount_required
      if matching_egg_group[index].nil?
        # If there's not enough pokemon in the list (e.g. for Ditto), get anything
        new_pokemon = rand(1..NB_POKEMON-4) until !choices.include?(new_pokemon) && new_pokemon != pokemon.id_number
        choices << new_pokemon
      else
        choices << matching_egg_group[index]
      end
    end

    return choices
  end

  def prompt_pick_answer_regular(prompt_message, real_answer, choices, question_type=:BODY)
    echoln choices
    if choices && choices.is_a?(Array)
      commands = choices.shuffle
    else
      commands = generate_new_choices(real_answer,question_type)
    end
    chosen = pbMessage(prompt_message, commands)
    return commands[chosen]
  end

  def generate_new_choices(real_answer,question_type=:BODY)
    choices = []
    choices << real_answer
    choices.push(*get_random_pokemon_from_same_egg_group(real_answer, 3))

    commands = []
    choices.each do |dex_num, i|
      species = getPokemon(dex_num)
      commands.push(species.name)
    end
    if question_type == :BODY
      @body_choices = commands
    else
      @head_choices = commands
    end
    return commands.shuffle
  end

  def prompt_pick_answer_advanced(prompt_message, answer)
    commands = []
    for dex_num in 1..NB_POKEMON-4
      species = getPokemon(dex_num)
      commands.push([dex_num - 1, species.name, species.name])
    end
    pbMessage(prompt_message)
    return pbChooseListWithFilter(commands, 0, nil, 1,0,42,_INTL("Type with your keyboard"))
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
