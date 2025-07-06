#===============================================================================
# Ekans Game
# By Swdfm
# Field Page
#===============================================================================
module Ekans_Game
  FIELD_DATA = {
    :standard => {
	  :metal => {},
	  :order => 0,
	  :default => true
	},
    :box => {
	  # [xs] => [ys]
	  :metal => {
	    [0, :last_0] => [0, 1, :last_1, :last_0],
	    [1, :last_1] => [0, :last_0]
	  },
	  :order => 1
	},
    :tunnel => {
	  :metal => {
	   [4, 5, 6, 7] => [0, :mid, :last_0]
	  },
	  :order => 2
	},
    :mill => {
	  :metal => {
	    [:all] => [:mid]
	  },
	  :order => 3
	},
    :rails => {
	  :metal => {
	    [:mid] => [:below_5],
	    [:below_mid] => [:mid]
	  },
	  :order => 4
	},
    :apartment => {
	  :metal => {
	    [4] => [:below_4],
	    [:mid] => [:above_11],
	    [:above_4] => [4],
	    [:below_mid] => [11]
	  },
	  :order => 5
	}
  }
  
  def self.field_name(f)
    return {
	  :standard  => _INTL("Standard"),
	  :box       => _INTL("Box"),
	  :tunnel    => _INTL("Tunnel"),
	  :mill      => _INTL("Mill"),
	  :rails     => _INTL("Rails"),
	  :apartment => _INTL("Apartment")
	}[f]
  end
  
  def self.get_field
    return progress.game_type
  end
  
  def self.get_default_field
    if FIELD_DATA.keys.empty?
	  raise "You have not set any fields. Do so in the Field Page!"
	end
    for k, v in FIELD_DATA
	  return k if v[:default]
	end
	return FIELD_DATA.keys.sample # failsafe!
  end
  
  def self.get_available_fields
    ret = []
    for s, v in FIELD_DATA
	  if v.keys.include?(:conditions)
	    next unless v[:conditions]
	  end
	  ret.push(s)
	end
	if ret.empty? # failsafe!
	  ret = [get_default_field]
	end
	ret.sort!{ |a, b|
	  FIELD_DATA[a][:order] <=> FIELD_DATA[b][:order]
	}
	return ret
  end
  
  # Metal
  def self.compile_metal
    ret = {}
    hash = FIELD_DATA[get_field][:metal]
	for k, v in hash
	  k_a = interpret_metal_array(k)
	  v_a = interpret_metal_array(v, true)
	  for k_i in k_a
	    for v_i in v_a
	      ret[[k_i, v_i]] = true
		end
	  end
	end
	return ret
  end
  
  def self.interpret_metal_array(a, is_y = false)
    size = is_y ? BOARD_HEIGHT : BOARD_WIDTH
	mid = (size - 1).quot(2) + 1
    a = [a] unless a.is_a?(Array)
	ret = []
	for i in a
	  if i.is_a?(Integer)
	    ret.push(i)
		next
	  end
	  # i is a Symbol
	  case i
	  when :all
	    for ii in 0...size
		  ret.push(ii)
		end
		next
	  when :mid
	    ret.push(mid)
		next
      end
	  lhs, rhs = i.to_s.split("_")
	  lhs = lhs.to_sym
	  rhs = rhs == "mid" ? mid : rhs.to_i
	  case lhs
	  when :last
	    ret.push(size - 1 - rhs)
	  when :below
	    for ii in 0..rhs
		  ret.push(ii)
		end
	  when :above
	    for ii in rhs...size
		  ret.push(ii)
		end
	  end
	end
	return ret
  end
end
