module CraftInfos
    PRIMARY_M_LIST = %i[plain_seed spare_cloth dull_berry persim_berry rawst_berry pecha_berry chesto_berry cheri_berry pomeg_berry kelpsy_berry qualot_berry hondew_berry grepa_berry tamato_berry oran_berry gravelerock]

        # NAME
        PRIMARY_M_DATA = {
            :plain_seed => ["Plain Seed"],
            :spare_cloth => ["Spare Cloth"],
            :dull_berry => ["Dull Berry"],
            :oran_berry => ["Oran Berry"],
            :persim_berry => ["Persim Berry"],
            :rawst_berry => ["Rawst Berry"],
            :pecha_berry => ["Pecha Berry"],
            :chesto_berry => ["Chesto Berry"],
            :cheri_berry => ["Cheri Berry"],
            :pomeg_berry => ["Pomeg Berry"],
            :kelpsy_berry => ["Kelpsy Berry"],
            :qualot_berry => ["Qualot Berry"],
            :hondew_berry => ["Hondew Berry"],
            :grepa_berry => ["Grepa Berry"],
            :tamato_berry => ["Tamato Berry"],
            :gravelerock => ["Gravelerock"],
        }

        # NAME PATTERN(ARRAY[9])
        RECIPES = {
            :totter_seed => {:plain_seed => 1, :persim_berry => 1 },
            :sleep_seed => {:plain_seed => 1, :chesto_berry => 1 },
            :noxious_seed => {:plain_seed => 1, :pecha_berry => 1 },
            :stun_seed => {:plain_seed => 1, :cheri_berry => 1},
            :quick_seed => {:plain_seed => 1, :tamato_berry => 2 },
            :sharp_seed => {:plain_seed => 1, :kelpsy_berry => 2 },
            :iron_seed => {:plain_seed => 1, :qualot_berry => 2 },
            :amplify_seed => {:plain_seed => 1, :hondew_berry => 2 },
            :fortify_seed => {:plain_seed => 1, :grepa_berry => 2 },
            :oran_berry => {:dull_berry => 2},
            :sitrus_berry => {:dull_berry => 4},
            :persim_band => {:spare_cloth => 2, :persim_berry => 1 },
            :pecha_scarf => {:spare_cloth => 2, :pecha_berry => 1 },
            :defense_scarf => {:spare_cloth => 3 , :qualot_berry => 1},
            :zinc_band => {:spare_cloth => 3 , :grepa_berry => 1},
            :graveler_statue => {:gravelerock => 3 }
        }
    

    module_function

    def get_primary_item_name(sym)
        return PRIMARY_M_DATA[sym][0]
    end

    def get_primary_item_icon(sym)
        return "craft/ingredients/#{get_primary_item_name(sym)}"
    end

    def get_recipe(sym)
        return RECIPES[sym]
    end
end