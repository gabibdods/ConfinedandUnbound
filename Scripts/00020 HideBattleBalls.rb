module BattleUI
  # Object that display the Battle Party Balls of a trainer in Battle
  #
  # Remaining Pokemon, Pokemon with status
  class TrainerPartyBalls < UI::SpriteStack
    # Get the base position of the Pokemon in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return @viewport.rect.width, 0 if enemy? && !@scene.battle_info.trainer_battle?
      return -400, 48 if enemy?

      return -400, 115
    end
    alias base_position_v2 base_position_v1
  end
end
