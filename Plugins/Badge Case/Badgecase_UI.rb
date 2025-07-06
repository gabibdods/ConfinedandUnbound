#===============================================================================
# Badgecase UI
# Are you tired of the old fashion badge case inside your trainer card? This plugin is for you!
#===============================================================================
# Badgecase_UI
# Main script for the plugin's frontend
#===============================================================================
#  Calaculating best way to spread badges
#===============================================================================
module BadgecaseUtilities
  def self.getBadgePositions(badgecount=8)
    @@width = Graphics.width - 32
    @@height = Graphics.height - 44 - 76
    bestPositionsx=[]
    bestPositionsy=[]
    bestSize = 0
    if BadgecaseSetting::BADGECASE_ROWS != 0 && BadgecaseSetting::BADGECASE_COLUMNS != 0
      columns = BadgecaseSetting::BADGECASE_COLUMNS
      rows = BadgecaseSetting::BADGECASE_ROWS
      bestSize = find_size(columns, rows)
      bestPositionsx, bestPositionsy, bestSize, bestColumns, bestRows = calculate(rows, columns, bestSize)
    elsif BadgecaseSetting::BADGECASE_ROWS != 0
      rows = BadgecaseSetting::BADGECASE_ROWS
      columns = (badgecount/rows.to_f).ceil
      bestSize = find_size(columns, rows)
      bestPositionsx, bestPositionsy, bestSize, bestColumns, bestRows = calculate(rows, columns, bestSize)
    elsif BadgecaseSetting::BADGECASE_COLUMNS != 0
      columns = BadgecaseSetting::BADGECASE_COLUMNS
      rows = (badgecount/columns.to_f).ceil
      bestSize = find_size(columns, rows)
      bestPositionsx, bestPositionsy, bestSize, bestColumns, bestRows = calculate(rows, columns, bestSize)
    else
      for rows in 1..10
        columns = (badgecount/rows.to_f).ceil
        temp_size = find_size(columns, rows)
        if bestSize < temp_size
          bestSize = temp_size
          bestPositionsx, bestPositionsy, bestSize, bestColumns, bestRows = calculate(rows, columns, temp_size)
        end
      end
    end
    bestPositions = [bestPositionsx, bestPositionsy, [bestSize,bestColumns,bestRows]]
    return bestPositions
  end

  def self.find_size(columns, rows)
    icon = IconSprite.new(0, 0, nil)
    icon.setBitmap("Graphics/UI/Badgecase/Badges/#{$PokemonGlobal.badges.all_badges_information[0].id}")
    icon_size = icon.width
    icon.dispose
    per_size = 100
    calculating = false
    loop do
      if (@@width - columns * (icon_size * per_size / 100.0).to_i > 0) && (@@height - rows * (icon_size * per_size / 100.0).to_i > 0)
        return (per_size / 100.0 * icon_size).to_i
      end
      per_size -= 10
      return nil if per_size <= 0
    end
  end

  def self.calculate(rows, columns, bestSize)
    bestRows = rows
    bestColumns = columns
    bestPositionsx = []
    bestPositionsy = []
    xstep = (@@width - columns * bestSize) / (columns + 1)
    ystep = (@@height - rows * bestSize) / (rows + 1)
    x = xstep + 16
    y = ystep + 44
    rows.times do
      columns.times do
        bestPositionsx.push(x)
        bestPositionsy.push(y)
        x += bestSize + xstep
      end
      x = xstep + 16
      y += bestSize + ystep
    end
    return bestPositionsx, bestPositionsy, bestSize, bestColumns, bestRows
  end
