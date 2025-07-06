#===============================================================================
# Ekans Game
# By Swdfm
# Progress Page
#===============================================================================
class Player < Trainer
  def ekans_progress
    unless @ekans_progress
	  @ekans_progress = Ekans_Progress.new
	end
	return @ekans_progress
  end
end

class Ekans_Progress
  attr_accessor :in_game
  attr_accessor :game_type
  attr_accessor :character
  attr_accessor :difficulty
  attr_accessor :hiscores
  attr_accessor :game_data
  def initialize
    @in_game    = false
    @game_type  = Ekans_Game::get_default_field
    @character  = Ekans_Game::get_default_character
    @difficulty = 0
	@hiscores   = [] # An array of hashes!
	@game_data  = Ekans_Game_Data.new
  end
end