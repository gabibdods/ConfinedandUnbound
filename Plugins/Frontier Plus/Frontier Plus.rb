#======================================================
# Frontier Plus: Script Page
# By Swdfm
# 2024-10-31
#======================================================
# Requires: Swdfm Utilities Plugin!
#-------------------------------
# Set to false if using converter!
USE_FRONTIER_PLUS = true
#-------------------------------
# What does this plugin do?
# - Changes all battle frontier pokemon PBS files (NOT trainer files!):
#    a) to match a neater format
#    b) to allow for
#      i) an ability
#      ii) specific EVs
#      iii) a tera type (if applicable)
# - Converts a smogon PBS file to the new format of frontier pokemon PBS files
#   A smogon PBS file is basically a bunch of "Export" files from smogon
#    on top of one another in a .txt file
#-------------------------------
# To change your vanilla files to the new format, use:
# 1) Ensure USE_FRONTIER_PLUS is set to false!
# 2) Run "Frontier_Plus.convert_files" in DEBUG
# 3) Ensure USE_FRONTIER_PLUS is set to true!
#-------------------------------
# To convert a smogon file:
# Run "Frontier_Plus.convert_smogon(p)",
#  where "p" is the path within the game folder
#  of the .txt file you wish to convert!
#-------------------------------
# NOTES:
# 1) The [id] numbers in the PBS file are not indicative of which pokemon
#     are picked by the trainers in their ID files
#     They are ordered in order like the vanilla and the numbers are guideline only!
#     To order properly, use Frontier_Plus.neaten_files
# 2) This has NOT been tested for tera types yet!
# 3) When the game in the Battle Frontier asks
#     if you want to generate new team, ALWAYS ANSWER "NO"
#======================================================
# Don't mess with anything below here!
# Unless you know what's up!
# Having said that, if you're starting scripting,
#  there's some useful stuff here to look at!
#======================================================
# Section 1: Custom Module
#======================================================
module Frontier_Plus
  CORE = ["species", "moves"]
  LHS_VALID = CORE + [
    "item", "nature", "evs", "ability",
    "evs_core", "tera"
  ]
  EV_HASH = {
    "HP" => :HP,
    "ATK" => :ATTACK,
    "DEF" => :DEFENSE,
    "SA" => :SPECIAL_ATTACK,
    "SD" => :SPECIAL_DEFENSE,
    "SPD" => :SPEED
  }
  
#-------------------------------
# Converts all vanilla frontier pokemon files
# NOTE: It doesn't do cup_fancy_pkmn as it
#  isn't defined in battle_facility_lists
#  This can be bypassed with Frontier_Plus.convert_file("cup_fancy_pkmn")
  def self.convert_files(is_neaten = false)
    return unless $DEBUG
    files = Compiler.gather_pokemon_frontier_files
    echoln Swd.pbsline
    unless is_neaten
      echoln "Converting pokemon frontier PBS files"
    else
      echoln "Neatening pokemon frontier PBS files"
    end
    echoln Swd.pbsline
    for p in files
      unless is_neaten
        echoln "- Converting file #{p}..."
      else
        echoln "- Neatening file #{p}..."
      end
      convert_file(p, is_neaten)
    end
    echoln Swd.pbsline
    unless is_neaten
      echoln "Done! All your pokemon frontier PBS files should now be in the new format!"
      echoln "On Frontier Plus Plugin page, set USE_FRONTIER_PLUS to true, and it should now work!"
    else
      echoln "Done! All your pokemon frontier PBS files should now have their IDs in order!"
    end
  end
  
#-------------------------------
# Converts a vanilla frontier pokemon file to the new format
# if is_neaten is set to true:
# Neatens ID numbers of a frontier pokemon file to the new format
  def self.convert_file(p, is_neaten = false)
    ret = []
    id = 0
    Swd.read_pbs_neat(p, true).each_with_index do |line, i|
      unless is_neaten
        ret += convert_line(line, i)
      else
        if line.starts_with?("[")
          ret.push(Swd.pbsline)
          line = "[#{id}]"
          id += 1
        end
        ret.push(line)
      end
    end
    Swd.dump_txt_pbs(ret, p)
	return if is_neaten
	convert_file(p, true)
  end
  
