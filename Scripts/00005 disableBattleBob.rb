module Battle
  class Visual
    class IdlePokemonAnimation
    # Pixel offset for each index of the sprite
    OFFSET_SPRITE = [0]
    # Pixel offset for each index of the bar
    OFFSET_BAR = [0, 1, 0, 1]
	# Function that moves the pokemon using the relative offset specified by 
      def move_pokemon(index)
        return if @pokemon.out?

        @pokemon.y = @pokemon_origin.last + OFFSET_SPRITE[index]
      end
    end
  end
end