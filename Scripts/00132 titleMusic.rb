# Scene responsive of showing the title of the game
#
# It's being the first scene called when starting game without specific arguments.
# It's also the scene that gets called when the game soft resets.
#
# @note Due to how Scene_Title is designed, create_graphics will not be overloaded so the default viewport will be created
#       and other required graphics will be initialized / disposed when needed
class Scene_Title < GamePlay::BaseCleanUpdate
    # Create a new Scene_Title
    def initialize
      data_load
      super(true)
      @current_state = :psdk_splash_initialize
      @current_state = :action_play_game if debug? && ARGV.include?('skip_title')
      @splash_counter = 0
      @movie_map_id = Configs.scene_title_config.intro_movie_map_id || 0
    end
  
    # Update the input of the scene
    def update_inputs
      return false unless !@splash_animation || @splash_animation.done?
      return false unless !@title_controls || @title_controls.done?
  
      if @current_state != :title_animation
        send(@current_state)
        return false
        @running = false
        $scene = Scene_Title.new
      end
      
      action_play_game
      # if Input.trigger?(:A)
      #   action_a
      # elsif Input.trigger?(:UP)
      #   action_up
      # elsif Input.trigger?(:DOWN)
      #   action_down
      # else
      #   return true
      # end
      
      return false
    end
  
    # Update the graphics
    def update_graphics
      @splash_animation&.update
      @title_controls&.update
    end
  
    # Update the mouse
    def update_mouse(*)
      return unless @title_controls
  
      if @title_controls.index == 1 && @title_controls.play_bg.mouse_in?
        play_cursor_se
        @title_controls.index = 0
      elsif @title_controls.index == 0 && @title_controls.credit_bg.mouse_in?
        play_cursor_se
        @title_controls.index = 1
      elsif Mouse.trigger?(:LEFT)
        action_a if @title_controls.play_bg.mouse_in? || @title_controls.credit_bg.mouse_in?
      end
    end
  
    private
  
    # Function that loads a data through a thread
    # @param filename [String] name of the file to load
    # @param clean [Boolean] if the utf-8 objects names should be cleaned
    # @yieldparam data [Object] the loaded data
    def thread_load(filename, clean: true)
      @all_load_data_threads ||= []
      @all_load_data_threads << Thread.new do
        Thread.current.abort_on_exception = true
        data = load_data(filename)
        data = _clean_name_utf8(data) if clean
        yield(data)
      end
    end
  
    # Function that tells if all data was loaded
    # @return [Boolean]
    def all_data_loaded?
      return $data_actors unless @all_load_data_threads
  
      return @all_load_data_threads.none?(&:status)
    end
  end
