#===============================================================================
# * Main
#===============================================================================

module GameData
  class Item
    alias bp_initialize initialize
    def initialize(hash)
      bp_initialize(hash)
      @bp_price = hash[:bp_price] || @price
    end
  end

  class TrainerType
    attr_reader :base_bp

    SCHEMA["BaseBP"] = [:base_bp, "u"]

    def self.editor_properties
      gender_array = []
      self.schema["Gender"][2].each { |key, value| gender_array[value] = key if !gender_array[value] }
      return [
        ["ID",         ReadOnlyProperty,               _INTL("ID of this Trainer Type (used as a symbol like :XXX).")],
        ["Name",       StringProperty,                 _INTL("Name of this Trainer Type as displayed by the game.")],
        ["Gender",     EnumProperty.new(gender_array), _INTL("Gender of this Trainer Type.")],
        ["BaseMoney",  LimitProperty.new(9999),        _INTL("Player earns this much money times the highest level among the trainer's Pokémon.")],
        ["BaseBP",     LimitProperty.new(9999),        _INTL("Player earns this much BP times the highest level among the trainer's Pokémon.")],
        ["SkillLevel", LimitProperty2.new(9999),       _INTL("Skill level of this Trainer Type.")],
        ["Flags",      StringListProperty,             _INTL("Words/phrases that can be used to make trainers of this type behave differently to others.")],
        ["IntroBGM",   BGMProperty,                    _INTL("BGM played before battles against trainers of this type.")],
        ["BattleBGM",  BGMProperty,                    _INTL("BGM played in battles against trainers of this type.")],
        ["VictoryBGM", BGMProperty,                    _INTL("BGM played when player wins battles against trainers of this type.")]
      ]
    end

    alias bp_initialize initialize
    def initialize(hash)
      bp_initialize(hash)
      @base_bp = hash[:base_bp] || @base_money
    end
  end
end

class Trainer
  def base_bp; return GameData::TrainerType.get(self.trainer_type).base_bp; end
end

def pbActiveCharm(charm)
  if PluginManager.installed?("Charms Compilation") || PluginManager.installed?("Charms Case")
    return $player.activeCharm?(charm)
  else
    return $bag.has?(charm)
  end
end