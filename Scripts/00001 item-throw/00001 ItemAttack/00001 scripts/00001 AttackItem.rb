module Battle
  module Actions
    # Class describing the usage of an AttackItem
    class AttackItem < Base
      # Get the Pokemon responsive of the item usage
      # @return [PFM::PokemonBattler]
      attr_reader :user
      # Get the item wrapper executing the action
      # @return [PFM::ItemDescriptor::Wrapper]
      attr_reader :item_wrapper

      # Create a new item action
      # @param scene [Battle::Scene]
      # @param item_wrapper [PFM::ItemDescriptor::Wrapper]
      # @param bag [PFM::Bag]
      # @param user [PFM::PokemonBattler] pokemon responsive of the usage of the item (to help sorting alg.)
      def initialize(scene, item_wrapper, bag, user)
        super(scene)
        @item_wrapper = item_wrapper
        @bag = bag
        @user = user
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1 if other.is_a?(HighPriorityItem)
        return 1 if other.is_a?(Attack) && Attack.from(other).pursuit_enabled
        return Item.from(other).user.spd <=> @user.spd if other.is_a?(Item)

        return -1
      end

      # Execute the action
      def execute
        @bag.remove_item(@item_wrapper.item.id, 1) if @item_wrapper.item.is_limited
        
        @bag.last_battle_item_db_symbol = @item_wrapper.item.db_symbol
        @item_wrapper.on_attack_item.call
      end
    end
  end
end
