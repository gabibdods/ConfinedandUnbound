module Battle
    module Effects
      class Item
        class ReviverSeed < Item
          # Function called when a damage_prevention is checked
          # @param handler [Battle::Logic::DamageHandler]
          # @param hp [Integer] number of hp (damage) dealt
          # @param target [PFM::PokemonBattler]
          # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
          # @param skill [Battle::Move, nil] Potential move used
          # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
          def on_damage_prevention(handler, hp, target, launcher, skill)
            return unless skill && target == @target
            return if hp < target.hp

            @show_message = true
            return target.hp - 1 if hp >= target.hp
          end
        end

        def on_post_damage(handler, hp, target, launcher, skill)
            return unless @show_message
            @show_message = false

            handler.scene.visual.show_item(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 19, target))
            Audio.se_play("Audio/SE/pmdBeam", 100)
            @logic.damage_handler.heal(target, hp_healed)
            @logic.status_change_handler.status_change(:confuse_cure, target, launcher, skill) if target.confused?
            @logic.status_change_handler.status_change(:cure, target, launcher, skill) if target.status?
            handler.logic.item_change_handler.change_item(:none, true, target)
        end

        def hp_healed
            return (@target.max_hp).clamp(1, Float::INFINITY)
        end

        class Revital < ReviverSeed
          # Give the stat it should improve
          # @return [Symbol]

          def on_post_damage(handler, hp, target, launcher, skill)
            return unless @show_message
            @show_message = false
            handler.scene.visual.show_item(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(70, 22, target))
            Audio.se_play("Audio/SE/pmdBeam", 100)
            @logic.damage_handler.heal(target, hp_healed)
            @logic.status_change_handler.status_change(:confuse_cure, target, launcher, skill) if target.confused?
            @logic.status_change_handler.status_change(:cure, target, launcher, skill) if target.status?
            handler.logic.item_change_handler.change_item(:none, true, target)
          end

          def hp_healed
            return (@target.max_hp * 2 / 4).clamp(1, Float::INFINITY)
          end
        end

        register(:reviver_seed, ReviverSeed)
        register(:revital_seed, ReviverSeed::Revital)
      end
    end
  end
  