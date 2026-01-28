# frozen_string_literal: true

module ResurgenceEngine
  # Base class for all map objects
  #
  # Provides common functionality for objects that exist on a map.
  class MapObject < Object
    # @return [Position, nil] Current position
    attr_accessor :position

    # @return [Map, nil] Current map
    attr_accessor :map

    # @return [Integer] Layer for rendering order
    attr_accessor :layer

    # @return [Integer] Plane for Z-ordering
    attr_accessor :plane

    # @return [Integer] Render priority
    attr_accessor :render_priority

    # @return [Boolean] Whether visible
    attr_accessor :visible

    # @return [Boolean] Whether inanimate (doesn't tick)
    attr_accessor :inanimate

    # Initialize a new map object
    # @param position [Position, nil] Initial position
    def initialize(position: nil, **kwargs)
      super(**kwargs)
      @position = position
      @map = nil
      @layer = 0
      @plane = 0
      @render_priority = 0
      @visible = true
      @inanimate = false
    end

    # Called when added to a map
    # @param map [Map] Map being added to
    def on_add_to_map(map)
      super
      @map = map
    end

    # Called when removed from a map
    # @param map [Map] Map being removed from
    def on_remove_from_map(map)
      super
      @map = nil
    end

    # Tick the object
    # @param delta [Float] Time since last tick
    def tick(delta)
      return if @inanimate
      return unless @map

      on_tick(delta)
    end

    # Called each tick (override in subclasses)
    # @param delta [Float] Time since last tick
    def on_tick(delta); end

    # Check if object is at a position
    # @param pos [Position] Position to check
    # @return [Boolean]
    def at?(pos)
      @position == pos
    end

    # Move to a new position
    # @param new_pos [Position] New position
    # @return [Boolean] Success
    def move_to(new_pos)
      return false unless @map
      return false unless @map.valid_position?(new_pos)
      return false if @map.occupied?(new_pos)

      old_pos = @position
      @position = new_pos
      on_moved(old_pos, new_pos)
      true
    end

    # Called after moving
    # @param old_pos [Position] Previous position
    # @param new_pos [Position] New position
    def on_moved(old_pos, new_pos); end

    # Check if can be seen from position
    # @param from [Position] Observer position
    # @return [Boolean]
    def visible_from?(from)
      return false unless @map
      return false unless @map.has_los?(from, @position)

      @visible && !@map.get_cell(@position)&.taged?(:transparent)
    end

    # Get view info for rendering
    # @return [Types::ViewInfo]
    def get_view_info
      return Types::EMPTY_VIEW unless @visible

      Types::ViewInfo.new(
        icon: icon_path,
        icon_state: icon_state,
        dir: Direction::SOUTH,
        pixel_x: pixel_x,
        pixel_y: pixel_y,
        color: color,
        alpha: alpha
      )
    end

    # Get icon path
    # @return [String]
    def icon_path
      @icon_path || object_type.downcase
    end

    # Get icon state
    # @return [String]
    def icon_state
      @icon_state || ''
    end

    # Get pixel X offset
    # @return [Integer]
    def pixel_x
      @pixel_x || 0
    end

    # Get pixel Y offset
    # @return [Integer]
    def pixel_y
      @pixel_y || 0
    end

    # Get color overlay
    # @return [String]
    def color
      @color || '#FFFFFF'
    end

    # Get alpha value
    # @return [Integer]
    def alpha
      @alpha || 255
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        position: @position&.to_a,
        layer: @layer,
        plane: @plane,
        render_priority: @render_priority,
        visible: @visible,
        inanimate: @inanimate
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [MapObject]
    def self.deserialize(data)
      obj = new(
        name: data['name'],
        position: data['position'] && Position[*data['position']]
      )
      obj.instance_variable_set(:@layer, data['layer'] || 0)
      obj.instance_variable_set(:@plane, data['plane'] || 0)
      obj.instance_variable_set(:@render_priority, data['render_priority'] || 0)
      obj.instance_variable_set(:@visible, data.fetch('visible', true))
      obj.instance_variable_set(:@inanimate, data.fetch('inanimate', false))
      obj
    end
  end
end