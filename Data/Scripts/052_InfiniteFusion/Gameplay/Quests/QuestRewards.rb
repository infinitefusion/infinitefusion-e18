#
# Rewards given by hotel questman after a certain nb. of completed quests
#
QUEST_REWARDS = Settings::KANTO ? [
  # Kanto quest rewards
  QuestReward.new(1, :HM08, 1, _INTL("This HM will allow you to illuminate dark caves and should help you to progress in your journey!")),
  QuestReward.new(5, :AMULETCOIN, 1, _INTL("This item will allows you to get twice the money in a battle if the Pokémon holding it took part in it!")),
  QuestReward.new(10, :LANTERN, 1, _INTL("This will allow you to illuminate caves without having to use a HM! Practical, isn't it?")),
  QuestReward.new(15, :LINKINGCORD, 3, _INTL("This strange cable triggers the evolution of Pokémon that typically evolve via trade. I know you'll put it to good use!")),
  QuestReward.new(20, :SLEEPINGBAG, 1, _INTL("This handy item will allow you to sleep anywhere you want. You won't even need hotels anymore!")),
  QuestReward.new(30, :MISTSTONE, 1, _INTL("This rare stone can evolve any Pokémon, regardless of their level or evolution method. Use it wisely!"), true),
  QuestReward.new(50, :GSBALL, 1, _INTL("This mysterious ball is rumored to be the key to call upon the protector of Ilex Forest.  It's a precious relic.")),
  QuestReward.new(60, :MASTERBALL, 1, _INTL("This rare ball can catch any Pokémon. Don't waste it!"), true),
] : [
  # Hoenn quest rewards
  QuestReward.new(2, :AMULETCOIN, 1, _INTL("This doubles the money you get in Pokémon battles. Maybe it'll help finance the show!")),
  QuestReward.new(5, :INCUBATOR, 1, _INTL("The note that came with it said that it allows you to hatch an egg instantly!")),
  QuestReward.new(10, :ITEMFINDER, 1, _INTL("There's a note with it. If there's a hidden item anywhere near you, that little thing will react to tell you.")),
  QuestReward.new(15, :INCUBATOR, 3, _INTL("Looks like they sent even more of these incubators for hatching Eggs. There must be a high-profile Pokémon breeder that's a fan of the show!")),
  QuestReward.new(20, :SLEEPINGBAG, 1, _INTL("There's a note with it. This deluxe sleeping bag will allow you to sleep anywhere you want. It's so comfortable that you can sleep in it for hours!")),
  QuestReward.new(25, :LINKINGCORD, 1, _INTL("Apparently, this strange cable triggers the evolution of Pokémon that typically evolve via trade. I know you'll put it to good use!")),
  QuestReward.new(50, :MISTSTONE, 1, _INTL("This rare stone can evolve any Pokémon, regardless of their level or evolution method. Use it wisely!"), true),
  QuestReward.new(60, :GSBALL, 1, _INTL("This mysterious ball is rumored to be the key to call upon the protector of Ilex Forest.  It's a precious relic.")),
  QuestReward.new(70, :MASTERBALL, 1, _INTL("This rare ball can catch any Pokémon. Don't waste it!"), true),
]
