#===============================================================================
# Ekans Game
# By Swdfm
# Interface: Main Page
#===============================================================================
class Ekans_Interface_Main
  def initialize
    @base_col = Ekans_Game::SCREEN_BASE
	@shad_col = Ekans_Game::SCREEN_SHADOW
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = Ekans_Game::SCREEN_Z
    @sprites = {}
	# Background
	bg_path = Ekans_Game.get_background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(bg_path)
	# For Panels/Text
	p_path = Ekans_Game::SCREEN_PANEL_PATH
	@panel_bitmap = AnimatedBitmap.new(p_path)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @index = 0
    draw
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
    main_loop
	pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end
  
  def draw
    @options = Ekans_Game.get_available_options
	bmp      = @sprites["overlay"].bitmap
	bmp.clear
	@index   = 0 if @index >= @options.length
	text_pos = []
	@options.each_with_index do |opt, i|
	  # Panel
	  dims = i == @index ? Ekans_Game.panel_dims_sel : Ekans_Game.panel_dims
	  p_x, p_y, p_w, p_h = dims
	  t_x = Graphics.width - p_w
	  t_x = [(t_x / 2).floor, 0].max
	  gap = Graphics.height - p_h * @options.length
	  gap = (gap / (@options.length + 1)).floor
	  t_y = gap + i * (p_h + gap)
	  bmp.blt(t_x, t_y, @panel_bitmap.bitmap, Rect.new(p_x, p_y, p_w, p_h))
	  # Text
	  txt_x = t_x + (p_w / 2).floor
	  txt_y = t_y + (p_h / 2).floor - 8
	  lhs = Ekans_Game.option_name(opt)
	  rhs = Ekans_Game.rhs_text(opt)
	  unless rhs == ""
		lhs += ": "
	  end
	  txt = _INTL("{1}{2}", lhs, rhs)
	  text_pos.push([txt, txt_x, txt_y, 2, @base_col, @shad_col])
	end
   	pbDrawTextPositions(bmp, text_pos)
  end
  
  def main_loop
    loop do
      Graphics.update
      Input.update
	  @do_refresh = false
      old_index = @index
      if Input.trigger?(Input::USE)
		case do_action
		when :refresh
          @do_refresh = true
        when :close
          break
        end
      elsif Input.trigger?(Input::DOWN)
	    @index += 1
        @index = 0 if @index >= @options.length
      elsif Input.trigger?(Input::UP)
	    @index -= 1
        @index = @options.length - 1 if @index < 0
	  elsif Input.trigger?(Input::LEFT)
        c = @options[@index]
	    @do_refresh = Ekans_Game.move_value_menu(c)
	  elsif Input.trigger?(Input::RIGHT)
        c = @options[@index]
	    @do_refresh = Ekans_Game.move_value_menu(c, true)
      elsif Input.trigger?(Input::BACK)
        break
      end
	  if @index != old_index || @do_refresh
	    pbPlayCursorSE
        draw
	  end
    end
  end
  
  def do_action
    case @options[@index]
	when :new_game
	  pbPlayDecisionSE
	  Ekans_Interface_Game.new
      return :refresh
	when :continue
	  pbPlayDecisionSE
	  Ekans_Interface_Game.new(true)
      return :refresh
	when :hiscores
	  pbPlayDecisionSE
	  Ekans_Interface_Hiscores.new
      return :refresh
	when :exit
      return :close
	end
	return :Nothing
  end
end