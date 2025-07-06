module PFM
  module ItemDescriptor
    class Base
      # List the targets of this move
      # @param logic [Battle::Logic]
      # @param move [Battle::Move]
      # @return [Array<PFM::PokemonBattler>] the possible targets
      def battler_targets(logic, move)
        case move.target
        when :adjacent_all_pokemon, :all_pokemon
          return logic.all_alive_battlers
        when :adjacent_foe, :random_foe, :adjacent_pokemon
          return [logic.alive_battlers(1).sample]
        when :all_foe, :adjacent_all_foe
          return logic.alive_battlers(1)
        when :user, :user_or_adjacent_ally, :adjacent_ally
          return [logic.alive_battlers(0).sample]
        when :all_ally, :all_ally_but_user
          return logic.alive_battlers(0)
        when :any_other_pokemon
          return [logic.all_alive_battlers.sample]
        else
          raise `Invalid target: #{move.target}`
        end
      end
    end
  end
end
