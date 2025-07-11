module Battle
  module Effects
    class Ability
      class Static < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0 && launcher.can_be_paralyzed? && bchance?(0.3, @logic) && !launcher.has_ability?(:long_reach)

          handler.scene.visual.show_ability(target)
          handler.logic.status_change_handler.status_change_with_process(:paralysis, launcher, target)
        end
      end
      register(:static, Static)
    end
  end
end
