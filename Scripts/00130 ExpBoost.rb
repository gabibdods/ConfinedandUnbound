module Battle
    class Logic
      # Class responsive of calculating experience & EV of Pokemon when a Pokemon faints
      class ExpHandler
        alias psdk_exp_multipliers exp_multipliers
        def exp_multipliers(receiver)
          multipliers = psdk_exp_multipliers(receiver)
          multipliers *= ($game_switches[500] ? 3 : 1)
        end
      end
    end
  end