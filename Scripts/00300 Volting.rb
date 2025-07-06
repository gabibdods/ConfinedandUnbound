module Battle
  class Move
    class Volting < Basic
      # Function which permit things to happen before the move's animation
      def post_accuracy_check_move(user, actual_targets)
        @physical = user.atk > user.ats
        @special = !@physical

        return true
      end

      # Is the skill physical ?
      # @return [Boolean]
      def physical?
        return @physical
      end

      # Is the skill special ?
      # @return [Boolean]
      def special?
        return @special
      end
    end
    Move.register(:volting, Volting)
  end
end