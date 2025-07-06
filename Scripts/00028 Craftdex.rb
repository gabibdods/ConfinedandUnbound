module PFM

    class Craftdex
        # Get the game state responsive of the whole game state
        # @return [PFM::GameState]
        attr_accessor :game_state

        # Get all the primary items the player have got
        # @return [Array[Integer]]
        attr_accessor :primary_items

        # Get all the unlocked ingredients
        # @return [Array[sym]]
        attr_accessor :unlocked_ingredients
        
        # Create a new Craftdex object
        # @param game_state [PFM::GameState] game state storing this instance
        def initialize(game_state = PFM.game_state)
            @game_state = game_state
            @primary_items = initialize_primary_items
            @unlocked_ingredients = []
        end

        def initialize_primary_items
            primary_items = {}
            CraftInfos::PRIMARY_M_LIST.each do |sym|
                primary_items[sym] = 0
            end
            return primary_items
        end

        def unlock(sym)
            @unlocked_ingredients << sym
        end

        def get_max_craftable_quantity(recipe, recipe_name = nil)
            maximum = 99
            log_info(recipe_name)
            recipe.each do |ingredient, quantity|
                new_candidate = $bag.item_quantity(ingredient) / quantity
                if new_candidate < maximum
                    maximum = new_candidate
                end
            end
            return maximum == 0 ? 0 : 1 if recipe_name == :graveler_statue
            return maximum
        end

        # Returns Boolean : If the recipe can be crafted
        def can_craft(recipe, nb=1)
            recipe.each do |ingredient, quantity|
                return false if $bag.item_quantity(ingredient) < nb*quantity
            end
            return true
        end

        def craft(sym, nb)
            recipe = CraftInfos.get_recipe(sym)
            recipe.each do |ingredient, quantity|
                $bag.remove_item(ingredient, quantity*nb)
            end
            $bag.add_item(sym, nb)
            $craftdex.unlocked_ingredients.delete(:graveler_statue) if sym == :graveler_statue
        end

        def add_primary_item(sym, quantity)
            @primary_items[sym] += quantity 
        end
    end
    
    class GameState
        # The Craftdex of the player
        # @return [PFM::Craftdex]
        attr_accessor :craftdex

        on_player_initialize(:craftdex) { @craftdex = PFM::Craftdex.new(self) }
        on_expand_global_variables(:craftdex) do
            # Variable containing the Pokedex Information
            $craftdex = @craftdex
            @craftdex.game_state = self
        end
    end
end