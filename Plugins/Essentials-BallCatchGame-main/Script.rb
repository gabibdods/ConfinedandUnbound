#===============================================================================
# * Ball Catch Game - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's a simple minigame where the player
# must pick the balls that are falling at screen.
#
#== INSTALLATION ===============================================================
#
# Put it above main or convert into a plugin. Create "Ball Catch" folder at 
# Graphics/Pictures and put the pictures (may works with other sizes):
# -  20x20  ball
# - 512x384 bg 
# -  80x44  catcher
#
#== HOW TO USE =================================================================
#
# To call this script, use the script command 'pbCatchGame' This method will 
# return the number of picked balls or nil if cancelled. 
#
#=== NOTES =====================================================================
#
# You can pass game parameters using CatchGameParameters. Example:
#  
#  params = CatchGameParameters.new
#  params.balls = 20
#  params.initialFramesPerLine = 16
#  params.finalFramesPerLine = 8
#  params.canExit = false
#  pbCatchGame(params)
#
# Look at class CatchGameParameters for full parameter list.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Ball Catch Game")
  PluginManager.register({                                                 
    :name    => "Ball Catch Game",                                        
    :version => "1.3",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=317142",             
    :credits => "FL"
  })
end

class CatchGameParameters
  # Ball speed when game start and when ends. 
  # The game interpolate between these two values base on spawned ball count
  attr_accessor :initialBallSpeed
  attr_accessor :finalBallSpeed
  
  # Bigger values = More time between ball spawn tries.
  # The game interpolate between these two values base on spawned ball count
  attr_accessor :initialFramesPerLine
  attr_accessor :finalFramesPerLine
  
  # Total balls spawned
  attr_accessor :balls
  
  # The number of positions/columns for the balls/player
  attr_accessor :columns
  
  # Player sprite speed. Lower = move faster. 1 = Instant move
  attr_accessor :playerFramesToMove
  
  # Lines per ball proportion. Lower = less vertical "gaps" between balls
  attr_accessor :linePerBall
  
  # If player can exit
  attr_accessor :canExit
  
  # Set the default values
  def initialize 
    @initialBallSpeed = 8.0
    @finalBallSpeed = 8.0
    @initialFramesPerLine = 12
    @finalFramesPerLine = 12
    @balls = 50
    @columns = 7
    @playerFramesToMove = 4
    @linePerBall = 3
    @canExit = true
  end
  
  def totalLines
    return (@linePerBall*@balls).floor
  end
  
  def ballSpeed(ratio)
    return lerp(@initialBallSpeed, @finalBallSpeed, ratio) 
  end
  
  def framesPerLine(ratio)
    if @finalFramesPerLine>@initialFramesPerLine # Because this makes no sense 
      raise "initialFramesPerLine (#{@initialFramesPerLine}) should not be lower than finalFramesPerLine (#{@finalFramesPerLine})"
    end
    return lerp(@finalFramesPerLine, @initialFramesPerLine, 1.0-ratio)
  end
  
  def lerp(a, b, t)
    return a*(1.0-t)+b*t
  end
end

