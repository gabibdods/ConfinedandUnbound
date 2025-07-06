module Battle
  class Move
    # Method calculating the damages done by the actual move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def item_damages(target)
      @effectiveness = 1
      @critical = logic.calc_critical_hit_item(target, critical_rate)
      damage = power
      damage = (damage * calc_sp_atk_item).floor / 50
      damage = (damage / calc_sp_def_item(target)).floor
      damage = (damage * calc_mod1_tvt(target)).floor + 2
      damage = (damage * calc_ch_item).floor
      damage *= logic.move_damage_rng.rand(calc_r_range)
      damage /= 100
      damage = (damage * calc_type_n_multiplier(target, :type1, [type])).floor
      damage = (damage * calc_type_n_multiplier(target, :type2, [type])).floor
      damage = (damage * calc_type_n_multiplier(target, :type3, [type])).floor

      target_hp = target.effects.get(:substitute).hp if target.effects.has?(:substitute) && !authentic?
      target_hp ||= target.hp
      damage = damage.clamp(1, target_hp)

      return damage
    end

    # [Special]ATK calculation
    # @param target [PFM::PokemonBattler] target of the item
    # @return [Integer]
    def calc_sp_atk_item
      # return $game_variables[x]

      return 150
    end

    # [Spe]def calculation
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_sp_def_item(target)
      ph_move = physical?
      result = calc_sp_def_basis_item(target, ph_move)
      result = (result * calc_def_stat_modifier_item(target, ph_move)).floor

      return result
    end

    # Get the basis dfe/dfs for the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_sp_def_basis_item(target, ph_move)
      return ph_move ? target.dfe_basis : target.dfs_basis
    end

    # Statistic modifier calculation: DFE/DFS
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_def_stat_modifier_item(target, ph_move)
      modifier = ph_move ? target.dfe_modifier : target.dfs_modifier
      modifier = modifier > 1 ? 1 : modifier if critical_hit?

      return modifier
    end

    # CH calculation
    # @return [Numeric]
    def calc_ch_item
      crit_dmg_rate = 1
      crit_dmg_rate *= 1.5 if critical_hit?

      return crit_dmg_rate
    end

    # Test if the target is immune
    # @param target [PFM::PokemonBattler]
    # @return [Boolean]
    def target_immune_item?(target)
      @effectiveness = -1

      return  calc_type_n_multiplier(target, :type1, [type]).zero? ||
              calc_type_n_multiplier(target, :type2, [type]).zero? ||
              calc_type_n_multiplier(target, :type3, [type]).zero?
    end
  end
end
