﻿#===============================================================================
# * Weather System Handler
#===============================================================================

# Code that creates the weather on map when the player enters it.
# Weather is forced to clear when entering a map that isn't outdoors.
EventHandlers.add(:on_enter_map, :change_weather,
  proc { |_old_map_id|
    next if !$game_map
    pbInitializeWeather if !$WeatherSystem.actualWeather || $WeatherSystem.actualWeather.length == 0
    $game_screen.weather(:None,0,0) unless $game_map.metadata&.outdoor_map
#    $game_screen.weather(:None,0,0) if WeatherConfig::NO_WEATHER
    next unless $game_map.metadata&.outdoor_map
    next if WeatherConfig::NO_WEATHER
    pbFindZone
    i = $WeatherSystem.currentZone
#    $game_screen.weather(:None,0,0) if $WeatherSystem.currentZone == nil
    next if $WeatherSystem.currentZone == nil
    pbUpdateWeather(i) if !WeatherConfig::FORCE_UPDATE
    weather = $WeatherSystem.actualWeather[i].mainWeather
    weather = pbCheckValidWeather(weather, i)
    weather = :None if PBDayNight.isNight? && weather == :Sun
    next if $game_screen.weather_type == weather
    power = (weather == :None) ? 0 : 9
    duration = 0
    $game_screen.weather(weather,power,duration)
  }
)

# Code that clears the weather when the player leaves a map.
EventHandlers.add(:on_leave_map, :end_weather_system,
  proc { |new_map_id, new_map|
    $game_screen.weather(:None,0,0) if WeatherConfig::NO_WEATHER
  }
)