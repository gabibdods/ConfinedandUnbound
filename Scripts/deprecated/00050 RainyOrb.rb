module PFM
  module ItemDescriptor
    class RainDance < Base
      # Function that deals the effect to the pokemon
      # @param scene [Battle::Scene]
      # @param target [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @param item [Studio::Item]
      def deal_effect(scene, target, move, item)
        move.logic.weather_change_handler.weather_change_with_process(:rain, 5)
      end
    end

    define_chen_prevention(:rain_dance) { !$game_temp.in_battle }
    define_on_attack_item_use(:rain_dance) { |item, scene, wrapper| RainDance.new.proceed_internal(scene, item, wrapper) }
  end
end
