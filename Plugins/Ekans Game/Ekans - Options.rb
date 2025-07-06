#===============================================================================
# Ekans Game
# By Swdfm
# Options Page
#===============================================================================
module Ekans_Game
  def self.options_data
    return {
	  :new_game => {
	    :name => _INTL("New Game"),
		:order => 0
	  },
	  :continue => {
	    :name => _INTL("Continue"),
		:order => 1,
		:conditions => progress.in_game
	  },
	  :hiscores => {
	    :name => _INTL("Hiscores"),
		:order => 2
	  },
	  :difficulty => {
	    :name => _INTL("Difficulty"),
		:order => 3,
		:rhs_text => (progress.difficulty + 1).to_s,
		:limit => 8,
		:value => progress.difficulty
	  },
	  :field_type => {
	    :name => _INTL("Game Type"),
		:order => 4,
		:rhs_text => field_name(progress.game_type),
		:limit => get_available_fields.length,
		:value => get_available_fields.index(progress.game_type)
	  },
	  :player => {
	    :name => _INTL("Player"),
		:order => 5,
		:conditons => get_available_characters.length > 1,
		:rhs_text => get_current_character_name,
		:limit => get_available_characters.length,
		:value => get_available_characters.index(progress.character)
	  },
	  :exit => {
	    :name => _INTL("Exit"),
		:order => 6
	  }
	}
  end
  
  def self.option_name(c)
    return options_data[c][:name]
  end
  
  def self.get_available_options
    ret = []
    for s, v in options_data
	  if v.keys.include?(:conditions)
	    next unless v[:conditions]
	  end
	  ret.push(s)
	end
	if ret.empty? # failsafe!
	  raise "You have got rid of all of the Menu Options! Set them again in the Options Page!"
	end
	ret.sort!{ |a, b|
	  options_data[a][:order] <=> options_data[b][:order]
	}
	return ret
  end
  
# Used in Main Menu
  def self.rhs_text(c)
	return options_data[c][:rhs_text] || ""
  end
  
  def self.move_value_menu(c, right = false)
    v = options_data[c][:value]
    return false unless v
	v = right ? v + 1 : v - 1
	lim = options_data[c][:limit]
	if v < 0
	  v = lim - 1
	elsif v >= lim
	  v = 0
	end
    change_menu_value(c, v)
	return true
  end
  
  def self.change_menu_value(c, value)
    case c
	when :difficulty
	  progress.difficulty = value
	when :field_type
	  progress.game_type = get_available_fields[value]
	when :player
	  progress.character = get_available_characters[value]
	end
  end
end