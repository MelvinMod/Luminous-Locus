# frozen_string_literal: true

module ResurgenceEngine
  # Frame data for visual rendering
  #
  # Represents a single frame of animation or static sprite.
  class FrameData
    # @return [String] Icon file path
    attr_reader :icon

    # @return [String] Icon state (animation state)
    attr_reader :icon_state

    # @return [Integer] Direction for directional sprites
    attr_reader :dir

    # @return [Integer] Pixel X offset
    attr_reader :pixel_x

    # @return [Integer] Pixel Y offset
    attr_reader :pixel_y

    # @return [String] Color overlay (hex or CSS color)
    attr_reader :color

    # @return [Integer] Alpha/transparency (0-255)
    attr_reader :alpha

    # @return [Integer] Frame number in animation
    attr_reader :frame_number

    # @return [Float] Frame delay in seconds
    attr_reader :delay

    # @return [Boolean] Whether this is a looping frame
    attr_reader :loop

    # Create a new FrameData
    # @param icon [String] Icon file path
    # @param icon_state [String] Icon state
    # @param dir [Integer] Direction
    # @param pixel_x [Integer] Pixel X offset
    # @param pixel_y [Integer] Pixel Y offset
    # @param color [String] Color overlay
    # @param alpha [Integer] Alpha value
    # @param frame_number [Integer] Frame number
    # @param delay [Float] Frame delay
    # @param loop [Boolean] Loop flag
    def initialize(
      icon: '',
      icon_state: '',
      dir: Direction::SOUTH,
      pixel_x: 0,
      pixel_y: 0,
      color: '#FFFFFF',
      alpha: 255,
      frame_number: 0,
      delay: 0.1,
      loop: true
    )
      @icon = icon
      @icon_state = icon_state
      @dir = dir
      @pixel_x = pixel_x
      @pixel_y = pixel_y
      @color = color
      @alpha = alpha
      @frame_number = frame_number
      @delay = delay
      @loop = loop
    end

    # Create from view info
    # @param view [Types::ViewInfo] View info
    # @return [FrameData]
    def self.from_view_info(view)
      new(
        icon: view.icon,
        icon_state: view.icon_state,
        dir: view.dir,
        pixel_x: view.pixel_x,
        pixel_y: view.pixel_y,
        color: view.color,
        alpha: view.alpha
      )
    end

    # Convert to view info
    # @return [Types::ViewInfo]
    def to_view_info
      Types::ViewInfo.new(
        icon: @icon,
        icon_state: @icon_state,
        dir: @dir,
        pixel_x: @pixel_x,
        pixel_y: @pixel_y,
        color: @color,
        alpha: @alpha
      )
    end

    # Create a copy with modifications
    # @param kwargs [Hash] Modifications
    # @return [FrameData]
    def with(**kwargs)
      FrameData.new(
        icon: kwargs.fetch(:icon, @icon),
        icon_state: kwargs.fetch(:icon_state, @icon_state),
        dir: kwargs.fetch(:dir, @dir),
        pixel_x: kwargs.fetch(:pixel_x, @pixel_x),
        pixel_y: kwargs.fetch(:pixel_y, @pixel_y),
        color: kwargs.fetch(:color, @color),
        alpha: kwargs.fetch(:alpha, @alpha),
        frame_number: kwargs.fetch(:frame_number, @frame_number),
        delay: kwargs.fetch(:delay, @delay),
        loop: kwargs.fetch(:loop, @loop)
      )
    end

    # Check if frame is visible
    # @return [Boolean]
    def visible?
      !@icon.nil? && !@icon.empty?
    end

    # Equality
    # @return [Boolean]
    def ==(other)
      other.is_a?(FrameData) &&
        @icon == other.icon &&
        @icon_state == other.icon_state &&
        @dir == other.dir
    end

    alias eql? ==

    # Hash
    # @return [Integer]
    def hash
      [@icon, @icon_state, @dir].hash
    end

    # String representation
    # @return [String]
    def inspect
      "#<FrameData #{@icon.inspect}/#{@icon_state.inspect} dir=#{Direction.name(@dir)}>"
    end
  end
end