def failAllIncompleteRocketQuests()
  for trainer_quest in $Trainer.quests
    finishTRQuest("tr_cerulean_1", :FAILURE) if trainer_quest.id == "tr_cerulean_1" && !pbCompletedQuest?("tr_cerulean_1")
    finishTRQuest("tr_cerulean_2", :FAILURE) if trainer_quest.id == "tr_cerulean_2" && !pbCompletedQuest?("tr_cerulean_2")
    finishTRQuest("tr_cerulean_3", :FAILURE) if trainer_quest.id == "tr_cerulean_3" && !pbCompletedQuest?("tr_cerulean_3")
    finishTRQuest("tr_cerulean_4", :FAILURE) if trainer_quest.id == "tr_cerulean_4" && !pbCompletedQuest?("tr_cerulean_4")

    finishTRQuest("tr_celadon_1", :FAILURE) if trainer_quest.id == "tr_celadon_1" && !pbCompletedQuest?("tr_celadon_1")
    finishTRQuest("tr_celadon_2", :FAILURE) if trainer_quest.id == "tr_celadon_2" && !pbCompletedQuest?("tr_celadon_2")
    finishTRQuest("tr_celadon_3", :FAILURE) if trainer_quest.id == "tr_celadon_3" && !pbCompletedQuest?("tr_celadon_3")
    finishTRQuest("tr_celadon_4", :FAILURE) if trainer_quest.id == "tr_celadon_4" && !pbCompletedQuest?("tr_celadon_4")
  end
end

def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(233)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = GameData::Ability.get(abilityIndex).name
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end

def initialize_quest_points
  return if $Trainer.quest_points
  $Trainer.quest_points = get_completed_quests(false).length
end

def player_has_quest_journal?
  return $PokemonBag.pbHasItem?(:DEVONSCOPE) || $PokemonBag.pbHasItem?(:NOTEBOOK)
end

def count_nb_quests(stage,var_nb_total=1,var_nb_remaining=2, var_nb_relative_to_last_stage=3)
  nb_quests_for_next_reward = QUEST_REWARDS[stage].nb_quests
  nb_quests_completed = get_completed_quests(false).length
  nb_remaining = nb_quests_for_next_reward - nb_quests_completed
  diff_with_last_stage = -1
  diff_with_last_stage = nb_quests_for_next_reward - QUEST_REWARDS[stage-1].nb_quests if stage >= 1
  pbSet(var_nb_total,nb_quests_for_next_reward)
  pbSet(var_nb_remaining,nb_remaining)
  pbSet(var_nb_relative_to_last_stage,diff_with_last_stage)
end

def enough_quest_for_reward?(stage)
  return true
  nb_quests_for_next_reward = QUEST_REWARDS[stage].nb_quests
  return get_completed_quests(false).length >= nb_quests_for_next_reward
end

def receiveQuestReward(stage)
  item = QUEST_REWARDS[stage].item
  quantity =QUEST_REWARDS[stage].quantity
  pbReceiveItem(item, quantity)
  reward_message = QUEST_REWARDS[stage].description
  pbCallBub(2,@event_id)
  pbMessage(reward_message)
end