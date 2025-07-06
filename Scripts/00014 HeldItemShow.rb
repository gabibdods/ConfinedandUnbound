module BattleUI
    class ItemBar < AbilityBar
        private_methods
        
    def create_icon
        add_sprite(*icon_coordinates, NO_INITIAL_IMAGE, false, type: RealHoldSprite)
    end
  end
end