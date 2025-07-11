# Auto Multi Save by http404error
# For Pokemon Essentials v21.1

# Description:
#   Adds multiple save slots and the abliity to auto-save.
#   Included is code to autosave every 100 overworld steps. Feel free to edit or delete it (it's right at the top).
#   On the Load screen you can use the left and right buttons while "Continue" is selected to cycle through files.
#   When saving, you can quickly save to the same slot you loaded from, or pick another slot.
#   Battle Challenges are NOT supported.

# Customization:
#   I recommend altering your pause menu to quit to the title screen or load screen instead of exiting entirely.
#     -> For instance, just change the menu text to "Quit to Title" and change `$scene = nil` to `$scene = pbCallTitle`.
#     -> You may need to also add a `SaveData.mark_values_as_unloaded` right before setting $scene.
#     -> If you change `screen.pbSaveScreen` to `screen.pbSaveScreen(true)` here, it will also change the UI behavior slightly for clarity.
#   Call Game.auto_save whenever you want.
#     -> Autosaving during an event script will correctly resume event execution when you load the game.
#     -> I haven't investigated if it might be possible to autosave on closing the window with the X or Alt-F4 yet.
#   You can rename the slots to your liking, or change how many there are.
#   In some cases, you might want to remove the option to save to a different slot than the one you loaded from.

# Notes:
#   On the first Load, the old Game.rxdata will be copied to the first slot in MANUAL_SLOTS. It won't have a known save time though.
#   The interface to `Game.save` has been changed.
#   Due to the slots, alters the save backup system in the case of save corruption/crashes - backups will be named Backup000.rxdata and so on.
#   Heavily modifies the SaveData module and Save and Load screens. This may cause incompatibility with some other plugins or custom game code.
#   Not everything here has been tested extensively, only what applies to normal usage of my game. Please let me know if you run into any problems.

# Future development ideas:
#   There isn't currently support for unlimited slots but it wouldn't be too hard.
#   Letting the user name their slots seems cool.
#   It would be nice if there was a sliding animation for switching files on that load screen. :)
#   It would be nice if the file select arrows used nicer animated graphics, kind of like the Bag.
#   Maybe auto-save slots should act like a queue instead of cycling around. 

# Autosave every 100 steps
EventHandlers.add(:on_player_step_taken, :auto_save, proc {
  $player.autosave_steps = 0 if !$player.autosave_steps
  next if $PokemonGlobal.ice_sliding
  $player.autosave_steps += 1
  if $player.autosave_steps >= 100
    echo("Autosaving...")
    $player.autosave_steps = 0
    Game.auto_save
    echoln("done.")
  end
})

