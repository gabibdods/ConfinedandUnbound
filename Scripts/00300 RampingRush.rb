module Battle
    class Move
      # Quash move
      class RampingRush < Basic
        # Function that tests if the user is able to use the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
        # @return [Boolean] if the procedure can continue
        def move_usable_by_user(user, targets)
          return false unless super
  
          return true
        end
  
        private
  
        # Function that deals the effect to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_effect(user, actual_targets)
          target = actual_targets.first
          # @type [Array<Actions::Attack>]
          attacks = logic.actions.select { |action| action.is_a?(Actions::Attack) }
          target_action = attacks.find { |action| action.launcher == target }
          return unless target_action
  
          logic.actions.delete(target_action)
          logic.actions.insert(0, target_action)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 1137, target))
        end
      end
      Move.register(:s_ramping_rush, RampingRush)
    end
  end
  