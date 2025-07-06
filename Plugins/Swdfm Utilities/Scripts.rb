#=============================================================================
# Swdfm Utilites - Scripts
# Last Updated: 2023-12-04
#=============================================================================
module Swd
  # Writes all RPG Maker Xp Scripts in one big .txt file
  def self.write_all_scripts
    scripts = []
    File.open("Data/Scripts_1.rxdata") do |file|
      scripts = Marshal.load(file)
    end
    path = "Outputs/"
    Dir.mkdir(path) rescue nil
    File.open("#{path}scripts_full.txt", "wb") { |f|
      for script in scripts
        f.write("#{self.bigline}\n")
        str = "#{script[1]}\n"
        f.write("# Script Page: " + str)
        f.write("#{self.bigline}\n")
        scr = Zlib::Inflate.inflate(script[2]).force_encoding(Encoding::UTF_8)
        f.write("#{scr.gsub("\t", "    ")}\n")
        # script[2] = Zlib::Deflate.deflate(code) #,   Zlib::FINISH)
      end
    }
  end
  
  # Writes All Plugins in one big .txt file
  def self.write_all_plugins
    path = "Outputs/"
    Dir.mkdir(path) rescue nil
    File.open("#{path}plugins_full.txt", "wb") { |f|
      plugin_scripts = load_data("Data/PluginScripts.rxdata")
      plugin_scripts.each do |plugin|
        plugin[2].each do |script|
          f.write("#{self.bigline}\n")
          str = "#{plugin[0]}/#{script[0]}\n"
          f.write("# Plugin Page: " + str)
          f.write("#{self.bigline}\n")
          scr = Zlib::Inflate.inflate(script[1]).force_encoding(Encoding::UTF_8)
          f.write("#{scr.gsub("\t", "    ")}\n")
        end
      end
    }
  end
  
  def self.pbsline
    return "#-------------------------------"
  end
  
  def self.bigline
    return "#==============================================================================="
  end
end