#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
# Bop Module
#====================================================================================

def pbWaitForCharacterMove(event)
  return unless event
	while event.move_route_forcing
		pbWait(1)
	end
end

class PokemonContestTalent_Scene
    # Dispose
    def dispose(sprite=@sprites, id=nil)
      (id.nil?)? pbDisposeSpriteHash(sprite) : pbDisposeSprite(sprite, id)
    end
    # Update (just script)
    def update
      pbUpdateSpriteHash(@sprites)
    end
end