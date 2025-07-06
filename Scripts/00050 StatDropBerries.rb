module Battle
    module Effects
      class Item
        class StatDropBerries < Berry
            # Function called when a stat_decrease_prevention is checked
            # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
            # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
            # @param target [PFM::PokemonBattler]
            # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
            # @param skill [Battle::Move, nil] Potential move used
            # @return [:prevent, nil] :prevent if the stat decrease cannot apply
            def on_stat_change_post(handler, stat, power, target, launcher, skill)
                return if target != @target || target == launcher
                return if @logic.allies_of(target).include?(launcher)
                return if power >= 0
                handler.scene.visual.show_item(target)
                handler.scene.visual.wait_for_animation
                item_name = data_item(db_symbol).name
                handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 2, target, PFM::Text::ITEM2[1] => item_name))
                handler.logic.stat_change_handler.stat_change_with_process(stat_improved, 2, target)
                consume_berry(target, launcher, skill, should_confuse: should_confuse)
              end
  
          # Function that executes the effect of the berry (for Pluck & Bug Bite)
          # @param force_heal [Boolean] tell if a healing berry should force the heal
          def execute_berry_effect(force_heal: false)
            # Remove the following line if the berry should be executed only if the condition match

            process_effect(@target, nil, nil)
          end
  
          private
  
          # Function that process the effect of the berry (if possible)
          # @param target [PFM::PokemonBattler]
          # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
          # @param skill [Battle::Move, nil] Potential move used
          def process_effect(target, launcher, skill)
            return if cannot_be_consumed?
            return if target.dead?
            return if target.battle_stage.all?(&:zero?)
            
            consume_berry(target, launcher, skill, should_confuse: should_confuse)
  
            power = target.has_ability?(:ripen) ? 4 : 2
            @logic.stat_change_handler.stat_change_with_process(stat_improved, power, target, launcher, skill)
          end
  
          # Give the hp rate that triggers the berry
          # @return [Float]
  
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return :spd
          end

          # @return [Boolean]
          def should_confuse
            return false
          end

          class Sharp < StatDropBerries
            # Give the stat it should improve
            # @return [Symbol]
            def stat_improved
              return :atk
            end
          end
  
          class Iron < StatDropBerries
            # Give the stat it should improve
            # @return [Symbol]
            def stat_improved
              return :dfe
            end
          end
  
          class Amplify < StatDropBerries
            # Give the stat it should improve
            # @return [Symbol]
            def stat_improved
              return :ats
            end
          end
  
          class Fortify < StatDropBerries
            # Give the stat it should improve
            # @return [Symbol]
            def stat_improved
              return :dfs
            end
          end

        end
        register(:quick_seed, StatDropBerries)
        register(:sharp_seed, StatDropBerries::Sharp)
        register(:iron_seed, StatDropBerries::Iron)
        register(:amplify_seed, StatDropBerries::Amplify)
        register(:fortify_seed, StatDropBerries::Fortify)
      end
    end
  end