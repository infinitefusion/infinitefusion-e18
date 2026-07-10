# Loads other player secret bases from a local file and places them into the world

# todo: only load max 5
class SecretBaseLoader
  def initialize
    @importer = SecretBaseImporter.new
  end

  def load_visitor_bases
    return #DISABLED FOR NOW

    #todo
    visitor_bases = @importer.load_bases(SecretBaseImporter::VISITOR_BASES_FILE)
    friend_bases = @importer.load_bases(SecretBaseImporter::FRIEND_BASES_FILE)
    all_bases = visitor_bases + friend_bases
    $game_temp.visitor_secret_bases = all_bases
  end

  def loadSecretBaseFurniture(secretBase)
    return unless $scene.is_a?(Scene_Map)
    secretBase.load_furniture
  end

  def list_friend_bases
    return @importer.load_bases(SecretBaseImporter::FRIEND_BASES_FILE)
  end

  def list_visitor_bases
    return @importer.load_bases(SecretBaseImporter::FRIEND_BASES_FILE)
  end
end

class Game_Temp
  attr_accessor :visitor_secret_bases
end


def setupAllSecretBaseEntrances
  $PokemonTemp.pbClearTempEvents

  if $Trainer && $Trainer.secretBase && $game_map.map_id == $Trainer.secretBase.outside_map_id
    setupSecretBaseEntranceEvent($Trainer.secretBase)
  end

  if $game_temp.visitor_secret_bases && !$game_temp.visitor_secret_bases.empty?
    $game_temp.visitor_secret_bases.each do |base|
      if $game_map.map_id == base.outside_map_id
        setupSecretBaseEntranceEvent(base)
      end
    end
  end
end
# Called on map load
def setupSecretBaseEntranceEvent(secretBase)
  warpPosition = secretBase.outside_entrance_position
  entrancePosition = [warpPosition[0], warpPosition[1] - 1]
  case secretBase.biome_type
  when :TREE
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_TREE
  when :CAVE
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_CAVE
  when :BUSH
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_BUSH
  else
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_CAVE
  end
  event = $PokemonTemp.createTempEvent(template_event_id, $game_map.map_id, entrancePosition)
  event.setVariable(secretBase)
  event.refresh

end

Events.onMapSceneChange += proc { |_sender, e|
  next unless $PokemonTemp.tempEvents.empty?
  setupAllSecretBaseEntrances
}