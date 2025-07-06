module Battle
    class Scene
      def show_wild_event_message(*messages)
        visual.lock do
          # => Show all messages
          messages.each do |message|
            # Tell message box to let player read
            message_window.blocking = true
            message_window.wait_input = true
            # Actually show the message
            display_message_and_wait(message)
          end
        end
      end
  
      def show_wild_choice_message(message, start, *choices)
          visual.lock do
          # => Show all messages
            # Tell message box to let player read
            message_window.blocking = true
            message_window.wait_input = true
            # Actually show the message
            @result = display_message_and_wait(message, start, *choices)   
          end
        return @result
      end
    end
  end