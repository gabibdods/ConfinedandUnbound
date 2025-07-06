class PokemonRegionMap_Scene
  def getFlyIconPositions
    @mapInfo.each do |key, value|
      selFlySpots = Hash.new { |hash, key| hash[key] = [] }
      value[:positions].each do |pos|
        flySpot = pos[:flyspot]
        next if flySpot.empty?
        key = [flySpot[:map], flySpot[:x], flySpot[:y]]
        selFlySpots[key] << [flySpot, pos[:x], pos[:y]]
      end
      selFlySpots.each do |index, spot|
        visited = visited = spot.any? { |map| map[0][:visited] }
        name = visited ? "mapFly" : "mapFlyDis"
        centerX = spot.map { |map| map[1] }.sum.to_f / spot.length
        centerY = spot.map { |map| map[2] }.sum.to_f / spot.length
        original = spot.map { |map| { x: map[1], y: map[2] } }
        result = [centerX, centerY]
        unless result.nil?
          value[:flyicons] << { name: name, x: result[0], y: result[1], originalpos: original }
        end
      end
    end
  end

  def addFlyIconSprites
    if !@spritesMap["FlyIcons"]
      @spritesMap["FlyIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["FlyIcons"].x = @spritesMap["map"].x
      @spritesMap["FlyIcons"].y = @spritesMap["map"].y
      @spritesMap["FlyIcons"].visible = @mode == 1
    end
    @spritesMap["FlyIcons"].z = 15
    @mapInfo.each do |key, value|
      value[:flyicons].each do |spot|
        next if spot.nil?
        pbDrawImagePositions(
          @spritesMap["FlyIcons"].bitmap,
          [["#{FOLDER}Icons/Fly/#{spot[:name]}", pointXtoScreenX(spot[:x]), pointYtoScreenY(spot[:y])]]
        )
      end
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
  end

  def getFlyLocationAndConfirm
    @healspot = pbGetHealingSpot(@mapX, @mapY)
    if @healspot && ($PokemonGlobal.visitedMaps[@healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
      name = pbGetMapNameFromId(@healspot[0])
      return confirmMessageMap(_INTL("Would you like to use Fly to go to {1}?", name))
    end
  end

  def canFlyOtherRegion
    @mapName = @playerMapName if !@mapName
    return false if !ARMSettings::AllowFlyToOtherRegions
    flyRegion = ARMSettings::FlyToRegions
    regionName = (@currentRegionName).to_sym
    canFly = flyRegion.key?(regionName) && flyRegion[regionName].include?(@region)
    return true if canFly && ARMSettings::LocationFlyToOtherRegion.key?(regionName) && ARMSettings::LocationFlyToOtherRegion[regionName].include?(@mapName)
  end

  def canActivateQuickFly(lastChoiceFly, cursor)
    @visited = getFlyLocations
    return if @visited.empty?
    if enableMode(ARMSettings::CanQuickFly) && Input.trigger?(ARMSettings::QuickFlyButton)
      findChoice = @visited.find_index { |pos| pos[:x] == @mapX && pos[:y] == @mapY }
      lastChoiceFly = findChoice if findChoice
      choice = messageMap(_INTL("Quick Fly: Choose one of the available locations to fly to."),
          (0...@visited.size).to_a.map{ |i| "#{@visited[i][:name]}" }, -1, nil, lastChoiceFly, true) { pbUpdate }
      if choice != -1
        @mapX = @visited[choice][:x]
        @mapY = @visited[choice][:y]
      elsif choice == -1
        @mapX = cursor[:oldX]
        @mapY = cursor[:oldY]
      end
      @sprites["cursor"].x = 8 + (@mapX * ARMSettings::SquareWidth)
      @sprites["cursor"].y = 24 + (@mapY * ARMSettings::SquareHeight)
      @sprites["cursor"].x -= UI_BORDER_WIDTH if ARMSettings::RegionMapBehindUI
      @sprites["cursor"].y -= UI_BORDER_HEIGHT if ARMSettings::RegionMapBehindUI
      pbGetMapLocation(@mapX, @mapY)
      centerMapOnCursor
    end
    return choice
  end

  def getFlyLocations
    visits = []
    @mapInfo.each do |key, value|
      value[:positions].each do |pos|
        next if pos[:flyspot].empty? || !pos[:flyspot][:visited]
        sel = { name: value[:mapname], x: pos[:x], y: pos[:y], flyspot: pos[:flyspot] }
        visits << sel unless visits.any? { |visited| visited[:flyspot] == sel[:flyspot] }
      end
    end
    return visits
  end
end
