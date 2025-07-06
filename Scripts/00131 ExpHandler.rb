module Battle
    class Logic
      # Class responsive of calculating experience & EV of Pokemon when a Pokemon faints
      class ExpHandler
        include Hooks
        # Get the logic object
        # @return [Battle::Logic]
        attr_reader :logic
  
        # Create the exp handler
        # @param logic [Battle::Logic]
        def initialize(logic)
          @logic = logic
        end
  
        # Distribute the experience for several pokemon and merge them
        # @param enemies [Array<PFM::PokemonBattler>]
        # @return [Hash{ PFM::PokemonBattler => Integer }]
        def distribute_exp_grouped(enemies)
          exp_distributions = {}
          # Distribute exp and add all enemy that are dead to switch request
          enemies.each do |enemy|
            next if enemy.exp_distributed
  
            exp_distributions.merge!(distribute_exp_for(enemy)) do |_, old_val, new_val|
              old_val + new_val
            end
          end
          return exp_distributions
        end
  
        # Distribute the experience for a single pokemon
        # @param enemy [PFM::PokemonBattler]
        # @return [Hash{ PFM::PokemonBattler => Integer }]
        def distribute_exp_for(enemy)
          evable = evable_pokemon(enemy)
          expable = expable_pokemon(enemy)
          return {} if logic.battle_info.disallow_exp?
  
          distribute_ev_to(evable, enemy)
          exp_data = global_multi_exp_factor? ? distribute_global_exp_for(enemy, expable) : distribute_separate_exp_for(enemy, expable)
          enemy.exp_distributed = true
          return exp_data.to_h
        end
  
        private
  
        # Tell if the exp factor is global or on pokemon that fought
        # @return [Boolean]
        def global_multi_exp_factor?
          $bag.contain_item?(:exp_share)
        end
  
        # Get the list of Pokemon that should receive the exp
        # @param enemy [PFM::PokemonBattler]
        # @return [Array<PFM::PokemonBattler>]
        def expable_pokemon(enemy)
          if !$game_switches[Yuki::Sw::BT_HardExp] || global_multi_exp_factor?
            return logic.trainer_battlers.reject { |receiver| receiver.max_level == receiver.level || receiver.dead? }
          else
            return logic.trainer_battlers.reject do |receiver|
              receiver.delete_battler_to_encounter_list(enemy) if (has_encountered = receiver.encountered?(enemy))
              next receiver.max_level == receiver.level || receiver.dead? || !(has_encountered || receiver.item_db_symbol == :exp_share)
            end
          end
        end
  
        # Exp distribution formula when multi-exp is in bag (thus act as global distribution)
        # @param expable [Array<PFM::PokemonBattler>]
        # @param enemy [PFM::PokemonBattler]
        # @return [Array<[PFM::PokemonBattler, Integer]>]
        def distribute_global_exp_for(enemy, expable)
          base_exp = exp_base(enemy)
          return expable.map do |receiver|
            exp = (base_exp * level_multiplier(enemy.level, receiver.level) * exp_multipliers(receiver)).floor
            exp /= (receiver.last_battle_turn != $game_temp.battle_turn ? 2 : 1) * ($game_switches[Yuki::Sw::BT_ScaledExp] ? 5 : 7)
            next [receiver, exp]
          end
        end
  
        # Exp distribution formulat when multi-exp is not in bag (thus calculated separately for all pokemon)
        # @param expable [Array<PFM::PokemonBattler>]
        # @param enemy [PFM::PokemonBattler]
        # @return [Array<[PFM::PokemonBattler, Integer]>]
        def distribute_separate_exp_for(enemy, expable)
          base_exp = exp_base(enemy)
          fought_count_during_this_turn = expable.count { |battler| battler.last_battle_turn == $game_temp.battle_turn && battler.alive? }.clamp(1, 6)
          multi_exp_count = expable.count { |battler| battler.item_db_symbol == :exp_share && battler.alive? }
          multi_exp_factor = exp_multi_exp_factor(multi_exp_count)
          fought_exp_factor = exp_fought_factor(multi_exp_count, fought_count_during_this_turn)
          return expable.map do |receiver|
            exp = (base_exp * level_multiplier(enemy.level, receiver.level) * exp_multipliers(receiver)).floor
            if receiver.last_battle_turn != $game_temp.battle_turn # Did not fight this turn
              next [receiver, (exp / multi_exp_factor).to_i]
            else
              next [receiver, (exp / fought_exp_factor).to_i + (receiver.item_db_symbol == :exp_share ? exp / multi_exp_factor : 0).to_i]
            end
          end
        end
  
        # Base exp
        # @param enemy [PFM::PokemonBattler]
        # @return [Float]
        def exp_base(enemy)
          return enemy.base_exp * enemy.level * (logic.battle_info.trainer_battle? ? 1.5 : 1)
        end
  
        # Multiplier depending on levels of enemy and receiver
        # @param enemy_level [Integer]
        # @param receiver_level [Integer]
        # @return [Float]
        def level_multiplier(enemy_level, receiver_level)
          return $game_switches[Yuki::Sw::BT_ScaledExp] ? ((2.0 * enemy_level + 10) / (enemy_level + receiver_level + 10)) ** 2.5 : 1
        end
  
        # Exp multipliers
        # @param receiver [PFM::PokemonBattler]
        def exp_multipliers(receiver)
          aura_factor = aura_factor(receiver)
          lucky_factor = receiver.item_db_symbol == :lucky_egg ? 1.5 : 1
          joy_factor = receiver.item_db_symbol == :joy_ribbon ? 1.5 : 1
          trade_factor = receiver.from_player? ? 1 : 1.5
          loyalty_factor = happy?(receiver) ? 1.2 : 1
          evolution_factor = receiver.evolve_check(:level_up) ? 1.2 : 1
          return aura_factor * lucky_factor * trade_factor * loyalty_factor * evolution_factor
        end
  
        # Tell if the pokemon is happy
        # @param receiver [PFM::PokemonBattler]
        # @return [Boolean]
        def happy?(receiver)
          return receiver.loyalty > 200
        end
  
        # Get the aura factor
        # @param receiver [PFM::PokemonBattler]
        # @return [Integer]
        def aura_factor(receiver)
          return 1
        end
  
        # Get the multi_exp factor
        # @param multi_exp_count [Integer] number of Pokemon with multi_exp
        # @return [Integer]
        def exp_multi_exp_factor(multi_exp_count)
          return ($game_switches[Yuki::Sw::BT_ScaledExp] ? 10 : 14) * (multi_exp_count + 1)
        end
  
        # Get the fought factor
        # @param multi_exp_count [Integer] number of Pokemon with multi_exp
        # @param fought [Integer] number of Pokemon that fought
        def exp_fought_factor(multi_exp_count, fought)
          return ($game_switches[Yuki::Sw::BT_ScaledExp] ? 5 : 7) * (multi_exp_count > 0 ? 2.0 : 1.0) * fought
        end
      end
    end
  end
  