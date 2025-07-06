module PFM
  module ItemDescriptor
    class IronSpike < Base
    end

    define_chen_prevention(:iron_spike) { !$game_temp.in_battle }
    define_on_attack_item_use(:iron_spike) { |item, scene| IronSpike.new.proceed_internal(scene, item) }
  end
end