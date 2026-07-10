#===============================================================================
#
#===============================================================================
class PokeRadarAppScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(main_menu_scene)
    @scene.pbStartScene(main_menu_scene)
    @scene.pbScene
    @scene.pbEndScene
  end

end