#-------------------------------
# Converts a line from vanilla PBS file to new format
  def self.convert_line(line, i)
    return [line] unless line.include?(";") # Stops converting twice!
    #species, item, nature, evs, moves = line.split(";")
    ret = [Swd.pbsline, "[#{i}]"]
    ret.push("species = #{species}")
    ret.push("item = #{item}")
    ret.push("nature = #{nature}")
    evs.gsub!(",", ", ")
    ret.push("evs = #{evs}")
    moves.gsub!(",", ", ")
    ret.push("moves = #{moves}")
    return ret
  end
  
#-------------------------------
# Neatens all ID numbers of a new format pokemon frontier PBS file
  def self.neaten_files
    convert_files(true)
  end
  
#-------------------------------
# Compiles a line from the new pbs format
# Used in Compiler
  def self.compile_pbs(line, hash, id_number)
    hash["new_section"] = line.starts_with?("[")
    return hash if hash["new_section"]
    lhs, rhs = line.unblanked.split("=")
    lhs = lhs.downcase
    return hash unless LHS_VALID.include?(lhs)
    # Validation (sort of)!
    case lhs
    when "species"
      rhs = GameData::Species.exists?(rhs.to_sym) ? GameData::Species.get(rhs.to_sym).id : nil
    when "item"
      rhs = GameData::Item.exists?(rhs.to_sym) ? GameData::Item.get(rhs.to_sym).id : nil
    when "nature"
      rhs = GameData::Nature.exists?(rhs.to_sym) ? GameData::Nature.get(rhs.to_sym).id : nil
    when "ability"
      rhs = GameData::Ability.exists?(rhs.to_sym) ? GameData::Ability.get(rhs.to_sym).id : nil
    when "tera"
      rhs = GameData::Type.exists?(rhs.to_sym) ? GameData::Type.get(rhs.to_sym).id : nil
    when "evs"
      evs = rhs.unblanked.split(",")
      rhs = []
      for ev in evs
        t_ev = evaluate_ev(ev)
        rhs.push(t_ev) if t_ev
      end
    when "evs_core"
      evs = rhs.unblanked.split(",")
      rhs = {}
      for ev_c in evs
        next unless ev_c.include?("_")
        ev, amt = ev_c.split("_")
        ev = evaluate_ev(ev)
        next unless ev
        amt = amt.to_i
        rhs[ev] = amt
      end
    when "moves"
      moves = rhs.unblanked.split(",")
      rhs = []
      for move in moves
        move_data = GameData::Move.try_get(move.to_sym)
        rhs.push(move_data.id) if move_data
      end
      rhs.push(GameData::Move.keys.first) if rhs.length == 0 # Get any one move
    end
    hash[lhs] = rhs
    return hash
  end
  
#-------------------------------
# Used to deal with EVs
  def self.evaluate_ev(s)
    s = s.upcase
    s = "SA" if s == "SPATK"
    s = "SD" if s == "SPDEF"
    return EV_HASH[s] || nil
  end
  
#-------------------------------
  def self.convert_smogon(p)
    sns = []
	t_sn = []
    echoln Swd.pbsline
    echoln "Converting Smogon File: #{p}..." 
    echoln Swd.pbsline
    Swd.read_txt_neat(p, true).each_with_index do |line, i|
      if line.include?("@")
        unless t_sn.empty? # Avoids first being empty!
          sns.push(t_sn)
          t_sn = []
        end
      end
      t_sn.push(line)
    end
    unless t_sn.empty? # Adds last!
      sns.push(t_sn)
    end
    ret = []
    sns.each_with_index do |sn, i|
      ret += convert_smogon_sn(sn, i)
    end
    Swd.dump_txt(ret, p)
    echoln Swd.pbsline
    echoln "Done! All your smogon format pokemon should now be in the new format!"
    echoln "Remember, on Frontier Plus Plugin page, set USE_FRONTIER_PLUS to true for it to work!"
  end
  
