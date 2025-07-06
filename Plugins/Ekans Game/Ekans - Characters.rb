#===============================================================================
# Ekans Game
# By Swdfm
# Characters Page
#===============================================================================
module Ekans_Game
  def self.characters_data
    return {
	  :EKANS => {
	    :default => true,
		:order => 0
	  },
	  :SILICOBRA => {
	    :conditions => $player.seen?(:SILICOBRA),
		:order => 1
	  },
	  :SEVIPER => {
	    :conditions => $player.seen?(:SEVIPER),
		:order => 2
	  },
	  :SERPERIOR => {
	    :conditions => $player.seen?(:SERPERIOR),
		:order => 3
	  },
	  :ONIX => {
	    :conditions => $player.seen?(:ONIX),
		:order => 3
	  }
	}
  end
  
  def self.character
    return progress.character
  end
  
  def self.get_default_character
    if characters_data.keys.empty?
	  raise "You have not set any characters. Do so in the Characters Page!"
	end
    for k, v in characters_data
	  return k if v[:default]
	end
	return characters_data.keys.sample # failsafe!
  end
  
  def self.get_available_characters
    ret = []
    for s, v in characters_data
	  if v.keys.include?(:conditions)
	    next unless v[:conditions]
	  end
	  ret.push(s)
	end
	if ret.empty? # failsafe!
	  ret = [get_default_character]
	end
	ret.sort!{ |a, b|
	  characters_data[a][:order] <=> characters_data[b][:order]
	}
	return ret
  end
  
  def self.get_current_character_name
    return GameData::Species.get(progress.character).name
  end
end