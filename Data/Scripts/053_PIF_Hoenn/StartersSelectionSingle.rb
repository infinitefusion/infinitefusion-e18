class StartersSelectionSceneSingle < StartersSelectionScene
  POKEBALL_MIDDLE_X = 125; POKEBALL_MIDDLE_Y = 100

  TEXT_POSITION_X = 100
  TEXT_POSITION_Y = 10

  def initialize(starter_species)
    invisible_placeholder = GameData::Species.get(:PIKACHU)
    super([invisible_placeholder,GameData::Species.get(starter_species),invisible_placeholder])
    @index = 1
  end

  def initializeGraphics()
    super
    @pokeball_closed_left.visible =false
    @pokeball_closed_right.visible=false
  end



  def startScene
    initializeGraphics
    @index = nil
    previous_index = nil
    loop do
      if @index
        if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          updateOpenPokeballPosition
          updateStarterSelectionGraphics
        end
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          disposeGraphics
          return nil
        end
        if Input.trigger?(Input::USE)
          if pbConfirmMessage(_INTL("Do you choose this Pokémon?"))
            chosenPokemon = @starter_pokemon[@index]
            @spritesLoader.registerSpriteSubstitution(@pif_sprite)
            disposeGraphics
            pbSet(VAR_HOENN_CHOSEN_STARTER_INDEX, @index)
            chosenPokemon.pif_sprite = @pif_sprite
            return chosenPokemon
          end
        end
      else
        @index = 1 if Input.trigger?(Input::LEFT)
        @index = 1 if Input.trigger?(Input::DOWN)
        @index = 1 if Input.trigger?(Input::RIGHT)
      end

      if previous_index != @index
        echoln @index
        updateOpenPokeballPosition
        updateStarterSelectionGraphics
        previous_index = @index
      end
      Input.update
      Graphics.update
    end
  end


  def updateClosedBallGraphicsVisibility
    @pokeball_closed_left.visible = false
    @pokeball_closed_right.visible = false

    case @index
    when 0
      @pokeball_closed_middle.visible = true
    when 1
      @pokeball_closed_middle.visible = false
    when 2
      @pokeball_closed_middle.visible = true
    else
      @pokeball_closed_middle.visible = true
    end
  end
end