#-------------------------------
# Converts Smogon lines to new PBS format
  def self.convert_smogon_sn(lines, pref_id = 0)
    ret = [Swd.pbsline, "[#{pref_id}]"]
    # NOTE: there may be weird exceptions
    status = "sp_item"
    moves = []
    for line in lines
      next if line.unblanked == ""
      if line.include?("@")
        status = "sp_item"
      elsif line.starts_with?("Ability:")
        status = "ability"
      elsif line.starts_with?("EVs:")
        status = "evs_core"
      elsif line.starts_with?("Tera Type:")
        status = "tera"
      elsif line.starts_with?("-") # Move
        status = "move"
      elsif line.ends_with?("Nature") &&
         !line.include?(":")
        status = "nature"
      end
      str = ""
      case status
      when "sp_item"
        # First Line: Species and Item
        species, item = line.unblanked.split("@")
        species = filter_smogon_str(species)
        ret.push("species = #{species}")
        if item && item != ""
          item = filter_smogon_str(item)
          ret.push("item = #{item}")
        end
      when "ability", "tera"
        str = line.unblanked.split(":")[1]
      when "evs_core"
        str = []
        rhs = line.split(":")[1].sandwich
        for t_ev in rhs.split("/")
          t_ev = t_ev.sandwich
          amount, stat = t_ev.split(" ")
          stat = evaluate_ev_smogon(stat)
          str.push("#{stat}_#{amount}")
        end
        str = str.join(", ")
      when "nature"
        str = line.split(" ")[0].sandwich
      when "move"
        move = line.after_first(" ").unblanked
        move = filter_smogon_str(move)
        moves.push(move)
      end
      # Adds to lines!
      if str != ""
        str = filter_smogon_str(str)
        ret.push("#{status} = #{str}")
      end
    end
    unless moves.empty?
      ret.push("moves = #{moves.join(", ")}")
    end
    return ret
  end
  
#-------------------------------
# Filters a string to make it suitable for Essentials
# Removes the - (eg. will-o-wisp) etc.
  def self.filter_smogon_str(str)
    str = str.upcase
    str = str.multi_delete("-", ".", ":")
    str.gsub!("é".upcase, "E")
    return str
  end
  
#-------------------------------
# Used to deal with EVs in smogon conversion
  def self.evaluate_ev_smogon(s)
    s = s.upcase
    s = "SA" if s == "SPA"
    s = "SD" if s == "SPD"
    s = "SPD" if s == "SPE"
    return s
  end
end

#======================================================
# Section 2: Changes To Compiler
#======================================================
module Compiler
#-------------------------------
# Works out which pokemon files need to be converted
  def self.gather_pokemon_frontier_files(path = "PBS/battle_facility_lists.txt")
    if !FileTest.exist?(path)
      raise "File #{path} needs to exist so we know which files to convert. If you have not defined any there, you can convert a file individually with Frontier_Plus.convert_file(p), where p is the name of the PBS file"
    end
    ret = []
    File.open(path, "rb") do |f|
      idx = 0
      pbEachFileSection(f) do |section, name|
        idx += 1
        Graphics.update
        next if name != "DefaultTrainerList" && name != "TrainerList"
        rsection = []
        key = "Pokemon"
        schema = [1, "s"]
        next if !schema
        record = get_csv_record(section[key], schema)
        rsection = record
        if rsection && FileTest.exist?("PBS/" + rsection)
          ret.push(rsection)
        end
      end
    end
    ret |= []
    return ret
  end
  
