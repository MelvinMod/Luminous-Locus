# frozen_string_literal: true

module ResurgenceEngine
  # Line of Sight (LOS) Calculator
  #
  # Determines visibility between grid positions using ray casting.
  class LosCalculator
    # @return [Array<Position>] Cached ray path
    attr_reader :ray_path

    # Create a new LOS calculator
    def initialize
      @ray_path = []
      @opaque_blocks = []
    end

    # Set blocks that stop LOS
    # @param blocks [Array<Symbol>] Block types
    def set_opaque_blocks(*blocks)
      @opaque_blocks = blocks.flatten
    end

    # Check if two positions have line of sight
    # @param start [Position] Starting position
    # @param end_pos [Position] Target position
    # @param map [Map] Map to check on
    # @return [Boolean] Whether LOS exists
    def has_los?(start, end_pos, map)
      return false unless start && end_pos && map
      return false if start.z != end_pos.z
      return true if start == end_pos

      calculate_ray(start, end_pos, map)
      @ray_path.empty? || @ray_path.none? { |pos| blocks_los?(pos, map) }
    end

    # Calculate ray path between two points
    # @param start [Position] Starting position
    # @param end_pos [Position] Target position
    # @param map [Map] Map to check on
    # @return [Array<Position>] Path points
    def calculate_ray(start, end_pos, map)
      @ray_path = bresenham_line(start, end_pos, map)
      @ray_path
    end

    # Get the calculated ray path
    # @return [Array<Position>]
    def get_ray_path
      @ray_path
    end

    # Check if position blocks LOS
    # @param pos [Position] Position to check
    # @param map [Map] Map to check on
    # @return [Boolean]
    def blocks_los?(pos, map)
      obj = map.get_cell(pos)
      return false unless obj

      @opaque_blocks.any? { |block| obj.tagged?(block) }
    end

    # Bresenham's line algorithm for grid traversal
    # @param start [Position] Starting position
    # @param end_pos [Position] Ending position
    # @param map [Map] Map to check on
    # @return [Array<Position>] Grid positions along line
    def bresenham_line(start, end_pos, map)
      points = []
      return points unless map

      dx = (end_pos.x - start.x).abs
      dy = (end_pos.y - start.y).abs
      x = start.x
      y = start.y
      sx = start.x < end_pos.x ? 1 : -1
      sy = start.y < end_pos.y ? 1 : -1
      err = dx - dy

      loop do
        pos = Position[x, y, start.z]
        points << pos if map.valid_position?(pos)

        break if x == end_pos.x && y == end_pos.y

        e2 = 2 * err
        if e2 > -dy
          err += dy
          x += sx
        end
        if e2 < dx
          err += dx
          y += sy
        end
      end

      points
    end

    # Get visible cells from a position
    # @param center [Position] Center position
    # @param range [Integer] View radius
    # @param map [Map] Map to check on
    # @return [Array<Position>] Visible positions
    def get_visible_cells(center, range, map)
      return [] unless map

      visible = []
      (center.x - range..center.x + range).each do |x|
        (center.y - range..center.y + range).each do |y|
          pos = Position[x, y, center.z]
          next unless map.valid_position?(pos)

          dist = pos.manhattan_distance(center)
          next if dist > range

          if has_los?(center, pos, map)
            visible << pos
          end
        end
      end
      visible
    end

    # Get visible cells with shading
    # @param center [Position] Center position
    # @param range [Integer] View radius
    # @param map [Map] Map to check on
    # @return [Hash<Position, Symbol>] Visible positions and their status
    def get_visible_cells_with_shadows(center, range, map)
      visible = get_visible_cells(center, range, map)
      visible.each_with_object({}) do |pos, result|
        result[pos] = if pos == center
          :visible
        elsif blocks_los?(pos, map)
          :blocking
        else
          :visible
        end
      end
    end
  end
end