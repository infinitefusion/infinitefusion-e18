
FieldQuestColor = :WHITE
LegendaryQuestColor = :GOLD
TRQuestColor = :DARKRED

MagmaQuestColor = :DARKRED
AquaQuestColor = :LIGHTPURPLE

QuestBranchMain = _INTL("Main Quests")

QuestBranchHotels = _INTL("Hotel Quests")
QuestBranchField = _INTL("Field Quests")
QuestBranchRocket = _INTL("Team Rocket Quests")
QuestBranchLegendary = _INTL("Legendary Quests")

class PokeBattle_Trainer
  attr_accessor :quests
end

# Shortcuts for events
def pbQuest(id,show_description=true)
  pbAcceptNewQuest(id,20,show_description)
end

def pbAcceptNewQuest(id, bubblePosition = 20, show_description = true)
  return if isQuestAlreadyAccepted?(id)
  $game_variables[96] += 1 # nb. quests accepted
  $game_variables[97] += 1 # nb. quests active

  title = QUESTS[id].name
  description = QUESTS[id].desc
  type = QUESTS[id].type
  if type && type == :MAIN_QUEST
    showNewMainQuestMessage(title, description, show_description)
  elsif type && type == :MAGMA_QUEST
    showEvilTeamMissionMessage(:MAGMA, title, description, show_description)
  elsif type && type == :AQUA_QUEST
    showEvilTeamMissionMessage(:AQUA, title, description, show_description)
  else
    showNewSideQuestMessage(title, description, show_description)
  end
  character_sprite = get_spritecharacter_for_event(@event_id)
  character_sprite.removeQuestIcon if character_sprite

  pbAddQuest(id)
end

