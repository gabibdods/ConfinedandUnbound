module UI
  # Generica base UI for most of the scenes
  class GenericBase < SpriteStack
    # @return [Array<Symbol>] keys shown in the button
    attr_reader :keys
    # @return [Array<String>] the texts shown in the button
    attr_reader :button_texts
    # @return [Array<ControlButton>] the control buttons
    attr_reader :ctrl
    # @return [Sprite]
    attr_reader :background
    # List of key by default
    DEFAULT_KEYS = %i[A X Y B]
    # List of button to hide when a text is shown
    BUTTON_TO_HIDE = 0..2
    # Create a new GenericBase UI
    # @param viewport [Viewport]
    # @param texts [Array<String>] list of texts shown in the ControlButton
    # @param keys [Array<Symbol>] list of keys used in the ControlButton
    # @param hide_background_and_button [Boolean] tell if we don't want to show the button and its bar
    def initialize(viewport, texts = [], keys = DEFAULT_KEYS, hide_background_and_button: false)
      super(viewport)
      @keys = keys
      create_graphics
      self.button_texts = texts
      if hide_background_and_button
        @button_background.visible = false
        @ctrl.each {|button| button.visible = false}
      end
    end

    # Set the keys of the buttons
    # @param value [Array<Symbol>] the 4 key to show
    def keys=(value)
      @keys = value
      @ctrl.each_with_index { |button, index| button.key = value[index] }
    end

    # Set the texts of the buttons
    # @param value [Array<String>]
    def button_texts=(value)
      @button_texts = value
      @ctrl.each_with_index do |button, index|
        next unless (button.visible = !value[index].nil?)
        button.text = value[index]
      end
    end

    # Show the "win text" (bottom text giving information to the player)
    # @param text [String] text to show
    def show_win_text(text)
      hidden_button_indexes.each { |i| @ctrl[i].visible = false }
      text_sprite = win_text
      text_sprite.visible = true
      text_sprite.text = text
      @win_text_background.visible = true
    end

    # Hide the "win text"
    def hide_win_text
      hidden_button_indexes.each { |i| @ctrl[i].visible = true }
      win_text.visible = false
      @win_text_background.visible = false
    end

    # Tell if the win text is visible
    # @return [Boolean]
    def win_text_visible?
      @win_text_background&.visible
    end

    # Update the background animation
    def update_background_animation
      @on_update_background_animation&.call
      @background_animation&.update
    end

    private

    def create_graphics
      create_background
      create_background_bottom
      create_background_top
      create_button_background
      create_control_button
    end

    def create_background
      @background = add_background(background_filename).set_z(-13)
      create_background_animation
    end

    def create_background_bottom
      @background_bottom = add_background(background_bottom_filename).set_z(-15)
    end

    def create_background_top
      @background_top = add_background(background_top_filename).set_z(-10)
    end

    def create_background_animation
      ya = Yuki::Animation
      # Failsafe check to see if a save file exists first
      if $game_variables == nil
        duration = 6.6
      # Otherwise, continue as normal
      else
        case $game_variables[496]
          when 0 # Default
            duration = 6.6

          # Facilities
          when 1 # Vespiquen
            duration = 13.2
          when 2..3 # Kecleon (Green / Pink)
            duration = 13.2
          when 4 # Smeargle
            duration = 13.2
          when 5 # RESERVED
            duration = 13.2
          when 6 # RESERVED
            duration = 13.2
          when 7 # RESERVED
            duration = 13.2

          # System
          when 10 # Saving
            duration = 13.2
          when 11 # Options
            duration = 6.6
          when 12 # Party
            duration = 13.2
          when 13 # Controls
            duration = 6.6
          
          # Failsafe
          else
            duration = 6.6
        end
      end
      
      @background_animation = ya.timed_loop_animation(duration)

      # Failsafe check to see if a save file exists first
      if $game_variables == nil
        @background_animation.play_before(ya.shift(duration, @background, 160, 0, 0, 0))
      # Otherwise, continue as normal
      else
        case $game_variables[496]
          when 0 # Default
            @background_animation.play_before(ya.shift(duration, @background, 160, 0, 0, 0))

          # Facilities
          when 1 # Vespiquen
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          when 2 # Kecleon (Green)
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          when 3 # Kecleon (Pink)
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          
          # System
          when 10 # Saving
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          when 11 # Options
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          when 13 # Controls
            @background_animation.play_before(ya.shift(duration, @background, 320, 0, 0, 0))
          
          # Failsafe
          else # the actual default
            @background_animation.play_before(ya.shift(duration, @background, 160, 0, 0, 0))
        end
      end

      @on_update_background_animation = proc do
        @background_animation.start
        @on_update_background_animation = nil
      end
    end

    def create_button_background
      @button_background = add_sprite(0, 214, button_background_filename).set_z(500)
    end

    # Return the name of the background
    # @return [String]
    def background_filename
      # Failsafe check to see if a save file exists first
      if $game_variables == nil
        base =  'team/Fond'
      # Otherwise, continue as normal
      else
        case $game_variables[496]
          when 0 # Default
            base =  'team/Fond'
          
          # Facilities
          when 1 # Vespiquen
            base = 'team/craft2'
          when 2 # Kecleon (Green)
            base = 'shop/backdrop/shop-green2'
          when 3 # Kecleon (Pink)
            base = 'shop/backdrop/shop-pink2'
    
          # System
          when 10 # Saving
            base = 'load/backdrop/save2'
          when 11 # Options
            base = 'options/backdrop/options2'
          when 13 # Controls
            base = 'options/backdrop/options2'
          
          # Failsafe
          else
            base =  'team/Fond'
          end
        end
    end

    def background_bottom_filename
      # Failsafe check to see if a save file exists first
      if $game_variables == nil
        base =  'team/background_top'
      # Otherwise, continue as normal
      else
        case $game_variables[496]
          when 0 # Default
            base =  'team/background_bottom'

          # Facilities
          when 1 # Vespiquen
            base = 'team/craft1'
          when 2 # Kecleon (Green)
            base = 'shop/backdrop/shop-green1'
          when 3 # Kecleon (Pink)
            base = 'shop/backdrop/shop-pink1'

          # System
          when 10 # Saving
            base = 'load/backdrop/save1'
          when 11 # Options
            base = 'options/backdrop/options1'
          when 13 # Controls
            base = 'options/backdrop/options1'

          # Failsafe
          else
            base =  'team/background_bottom'
        end
      end
    end

    def background_top_filename
      # Failsafe check to see if a save file exists first
      if $game_variables == nil
        base =  'team/background_top'
      # Otherwise, continue as normal
      else
        case $game_variables[496]
          when 0 # Default
            base = 'team/background_top'

          # Facilities
          when 1 # Vespiquen
            base = 'team/craft3'
          when 2 # Kecleon (Green)
            base = 'shop/backdrop/shop-green3'
          when 3 # Kecleon (Pink)
            base = 'shop/backdrop/shop-pink3'
          
          # System
          when 10 # Saving
            base = 'load/backdrop/save3'
          when 11 # Options
            base = 'options/backdrop/options3-options'
          when 13 # Controls
            base = 'options/backdrop/options3-controls'

          # Failsafe
          else
            base = 'team/background_top'
        end
      end
    end

    # Create the control buttons
    def create_control_button
      # @type [Array<ControlButton>]
      @ctrl = Array.new(4) { |index| ControlButton.new(@viewport, index, @keys[index]) }
    end

    # Return the win_text and create it if needed
    # @return [Text]
    def win_text
      @win_text_background ||= add_sprite(0, 217, 'team/Win_Txt').set_z(502)
      @win_text ||= add_text(5, 222, 238, 15, nil.to_s, color: 9)
      @win_text.z = 502
      @win_text
    end

    # Return the list of hidden button when win_text is shown
    # @return [#each]
    def hidden_button_indexes
      BUTTON_TO_HIDE
    end

    # Generic Button used to help the player to know what key he can press
    class ControlButton < SpriteStack
      # Array of button coordinates
      COORDINATES = [[3, 219], [83, 219], [163, 219], [243, 219]]
      # Create a new Button
      # @param viewport [Viewport]
      # @param coords_index [Integer] index of the coordinates to use in order to position the button
      # @param key [Symbol] key to show by default
      def initialize(viewport, coords_index, key)
        super(viewport, *COORDINATES[coords_index], default_cache: :pokedex)
        @background = add_background('buttons')
        # @type [KeyShortcut]
        @key_button = add_sprite(0, 1, NO_INITIAL_IMAGE, key, type: KeyShortcut)
        with_font(text_font) { @text = add_text(17, 3, 51, 13, nil.to_s, color: text_color(coords_index)) }
        @coords_index = coords_index
        self.pressed = false
        self.z = 501
      end

      # Set the button pressed
      # @param pressed [Boolean] if the button is pressed or not
      def pressed=(pressed)
        @background.set_rect_div(@coords_index == 3 ? 1 : 0, pressed ? 1 : 0, 2, 2)
        @background.src_rect.x += 1 if @coords_index == 3
        @background.src_rect.y += 1 if pressed
      end
      alias set_press pressed=

      # Set the text shown by the button
      # @param value [String] text to show
      def text=(value)
        return unless value.is_a?(String) || value.nil?

        @text.text = value if value
        self.visible = (value ? true : false)
      end

      # Set the key shown by the button
      # @param value [Symbol]
      def key=(value)
        return unless value.is_a?(Symbol)
        @key_button.find_key(value)
      end

      private

      # Retrieve the color of the text
      # @param coords_index [Integer] index of the coordinates to use in order to position the button
      # @return [Integer]
      def text_color(coords_index)
        coords_index == 3 ? 21 : 20
      end

      # Retrieve the id of the font used to show the text
      # @return [Integer]
      def text_font
        20
      end
    end
  end
  # Generic base allowing multiple button mode by initilizing it with all the value for keys & texts
  class GenericBaseMultiMode < GenericBase
    # @return [Integer] current mode of the UI
    attr_reader :mode
    # Create a new GenericBase UI
    # @param viewport [Viewport]
    # @param texts [Array<Array<String>>] list of texts shown in the ControlButton
    # @param keys [Array<Array<Symbol>>] list of keys used in the ControlButton
    def initialize(viewport, texts, keys, mode = 0)
      raise 'Text array & key array should have the same size' if texts.size != keys.size
      @texts_array = texts
      @keys_array = keys
      @mode = mode.clamp(0, keys.size)
      super(viewport, texts[@mode], keys[@mode])
    end

    # Set the mode to change the button display
    def mode=(value)
      @mode = value.clamp(0, @keys_array.size)
      self.button_texts = @texts_array[@mode]
      self.keys = @keys_array[@mode]
    end
  end
end
