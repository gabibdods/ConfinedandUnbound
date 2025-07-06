PFM::ItemDescriptor.define_bag_use(:tiny_apple, true) do |item, scene|
  GamePlay.open_party_menu_to_select_pokemon($actors)
  if $game_variables[43] != -1
    # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
    amount = 500
    $scene.display_message("Gained 500 experience points!")
    $game_system.map_interpreter.give_exp($game_variables[43], amount)
  else
    next :unused
  end
end

PFM::ItemDescriptor.define_bag_use(:chestnut, true) do |item, scene|
    GamePlay.open_party_menu_to_select_pokemon($actors)
    if $game_variables[43] != -1
      # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
      amount = 800
      $scene.display_message("Gained 800 experience points!")
      $game_system.map_interpreter.give_exp($game_variables[43], amount)
    else
      next :unused
    end
  end

  PFM::ItemDescriptor.define_bag_use(:apple, true) do |item, scene|
    GamePlay.open_party_menu_to_select_pokemon($actors)
    if $game_variables[43] != -1
      # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
      amount = 3000
      $scene.display_message("Gained 3000 experience points!")
      $game_system.map_interpreter.give_exp($game_variables[43], amount)
    else
      next :unused
    end
  end

  PFM::ItemDescriptor.define_bag_use(:big_apple, true) do |item, scene|
    GamePlay.open_party_menu_to_select_pokemon($actors)
    if $game_variables[43] != -1
      # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
      amount = 10000
      $scene.display_message("Gained 10000 experience points!")
      $game_system.map_interpreter.give_exp($game_variables[43], amount)
    else
      next :unused
    end
  end

  PFM::ItemDescriptor.define_bag_use(:huge_apple, true) do |item, scene|
    GamePlay.open_party_menu_to_select_pokemon($actors)
    if $game_variables[43] != -1
      # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
      amount = 30000
      $scene.display_message("Gained 30000 experience points!")
      $game_system.map_interpreter.give_exp($game_variables[43], amount)
    else
      next :unused
    end
  end

  PFM::ItemDescriptor.define_bag_use(:perfect_apple, true) do |item, scene|
    GamePlay.open_party_menu_to_select_pokemon($actors)
    if $game_variables[43] != -1
      # pokemon = $actors[$game_variables[43]] keeping for when we eventually add the EXP animation
      amount = 50000
      $scene.display_message("Gained 50000 experience points!")
      $game_system.map_interpreter.give_exp($game_variables[43], amount)
    else
      next :unused
    end
  end