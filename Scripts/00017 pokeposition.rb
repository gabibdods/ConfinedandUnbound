module BattleUI
  # Sprite of a Pokemon in the battle
  class PokemonSprite < ShaderedSprite
        # Get the base position of the Pokemon in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return 242, 100 if enemy?

      return 90, 189
    end

    # Get the base position of the Pokemon in 2v2+
    def base_position_v2
        return 246, 86 if enemy? && $game_switches[498] #2v1
        return 213, 94 if enemy? && $game_switches[451] #SandileBoss
        return 223, 84 if enemy?

        return 52, 187
    end

    # Get the offset position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def offset_position_v2
      return 45, 6 if enemy?
      
      return 70, 0
    end
  end
end