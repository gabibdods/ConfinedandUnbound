module Battle
    module Effects
      class Ability
        class Legion < Ability
          # Function called when a Pokemon has actually switched with another one
          # @param handler [Battle::Logic::SwitchHandler]
          # @param who [PFM::PokemonBattler] Pokemon that is switched out
          # @param with [PFM::PokemonBattler] Pokemon that is switched in
          def on_switch_event(handler, who, with)
            return if with != @target
            return unless (th = handler.logic.transform_handler).can_transform?(with)
  
            handler.scene.visual.show_ability(with)
            with.transform = find_morphable_pokemon(with)
            handler.scene.visual.show_switch_form_animation(with)
            handler.scene.visual.wait_for_animation
            handler.scene.display_message_and_wait(parse_text_with_2pokemon(*message_id, with, with.transform))
            with.effects.add(Effects::Transform.new(handler.logic, with))
  
            with.type1 = data_type(:normal).id if with.transform.type1 == 0
          end
  
          def find_morphable_pokemon(pkmn)
            all_seen = (data_dex(0).creatures).select { |i| $pokedex.has_seen?(i.db_symbol) && i.db_symbol != pkmn.db_symbol }
            possible_option = all_seen.sample&.db_symbol || (:pawniard)
            pokemon = PFM::Pokemon.new(possible_option,pkmn.level)
            return PFM::PokemonBattler.new(pokemon,$scene)
          end
  
          # Return the text's CSV ids
          # @return [Array<Integer>]
          def message_id
            return 19, 644
          end
        end
        register(:legion, Legion)
      end
    end
  end