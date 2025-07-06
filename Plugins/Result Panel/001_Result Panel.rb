class ResultPanelScene
  def update
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"]
       @sprites["bg"].ox -= 1
       @sprites["bg"].oy -= 1
    end
  end

  def pbStartScene(panel_name, title, panel_type, round)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "Result Panel/bg", @viewport)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(Settings::FILEPATH + "Panel_" + panel_type.to_s + "_#{Settings::PANELSTYLE}")
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height)/2

    @sprites["bg"].zoom_x = 2 ; @sprites["bg"].zoom_y = 2
    @sprites["bg"].ox += 6
    @sprites["bg"].oy -= 26
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)

    trainers = Settings::RESULTPANEL8_SINGLE[:"#{panel_name}"][:Trainers] if panel_type == 8
    trainers = Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Trainers] if panel_type == 16

    player_position = 0

    for i in 0...trainers.size
      player_position = i + 1 if (trainers[i]).to_s == "Player"
      trainers[i] = $game_variables[trainers[i]].to_s if trainers[i].is_a?(Integer)
    end

    icons = Settings::RESULTPANEL8_SINGLE[:"#{panel_name}"][:Icons] if panel_type == 8
    icons = Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Icons] if panel_type == 16

    classified = [Settings::RESULTPANEL8_SINGLE[:"#{panel_name}"][:Round2],
                  Settings::RESULTPANEL8_SINGLE[:"#{panel_name}"][:Round3],
                  Settings::RESULTPANEL8_SINGLE[:"#{panel_name}"][:Round4]
    ] if panel_type == 8
    classified = [Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Round2],
                  Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Round3],
                  Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Round4],
                  Settings::RESULTPANEL16_SINGLE[:"#{panel_name}"][:Round5]
    ] if panel_type == 16

    if panel_type == 8
      for i in 1...15
        @sprites["bar" + i.to_s] = IconSprite.new(48, 22, @viewport) if [1,3,5,7].include?(i)
        @sprites["bar" + i.to_s] = IconSprite.new(48, 20, @viewport) if [2,4,6,8].include?(i)
        @sprites["bar" + i.to_s] = IconSprite.new(26, 42, @viewport) if [9,10,11,12].include?(i)
        @sprites["bar" + i.to_s] = IconSprite.new(50, 16, @viewport) if [13,14].include?(i)
         
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-8_1") if [1,3].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-8_2") if [2,4].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-8_3") if [5,7].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-8_4") if [6,8].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-8_" + (i - 4).to_s) if i >= 9

        @sprites["bar" + i.to_s].x = 144 if [1,2,3,4].include?(i)
        @sprites["bar" + i.to_s].x = 320 if [5,6,7,8].include?(i)
        @sprites["bar" + i.to_s].x = 182 if [9,10].include?(i)
        @sprites["bar" + i.to_s].x = 304 if [11,12].include?(i)
        @sprites["bar" + i.to_s].x = 198 if i == 13
        @sprites["bar" + i.to_s].x = 264 if i == 14

        @sprites["bar" + i.to_s].y = 138 if [1,5].include?(i)
        @sprites["bar" + i.to_s].y = 176 if [2,6].include?(i)
        @sprites["bar" + i.to_s].y = 222 if [3,7].include?(i)
        @sprites["bar" + i.to_s].y = 260 if [4,8].include?(i)
        @sprites["bar" + i.to_s].y = 160 if [9,11].include?(i)
        @sprites["bar" + i.to_s].y = 218 if [10,12].include?(i)
        @sprites["bar" + i.to_s].y = 202 if [13,14].include?(i)
      end
      @sprites["bar15"] = IconSprite.new(16, 16, @viewport)
      @sprites["bar15"].setBitmap(Settings::FILEPATH + "Bars/Central_icon")
      @sprites["bar15"].x = 248
      @sprites["bar15"].y = 202
    else
      for i in 1...31
        @sprites["bar" + i.to_s] = IconSprite.new(48, 20, @viewport) if i <= 16
        @sprites["bar" + i.to_s] = IconSprite.new(26, 40, @viewport) if i >= 17 && i <= 24
        @sprites["bar" + i.to_s] = IconSprite.new(26, 80, @viewport) if [25,26,27,28].include?(i)
        @sprites["bar" + i.to_s] = IconSprite.new(34, 16, @viewport) if [29,30].include?(i)

        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_1") if [1,3,5,7].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_2") if [2,4,6,8].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_3") if [9,11,13,15].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_4") if [10,12,14,16].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_5") if [17,19].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_6") if [18,20].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_7") if [21,23].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_8") if [22,24].include?(i)
        @sprites["bar" + i.to_s].setBitmap(Settings::FILEPATH + "Bars/Bar-16_" + (i - 16).to_s) if i >= 25

        @sprites["bar" + i.to_s].x = 144 if i <= 8
        @sprites["bar" + i.to_s].x = 320 if i >= 9 && i <= 16
        @sprites["bar" + i.to_s].x = 182 if [17,18,19,20].include?(i)
        @sprites["bar" + i.to_s].x = 304 if [21,22,23,24].include?(i)
        @sprites["bar" + i.to_s].x = 198 if [25,26].include?(i)
        @sprites["bar" + i.to_s].x = 288 if [27,28].include?(i)
        @sprites["bar" + i.to_s].x = 214 if i == 29
        @sprites["bar" + i.to_s].x = 264 if i == 30

        @sprites["bar" + i.to_s].y = 58 if [1,9].include?(i)
        @sprites["bar" + i.to_s].y = 94 if [2,10].include?(i)
        @sprites["bar" + i.to_s].y = 138 if [3,11].include?(i)
        @sprites["bar" + i.to_s].y = 174 if [4,12].include?(i)
        @sprites["bar" + i.to_s].y = 218 if [5,13].include?(i)
        @sprites["bar" + i.to_s].y = 254 if [6,14].include?(i)
        @sprites["bar" + i.to_s].y = 298 if [7,15].include?(i)
        @sprites["bar" + i.to_s].y = 334 if [8,16].include?(i)

        @sprites["bar" + i.to_s].y = 78 if [17,21].include?(i)
        @sprites["bar" + i.to_s].y = 134 if [18,22].include?(i)
        @sprites["bar" + i.to_s].y = 238 if [19,23].include?(i)
        @sprites["bar" + i.to_s].y = 294 if [20,24].include?(i)
        @sprites["bar" + i.to_s].y = 118 if [25,27].include?(i)
        @sprites["bar" + i.to_s].y = 214 if [26,28].include?(i)
        @sprites["bar" + i.to_s].y = 198 if [29,30].include?(i)
      end
      @sprites["bar31"] = IconSprite.new(16, 16, @viewport)
      @sprites["bar31"].setBitmap(Settings::FILEPATH + "Bars/Central_icon")
      @sprites["bar31"].x = 248
      @sprites["bar31"].y = 198
    end

    player = true
    if round > 1
      for i in 0...round
        player = false
        for j in 0...classified[i - 1].size
          player = true if classified[i -1][j] == player_position
          if i + 1 == 2
            s = 9 if panel_type == 8
            s = 17 if panel_type == 16
            for k in 1...s
              @sprites["bar" + k.to_s].visible = false if classified[i-1][j] == k
            end
          elsif i + 1 == 3
            if panel_type == 8
              @sprites["bar9"].visible = false if [1,2].include?(classified[i-1][j])
              @sprites["bar10"].visible = false if [3,4].include?(classified[i-1][j])
              @sprites["bar11"].visible = false if [5,6].include?(classified[i-1][j])
              @sprites["bar12"].visible = false if [7,8].include?(classified[i-1][j])
            else
              @sprites["bar17"].visible = false if [1,2].include?(classified[i-1][j])
              @sprites["bar18"].visible = false if [3,4].include?(classified[i-1][j])
              @sprites["bar19"].visible = false if [5,6].include?(classified[i-1][j])
              @sprites["bar20"].visible = false if [7,8].include?(classified[i-1][j])
              @sprites["bar21"].visible = false if [9,10].include?(classified[i-1][j])
              @sprites["bar22"].visible = false if [12,11].include?(classified[i-1][j])
              @sprites["bar23"].visible = false if [13,14].include?(classified[i-1][j])
              @sprites["bar24"].visible = false if [15,16].include?(classified[i-1][j])
            end
          elsif i + 1 == 4
            if panel_type == 8
              @sprites["bar13"].visible = false if [1,2,3,4].include?(classified[i-1][j])
              @sprites["bar14"].visible = false if [5,6,7,8].include?(classified[i-1][j])
              @sprites["bar15"].visible = false
            else
              @sprites["bar25"].visible = false if [1,2,3,4].include?(classified[i-1][j])
              @sprites["bar26"].visible = false if [5,6,7,8].include?(classified[i-1][j])
              @sprites["bar27"].visible = false if [9,10,11,12].include?(classified[i-1][j])
              @sprites["bar28"].visible = false if [13,14,15,16].include?(classified[i-1][j])
            end
          elsif i + 1 == 5
              @sprites["bar29"].visible = false if classified[i-1][j] <= 8
              @sprites["bar30"].visible = false if classified[i-1][j] >= 9
              @sprites["bar31"].visible = false
          end
        end
      end
    end

    if panel_type == 8
      x = 138 if player_position <= 4 && round == 1 
      x = 346 if player_position >= 5 && round == 1
      y = 132 if [1,5].include?(player_position) && round == 1
      y = 174 if [2,6].include?(player_position) && round == 1
      y = 216 if [3,7].include?(player_position) && round == 1
      y = 258 if [4,8].include?(player_position) && round == 1
      x = 176 if player_position <= 4 && round == 2
      x = 308 if player_position >= 5 && round == 2
      y = 156 if [1,2,5,6].include?(player_position) && round == 2
      y = 238 if [3,4,7,8].include?(player_position) && round == 2
      x = 192 if player_position <= 4 && round == 3
      x = 292 if player_position >= 5 && round == 3
      y = 196 if round == 3 || round == 4
      x = 242 if round == 4
    else
      x = 138 if player_position < 9 && round == 1 
      x = 346 if player_position > 8 && round == 1
      y = 52 if [1,6].include?(player_position) && round == 1
      y = 92 if [2,10].include?(player_position) && round == 1
      y = 132 if [3,11].include?(player_position) && round == 1
      y = 172 if [4,12].include?(player_position) && round == 1
      y = 212 if [5,13].include?(player_position) && round == 1
      y = 252 if [6,14].include?(player_position) && round == 1
      y = 292 if [7,15].include?(player_position) && round == 1
      y = 332 if [8,16].include?(player_position) && round == 1
      x = 176 if player_position <= 8 && round == 2
      x = 308 if player_position >= 9 && round == 2
      y = 74 if [1,2,9,10].include?(player_position) && round == 2
      y = 152 if [3,4,11,12].include?(player_position) && round == 2
      y = 234 if [5,6,13,14].include?(player_position) && round == 2
      y = 312 if [7,8,15,16].include?(player_position) && round == 2
      x = 192 if player_position <= 8 && round == 3
      x = 292 if player_position >= 9 && round == 3
      y = 114 if [1,2,3,4,9,10,11,12].include?(player_position) && round == 3
      y = 272 if [5,6,7,8,13,14,15,16].include?(player_position) && round == 3
      x = 208 if player_position <= 8 && round == 4
      x = 276 if player_position >= 9 && round == 4
      y = 192 if round == 4 || round == 5
      x = 242 if round == 5
    end

    @sprites["cursor"] = IconSprite.new(28, 28, @viewport) if player
    @sprites["cursor"].setBitmap(Settings::FILEPATH + "Cursor") if player
    @sprites["cursor"].x = x if player
    @sprites["cursor"].y = y if player

    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawResultPanel(title, panel_type, round, trainers, icons, classified, player_position)
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawResultPanel(title, panel_type, round, trainers, icons, classified, player_position)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base_color = Color.new(248, 248, 248)
    shadow_color = Color.new(72, 80, 88)
    height = 101 if panel_type == 8
    height = 21 if panel_type == 16
    text_positions = [
       [title,Graphics.width/2,height,2,base_color,shadow_color]
    ]

    if [1,3].include?(Settings::PANELSTYLE)
      for i in 0...trainers.size
        if Settings::PANELSTYLE == 1
          if panel_type == 8
            (x = 134; y = 134; z = 1) if i == 0
            (x = 378; y = 134; z = 0) if i == 4
          else
            (x = 134; y = 56; z = 1) if i == 0
            (x = 378; y = 56; z = 0) if i == 8
          end
        else
          if panel_type == 8
            (x = 100; y = 134; z = 1) if i == 0
            (x = 412; y = 134; z = 0) if i == 4
          else
            (x = 100; y = 56; z = 1) if i == 0
            (x = 412; y = 56; z = 0) if i == 8
          end
        end
        if round > 1
          aux = 0
          for j in 0...classified[round - 2].size()
            aux = classified[round - 2][j] if classified[round - 2][j] == i+1
          end
          text_positions.push([trainers[i],x,y,z,Color.new(128, 128, 128),Color.new(72, 72, 72)]) if aux == 0
          text_positions.push([trainers[i],x,y,z,base_color,shadow_color]) if aux != 0 && i != player_position - 1
          text_positions.push([trainers[i],x,y,z,Color.new(248, 160, 96),Color.new(128, 80, 48)]) if aux != 0 && i == player_position - 1
        else
          text_positions.push([trainers[i],x,y,z,base_color,shadow_color]) if i != player_position - 1
          text_positions.push([trainers[i],x,y,z,Color.new(248, 160, 96),Color.new(128, 80, 48)]) if i == player_position - 1
        end
        y += 42 if panel_type == 8
        y += 40 if panel_type == 16
      end
      text_positions[player_position][0] = $player.name
    end

    pbDrawTextPositions(overlay, text_positions)

    imagepos=[]

    if [2,3].include?(Settings::PANELSTYLE)
      image_path = Settings::FILEPATH + Settings::TEMPLATENAME
      for i in 0...panel_type
        if panel_type == 8
          (x = 102; y = 128) if i == 0
          (x = 378; y = 128) if i == 4
        else
          (x = 102; y = 50) if i == 0
          (x = 378; y = 50) if i == 8
        end 
        row = 0
        for l in 0...Settings::TEMPLATEROWS
          column = 0
          for c in 1...9
            if round > 1
              aux = 0
              for j in 0...classified[round - 2].size()
                aux = classified[round - 2][j] if classified[round - 2][j] == i+1
              end
              if c + 8 * l == icons[i] && aux != 0
                imagepos.push([image_path, x, y, column, row, 32, 32])
                imagepos.push([image_path, 240, 196 - 50, column, row, 32, 32]) if panel_type == 8 && round == 4
                imagepos.push([image_path, 240, 192 - 50, column, row, 32, 32]) if panel_type == 16 && round == 5
              elsif c + 8 * l == icons[i] && aux == 0
                imagepos.push([image_path + "_OUT", x, y, column, row, 32, 32])
              end 
            else
              imagepos.push([image_path, x, y, column, row, 32, 32]) if c + 8 * l == icons[i]
            end
            column += 32
          end
          row += 32
        end
        y += 42 if panel_type == 8
        y += 40 if panel_type == 16
      end

      pbDrawImagePositions(overlay, imagepos)
    end
  end

  def pbMain
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        pbPlayCancelSE
        break
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class ResultPanelScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(panel_name, title, panel_type, round)
    @scene.pbStartScene(panel_name, title, panel_type, round)
    @scene.pbMain
    @scene.pbEndScene
  end
end

def pbResultPanel(panel_name=nil, title=nil, panel_type=nil, round=1)
  if (panel_type == 8 || panel_type == 16) && panel_name
    title = _INTL("CONTEST") if !title
    round = 1 if round <= 0 || round > 5
    pbFadeOutIn(99999) {
      scene = ResultPanelScene.new
      screen = ResultPanelScreen.new(scene)
      screen.pbStartScreen(panel_name, title, panel_type, round)
    }
  end
end