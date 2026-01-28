# frozen_string_literal: true

module ResurgenceEngine
  # Structure class - large objects on the map
  #
  # Structures include walls, machines, furniture, etc.
  class Structure < MapObject
    # @return [Boolean] Whether structure is intact
    attr_accessor :intact

    # @return [Integer] Structure health
    attr_accessor :structure_health

    # @return [Integer] Max structure health
    attr_accessor :max_structure_health

    # @return [Boolean] Whether deconstructed
    attr_accessor :deconstructed

    # @return [Boolean] Whether opaque (blocks light)
    attr_accessor :opaque

    # @return [Boolean] Whether flammable
    attr_accessor :flammable

    # @return [Boolean] Whether open (for doors, etc.)
    attr_accessor :open

    # Initialize a new structure
    def initialize(
      intact: true,
      structure_health: 100,
      max_structure_health: 100,
      deconstructed: false,
      opaque: true,
      flammable: false,
      open: false,
      **kwargs
    )
      super(**kwargs)
      @intact = intact
      @structure_health = structure_health
      @max_structure_health = max_structure_health
      @deconstructed = deconstructed
      @opaque = opaque
      @flammable = flammable
      @open = open

      add_tag(:structure)
      @inanimate = true
    end

    # Check if structure blocks movement
    # @return [Boolean]
    def blocks_movement?
      @intact && !@open && !@deconstructed
    end

    # Check if structure blocks LOS
    # @return [Boolean]
    def blocks_los?
      @opaque && @intact && !@open
    end

    # Damage the structure
    # @param amount [Integer] Damage amount
    def damage(amount)
      return if @deconstructed

      @structure_health -= amount
      if @structure_health <= 0
        on_destroyed
      else
        on_damaged(amount)
      end
    end

    # Called when structure is damaged
    # @param amount [Integer] Damage amount
    def on_damaged(amount); end

    # Called when structure is destroyed
    def on_destroyed
      @intact = false
      @deconstructed = true
      @structure_health = 0
      add_tag(:destroyed)
    end

    # Repair the structure
    # @param amount [Integer] Repair amount
    def repair(amount)
      return if @deconstructed

      @structure_health = [@structure_health + amount, @max_structure_health].min
      @intact = true if @structure_health > 0
    end

    # Check if structure is damaged
    # @return [Boolean]
    def damaged?
      @structure_health < @max_structure_health
    end

    # Toggle open/close state
    # @return [Boolean] New state
    def toggle_open
      @open = !@open
      on_open_changed(@open)
    end

    # Called when open state changes
    # @param is_open [Boolean] New state
    def on_open_changed(is_open); end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        intact: @intact,
        structure_health: @structure_health,
        max_structure_health: @max_structure_health,
        deconstructed: @deconstructed,
        opaque: @opaque,
        flammable: @flammable,
        open: @open
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Structure]
    def self.deserialize(data)
      new(
        intact: data.fetch('intact', true),
        structure_health: data.fetch('structure_health', 100),
        max_structure_health: data.fetch('max_structure_health', 100),
        deconstructed: data.fetch('deconstructed', false),
        opaque: data.fetch('opaque', true),
        flammable: data.fetch('flammable', false),
        open: data.fetch('open', false),
        **data.slice('name', 'description', 'position').to_h
      )
    end
  end
end
