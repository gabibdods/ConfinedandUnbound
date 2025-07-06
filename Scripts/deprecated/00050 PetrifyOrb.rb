module PFM
    module ItemDescriptor
      class PetrifyOrb < Base
      end
            # Function that deals the effect to the pokemon
      # @param scene [Battle::Scene]
      # @param target [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @param item [Studio::Item]

      define_chen_prevention(:petrify_orb) { !$game_temp.in_battle }
      define_on_attack_item_use(:petrify_orb) { |item, scene| PetrifyOrb.new.proceed_internal(scene, item) }
    end
  end