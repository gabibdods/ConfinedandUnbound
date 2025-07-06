module BattleUI
  class InfoBar
    class Background < ShaderedSprite
      def background_filename(pokemon)
        return 'battle/battlebar_boss'  if  $game_switches[499] && pokemon.bank != 0
        return 'battle/battlebar_enemy' if pokemon.bank != 0

        return 'battle/battlebar_actor' if pokemon.from_party?
        return 'battle/battlebar_ally'
      end
    end
  end
end