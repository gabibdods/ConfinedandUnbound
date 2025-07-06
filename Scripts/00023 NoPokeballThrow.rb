module BattleUI
    # Sprite of a Pokemon in the battle
    class PokemonSprite < ShaderedSprite
      include GoingInOut
      include MultiplePosition
      # Constant giving the deat Delta Y (you need to adjust that so your screen animation are OK when Pokemon are KO)
      DELTA_DEATH_Y = 32
      # Tell if the sprite is currently selected
      # @return [Boolean]
      attr_accessor :selected
      # Get the Pokemon shown by the sprite
      # @return [PFM::PokemonBattler]
      attr_reader :pokemon
      # Get the animation handler
      # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
      attr_reader :animation_handler
      # Get the position of the pokemon shown by the sprite
      # @return [Integer]
      attr_reader :position
      # Get the bank of the pokemon shown by the sprite
      # @return [Integer]
      attr_reader :bank
      # Get the scene linked to this object
      # @return [Battle::Scene]
      attr_reader :scene
  
      # Create a new PokemonSprite
      # @param viewport [Viewport]
      # @param scene [Battle::Scene]
      def initialize(viewport, scene)
        super(viewport)
        @shadow = ShaderedSprite.new(viewport)
        @shadow.shader = Shader.create(:battle_shadow)
        @animation_handler = Yuki::Animation::Handler.new
        @bank = 0
        @position = 0
        @scene = scene
      end
  
      # Update the sprite
      def update
        @animation_handler.update
        @gif&.update(bitmap) unless pokemon&.dead?
      end
  
      # Tell if the sprite animations are done
      # @return [Boolean]
      def done?
        return @animation_handler.done?
      end
  
      # Set the Pokemon
      # @param pokemon [PFM::PokemonBattler]
      def pokemon=(pokemon)
        @pokemon = pokemon
        if pokemon
          @position = pokemon.position
          @bank = pokemon.bank
          load_battler
          reset_position
        end
      end
  
      # Play the cry of the Pokemon
      # @param dying [Boolean] if the Pokemon is dying
      def cry(dying = false)
        return unless pokemon
  
        Audio.se_play(pokemon.cry, 100, dying ? 80 : 100)
      end
  
      # Set the position of the sprite
      # @param x [Numeric]
      # @param y [Numeric]
      # @return [self]
      def set_position(x, y)
        @shadow.set_position(x, y)
        super
      end
  
      # Creates the flee animation
      # @return [Yuki::Animation::TimedAnimation]
      def flee_animation
        bx = enemy? ? viewport.rect.width + width : -width
        ya = Yuki::Animation
        animation = ya.move(0.5, self, x, y, bx, y)
        animation.parallel_add(ya::ScalarAnimation.new(0.5, self, :opacity=, 255, 0))
        animation.parallel_add(ya.se_play('fleee', 100, 60))
        animation.start
        animation_handler[:in_out] = animation
      end
  
      private
  
      # Creates the go_in animation (Exiting the ball)
      # @return [Yuki::Animation::TimedAnimation]
      def go_in_animation
        no_ball_trainer = $game_switches[Yuki::Sw::BT_NO_BALL_ANIMATION] && enemy?
        return follower_go_in_animation
      end
  
      # Creates the go_out animation (Entering the ball if not KO, shading out if KO)
      # @return [Yuki::Animation::TimedAnimation]
      def go_out_animation
        return follower_go_out_animation
      end
  
      # Creates the go_out animation of a "follower" pokemon
      # @return [Yuki::Animation::TimedAnimation]
      def follower_go_out_animation
        x, y = sprite_position
        bx = enemy? ? viewport.rect.width + width : -width
        return Yuki::Animation.move(0.1, self, x, y, bx, y)
      end
  
      # Create the go_out animation of a KO pokemon
      # @return [Yuki::Animation::TimedAnimation]
      def ko_go_out_animation
        ya = Yuki::Animation
        animation = ya.send_command_to(self, :cry, true)
        going_down = ya.opacity_change(0.1, self, opacity, 0)
        animation.play_before(going_down)
        going_down.parallel_add(ya.move(0.1, self, x, y, x, y + DELTA_DEATH_Y))
  
        return animation
      end
  
      # SE played when the ball is sent
      def sending_ball_se
        return 'fall'
      end
  
      # Pokemon sprite zoom
      # @return [Integer]
      def sprite_zoom
        return 1
      end
    end
  end