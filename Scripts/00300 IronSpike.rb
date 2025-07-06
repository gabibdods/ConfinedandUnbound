module Battle
    class Move
      # Move that deals damage from the user defense and not its attack statistics
      class IronSpike < Basic
        # Get the basis atk for the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param ph_move [Boolean] true: physical, false: special
        # @return [Integer]
        def calc_sp_atk_basis(user, target, ph_move)
          return user.dfe_basis
        end
  
        # Statistic modifier calculation: ATK/ATS
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param ph_move [Boolean] true: physical, false: special
        # @return [Integer]
        def calc_atk_stat_modifier(user, target, ph_move)
          return 1 if critical_hit?
  
          return user.atk_modifier
        end

        def calc_def_stat_modifier(user, target, ph_move)
          return 1
        end
      end
      class SilverSpike < IronSpike
  
        # Give the amount of HP healed
        # @return [Integer]
        def calc_sp_atk_basis(user, target, ph_move)
          return user.dfe_basis
        end
      end
      Move.register(:s_iron_spike, IronSpike)
      Move.register(:s_silver_spike, SilverSpike)
    end
  end
  