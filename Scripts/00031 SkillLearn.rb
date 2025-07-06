module UI
    module MoveTeaching
      # UI part displaying the Skill description in the Skill Learn scene
      class SkillDescription < SpriteStack
        # Init the texts of the skill informations
        def create_texts
          texts = text_file_get(27)
          with_surface(0, 0, 95) do
            add_line(0, texts[3]) # Type
            add_line(1, texts[36]) # Category
            add_line(0, texts[37], dx: 1) # Power
            add_line(1, texts[39], dx: 1) # Accuracy
          end
          @skill_info = SpriteStack.new(@viewport)
          @skill_info.with_surface(114, 16, 95) do
            @skill_info.add_line(0, :power_text, 2, type: SymText, color: 1, dx: 1)
            @skill_info.add_line(1, :accuracy_text, 2, type: SymText, color: 1, dx: 1)
            @skill_info.add_line(2, :description, type: SymMultilineText, color: 32).width = 195
          end
          @skill_info.push(114 + 61, 16 + 1, nil, type: TypeSprite)
          @skill_info.push(114 + 61, 16 + 17, nil, type: CategorySprite)
        end
  
      end
    end
  end