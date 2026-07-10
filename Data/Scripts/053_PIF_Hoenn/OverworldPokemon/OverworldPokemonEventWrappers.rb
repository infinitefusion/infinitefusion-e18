#Just wrappers over OverworldPokemonEvent so that statics can be handled separately when cleaning the map (and other places if needed)
class StaticOverworldPokemonEvent < OverworldPokemonEvent
end

class DynamicOverworldPokemonEvent < OverworldPokemonEvent
end