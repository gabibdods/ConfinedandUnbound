module PFM
    module ItemDescriptor
      class Earthquake < Base
      end
  
      define_chen_prevention(:earthquake) { !$game_temp.in_battle }
      define_on_attack_item_use(:earthquake) { |item, scene| Earthquake.new.proceed_internal(scene, item) }
    end
  end