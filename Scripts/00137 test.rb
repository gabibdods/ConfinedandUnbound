class Scene_Title
  private

  # Create the title animation
  def create_title_animation
    checkup_language
    GamePlay::Save.save_index = Configs.save_config.single_save? ? 0 : 1
    Studio::Text.load unless GamePlay::Save.load
    start_intro_movie(@movie_map_id) if @movie_map_id > 0
    create_title_graphics
    Audio.bgm_play(*Configs.scene_title_config.bgm_name)
  end

  # Function that create the title graphics
  def create_title_graphics
    create_title_background
    create_title_title
    create_title_controls
    # You can hook an animation over there
  end

  def create_title_background
    @background.load('background', :title)
    @background.opacity = 255
  end

  def create_title_title
    @title = Sprite.new(@viewport)
    @title.z = 200
    @title.load('title', :title)
  end

  def call_action_play_game
    scene = Scene_Title.new
    scene.send(:action_play_game)
  end
  
  def create_title_controls
  # @title_controls = UI::TitleControls.new(@viewport)
    # if $scene.should_make_new_game?
    # self.visible = false
        # $scene.create_new_game
    # else
        call_action_play_game
    # end
  end

  def checkup_language
    return if Configs.language.choosable_language_code.empty? || !Configs.scene_title_config.language_selection_enabled

    base_filename = GamePlay::Save.save_filename
    call_scene(GamePlay::Language_Choice) if Dir["#{base_filename}*"].reject { |i| i.end_with?('.bak') }.empty?
  end
end