end
#===============================================================================
# BadgeCase_Scene
#===============================================================================
class BadgeCase_Scene

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @badges = $PokemonGlobal.badges.all_badges_information
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @badgeindex = 0
    @badgepage = false
    @regions = $PokemonGlobal.badges.get_all_regions
    @regionindex = 0
    @badges = $PokemonGlobal.badges.all_badges_information.select {|badge| badge.region == @regions[@regionindex]} if @regions.length > 1
    @angle = 0
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["casebg"] = IconSprite.new(0,0,@viewport)
    @sprites["leadersprite"] = IconSprite.new(286,220,@viewport)
    @sprites["acepokemon"] = PokemonSpeciesIconSprite.new(nil,@viewport)
    @sprites["acepokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["acepokemon"].x = 36
    @sprites["acepokemon"].y = 314
    @sprites["badge"] = IconSprite.new(30,106,@viewport)
    @badgePositions = BadgecaseUtilities.getBadgePositions(@badges.length)
    @badges_showed = [@badges.length, @badgePositions[0].length].min
    for i in 0...@badges_showed
      @sprites["badge#{i}"] = IconSprite.new(@badgePositions[0][i],@badgePositions[1][i],@viewport)
      @sprites["badge#{i}"].setBitmap("Graphics/UI/Badgecase/Badges/#{@badges[i].id}")
      @sprites["badge#{i}"].zoom_x = @badgePositions[2][0] / @sprites["badge#{i}"].src_rect.width.to_f
      @sprites["badge#{i}"].zoom_y = @sprites["badge#{i}"].zoom_x
    end
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @sprites["badgecursor"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["casebg"].setBitmap("Graphics/UI/Badgecase/Backgrounds/badgebg")
    @sprites["background"].setBitmap("Graphics/UI/Badgecase/Backgrounds/badgeinfobg")
    @sprites["badgecursor"].setBitmap("Graphics/UI/Badgecase/badgeCursor")
    @sprites["badgecursor"].zoom_x = @badgePositions[2][0] / @sprites["badgecursor"].src_rect.width.to_f
    @sprites["badgecursor"].zoom_y = @sprites["badgecursor"].zoom_x
    pbSetNarrowFont(@sprites["overlay"].bitmap)
    drawPage
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneOne(badge)
    @badges = $PokemonGlobal.badges.all_badges_information
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    tempBadge = (@badges.select {|temp| temp.id == badge})[0]
    @badgeindex = @badges.find_index(tempBadge)
    @badgepage = true
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["casebg"] = IconSprite.new(0,0,@viewport)
    @sprites["leadersprite"] = IconSprite.new(286,220,@viewport)
    @sprites["acepokemon"] = PokemonSpeciesIconSprite.new(nil,@viewport)
    @sprites["acepokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["acepokemon"].x = 36
    @sprites["acepokemon"].y = 314
    @sprites["badge"] = IconSprite.new(30,106,@viewport)
    @badgePositions = BadgecaseUtilities.getBadgePositions(@badges.length)
    @badges_showed = [@badges.length, @badgePositions[0].length].min
    for i in 0...@badges_showed
      @sprites["badge#{i}"] = IconSprite.new(@badgePositions[0][i],@badgePositions[1][i],@viewport)
      @sprites["badge#{i}"].setBitmap("Graphics/UI/Badgecase/Badges/#{@badges[i].id}")
      @sprites["badge#{i}"].zoom_x = @badgePositions[2][0] / @sprites["badge#{i}"].src_rect.width.to_f
      @sprites["badge#{i}"].zoom_y = @sprites["badge#{i}"].zoom_x
    end
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @sprites["badgecursor"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["casebg"].setBitmap("Graphics/UI/Badgecase/Backgrounds/badgebg")
    @sprites["background"].setBitmap("Graphics/UI/Badgecase/Backgrounds/badgeinfobg")
    @sprites["badgecursor"].setBitmap("Graphics/UI/Badgecase/badgeCursor")
    @sprites["badgecursor"].zoom_x = @badgePositions[2][0] / @sprites["badgecursor"].src_rect.width.to_f
    @sprites["badgecursor"].zoom_y = @sprites["badgecursor"].zoom_x
    pbSetNarrowFont(@sprites["overlay"].bitmap)
    drawPage
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @typebitmap.dispose
  end

  def drawPage
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].visible = @badgepage
    @sprites["leadersprite"].visible = @badgepage
    @sprites["acepokemon"].visible = @badgepage
    @sprites["badge"].visible = @badgepage
    @sprites["casebg"].visible = !@badgepage
    @sprites["badgecursor"].visible = !@badgepage
    for i in 0...@badges_showed
      @sprites["badge#{i}"].visible = !@badgepage
    end
    if @badgepage
      drawBadgePage
    else
      drawCasePage
    end
  end

  def drawCasePage
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(156, 152, 149)
    shadow = Color.new(166, 162, 159)
    for i in 0...@badges_showed
      if $PokemonGlobal.badges.has?(@badges[i].id)
        @sprites["badge#{i}"].setBitmap("Graphics/UI/Badgecase/Badges/#{@badges[i].id}")
      else
        @sprites["badge#{i}"].setBitmap("Graphics/UI/Badgecase/Badges/unobtained/#{@badges[i].id}")
      end
    end
    updateCursor
  end

  def drawBadgePage
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    @sprites["background"].setBitmap("Graphics/UI/Badgecase/Backgrounds/badgeinfobg")
    @sprites["badge"].setBitmap(nil)
    @sprites["leadersprite"].setBitmap(nil)
    @sprites["acepokemon"].species = nil
    if $PokemonGlobal.badges.has?(@badges[@badgeindex].id)
      @sprites["badge"].setBitmap("Graphics/UI/Badgecase/Badges/#{@badges[@badgeindex].id}")
      @sprites["badge"].zoom_x = 160 / @sprites["badge"].src_rect.width.to_f
      @sprites["badge"].zoom_y = @sprites["badge"].zoom_x
      @sprites["leadersprite"].setBitmap("Graphics/Trainers/#{@badges[@badgeindex].leadersprite}")
      @sprites["leadersprite"].zoom_x = 160 / @sprites["leadersprite"].src_rect.width.to_f
      @sprites["leadersprite"].zoom_y = @sprites["leadersprite"].zoom_x
      @sprites["acepokemon"].species = @badges[@badgeindex].acepokemon if $PokemonGlobal.badges.has?(@badges[@badgeindex].id)
    end
    textpos = [
      [_INTL("BADGE INFO"), 26, 22, :left, base, shadow],
      [_INTL("Obtained At"), 238, 86, :left, base, shadow],
      [_INTL("Main Type"), 238, 118, :left, base, shadow],
      [_INTL("Location"), 238, 150, :left, base, shadow],
      [_INTL("Leader"), 238, 182, :left, base, shadow],
      [_INTL("ACE"), 78, 304, :left, base, shadow],
      [_INTL("POKEMON"), 78, 324, :left, base, shadow],
    ]
    if $PokemonGlobal.badges.has?(@badges[@badgeindex].id) || BadgecaseSetting::BADGE_NAME_ALWAYS
      textpos.push([@badges[@badgeindex].name, 26, 68, :left, base, shadow])
    else
      textpos.push([_INTL("???"), 26, 68, :left, base, shadow])
    end
    if $PokemonGlobal.badges.has?(@badges[@badgeindex].id) || BadgecaseSetting::BADGE_LOCATION_ALWAYS
      textpos.push([@badges[@badgeindex].location, 425, 150, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("???"), 425, 150, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
    if $PokemonGlobal.badges.has?(@badges[@badgeindex].id)
      textpos.push([@badges[@badgeindex].leadername, 425, 182, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push([@badges[@badgeindex].acepokemon.to_s.capitalize, 16, 358, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      time = $PokemonGlobal.badges.get_time(@badges[@badgeindex].id)
      textpos.push([_INTL("{1} {2} {3}",time.day,pbGetMonthName(time.mon),time.year), 425, 86, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("???"), 425, 182, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push([_INTL("???"), 16, 358, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push([_INTL("Not Obtained"), 425, 86, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
    if $PokemonGlobal.badges.has?(@badges[@badgeindex].id) || BadgecaseSetting::BADGE_TYPE_ALWAYS
      type_number = GameData::Type.get(@badges[@badgeindex].type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      overlay.blt(392, 114, @typebitmap.bitmap, type_rect)
    else
      textpos.push([_INTL("???"), 425, 118, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
    pbDrawTextPositions(overlay,textpos)
  end

  def updateCursor
    @sprites["badgecursor"].x = @badgePositions[0][@badgeindex]
    @sprites["badgecursor"].y = @badgePositions[1][@badgeindex]
  end

  def updateBadges
    @badges = $PokemonGlobal.badges.all_badges_information.select {|badge| badge.region == @regions[@regionindex]} if @regions.length > 1
    @badgePositions = getBadgePositions(@badges.length)
    for i in 0...@badges.length
      @sprites["badge#{i}"] = IconSprite.new(0,0,@viewport) if !@sprites["badge#{i}"]
      @sprites["badge#{i}"].setBitmap("Graphics/UI/Badgecase/Badges/#{@badges[i].id}")
      @sprites["badge#{i}"].zoom_x = @badgePositions[2][0] / @sprites["badge#{i}"].src_rect.width.to_f
      @sprites["badge#{i}"].zoom_y = @sprites["badge#{i}"].zoom_x
      @sprites["badge#{i}"].x = @badgePositions[0][i]
      @sprites["badge#{i}"].y = @badgePositions[1][i]
    end
    for i in @badges.length...$PokemonGlobal.badges.all_badges.length
      pbDisposeSprite(@sprites, "badge#{i}") if @sprites["badge#{i}"]
    end
    @sprites["badgecursor"].zoom_x = @badgePositions[2][0] / @sprites["badgecursor"].src_rect.width.to_f
    @sprites["badgecursor"].zoom_y = @sprites["badgecursor"].zoom_x
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        if @badgepage
          @badgepage = false
          dorefresh = true
        else
          break
        end
      elsif Input.trigger?(Input::USE) && ($PokemonGlobal.badges.has?(@badges[@badgeindex].id) || BadgecaseSetting::SHOW_UNOBTAINED_BADGES)
        @badgepage = !@badgepage
        dorefresh = true
      elsif Input.trigger?(Input::LEFT)
        if !@badgepage
          @badgeindex -= 1 if @badgeindex % @badgePositions[2][1] != 0
          @badgeindex = 0 if @badgeindex<0
          @badgeindex = @badges_showed-1 if @badgeindex > @badges_showed-1
          updateCursor
        else
          loop do
            @badgeindex -= 1
            @badgeindex = @badges_showed-1 if @badgeindex < 0
            break if BadgecaseSetting::SHOW_UNOBTAINED_BADGES
            break if $PokemonGlobal.badges.has?(@badges[@badgeindex].id)
          end
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        if !@badgepage
          @badgeindex += 1 if (@badgeindex+1) % @badgePositions[2][1] != 0
          @badgeindex = 0 if @badgeindex<0
          @badgeindex = @badges_showed-1 if @badgeindex > @badges_showed-1
          updateCursor
        else
          loop do
            @badgeindex += 1
            @badgeindex = 0 if @badgeindex > @badges_showed-1
            break if BadgecaseSetting::SHOW_UNOBTAINED_BADGES
            break if $PokemonGlobal.badges.has?(@badges[@badgeindex].id)
          end
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        if !@badgepage
          @badgeindex += @badgePositions[2][1].to_int if (@badgeindex/@badgePositions[2][1]) < (@badgePositions[2][2]-1)
          @badgeindex = 0 if @badgeindex<0
          @badgeindex = @badges_showed-1 if @badgeindex > @badges_showed-1
          updateCursor
        end
      elsif Input.trigger?(Input::UP)
        if !@badgepage
          @badgeindex -= @badgePositions[2][1].to_int if @badgeindex>=@badgePositions[2][1]
          @badgeindex = 0 if @badgeindex<0
          @badgeindex = @badges_showed-1 if @badgeindex > @badges_showed-1
          updateCursor
        end
      elsif Input.trigger?(Input::JUMPDOWN) && @regions.length > 1 && @badgepage == false
        @regionindex -= 1
        @regionindex = @regions.length - 1 if @regionindex < 0
        updateBadges
        @badgeindex = 0
        dorefresh = true
      elsif Input.trigger?(Input::JUMPUP) && @regions.length > 1 && @badgepage == false
        @regionindex += 1
        @regionindex = 0 if @regionindex == @regions.length
        updateBadges
        @badgeindex = 0
        dorefresh = true
      end
      if dorefresh
        drawPage
      end
    end
  end

  def pbSceneOne
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        pbPlayCloseMenuSE
        break
      end
    end
  end
end
#===============================================================================
# BadgeCaseScreen
#===============================================================================
class BadgeCaseScreen

  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen()
    @scene.pbStartScene
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartScreenOne(badge)
    @scene.pbStartSceneOne(badge)
    ret = @scene.pbSceneOne
    @scene.pbEndScene
    return ret
  end
end
#===============================================================================
# Main method to get a badge
# Pay attention! The argument is the wanted badge ID!
#===============================================================================
def pbGetBadge(badge)
  getBadge(badge)
  scene = BadgeCase_Scene.new
  screen = BadgeCaseScreen.new(scene)
  screen.pbStartScreenOne(badge)
end