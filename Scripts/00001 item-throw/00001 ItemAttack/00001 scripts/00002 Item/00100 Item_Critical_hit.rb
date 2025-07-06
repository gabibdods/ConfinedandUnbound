module Battle
  class Logic
    # Calculate if the current action will be a critical hit
    # @param target [PFM::PokemonBattler]
    # @param critical_rate [Integer] Critical rate of the move
    # @return [Boolean]
    def calc_critical_hit_item(target, critical_rate)
      return false if NO_CRITICAL_ABILITIES.include?(target.battle_ability_db_symbol)
      return false if bank_effects[target.bank].has?(:lucky_chant)

      current_value = @move_critical_rng.rand(100_000)
      return current_value < CRITICAL_RATES[critical_rate]
    end
  end
end