class CatchGameScene
  X_START=56
  Y_START=-40
  X_GAIN=64
  MAX_DISTANCE_BETWEEN_BALLS = 1
  
  def pbStartScene(parameters)
    @params = parameters ? parameters : CatchGameParameters.new
    @sprites={} 
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Ball Catch/bg")
    @sprites["background"].x=(Graphics.width-@sprites["background"].bitmap.width)/2
    @sprites["background"].y=(Graphics.height-@sprites["background"].bitmap.height)/2
    @sprites["player"]=IconSprite.new(0,0,@viewport)
    @sprites["player"].setBitmap("Graphics/Pictures/Ball Catch/catcher")
    @sprites["player"].y=340-@sprites["player"].bitmap.height/2
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    initializeBallsPositions
    @playerColumn=@params.columns/2
    @playerPosition = playerColumnPosition(@playerColumn)
    refreshPlayerPosition
    @ballCount = 0
    @score=0
    @ballsY = [] # used to calculate balls current Y positions using float values
    @pickSE="Player jump"
    @pickSE="jump" if !pbResolveAudioSE(@pickSE) # Compatibility with older versions
    @outSE="Battle ball drop"
    @outSE="balldrop" if !pbResolveAudioSE(@outSE) # Compatibility with older versions
    pbDrawText
    pbBGMPlay("021-Field04")
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawText
    overlay=@sprites["overlay"].bitmap
    overlay.clear 
    score=_INTL("Score: {1}/{2}",@score,@params.balls)    
    baseColor=Color.new(248,248,248)
    shadowColor=Color.new(112,112,112)
    textPositions=[[score,8,8,false,baseColor,shadowColor]]
    pbDrawTextPositions(overlay,textPositions)
  end
  
  def updatePlayerPosition
    targetPosition = playerColumnPosition(@playerColumn)
    return if @playerPosition == targetPosition
    gain = X_GAIN/@params.playerFramesToMove.to_f
    if targetPosition>@playerPosition
      @playerPosition=[@playerPosition+gain, targetPosition].min
    else
      @playerPosition=[@playerPosition-gain, targetPosition].max
    end
    refreshPlayerPosition
  end
      
  def refreshPlayerPosition
    @sprites["player"].x=@playerPosition-@sprites["player"].bitmap.width/2
  end
      
  def playerColumnPosition(column)
    return X_START+X_GAIN*column
  end 
  
  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def initializeBall(position)
    i=0
    # This method reuse old balls for better performance
    loop do
      if !@sprites["ball#{i}"]
        @sprites["ball#{i}"]=IconSprite.new(0,0,@viewport)
        @sprites["ball#{i}"].setBitmap("Graphics/Pictures/Ball Catch/ball")
        @sprites["ball#{i}"].ox=@sprites["ball#{i}"].bitmap.width/2
        @sprites["ball#{i}"].oy=@sprites["ball#{i}"].bitmap.height/2
        break
      end  
      if !@sprites["ball#{i}"].visible
        @sprites["ball#{i}"].visible=true
        break
      end
      i+=1
    end
    @sprites["ball#{i}"].x=X_START+X_GAIN*position
    @ballsY[i] = Y_START
    @sprites["ball#{i}"].y=@ballsY[i]
  end  
   
  def initializeBallsPositions
    @lineArray=[]
    @lineArray[@params.totalLines-1]=nil # One position for every line
    loop do
      while @lineArray.nitems<@params.balls
        ballIndex = rand(@params.totalLines)
        @lineArray[ballIndex] = rand(@params.columns) if !@lineArray[ballIndex]
      end  
      for i in 0...@lineArray.size
        next if !@lineArray[i]
        # Checks if the ball isn't too distant to pick.
        # If is, remove from the array
        checkRight(i+1,@lineArray[i]+MAX_DISTANCE_BETWEEN_BALLS)
        checkLeft(i+1,@lineArray[i]-MAX_DISTANCE_BETWEEN_BALLS)
      end
      return if @lineArray.nitems==@params.balls
    end
  end  
  
  def checkRight(index, position)
    return if (position>=@params.columns || index>=@lineArray.size)
    if (@lineArray[index] && @lineArray[index]>position)
      @lineArray[index]=nil
    end
    checkRight(index+1,position+MAX_DISTANCE_BETWEEN_BALLS)
  end  
  
  def checkLeft(index, position)
    return if (position<=0 || index>=@lineArray.size)
    if (@lineArray[index] && @lineArray[index]<position)
      @lineArray[index]=nil
    end
    checkLeft(index+1,position-MAX_DISTANCE_BETWEEN_BALLS)
  end  
  
  def applyCollisions
    i=0
    loop do
      break if !@sprites["ball#{i}"]
      if @sprites["ball#{i}"].visible
        @ballsY[i] += @params.ballSpeed(inverseLerp(0, @params.balls, @ballCount))
        @sprites["ball#{i}"].y = @ballsY[i].round
        @sprites["ball#{i}"].angle+=10
        ballBottomY = @sprites["ball#{i}"].y+@sprites["ball#{i}"].bitmap.height
       
        # Collision with player
        ballPosition=(@sprites["ball#{i}"].x-X_START+@sprites["ball#{i}"].bitmap.width/2)/X_GAIN
        if ballPosition==@playerColumn
          collisionStartY=-8 
          collisionEndY=10
          # Based at target center
          playerCenterY=@sprites["player"].y+@sprites["player"].bitmap.width/2
          collisionStartY+=playerCenterY
          collisionEndY+=playerCenterY
          if(collisionStartY < ballBottomY && collisionEndY > ballBottomY)
            # The ball was picked  
            @sprites["ball#{i}"].visible=false
            pbSEPlay(@pickSE)
            @score+=1
            pbDrawText # Update score at screen
          end
        end
        
        # Collision with screen limit
        screenLimit = Graphics.height+@sprites["ball#{i}"].bitmap.height
        if(ballBottomY>screenLimit)
          # The ball was out of screen 
          @sprites["ball#{i}"].visible=false
          pbSEPlay(@outSE)
        end
      end  
      i+=1
    end
  end  
  
  def thereBallsInGame?
    i=0
    loop do
      return false if !@sprites["ball#{i}"]
      return true if @sprites["ball#{i}"].visible
      i+=1
    end
  end
    
  def pbMain
    stopBalls = false
    framesToNextBall = 0.0
    lineIndex = 0
    loop do
      applyCollisions
      if framesToNextBall<=0 && !stopBalls 
        if @lineArray[lineIndex]
          initializeBall(@lineArray[lineIndex])
          @ballCount+=1
        end
        lineIndex+=1
        stopBalls = lineIndex>=@lineArray.size
        framesToNextBall+=@params.framesPerLine(inverseLerp(0, @params.balls-1, @ballCount))
      end
      Graphics.update
      Input.update
      self.update
      if stopBalls && !thereBallsInGame?
        pbMessage(_INTL("Game end!"))
        break
      end  
      if Input.repeat?(Input::LEFT) && @playerColumn>0
        @playerColumn=@playerColumn-1
      end
      if Input.repeat?(Input::RIGHT) && @playerColumn<(@params.columns-1)
        @playerColumn=@playerColumn+1
      end
      if Input.repeat?(Input::B) && @params.canExit
        return nil if pbConfirmMessage(_INTL("Exit?"))
      end
      updatePlayerPosition      
      framesToNextBall-=1
    end
    return @score
  end

  def pbEndScene
    $game_map.autoplay
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def inverseLerp(a, b, t)
    return (t.to_f-a)/(b-a)
  end
end

class CatchGame
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(parameters)
    @scene.pbStartScene(parameters)
    ret=@scene.pbMain
    @scene.pbEndScene
    return ret
  end
end

def pbCatchGame(parameters = nil)
  ret = nil
  pbFadeOutIn(99999) { 
    scene=CatchGameScene.new
    screen=CatchGame.new(scene)
    ret = screen.pbStartScreen(parameters)
  }
  return ret
end

#===============================================================================
# For compatibility with older Essentials
#===============================================================================

class Array
  def nitems
    count{|x| !x.nil?}
  end
end unless Array.method_defined?(:nitems)

def pbMessage(
  message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block
)
  return Kernel.pbMessage(
    message, commands, cmdIfCancel, skin, defaultCmd, &block
  )
end unless defined?(:pbMessage)

def pbConfirmMessage(message, &block)
  return Kernel.pbConfirmMessage(message, &block)
end unless defined?(:pbConfirmMessage)