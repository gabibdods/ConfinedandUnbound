module PFM
    module ItemDescriptor
      class SleepSeed < Base
      end
  
      define_chen_prevention(:sleep_seed) { !$game_temp.in_battle }
      define_on_attack_item_use(:sleep_seed) { |item, scene| SleepSeed.new.proceed_internal(scene, item) }
    end
  end