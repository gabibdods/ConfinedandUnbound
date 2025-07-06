#===============================================================================
# Ekans Game
# By Swdfm
# Interface: Hiscores Page
#===============================================================================
class Ekans_Interface_Hiscores
  def initialize
    @base_col = Ekans_Game::SCREEN_BASE
	@shad_col = Ekans_Game::SCREEN_SHADOW
    @progress = Ekans_Game.progress.hiscores
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = Ekans_Game::SCREEN_Z_1
    @sprites = {}
	# Background
	bg_path = Ekans_Game.get_background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(bg_path)
	# Text
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap, get_text_pos)
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
	  if Input.trigger?(Input::ACTION) ||
	     Input.trigger?(Input::BACK) ||
	     Input.trigger?(Input::USE)
	    break
	  end
    end
	pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites) 
  end
  
  def get_text_pos
    if @progress.empty?
      return [[
	    _INTL("No High Scores"),
		Graphics.width / 2,
		Graphics.height / 2 - 16, 2,
		@base_col, @shad_col
	  ]]
    end
    text_pos = []
	lhs_a = [_INTL("Score"), _INTL("Difficulty"), _INTL("Type")]
	lhs_a.each_with_index do |lhs, i|
	  x_pos = (Graphics.width * (1 + i) / 4).floor
	  text_pos.push([lhs, x_pos, 48, 2, @base_col, @shad_col])
	end
	@progress.each_with_index do |t_hs, i|
      score = t_hs[:Score].to_s_formatted
      diff  = t_hs[:Difficulty].to_s
      type  = Ekans_Game.field_name(t_hs[:Type])
	  t_y   = 96 + 32 * i
	  [score, diff, type].each_with_index do |rhs, i_r|
		x_pos = (Graphics.width * (1 + i_r) / 4).floor
		text_pos.push([rhs, x_pos, t_y, 2, @base_col, @shad_col])
      end
    end
	return text_pos
  end
end