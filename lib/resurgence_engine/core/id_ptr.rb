# frozen_string_literal: true

module ResurgenceEngine
  # Unique identifier for game objects
  #
  # Provides type-safe ID management with generation tracking.
  class IdPtr
    # @return [Integer] The unique ID
    attr_reader :id

    # @return [Class] The class this ID points to
    attr_reader :type

    # @return [Boolean] Whether this ID is valid
    attr_reader :valid

    # Counter for generating unique IDs
    @@next_id = 0
    @@id_lock = Mutex.new

    # Create a new IdPtr with auto-generated ID
    # @param type [Class] The type this ID represents
    # @return [IdPtr]
    def self.generate(type)
      @@id_lock.synchronize do
        @@next_id += 1
        new(id: @@next_id, type: type, valid: true)
      end
    end

    # Reset ID counter (for testing)
    # @param start [Integer] Starting ID value
    def self.reset!(start = 0)
      @@id_lock.synchronize do
        @@next_id = start
      end
    end

    # Create an invalid IdPtr
    # @return [IdPtr]
    def self.invalid
      new(id: 0, type: nil, valid: false)
    end

    # Initialize an IdPtr
    # @param id [Integer] Unique identifier
    # @param type [Class] Referenced type
    # @param valid [Boolean] Validity flag
    def initialize(id:, type:, valid: true)
      @id = id
      @type = type
      @valid = valid
    end

    # Check if this is a valid pointer
    # @return [Boolean]
    def valid?
      @valid && @id > 0
    end

    # Get the next ID without creating an instance
    # @return [Integer]
    def self.next_id
      @@id_lock.synchronize { @@next_id + 1 }
    end

    # Equality comparison
    # @param other [Object] Object to compare
    # @return [Boolean]
    def ==(other)
      other.is_a?(IdPtr) && @id == other.id && @type == other.type
    end

    alias eql? ==

    # Hash for use in collections
    # @return [Integer]
    def hash
      [@id, @type].hash
    end

    # String representation
    # @return [String]
    def inspect
      return "IdPtr(invalid)" unless @valid

      "IdPtr(#{@type&.name || 'Unknown'}_#{@id})"
    end

    alias to_s inspect
  end
end