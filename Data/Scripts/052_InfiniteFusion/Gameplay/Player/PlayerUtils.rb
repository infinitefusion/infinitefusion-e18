def isPlayerMale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
end

def isPlayerFemale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_FEMALE
end

def getPlayerGenderId()
  return pbGet(VAR_TRAINER_GENDER)
end


def isPostgame?()
  return $game_switches[SWITCH_BEAT_THE_LEAGUE]
end

def isPlayerBirthDate? #used only for the nurse to wish you happy birthday. The normal check needs to be deactivated before petalburg lol
  return unless $Trainer.birth_day && $Trainer.birth_month
  current_date = Time.now
  return current_date.day == $Trainer.birth_day && current_date.month == $Trainer.birth_month
end

def isPlayerBirthDay?
  return false unless $game_switches[SWITCH_PETALBURG_WOODS_UNLOCKED]
  return false unless $Trainer.birth_day && $Trainer.birth_month
  current_date = Time.now
  return current_date.day == $Trainer.birth_day && current_date.month == $Trainer.birth_month
end

def obtainedTransferBox?
  return $PokemonSystem.obtained_transfer_box
end