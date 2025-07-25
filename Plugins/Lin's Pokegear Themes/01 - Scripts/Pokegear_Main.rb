﻿#===============================================================================
# * Pokegear - by LinKazamine and CynderHydra (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It adds a themes the Pokégear.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

class PokemonSystem
  attr_accessor :pokegear
  
  alias pokegear_initialize initialize
  def initialize
    pokegear_initialize
    @pokegear      = "Theme 1"     # Pokegear's theme name
  end
end

class PokegearButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]
    @selected = false
    @button = AnimatedBitmap.new("Graphics/UI/Pokegear/#{$PokemonSystem.pokegear}/icon_button")
    @contents = Bitmap.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) +24, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = [
      [sprintf("Graphics/UI/Pokegear/icon_%s", @image), 50, 10]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegear_Scene
  def pbUpdate
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Pokegear/#{$PokemonSystem.pokegear}/bg")
    commands.each_with_index do |command, i|
      @sprites["button#{i}"] = PokegearButton.new(@commands[i], 0, 0, @viewport)
      button_height = @sprites["button#{i}"].bitmap.height / PokegearConfig::BUTTON_HEIGHT_SPACING
      column_height = Graphics.height -button_height
      column_count = (commands.length.to_f / 2).ceil
      column_index = i % PokegearConfig::NUM_COLUMNS
      column_x = Graphics.width / 2.73 - ((PokegearConfig::COLUMN_WIDTH + PokegearConfig::COLUMN_SPACING) * PokegearConfig::NUM_COLUMNS) / 2 + (PokegearConfig::COLUMN_WIDTH + PokegearConfig::COLUMN_SPACING) * column_index
      button_y = (column_height - (button_height * PokegearConfig::NUM_COLUMNS)) / 2 + (button_height * (i / PokegearConfig::NUM_COLUMNS))
      @sprites["button#{i}"].x = column_x + PokegearConfig::COLUMN_WIDTH / 2
      specialThemes = PokegearConfig::SPECIAL_THEME
      specialHeight = PokegearConfig::BUTTON_HEIGHT
      if specialThemes.include?($PokemonSystem.pokegear)
        index = specialThemes.find_index($PokemonSystem.pokegear)
        @sprites["button#{i}"].y = button_y + specialHeight[index] #Altura botones
      else
        @sprites["button#{i}"].y = button_y + 10 #Altura botones
      end
    end
    if PluginManager.installed?("Pokegear Watch")
      initialize_watch
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index = (@index - PokegearConfig::NUM_COLUMNS) % @commands.length
        update_selection
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index = (@index + PokegearConfig::NUM_COLUMNS) % @commands.length
        update_selection
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE if @commands.length > 1
        @index = (@index - 1 + @commands.length) % @commands.length
        update_selection
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE if @commands.length > 1
        @index = (@index + 1) % @commands.length
        update_selection
      end
    end
    return ret
  end
  
  def update_selection
    @commands.each_with_index do |command, i|
      @sprites["button#{i}"].selected = (i == @index)
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokegear_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
end