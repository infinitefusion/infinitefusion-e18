def berryContest(map_id,plots_event_ids=[])
  total_yield = 0
  berry_types= []
  plots_event_ids.each do |event_id|
    berryData = $PokemonGlobal.eventvars[[map_id, event_id]]
    if berryData
      berry_type = berryData[1]
      growth_stage= berryData[0]
        if berry_type && growth_stage == 5
        berry_types << berry_type unless berry_types.include?(berry_type)
        berry_yield = calculateBerryYield(berryData)
        total_yield += berry_yield
      end
    end
  end
  return total_yield + berry_types.length
end

def calculateBerryYield(berryData)
  berryvalues = GameData::BerryPlant.get(berryData[1])
  berrycount = [berryvalues.maximum_yield - berryData[6], berryvalues.minimum_yield].max
  return berrycount
end


def berry_contest_results(player_score)
  contestants = {"Evelyn" => rand(5..8),
                 "Martin" => rand(4..8),
                 "Sarah" => rand(3..5)}
  contestants[$Trainer.name] = player_score
  results = contestants.sort_by { |name, score| score }
  return results
end