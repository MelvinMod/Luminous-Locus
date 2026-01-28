# frozen_string_literal: true

module ResurgenceEngine
  # Turf class - the ground tiles of the game world
  #
  # Turfs form the base layer of each map z-level.
  class Turf < Tile
    # @return [Boolean] Whether excavated
    attr_accessor :excavated

    # @return [Boolean] Whether sealed (can't be dug)
    attr_accessor :sealed

    # @return [Integer] Turf health
    attr_accessor :turf_health

    # @return [String] Turf category
    attr_accessor :category

    # Initialize a new turf
    def initialize(
      excavated: false,
      sealed: false,
      turf_health: 100,
      category: 'floor',
      **kwargs
    )
      super(**kwargs)
      @excavated = excavated
      @sealed = sealed
      @turf_health = turf_health
      @category = category

      add_tag(:turf)
      add_tag(category.to_sym) if category
    end

    # Check if turf can be dug
    # @return [Boolean]
    def diggable?
      !@sealed && @turf_health > 0
    end

    # Damage the turf
    # @param amount [Integer] Damage amount
    def damage_turf(amount)
      return unless diggable?

      @turf_health -= amount
      if @turf_health <= 0
        on_destroyed
      end
    end

    # Called when turf is destroyed
    def on_destroyed
      add_tag(:destroyed)
      @excavated = true
    end

    # Check if turf is damaged
    # @return [Boolean]
    def damaged?
      @turf_health < 100
    end

    # Get damage percentage
    # @return [Float]
    def damage_percentage
      1.0 - (@turf_health.to_f / 100)
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        excavated: @excavated,
        sealed: @sealed,
        turf_health: @turf_health,
        category: @category
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Turf]
    def self.deserialize(data)
      new(
        excavated: data.fetch('excavated', false),
        sealed: data.fetch('sealed', false),
        turf_health: data.fetch('turf_health', 100),
        category: data.fetch('category', 'floor'),
        **data.slice('name', 'description', 'position').to_h
      )
    end
  end

  # Predefined turf types
  module TurfTypes
    SPACE = :space
    FLOOR = :floor
    WALL = :wall
    GRASS = :grass
    METAL = :metal
    WOOD = :wood
    GLASS = :glass
    CONCRETE = :concrete
    VOID = :void
  end
end