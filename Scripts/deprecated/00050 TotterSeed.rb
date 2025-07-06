module PFM
    module ItemDescriptor
      class TotterSeed < Base
      end
  
      define_chen_prevention(:totter_seed) { !$game_temp.in_battle }
      define_on_attack_item_use(:totter_seed) { |item, scene| TotterSeed.new.proceed_internal(scene, item) }
    end
  end