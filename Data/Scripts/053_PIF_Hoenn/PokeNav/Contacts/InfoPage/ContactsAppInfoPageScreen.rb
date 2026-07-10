class ContactsAppInfoPageScreen

  def pbStartScreen(scene, trainer, trainers_list)
    @trainers_list = trainers_list
    @scene = scene
    @index = get_current_index(trainer.id)
    @scene.pbStartScene(self, trainer)
    @scene.pbScene
    @scene.pbEndScene
    updateStatus
  end

  def updateStatus
    trainer_id = @trainers_list[@index]
    unless $Trainer.pokenav.viewed_trainers.include?(trainer_id)
      $Trainer.pokenav.viewed_trainers << trainer_id
    end
  end

  def view_trainer_team(trainer_id)
    trainer = getRebattledTrainerFromKey(trainer_id)
    if trainer
      team = trainer.currentTeam
      pbFadeOutIn {
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene)
        screen.pbStartScreen(team, 0, false)
      }
    else
      pbSEPlay("buzzer", 80)
      pbWait(4)
    end
  end

  def get_current_index(current_trainer_id)
    @trainers_list.each_with_index do |trainer_id, i|
      if trainer_id == current_trainer_id
        return i
      end
    end
    return 0
  end

  def change_trainer(delta)
    new_index = @index + delta
    new_index = @trainers_list.length - 1 if new_index >= @trainers_list.length
    new_index = 0 if new_index < 0
    @index = new_index

    new_trainer_id = @trainers_list[new_index]
    @scene.trainer = getRebattledTrainerFromKey(new_trainer_id)
    updateStatus
  end
end