# This is a basic autosave plugin for Pokémon Essentials

# Define your autosave interval in seconds
AUTOSAVE_INTERVAL = 120 # Autosave every 30 seconds

# Define the filename for the save file
SAVE_FILE_NAME = "Game.rxdata"

# Define the plugin module
module AutosavePlugin
  # Start the autosave loop
  def self.start_autosave
    # Create a new thread for the autosave loop
    Thread.new do
      loop do
        # Sleep for the defined autosave interval
        sleep AUTOSAVE_INTERVAL

        # Perform the autosave
        autosave
      end
    end
  end

  # Perform the autosave
  def self.autosave
    # Save the game data to the file
    SaveData.save_to_file(SaveData::FILE_PATH)
  end
end

# Call the method to start the autosave loop
AutosavePlugin.start_autosave
