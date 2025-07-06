class PokemonRegionMap_Scene
  def centerMapOnCursor
    centerMapX
    centerMapY
    addArrowSprites if !@sprites["upArrow"]
    updateArrows
  end

  def centerMapX
    posX, center = getCenterMapX(@sprites["cursor"].x, true)
    @mapOffsetX = @mapWidth < (Graphics.width - BEHIND_UI[1]) ? ((Graphics.width - BEHIND_UI[1]) - @mapWidth) / 2 : 0
    if center
      @spritesMap.each do |key, value|
        @spritesMap[key].x = posX
      end
    else
      @spritesMap.each do |key, value|
        @spritesMap[key].x = @mapOffsetX
      end
    end
    @sprites["cursor"].x += @spritesMap["map"].x
  end

  def getCenterMapX(cursorX, getCenter = false)
    center = cursorX > (Settings::SCREEN_WIDTH / 2) && ((@mapWidth > Graphics.width && ARMSettings::RegionMapBehindUI) || (@mapWidth > UI_WIDTH && !ARMSettings::RegionMapBehindUI))
    steps = @zoomHash[@zoomIndex][:steps]
    curCorr = @zoomHash[@zoomIndex][:curCorr]
    mapMaxX = -1 * (@mapWidth - UI_WIDTH)
    mapMaxX += UI_BORDER_WIDTH * 2 if ARMSettings::RegionMapBehindUI
    mapPosX = (UI_WIDTH / 2) - cursorX
    pos = mapPosX < mapMaxX ? mapMaxX : mapPosX
    posX = pos % steps != 0 ? pos + curCorr : pos
    if getCenter
      return posX, center
    elsif center
      return posX
    else
      return 0
    end
  end

  def centerMapY
    posY, center = getCenterMapY(@sprites["cursor"].y, true)
    @mapOffsetY = @mapHeight < (Graphics.height - BEHIND_UI[3]) ? ((Graphics.height - BEHIND_UI[3]) - @mapHeight) / 2 : 0
    if center
      @spritesMap.each do |key, value|
        @spritesMap[key].y = posY
      end
    else
      @spritesMap.each do |key, value|
        @spritesMap[key].y = @mapOffsetY
      end
    end
    @sprites["cursor"].y += @spritesMap["map"].y
  end

  def getCenterMapY(cursorY, getCenter = false)
    center = cursorY > (Settings::SCREEN_HEIGHT / 2) && ((@mapHeight > Graphics.height && ARMSettings::RegionMapBehindUI) || (@mapHeight > UI_HEIGHT && !ARMSettings::RegionMapBehindUI))
    steps = @zoomHash[@zoomIndex][:steps]
    curCorr = @zoomHash[@zoomIndex][:curCorr]
    mapMaxY = -1 * (@mapHeight - UI_HEIGHT)
    mapMaxY += UI_BORDER_HEIGHT * 2 if ARMSettings::RegionMapBehindUI
    mapPosY = (UI_HEIGHT / 2) - cursorY
    pos = mapPosY < mapMaxY ? mapMaxY : mapPosY
    posY = pos % steps != 0 ? pos + curCorr : pos
    if getCenter
      return posY, center
    elsif center
      return posY
    else
      return 0
    end
  end

  def addArrowSprites
    @sprites["upArrow"] = AnimatedSprite.new(findUsableUI("mapArrowUp"), 8, 28, 40, 2, @viewport)
    @sprites["upArrow"].x = (Graphics.width / 2) - 14
    @sprites["upArrow"].y = (BOX_TOP_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_TOP_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? @sprites["buttonPreview"].height : 16
    @sprites["upArrow"].z = 35
    @sprites["upArrow"].play
    @sprites["downArrow"] = AnimatedSprite.new(findUsableUI("mapArrowDown"), 8, 28, 40, 2, @viewport)
    @sprites["downArrow"].x = (Graphics.width / 2) - 14
    @sprites["downArrow"].y = (BOX_BOTTOM_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_BOTTOM_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? (Graphics.height - (44 + @sprites["buttonPreview"].height)) : (Graphics.height - 60)
    @sprites["downArrow"].z = 35
    @sprites["downArrow"].play
    @sprites["leftArrow"] = AnimatedSprite.new(findUsableUI("mapArrowLeft"), 8, 40, 28, 2, @viewport)
    @sprites["leftArrow"].y = (Graphics.height / 2) - 14
    @sprites["leftArrow"].z = 35
    @sprites["leftArrow"].play
    @sprites["rightArrow"] = AnimatedSprite.new(findUsableUI("mapArrowRight"), 8, 40, 28, 2, @viewport)
    @sprites["rightArrow"].x = Graphics.width - 40
    @sprites["rightArrow"].y = (Graphics.height / 2) - 14
    @sprites["rightArrow"].z = 35
    @sprites["rightArrow"].play
  end

  def updateArrows
    @sprites["upArrow"].visible = @spritesMap["map"].y < 0 && !@previewBox.isExtShown
    @sprites["downArrow"].visible = @spritesMap["map"].y > -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3])) && !@previewBox.isExtShown
    @sprites["leftArrow"].visible =  @spritesMap["map"].x < 0 - @cursorCorrZoom && !@previewBox.isExtShown
    @sprites["rightArrow"].visible = @spritesMap["map"].x > -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1])) + @cursorCorrZoom && !@previewBox.isExtShown
  end

  def updateMapRange
    offset = ARMSettings::CursorMapOffset ? 16 * @zoomLevel : 0
    mapOffsetX = ARMSettings::RegionMapBehindUI ? UI_BORDER_WIDTH / @zoomHash[@zoomIndex][:steps].ceil : 0
    mapOffsetX += 1 if @zoomHash[@zoomIndex][:level] == 0.5 && ARMSettings::CursorMapOffset
    mapOffsetY = ARMSettings::RegionMapBehindUI ? UI_BORDER_HEIGHT / @zoomHash[@zoomIndex][:steps].ceil : 0
    @mapRange = {
      :minX => (((@spritesMap["map"].x - offset) / (ARMSettings::SquareWidth * @zoomLevel)).abs).ceil + mapOffsetX,
      :maxX => (((@spritesMap["map"].x + offset).abs + (UI_WIDTH - (ARMSettings::SquareWidth * @zoomLevel))) / (ARMSettings::SquareWidth * @zoomLevel)).ceil + mapOffsetX,
      :minY => (((@spritesMap["map"].y - offset) / (ARMSettings::SquareHeight * @zoomLevel)).abs).ceil + mapOffsetY,
      :maxY => (((@spritesMap["map"].y + offset).abs + (UI_HEIGHT - (ARMSettings::SquareHeight * @zoomLevel))) / (ARMSettings::SquareHeight * @zoomLevel)).ceil + mapOffsetY
    }
    if ARMSettings::CursorMapOffset
      @mapRange[:maxX] -= 2 if @spritesMap["map"].x == 0
      @mapRange[:maxY] -= 2 if @spritesMap["map"].y == 0
    end
  end

  def createCursorLimitObject(offset, curCorr, level = 1.0)
    cursorOffset = ARMSettings::CursorMapOffset ? offset : 0
    width = @sprites["cursor"].bitmap.width / level # 64, 32, 16
    height = @sprites["cursor"].bitmap.height / level # 64, 32, 16
    @mapOffsetX = 0 if @mapOffsetX.nil?
    @mapOffsetY = 0 if @mapOffsetY.nil?
    minX =  if !ARMSettings::RegionMapBehindUI
              (UI_BORDER_WIDTH + @mapOffsetX + cursorOffset) - curCorr # ok
            else
              if @mapWidth > UI_WIDTH
                (UI_BORDER_WIDTH + cursorOffset) - curCorr # ok
              else
                @mapOffsetX + cursorOffset
              end
            end
    maxX =  if !ARMSettings::RegionMapBehindUI
              (UI_WIDTH + UI_BORDER_WIDTH) - ((width / 2) + @mapOffsetX + cursorOffset)
            else
              if @mapWidth > UI_WIDTH
                (UI_WIDTH + UI_BORDER_WIDTH) - ((width / 2) + cursorOffset)
              else
                UI_WIDTH - (@mapOffsetX + cursorOffset)
              end
            end
    minY = if !ARMSettings::RegionMapBehindUI
              (UI_BORDER_HEIGHT + @mapOffsetY + cursorOffset) - curCorr
            else
              if @mapHeight > UI_HEIGHT
                (UI_BORDER_HEIGHT + cursorOffset) - curCorr
              else
                @mapOffsetY + cursorOffset
              end
            end
    maxY = if !ARMSettings::RegionMapBehindUI
              (UI_HEIGHT + UI_BORDER_HEIGHT) - (height + @mapOffsetY + cursorOffset)
            else
              if @mapHeight > UI_HEIGHT
                (UI_HEIGHT + UI_BORDER_HEIGHT) - (height + cursorOffset)
              else
                (UI_HEIGHT + UI_BORDER_HEIGHT) - (@mapOffsetY + cursorOffset)
              end
            end
    return {
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY
    }
  end
end