#===============================================================================
#
#===============================================================================
module SaveData
  # You can rename these slots or change the amount of them
  # They change the actual save file names though, so it would take some extra work to use the translation system on them.
  AUTO_SLOTS = [
    'Auto 1',
    'Auto 2',
    'Auto 3'
  ]
  MANUAL_SLOTS = [
    'File A',
    'File B',
    'File C',
    'File D',
    'File E',
    'File F',
    'File G',
    'File H'
  ]

  # For compatibility with games saved without this plugin
  OLD_SAVE_SLOT = 'Game'

  SAVE_DIR = if File.directory?(System.data_directory)
               System.data_directory
             else
              '.'
             end

  def self.each_slot
    (AUTO_SLOTS + MANUAL_SLOTS).each { |f| yield f }
  end

  def self.get_full_path(file)
    return "#{SAVE_DIR}/#{file}.rxdata"
  end

  def self.get_backup_file_path
    backup_file = "Backup000"
    while File.file?(self.get_full_path(backup_file))
      backup_file.next!
    end
    return self.get_full_path(backup_file)
  end

  # Given a list of save file names and a file name in it, return the next file after it which exists
  # If no other file exists, will just return the same file again
  def self.get_next_slot(file_list, file)
    old_index = file_list.find_index(file)
    ordered_list = file_list.rotate(old_index + 1)
    ordered_list.each do |f|
      return f if File.file?(self.get_full_path(f))
    end
    # should never reach here since the original file should always exist
    return file
  end
  # See self.get_next_slot
  def self.get_prev_slot(file_list, file)
    return self.get_next_slot(file_list.reverse, file)
  end

  # Returns nil if there are no saves
  # Returns the first save if there's a tie for newest
  # Old saves from previous version don't store their saved time, so are treated as very old
  def self.get_newest_save_slot
    newest_time = Time.at(0) # the Epoch
    newest_slot = nil
    self.each_slot do |file_slot|
      full_path = self.get_full_path(file_slot)
      next if !File.file?(full_path)
      temp_save_data = self.read_from_file(full_path)
      save_time = temp_save_data[:player].last_time_saved || Time.at(1)
      if save_time > newest_time
        newest_time = save_time
        newest_slot = file_slot
      end
    end
    # Port old save
    if newest_slot.nil? && File.file?(self.get_full_path(OLD_SAVE_SLOT))
      file_copy(self.get_full_path(OLD_SAVE_SLOT), self.get_full_path(MANUAL_SLOTS[0]))
      return MANUAL_SLOTS[0]
    end
    return newest_slot
  end

  # @return [Boolean] whether any save file exists
  def self.exists?
    self.each_slot do |slot|
      full_path = SaveData.get_full_path(slot)
      return true if File.file?(full_path)
    end
    return false
  end

  # This is used in a hidden function (ctrl+down+cancel on title screen) or if the save file is corrupt
  # Pass nil to delete everything, or a file path to just delete that one
  # @raise [Error::ENOENT]
  def self.delete_file(file_path=nil)
    if file_path
      File.delete(file_path) if File.file?(file_path)
    else
      self.each_slot do |slot|
        full_path = self.get_full_path(slot)
        File.delete(full_path) if File.file?(full_path)
      end
    end
  end

  # Runs all possible conversions on the given save data.
  # Saves a backup before running conversions.
  # @param save_data [Hash] save data to run conversions on
  # @return [Boolean] whether conversions were run
  def self.run_conversions(save_data)
    validate save_data => Hash
    conversions_to_run = self.get_conversions(save_data)
    return false if conversions_to_run.none?
    File.open(SaveData.get_backup_file_path, 'wb') { |f| Marshal.dump(save_data, f) }
    Console.echo_h1 "Backed up save to #{SaveData.get_backup_file_path}"
    Console.echo_h1 "Running #{conversions_to_run.length} conversions..."
    conversions_to_run.each do |conversion|
      Console.echo_li "#{conversion.title}..."
      conversion.run(save_data)
      Console.echo_done ' done.'
    end
    echoln '' if conversions_to_run.length > 0
    Console.echo_h2("All save file conversions applied successfully", text: :green)
    save_data[:essentials_version] = Essentials::VERSION
    save_data[:game_version] = Settings::GAME_VERSION
    return true
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
  def pbChoose(commands, continue_idx)
    @sprites["cmdwindow"].commands = commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
      elsif @sprites["cmdwindow"].index == continue_idx
        if Input.trigger?(Input::LEFT)
          return -3
        elsif Input.trigger?(Input::RIGHT)
          return -2
        end
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    @selected_file = SaveData.get_newest_save_slot
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + ".bak")
        pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
        save_data = load_save_file(file_path + ".bak")
      else
        self.prompt_save_deletion(file_path)
        return {}
      end
    end
    return save_data
  end

  # Called if save file is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion(file_path)
    pbMessage(_INTL("A save file is corrupt, or is incompatible with this game.") + "\1")
    self.delete_save_data(file_path) if pbConfirmMessageSerious(
      _INTL("Do you want to delete that save file? The game will exit afterwards either way.")
    )
    exit
  end

  # nil deletes all, otherwise just the given file
  def delete_save_data(file_path=nil)
    begin
      SaveData.delete_file(file_path)
      pbMessage(_INTL("The save data was deleted."))
    rescue SystemCallError
      pbMessage(_INTL("The save data could not be deleted."))
    end
  end

  def pbStartLoadScreen
    save_file_list = SaveData::AUTO_SLOTS + SaveData::MANUAL_SLOTS
    first_time = true
    loop do # Outer loop is used for switching save files
      if @selected_file
        @save_data = load_save_file(SaveData.get_full_path(@selected_file))
      else
        @save_data = {}
      end
      commands = []
      cmd_continue     = -1
      cmd_new_game     = -1
      cmd_options      = -1
      cmd_language     = -1
      cmd_mystery_gift = -1
      cmd_debug        = -1
      cmd_quit         = -1
      show_continue = !@save_data.empty?
      if show_continue
        commands[cmd_continue = commands.length] = " <- #{@selected_file} -> "
        if @save_data[:player].mystery_gift_unlocked
          commands[cmd_mystery_gift = commands.length] = _INTL('Mystery Gift') # Honestly I have no idea how to make Mystery Gift work well with this.
        end
      end
      commands[cmd_new_game = commands.length]  = _INTL('New Game')
      commands[cmd_options = commands.length]   = _INTL('Options')
      commands[cmd_language = commands.length]  = _INTL('Language') if Settings::LANGUAGES.length >= 2
      commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG
      commands[cmd_quit = commands.length]      = _INTL('Quit Game')
      cmd_left = -3
      cmd_right = -2

      map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
      @scene.pbStartScene(commands, show_continue, @save_data[:player], @save_data[:stats], map_id)
      @scene.pbSetParty(@save_data[:player]) if show_continue
      if first_time
        @scene.pbStartScene2
        first_time = false
      else
        @scene.pbUpdate
      end

      loop do # Inner loop is used for going to other menus and back and stuff (vanilla)
        command = @scene.pbChoose(commands, cmd_continue)
        pbPlayDecisionSE if command != cmd_quit

        case command
        when cmd_continue
          @scene.pbEndScene
          Game.load(@save_data)
          return
        when cmd_new_game
          @scene.pbEndScene
          Game.start_new
          return
        when cmd_mystery_gift
          pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
        when cmd_options
          pbFadeOutIn do
            scene = PokemonOption_Scene.new
            screen = PokemonOptionScreen.new(scene)
            screen.pbStartScreen(true)
          end
        when cmd_language
          @scene.pbEndScene
          $PokemonSystem.language = pbChooseLanguage
          MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
          if show_continue
            @save_data[:pokemon_system] = $PokemonSystem
            File.open(SaveData.get_full_path(@selected_file), "wb") { |file| Marshal.dump(@save_data, file) }
          end
          $scene = pbCallTitle
          return
        when cmd_debug
          pbFadeOutIn { pbDebugMenu(false) }
        when cmd_quit
          pbPlayCloseMenuSE
          @scene.pbEndScene
          $scene = nil
          return
        when cmd_left
          @scene.pbCloseScene
          @selected_file = SaveData.get_prev_slot(save_file_list, @selected_file)
          break # to outer loop
        when cmd_right
          @scene.pbCloseScene
          @selected_file = SaveData.get_next_slot(save_file_list, @selected_file)
          break # to outer loop
        else
          pbPlayBuzzerSE
        end
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSave_Scene
  def pbUpdateSlotInfo(slottext)
    pbDisposeSprite(@sprites, "slotinfo")
    @sprites["slotinfo"] = Window_AdvancedTextPokemon.new(slottext)
    @sprites["slotinfo"].viewport = @viewport
    @sprites["slotinfo"].x = 0
    @sprites["slotinfo"].y = 160
    @sprites["slotinfo"].width = 228 if @sprites["slotinfo"].width < 228
    @sprites["slotinfo"].visible = true
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSaveScreen
  def doSave(slot)
    if Game.save(slot)
      pbMessage("\\se[]" + _INTL("{1} saved the game.", $player.name) + "\\me[GUI save game]\\wtnp[20]")
      return true
    else
      pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
      return false
    end
  end

  # Return true if pause menu should close after this is done (if the game was saved successfully)
  def pbSaveScreen(exiting=false)
    ret = false
    @scene.pbStartScreen
    if !$player.save_slot
      # New Game - must select slot
      ret = slotSelect(exiting)
    else
      choices = [
        _INTL("Save to #{$player.save_slot}"),
        _INTL("Save to another file"),
        exiting ? _INTL("Quit without saving") : _INTL("Cancel")
      ]
      opt = pbMessage(_INTL("Would you like to save the game?"),choices,3)
      if opt == 0
        pbSEPlay("GUI save choice")
        ret = doSave($player.save_slot)
      elsif opt == 1
        pbPlayDecisionSE
        ret = slotSelect(exiting)
      else
        pbPlayCancelSE
      end
    end
    @scene.pbEndScreen
    return ret
  end

  # Call this to open the slot select screen
  # Returns true if the game was saved, otherwise false
  def slotSelect(exiting=false)
    ret = false
    choices = SaveData::MANUAL_SLOTS
    choice_info = SaveData::MANUAL_SLOTS.map { |s| getSaveInfoBoxContents(s) }
    loop do
      index = slotSelectCommands(choices, choice_info)
      if index >= 0
        slot = SaveData::MANUAL_SLOTS[index]
        # Confirm if slot not empty
        if !File.file?(SaveData.get_full_path(slot)) ||
            pbConfirmMessageSerious(_INTL("Are you sure you want to overwrite the save in #{slot}?")) # If the slot names were changed this grammar might need adjustment.
          pbSEPlay('GUI save choice')
          ret = doSave(slot)
        end
      elsif exiting # Pressed cancel
        next unless pbConfirmMessageSerious(_INTL("Are you sure you want to quit without saving?"))
      end
      break
    end
    pbPlayCloseMenuSE if !ret
    return ret
  end

  # Handles the UI for the save slot select screen. Returns the index of the chosen slot, or -1.
  # Based on pbShowCommands
  def slotSelectCommands(choices, choice_info, defaultCmd=0)
    msgwindow = Window_AdvancedTextPokemon.new(_INTL("Which slot to save in?"))
    msgwindow.z = 99999
    msgwindow.visible = true
    msgwindow.letterbyletter = true
    msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
    pbBottomLeftLines(msgwindow, 2)
    $game_temp.message_window_showing = true if $game_temp
    msgwindow.setSkin(MessageConfig.pbGetSpeechFrame)

    cmdwindow = Window_CommandPokemonEx.new(choices)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow,msgwindow,:right)
    cmdwindow.index = defaultCmd
    command = 0
    loop do
      @scene.pbUpdateSlotInfo(choice_info[cmdwindow.index])
      Graphics.update
      Input.update
      cmdwindow.update
      msgwindow.update if msgwindow
      if Input.trigger?(Input::BACK)
        command = -1
        break
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    msgwindow.dispose
    $game_temp.message_window_showing = false if $game_temp
    Input.update
    return ret
  end

  # Show the player some data about their currently selected save slot for quick identification
  # This doesn't use player gender for coloring, unlike the default save window
  def getSaveInfoBoxContents(slot)
    full_path = SaveData.get_full_path(slot)
    if !File.file?(full_path)
      return _INTL("<ac><c3=3050C8,D0D0C8>(empty)</c3></ac>")
    end
    temp_save_data = SaveData.read_from_file(full_path)

    # Last save time
    time = temp_save_data[:player].last_time_saved
    if time
      date_str = time.strftime("%x")
      time_str = time.strftime(_INTL("%I:%M%p"))
      datetime_str = "#{date_str}<r>#{time_str}<br>"
    else
      datetime_str = _INTL("<ac>(old save)</ac>")
    end

    # Map name
    map_str = pbGetMapNameFromId(temp_save_data[:map_factory].map.map_id)

    # Elapsed time
    totalsec = (temp_save_data[:frame_count] || 0) / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    if hour > 0
      elapsed_str = _INTL("Time<r>{1}h {2}m<br>", hour, min)
    else
      elapsed_str = _INTL("Time<r>{1}m<br>", min)
    end

    return "<c3=3050C8,D0D0C8>#{datetime_str}</c3>"+ # blue
           "<ac><c3=209808,90F090>#{map_str}</c3></ac>"+ # green
           "#{elapsed_str}"
  end
