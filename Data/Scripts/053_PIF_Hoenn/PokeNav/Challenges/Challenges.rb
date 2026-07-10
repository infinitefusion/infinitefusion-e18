def openChallengeApp
  pbFadeOutIn {
    scene = PokemonChallenges_Scene.new
    screen = PokemonChallenges_Screen.new(scene)
    screen.pbStartScreen
    # scene.pbRefresh
  }
end

class Player

  def add_challenge(challenge_id)
    @challenges = {} unless @challenges
    challenge_template = CHALLENGES[challenge_id]
    return unless challenge_template

    reward = pick_challenge_reward(challenge_template.category)
    @challenges[challenge_id] = PlayerChallenge.new(challenge_id, reward)
  end

  def complete_challenge(challenge_id)
    @challenges = {} unless @challenges
    if @challenges.has_key?(challenge_id)
      challenge = @challenges[challenge_id]
      challenge.completed = true
      @challenges[challenge_id] = challenge
      $Trainer.nb_completed_challenges = 0 unless $Trainer.nb_completed_challenges
      $Trainer.nb_completed_challenges += 1
      pbSEPlay("challenge_complete")
    end
  end

  def completed_challenge?(challenge_id)
    if @challenges.has_key?(challenge_id)
      return @challenges[challenge_id]
    end
    return false
  end

  def select_random_challenge(category)
    candidates = CHALLENGES.select { |_k, v| v.category == category }.keys
    return nil if candidates.empty?
    return candidates.sample
  end

  def refresh_challenges()
    @challenges = {} unless @challenges
    @challenges.each do |challenge_id, challenge|
      unless challenge.completed
        remove_challenge(challenge.id)
      end
    end
    categories = [:encounter, :battle, :catch, :fusion]
    categories.each do |category|
      unclaimed_challenges = listPlayerChallengesOfCategory(category)
      if unclaimed_challenges.empty?
        challenge_id = select_random_challenge(category)
        add_challenge(challenge_id)
      end
    end
  end

  def listPlayerChallengesOfCategory(category)
    challenges_list = []
    @challenges.each do |challenge_id, challenge|
      if challenge.category == category
        challenges_list << challenge.id
      end
    end
    return challenges_list
  end

  def remove_challenge(challenge_id)
    @challenges.delete(challenge_id)
  end

  def clear_all_challenges
    @challenges = {} unless @challenges
    for id in @challenges
      remove_challenge(id)
    end
  end

  def pick_challenge_reward(category)
    tier = rand(3) == 0 ? :TIER2 : :TIER1
    items_list = []
    case category
    when :encounter
      items_list = tier == :TIER1 ? CHALLENGE_ENCOUNTER_REWARDS_TIER1 : CHALLENGE_ENCOUNTER_REWARDS_TIER2
    when :battle
      items_list = tier == :TIER1 ? CHALLENGE_BATTLE_REWARDS_TIER1 : CHALLENGE_BATTLE_REWARDS_TIER2
    when :catch
      items_list = tier == :TIER1 ? CHALLENGE_CATCH_REWARDS_TIER1 : CHALLENGE_CATCH_REWARDS_TIER2
    when :fusion
      items_list = tier == :TIER1 ? CHALLENGE_FUSE_REWARDS_TIER1 : CHALLENGE_FUSE_REWARDS_TIER2
    end
    item = items_list.sample
    if tier == :TIER1
      quantity = rand(1..3)
    else
      quantity = 1
    end
    reward = []
    for i in 1..quantity
      reward << item
    end
    return reward
  end

end

class PlayerChallenge
  attr_reader :id
  attr_reader :item_reward
  attr_reader :template
  attr_accessor :completed

  def initialize(id, item_reward = [])
    @id = id
    @item_reward = item_reward
    @template = CHALLENGES[id]
    @completed = false
  end

  def description
    return _INTL(@template.description)
  end

  def category
    return _INTL(@template.category)
  end

  def money_reward
    return _INTL(@template.money_reward)
  end
end

class ChallengeTemplate
  attr_reader :id, :description, :category, :money_reward

  def initialize(id, description, category, money_reward)
    @id = id
    @description = description
    @money_reward = money_reward
    @category = category
  end
end

CHALLENGES = {}

def define_challenge(id, description:, category:, money_reward:)
  CHALLENGES[id] = ChallengeTemplate.new(id, description, category, money_reward)
end

