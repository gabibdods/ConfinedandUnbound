module Battle
    class Move
      # Class managing the Thief move
      class HitAndRun < BasicWithSuccessfulEffect
        # Function that deals the effect to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_effect(user, actual_targets)
          actual_targets.each do |target|
            next unless @logic.item_change_handler.can_lose_item?(target, user) && %i[none __undef__].include?(user.item_db_symbol)
            # Specific case : dying from Rocky Helmet or Rough Skin damage prevents from removing the target's item
            next if user.dead? && target.hold_item?(:rocky_helmet) || %i[rough_skin iron_barbs].include?(target.battle_ability_db_symbol)
  
            additionnal_variables = {
              PFM::Text::ITEM2[2] => target.item_name,
              PFM::Text::PKNICK[1] => target.given_name
            }
            @scene.display_message_and_wait(parse_text_with_pokemon(19, 1063, user, additionnal_variables))
            target_item = target.item_db_symbol
  
            if $game_temp.trainer_battle
              @logic.item_change_handler.change_item(target_item, false, user, user, self)
              if target.from_party? && !target.effects.has?(:item_stolen)
                @logic.item_change_handler.change_item(:none, false, target, user, self)
                target.effects.add(Effects::ItemStolen.new(@logic, target))
              else
                @logic.item_change_handler.change_item(:none, true, target, user, self)
              end
  
            else # wild battle
                @logic.item_change_handler.change_item(target_item, false, user, user, self)
                if target.from_party? && !target.effects.has?(:item_stolen)
                  @logic.item_change_handler.change_item(:none, false, target, user, self)
                  target.effects.add(Effects::ItemStolen.new(@logic, target))
                  scene.display_message_and_wait(parse_text_with_pokemon(70, 8, user))
                else
                  @logic.item_change_handler.change_item(:none, true, target, user, self)
                end
            end
          end
          @battler_s = @scene.visual.battler_sprite(user.bank, user.position)
          @battler_s.flee_animation
          @logic.scene.visual.wait_for_animation
          @logic.switch_request << { who: user }
        end
      end
      Move.register(:s_hit_and_run, HitAndRun)
    end
  end