#===============================================================================
# Ekans Game
# By Swdfm
# Data Page
#===============================================================================
class Ekans_Game_Data
  attr_accessor :ate_oran_berry
  attr_accessor :ate_sitrus_berry
  attr_accessor :board
  attr_accessor :character
  attr_accessor :decision
  attr_accessor :difficulty
  attr_accessor :field_type
  attr_accessor :frames_per_action
  attr_accessor :needs_update
  attr_accessor :score
  attr_accessor :sitrus_display
  attr_accessor :sitrus_timer
  attr_accessor :snake
  def initialize
  end
  
  def start_new_game
	set_up_board
    p = Ekans_Game.progress.clone
	@ate_oran_berry    = false
	@ate_sitrus_berry  = false
    @character         = p.character
	@decision          = nil
	# NOTE: difficulty saved for hiscores
    @difficulty        = p.difficulty
	speed              = 2 + 0.8 * @difficulty
	speed             += 1 if speed > 7 # All speeds are different
	@field_type        = p.game_type
	@frames_per_action = (Ekans_Game.frame_rate / speed).round
	@needs_update      = false
    @score             = 0
    @sitrus_display    = 0 # Secs shown on screen! (int)
    @sitrus_timer      = 0 # Time actually left! (float)
  end
  
  def set_up_board
    # Board is hash
	# Keys are always [x, y]
	# Values can be: :metal, :head, :body, :oran, :sitrus
    @board = {}
	# Sets Up Metal
	for k, v in Ekans_Game.compile_metal
	  x, y = k
	  @board[[x, y]] = :metal
	end
	@snake = Ekans_Snake.new
	h = find_snake_space
	unless h
	  raise "Snake cannot find a good amount of space to spawn!"
	end
	h, b, t, d  = h
	@snake.head = h
	@snake.body = [b, t]
	@snake.direction = d
	@board[h] = :head
	@board[b] = :body
	@board[t] = :body
  end
  
  def space_occupied?(x, y, danger = true) # Dangerous!
    return false unless @board[[x, y]]
	return true unless danger
	return !([:oran, :sitrus].include?(@board[[x, y]]))
  end
  
  def find_empty_space # For Head 1 and Berries
    loop do
	  r_x = rand(Ekans_Game::BOARD_WIDTH)
	  r_y = rand(Ekans_Game::BOARD_HEIGHT)
	  unless space_occupied?(r_x, r_y, false)
	    return [r_x, r_y]
	  end
	end
  end
  
  def tile_after_direction(d = nil, h = nil)
    d = @snake.direction unless d
    h = @snake.head unless h
    t_x, t_y = h
	case d
	when 2 then t_y += 1
	when 4 then t_x -= 1
	when 6 then t_x += 1
	when 8 then t_y -= 1
	end
	b_w = Ekans_Game::BOARD_WIDTH
	b_h = Ekans_Game::BOARD_HEIGHT
	t_x = b_w - 1 if t_x < 0
	t_x = 0 if t_x >= b_w
	t_y = b_h - 1 if t_y < 0
	t_y = 0 if t_y >= b_h
	return [t_x, t_y]
  end
  
  def find_snake_space
	200.times do
	  h = find_empty_space
	  # Find Safe Starting Directon
	  for d, d_1 in [[2, 8], [4, 6]].shuffle
	    t_x, t_y = tile_after_direction(d, h)
		next if space_occupied?(t_x, t_y)
	    t_x, t_y = tile_after_direction(d_1, h)
		next if space_occupied?(t_x, t_y)
		# Looks for third space
		perp = [2, 4, 6, 8]
		perp.delete(d) ; perp.delete(d_1)
		for t_d in [d, d_1]
		  t_loc = tile_after_direction(t_d, h)
		  for t_d_1 in [d] + perp
		    t_x_1, t_y_1 = tile_after_direction(t_d_1, t_loc)
		    next if space_occupied?(t_x_1, t_y_1)
			return [
			  h, # Head space
			  t_loc, # Body space 1
			  [t_x_1, t_y_1], # Body space 2
			  10 - t_d # Head direction
			]
		  end
		end
	  end
	end
	return nil
  end
  
  def make_move
    if @decision
      @snake.direction = @decision
	  @decision = nil
	end
	n_x, n_y = tile_after_direction.clone
	return false if space_occupied?(n_x, n_y) # Loss
	new_tile = [n_x, n_y]
	# Adds head to body
    # Removes last tile from snake and board
	#  unless ate an Oran Berry the turn before
	unless @ate_oran_berry
	  last_tile = @snake.body.pop
	  @board.delete(last_tile)
	end
	h = @snake.head.clone
	@snake.body.unshift(h)
	@snake.head       = new_tile
	@ate_oran_berry   = false
	@ate_sitrus_berry = false
	if @board[[n_x, n_y]]
	  case @board[[n_x, n_y]]
	  when :oran
	    @ate_oran_berry = true
	  when :sitrus
	    @ate_sitrus_berry = true
	  end
	end
	# Change head to Tail
	for k, v in @board
	  next unless v == :head
	  @board[k] = :body
	end
	# Add Head To Board
	@board[[n_x, n_y]] = :head
	return true
  end
  
  def clear_sitrus_berry
    for k, v in @board
	  next unless v == :sitrus
	  @board.delete(k)
	end
  end
end