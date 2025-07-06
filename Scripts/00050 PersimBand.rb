module Battle
    module Effects
      class Item
        class PersimBand < Item
          # Function called when we try to check if the target evades the move
          # @param user [PFM::PokemonBattler]
          # @param target [PFM::PokemonBattler] expected target
          # @param move [Battle::Move]
          # @return [Boolean] if the target is evading the move
          def on_status_prevention(handler, status, target, launcher, skill)
            return if target != @target
            return if status != :confusion
            return unless launcher&.can_be_lowered_or_canceled?
  
            return handler.prevent_change do
              handler.scene.visual.show_item(target)
              handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 17, target))
            end
          end
        end
        register(:persim_band, PersimBand)
      end
    end
  end
  