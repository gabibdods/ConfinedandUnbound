class PokemonRegionMap_Scene
  def findUsableUI(image)
    if THEMEPLUGIN
      # Use Current set Theme's UI Graphics
      return "#{FOLDER}UI/#{$PokemonSystem.pokegear}/#{image}"
    else
      folderUI = "UI/Region#{@region}/"
      bitmap = pbResolveBitmap("#{FOLDER}#{folderUI}#{image}")
      if bitmap && ARMSettings::ChangeUIOnRegion
        # Use UI Graphics for the Current Region.
        return "#{FOLDER}#{folderUI}#{image}"
      else
        # Use Default UI Graphics.
        return "#{FOLDER}UI/#{UI_FOLDER}/#{image}"
      end
    end
  end

  def getTimeOfDay
    path = "#{FOLDER}Regions/"
    return "#{path}#{@regionFile}" if !ARMSettings::TimeBasedRegionMap
    if PBDayNight.isDay?
      time = "Day"
    elsif PBDayNight.isNight?
      time = "Night"
    elsif PBDayNight.isMorning?
      time = "Morning"
    elsif PBDayNight.isAfternoon?
      time = "Afternoon"
    elsif PBDayNight.isEvening?
      time = "Evening"
    end
    file = @regionFile.chomp(".png") << time << ".png"
    bitmap = pbResolveBitmap("#{path}#{file}")
    unless bitmap
      case time
      when /Morning|Afternoon|Evening|Night/
        time = "Day"
      else
        Console.echoln_li _INTL("There was no file named '#{file}' found.")
        time = ""
      end
    end
    file = @regionFile.chomp(".png") << time << ".png"
    return "#{path}#{file}"
  end

  def locationShown?(point)
    return (point[5] == nil && point[1] > 0 && $game_switches[point[1]]) || point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def createObject
    object = {
      offsetX: 0,
      offsetY: 0,
      newX: 0,
      newY: 0,
      oldX: 0,
      oldY: 0
    }
    return object
  end

  def getMapFolderName(image)
    name = image[:name]
    case name
    when /Route/
      mapFolder = "Routes"
    else
      mapFolder = "Others"
    end
    return mapFolder
  end
end
