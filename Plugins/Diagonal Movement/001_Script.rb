class Game_Player < Game_Character

  def allow_diagonal_movement
    return Settings::ALLOW_DIAGONAL_MOVEMENT && ($PokemonSystem.diagmovement == 0 || $PokemonSystem.diagmovement.nil?)
  end

  alias allow_diag_movement_update_com update_command_new
  def update_command_new
    return update_command_new_8_diag if allow_diagonal_movement
    allow_diag_movement_update_com
  end
  
  def update_command_new_8_diag
    dir = Input.dir8
    if $PokemonGlobal.forced_movement?
      move_forward
    elsif !pbMapInterpreterRunning? && !$game_temp.message_window_showing &&
          !$game_temp.in_mini_update && !$game_temp.in_menu
      # Move player in the direction the directional button is being pressed
      if @moved_last_frame ||
         (dir > 0 && dir == @lastdir && System.uptime - @lastdirframe >= 0.075)
        case dir
        when 1 then move_lower_left
        when 2 then move_down
        when 3 then move_lower_right
        when 4 then move_left
        when 6 then move_right
        when 7 then move_upper_left
        when 8 then move_up
        when 9 then move_upper_right
        end
      elsif dir != @lastdir
        case dir
        when 1 then move_lower_left
        when 2 then turn_down
        when 3 then move_lower_right
        when 4 then turn_left
        when 6 then turn_right
        when 7 then move_upper_left
        when 8 then turn_up
        when 9 then move_upper_right
        end
      end
      # Record last direction input
      @lastdirframe = System.uptime if dir != @lastdir
      @lastdir = dir
    end
  end
end

class PokemonSystem
  attr_accessor :diagmovement
  alias allow_diag_movement_syst_init initialize
  def initialize
	allow_diag_movement_syst_init
	@diagmovement = 0
  end

end

MenuHandlers.add(:options_menu, :diag_movement, {
  "name"        => _INTL("Diagonal Movement"),
  "order"       => 62,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you can move diagonally."),
  "condition"   => proc { next Settings::ALLOW_DIAGONAL_MOVEMENT && Settings::CHANGE_DIAGONAL_MOVEMENT_IN_OPTIONS },
  "get_proc"    => proc { next $PokemonSystem.diagmovement },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.diagmovement = value }
})