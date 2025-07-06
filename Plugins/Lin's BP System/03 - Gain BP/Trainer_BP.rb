#===============================================================================
# * Trainer BP
#===============================================================================

class Battle
  #===============================================================================
  # End of Battle
  #===============================================================================
  def pbGainBP
    return if !@internalBattle || !@moneyGain
    # BP rewarded from opposing trainers
    if trainerBattle?
      tBP = 0
      @opponent.each_with_index do |t, i|
        tBP += pbMaxLevelInTeam(1, i) * t.base_bp
      end
      tBP *= BPConfig::BP_MULTIPLY if pbActiveCharm(:POINTSCHARM)
      oldBP = pbPlayer.battle_points
      pbPlayer.battle_points += tBP
      bpGained = pbPlayer.battle_points - oldBP
      if bpGained > 0
        $stats.battle_points_won += bpGained
        pbDisplayPaused(_INTL("You got {1} BP for winning!", bpGained.to_s_formatted))
      end
    end
  end

  alias battlePoints_pbGainMoney pbGainMoney
  def pbGainMoney
    battlePoints_pbGainMoney
    # Money rewarded from opposing trainers
    if trainerBattle?
	  pbGainBP if BPConfig::TRAINER_BP
    end
  end
end