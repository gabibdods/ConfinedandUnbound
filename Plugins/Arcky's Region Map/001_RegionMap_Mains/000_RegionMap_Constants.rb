class PokemonRegionMap_Scene
  ENGINE20 = Essentials::VERSION.include?("20")
  ENGINE21 = Essentials::VERSION.include?("21")

  QUESTPLUGIN = PluginManager.installed?("Modern Quest System + UI")
  BERRYPLUGIN = PluginManager.installed?("TDW Berry Planting Improvements")
  WEATHERPLUGIN = PluginManager.installed?("Lin's Weather System") && ARMSettings::UseWeatherPreview
  THEMEPLUGIN = PluginManager.installed?("Lin's Pokegear Themes")

  ZERO_POINT_X  = ARMSettings::CursorMapOffset ? 1 : 0
  ZERO_POINT_Y  = ARMSettings::CursorMapOffset ? 1 : 0

  REGION_UI = ARMSettings::ChangeUIOnRegion
  UI_BORDER_WIDTH = 16 # don't edit this
  UI_BORDER_HEIGHT = 32 # don't edit this
  UI_WIDTH = Settings::SCREEN_WIDTH - (UI_BORDER_WIDTH * 2)
  UI_HEIGHT = Settings::SCREEN_HEIGHT - (UI_BORDER_HEIGHT * 2)
  BEHIND_UI = ARMSettings::RegionMapBehindUI ? [0, 0, 0, 0] : [UI_BORDER_WIDTH, (UI_BORDER_WIDTH * 2), UI_BORDER_HEIGHT, (UI_BORDER_HEIGHT * 2)]

  FOLDER = "Graphics/Pictures/RegionMap/" if ENGINE20
  FOLDER = "Graphics/UI/Town Map/" if ENGINE21
  UI_FOLDER = ARMSettings::UseSpecialUI ? "Special" : "Default"
  SPECIAL_UI = ARMSettings::ExtendedMainInfoFixed && ARMSettings::UseSpecialUI && !THEMEPLUGIN

  BOX_BOTTOM_LEFT = ARMSettings::ButtonBoxPosition == 2
  BOX_BOTTOM_RIGHT = ARMSettings::ButtonBoxPosition == 4
  BOX_TOP_LEFT = ARMSettings::ButtonBoxPosition == 1
  BOX_TOP_RIGHT = ARMSettings::ButtonBoxPosition == 3
  BOX_PREVIEW_DISABLED = ARMSettings::ButtonBoxPosition.nil?

  REGIONNAMES = MessageTypes::RegionNames if ENGINE20
  REGIONNAMES = MessageTypes::REGION_NAMES if ENGINE21

  LOCATIONNAMES = MessageTypes::PlaceNames if ENGINE20
  LOCATIONNAMES = MessageTypes::REGION_LOCATION_NAMES if ENGINE21

  POINAMES = MessageTypes::PlaceDescriptions if ENGINE20
  POINAMES = MessageTypes::REGION_LOCATION_DESCRIPTIONS if ENGINE21

  SCRIPTTEXTS = MessageTypes::ScriptTexts if ENGINE20
  SCRIPTTEXTS = MessageTypes::SCRIPT_TEXTS if ENGINE21
end
