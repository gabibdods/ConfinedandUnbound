#===============================================================================
# The Region Map and everything else it does and can do.
#===============================================================================
class PokemonRegionMap_Scene
  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbStartScene(editor = false, flyMap = false)
    startFade
    @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z       = 100001
    @viewportCursor   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewportCursor.z = 100000
    @viewportMap      = Viewport.new(BEHIND_UI[0], BEHIND_UI[2], (Graphics.width - BEHIND_UI[1]), (Graphics.height - BEHIND_UI[3]))
    @viewportMap.z    = 99999
    @sprites          = {}
    @spritesMap       = {}
    @mapData          = pbLoadTownMapData if ENGINE20
    @flyMap           = flyMap
    @mode             = flyMap ? 1 : 0
    @mapMetadata      = $game_map.metadata
    @playerPos        = (@mapMetadata) ? @mapMetadata.town_map_position : nil
    getPlayerPosition
    @regionName = @map[0] if ENGINE20
    @regionName = @map.name.to_s if ENGINE21
    @regionFile = @map[1] if ENGINE20
    @regionFile = @map.filename if ENGINE21
    if QUESTPLUGIN && $quest_data
      @questMap  = $quest_data.getQuestMapPositions(@map[2], @region) if ENGINE20
      @questMap  = $quest_data.getQuestMapPositions(@map.point, @region) if ENGINE21
    end
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    @previewBox = PreviewState.new
    @extendedBox = ExtendedState.new
    @zoomLevel = 1.0
    main
    @playerMapName = !(@playerPos.nil?) ? pbGetMapLocation(@playerPos[1], @playerPos[2]) : ""
  end

  def main
    echoln("#{ARMSettings.constants.size} Settings")
    changeBGM
    addBackgroundAndRegionSprite
    getMapObject
    getFlyIconPositions
    addFlyIconSprites
    addUnvisitedMapSprites
    getCounter
    addCursorSprite
    getZoomLevels
    mapModeSwitchInfo
    showAndUpdateMapInfo
    getExtendedPreview
    addPlayerIconSprite
    addQuestIconSprites
    addBerryIconSprites
    addRoamingIconSprites
    centerMapOnCursor
    refreshFlyScreen
    stopFade { pbUpdate }
  end

  def startFade
    return if @FadeViewport || @FadeSprite
    @FadeViewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    @FadeViewport.z = 1000000
    @FadeSprite = BitmapSprite.new(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, @FadeViewport)
    @FadeSprite.bitmap.fill_rect(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, Color.new(0, 0, 0))
    @FadeSprite.opacity = 0
    for i in 0..16
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity += 256 / 16.to_f
    end
  end

  def getPlayerPosition
    if ARMSettings::CenterCursorByDefault || ARMSettings::ShowPlayerOnRegion
      @mapX      = UI_WIDTH % ARMSettings::SquareWidth != 0 ? ((UI_WIDTH / 2) + 8) / ARMSettings::SquareWidth : (UI_WIDTH / 2) / ARMSettings::SquareWidth
      @mapY      = UI_HEIGHT % ARMSettings::SquareHeight != 0 ? ((UI_HEIGHT / 2) + 8) / ARMSettings::SquareHeight : (UI_HEIGHT / 2) / ARMSettings::SquareHeight
    else
      @mapX      = ZERO_POINT_X
      @mapY      = ZERO_POINT_Y
    end
    if !@playerPos
      @region    = 0
      # v20.1.
      @map       = @mapData[0] if ENGINE20
      # v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
    elsif @region >= 0 && @region != @playerPos[0] && ((ENGINE20 && @mapData[@region]) || (ENGINE21 && GameData::TownMap.exists?(@region)))
      # v20.1.
      @map       = @mapData[@region] if ENGINE20
      # v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
    else
      @region    = @playerPos[0]
      # v20.1.
      @map       = @mapData[@playerPos[0]] if ENGINE20
      #v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
      @mapX      = @playerPos[1]
      @mapY      = @playerPos[2]
      ARMSettings::FakeRegionLocations[$game_map.map_id]&.each do |var, keys|
        keys.each do |value, pos|
          if $game_variables[var] == value
            @region = @playerPos[0] = pos[0]
            @map = @mapData[pos[0]] if ENGINE20
            @map = GameData::TownMap.get(@region) if ENGINE21
            @mapX = @playerPos[1] = pos[1]
            @mapY = @playerPos[2] = pos[2]
          end
        end
      end
      mapsize    = @mapMetadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @mapX   += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @mapY   += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
  end

  def changeBGM
    $game_system.bgm_memorize
    return if !ARMSettings::ChangeMusicInRegionMap
    newBGM = ARMSettings::MusicForRegion.find { |region| region[0] == @region }
    return if !newBGM
    newBGM[2] = 100 if !newBGM[2]
    newBGM[3] = 100 if !newBGM[3]
    pbBGMPlay(newBGM[1], newBGM[2], newBGM[3])
  end

  def addBackgroundAndRegionSprite
    @sprites["Background"] = IconSprite.new(0, 0, @viewport)
    @sprites["Background"].setBitmap(findUsableUI("mapBackground"))
    @sprites["Background"].x += (Graphics.width - @sprites["Background"].bitmap.width) / 2
    @sprites["Background"].y += (Graphics.height - @sprites["Background"].bitmap.height) / 2
    @sprites["Background"].z = 30
    if THEMEPLUGIN
      @sprites["BackgroundOver"] = IconSprite.new(0, 0, @viewport)
      @sprites["BackgroundOver"].setBitmap(findUsableUI("mapBackgroundOver"))
      @sprites["BackgroundOver"].x += (Graphics.width - @sprites["BackgroundOver"].bitmap.width) / 2
      @sprites["BackgroundOver"].y += (Graphics.height - @sprites["BackgroundOver"].bitmap.height) / 2
      unless $PokemonSystem.pokegear == "Theme 6"
        @sprites["BackgroundOver"].z = 22
      else
        @sprites["BackgroundOver"].z = 31
      end
    end
    @spritesMap["map"] = IconSprite.new(0, 0, @viewportMap)
    @spritesMap["map"].setBitmap("#{getTimeOfDay}")
    @spritesMap["map"].z = 1
    @mapWidth = @spritesMap["map"].bitmap.width
    @mapHeight = @spritesMap["map"].bitmap.height
    ARMSettings::RegionMapExtras.each do |graphic|
      next if graphic[0] != @region || !locationShown?(graphic)
      if !@spritesMap["map2"]
        @spritesMap["map2"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["map2"].x = @spritesMap["map"].x
        @spritesMap["map2"].y = @spritesMap["map"].y
        @spritesMap["map2"].z = 6
      end
      pbDrawImagePositions(
        @spritesMap["map2"].bitmap,
        [["#{FOLDER}HiddenRegionMaps/#{graphic[4]}", graphic[2] * ARMSettings::SquareWidth, graphic[3] * ARMSettings::SquareHeight]]
      )
    end
    ARMSettings::RegionMapDecoration.each do |graphic|
      next if graphic[0] != @region || (!graphic[1].nil? && locationShown?(graphic))
      if !@spritesMap["map3"]
        @spritesMap["map3"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["map3"].x = @spritesMap["map"].x
        @spritesMap["map3"].y = @spritesMap["map"].y
        @spritesMap["map3"].z = 21
      end
      pbDrawImagePositions(
        @spritesMap["map3"].bitmap,
        [["#{FOLDER}Regions/Region Decorations/#{graphic[4]}", graphic[2] * ARMSettings::SquareWidth, graphic[3] * ARMSettings::SquareHeight]]
      )
    end
  end

  def pointXtoScreenX(x)
    return ((ARMSettings::SquareWidth * x + (ARMSettings::SquareWidth / 2)) - 16)
  end

  def pointYtoScreenY(y)
    return ((ARMSettings::SquareHeight * y + (ARMSettings::SquareHeight / 2)) - 16)
  end

  def showAndUpdateMapInfo
    if !@sprites["mapbottom"]
      @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
      @sprites["mapbottom"].z = 40
      @lineCount = 2
    end
    getPreviewBox if !@flyMap
    @oldLineCount = nil
    getPreviewWeather if !@flyMap
    @sprites["mapbottom"].mapname = getMapName(@mapX, @mapY)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX, @mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX, @mapY)
    @sprites["mapbottom"].previewName   = [getPreviewName(@mapX, @mapY), @previewWidth] if @mode == 2 || @mode == 3 || @mode == 4
  end

  def addPlayerIconSprite
    if @playerPos && @region == @playerPos[0]
      if !@spritesMap["player"]
        @spritesMap["player"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["player"].x = @spritesMap["map"].x
        @spritesMap["player"].y = @spritesMap["map"].y
        @spritesMap["player"].visible = ARMSettings::ShowPlayerOnRegion[(@regionName.gsub(' ','')).to_sym]
      end
      @spritesMap["player"].z = 60
      pbDrawImagePositions(
        @spritesMap["player"].bitmap,
        [[GameData::TrainerType.player_map_icon_filename($player.trainer_type), pointXtoScreenX(@mapX) , pointYtoScreenY(@mapY)]]
      )
    end
  end

  def addCursorSprite
    @sprites["cursor"] = AnimatedSprite.create(findUsableUI("mapCursor"), 2, 5)
    @sprites["cursor"].viewport = @viewportCursor
    @sprites["cursor"].x        = (-8 + BEHIND_UI[0]) + ARMSettings::SquareWidth * @mapX
    @sprites["cursor"].y        = (-8 + BEHIND_UI[2]) + ARMSettings::SquareHeight * @mapY
    @sprites["cursor"].play
  end

  def stopFade
    return if !@FadeSprite || !@FadeViewport
    for i in 0...(16 + 1)
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity -= 256 / 16.to_f
    end
    @FadeSprite.dispose
    @FadeSprite = nil
    @FadeViewport.dispose
    @FadeViewport = nil
  end

  def pbMapScene
    cursor = createObject
    map    = createObject
    opacityBox = convertOpacity(ARMSettings::ButtonBoxOpacity)
    choice   = nil
    lastChoiceLocation = 0
    lastChoiceFly = 0
    lastChoiceQuest = 0
    lastChoiceBerries = 0
    @zoom = false # for v2.7.0
    @limitCursor = @zoomHash[@zoomIndex][:limits]
    updateMapRange
    @distPerFrame = 8 * 20 / Graphics.frame_rate if ENGINE20
    @distPerFrame = System.uptime if ENGINE21
    @uiWidth = @mapWidth < UI_WIDTH ? @mapWidth : UI_WIDTH
    @uiHeight = @mapHeight < UI_HEIGHT ? @mapHeight : UI_HEIGHT
    @switchMode = false
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      toggleButtonBox(opacityBox) if @modeCount >= 2
      updateButtonInfo if @previewBox.isShown && !ARMSettings::ButtonBoxPosition.nil?
      animatePreviewBox if previewAnimation
      if @zoomTriggered
        @sprites["cursor"].x = lerp(@ZoomValues[:begin][:cursor][:x], @ZoomValues[:end][:cursor][:x], @zoomSpeed, @distPerFrame, System.uptime)
        @sprites["cursor"].y = lerp(@ZoomValues[:begin][:cursor][:y], @ZoomValues[:end][:cursor][:y], @zoomSpeed, @distPerFrame, System.uptime)
        @spritesMap.each do |key, value|
          @spritesMap[key].zoom_x = @spritesMap[key].zoom_y = lerp(@ZoomValues[:begin][:map][:zoom], @ZoomValues[:end][:map][:zoom], @zoomSpeed, @distPerFrame, System.uptime)
          @spritesMap[key].x = lerp(@ZoomValues[:begin][:map][:x], @ZoomValues[:end][:map][:x], @zoomSpeed, @distPerFrame, System.uptime)
          @spritesMap[key].y = lerp(@ZoomValues[:begin][:map][:y], @ZoomValues[:end][:map][:y], @zoomSpeed, @distPerFrame, System.uptime)
        end
        @sprites["cursor"].zoom_x = @sprites["cursor"].zoom_y = lerp(@ZoomValues[:begin][:cursor][:zoom], @ZoomValues[:end][:cursor][:zoom], @zoomSpeed, @distPerFrame, System.uptime)
        Graphics.update
        if @sprites["cursor"].zoom_x == @ZoomValues[:end][:cursor][:zoom]
          updateMapRange
          updateButtonInfo
          @zoomTriggered = false
        end
        next
      end
      if cursor[:offsetX] != 0 || cursor[:offsetY] != 0
        updateCursor(cursor)
        updateMap(map) if map[:offsetX] != 0 || map[:offsetY] != 0
        next if cursor[:offsetX] != 0 || cursor[:offsetY] != 0
      end
      if map[:offsetX] != 0 || map[:offsetY] != 0
        updateMap(map)
        next if map[:offsetX] != 0 || map[:offsetY] != 0
      end
      if cursor[:offsetX] == 0 && cursor[:offsetY] == 0 && choice && choice.is_a?(Integer) && choice >= 0
        inputFly = true if @mode == 1
        lastChoiceLocation = choice if @mode == 0
        lastChoiceFly = choice if @mode == 1
        lastChoiceQuest = choice if @mode == 2
        lastChoiceBerries = choice if @mode == 3
      end
      if Input.trigger?(Input::CTRL) && @mode == 0 && !ENGINE20 && ARMSettings::UseRegionMapZoom
        if !@zoom
          @zoom = true
          @sprites["modeName"].bitmap.clear
          pbDrawTextPositions(
            @sprites["modeName"].bitmap,
            [["Zoom Mode", Graphics.width - (22 - ARMSettings::ModeNameOffsetX), 4 + ARMSettings::ModeNameOffsetY, 1, ARMSettings::ModeTextMain, ARMSettings::ModeTextShadow]]
          )
        else
          @zoom = false
          @zoomTriggered = @zoomIndex != 1
          @zoomIndex = 1
          getZoomValues
          next
        end
      elsif @zoom && !ENGINE20
        if Input.trigger?(Input::JUMPUP) && (@zoomIndex != 0 && @zoomHash[@zoomIndex - 1][:enabled]) # zoom in
          @zoomIndex -= 1
          @zoomTriggered = true
        elsif Input.trigger?(Input::JUMPDOWN) && (@zoomIndex != @zoomHash.length - 1 && @zoomHash[@zoomIndex + 1][:enabled]) # zoom out
          @zoomIndex += 1
          @zoomTriggered = true
        end
        if @zoomTriggered
          getZoomValues
          next
        end
      end
      updateArrows
      ox, oy, mox, moy = 0, 0, 0, 0
      cursor[:oldX] = @mapX
      cursor[:oldY] = @mapY
      ox, oy, mox, moy = getDirectionInput(ox, oy, mox, moy)
      ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries = getMouseInput(ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries) if ARMSettings::UseMouseOnRegionMap
      choice = canSearchLocation(lastChoiceLocation, cursor) if @mode == 0
      choice = canActivateQuickFly(lastChoiceFly, cursor) if @mode == 1
      updateCursorPosition(ox, oy, cursor) if (ox != 0 || oy != 0) && !previewAnimation
      updateMapPosition(mox, moy, map) if (mox != 0 || moy != 0) && !previewAnimation
      #updatePreviewBox if @previewBox.canUpdate
      showAndUpdateMapInfo if (@mapX != cursor[:oldX] || @mapY != cursor[:oldY]) && @previewBox.isUpdateAnim || @previewBox.isHidden
      if !@wallmap
        if (Input.trigger?(ARMSettings::ShowLocationButton) && @mode == 0 && ARMSettings::UseLocationPreview) && getLocationInfo && !@previewBox.isShown && !previewAnimation
          pbPlayDecisionSE
          @previewBox.showIt
          showPreviewBox
        elsif Input.trigger?(ARMSettings::ShowExtendedButton) && @previewBox.isShown && !@cannotExtPreview && @mode == 0 && ARMSettings::ProgressCounter
          pbPlayDecisionSE
          showExtendedPreview
        elsif ((Input.trigger?(Input::USE) || Input.trigger?(ARMSettings::MouseButtonSelectLocation)) && @mode == 1) || inputFly
          return @healspot if getFlyLocationAndConfirm { pbUpdate }
        elsif Input.trigger?(ARMSettings::ShowQuestButton) && QUESTPLUGIN && @mode == 2
          @ChangeQuestIcon = true
          choice = showQuestInformation(lastChoiceQuest)
          if choice != -1
            if @previewBox.isShown && @questNames.length >= 2 && choice != lastChoiceQuest
              @previewBox.updateIt
              updatePreviewBox
            else
              @previewBox.showIt
              showPreviewBox
            end
          elsif @previewBox.isShown
            @previewBox.hideIt
            hidePreviewBox
          end
        elsif Input.trigger?(ARMSettings::ChangeModeButton) && !@flyMap && @modeCount >= 2 && !@zoom
          @ChangeQuestIcon = false if @mode == 2
          if @previewBox.isShown
            @previewBox.hideIt
            hidePreviewBox
            @switchMode = true
          else
            switchMapMode
          end
        elsif Input.trigger?(ARMSettings::ChangeRegionButton) && @previewBox.isHidden && ((ENGINE20 && @mapData.length >= 2) || (ENGINE21 && GameData::TownMap.count >= 2)) && !@flyMap && !@zoom
          @ChangeQuestIcon = false if @mode == 2
          switchRegionMap
        elsif Input.trigger?(ARMSettings::ShowBerryButton) && BERRYPLUGIN && @mode == 3
          choice = showBerryInformation(lastChoiceBerries)
          if choice != -1
            if @previewBox.isShown && @berryPlants.length >= 2 && choice != lastChoiceBerries
              @previewBox.updateIt
              updatePreviewBox
            else
              @previewBox.showIt
              showPreviewBox
            end
          elsif @previewBox.isShown
            @previewBox.hideIt
            hidePreviewBox
          end
        end
      end
      if Input.trigger?(Input::BACK)
        next if previewAnimation
        if @previewBox.isShown || @previewBox.isUpdated
          @previewBox.hideIt
          hidePreviewBox
          next
        elsif @previewBox.isExtHidden
          @previewBox.shown
          getPreviewWeather
          next
        else
          break
        end
      end
    end
    pbPlayCloseMenuSE
    return nil
  end

  def updateCursor(cursor)
    if ENGINE20
      cursor[:offsetX] += (cursor[:offsetX] > 0) ? -@distPerFrame : (cursor[:offsetX] < 0) ? @distPerFrame : 0
      cursor[:offsetY] += (cursor[:offsetY] > 0) ? -@distPerFrame : (cursor[:offsetY] < 0) ? @distPerFrame : 0
      @sprites["cursor"].x = cursor[:newX] - cursor[:offsetX]
      @sprites["cursor"].y = cursor[:newY] - cursor[:offsetY]
    elsif ENGINE21
      if cursor[:offsetX] != 0
        @sprites["cursor"].x = lerp(cursor[:newX] - cursor[:offsetX], cursor[:newX], 0.1, @distPerFrame, System.uptime)
        cursor[:offsetX] = 0 if @sprites["cursor"].x == cursor[:newX]
      end
      if cursor[:offsetY] != 0
        @sprites["cursor"].y = lerp(cursor[:newY] - cursor[:offsetY], cursor[:newY], 0.1, @distPerFrame, System.uptime)
        cursor[:offsetY] = 0 if @sprites["cursor"].y == cursor[:newY]
      end
    end
  end

  def updateMap(map)
    if ENGINE20
      map[:offsetX] += (map[:offsetX] > 0) ? -@distPerFrame : (map[:offsetX] < 0) ? @distPerFrame : 0
      map[:offsetY] += (map[:offsetY] > 0) ? -@distPerFrame : (map[:offsetY] < 0) ? @distPerFrame : 0
      @spritesMap.each do |key, value|
        @spritesMap[key].x = map[:newX] - map[:offsetX]
        @spritesMap[key].y = map[:newY] - map[:offsetY]
      end
    elsif ENGINE21
      if map[:offsetX] != 0
        @spritesMap.each do |key, value|
          @spritesMap[key].x = lerp(map[:newX] - map[:offsetX], map[:newX], 0.1, @distPerFrame, System.uptime)
        end
        map[:offsetX] = 0 if @spritesMap["map"].x == map[:newX]
      end
      if map[:offsetY] != 0
        @spritesMap.each do |key, value|
          @spritesMap[key].y = lerp(map[:newY] - map[:offsetY], map[:newY], 0.1, @distPerFrame, System.uptime)
        end
        map[:offsetY] = 0 if @spritesMap["map"].y == map[:newY]
      end
    end
    updateMapRange
  end

  def getDirectionInput(ox, oy, mox, moy)
    case Input.dir8
    when 1, 2, 3
      oy = 1 if @sprites["cursor"].y < @limitCursor[:maxY]
      moy = -1 if @spritesMap["map"].y > -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3])) && oy == 0
    when 7, 8, 9
      oy = -1 if @sprites["cursor"].y > @limitCursor[:minY]
      moy = 1 if @spritesMap["map"].y < 0 && oy == 0
    end
    case Input.dir8
    when 1, 4, 7
      ox = -1 if @sprites["cursor"].x > @limitCursor[:minX]
      mox = 1 if @spritesMap["map"].x < 0 - @cursorCorrZoom && ox == 0
    when 3, 6, 9
      ox = 1 if @sprites["cursor"].x < @limitCursor[:maxX]
      mox = -1 if @spritesMap["map"].x > -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1])) + @cursorCorrZoom && ox == 0
    end
    return ox, oy, mox, moy
  end

  def updateCursorPosition(ox, oy, cursor)
    @mapX += ox
    @mapY += oy
    cursor[:offsetX] = ox * (ARMSettings::SquareWidth * @zoomLevel)
    cursor[:offsetY] = oy * (ARMSettings::SquareHeight * @zoomLevel)
    cursor[:newX] = @sprites["cursor"].x + cursor[:offsetX]
    cursor[:newY] = @sprites["cursor"].y + cursor[:offsetY]
    # Hide Preview when moving cursor.
    if @previewBox.isShown
      if @mode == 0 && @curLocName == pbGetMapLocation(@mapX, @mapY)
        @previewBox.updateIt
        updatePreviewBox
      else
        @previewBox.hideIt
        hidePreviewBox
      end
    end
    @distPerFrame = System.uptime if ENGINE21
  end

  def updateMapPosition(mox, moy, map)
    @mapX -= mox
    @mapY -= moy
    map[:offsetX] = mox * (ARMSettings::SquareWidth * @zoomLevel)
    map[:offsetY] = moy * (ARMSettings::SquareHeight * @zoomLevel)
    map[:newX] = @spritesMap["map"].x + map[:offsetX]
    map[:newY] = @spritesMap["map"].y + map[:offsetY]
    if @previewBox.isShown
      if @mode == 0 && @curLocName == pbGetMapLocation(@mapX, @mapY)
        @previewBox.updateIt
        updatePreviewBox
      else
        @previewBox.hideIt
        hidePreviewBox
      end
    end
    @distPerFrame = System.uptime if ENGINE21
  end

  def pbEndScene
    startFade { pbUpdate }
    $game_system.bgm_restore
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@spritesMap)
    @viewport.dispose
    @viewportCursor.dispose
    @viewportMap.dispose
    stopFade
  end
end
