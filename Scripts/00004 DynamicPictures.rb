def show_player_portrait(mood: :neutral, number: 50, x: 30, y: 136, zoom_x: 50, zoom_y: 50)
    case $game_variables[111]
    when 1 # Charmander
      base = "charmander_"
    when 2 # Chikorita
      base = "chikorita_"
    when 3 # Mudkip
      base = "mudkip_"
    when 4 # Turtwig
      base = "turtwig_"
    when 5 # Oshawott
      base = "oshawott_"
    when 6 # Fennekin
      base = "fennekin_"
    when 7 # Popplio
      base = "popplio_"
    when 8 # Chespin GROOKEY HAS BEEN ANNIHILATED FROM THE GAME DUE TO NOT HAVING ANY PORTRAITS RAHH
      base = "chespin_"
    when 9 # Fuecoco
      base = "fuecoco_"
    when 10 # Phanpy
      base = "phanpy_"
    when 11 # Riolu
      base = "riolu_"
    when 12 # Mincinno
      base = "minccino_"
    end

    dir = "portraits/"
    filename = dir + base + mood.to_s
    $game_screen.pictures[number].show(filename, 0, x, y, zoom_x, zoom_y, 255, 0)
    return true
  end

  def show_npc_portrait(mood: :neutral, number: 50, x: 30, y: 136, zoom_x: 50, zoom_y: 50)
    dir = "portraits/"
    filename = dir + mood.to_s
    $game_screen.pictures[number].show(filename, 0, x, y, zoom_x, zoom_y, 255, 0)
    return true
  end