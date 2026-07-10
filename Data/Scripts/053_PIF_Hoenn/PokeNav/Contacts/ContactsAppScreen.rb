#===============================================================================
#
#===============================================================================
class ContactsAppScreen
  def initialize(scene)
    @scene = scene
  end

  UNLISTABLE_TRAINER_TYPES = [:TEAM_AQUA_GRUNT_M, :TEAM_AQUA_GRUNT_F,
                              :TEAM_MAGMA_GRUNT_M, :TEAM_MAGMA_GRUNT_F,
                              :TEAM_MAGMAQUA_GRUNT_M, :TEAM_MAGMAQUA_GRUNT_F,
                              :TEAM_AQUA_EXEC_M, :TEAM_AQUA_EXEC_F,
                              :TEAM_MAGMA_EXEC_M, :TEAM_MAGMA_EXEC_F,
                              :TEAM_AQUA_BOSS, :TEAM_MAGMA_BOSS,
                              :ADVENTURER_KANTO, :ADVENTURER_JOHTO,
                              :ADVENTURER_SINNOH, :ADVENTURER_UNOVA,
                              :ADVENTURER_KALOS, :ADVENTURER_ALOLA,
  ]

  def pbStartScreen(main_menu_scene, screen)
    @main_menu_scene = main_menu_scene
    @scene.pbStartScene(self)
    @scene.pbScene
    @scene.pbEndScene
    @screen = screen
  end

  def list_contacts
    contacts_list_by_location = {}
    $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
    $PokemonGlobal.battledTrainers.each do |id, trainer|
      next unless can_be_listed(trainer)
      if trainer.favorite
        contacts_list_by_location[_INTL("Favorites")] ||= []
        contacts_list_by_location[_INTL("Favorites")] << trainer
      else
        location = trainer.location
        contacts_list_by_location[location] ||= []
        contacts_list_by_location[location] << trainer
      end
    end
    contacts_list_by_location.each_value do |trainer_array|
      trainer_array.sort_by! { |t| t.trainerName }
    end
    # Move Favorites to front
    favorites = contacts_list_by_location.delete(_INTL("Favorites"))
    if favorites
      contacts_list_by_location = { _INTL("Favorites") => favorites }.merge(contacts_list_by_location)
    end
    return contacts_list_by_location
  end

  def can_be_listed(trainer)
    trainerType = trainer.trainerType
    return false if UNLISTABLE_TRAINER_TYPES.include?(trainerType)
    return true
  end

  def view_trainer_page(trainer_id, trainers_list)
    trainer= getRebattledTrainerFromKey(trainer_id)
    if trainer
      pbFadeOutIn {
        scene = ContactsAppInfoPageScene.new
        screen = ContactsAppInfoPageScreen.new
        screen.pbStartScreen(scene, trainer, trainers_list)
      }
    else
      pbSEPlay("buzzer", 80)
      pbWait(4)
    end
  end

  def view_trainer_team(trainer_id)
    trainer= getRebattledTrainerFromKey(trainer_id)
    if trainer
      team = trainer.currentTeam
      pbFadeOutIn {
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene)
        screen.pbStartScreen(team,0, false)
      }
    else
      pbSEPlay("buzzer", 80)
      pbWait(4)
    end
  end


  def pbSummary(list, index)
    visibleSprites = pbFadeOutAndHide(@sprites) { pbUpdate }
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    @sprites["list"].index = screen.pbStartScreen(list, index ,false)
    pbFadeInAndShow(@sprites, visibleSprites) { pbUpdate }
  end

end


