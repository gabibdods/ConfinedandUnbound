module Battle
    module Effects
      class Ability
        class SupremeVanguard < Ability
          # Function called when a status_prevention is checked
          # @param handler [Battle::Logic::StatusChangeHandler]
          # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
          # @param target [PFM::PokemonBattler]
          # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
          # @param skill [Battle::Move, nil] Potential move used
          # @return [:prevent, nil] :prevent the status cannot be applied
          MOVES_AFFECTED = %i[fire_spin whirlpool]
          def on_status_prevention(handler, status, target, launcher, skill)
            return if target != @target
            return if status == :cure
            return unless launcher&.can_be_lowered_or_canceled?
  
            return handler.prevent_change do
              handler.scene.visual.show_ability(target)
              handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 25, target))
            end
          end

          def on_move_prevention_user(user, targets, move)
            return if user == @target || !targets.include?(@target)
            return unless MOVES_AFFECTED.include?(move)
  
            move.show_usage_failure(user)
            return :prevent
          end
  
          # Function called when we try to check if the target evades the move
          # @param user [PFM::PokemonBattler]
          # @param target [PFM::PokemonBattler] expected target
          # @param move [Battle::Move]
          # @return [Boolean] if the target is evading the move
          def on_move_prevention_target(user, target, move)
            return false if user == @target || target != @target
            return false unless move&.status?
            return false unless move&.one_target?
  
            @logic.scene.visual.show_ability(target)
            @logic.scene.visual.wait_for_animation
            @logic.scene.display_message_and_wait(parse_text_with_pokemon(70, 25, target))
  
            return true
          end

          def on_switch_event(handler, who, with)
            @logic.scene.visual.show_ability(with)
            @logic.scene.visual.wait_for_animation
            @logic.scene.display_message_and_wait(parse_text_with_pokemon(70, 26, with))
          end
        end
        register(:supreme_vanguard, SupremeVanguard)
      end
    end
  end
  