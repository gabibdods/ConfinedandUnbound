module PFM
  module ItemDescriptor
    module_function

    # Define a usage of an attack item from the bag
    # @param klass [Class<Studio::Item>, Symbol] class or db_symbol of the item
    # @param use_before_telling [Boolean] if the item should be used before showing the message
    # @yieldparam item [Studio::Item] item used
    # @yieldparam scene [GamePlay::Base]
    # @yieldreturn [:unused] if block returns :unused, the item is considered as not used and not consumed
    def define_on_attack_item_use(klass, use_before_telling = false, &block)
      raise 'Block is mandatory' unless block_given?

      EXTEND_DATAS[klass] = wrapper = Wrapper.new
      wrapper.on_use = block
      wrapper.use_before_telling = use_before_telling
      EXTEND_DATAS[klass].attack_item = true
    end

    # Wrapper to make the item description more usefull
    class Wrapper
      # Tell if the item is an attack item
      # @return [Boolean, nil]
      attr_accessor :attack_item
      # Register the on_attack_item proc
      # @return [Proc, nil]
      attr_accessor :on_attack_item
    end
  end
end
