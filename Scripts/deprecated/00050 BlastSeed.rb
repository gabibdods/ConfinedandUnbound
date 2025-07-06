module PFM
    module ItemDescriptor
      class BlastSeed < Base
      end
  
      define_chen_prevention(:blast_seed) { !$game_temp.in_battle }
      define_on_attack_item_use(:blast_seed) { |item, scene| BlastSeed.new.proceed_internal(scene, item) }
    end
  end