module PFM
  module ItemDescriptor
    class Base
      # Internal procedure of the move
      # @param scene [GamePlay::Base]
      # @param item [Studio::Item]
      def proceed_internal(scene, item)
        # @type [Battle::Scene]
        battle_scene = scene.find_parent(Battle::Scene)

        move = create_move(battle_scene, item.db_symbol)
        targets = battler_targets(battle_scene.logic, move)
        return if targets.empty?

        GamePlay.bag_mixin.from(scene).battle_item_wrapper = PFM::ItemDescriptor.actions(item.id)

        block = proc do
          targets.each do |target|
            next show_usage_failure(battle_scene, item) unless move.bchance?(move.accuracy, move.logic)
            next show_usage_immunity(battle_scene, item, target) if move.target_immune_item?(target)
            battle_scene.display_message_and_wait(parse_text_with_pokemon(70, 0, target, PFM::Text::ITEM2[1] => item.exact_name))
            Audio.se_play("Audio/SE/pmdItemThrow", 100)
            deal_damage(target, move) &&
              effect_working?(target, move) &&
              deal_status(target, move) &&
              deal_stats(target, move) &&
              deal_effect(target, move)
          end
        end

        GamePlay.bag_mixin.from(scene).battle_item_wrapper.on_attack_item = block

        scene.return_to_scene(Battle::Scene)
      end

      # Function that deals the damage to the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      def deal_damage(target, move)
        return true if move.status?
        hp = move.item_damages(target)

        damage_handler = move.logic.damage_handler
        damage_handler.damage_change_with_process(hp, target) do
          move.logic.scene.display_message_and_wait(parse_text(18, 84)) if move.critical_hit?
          move.efficent_message(move.effectiveness, target) if hp > 0
        end
      end

      # Test if the effect is working
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Boolean]
      def effect_working?(target, move)
        return move.logic.bchance?(move.data.effect_chance / 100.0, move.logic)
      end

      # Function that deals the status condition to the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      def deal_status(target, move)
        status_effects = move.status_effects
        return true if status_effects.empty?

        dice = move.logic.generic_rng.rand(0...100)
        status = status_effects.find do |status_effect|
          next true if status_effect.luck_rate > dice

          dice -= status_effect.luck_rate
          next false
        end || status_effects[0]

        move.logic.status_change_handler.status_change_with_process(status.status, target)

        return true
      end

      # Function that deals the stat to the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      def deal_stats(target, move)
        battle_stage_mod = move.battle_stage_mod
        return true if battle_stage_mod.empty?

        battle_stage_mod.each do |stage|
          next if stage.count == 0

          move.logic.stat_change_handler.stat_change_with_process(stage.stat, stage.count, target)
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      def deal_effect(target, move)
        return true
      end

      # Create the right move to retrieve its information according to the object's db_symbol
      # @param scene [Battle::Scene]
      # @param db_symbol [Symbol]
      # @return [Battle::Move]
      def create_move(scene, db_symbol)
        return Battle::Move.new(db_symbol, 1, 1, scene)
      end

      # Get the message text
      # @param item [Studio::Item]
      # @return [String]
      def message(item)
        return parse_text(70, 0, PFM::Text::TRNAME[0] => $trainer.name, PFM::Text::ITEM2[1] => item.exact_name)
      end

      # Show the usage failure when move is not usable by trainer
      # @param item [Studio::Item]
      # @param scene [Battle::Scene]
      def show_usage_failure(scene, item)
        scene.display_message_and_wait(message(item))
        scene.display_message_and_wait(parse_text(18, 74))
      end

      # Show the usage failure when move is not usable by trainer
      # @param item [Studio::Item]
      # @param scene [Battle::Scene]
      # @param pokemon [PFM::PokemonBattler]
      def show_usage_immunity(scene, item, pokemon)
        scene.display_message_and_wait(message(item))
        scene.display_message_and_wait(parse_text_with_pokemon(19, 210, pokemon))
      end
    end
  end
end
