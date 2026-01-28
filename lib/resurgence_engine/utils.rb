# ResurgenceEngine Utils Module
# Utility functions for the engine
# 
# Helper functions for math, randomization,
# formatting, and data manipulation

module ResurgenceEngine
  module Utils
    # Generate a unique ID
    def self.generate_id
      "#{Time.now.to_i}-#{rand(1000000)}"
    end

    # Clamp value between min and max
    def self.clamp(value, min, max)
      [[value, max].min, min].max
    end

    # Linear interpolation
    def self.lerp(start, stop, fraction)
      start + (stop - start) * fraction
    end

    # Map value from one range to another
    def self.map_range(value, in_min, in_max, out_min, out_max)
      return out_min if in_max == in_min
      (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    end

    # Convert degrees to radians
    def self.degrees_to_radians(degrees)
      degrees * Math::PI / 180
    end

    # Convert radians to degrees
    def self.radians_to_degrees(radians)
      radians * 180 / Math::PI
    end

    # Wrap value between min and max
    def self.wrap(value, min, max)
      range = max - min
      return min + ((value - min) % range) if range != 0
      min
    end

    # Check if value is between min and max
    def self.between?(value, min, max)
      value >= min && value <= max
    end

    # Round to nearest multiple
    def self.round_to(value, nearest)
      (value / nearest.to_f).round * nearest
    end

    # Get random float in range
    def self.random_float(min = 0.0, max = 1.0)
      min + rand * (max - min)
    end

    # Get random integer in range
    def self.random_int(min, max)
      rand(max - min + 1) + min
    end

    # Get random element from array
    def self.random_element(array)
      array.sample if array.any?
    end

    # Weighted random selection
    def self.weighted_random(options)
      total = options.values.sum
      return options.keys.first if total.zero?

      threshold = rand * total
      current = 0

      options.each do |item, weight|
        current += weight
        return item if current >= threshold
      end

      options.keys.last
    end

    # Normalize a vector
    def self.normalize(vector)
      length = Math.sqrt(vector.sum { |v| v**2 })
      return vector if length.zero?
      vector.map { |v| v / length }
    end

    # Vector magnitude
    def self.magnitude(vector)
      Math.sqrt(vector.sum { |v| v**2 })
    end

    # Dot product
    def self.dot(v1, v2)
      v1.zip(v2).sum { |a, b| a * b }
    end

    # Distance between two points
    def self.distance(p1, p2)
      Math.sqrt(p1.zip(p2).sum { |a, b| (a - b)**2 })
    end

    # Format number with commas
    def self.format_number(number)
      number.to_s.gsub(/\d(?=(...)+$)/, '\1,')
    end

    # Format duration in seconds
    def self.format_duration(seconds)
      return '0s' if seconds.zero?

      parts = []
      remaining = seconds

      if remaining >= 86400
        days = (remaining / 86400).to_i
        parts << "#{days}d"
        remaining %= 86400
      end

      if remaining >= 3600
        hours = (remaining / 3600).to_i
        parts << "#{hours}h"
        remaining %= 3600
      end

      if remaining >= 60
        minutes = (remaining / 60).to_i
        parts << "#{minutes}m"
        remaining %= 60
      end

      parts << "#{remaining.round(1)}s" if remaining > 0 || parts.empty?
      parts.join(' ')
    end

    # Deep freeze a hash or array
    def self.deep_freeze(obj)
      case obj
      when Hash
        obj.each { |_, v| deep_freeze(v) }
        obj.freeze
      when Array
        obj.each { |v| deep_freeze(v) }
        obj.freeze
      else
        obj
      end
    end

    # Deep copy an object
    def self.deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end

    # Memoize a method result
    def self.memoize(key, expires_in = nil)
      cache_key = [:utils_memoize, key]
      return nil unless ResurgenceEngine::Core.world

      cached = ResurgenceEngine::Core.world.get_data(cache_key)
      return cached if cached && !expires_in
      return cached if cached && cached[:expires_at] > Time.now

      result = yield
      cached_result = { value: result, expires_at: Time.now + expires_in }
      ResurgenceEngine::Core.world.set_data(cache_key, cached_result)
      result
    end

    # Debounce a block
    def self.debounce(delay)
      ->(&block) do
        last_call = nil
        lambda do |*args|
          last_call = Time.now
          sleep(delay)
          block.call(*args) if Time.now - last_call >= delay
        end
      end
    end

    # Throttle a block
    def self.throttle(interval)
      lambda do |&block|
        last_call = 0
        lambda do |*args|
          now = Time.now
          if now - last_call >= interval
            last_call = now
            block.call(*args)
          end
        end
      end
    end
  end
end