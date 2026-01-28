# frozen_string_literal: true

module ResurgenceEngine
  # Factory for creating game objects
  #
  # Provides centralized object creation with registration system.
  class Factory
    # @return [Hash<Symbol, Proc>] Registered object creators
    class << self
      attr_reader :creators
    end

    @creators = {}

    # Register an object type with a creator block
    # @param type [Symbol] Object type identifier
    # @param creator [Proc] Creator block
    def self.register(type, &creator)
      @creators[type] = creator
    end

    # Create an object of the specified type
    # @param type [Symbol] Object type identifier
    # @param args [Hash] Arguments to pass to creator
    # @return [Object] Created object
    # @raise [Error] If type is not registered
    def self.create(type, **args)
      creator = @creators[type]
      unless creator
        raise Error, "Unknown object type: #{type}"
      end

      creator.call(**args)
    end

    # Check if type is registered
    # @param type [Symbol] Object type to check
    # @return [Boolean]
    def self.registered?(type)
      @creators.key?(type)
    end

    # Get all registered types
    # @return [Array<Symbol>]
    def self.types
      @creators.keys
    end

    # Clear all registrations
    def self.clear
      @creators.clear
    end

    # Register object types on load
    def self.register_types
      # Object types are registered by their respective modules
    end
  end
end