module Battle
    module Effects
      class Item
        class RecoveryScarf < Item
          # Function called at the end of a turn
          # @param logic [Battle::Logic] logic of the battle
          # @param scene [Battle::Scene] battle scene
          # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
          def on_end_turn_event(logic, scene, battlers)
            return unless battlers.include?(@target)
            return if @target.dead?
            return if @target.status_effect.instance_of?(Status) || bchance?(0.66, logic)
  
            scene.visual.show_item(@target)
            scene.display_message_and_wait(parse_text_with_pokemon(70, 14, @target))
            logic.status_change_handler.status_change(:cure, @target)
          end
        end
        register(:recovery_scarf, RecoveryScarf)
      end
    end
  end
  