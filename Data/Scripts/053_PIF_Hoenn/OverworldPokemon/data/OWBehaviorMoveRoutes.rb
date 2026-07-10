# todo:
# - Jumping (Spoink)
# - Dancing (turns around in a circle) - Oricorio, Spinda
# Curious walks up to the trainer and then look at them at a distance of 1 tile instead of running into them

OW_BEHAVIOR_MOVE_ROUTES = {
  :roaming => {
    :look_around => [
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :look_around_player => [# Used for Pokeradar, looks towards the player more often
      RPG::MoveCommand.new(PBMoveRoute::TurnTowardPlayer),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

    :still_teleport =>
      [
        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),

        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
        RPG::MoveCommand.new(PBMoveRoute::End)
      ],

    :random_burrow => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)

    ],

    :random_dive => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)

    ],

    :random_vanish => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [50]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

    :random_spin => [
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRight90),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRight90),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRight90),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRight90),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::End)

    ],

    :charge => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),

      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::End)

    ],

    :uproar => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [4]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

    :water_skip => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),

      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],


    #WIND
    :blown_away => [
      RPG::MoveCommand.new(PBMoveRoute::ThroughOn),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::ChangeSpeed, 3),

      RPG::MoveCommand.new(PBMoveRoute::SetFloatingOn),
      RPG::MoveCommand.new(PBMoveRoute::DirectionFixOn),
      RPG::MoveCommand.new(PBMoveRoute::Left),
      RPG::MoveCommand.new(PBMoveRoute::DirectionFixOff),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::LowerLeft),
      RPG::MoveCommand.new(PBMoveRoute::DirectionFixOn),
      RPG::MoveCommand.new(PBMoveRoute::Left),
      RPG::MoveCommand.new(PBMoveRoute::DirectionFixOff),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),

      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

  },

  :noticed => {
    :shy => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::TurnTowardPlayer),
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [4]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :teleport_away => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::PlaySE, [RPG::AudioFile.new("SE_Zoom5")]),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::TurnTowardPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :flee => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [200]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [150]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :flee_flying => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::TurnAwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [200]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [150]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :explode => [
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.set_animation_speed(2)"]),
      RPG::MoveCommand.new(PBMoveRoute::StepAnimeOn),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [30]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [EXPLODE_ANIMATION]),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

    :uproar => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Forward),
      RPG::MoveCommand.new(PBMoveRoute::Wait, [4]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
  }

}