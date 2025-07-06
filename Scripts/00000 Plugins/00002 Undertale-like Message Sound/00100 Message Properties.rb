# frozen_string_literal: true

module PFM
  module Message
    # Class holding all the properties for the currently showing message
    class Properties
      # Initializing the bloop_sound message tag and its corresponding parse method
      PROPERTIES['bloop_sound'] = :parse_bloop_sound

      # Initializing the bloop_mod message tag and its corresponding parse method
      PROPERTIES['bloop_mod'] = :parse_bloop_mod

      # Return the filename of the sound to play
      # @return [Array]
      attr_reader :bloop_sound
      # Return the modulo used to play the bloops
      # (I definitely use "bloops" a little too much, do I?)
      # @return [Integer]
      attr_reader :bloop_modulo

      # Parse the string sent to this method and get the filename and the eventual modulo
      # @param str [String]
      def parse_bloop_sound(str)
        params = str.split(',')
        params[0] = "audio/se/#{params[0]}"
        params[1] = params[1].to_i if params[1]
        params[2] = params[2].to_i if params[2]
        if params[3]
          @bloop_modulo = params[3].to_i
          params.pop
        end
        @bloop_sound = params
      end

      # Parse the string sent to this method and get the filename and the eventual modulo
      # @param str [String] the modulo for this bloop sound
      def parse_bloop_mod(str)
        @bloop_modulo = str.to_i
      end
    end
  end
end

module Rey
  module BloopSound
    def initialize(parsed_text)
      @bloop_sound = nil
      @bloop_modulo = nil
      super(parsed_text)
    end
  end
end

PFM::Message::Properties.prepend(Rey::BloopSound)
