module Util
  # Item Helper
  module Item
    # Use an item in a GamePlay::Base child class
    # @param item_id [Integer] ID of the item in the database
    # @return [PFM::ItemDescriptor::Wrapper, false] item descriptor wrapper if the item could be used
    def util_item_useitem(item_id, &result_process)
      extend_data = PFM::ItemDescriptor.actions(item_id)

      if extend_data.chen
        display_message(parse_text(22, 43))
        return false
      elsif extend_data.no_effect
        display_message(parse_text(22, 108))
        return false
      elsif $actors.empty? && extend_data.open_party
        display_message(parse_text(22, 119))
        return false
      elsif extend_data.open_party
        return util_item_open_party_sequence(extend_data, result_process)
      elsif extend_data.attack_item
        return util_attack_item_on_use_sequence(extend_data, result_process)
      end

      return util_item_on_use_sequence(extend_data, result_process)
    end

    # Part where the extend_data request to use the item
    # @param extend_data [PFM::ItemDescriptor::Wrapper]
    # @param result_process [Proc, nil]
    # @return [PFM::ItemDescriptor::Wrapper, false]
    def util_attack_item_on_use_sequence(extend_data, result_process)
      if extend_data.use_before_telling
        if extend_data.on_use(self) != :unused
          #$bag.remove_item(extend_data.item.id, 1) if extend_data.item.is_limited
          display_message(message) if $scene == self
          if $game_temp.common_event_id > 0
            return_to_scene(Scene_Map)
          else
            result_process&.call
          end
          return extend_data
        end

        return false
      end

      #$bag.remove_item(extend_data.item.id, 1) if extend_data.item.is_limited
      extend_data.on_use(self)
      result_process&.call

      return extend_data
    end
  end
end
