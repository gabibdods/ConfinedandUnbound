#Hides the HP during move animation, but makes it be shown during move selection
#Provided by Aerun/Arex

module Battle
    class Visual
      # Set the state info
      # @param state [Symbol] kind of state (:choice, :move, :move_animation)
      # @param pokemon [Array<PFM::PokemonBattler>] optional list of Pokemon to show (move)
      def set_info_state(state, pokemon = nil)
        if state == :choice
          show_info_bars
          show_info_bars
          show_team_info
        elsif state == :move
          hide_info_bars
          pokemon&.each { |target| show_info_bar(target) }
        elsif state == :move_animation
          hide_info_bars
          hide_team_info
        end
      end
    end
  end