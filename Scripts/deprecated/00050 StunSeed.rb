module PFM
    module ItemDescriptor
      class StunSeed < Base
      end
  
      define_chen_prevention(:stun_seed) { !$game_temp.in_battle }
      define_on_attack_item_use(:stun_seed) { |item, scene| StunSeed.new.proceed_internal(scene, item) }
    end
  end