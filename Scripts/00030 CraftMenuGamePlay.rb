module GamePlay
    class CraftMenu < BaseCleanUpdate::FrameBalanced
        include UI

        ACTIONS = [:in_press_a, nil, nil, :in_press_b]
        def initialize()
            super()
            @index = 0
            @real_index = 0
            @max_index = $craftdex.unlocked_ingredients.size() - 1
        end

        def create_graphics
            create_viewport
            create_base_ui
            create_item_boxes
            create_ingredients
        end

        #Called when input can be updated (put your input related code inside)
        # @return [Boolean] if the update can continue
        def update_inputs
            if Input.repeat?(:UP)
                update_in_index_change if @current_stage == 0 and set_index_by_delta(-4)
            elsif Input.repeat?(:DOWN)
                update_in_index_change if @current_stage == 0 and set_index_by_delta(4)
            elsif Input.repeat?(:LEFT)
                update_in_index_change if @current_stage == 0 and set_index_by_delta(-1)
                @ingredients_box.move_arrow(-1) if @current_stage == 1
            elsif Input.repeat?(:RIGHT)
                update_in_index_change if @current_stage == 0 and set_index_by_delta(1)
                @ingredients_box.move_arrow(1) if @current_stage == 1
            elsif Input.trigger?(:A)
                in_press_a
            elsif Input.trigger?(:B)
                in_press_b
            end
            return true
        end
  
        # Called when mouse can be updated (put your mouse related code inside)
        # @param moved [Boolean] boolean telling if the mouse moved
        # @return [Boolean] if the update can continue
        def update_mouse(moved)
            update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS)
            if Mouse.released?(:LEFT)
                @item_boxes.each do |box|
                    if box.visible? and box.simple_mouse_in? and @current_stage == 0
                        in_press_a
                    end
                end
            end
            return true unless moved
            @item_boxes.each do |box|
                if box.visible? and box.simple_mouse_in? and @current_stage == 0
                    update_in_index_change if set_index_by_delta(box.index - @index)
                end
            end
        end
  
        # Called each frame after message update and eventual mouse/input update
        # @return [Boolean] if the update can continue
        def update_graphics
            @base_ui.update_background_animation
            return true
        end

        private

        # Create the base UI
        def create_base_ui
            @base_ui = GenericBase.new(@viewport, button_texts)
            go_to_stage_0
        end

        # Retrieve the button texts
        # @return [Array<String>]
        def button_texts
            return Array.new(4, ext_text(9000, 22 + 3))
        end

        # Create the boxes containing recipes
        def create_item_boxes
            @item_boxes = []
            0.upto(15) do |idx|
                @item_boxes << CraftItemBox.new(@viewport, idx)
            end
            @item_boxes[0].select
            update_item_boxes
            @item_info_box = CraftItemInfoBox.new(@viewport)
            update_item_info_box
        end

        # Create the ingredient box
        def create_ingredients
            @ingredients_box = IngredientsBox.new(@viewport)
            update_ingredients_box
        end

        # Assign the given item to the box represented by idx
        def assign_item_to_box(sym, idx)
            current_data = {"item_sym" => sym, "recipe" => CraftInfos::RECIPES[sym]}
            @item_boxes[idx].data = current_data
            @item_boxes[idx].show
        end

        # Update the items shown by the boxes
        def update_item_boxes
            offset = 0
            @index.downto(0) do |idx|
                current_item_sym = $craftdex.unlocked_ingredients[@real_index - offset]
                assign_item_to_box(current_item_sym, idx)
                offset += 1
            end

            max = (@max_index - @real_index + @index) >= 15 ? 15 : (@max_index - @real_index + @index)
            offset = 1
            (@index + 1).upto(max) do |idx|
                current_item_sym = $craftdex.unlocked_ingredients[@real_index + offset]
                assign_item_to_box(current_item_sym, idx)
                offset += 1
            end

            (max + 1).upto(15) do |idx|
                @item_boxes[idx].hide
            end
        end

        # Retrieves the current item symbol
        def get_selected_item
            return $craftdex.unlocked_ingredients[@real_index]
        end

        # Updates the item info box
        def update_item_info_box
            @item_info_box.data = get_selected_item
        end

        # Updates the ingredients box
        def update_ingredients_box
            @ingredients_box.recipe_name = get_selected_item
            @ingredients_box.recipe = CraftInfos::RECIPES[get_selected_item]
        end

        # Changes the real index by delta if possible
        # @return [Boolean] If the index has changed
        def set_index_by_delta(delta)
            return false if delta == 0
            next_real_index = @real_index + delta
            return false if next_real_index < 0 or next_real_index > @max_index
            play_decision_se
            next_index = @index + delta
            next_index = @index - 3 if (delta == 1) and (next_index > 15)
            next_index = @index + 3 if (delta == -1) and (next_index < 0)
            if (next_index >= 0) and (next_index <= 15)
                @item_boxes[next_index].select
                @item_boxes[@index].unselect
                @index = next_index
            end
            @real_index += delta
        end

        # Make the necessary changes when the selected index changes
        def update_in_index_change
            update_item_boxes
            update_item_info_box
            update_ingredients_box
        end

        def go_to_stage_0
            @base_ui.button_texts = ["Select", nil, nil, "Quit"]
            @current_stage = 0
            @ingredients_box.hide_choice if @ingredients_box
        end

        def go_to_stage_1
            item = get_selected_item
            quantity = @ingredients_box.get_crafted_quantity
            Audio.se_play("audio/se/pmdSystemConfirm")
            display_message(" How many of that #{data_item(item).exact_name} ?")
            @base_ui.button_texts = ["Craft", nil, nil, "Quit"]
            @current_stage = 1
            @ingredients_box.show_choice
        end

        def in_press_a
            case @current_stage
            when 0
                if $craftdex.can_craft(CraftInfos.get_recipe(get_selected_item))
                    go_to_stage_1
                else
                    play_buzzer_se
                end
            when 1
                item = get_selected_item
                quantity = @ingredients_box.get_crafted_quantity
                Audio.se_play("audio/me/pmdItemGet")
                $craftdex.craft(item, quantity)
                display_message(" You obtained #{quantity} #{data_item(item).exact_name} !")
            
                if ! $craftdex.can_craft(CraftInfos.get_recipe(item))
                    go_to_stage_0
                end
                if item == :graveler_statue
                    if @index == @max_index
                        @index -= 1
                        @real_index -= 1
                        @item_boxes[@index].select
                    end
                    @max_index -= 1
                    go_to_stage_0
                end
                update_in_index_change
            end
        end

        def in_press_b
            case @current_stage
            when 0
                @running = false
            when 1
                go_to_stage_0
            end
        end
    end
end