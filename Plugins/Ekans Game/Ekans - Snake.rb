#===============================================================================
# Ekans Game
# By Swdfm
# Snake Page
#===============================================================================
class Ekans_Snake
  attr_accessor :body
  attr_accessor :direction
  attr_accessor :head
  def initialize
    @direction = 2
    @head      = nil
	@body      = []
  end
end