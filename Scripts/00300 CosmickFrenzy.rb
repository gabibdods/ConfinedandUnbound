module Battle
  class Move
    # Cosmic Frenzy move
    class CosmickFrenzy < Move
      STATUS_MOVES = %i[
        dragon_dance quiver_dance white_void
      ]

      SPECIAL_MOVES = %i[
        flamethrower flare_blitz
      ]

      PHYSICAL_MOVES = %i[
        earthquake close_combat
      ]

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        skill1 = data_move(STATUS_MOVES.sample)
        skill2 = data_move(SPECIAL_MOVES.sample)
        skill3 = data_move(PHYSICAL_MOVES.sample)
        move1 = Battle::Move[skill1.be_method].new(skill1.id, 5, 5, @scene)
        move2 = Battle::Move[skill2.be_method].new(skill2.id, 5, 5, @scene)
        move3 = Battle::Move[skill3.be_method].new(skill3.id, 5, 5, @scene)
        def move1.usage_message(user)
          nil
        end
        def move2.usage_message(user)
          nil
        end
        def move3.usage_message(user)
          nil
        end
        str = ""
        str += parse_text(6969, 7, '[VAR MOVE(0000)]' => move1.name)
        str += " #{parse_text(6969, 8, '[VAR MOVE(0000)]' => move2.name)}"
        str += " #{parse_text(6969, 9, '[VAR MOVE(0000)]' => move3.name)}"
        scene.display_message_and_wait(parse_text_with_pokemon(6969, 6, user))
        scene.display_message_and_wait(str)
        
        [move1, move2, move3].each_with_index do |move, index|
          if actual_targets.any? { |target| target.alive? }
            def move.move_usable_by_user(user, targets)
              return true
            end
            use_another_move(move, user)
          end
        end
      end
    end
    Move.register(:s_cosmick_frenzy, CosmickFrenzy)
  end
end