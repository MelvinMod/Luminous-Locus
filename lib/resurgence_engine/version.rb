# frozen_string_literal: true

# ResurgenceEngine Version Information
#
# Used for "Luminous Locus" game
# Creators: MelvinSGjr (MelvinMod), RikislavCheboksary

module ResurgenceEngine
  VERSION = '1.0.0'
  VERSION_INFO = '1.0.0'

  # Engine build date
  BUILD_DATE = Time.now.utc.strftime('%Y-%m-%d')

  # Engine build time
  BUILD_TIME = Time.now.utc.strftime('%H:%M:%S')

  # Minimum Ruby version
  MIN_RUBY_VERSION = Gem::Version.new('3.0.0')

  # Current Ruby version
  CURRENT_RUBY_VERSION = Gem::Version.new(RUBY_VERSION)

  # Check Ruby version compatibility
  def self.ruby_compatible?
    CURRENT_RUBY_VERSION >= MIN_RUBY_VERSION
  end

  # Get engine info
  # @return [Hash]
  def self.info
    {
      name: 'ResurgenceEngine',
      version: VERSION,
      version_info: VERSION_INFO,
      game: GAME_NAME,
      creators: CREATORS,
      ruby_version: RUBY_VERSION,
      build_date: BUILD_DATE,
      build_time: BUILD_TIME,
      platform: RUBY_PLATFORM
    }
  end

  # String representation
  # @return [String]
  def self.to_s
    "#{GAME_NAME} - ResurgenceEngine v#{VERSION}"
  end
end