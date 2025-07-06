module Battle
  class Move
    # Move that has a big recoil when fails
    class Cannonball < Basic
      # Event called if the move failed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @param reason [Symbol] why the move failed: :usable_by_user, :accuracy, :immunity, :pp
      def on_move_failure(user, targets, reason)
       if reason == :accuracy
        if !@logic.battle_info.trainer_battle? && user.bank == 1
          scene.display_message_and_wait(parse_text_with_pokemon(6969, 0, user))
          @battler_s = @scene.visual.battler_sprite(user.bank, user.position)
          @battler_s.flee_animation
          @logic.scene.visual.wait_for_animation
          @logic.battle_result = 1
        else
          return crash_procedure(user)
        end
       end
      end

      # Define the crash procedure when the move isn't able to connect to the target
      # @param user [PFM::PokemonBattler] user of the move
      def crash_procedure(user)
        scene.display_message_and_wait(parse_text_with_pokemon(6969, 0, user))
        @battler_s = @scene.visual.battler_sprite(user.bank, user.position)
        @battler_s.flee_animation
        @logic.scene.visual.wait_for_animation
        @logic.switch_request << { who: user }
      end
    end
    Move.register(:s_cannonball, Cannonball)
  end
end

