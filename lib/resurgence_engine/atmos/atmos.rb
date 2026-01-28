# frozen_string_literal: true

module ResurgenceEngine
  # Atmospheric simulation system
  #
  # Handles gas mixtures, temperature, and pressure.
  module Atmos
    # Gas type constants
    module GasTypes
      OXYGEN = 1
      NITROGEN = 2
      CARBON_DIOXIDE = 4
      PLASMA = 8
      WATER_VAPOR = 16
      METHANE = 32
      HYDROGEN = 64
      HELIUM = 128
      ARGON = 256
      TRITIUM = 512

      # Gas names for display
      NAMES = {
        OXYGEN => 'Oxygen',
        NITROGEN => 'Nitrogen',
        CARBON_DIOXIDE => 'Carbon Dioxide',
        PLASMA => 'Plasma',
        WATER_VAPOR => 'Water Vapor',
        METHANE => 'Methane',
        HYDROGEN => 'Hydrogen',
        HELIUM => 'Helium',
        ARGON => 'Argon',
        TRITIUM => 'Tritium'
      }.freeze

      # Get gas name
      # @param type [Integer] Gas type
      # @return [String]
      def self.name(type)
        NAMES[type] || "Unknown(#{type})"
      end
    end

    # Gas mixture class
    class GasMixture
      # @return [Hash<Integer, Float>] Gas amounts in moles
      attr_reader :gases

      # @return [Float] Temperature in Kelvin
      attr_accessor :temperature

      # @return [Float] Volume in liters
      attr_reader :volume

      # @return [Float] Pressure in kPa
      attr_reader :pressure

      # Create a new gas mixture
    def initialize(temperature: 293, volume: 100)
      @gases = Hash.new(0)
      @temperature = temperature
      @volume = volume
      @pressure = 0
      calculate_pressure
    end

      # Add gas
      # @param type [Integer] Gas type
      # @param amount [Float] Amount in moles
      def add_gas(type, amount)
        @gases[type] += amount
        calculate_pressure
      end

      # Remove gas
      # @param type [Integer] Gas type
      # @param amount [Float] Amount to remove
      # @return [Float] Actual amount removed
      def remove_gas(type, amount)
        existing = @gases[type] || 0
        removed = [amount, existing].min
        @gases[type] = existing - removed
        calculate_pressure
        removed
      end

      # Get gas amount
      # @param type [Integer] Gas type
      # @return [Float]
      def [](type)
        @gases[type] || 0
      end

      # Set gas amount
      # @param type [Integer] Gas type
      # @param amount [Float] Amount
      def []=(type, amount)
        @gases[type] = amount
        calculate_pressure
      end

      # Get total moles
      # @return [Float]
      def total_moles
        @gases.values.sum
      end

      # Calculate pressure using ideal gas law
      def calculate_pressure
        return if total_moles.zero?
        return if @volume.zero?

        # PV = nRT
        # P = nRT / V
        # R = 8.314 J/(mol·K)
        r = 8.314
        @pressure = (total_moles * r * @temperature) / @volume
      end

      # Get gas fraction
      # @param type [Integer] Gas type
      # @return [Float] Fraction (0-1)
      def fraction(type)
        total = total_moles
        return 0 if total.zero?

        (@gases[type] || 0) / total
      end

      # Get partial pressure
      # @param type [Integer] Gas type
      # @return [Float] Partial pressure
      def partial_pressure(type)
        fraction(type) * @pressure
      end

      # Check if gas is present
      # @param type [Integer] Gas type
      # @return [Boolean]
      def has_gas?(type)
        (@gases[type] || 0) > 0
      end

      # Check if gas is toxic
      # @return [Boolean]
      def toxic?
        # High CO2 or plasma
        fraction(GasTypes::CARBON_DIOXIDE) > 0.05 || has_gas?(GasTypes::PLASMA)
      end

      # Check if breathable
      # @return [Boolean]
      def breathable?
        return false unless has_gas?(GasTypes::OXYGEN)
        fraction(GasTypes::OXYGEN) > 0.16
      end

      # Check if flammable
      # @return [Boolean]
      def flammable?
        has_gas?(GasTypes::PLASMA) || has_gas?(GasTypes::HYDROGEN) ||
          has_gas?(GasTypes::METHANE)
      end

      # Copy mixture
      # @return [GasMixture]
      def copy
        mixture = GasMixture.new(temperature: @temperature, volume: @volume)
        @gases.each { |type, amount| mixture.gases[type] = amount }
        mixture
      end

      # Merge with another mixture
      # @param other [GasMixture] Mixture to merge
      def merge!(other)
        other.gases.each do |type, amount|
          @gases[type] += amount
        end
        @temperature = (@temperature + other.temperature) / 2
        calculate_pressure
      end

      # Equalize with another mixture
      # @param other [GasMixture] Mixture to equalize with
      # @param rate [Float] Equalization rate
      def equalize!(other, rate = 0.1)
        return if other.total_moles.zero?

        # Temperature equalization
        temp_diff = other.temperature - @temperature
        @temperature += temp_diff * rate
        other.temperature -= temp_diff * rate

        # Pressure equalization
        pressure_diff = other.pressure - @pressure
        transfer_amount = (pressure_diff * @volume / 2) * rate

        if pressure_diff > 0
          other.remove_gas(0, transfer_amount / 100)
          add_gas(0, transfer_amount / 100)
        else
          remove_gas(0, -transfer_amount / 100)
          other.add_gas(0, -transfer_amount / 100)
        end

        calculate_pressure
        other.calculate_pressure
      end

      # Serialize to hash
      # @return [Hash]
      def serialize
        {
          gases: @gases.dup,
          temperature: @temperature,
          volume: @volume,
          pressure: @pressure
        }
      end

      # Deserialize from hash
      # @param data [Hash] Serialized data
      # @return [GasMixture]
      def self.deserialize(data)
        mixture = new(temperature: data['temperature'], volume: data['volume'])
        data['gases'].each { |type, amount| mixture.gases[type] = amount }
        mixture.calculate_pressure
        mixture
      end
    end

    # Tile atmosphere data
    class TileAtmos
      # @return [GasMixture] Gas mixture
      attr_reader :air

      # @return [Boolean] Whether sealed (no air exchange)
      attr_accessor :sealed

      # @return [Boolean] Whether actively processing
      attr_accessor :active

      # @return [Integer] Fire temperature
      attr_accessor :fire_temperature

      # @return [Boolean] Whether on fire
      attr_accessor :on_fire

      # Create new tile atmosphere
      def initialize
        @air = GasMixture.new
        @sealed = false
        @active = true
        @fire_temperature = 0
        @on_fire = false
      end

      # Process atmosphere tick
      # @param delta [Float] Time since last tick
      # @param neighbors [Array<TileAtmos>] Adjacent tiles
      def tick(delta, neighbors)
        return unless @active
        return if @sealed

        # Fire processing
        if @on_fire
          process_fire(delta)
        end

        # Gas diffusion
        process_diffusion(delta, neighbors)

        # Temperature exchange
        process_temperature(delta, neighbors)
      end

      # Process fire
      # @param delta [Float] Time since last tick
      def process_fire(delta)
        # Fire consumes flammable gases
        flammable_gases = [GasTypes::PLASMA, GasTypes::METHANE, GasTypes::HYDROGEN]
        flammable_gases.each do |gas|
          amount = @air[gas]
          next unless amount.positive?

          consumed = [@air.remove_gas(gas, amount * delta * 2), 0].max
          @fire_temperature += consumed * 100
        end

        # Fire heats up
        @fire_temperature = [@fire_temperature - delta * 10, 0].max
        @on_fire = @fire_temperature > 400
        @air.temperature = [@air.temperature + delta * 5, @fire_temperature].min
      end

      # Process gas diffusion
      # @param delta [Float] Time since last tick
      # @param neighbors [Array<TileAtmos>] Adjacent tiles
      def process_diffusion(delta, neighbors)
        neighbors.each do |neighbor|
          next if neighbor.sealed

          @air.equalize!(neighbor.air, delta * 0.1)
        end
      end

      # Process temperature exchange
      # @param delta [Float] Time since last tick
      # @param neighbors [Array<TileAtmos>] Adjacent tiles
      def process_temperature(delta, neighbors)
        neighbors.each do |neighbor|
          next if neighbor.sealed

          temp_diff = neighbor.air.temperature - @air.temperature
          next if temp_diff.zero?

          exchange = temp_diff * delta * 0.1
          @air.temperature += exchange
          neighbor.air.temperature -= exchange
        end
      end

      # Ignite tile
      # @return [Boolean] Success
      def ignite
        return false if @on_fire || !@air.flammable?

        @on_fire = true
        @fire_temperature = 400
        true
      end

      # Extinguish fire
      def extinguish
        @on_fire = false
        @fire_temperature = 0
      end

      # Check if smoke is present
      # @return [Boolean]
      def smoky?
        @air.fraction(GasTypes::CARBON_DIOXIDE) > 0.1 ||
          @air.fraction(GasTypes::PLASMA) > 0.05
      end

      # Serialize to hash
      # @return [Hash]
      def serialize
        {
          air: @air.serialize,
          sealed: @sealed,
          active: @active,
          fire_temperature: @fire_temperature,
          on_fire: @on_fire
        }
      end

      # Deserialize from hash
      # @param data [Hash] Serialized data
      # @return [TileAtmos]
      def self.deserialize(data)
        atmos = new
        atmos.instance_variable_set(:@air, GasMixture.deserialize(data['air']))
        atmos.sealed = data.fetch('sealed', false)
        atmos.active = data.fetch('active', true)
        atmos.fire_temperature = data.fetch('fire_temperature', 0)
        atmos.on_fire = data.fetch('on_fire', false)
        atmos
      end
    end

    # Atmosphere global handler
    class Atmosphere
      # @return [Hash<Position, TileAtmos>] Tile atmospheres
      attr_reader :tile_atmos

      # @return [Float] Processing interval
      attr_accessor :process_interval

      # @return [Boolean] Whether running
      attr_reader :running

      def initialize
        @tile_atmos = {}
        @process_interval = 0.1
        @running = false
        @last_process = Time.now
      end

      # Start atmosphere simulation
      def start
        @running = true
      end

      # Stop atmosphere simulation
      def stop
        @running = false
      end

      # Get or create tile atmosphere
      # @param position [Position] Tile position
      # @return [TileAtmos]
      def get_atmos(position)
        @tile_atmos[position] ||= TileAtmos.new
      end

      # Remove tile atmosphere
      # @param position [Position] Tile position
      def remove_atmos(position)
        @tile_atmos.delete(position)
      end

      # Check if tile has atmosphere
      # @param position [Position] Tile position
      # @return [Boolean]
      def has_atmos?(position)
        @tile_atmos.key?(position)
      end

      # Process atmosphere updates
      # @param map [Map] Map to process
      # @param delta [Float] Time since last tick
      def process(map, delta)
        return unless @running

        now = Time.now
        return if now - @last_process < @process_interval

        @last_process = now

        @tile_atmos.each do |position, atmos|
          next unless map.valid_position?(position)

          neighbors = get_neighbor_atmos(position, map)
          atmos.tick(delta, neighbors)
        end
      end

      # Get neighboring atmospheres
      # @param position [Position] Center position
      # @param map [Map] Map to check
      # @return [Array<TileAtmos>]
      def get_neighbor_atmos(position, map)
        neighbors = []
        Direction::CARDINAL.each do |dir|
          neighbor_pos = position.neighbor(dir)
          next unless map.valid_position?(neighbor_pos)

          atmos = @tile_atmos[neighbor_pos]
          neighbors << atmos if atmos
        end
        neighbors
      end

      # Get all fire tiles
      # @return [Array<Position>]
      def fire_tiles
        @tile_atmos.select { |_, a| a.on_fire }.keys
      end

      # Get all smoky tiles
      # @return [Array<Position>]
      def smoky_tiles
        @tile_atmos.select { |_, a| a.smoky? }.keys
      end

      # Check if position is on fire
      # @param position [Position] Position to check
      # @return [Boolean]
      def on_fire?(position)
        @tile_atmos[position]&.on_fire || false
      end

      # Ignite position
      # @param position [Position] Position to ignite
      # @return [Boolean] Success
      def ignite(position)
        get_atmos(position).ignite
      end

      # Extinguish position
      # @param position [Position] Position to extinguish
      def extinguish(position)
        @tile_atmos[position]&.extinguish
      end

      # Serialize to hash
      # @return [Hash]
      def serialize
        {
          tile_atmos: @tile_atmos.transform_keys(&:to_a).transform_values(&:serialize),
          process_interval: @process_interval
        }
      end

      # Deserialize from hash
      # @param data [Hash] Serialized data
      # @return [Atmosphere]
      def self.deserialize(data)
        atmos = new
        atmos.process_interval = data.fetch('process_interval', 0.1)
        data['tile_atmos'].each do |pos_array, atmos_data|
          position = Position[*pos_array]
          atmos.tile_atmos[position] = TileAtmos.deserialize(atmos_data)
        end
        atmos
      end
    end
  end
end