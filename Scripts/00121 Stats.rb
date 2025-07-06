module UI
  class Summary_Stat < SpriteStack
    
    def data=(pokemon)
      super
      fix_nature_texts(pokemon)
    end

    def reload_nature_name_texts
      texts = text_file_get(27)
      @stat_name_texts[0].text = texts[18]
      @stat_name_texts[1].text = texts[20]
      @stat_name_texts[2].text = texts[22]
      @stat_name_texts[3].text = texts[24]
      @stat_name_texts[4].text = texts[26]
    end

    # @param creature [PFM::Pokemon]
    def fix_nature_texts(creature)
      @nature_text.text = PFM::Text.parse(28, creature.nature_id)
      # Load the stat color according to the nature
      nature = creature.nature.partition.with_index { |_, i| i != 3 }.flatten(1)
      reload_nature_name_texts
      1.upto(5) do |i|
        color = nature[i] < 100 ? 30 : 29
        color = 9 if nature[i] == 100
        @stat_name_texts[i - 1].text += (color == 29 ? '+' : '-') if color != 9
        @stat_name_texts[i - 1].load_color(color)
      end
    end    
    
    # Init the stat texts
    def init_stats
      @stat_name_texts = []
      texts = text_file_get(27)
      with_surface(114, 19, 95) do
        # --- Static part ---
        @nature_text = add_line(0, '', color: 29, dx: 1) # Nature
        add_line(1, texts[15], color: 9) # HP
        @stat_name_texts << add_line(2, texts[18]) # Attack
        @stat_name_texts << add_line(3, texts[20]) # Defense
        @stat_name_texts << add_line(4, texts[26]) # Speed
        @stat_name_texts << add_line(5, texts[22]) # Attack Spe
        @stat_name_texts << add_line(6, texts[24]) # Defense Spe
        # --- Data part ---
        add_line(1, :hp_text, 2, type: SymText, color: 30, dx: 1)
        add_line(2, :atk_basis, 2, type: SymText, color: 30, dx: 1)
        add_line(3, :dfe_basis, 2, type: SymText, color: 30, dx: 1)
        add_line(4, :spd_basis, 2, type: SymText, color: 30, dx: 1)
        add_line(5, :ats_basis, 2, type: SymText, color: 30, dx: 1)
        add_line(6, :dfs_basis, 2, type: SymText, color: 30, dx: 1)
      end
    end
    
    def init_ev_iv
      offset = 102
      # --- EV part ---
      if SHOW_EV
        with_surface(114 + offset, 19, 95) do
          add_line(1, :ev_hp_text, type: SymText, color: 10)
          add_line(2, :ev_atk_text, type: SymText, color: 10)
          add_line(3, :ev_dfe_text, type: SymText, color: 10)
          add_line(4, :ev_spd_text, type: SymText, color: 10)
          add_line(5, :ev_ats_text, type: SymText, color: 10)
          add_line(6, :ev_dfs_text, type: SymText, color: 10)
        end
        offset += 44
      end
      # --- IV part ---
      if SHOW_IV
        with_surface(114 + offset, 19, 95) do
          add_line(1, :iv_hp_text, type: SymText, color: 10)
          add_line(2, :iv_atk_text, type: SymText, color: 10)
          add_line(3, :iv_dfe_text, type: SymText, color: 10)
          add_line(4, :iv_spd_text, type: SymText, color: 10)
          add_line(5, :iv_ats_text, type: SymText, color: 10)
          add_line(6, :iv_dfs_text, type: SymText, color: 10)
        end
      end
    end
  end    
end