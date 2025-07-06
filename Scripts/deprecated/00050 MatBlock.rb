module PFM
    module ItemDescriptor
      class MatBlock < Base
      end
  
      define_chen_prevention(:mat_block) { !$game_temp.in_battle }
      define_on_attack_item_use(:mat_block) { |item, scene| MatBlock.new.proceed_internal(scene, item) }
    end
  end