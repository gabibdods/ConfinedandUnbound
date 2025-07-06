class Game_Player
  def enter_state(state: :ladder)
    new_suffix = "_#{state}"
    STATE_APPEARANCE_SUFFIX[state] = new_suffix
    @state = state
    update_move_parameter(:walking)
    update_appearance(0)
  end
end