end

#===============================================================================
#
#===============================================================================
module Game
  # Loads bootup data from save file (if it exists) or creates bootup data (if
  # it doesn't).
  def self.set_up_system
    save_slot = SaveData.get_newest_save_slot
    if save_slot
      save_data = SaveData.read_from_file(SaveData.get_full_path(save_slot))
    else
      save_data = {}
    end
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if !Settings::LANGUAGES.empty?
      $PokemonSystem.language = pbChooseLanguage if save_data.empty? && Settings::LANGUAGES.length >= 2
      MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
    end
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(slot=nil, auto=false, safe: false)
    slot = $player.save_slot if slot.nil?
    return false if slot.nil?
    
    file_path = SaveData.get_full_path(slot)
    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    $stats.set_time_last_saved
    $player.save_slot = slot unless auto
    $player.last_time_saved = Time.now
    begin
      SaveData.save_to_file(file_path)
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end

  # Overwrites the first empty autosave slot, otherwise the oldest existing autosave
  def self.auto_save
    oldest_time = nil
    oldest_slot = nil
    SaveData::AUTO_SLOTS.each do |slot|
      full_path = SaveData.get_full_path(slot)
      if !File.file?(full_path)
        oldest_slot = slot
        break
      end
      temp_save_data = SaveData.read_from_file(full_path)
      save_time = temp_save_data[:player].last_time_saved || Time.at(1)
      if oldest_time.nil? || save_time < oldest_time
        oldest_time = save_time
        oldest_slot = slot
      end
    end
    self.save(oldest_slot, true)
  end
end

#===============================================================================
#
#===============================================================================

# Lol who needs the FileUtils gem?
# This is the implementation from the original pbEmergencySave.
def file_copy(src, dst)
  File.open(src, "rb") do |r|
    File.open(dst, "wb") do |w|
      loop do
        s = r.read(4096)
        break if !s
        w.write(s)
      end
    end
  end
end

# When I needed extra data fields in the save file I put them in Player because it seemed easier than figuring out
# how to make a save file conversion, and I prefer to maintain backwards compatibility.
class Player
  attr_accessor :last_time_saved
  attr_accessor :save_slot
  attr_accessor :autosave_steps
end

def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("The script is taking too long. The game will restart."))
  return if !$player
  return if !$player.save_slot
  current_file = SaveData.get_full_path($player.save_slot)
  backup_file = SaveData.get_backup_file_path
  file_copy(current_file, backup_file)
  if Game.save
    pbMessage("\\se[]" + _INTL("The game was saved.") + "\\me[GUI save game]\\wtnp[20]")
    pbMessage("\\se[]" + _INTL("The previous save file has been backed up.") + "\\wtnp[20]")
  else
    pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
  end
  $scene = oldscene
end
