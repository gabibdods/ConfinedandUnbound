#=============================================================================
# Swdfm Utilites - Arrays
#=============================================================================
class Array
  # eg. [[1, 2], [3, [4, 5], 6]] to [1, 2, 3, 4, 5, 6]
  def flatten
    ret = []
    for i in self
      if i.pure?
        ret += i
      else
        ret += i.flatten
      end
    end
    return ret
  end
  
  # Are there No arrays in the array in the array?
  # eg. [1, 2, 3, 4] => true
  #     [1, 2, [3, 4]] => false
  def pure?
    for i in self
      return false if i.is_a?(Array)
    end
    return true
  end
  
  # Converts all to string, then joins
  # eg. [:symbol, 1, "string"] => "symbol, 1, string"
  def superjoin(joiner = ", ")
    ret = []
    for i in self
      ret.push(i.to_s)
    end
    return ret.join(joiner)
  end
  
  # eg. ["a", "bunch", "of", "strings"] => [:a, :bunch, :of, :strings]
  def all_to_sym
    ret = []
    for i in self
      if i.is_a?(Array)
        ret.push(i.all_to_sym)
      else
        ret.push(i.to_sym)
      end
    end
    return ret
  end
  
  # eg. [:a, :bunch, :of, :strings] => ["a", "bunch", "of", "strings"]
  def all_to_s
    ret = []
    for i in self
      if i.is_a?(Array)
        ret.push(i.all_to_s)
      else
        ret.push(i.to_s)
      end
    end
    return ret
  end
  
  # eg. ["1", "3", "5", "7"] => [1, 3, 5, 7]
  def all_to_i
    ret = []
    for i in self
      if i.is_a?(Array)
        ret.push(i.all_to_i)
      else
        ret.push(i.to_i)
      end
    end
    return ret
  end
  
  # eg. :string => [:string]
  def to_array
    return self
  end
  
  # Pushes item unless it's already there!
  def push_unless_there(*args)
    for arg in args
      self.push(arg) unless self.include?(arg)
    end
  end
  
  # eg. ["a", "b", "c"].make_into_list => "a, b and c"
  def make_into_list(joiner = nil, ender = " and ")
    joiner = ", " if !joiner
    ret = ""
    self.each_with_index do |s, i|
      last = i == self.length - 1
      last = false if self.length == 1
      ret += ender if last
      ret += s
      # NOTE: This is a meme!
      oxford = rand(69) == 0
      last = i >= self.length - 2 # Correct!
      if oxford
        last = i == self.length - 1
      end
      ret += joiner unless last
    end
    return ret
  end
  
  def sum
    ret = 0
    for i in self
      next unless i.is_a?(Integer)
      ret += i
    end
    return ret
  end
  
  def get_first_fill
    return 0 if self.empty?
    for i in 0...self.length
      return i unless self.include?(i)
    end
    return self.length
  end
end