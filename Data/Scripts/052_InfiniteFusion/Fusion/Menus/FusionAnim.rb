# class PokemonFusionScene
#   HEAD_SPRITE_STARTING_POS = Graphics.width / 2
#
#
#   def pbStartScreen(pokemon_head,pokemon_body,pokemon_fused)
#
#     @pokemon_head = pokemon_head
#     @pokemon_body = pokemon_body
#
#     @pokemon_fused = pokemon_fused
#
#     @sprites = {}
#     @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
#     @viewport.z = 99999
#
#     initialize_background()
#     initialize_sprites()
#   end
#
#   def initialize_background()
#     addBackgroundOrColoredPlane(@sprites, "background", "DNAbg",
#                                 Color.new(248, 248, 248), @viewport)
#   end
#
#   def initialize_sprites()
#     pokeHead_number = GameData::Species.get(@pokemon_head.species).id_number
#     pokeBody_number = GameData::Species.get(@pokemon_body.species).id_number
#
#     @sprites["poke_head"] = PokemonSprite.new(@viewport)
#     @sprites["poke_head"].setPokemonBitmapFromId(pokeHead_number, false, @pokemon_head.shiny?)
#
#     @sprites["poke_head"].ox = @sprites["rsprite1"].bitmap.width / 2
#     @sprites["poke_head"].x = Graphics.width / 2
#     @sprites["poke_head"].zoom_x = Settings::FRONTSPRITE_SCALE
#
#   end
#
# end