#-------------------------------
# Allows new format to be used
  module_function
  def compile_trainer_lists(path = "PBS/battle_facility_lists.txt")
    compile_pbs_file_message_start(path)
    btTrainersRequiredTypes = {
      "Trainers"   => [0, "s"],
      "Pokemon"    => [1, "s"],
      "Challenges" => [2, "*s"]
    }
    if !FileTest.exist?(path)
      File.open(path, "wb") do |f|
        f.write(0xEF.chr)
        f.write(0xBB.chr)
        f.write(0xBF.chr)
        f.write("[DefaultTrainerList]\r\n")
        f.write("Trainers = battle_tower_trainers.txt\r\n")
        f.write("Pokemon = battle_tower_pokemon.txt\r\n")
      end
    end
    sections = []
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_INTRO_SPEECHES, [])
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, [])
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, [])
    File.open(path, "rb") do |f|
      FileLineData.file = path
      idx = 0
      pbEachFileSection(f) do |section, name|
        echo "."
        idx += 1
        Graphics.update
        next if name != "DefaultTrainerList" && name != "TrainerList"
        rsection = []
        section.each_key do |key|
          FileLineData.setSection(name, key, section[key])
          schema = btTrainersRequiredTypes[key]
          next if key == "Challenges" && name == "DefaultTrainerList"
          next if !schema
          record = get_csv_record(section[key], schema)
          rsection[schema[0]] = record
        end
        if !rsection[0]
          raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
        end
        if !rsection[1]
          raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
        end
        rsection[3] = rsection[0]
        rsection[4] = rsection[1]
        rsection[5] = (name == "DefaultTrainerList")
        if FileTest.exist?("PBS/" + rsection[0])
          rsection[0] = compile_battle_tower_trainers("PBS/" + rsection[0])
        else
          rsection[0] = []
        end
        if FileTest.exist?("PBS/" + rsection[1])
          filename = "PBS/" + rsection[1]
          rsection[1] = []
#-------------------------------
# Changes made here:
          if USE_FRONTIER_PLUS
            hash = {}
            Swd.read_txt_neat(filename, true).each_with_index do |line, _lineno|
              hash = Frontier_Plus.compile_pbs(line, hash, rsection[1].length)
              if hash["new_section"]
                unless hash.keys.length == 1 # Not First instance!
                  # Adds Previous Section
                  rsection[1].push(PBPokemon.new(hash))
                  hash = {}
                end
              end
            end
            # Last Section!
            unless hash.keys.empty?
              rsection[1].push(PBPokemon.new(hash))
            end
          else
            pbCompilerEachCommentedLine(filename) do |line, _lineno|
              rsection[1].push(PBPokemon.fromInspected(line))
            end
          end
        else
          rsection[1] = []
        end
        rsection[2] = [] if !rsection[2]
        while rsection[2].include?("")
          rsection[2].delete("")
        end
        rsection[2].compact!
        sections.push(rsection)
      end
    end
    save_data(sections, "Data/trainer_lists.dat")
    process_pbs_file_message_end
  end
end

#======================================================
# Section 3: Changes to PBPokemon class
# NOTE: This is NOT Pokemon class!
# NOTE: No changes made to fromInspected
#======================================================
class PBPokemon
#-------------------------------
# Changes to initialize method
  alias swdfm_init initialize
  def initialize(*args)
    unless USE_FRONTIER_PLUS
      return swdfm_init(*args)
    end
    hash = args[0]
    @species = hash["species"]
    itm = GameData::Item.try_get(hash["item"])
    @item    = itm ? itm.id : nil
    @nature  = hash["nature"]
    @ability = hash["ability"]
    @move1, @move2, @move3, @move4 = hash["moves"]
    @ev = []
    for t_ev in hash["evs"]
      @ev.push(GameData::Stat.get(t_ev))
    end
    @ev_core = hash["evs_core"] || {}
    @tera = hash["tera"]
  end
  
#-------------------------------
# Changes to createPokemon method
  alias swdfm_create_pokemon createPokemon
  def createPokemon(level, iv, trainer)
    unless USE_FRONTIER_PLUS
      return swdfm_create_pokemon(level, iv, trainer)
    end
    pkmn = Pokemon.new(@species, level, trainer, false)
    pkmn.item = @item if @item
    pkmn.personalID = rand(2**16) | (rand(2**16) << 16)
    pkmn.nature = @nature if @nature
    pkmn.happiness = 0
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move1)))
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move2))) if @move2
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move3))) if @move3
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move4))) if @move4
    pkmn.moves.compact!
    if @ev.length > 0
      @ev.each { |stat| pkmn.ev[stat.id] = Pokemon::EV_LIMIT / @ev.length }
    end
    # Ability
    pkmn.ability = @ability if @ability
    # EVs specific
    if @ev_core.keys.length > 0
      pkmn.ev = {}
      for stat, amount in @ev_core
        pkmn.ev[stat] = amount
      end
      GameData::Stat.each_main do |s|
	    next if pkmn.ev[s.id]
	    pkmn.ev[s.id] = 0
	  end
    end
    # Tera Type (If Applicable)
    # Shoutout to Ludicious!
    if Pokemon.method_defined?(:tera_type)
      pkmn.tera_type = @tera if @tera
    end
    GameData::Stat.each_main { |s| pkmn.iv[s.id] = iv }
    pkmn.calc_stats
    return pkmn
  end
  
