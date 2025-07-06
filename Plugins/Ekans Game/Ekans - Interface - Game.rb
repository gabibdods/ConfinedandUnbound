#===============================================================================
# Ekans Game
# By Swdfm
# Interface: Game Page
#===============================================================================
# TODO Order these in decent order!
class Ekans_Interface_Game
  def initialize(continue_game = false)
    @progress      = Ekans_Game.progress
    @adapter       = @progress.game_data
    @base_col      = Ekans_Game::SCREEN_BASE
	@shad_col      = Ekans_Game::SCREEN_SHADOW
	@screen_width  = Graphics.width
	@screen_height = Graphics.height
    @board_width, @board_height = Ekans_Game.board_dims
    @tile_width    = Ekans_Game::SQUARE_WIDTH
    @tile_height   = Ekans_Game::SQUARE_HEIGHT
    @path          = "Graphics/UI/Ekans/"
    @board_x       = (@screen_width - @board_width) / 2
    @board_y       = 0
	@adapter.start_new_game unless continue_game
    @frame_count_at_last_update = (System.uptime * Ekans_Game.frame_rate).floor
    @frame_count_at_sitrus      = System.uptime.clone
	# Set Up Sprites
    @viewport         = Viewport.new(0, 0, @screen_width, @screen_height)
    @viewport.z       = Ekans_Game::SCREEN_Z
    @sprites          = {}
	# Background
	bg_path = Ekans_Game.get_background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(bg_path)
	produce_grid
    @sprites["pause_menu"] = IconSprite.new(0, 0, @viewport)
    @sprites["pause_menu"].setBitmap(@path + "pause_menu")
	p_x = (@screen_width - @sprites["pause_menu"].width) / 2
	p_y = @board_y + @board_height / 2 - @sprites["pause_menu"].height / 4
    @sprites["pause_menu"].src_rect.height = @sprites["pause_menu"].height / 2
    @sprites["pause_menu"].x       = p_x
    @sprites["pause_menu"].y       = p_y
    @sprites["pause_menu"].visible = false
    @sprites["pause_menu"].z       = @sprites["board"].z + 10
    @lost               = false
    @quitting           = false
    @sprites["overlay"] = BitmapSprite.new(@screen_width, @screen_height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["score"]   = BitmapSprite.new(@screen_width, @screen_height, @viewport)
    pbSetSystemFont(@sprites["score"].bitmap)
	# Sets Up Board
    set_up_berry
	board_graphics(true)
    update_score_display
	# Start
	@progress.in_game = true
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
    main_loop
	pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end
  
  def board_graphics(do_metal = false)
    # Update Snake Graphics
	ret  = [@adapter.snake.head]
	ret += @adapter.snake.body
    ret.each_with_index do |sel, i|
	  name     = "snake_#{i}"
	  @sprites[name].dispose if @sprites[name]
	  s_x, s_y = sel
	  s_x      = @tile_width * s_x + @board_x
	  s_y      = @tile_height * s_y + @board_y
      @sprites[name] = IconSprite.new(s_x, s_y, @viewport)
      @sprites[name].setBitmap(@path + "snake_#{@adapter.character}")
      @sprites[name].src_rect.height = @tile_height
      @sprites[name].src_rect.width  = @tile_width
      @sprites[name].src_rect.x      = @tile_width * 4
      next unless i == 0
	  # Head
	  d = @adapter.snake.direction.clone
	  d = (d / 2) - 1
      @sprites[name].src_rect.x = @tile_width * d
    end
	for k, v in @adapter.board
	  b_x, b_y = k.clone
	  b_x     *= @tile_width
	  b_y     *= @tile_height
	  b_x     += @board_x
	  b_y     += @board_y
	  # Draws Oran Sprite
	  unless @sprites["oran"]
        @sprites["oran"] = IconSprite.new(0, 0, @viewport)
        @sprites["oran"].setBitmap(@path + "berries")
        @sprites["oran"].src_rect.height = @tile_height
	  end
	  # Draws Sitrus Sprite
	  unless @sprites["sitrus"]
        @sprites["sitrus"] = IconSprite.new(0, 0, @viewport)
        @sprites["sitrus"].setBitmap(@path + "berries")
        @sprites["sitrus"].src_rect.height = @tile_height
        @sprites["sitrus"].src_rect.y      = @tile_height
	  end
	  case v
      when :oran
	    @sprites["oran"].x = b_x
	    @sprites["oran"].y = b_y
      when :sitrus
	    @sprites["sitrus"].x = b_x
	    @sprites["sitrus"].y = b_y
	  end
	end
	# Hides/Unhides Sitrus Berry Graphics
	@sprites["sitrus"].visible = @adapter.board.values.include?(:sitrus)
	return unless do_metal
	i = 0
	for k, v in @adapter.board
	  next unless v == :metal
	  m_x, m_y = k
      @sprites["metal_#{i}"].dispose if @sprites["metal_#{i}"]
      m_x = @tile_width * m_x + @board_x
      m_y = @tile_height * m_y + @board_y
      @sprites["metal_#{i}"] = IconSprite.new(m_x, m_y, @viewport)
      @sprites["metal_#{i}"].setBitmap(@path + "metal")
	  i += 1
    end
  end
  
  def produce_grid
    @sprites["board"] = BitmapSprite.new(@board_width, @board_height, @viewport)
	bmp = @sprites["board"].bitmap
	bmp.fill_rect(0, 0, @board_width, @board_height, Color.new(64, 64, 64))
	for ww in 0...Ekans_Game::BOARD_WIDTH
	  bmp.fill_rect(ww * @tile_width, 0, 1, @board_height, Color.white)
	end
	for hh in 0...Ekans_Game::BOARD_HEIGHT
	  bmp.fill_rect(0, hh * @tile_height, @board_width, 1, Color.white)
	end
	@sprites["board"].x = @board_x
	@sprites["board"].y = @board_y
  end
  
  def lose_game
    # Add To Hiscores
	if @adapter.score > 0
	  hash = {
	    :Score      => @adapter.score,
	    :Difficulty => @adapter.difficulty + 1,
	    :Type       => @adapter.field_type
	  }
      @progress.hiscores.push(hash)
	  @progress.hiscores.sort!{ |a, b|
	    b[:Score] <=> a[:Score]
	  }
	  while @progress.hiscores.length > 8
	    @progress.hiscores.delete_at(8)
	  end
	end
    @sprites["pause_menu"].src_rect.y = @sprites["pause_menu"].src_rect.height
    @sprites["pause_menu"].visible    = true
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::ACTION) ||
         Input.trigger?(Input::BACK) ||
         Input.trigger?(Input::USE)
    end
	@progress.in_game = false
  end
  
  def update_score_display
    @sprites["score"].bitmap.clear
    text_pos = [[
	  _INTL("Score: {1}", @adapter.score),
	  @screen_width / 4, 32, 0,
	  @base_col, @shad_col
	]]
    pbDrawTextPositions(@sprites["score"].bitmap, text_pos)
  end
  
  def clear_sitrus
    @adapter.sitrus_display = 0
    @adapter.sitrus_timer   = 0
    @adapter.clear_sitrus_berry
    @adapter.needs_update   = true
    set_sitrus_timer(0)
  end
  
  def set_sitrus_timer(s)
    @sprites["overlay"].bitmap.clear
    return unless s > 0
    text_pos = [[
	  s.to_s, @screen_width / 2, 32, 0,
	  @base_col, @shad_col
	]]
    pbDrawTextPositions(@sprites["overlay"].bitmap,text_pos)
  end
  
  def main_loop
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        do_pause_menu
        break if @quitting
      elsif Input.trigger?(Input::DOWN)
        @adapter.decision = 2
      elsif Input.trigger?(Input::LEFT)
        @adapter.decision = 4
      elsif Input.trigger?(Input::RIGHT)
        @adapter.decision = 6
      elsif Input.trigger?(Input::UP)
        @adapter.decision = 8
      end
	  review_frames
	  if @lost
	    lose_game
		break
	  end
	  board_graphics if @adapter.needs_update
    end
  end
  
  def review_frames
    frame_count = (System.uptime * Ekans_Game.frame_rate).floor
	# Does Ekans move a tile?
	diff_general = frame_count - @frame_count_at_last_update
	if diff_general >= @adapter.frames_per_action
	  @adapter.needs_update = true
	  @lost = !@adapter.make_move
	  review_berries
	  @frame_count_at_last_update = frame_count
	end
	diff_sitrus = System.uptime - @frame_count_at_sitrus
	return unless !@lost && @adapter.sitrus_timer > 0
	@adapter.sitrus_timer -= diff_sitrus
	@frame_count_at_sitrus = System.uptime.clone
	# Does Display Change?
	if @adapter.sitrus_timer.floor != @adapter.sitrus_display
	  @adapter.needs_update   = true
	  @adapter.sitrus_display = @adapter.sitrus_timer.floor
	  set_sitrus_timer(@adapter.sitrus_display)
	end
	# Removes Sitrus Berry
	if @adapter.sitrus_timer <= 0
	  clear_sitrus
	end
  end
  
  def review_berries
    if @adapter.ate_oran_berry
	  set_up_berry
	  @adapter.score += 1
	  update_score_display
      if @adapter.score % 6 == 0 &&
	     !@adapter.board.values.include?(:sitrus)
        @adapter.sitrus_timer  = Ekans_Game::SITRUS_BERRY_DURATION
		@frame_count_at_sitrus = System.uptime.clone
        set_up_berry(:sitrus)
	  end
	end
    if @adapter.ate_sitrus_berry
	  clear_sitrus
      @adapter.score       += 3 * (2 + rand(4))
      update_score_display
    end
  end
  
  def set_up_berry(berry = :oran)
    return if @adapter.board.values.include?(berry)
    pos = @adapter.find_empty_space
	@adapter.board[pos] = berry
  end
  
  def do_pause_menu
    @sprites["pause_menu"].src_rect.y = 0
    @sprites["pause_menu"].visible    = true
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::USE)
        break
      elsif Input.trigger?(Input::BACK)
        @quitting = true
        break
      end
    end
    @sprites["pause_menu"].visible = false
  end
end