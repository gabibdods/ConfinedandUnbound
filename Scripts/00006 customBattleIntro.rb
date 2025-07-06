module Battle
  class Visual
    # Module holding all the Battle transition
    module Transition
      # Base class of all transitions
      class Base
        alias psdk_show_appearing_message show_appearing_message
        def show_appearing_message
          psdk_show_appearing_message unless $game_switches[497]
        end

        alias psdk_show_enemy_send_message show_enemy_send_message
        def show_enemy_send_message
          psdk_show_enemy_send_message unless $game_switches[497]
        end

        def show_player_send_message
          @scene.message_window.stay_visible = false
          @scene.display_message(player_send_message) unless $game_switches[497]
        end
      end
    end
  end
end