#-------------------------------
# Changes to inspect method
# NOTE: The ID numbers will be weird but this does not actually matter!
  alias swdfm_inspect inspect
  def inspect
    ret = swdfm_inspect
    unless USE_FRONTIER_PLUS
      return ret
    end
    ret = Frontier_Plus.convert_line(ret, 0)
    if @ability
      ab = GameData::Ability.get(@ability).id
      ret.push("ability = #{ab}")
    end
    if @ev_core && !@ev_core.keys.empty?
      ev_a = []
      for stat, amount in @ev_core
        for lhs, rhs in Frontier_Plus::EV_HASH
          next unless rhs == stat
          ev_a.push("#{lhs}_#{amount}")
        end
      end
      ret.push("evs_core = #{ev_a.join(", ")}")
    end
    if @tera
      ty = GameData::Type.get(@tera).id
      ret.push("tera = #{ty}")
    end
    return ret.join("\n")
  end
  
#-------------------------------
# Needed to provide alias for self
  class << self
    alias swdfm_from_pokemon fromPokemon
    
#-------------------------------
# Changes made to self.fromPokemon
    def fromPokemon(pkmn)
      unless USE_FRONTIER_PLUS
        return swdfm_from_pokemon(pkmn)
      end
      mov1 = (pkmn.moves[0]) ? pkmn.moves[0].id : nil
      mov2 = (pkmn.moves[1]) ? pkmn.moves[1].id : nil
      mov3 = (pkmn.moves[2]) ? pkmn.moves[2].id : nil
      mov4 = (pkmn.moves[3]) ? pkmn.moves[3].id : nil
      ev_hash = {}
      for stat, amount in pkmn.ev
        next if amount <= 0
        ev_hash[stat] = amount
      end
      hash = {
        "species" => pkmn.species,
        "item" => pkmn.item_id,
        "nature" => pkmn.nature,
        "ability" => pkmn.ability,
        "moves" => [mov1, mov2, mov3, mov4],
        "evs" => [],
        "evs_core" => ev_hash,
        "tera" => nil
      }
      if Pokemon.method_defined?(:tera_type)
        hash["tera"] = pkmn.tera_type
      end
      return new(hash)
    end
    
#-------------------------------
# Ends "self" part
  end
end

