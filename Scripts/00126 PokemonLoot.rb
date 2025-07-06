
module Battle
    class Logic
      # Item Drop System by Lexio
        BattleEndHandler.register_no_defeat('Item Drop RPG style') do |handler, _|
            next if handler.logic.battle_info.trainer_battle?
            next unless handler.logic.battle_result.zero?

            pokemon_with_items = handler.logic.all_battlers.reject { |battler| battler.from_party? || %i[none __undef__].include?(battler.battle_item_db_symbol) || battler.bank == 0 }
            pokemon_with_items.each do |pokemon|                
                Audio.se_play("audio/me/pmdItemGet")
                handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 4, pokemon, PFM::Text::ITEM2[2] => pokemon.item_name))
                $bag.add_item(pokemon.item_db_symbol, 1)
            end
        end
      end
end
