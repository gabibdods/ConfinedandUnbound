module UI
    # Item boxes for the craft interface
    class CraftItemBox < SpriteStack
        BOX_WIDTH = 38
        BOX_HEIGHT = 40
        BOX_STRIDE_X = 6
        BOX_STRIDE_Y = 2
        BOX_BASE_X = 5
        BOX_BASE_Y = 5

        def initialize(viewport, index)
            super(viewport, *get_coordinates(index))
            @index = index
            @data = {}
            @visible = false
            create_sprite
        end

        def create_sprite
            @box = add_sprite(0, 0, 'craft/items_box', :interface)
            @item_icon = add_sprite(3, 3, NO_INITIAL_IMAGE)
        end

        def get_coordinates(index)
            coords = [
                BOX_BASE_X + (index % 4)*(BOX_WIDTH + BOX_STRIDE_X),
                BOX_BASE_Y + (index / 4)*(BOX_HEIGHT + BOX_STRIDE_Y)
            ]
            return coords
        end

        # data is a hash containing item_sym and recipe keys
        def data=(data)
            @data = data
            update_sprites
        end

        def update_sprites
            @item_icon.set_bitmap(data_item(@data["item_sym"]).icon, :icon)
            if !$craftdex.can_craft(@data["recipe"])
                @item_icon.opacity = 96
            else
                @item_icon.opacity = 255
            end
        end

        def hide
            self.visible = false
            @visible = false
        end

        def show
            self.visible = true
            @visible = true
        end

        def select
            @box.set_bitmap('craft/items_box_selected', :interface)
        end

        def unselect
            @box.set_bitmap('craft/items_box', :interface)
        end

        def index
            return @index
        end

        def visible?
            return @visible
        end
    end

    # Item info box for the craft interface
    class CraftItemInfoBox < SpriteStack
        BOX_BASE_X = 5
        BOX_BASE_Y = 160

        def initialize(viewport)
            super(viewport, BOX_BASE_X, BOX_BASE_Y)
            @data = nil
            create_sprite
            @description = create_descr_text
        end

        def create_sprite
            @bg = add_background('craft/win_info')
        end

        def create_descr_text
            text = add_text(8, 4, 310, 16, nil.to_s, color: 9)
            text.z = 5
            return text
        end

        # data is a symbol representing an item
        def data=(data)
            @data = data
            update_description
        end

        def update_description
            @description.multiline_text = data_item(data).descr
        end
    end

    # The general box containing all the ingredients
    class IngredientsBox < SpriteStack
        BOX_BASE_X = 186
        BOX_BASE_Y = 1

        def initialize(viewport)
            super(viewport, BOX_BASE_X, BOX_BASE_Y)
            @recipe = nil
            @recipe_sprites = []
            create_sprite
            create_texts
            @arrow = create_arrow
            @arrow_index = 0
            @choice_length = 3
        end

        def create_sprite
            @bg = add_background('craft/ingredients_box')
            0.upto(3) do |idx|
                @recipe_sprites << IngredientsInfo.new(@viewport, idx)
            end
        end
        
        def recipe_name=(sym)
            @recipe_name = sym
        end

        def create_texts
            @text_1 = add_text(20, 135, 310, 16, "1".to_pokemon_number, color: 6)
            @text_1.z = 5
            @text_5 = add_text(45, 135, 310, 16, nil.to_s, color: 6)
            @text_5.z = 5
            @text_max = add_text(70, 135, 310, 16, nil.to_s, color: 6)
            @text_max.z = 5
            @text_1.visible = false
            @text_5.visible = false
            @text_max.visible = false
        end

        def create_arrow
            arrow = add_sprite(7, 139, 'craft/arrow', :interface)
            arrow.visible = false
            return arrow
        end

        def show_choice
            @text_1.visible = true
            @text_5.visible = true
            @text_max.visible = true
            @arrow.visible = true
        end

        def hide_choice
            @text_1.visible = false
            @text_5.visible = false
            @text_max.visible = false
            @arrow.visible = false
        end

        def move_arrow(direction)
            return if @choice_length == 1
            if (direction + @arrow_index) < @choice_length and (direction + @arrow_index) >= 0
                @arrow_index += direction
                @arrow.x +=  25*direction
            elsif (direction + @arrow_index) == @choice_length
                @arrow_index = 0
                @arrow.x -= 25*(@choice_length - 1)
            else
                @arrow_index = 2
                @arrow.x += 25*(@choice_length - 1)
            end
        end

        def recipe=(recipe)
            @recipe = recipe
            idx = 0
            @recipe.each do |item_sym, quantity|
                @recipe_sprites[idx].data = {"item_sym" => item_sym, "quantity" => quantity}
                idx += 1
            end
            @recipe.length.upto(3) do |idx|
                @recipe_sprites[idx].data = nil
            end
            max = $craftdex.get_max_craftable_quantity(@recipe, @recipe_name)
            if max == 0
                @text_5.text = nil.to_s
                @text_max.text = nil.to_s
                @choice_length = 1
            else
                max_5 = get_text_5(max)
                @text_5.text = max_5.to_s.to_pokemon_number
                if max_5 == 1
                    @text_max.text = nil.to_s
                    @text_5.text = nil.to_s
                    @choice_length = 1
                elsif max_5 == max
                    @text_max.text = nil.to_s
                    @choice_length = 2
                else
                    @text_max.text = max.to_s.to_pokemon_number
                    @choice_length = 3
                end
            end
        end

        def get_text_5(max)
            if (max / 10) > 1
                return (max / 10)
            elsif  (max / 5) > 1
                return (max / 5)
            elsif  (max / 4) > 1
                return (max / 4)
            elsif  (max / 2) > 1
                return (max / 2)
            else
                return max
            end
        end

        def get_crafted_quantity
            case @arrow_index
            when 0
                return 1
            when 1
                return get_text_5($craftdex.get_max_craftable_quantity(@recipe, @recipe_name))
            when 2
                return $craftdex.get_max_craftable_quantity(@recipe, @recipe_name)
            end
        end
    end

    # Text Infos about one ingredient
    class IngredientsInfo < SpriteStack
        BASE_X = 196
        BASE_Y = 7
        HEIGHT = 32
        Y_STRIDE = 3
        def initialize(viewport, index)
            super(viewport, *get_coordinates(index))
            @index = index
            @data = nil
            @item_icon = create_sprite
            @ingredient_name_text = create_ingredient_name
            @ingredient_quantity_text = create_ingredient_quantity
        end

        def create_sprite
            sp = add_sprite(0, 0, NO_INITIAL_IMAGE)
            return sp
        end

        def create_ingredient_name
            text = add_text(34, 4, 0, 13, nil.to_s, color: 9)
            text.z = 2
            return text
        end

        def create_ingredient_quantity
            text = add_text(34, 18, 0, 13, nil.to_s, color: 9)
            text.z = 2
            return text
        end

        def get_coordinates(index)
            coords = [
                BASE_X,
                BASE_Y + index*(Y_STRIDE + HEIGHT)
            ]
            return coords
        end

        # data is a hash containing item_sym and quantity keys
        def data=(data)
            @data = data
            update_sprites
        end

        def update_sprites
            if @data
                @item_icon.set_bitmap(CraftInfos.get_primary_item_icon(@data["item_sym"]), :interface)
                @item_icon.opacity = 255
                @ingredient_name_text.text = CraftInfos.get_primary_item_name(@data["item_sym"])
                @ingredient_quantity_text.text = "#{$bag.item_quantity(@data["item_sym"]).to_s.to_pokemon_number}#{"/".to_pokemon_number}#{@data["quantity"].to_s.to_pokemon_number}"
            else
                #@item_icon.set_bitmap(NO_INITIAL_IMAGE)
                @item_icon.opacity = 0
                @ingredient_name_text.text = nil.to_s
                @ingredient_quantity_text.text = nil.to_s
            end
        end
    end

end
