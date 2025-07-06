module PFM
  module ItemDescriptor
    class Gravelerock < Base
    end

    define_chen_prevention(:gravelerock) { !$game_temp.in_battle }
    define_on_attack_item_use(:gravelerock) { |item, scene| Gravelerock.new.proceed_internal(scene, item) }
  end
end