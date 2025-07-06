module Battle
    module Effects
      class Item
        class TwistBand < Item
          # Function called when a stat_decrease_prevention is checked
          # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
          # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
          # @param target [PFM::PokemonBattler]
          # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
          # @param skill [Battle::Move, nil] Potential move used
          # @return [:prevent, nil] :prevent if the stat decrease cannot apply
          def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
            return if target != @target
            return unless launcher && target != launcher && launcher.can_be_lowered_or_canceled?
  
            return handler.prevent_change do
              handler.scene.visual.show_item(@target)
              handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 13, target))
            end
          end
        end
        register(:twist_band, TwistBand)
      end
    end
  end
  