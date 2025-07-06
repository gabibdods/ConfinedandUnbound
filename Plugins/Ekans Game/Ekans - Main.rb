#===============================================================================
# Ekans Game
# By Swdfm
# General Page
#===============================================================================
def pbEkansGame
  Ekans_Interface_Main.new
end

#===============================================================================
module Ekans_Game
  SCREEN_Z          = 99_999
  SCREEN_Z_1        = SCREEN_Z + 1_000
  SCREEN_BASE       = Color.white
  SCREEN_SHADOW     = Color.black
  SCREEN_BACKGROUND = "Graphics/UI/Controls help/bg"
  SCREEN_PANEL_PATH = "Graphics/UI/Load/panels"
  # NOTE: Assumes selected version is straight underneath it
  #       and is the same size
  SCREEN_PANEL_DIMS     = [16, 444, 384, 46]
  # Duration in seconds
  SITRUS_BERRY_DURATION = 6.0
  BOARD_WIDTH           = 13
  BOARD_HEIGHT          = 16
  SQUARE_WIDTH          = 24
  SQUARE_HEIGHT         = 24
  
  def self.progress
    return $player.ekans_progress
  end
  
  def self.get_background
    return SCREEN_BACKGROUND
  end
  
  def self.panel_dims
    return SCREEN_PANEL_DIMS
  end
  
  def self.panel_dims_sel
    ret = SCREEN_PANEL_DIMS.clone
	ret[1] += ret[3]
	return ret
  end
  
  def self.frame_rate # FPS
    return 40
  end
  
  def self.board_dims
    return [
	  BOARD_WIDTH * SQUARE_WIDTH,
	  BOARD_HEIGHT * SQUARE_HEIGHT
	]
  end
end

