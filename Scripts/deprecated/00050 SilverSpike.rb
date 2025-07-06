module PFM
  module ItemDescriptor
    class SilverSpike < Base
    end

    define_chen_prevention(:silver_spike) { !$game_temp.in_battle }
    define_on_attack_item_use(:silver_spike) { |item, scene| SilverSpike.new.proceed_internal(scene, item) }
  end
end