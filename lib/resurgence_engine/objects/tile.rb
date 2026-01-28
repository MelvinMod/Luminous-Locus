# frozen_string_literal: true

module ResurgenceEngine
  # Base class for tiles
  #
  # Represents individual grid cells on a map.
  class Tile < MapObject
    # @return [Boolean] Whether the tile is solid
    attr_accessor :solid

    # @return [Boolean] Whether transparent for LOS
    attr_accessor :transparent

    # @return [Boolean] Whether walkable
    attr_accessor :walkable

    # @return [Boolean] Whether flammable
    attr_accessor :flammable

    # @return [Integer] Tile temperature
    attr_accessor :temperature

    # @return [Integer] Pressure level
    attr_accessor :pressure

    # @return [Integer] Gas mixture
    attr_accessor :gas_mixture

    # Initialize a new tile
    def initialize(
      solid: false,
      transparent: true,
      walkable: true,
      flammable: false,
      temperature: 293,  # ~20°C in Kelvin
      pressure: 101_325, # 1 atm in Pa
      gas_mixture: 0,
      **kwargs
    )
      super(**kwargs)
      @solid = solid
      @transparent = transparent
      @walkable = walkable
      @flammable = flammable
      @temperature = temperature
      @pressure = pressure
      @gas_mixture = gas_mixture

      add_tag(:tile)
    end

    # Check if tile is transparent
    # @return [Boolean]
    def transparent?
      @transparent
    end

    # Check if tile is walkable
    # @return [Boolean]
    def walkable?
      @walkable && !@solid
    end

    # Check if tile blocks movement
    # @return [Boolean]
    def blocks_movement?
      @solid || !@walkable
    end

    # Check if tile blocks LOS
    # @return [Boolean]
    def blocks_los?
      !@transparent
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        solid: @solid,
        transparent: @transparent,
        walkable: @walkable,
        flammable: @flammable,
        temperature: @temperature,
        pressure: @pressure,
        gas_mixture: @gas_mixture
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Tile]
    def self.deserialize(data)
      new(
        solid: data.fetch('solid', false),
        transparent: data.fetch('transparent', true),
        walkable: data.fetch('walkable', true),
        flammable: data.fetch('flammable', false),
        temperature: data.fetch('temperature', 293),
        pressure: data.fetch('pressure', 101_325),
        gas_mixture: data.fetch('gas_mixture', 0),
        **data.slice('name', 'description', 'position').to_h
      )
    end
  end
end