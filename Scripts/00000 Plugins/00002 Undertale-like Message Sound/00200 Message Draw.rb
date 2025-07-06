module UI
  module Message
    # Module defining the drawing methods of messages
    module Draw
      # @!parse include Transition

      private

      # Start the text animation
      def start_text_animation
        sizeid = bigger_text? ? 1 : current_layout.default_font
        text = text_stack.add_text(@text_x, @text_y, 0, default_line_height, current_instruction.text, color: @color, sizeid: sizeid)
        @text_x += current_instruction.width
        load_text_style(text)
        speed = (@current_speed == 0 ? $options&.message_speed : @current_speed) || 1
        @bloop_counter = 0
        text_updater = proc do |v|
          text.nchar_draw = v.to_i
          if properties.bloop_sound && (@bloop_counter <= text.nchar_draw % (properties.bloop_modulo || default_bloop_modulo))
            Audio.se_play(*properties.bloop_sound)
            @bloop_counter += 1
          end
        end
        duration = current_instruction.text.size / (speed * character_speed.to_f)
        @text_animation = Yuki::Animation.scalar(duration, text_updater, :call, 0, current_instruction.text.size)
        @text_animation.start
        @wait_animation = nil
      end

      def default_bloop_modulo
        return 8
      end
    end
  end
end
