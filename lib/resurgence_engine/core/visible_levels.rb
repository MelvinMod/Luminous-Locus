# frozen_string_literal: true

module ResurgenceEngine
  # Visible levels for rendering
  #
  # Determines which Z-levels are visible from a given position.
  class VisibleLevels
    # @return [Array<Integer>] List of visible Z-levels
    attr_reader :levels

    # @return [Integer] Minimum visible level
    attr_reader :min_level

    # @return [Integer] Maximum visible level
    attr_reader :max_level

    # @return [Integer] View distance in Z-axis
    attr_reader :z_view_range

    # Create a new VisibleLevels
    # @param levels [Array<Integer>] Visible levels
    # @param min_level [Integer] Minimum level
    # @param max_level [Integer] Maximum level
    # @param z_view_range [Integer] Z-axis view range
    def initialize(
      levels: [0],
      min_level: 0,
      max_level: 0,
      z_view_range: 1
    )
      @levels = levels
      @min_level = min_level
      @max_level = max_level
      @z_view_range = z_view_range
    end

    # Check if a level is visible
    # @param level [Integer] Level to check
    # @return [Boolean]
    def visible?(level)
      @levels.include?(level)
    end

    # Get levels visible from a center level
    # @param center [Integer] Center level
    # @param range [Integer] Range above/below to show
    # @return [VisibleLevels]
    def self.from_center(center, range = 1)
      levels = (center - range..center + range).to_a
      new(
        levels: levels,
        min_level: levels.min,
        max_level: levels.max,
        z_view_range: range
      )
    end

    # Get all levels
    # @param depth [Integer] Map depth
    # @return [VisibleLevels]
    def self.all(depth)
      levels = (0...depth).to_a
      new(
        levels: levels,
        min_level: 0,
        max_level: depth - 1,
        z_view_range: depth
      )
    end

    # Empty visibility
    def self.none
      new(levels: [], min_level: 0, max_level: 0, z_view_range: 0)
    end
  end
end