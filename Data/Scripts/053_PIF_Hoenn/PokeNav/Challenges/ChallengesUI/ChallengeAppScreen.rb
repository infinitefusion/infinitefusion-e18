#===============================================================================
#
#===============================================================================
class PokemonChallenges_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    challenges = getChallengesList
    $Trainer.pokenav.last_opened_challenges = pbGetTimeNow
    @scene.pbStartScene(challenges)
    @scene.pbScene
    @scene.pbEndScene
  end


  def getChallengesList
    last_opened = $Trainer.pokenav.last_opened_challenges
    if shouldRefreshChallenges(last_opened)
      $Trainer.refresh_challenges()
      $PokemonTemp.fuse_count_today = 0
      $PokemonTemp.unfuse_count_today = 0
    end

    return $Trainer.challenges.values
  end


  def shouldRefreshChallenges(last_opened_date)
    return true if last_opened_date.nil?
    #return Time.now.to_date > last_opened_date
    return timeDateGreaterThan(pbGetTimeNow,last_opened_date)
    #return pbGetTimeNow.to_date > last_opened_date #Replace Time.now by pbGetTimeNow everywhere to use in-game days for testing
  end
end


