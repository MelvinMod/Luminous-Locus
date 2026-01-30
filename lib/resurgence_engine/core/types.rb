# frozen_string_literal: true

module ResurgenceEngine
  # Basic types used throughout the engine
  module Types
    # 32-bit unsigned integer equivalent
    UInt32 = Integer

    # 32-bit signed integer equivalent
    Int32 = Integer

    # 64-bit signed integer equivalent
    Int64 = Integer

    # QByteArray equivalent for binary data
    ByteArray = String

    # QJsonObject equivalent for structured data
    JsonObject = Hash

    # QString equivalent
    String = ::String

    # View information for rendering
    ViewInfo = Data.define(:icon, :icon_state, :dir, :pixel_x, :pixel_y, :color, :alpha)

    # Default empty view info - will be initialized after Direction is loaded
    EMPTY_VIEW = nil

    # Type checking helpers
    def self.uint32?(value)
      value.is_a?(Integer) && value >= 0 && value <= 4_294_967_295
    end

    def self.int32?(value)
      value.is_a?(Integer) && value >= -2_147_483_648 && value <= 2_147_483_647
    end
  end
end