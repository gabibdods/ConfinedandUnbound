module Ranko
  # Specialized Gif sprite
  class GifSprite < ShaderedSprite
    # Create a new GifSprite
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    def initialize(viewport, bitmap)
      super(viewport)
      load(bitmap)
    end

    # Update the sprite
    def update
      @gif&.update(bitmap)
    end
    def load(bitmap)
      @gif = Yuki::GifReader.new(RPG::Cache.picture(bitmap), true)
      self.bitmap = Texture.new(@gif.width, @gif.height)
    end
  end
end
