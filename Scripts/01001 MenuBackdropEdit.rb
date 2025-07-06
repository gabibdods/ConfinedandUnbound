# Menu Edit
# Because we need to make those special backdrops show up somehow

module GamePlay
  # This is for the menu.
  # Should explain itself by looking at the functions involved
  class Menu < BaseCleanUpdate::FrameBalanced
    # Open the Party_Menu UI
    def open_party
      $game_variables[496] = 12 # For the party graphics
      # this stuff is the same dont edit it
      GamePlay.open_party_menu do |scene|
        Yuki::FollowMe.update
        @background.update_snapshot
        if scene.call_skill_process
          @call_skill_process = scene.call_skill_process
          @running = false
          Graphics.transition
        end
      end
      $game_variables[496] = 0 # ok go back to normal
    end

    # Open the TCard UI
    def open_tcard
      GamePlay.open_player_information
    end

    # Open the Save UI
    def open_save
      $game_variables[496] = 10 # For the save graphics
      # this stuff is the same dont edit it
      @in_save = true
      call_scene(Save) do |scene|
        @running = false if scene.saved
        Graphics.transition
      end
      @in_save = false
      $game_variables[496] = 0 # ok go back to normal
    end

    # Open the Options UI
    def open_option
      $game_variables[496] = 11 # For the options graphics
      # this stuff is the same dont edit it
      GamePlay.open_options do |scene|
        if scene.modified_options.include?(:language)
          @running = false
          Graphics.transition
        end
      end
      $game_variables[496] = 0 # ok go back to normal
    end
  end

  # This is just for the keybinding menu.
  class KeyBinding < BaseCleanUpdate::FrameBalanced
    # Create a new KeyBinding UI
    def initialize
      super
      $game_variables[496] = 13 # For the controls graphics
      @cool_down = 0
    end  

    # When the player presses B in navigation mode
    def action_b_nav
      KeyBinding.save_inputs
      $game_variables[496] = 0 # ok go back to normal
      return @running = false
    end
  end

  # i hope i know what im doing
  # update - i did
  class Save < Load
    # Hey guys, Aqua here. You might be wondering why I had to edit this function.
    # Whenever the game would save, it would save all game variables as is, which is great, but...
    # It's not good for the menu variable! It always thinks that we're on value 10.
    # With this, we now have a way to reset the variable back to normal.
    def save_game
      $game_variables[496] = 0 # ok go back to normal
      Save.save
    end
  end
end
