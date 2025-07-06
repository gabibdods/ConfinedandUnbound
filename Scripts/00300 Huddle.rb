module Battle
    class Move
      # Class managing the Huddle move
      class Huddle < BasicWithSuccessfulEffect
        # Function that tests if the user is able to use the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
        # @return [Boolean] if the procedure can continue
        def move_usable_by_user(user, targets)
          if (nb_mon = @logic.adjacent_allies_of(user).count) > 0
            def self.unfreeze?
              return true
            end
          else
            def self.unfreeze?
              return false
            end
          end
          was_frozen = user.frozen?
          result = super
          ally = @logic.adjacent_allies_of(user).first
          scene.logic.status_change_handler.status_change(:cure, ally) if ally&.frozen? && was_frozen != user.frozen?
          return result
        end
  
        # Function that deals the effect to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_effect(user, actual_targets)
          if logic.battle_info.vs_type == 2
            nb_mon = @logic.adjacent_allies_of(user).count
            if nb_mon > 0 
              scene.display_message_and_wait(parse_text_with_pokemon(70, 16, user))
              actual_targets.each do |target|
                logic.stat_change_handler.stat_change_with_process(:dfe, 1, target, user)
                logic.stat_change_handler.stat_change_with_process(:dfs, 1, target, user)
              end
            else
              @logic.stat_change_handler.stat_change_with_process(:dfe, 1, user, user, self)
            end
          else
            @logic.stat_change_handler.stat_change_with_process(:dfe, 1, user, user, self)
          end
        end
      end
      Move.register(:s_huddle, Huddle)
    end
  end