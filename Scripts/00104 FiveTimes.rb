module Battle
    class Move
      # Class describing a move hiting multiple time
      class FiveTimes < Basic
        # Number of hit randomly picked from that array
        MULTI_HIT_CHANCES = [6]
        # Function that deals the damage to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_damage(user, actual_targets)
          @user = user
          @actual_targets = actual_targets
          @nb_hit = 0
          @hit_amount = hit_amount(user, actual_targets)
          @hit_amount.times.count do |i|
            next false unless actual_targets.all?(&:alive?)
            next false if user.dead?
  
            @nb_hit += 1

            actual_targets.each do |target|
              hp = damages(user, target)
              @logic.damage_handler.damage_change_with_process(hp, target, user, self) do
                if critical_hit?
                  scene.display_message_and_wait(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
                elsif hp > 0 && i == @hit_amount - 1
                  efficent_message(effectiveness, target)
                end
              end
              recoil(hp, user) if recoil?
            end
            next true
          end
          @scene.display_message_and_wait(parse_text(18, 33, PFM::Text::NUMB[1] => @nb_hit.to_s))
          return false if user.dead?
  
          return true
        end
  
        # Check if this the last hit of the move
        # Don't call this method before deal_damage method call
        # @return [Boolean]
        def last_hit?
          return true if @user.dead?
          return true unless @actual_targets.all?(&:alive?)
  
          return @hit_amount == @nb_hit
        end
  
        # Tells if the move hits multiple times
        # @return [Boolean]
        def multi_hit?
          return true
        end
  
        private
        
      def hit_amount(user, actual_targets)

        return MULTI_HIT_CHANCES.sample(random: @logic.generic_rng)
      end
  
      # This method applies for triple kick and triple axel: power ramps up but the move stops if the subsequent attack misses.
      class SandilePile < FiveTimes
        # Get the real base power of the move (taking in account all parameter)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @return [Integer]
        private
  
        # Function that deals the damage to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_damage(user, actual_targets)
          @user = user
          @actual_targets = actual_targets
          @nb_hit = 0
          @hit_amount = hit_amount(user, actual_targets)
          @hit_amount.times.count do |i|
            break false unless actual_targets.all?(&:alive?)
            break false if user.dead?
  
            break false if i > 0 && !user.has_ability?(:skill_link) && (actual_targets = recalc_targets(user, actual_targets)).empty?
  
            play_animation(user, actual_targets) if i > 0
            actual_targets.each do |target|
              hp = damages(user, target)
              @logic.damage_handler.damage_change_with_process(hp, target, user, self) do
                if critical_hit?
                  scene.display_message_and_wait(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
                elsif hp > 0 && i == @hit_amount - 1
                  efficent_message(effectiveness, target)
                end
              end
              recoil(hp, user) if recoil?
            end
            @nb_hit += 1
            next true
          end
          @scene.display_message_and_wait(parse_text(18, 33, PFM::Text::NUMB[1] => @nb_hit.to_s))
          return false if user.dead?
  
          return true
        end
  
        # Recalculate the target each time it's needed
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] the current targets we need the accuracy recalculation on
        # @return [Array] the targets hit after accuracy recalculation
        def recalc_targets(user, targets)
  
          return [] unless proceed_move_accuracy(user, targets).any? || (on_move_failure(user, targets, :accuracy) && false)
  
          user, targets = proceed_battlers_remap(user, targets)
  
          actual_targets = accuracy_immunity_test(user, targets) # => Will call $scene.dislay_message for each accuracy fail
          return [] if actual_targets.none? && (on_move_failure(user, targets, :immunity) || true)
  
          return actual_targets
          # rubocop:enable Lint/LiteralAsCondition
        end
      end
  
      Move.register(:s_five_times, FiveTimes)
      Move.register(:s_sandile_pile, SandilePile)
    end
  end
end