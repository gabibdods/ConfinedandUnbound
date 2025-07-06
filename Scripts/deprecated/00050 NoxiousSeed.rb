module PFM
    module ItemDescriptor
      class NoxiousSeed < Base
      end
  
      define_chen_prevention(:noxious_seed) { !$game_temp.in_battle }
      define_on_attack_item_use(:noxious_seed) { |item, scene| NoxiousSeed.new.proceed_internal(scene, item) }
    end
  end