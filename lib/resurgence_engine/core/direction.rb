# ResurgenceEngine Direction Module
# Direction constants and utilities
# 
# Handles direction-related calculations
# for grid-based movement

module ResurgenceEngine
  module Direction
    # Direction constants
    NORTH = 0
    EAST = 1
    SOUTH = 2
    WEST = 3
    UP = 4
    DOWN = 5

    # All directions
    ALL = [NORTH, EAST, SOUTH, WEST, UP, DOWN]

    # Cardinal directions
    CARDINAL = [NORTH, EAST, SOUTH, WEST]

    # Horizontal directions
    HORIZONTAL = [EAST, WEST]

    # Vertical directions
    VERTICAL = [UP, DOWN]

    # Direction names
    NAMES = {
      NORTH => 'north',
      EAST => 'east',
      SOUTH => 'south',
      WEST => 'west',
      UP => 'up',
      DOWN => 'down'
    }

    # Opposite directions
    OPPOSITE = {
      NORTH => SOUTH,
      EAST => WEST,
      SOUTH => NORTH,
      WEST => EAST,
      UP => DOWN,
      DOWN => UP
    }

    # Direction vectors
    VECTORS = {
      NORTH => [0, -1, 0],
      EAST => [1, 0, 0],
      SOUTH => [0, 1, 0],
      WEST => [-1, 0, 0],
      UP => [0, 0, 1],
      DOWN => [0, 0, -1]
    }

    # Get direction name
    def self.name(dir)
      NAMES[dir] || 'unknown'
    end

    # Get opposite direction
    def self.opposite(dir)
      OPPOSITE[dir] || dir
    end

    # Get direction vector
    def self.vector(dir)
      VECTORS[dir] || [0, 0, 0]
    end

    # Get random direction
    def self.random
      ALL.sample
    end

    # Get random cardinal direction
    def self.random_cardinal
      CARDINAL.sample
    end

    # Turn left from direction
    def self.turn_left(dir)
      case dir
      when NORTH then WEST
      when WEST then SOUTH
      when SOUTH then EAST
      when EAST then NORTH
      else dir
      end
    end

    # Turn right from direction
    def self.turn_right(dir)
      case dir
      when NORTH then EAST
      when EAST then SOUTH
      when SOUTH then WEST
      when WEST then NORTH
      else dir
      end
    end

    # Get direction from vector
    def self.from_vector(vec)
      VECTORS.key(vec) || 0
    end
  end
end
