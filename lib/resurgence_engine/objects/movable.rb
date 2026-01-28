# frozen_string_literal: true

module ResurgenceEngine
  # Movable class - objects that can move
  #
  # Base class for items, mobs, and other moving objects.
  class Movable < MapObject
    # @return [Integer] Movement speed (tiles per second)
    attr_accessor :speed

    # @return [Integer] Movement flags
    attr_accessor :movement_flags

    # @return [Boolean] Whether currently moving
    attr_accessor :moving

    # @return [Position, nil] Destination if moving
    attr_accessor :destination

    # @return [Array<Position>] Path being followed
    attr_reader :path

    # @return [Float] Time until next movement step
    attr_accessor :move_timer

    # @return [Integer] Current direction facing
    attr_accessor :facing

    # Initialize a new movable object
    def initialize(
      speed: 4,
      movement_flags: 0,
      moving: false,
      destination: nil,
      move_timer: 0.0,
      facing: Direction::SOUTH,
      **kwargs
    )
      super(**kwargs)
      @speed = speed
      @movement_flags = movement_flags
      @moving = moving
      @destination = destination
      @path = []
      @move_timer = move_timer
      @facing = facing

      @inanimate = false
    end

    # Move in a direction
    # @param dir [Integer] Direction to move
    # @return [Boolean] Success
    def move(dir)
      return false unless @map
      return false if @movement_flags & MovementFlags::LOCKED != 0

      new_pos = @position.neighbor(dir)
      return false unless can_move_to?(new_pos)

      @facing = dir
      move_to(new_pos)
    end

    # Check if can move to position
    # @param pos [Position] Target position
    # @return [Boolean]
    def can_move_to?(pos)
      return false unless @map.valid_position?(pos)

      cell = @map.get_cell(pos)
      return true if cell.nil? || cell.tagged?(:passable)

      false
    end

    # Set movement destination
    # @param pos [Position] Target position
    # @return [Boolean] Success
    def set_destination(pos)
      return false unless @map.valid_position?(pos)

      @destination = pos
      @moving = true
      calculate_path
      true
    end

    # Calculate path to destination
    def calculate_path
      return unless @destination

      @path = find_path_to(@destination)
    end

    # Find path to target position
    # @param target [Position] Target position
    # @return [Array<Position>] Path
    def find_path_to(target)
      # Simple BFS pathfinding
      return [] unless @map

      queue = [[@position]]
      visited = Set.new([@position])

      until queue.empty?
        path = queue.shift
        current = path.last

        return path[1..] if current == target

        neighbors = @map.get_neighbors(current, Direction::CARDINAL)
        neighbors.each_value do |pos|
          next if visited.include?(pos)
          next unless can_move_to?(pos)

          visited << pos
          queue << path + [pos]
        end
      end

      []
    end

    # Stop moving
    def stop_moving
      @moving = false
      @destination = nil
      @path = []
    end

    # Tick movement
    # @param delta [Float] Time since last tick
    def tick(delta)
      super

      return unless @moving

      @move_timer -= delta
      return if @move_timer > 0

      if @path.any?
        next_pos = @path.shift
        move_to(next_pos)
        @move_timer = 1.0 / @speed if @speed > 0
      elsif @destination
        if can_move_to?(@destination)
          move_to(@destination)
        else
          # Path blocked, recalculate
          calculate_path
        end
        @move_timer = 1.0 / @speed if @speed > 0
      else
        stop_moving
      end
    end

    # Check if movement is locked
    # @return [Boolean]
    def movement_locked?
      @movement_flags & MovementFlags::LOCKED != 0
    end

    # Lock movement
    def lock_movement
      @movement_flags |= MovementFlags::LOCKED
    end

    # Unlock movement
    def unlock_movement
      @movement_flags &= ~MovementFlags::LOCKED
    end

    # Set facing direction
    # @param dir [Integer] Direction
    def facing=(dir)
      @facing = Direction.valid?(dir) ? dir : @facing
    end

    # Get opposite of facing direction
    # @return [Integer]
    def behind
      Direction.opposite(@facing)
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        speed: @speed,
        movement_flags: @movement_flags,
        moving: @moving,
        destination: @destination&.to_a,
        facing: @facing
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Movable]
    def self.deserialize(data)
      movable = new(
        speed: data.fetch('speed', 4),
        movement_flags: data.fetch('movement_flags', 0),
        moving: data.fetch('moving', false),
        move_timer: data.fetch('move_timer', 0.0),
        facing: data.fetch('facing', Direction::SOUTH),
        **data.slice('name', 'description', 'position').to_h
      )
      movable.instance_variable_set(:@destination,
        data['destination'] && Position[*data['destination']])
      movable
    end
  end

  # Movement flags module
  module MovementFlags
    NONE = 0
    LOCKED = 1
    FLYING = 2
    SWIMMING = 4
    NO_GRAVITY = 8
    SLIDE = 16
    MAGNETIC = 32
    PHASING = 64
  end
end