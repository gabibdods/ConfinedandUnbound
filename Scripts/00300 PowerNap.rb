module Battle
  class Move
    class PowerNap < Basic
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return true if user.has_ability?(:comatose)

        unless user.asleep?
          show_usage_failure(user)
          return false
        end

        return true
      end
    end
    Move.register(:s_power_nap, PowerNap)
  end
end
Battle::Effects::Status::Asleep::SLEEPING_MOVES << :power_nap