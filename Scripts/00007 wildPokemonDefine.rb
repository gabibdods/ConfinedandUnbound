module Battle
    class Logic
      # Class describing the informations about the battle
      class BattleInfo
        def add_wild_pokemon(bank, party, ai_level)
          add_party(bank, party, nil, nil, nil, nil, nil, ai_level)
        end
      end
    end
  end