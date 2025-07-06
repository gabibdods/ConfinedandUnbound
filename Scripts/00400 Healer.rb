module Battle
  module Effects
    class Ability
      # At the end of each turn, Healer has a 30% chance of curing an adjacent ally's status condition.
      # @see https://pokemondb.net/ability/healer
      # @see https://bulbapedia.bulbagarden.net/wiki/Healer_(Ability)
      # @see https://www.pokepedia.fr/Cœur_Soin
      class Healer < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          targets = logic.adjacent_allies_of(@target)
          potential_target = targets.select { |target| !target.status_effect.instance_of?(Status) }.sample
          potential_target ||= scene.logic.all_battlers.select { |target| target != @target && target.party_id == @target.party_id && !target.status_effect.instance_of?(Status) }.sample
          return unless potential_target
          return if bchance?(0.70, logic)

          scene.visual.show_ability(@target) 
          logic.status_change_handler.status_change(:cure, potential_target)
        end
      end
      register(:healer, Healer)
    end
  end
end