def showNewMainQuestMessage(title, description, show_description)
  pbMEPlay("Voltorb Flip Win")

  pbCallBub(3)
  Kernel.pbMessage(_INTL("\\C[3]NEW MAIN OBJECTIVE: \\n") + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[1]" + description)
  end
end

def showEvilTeamMissionMessage(team, title, description, show_description)
  titleColor = team == :MAGMA ? 2 : 1
  textColor = team == :MAGMA ? 2 : 1

  team = team == :MAGMA ? _INTL("MAGMA") : _INTL("AQUA")

  pbMEPlay("rocketQuest", 80, 110)

  pbCallBub(3)
  Kernel.pbMessage(_INTL("\\C[{1}]{2} MISSION: ", titleColor, team) + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[#{textColor}]" + description)
  end
end

def showNewSideQuestMessage(title, description, show_description)
  pbMEPlay("Voltorb Flip Win") if Settings::KANTO
  pbMEPlay("match_call") if Settings::HOENN

  pbCallBub(3)
  Kernel.pbMessage(_INTL("\\C[6]NEW QUEST: ") + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[1]" + description)
  end
end

def isQuestAlreadyAccepted?(id)
  $Trainer.quests ||= [] # Initializes quests as an empty array if nil
  return $Trainer.quests.any? { |quest| quest.id.to_s == id.to_s }
end

def finishQuest(id, silent = false)
  $Trainer.quest_points = initialize_quest_points unless $Trainer.quest_points
  return if pbCompletedQuest?(id)
  unless is_main_quest?(id)
    $Trainer.quest_points += 1
  end
  if is_main_quest?(id)
    pbMEPlay("Register phone") if !silent
    quest_name = QUESTS[id].name
    pbCallBub(3)
    Kernel.pbMessage(_INTL("\\C[3]Main quest completed:\\n \\C[6]{1}", quest_name)) if !silent
  else
    pbMEPlay("match_call") if !silent
    pbCallBub(3)
    Kernel.pbMessage(_INTL("\\C[6]Quest completed!")) if !silent
  end
  Kernel.pbMessage(_INTL("\\qp\\C[6]Obtained 1 Quest Point!")) if !silent
  $game_variables[VAR_KARMA] += 1 # karma
  $game_variables[VAR_NB_QUEST_ACTIVE] -= 1 # nb. quests active
  $game_variables[VAR_NB_QUEST_COMPLETED] += 1 # nb. quests completed
  pbSetQuest(id, true)
end

def pbCompletedQuest?(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for i in 0...$Trainer.quests.size
    return true if $Trainer.quests[i].completed && $Trainer.quests[i].id == id
  end
  return false
end

def is_main_quest?(id)
  quest = QUESTS[id]
  return quest.type == :MAIN_QUEST
end



def pbAddQuest(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  quest = QUESTS[id]
  return unless quest
  map_id = quest.location_map_id

  if map_id
    quest.location_map_id = map_id
  else
    quest.location_map_id = get_current_town_map_location
  end
  $Trainer.quests << quest if quest
end

def pbDeleteQuest(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    $Trainer.quests.delete(q) if q.id == id
  end
end

def pbSetQuest(id, completed)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.completed = completed if q.id == id
  end
end

def pbSetQuestName(id, name)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.name = name if q.id == id
  end
end

def pbSetQuestDesc(id, desc)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.desc = desc if q.id == id
  end
end

def pbSetQuestNPC(id, npc)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.npc = npc if q.id == id
  end
end

def pbSetQuestNPCSprite(id, sprite)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.sprite = sprite if q.id == id
  end
end

def pbSetQuestLocation(id, location)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.location = location if q.id == id
  end
end

def pbSetQuestColor(id, color)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  for q in $Trainer.quests
    q.color = pbColor(color) if q.id == id
  end
end





# TODO: à terminer
def pbSynchronizeQuestLog()
  ########################
  ### Quest started    ###
  ########################
  # Pewter
  pbAddQuest("pewter_1") if $game_switches[926]
  pbAddQuest("pewter_2") if $game_switches[927]

  # Cerulean
  pbAddQuest("cerulean_1") if $game_switches[931]
  pbAddQuest("cerulean_2") if $game_switches[942] || $game_self_switches[[462, 7, "A"]]

  # Vermillion
  pbAddQuest("vermillion_1") if $game_self_switches[[464, 6, "A"]]
  pbAddQuest("vermillion_2") if $game_switches[945]
  pbAddQuest("vermillion_3") if $game_switches[929]
  pbAddQuest("vermillion_4") if $game_switches[175]

  # Celadon
  pbAddQuest("celadon_1") if $game_self_switches[[466, 10, "A"]]
  pbAddQuest("celadon_2") if $game_switches[185]
  pbAddQuest("celadon_3") if $game_switches[946]
  pbAddQuest("celadon_4") if $game_switches[172]

  # Fuchsia
  pbAddQuest("fuchsia_1") if $game_switches[941]
  pbAddQuest("fuchsia_2") if $game_switches[943]
  pbAddQuest("fuchsia_3") if $game_switches[949]

  # Crimson
  pbAddQuest("crimson_1") if $game_switches[940]
  pbAddQuest("crimson_2") if $game_self_switches[[177, 9, "A"]]
  pbAddQuest("crimson_3") if $game_self_switches[[177, 8, "A"]]

  # Saffron
  pbAddQuest("saffron_1") if $game_switches[932]
  pbAddQuest("saffron_2") if $game_self_switches[[111, 19, "A"]]
  pbAddQuest("saffron_3") if $game_switches[948]
  pbAddQuest("saffron_4") if $game_switches[339]
  pbAddQuest("saffron_5") if $game_switches[300]

  # Cinnabar
  pbAddQuest("cinnabar_1") if $game_switches[904]
  pbAddQuest("cinnabar_2") if $game_switches[903]

  # Goldenrod
  pbAddQuest("goldenrod_1") if $game_self_switches[[244, 5, "A"]]
  pbAddQuest("goldenrod_2") if $game_self_switches[[244, 8, "A"]]

  # Violet
  pbSetQuest("violet_1", true) if $game_switches[908]
  pbSetQuest("violet_2", true) if $game_switches[410]

  # Blackthorn
  pbSetQuest("blackthorn_1", true) if $game_self_switches[[332, 10, "A"]]
  pbSetQuest("blackthorn_2", true) if $game_self_switches[[332, 8, "A"]]
  pbSetQuest("blackthorn_3", true) if $game_self_switches[[332, 5, "B"]]

  # Ecruteak
  pbSetQuest("ecruteak_1", true) if $game_self_switches[[576, 9, "A"]]
  pbSetQuest("ecruteak_2", true) if $game_self_switches[[576, 8, "A"]]

  # Kin
  pbSetQuest("kin_1", true) if $game_switches[526]
  pbSetQuest("kin_2", true) if $game_self_switches[[565, 10, "A"]]

  ########################
  ### Quest finished    ###
  ########################
  # Pewter
  pbSetQuest("pewter_1", true) if $game_self_switches[[460, 5, "A"]]
  pbSetQuest("pewter_2", true) if $game_self_switches[[460, 7, "A"]] || $game_self_switches[[460, 7, "B"]]
  if $game_self_switches[[460, 9, "A"]]
    pbAddQuest("pewter_3")
    pbSetQuest("pewter_3", true)
  end

  # Cerulean
  if $game_self_switches[[462, 8, "A"]]
    pbAddQuest("cerulean_3")
    pbSetQuest("cerulean_3", true)
  end
  pbSetQuest("cerulean_1", true) if $game_switches[931] && !$game_switches[939]
  pbSetQuest("cerulean_2", true) if $game_self_switches[[462, 7, "A"]]

  # Vermillion
  pbSetQuest("vermillion_4", true) if $game_self_switches[[19, 19, "B"]]
  if $game_self_switches[[464, 8, "A"]]
    pbAddQuest("vermillion_0")
    pbSetQuest("vermillion_0", true)
  end
  pbSetQuest("vermillion_1", true) if $game_self_switches[[464, 6, "B"]]
  pbSetQuest("vermillion_2", true) if $game_variables[145] >= 1
  pbSetQuest("vermillion_3", true) if $game_self_switches[[464, 5, "A"]]

  # Celadon
  pbSetQuest("celadon_1", true) if $game_self_switches[[466, 10, "A"]]
  pbSetQuest("celadon_2", true) if $game_switches[947]
  pbSetQuest("celadon_3", true) if $game_self_switches[[466, 9, "A"]]
  pbSetQuest("celadon_4", true) if $game_self_switches[[509, 5, "D"]]

  # Fuchsia
  pbSetQuest("fuchsia_1", true) if $game_self_switches[[478, 6, "A"]]
  pbSetQuest("fuchsia_2", true) if $game_self_switches[[478, 8, "A"]]
  pbSetQuest("fuchsia_3", true) if $game_switches[922]

  # Crimson
  pbSetQuest("crimson_1", true) if $game_self_switches[[177, 5, "A"]]
  pbSetQuest("crimson_2", true) if $game_self_switches[[177, 9, "A"]]
  pbSetQuest("crimson_3", true) if $game_self_switches[[177, 8, "A"]]

  # Saffron
  pbSetQuest("saffron_1", true) if $game_switches[938]
  pbSetQuest("saffron_2", true) if $game_self_switches[[111, 19, "A"]]
  pbSetQuest("saffron_3", true) if $game_self_switches[[111, 9, "A"]]
  pbSetQuest("saffron_4", true) if $game_switches[338]
  pbSetQuest("saffron_5", true) if $game_self_switches[[111, 18, "A"]]

  # Cinnabar
  pbSetQuest("cinnabar_1", true) if $game_self_switches[[136, 5, "A"]]
  pbSetQuest("cinnabar_2", true) if $game_self_switches[[136, 8, "A"]]

  # Goldenrod
  pbSetQuest("goldenrod_1", true) if $game_self_switches[[244, 5, "A"]]
  pbSetQuest("goldenrod_2", true) if $game_self_switches[[244, 8, "B"]]

  # Violet
  pbSetQuest("violet_1", true) if $game_self_switches[[274, 5, "A"]]
  pbSetQuest("violet_2", true) if $game_self_switches[[274, 8, "A"]] || $game_self_switches[[274, 8, "B"]]

  # Blackthorn
  pbSetQuest("blackthorn_1", true) if $game_self_switches[[332, 10, "A"]]
  pbSetQuest("blackthorn_2", true) if $game_switches[337]
  pbSetQuest("blackthorn_3", true) if $game_self_switches[[332, 5, "A"]]

  # Ecruteak
  pbSetQuest("ecruteak_1", true) if $game_self_switches[[576, 9, "A"]]
  pbSetQuest("ecruteak_2", true) if $game_self_switches[[576, 8, "A"]]

  # Kin
  pbSetQuest("kin_1", true) if $game_self_switches[[565, 9, "A"]]
  pbSetQuest("kin_2", true) if $game_self_switches[[565, 10, "A"]]

  pbSetQuest("pewter_field_1", true) if $game_self_switches[[380, 62, "C"]]
  pbSetQuest("pewter_field_2", true) if $game_switches[1073]
  pbSetQuest("pewter_field_3", true) if $game_self_switches[[381, 9, "A"]]

  pbSetQuest("cerulean_field_1", true) if $game_self_switches[[8, 19, "A"]]
  pbSetQuest("cerulean_field_2", true) if $game_self_switches[[8, 19, "C"]]
  pbSetQuest("cerulean_field_3", true) if $game_self_switches[[8, 19, "D"]]

  pbSetQuest("vermillion_field_1", true) if $game_self_switches[[19, 19, "B"]] || $game_self_switches[[19, 19, "C"]]
  pbSetQuest("vermillion_field_2", true) if $game_self_switches[[29, 12, "C"]]

  pbSetQuest("celadon_field_1", true) if $game_self_switches[[509, 5, "D"]]

  pbSetQuest("fuchsia_4", true) if $game_self_switches[[478, 12, "B"]]

  pbSetQuest("crimson_4", true) if $game_self_switches[[177, 11, "A"]]

  pbSetQuest("saffron_field_1", true) if $game_switches[938]

  pbSetQuest("cinnabar_3", true) if $game_self_switches[[136, 9, "B"]]

  pbSetQuest("saffron_field_1", true) if $game_switches[938]

  pbSetQuest("kin_field_1", true) if $game_self_switches[[563, 25, "B"]]

  pbSetQuest("legendary_deoxys_1", true) if $game_switches[839]
  pbSetQuest("legendary_deoxys_2", true) if $game_self_switches[[607, 2, "C"]]

  pbSetQuest("legendary_necrozma_1", true) if $game_switches[710]
  pbSetQuest("legendary_necrozma_2", true) if $game_switches[711]
  pbSetQuest("legendary_necrozma_3", true) if $game_switches[719]
  pbSetQuest("legendary_necrozma_4", true) if $game_switches[716]
  pbSetQuest("legendary_necrozma_5", true) if $game_switches[718]
  pbSetQuest("legendary_necrozma_6", true) if $game_self_switches[[42, 43, "A"]]
  pbSetQuest("legendary_necrozma_7", true) if $game_switches[760] || $game_switches[761]

  pbSetQuest("legendary_meloetta_1", true) if $game_switches[1011]
  pbSetQuest("legendary_meloetta_2", true) if $game_switches[1014]
  pbSetQuest("legendary_meloetta_3", true) if $game_switches[1015]
  pbSetQuest("legendary_meloetta_4", true) if $game_switches[750]

  pbSetQuest("pokemart_johto", true) if $game_switches[SWITCH_JOHTO_HAIR_COLLECTION]
  pbSetQuest("pokemart_hoenn", true) if $game_switches[SWITCH_HOENN_HAIR_COLLECTION]
  pbSetQuest("pokemart_sinnoh", true) if $game_switches[SWITCH_SINNOH_HAIR_COLLECTION]
  pbSetQuest("pokemart_unova", true) if $game_switches[SWITCH_UNOVA_HAIR_COLLECTION]
  pbSetQuest("pokemart_kalos", true) if $game_switches[SWITCH_KALOS_HAIR_COLLECTION]
  pbSetQuest("pokemart_alola", true) if $game_switches[SWITCH_ALOLA_HAIR_COLLECTION]

end

def fix_quest_ids
  return unless $Trainer.quests
  $Trainer.quests.each do |quest|
    new_id = get_new_quest_id(quest.id)
    if new_id != quest.id
      echoln "BEFORE FIX"
      echoln "ID: #{quest.id} "
      echoln "Name: #{quest.name}"
      echoln "Completed: #{quest.completed}"
      echoln ""

      quest.id = new_id

      echoln "AFTER FIX"
      echoln "ID: #{quest.id} "
      echoln "Name: #{quest.name}"
      echoln "Completed: #{quest.completed}"
      echoln ""
    end
  end
  pbSynchronizeQuestLog
end

def get_new_quest_id(old_quest_id)
  quest_id_map = {
    3 => "cerulean_1",
    4 => "vermillion_2",
    5 => "pokemart_johto",

    6 => "cerulean_field_1",
    7 => "cerulean_field_2",
    8 => "cerulean_field_3",

    9 => "vermillion_1",
    12 => "vermillion_3",
    13 => "vermillion_field_1",

    14 => "celadon_1",
    15 => "celadon_2",
    16 => "celadon_3",
    17 => "celadon_field_1",

    18 => "fuchsia_3",
    19 => "fuchsia_2",
    20 => "fuchsia_1",

    21 => "crimson_1",
    22 => "crimson_2",
    23 => "crimson_3",

    24 => "saffron_field_1",
    25 => "pokemart_sinnoh",
    26 => "saffron_1",
    27 => "saffron_2",
    28 => "saffron_3",

    29 => "cinnabar_1",
    30 => "cinnabar_2",

    31 => "pokemart_hoenn",

    32 => "goldenrod_1",

    33 => "violet_1",
    34 => "violet_2",

    35 => "blackthorn_1",
    36 => "blackthorn_2",
    37 => "blackthorn_3",

    38 => "pokemart_kalos",

    39 => "ecruteak_1",
    40 => "kin_1",
    41 => "pokemart_unova",
    42 => "cinnabar_3",
    43 => "kin_2",
    44 => "bond_1",
    45 => "bond_2",
    46 => "kin_3",
    47 => "tower_1",
    48 => "lavender_darkness_1",
    49 => "celadon_darkness_2",
    50 => "fuchsia_darkness_3",
    51 => "fuchsia_darkness_4",
    52 => "safari_darkness_5",
    53 => "pallet_darkness_6",
    54 => "pewter_field_1",
    55 => "goldenrod_2",
    56 => "fuchsia_4",
    57 => "saffron_band_1",
    58 => "saffron_band_2",
    59 => "saffron_band_3",
    60 => "saffron_band_4",
    61 => "lavender_lunar",
    62 => "pokemart_alola",
    63 => "pewter_field_2",
    64 => "vermillion_field_2",
    65 => "goldenrod_police_1",
    66 => "pinkan_police"
  }
  return quest_id_map[old_quest_id] || old_quest_id
end

def showQuestStatistics(eventId, includeRocketQuests = false)
  quests_accepted = []
  quests_in_progress = []
  quests_completed = []
  $Trainer.quests = [] if !$Trainer.quests
  for quest in $Trainer.quests
    next if quest.npc == QuestBranchRocket && !includeRocketQuests
    quests_accepted << quest
    if quest.completed
      quests_completed << quest
    else
      quests_in_progress << quest
    end
  end
  pbCallBub(2, eventId)
  pbMessage(_INTL("Accepted quests: \\C[1]{1}", quests_accepted.length))
  pbCallBub(2, eventId)
  pbMessage(_INTL("Completed quests: \\C[1]{1}", quests_completed.length))
  pbCallBub(2, eventId)
  pbMessage(_INTL("In-progress: \\C[1]{1}", quests_in_progress.length))
end

def get_completed_quests(includeRocketQuests = false, includeMainQuests = false)
  quests_completed = []
  $Trainer.quests = [] if !$Trainer.quests
  for quest in $Trainer.quests
    next if quest.type == :MAIN_QUEST && !includeMainQuests
    next if quest.npc == QuestBranchRocket && !includeRocketQuests
    quests_completed << quest if quest.completed
  end
  return quests_completed
end

def getQuestReward(eventId)
  $PokemonGlobal.questRewardsObtained = [] if !$PokemonGlobal.questRewardsObtained
  nb_quests_completed = get_completed_quests(false).length # pbGet(VAR_STAT_QUESTS_COMPLETED)
  pbSet(VAR_STAT_QUESTS_COMPLETED, nb_quests_completed)
  rewards_to_give = []
  for reward in QUEST_REWARDS
    rewards_to_give << reward if nb_quests_completed >= reward.nb_quests && !$PokemonGlobal.questRewardsObtained.include?(reward.item)
  end

  # Calculate how many until next reward
  next_reward = get_next_quest_reward
  nb_to_next_reward = next_reward.nb_quests - nb_quests_completed

  for reward in rewards_to_give
    echoln reward.item

  end
  # Give rewards
  for reward in rewards_to_give
    if !reward.can_have_multiple && $PokemonBag.pbQuantity(reward.item) >= 1
      $PokemonGlobal.questRewardsObtained << reward.item
      next
    end
    pbCallBub(2, eventId)
    pbMessage(_INTL("Also, there's one more thing..."))
    pbCallBub(2, eventId)
    pbMessage(_INTL("As a gift for having helped so many people, I want to give you this."))
    pbReceiveItem(reward.item, reward.quantity)
    $PokemonGlobal.questRewardsObtained << reward.item

    # recalculate nb to next reward
    next_reward = get_next_quest_reward
    nb_to_next_reward = next_reward.nb_quests - nb_quests_completed
  end

  pbCallBub(2, eventId)
  if nb_to_next_reward <= 0
    pbMessage(_INTL("I have no more rewards to give you! Thanks for helping all these people!"))
  elsif nb_to_next_reward == 1
    pbMessage(_INTL("Help {1} more person and I'll give you something good!", nb_to_next_reward))
  else
    pbMessage(_INTL("Help {1} more people and I'll give you something good!", nb_to_next_reward))
  end
end

def get_next_quest_reward()
  for reward in QUEST_REWARDS
    nextReward = reward
    break if !$PokemonGlobal.questRewardsObtained.include?(reward.item)
  end
  # rewards_to_give << nextReward if nb_to_next_reward <=0 #for compatibility with old system
  return nextReward
end
