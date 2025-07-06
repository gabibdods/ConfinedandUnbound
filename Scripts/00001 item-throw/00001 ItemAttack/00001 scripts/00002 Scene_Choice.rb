module Battle
  class Scene
    # Method that asks the item to use
    def item_choice
      item_wrapper = @visual.show_item_choice
      if item_wrapper
        return if special_item_choice_action(item_wrapper)

        if item_wrapper.on_attack_item
          @player_actions << Actions::AttackItem.new(self, item_wrapper, @logic.battler(0, @player_actions.size).bag, @logic.battler(0, @player_actions.size))
        else
          # The player made a choice we store the action and we check if he can make other choices
          @player_actions << Actions::Item.new(self, item_wrapper, @logic.battler(0, @player_actions.size).bag, @logic.battler(0, @player_actions.size))
          log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        end
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    end
  end
end
