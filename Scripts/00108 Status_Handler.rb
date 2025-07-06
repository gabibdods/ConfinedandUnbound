module Battle
  class Logic
    # Handler responsive of answering properly status changes requests
    class StatusChangeHandler < ChangeHandlerBase
      APPLY_MESSAGE_LINE = 2 # Line with "[VAR PKNICK(0000)] got frostbite!" in 100019.csv

      # List of message ID when applying a status
      STATUS_APPLY_MESSAGE[:freeze] = APPLY_MESSAGE_LINE - 2

      # Function that actually change the status
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure, :confuse_cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param message_overwrite [Integer] Index of the message to use of file 19 to apply the status (if there's specific reason)
      def status_change(status, target, launcher = nil, skill = nil, message_overwrite: nil)
        log_data("# status_change(#{status}, #{target}, #{launcher}, #{skill})")
        case status
        when :cure
          @was_frozen = target.frozen?
          message_overwrite ||= cure_message_id(target)
          target.send(STATUS_APPLY_METHODS[status])
        when :confuse_cure
          target.effects.get(:confusion)&.kill
          target.effects.delete_specific_dead_effect(:confusion)
          message_overwrite = 351
        else
          message_overwrite ||= STATUS_APPLY_MESSAGE[status]
          target.send(STATUS_APPLY_METHODS[status], true)
          @scene.visual.show_rmxp_animation(target, STATUS_APPLY_ANIMATION[status])
        end
        @scene.display_message_and_wait(parse_text_with_pokemon(@was_frozen || status == :freeze ? 400000 : 19, message_overwrite, target)) if message_overwrite
        exec_hooks(StatusChangeHandler, :post_status_change, binding)
      rescue Hooks::ForceReturn => e
        log_data("# FR: status_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      ensure
        @scene.visual.refresh_info_bar(target)
      end

      # Get the message ID for the curing message
      # @param target [PFM::PokemonBattler]
      # @return [Integer]
      alias default_cure_messages cure_message_id 
      def cure_message_id(target)
        return APPLY_MESSAGE_LINE + 4 if target.frozen?
        return default_cure_messages(target)
      end

      # Cannot be frozen
      StatusChangeHandler.register_status_prevention_hook('PSDK status prev: can_be_frozen') do |handler, status, target, _, skill|
        next if status != :freeze || target.can_be_frozen?(skill&.type || 0)

        next handler.prevent_change do
          handler.scene.display_message_and_wait(parse_text_with_pokemon(400000, APPLY_MESSAGE_LINE + 10, target)) if skill.nil? || skill.status?
        end
      end
    end
  end
end