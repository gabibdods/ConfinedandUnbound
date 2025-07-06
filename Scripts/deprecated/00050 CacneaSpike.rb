module PFM
  module ItemDescriptor
    class CacneaSpike < Base
    end

    define_chen_prevention(:cacnea_spike) { !$game_temp.in_battle }
    define_on_attack_item_use(:cacnea_spike) { |item, scene| CacneaSpike.new.proceed_internal(scene, item) }
  end
end