#======================================================
# Section 4: Changes to pbRandomPokemonFromRule
# Stops game from crashing in frontier!
# Irritatingly long, but useful, method!
#-------------------------------
def pbRandomPokemonFromRule(rules, trainer)
  pkmn = nil
  iteration = -1
  loop do
    iteration += 1
    species = nil
    level = rules.ruleset.suggestedLevel
    keys = GameData::Species.keys
    loop do
      loop do
        species = keys.sample
        break if GameData::Species.get(species).form == 0
      end
      r = rand(20)
      bst = baseStatTotal(species)
      next if level < minimumLevel(species)
      if iteration.even?
        next if r < 16 && bst < 400
        next if r < 13 && bst < 500
      else
        next if bst > 400
        next if r < 10 && babySpecies(species) != species
      end
      next if r < 10 && babySpecies(species) == species
      next if r < 7 && evolutions(species).length > 0
      break
    end
    ev = []
    GameData::Stat.each_main { |s| ev.push(s.id) if rand(100) < 50 }
    nature = nil
    keys = GameData::Nature.keys
    loop do
      nature = keys.sample
      nature_data = GameData::Nature.get(nature)
      if [:LAX, :GENTLE].include?(nature_data.id) || nature_data.stat_changes.length == 0
        next if rand(20) < 19
      else
        raised_emphasis = false
        lowered_emphasis = false
        nature_data.stat_changes.each do |change|
          next if !ev.include?(change[0])
          raised_emphasis = true if change[1] > 0
          lowered_emphasis = true if change[1] < 0
        end
        next if rand(10) < 6 && !raised_emphasis
        next if rand(10) < 9 && lowered_emphasis
      end
      break
    end
    $legalMoves = {} if level != $legalMovesLevel
    $legalMovesLevel = level
    $legalMoves[species] = pbGetLegalMoves2(species, level) if !$legalMoves[species]
    itemlist = [
      :ORANBERRY, :SITRUSBERRY, :ADAMANTORB, :BABIRIBERRY,
      :BLACKSLUDGE, :BRIGHTPOWDER, :CHESTOBERRY, :CHOICEBAND,
      :CHOICESCARF, :CHOICESPECS, :CHOPLEBERRY, :DAMPROCK,
      :DEEPSEATOOTH, :EXPERTBELT, :FLAMEORB, :FOCUSSASH,
      :FOCUSBAND, :HEATROCK, :LEFTOVERS, :LIFEORB, :LIGHTBALL,
      :LIGHTCLAY, :LUMBERRY, :OCCABERRY, :PETAYABERRY, :SALACBERRY,
      :SCOPELENS, :SHEDSHELL, :SHELLBELL, :SHUCABERRY, :LIECHIBERRY,
      :SILKSCARF, :THICKCLUB, :TOXICORB, :WIDELENS, :YACHEBERRY,
      :HABANBERRY, :SOULDEW, :PASSHOBERRY, :QUICKCLAW, :WHITEHERB
    ]
    # Most used: Leftovers, Life Orb, Choice Band, Choice Scarf, Focus Sash
    item = nil
    loop do
      if rand(40) == 0
        item = :LEFTOVERS
        break
      end
      item = itemlist[rand(itemlist.length)]
      next if !item
      case item
      when :LIGHTBALL
        next if species != :PIKACHU
      when :SHEDSHELL
        next if species != :FORRETRESS && species != :SKARMORY
      when :SOULDEW
        next if species != :LATIOS && species != :LATIAS
      when :FOCUSSASH
        next if baseStatTotal(species) > 450 && rand(10) < 8
      when :ADAMANTORB
        next if species != :DIALGA
      when :PASSHOBERRY
        next if species != :STEELIX
      when :BABIRIBERRY
        next if species != :TYRANITAR
      when :HABANBERRY
        next if species != :GARCHOMP
      when :OCCABERRY
        next if species != :METAGROSS
      when :CHOPLEBERRY
        next if species != :UMBREON
      when :YACHEBERRY
        next if ![:TORTERRA, :GLISCOR, :DRAGONAIR].include?(species)
      when :SHUCABERRY
        next if species != :HEATRAN
      when :DEEPSEATOOTH
        next if species != :CLAMPERL
      when :THICKCLUB
        next if ![:CUBONE, :MAROWAK].include?(species)
      when :LIECHIBERRY
        ev.push(:ATTACK) if !ev.include?(:ATTACK) && rand(100) < 50
      when :SALACBERRY
        ev.push(:SPEED) if !ev.include?(:SPEED) && rand(100) < 50
      when :PETAYABERRY
        ev.push(:SPECIAL_ATTACK) if !ev.include?(:SPECIAL_ATTACK) && rand(100) < 50
      end
      break
    end
    if level < 10 && GameData::Item.exists?(:ORANBERRY)
      item = :ORANBERRY if rand(40) == 0 || item == :SITRUSBERRY
    elsif level > 20 && GameData::Item.exists?(:SITRUSBERRY)
      item = :SITRUSBERRY if rand(40) == 0 || item == :ORANBERRY
    end
    moves = $legalMoves[species]
    sketch = false
    if moves[0] == :SKETCH
      sketch = true
      Pokemon::MAX_MOVES.times { |m| moves[m] = pbRandomMove }
    end
    next if moves.length == 0
    if (moves | []).length < Pokemon::MAX_MOVES
      moves = [:TACKLE] if moves.length == 0
      moves |= []
    else
      newmoves = []
      rest = GameData::Move.exists?(:REST) ? :REST : nil
      spitup = GameData::Move.exists?(:SPITUP) ? :SPITUP : nil
      swallow = GameData::Move.exists?(:SWALLOW) ? :SWALLOW : nil
      stockpile = GameData::Move.exists?(:STOCKPILE) ? :STOCKPILE : nil
      snore = GameData::Move.exists?(:SNORE) ? :SNORE : nil
      sleeptalk = GameData::Move.exists?(:SLEEPTALK) ? :SLEEPTALK : nil
      loop do
        newmoves.clear
        while newmoves.length < [moves.length, Pokemon::MAX_MOVES].min
          m = moves[rand(moves.length)]
          next if rand(100) < 50 && hasMorePowerfulMove(moves, m)
          newmoves.push(m) if m && !newmoves.include?(m)
        end
        if (newmoves.include?(spitup) || newmoves.include?(swallow)) &&
           !newmoves.include?(stockpile) && !sketch
          next
        end
        if (!newmoves.include?(spitup) && !newmoves.include?(swallow)) &&
           newmoves.include?(stockpile) && !sketch
          next
        end
        if newmoves.include?(sleeptalk) && !newmoves.include?(rest) &&
           !((sketch || !moves.include?(rest)) && rand(100) < 20)
          next
        end
        if newmoves.include?(snore) && !newmoves.include?(rest) &&
           !((sketch || !moves.include?(rest)) && rand(100) < 20)
          next
        end
        total_power = 0
        hasPhysical = false
        hasSpecial = false
        hasNormal = false
        newmoves.each do |move|
          d = GameData::Move.get(move)
          next if d.power == 0
          total_power += d.power
          hasNormal = true if d.type == :NORMAL
          hasPhysical = true if d.category == 0
          hasSpecial = true if d.category == 1
        end
        if !hasPhysical && ev.include?(:ATTACK) && rand(100) < 80
          # No physical attack, but emphasizes Attack
          next
        end
        if !hasSpecial && ev.include?(:SPECIAL_ATTACK) && rand(100) < 80
          # No special attack, but emphasizes Special Attack
          next
        end
        r = rand(10)
        next if r > 6 && total_power > 180
        next if r > 8 && total_power > 140
        next if total_power == 0 && rand(100) < 95
        ############
        # Moves accepted
        if hasPhysical && !hasSpecial
          ev.push(:ATTACK) if rand(100) < 80
          ev.delete(:SPECIAL_ATTACK) if rand(100) < 80
        end
        if !hasPhysical && hasSpecial
          ev.delete(:ATTACK) if rand(100) < 80
          ev.push(:SPECIAL_ATTACK) if rand(100) < 80
        end
        item = :LEFTOVERS if !hasNormal && item == :SILKSCARF
        moves = newmoves
        break
      end
    end
    if item == :LIGHTCLAY && moves.none? { |m| [:LIGHTSCREEN, :REFLECT].include?(m) }
      item = :LEFTOVERS
    end
    if item == :BLACKSLUDGE
      types = GameData::Species.get(species).types
      item = :LEFTOVERS if !types.include?(:POISON)
    end
    item = :LEFTOVERS if item == :HEATROCK && moves.none? { |m| m == :SUNNYDAY }
    if item == :DAMPROCK && moves.none? { |m| m == :RAINDANCE }
      item = :LEFTOVERS
    end
    if moves.any? { |m| m == :REST }
      item = :LUMBERRY if rand(100) < 33
      item = :CHESTOBERRY if rand(100) < 25
    end
#-------------------------------
# Changes made here!
    hash = {
      "species" => species,
      "item" => item,
      "nature" => nature,
      "moves" => [moves[0], moves[1], moves[2], moves[3]],
      "evs" => ev,
      "ability" => nil,
      "evs_core" => {},
      "tera" => nil
    }
    if USE_FRONTIER_PLUS
      pk = PBPokemon.new(hash)
    else
      pk = PBPokemon.new(species, item, nature, moves[0], moves[1], moves[2], moves[3], ev)
    end
    pkmn = pk.createPokemon(level, 31, trainer)
    break if rules.ruleset.isPokemonValid?(pkmn)
  end
  return pkmn
end

def pbTestBattleTower
  pbBattleChallenge.set(
    "towersingle",
    7,
    pbBattleTowerRules(false, false)
  )
  pbBattleChallenge.start(0, 7)
  pbBattleChallengeBattle
end