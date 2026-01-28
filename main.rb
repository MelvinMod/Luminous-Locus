# frozen_string_literal: true

#!/usr/bin/env ruby

# ResurgenceEngine - Main Entry Point
# For "Luminous Locus" game
#
# Creators: MelvinSGjr (MelvinMod), RikislavCheboksary

require_relative 'lib/resurgence_engine'

# Default command
COMMAND = ARGV.shift || 'server'

# Parse command line arguments
OPTIONS = {
  port: 8080,
  host: '127.0.0.1',
  width: 100,
  height: 100,
  depth: 1,
  tick_rate: 20,
  debug: false,
  load: nil,
  map: nil
}

# Parse options
while (arg = ARGV.shift)
  case arg
  when '--port', '-p'
    OPTIONS[:port] = ARGV.shift.to_i
  when '--host', '-h'
    OPTIONS[:host] = ARGV.shift
  when '--width', '-W'
    OPTIONS[:width] = ARGV.shift.to_i
  when '--height', '-H'
    OPTIONS[:height] = ARGV.shift.to_i
  when '--depth', '-D'
    OPTIONS[:depth] = ARGV.shift.to_i
  when '--tick-rate', '-t'
    OPTIONS[:tick_rate] = ARGV.shift.to_i
  when '--load', '-l'
    OPTIONS[:load] = ARGV.shift
  when '--map', '-m'
    OPTIONS[:map] = ARGV.shift
  when '--debug', '-d'
    OPTIONS[:debug] = true
  when '--help', '-?'
    show_help
    exit 0
  when '--version', '-v'
    show_version
    exit 0
  end
end

# Show help message
def show_help
  puts <<~HELP
    ResurgenceEngine for Luminous Locus
    Usage: ruby main.rb [command] [options]

    Commands:
      server     Start game server (default)
      client     Start game client
      editor     Start map editor
      test       Run unit tests
      bench      Run benchmarks
      console    Start interactive console

    Options:
      -p, --port PORT     Set server port (default: 8080)
      -h, --host HOST     Set server host (default: 127.0.0.1)
      -W, --width WIDTH   Set map width (default: 100)
      -H, --height HEIGHT  Set map height (default: 100)
      -D, --depth DEPTH    Set map depth (default: 1)
      -t, --tick-rate RATE Set tick rate (default: 20)
      -l, --load FILE      Load saved game from file
      -m, --map MAP        Load specific map
      -d, --debug          Enable debug mode
      -?, --help           Show this help
      -v, --version        Show version

    Examples:
      ruby main.rb server --port 3000
      ruby main.rb client --host localhost --port 3000
      ruby main.rb editor --width 50 --height 50
      ruby main.rb console

    Creators: MelvinSGjr (MelvinMod), RikislavCheboksary
  HELP
end

# Show version info
def show_version
  puts ResurgenceEngine.to_s
  puts "Ruby version: #{RUBY_VERSION}"
  puts "Platform: #{RUBY_PLATFORM}"
end

# Handle commands
case COMMAND
when 'server'
  puts "Starting #{ResurgenceEngine::GAME_NAME} server..."
  puts "Creators: #{ResurgenceEngine::CREATORS.join(', ')}"
  puts

  ResurgenceEngine::Core.init(
    width: OPTIONS[:width],
    height: OPTIONS[:height],
    depth: OPTIONS[:depth]
  )

  world = ResurgenceEngine::Core.world
  world.create_map('main', OPTIONS[:width], OPTIONS[:height], OPTIONS[:depth])

  puts "Map created: #{OPTIONS[:width]}x#{OPTIONS[:height]}x#{OPTIONS[:depth]}"
  puts "Starting server on #{OPTIONS[:host]}:#{OPTIONS[:port]}"
  puts

  if OPTIONS[:debug]
    puts 'Debug mode enabled'
    puts
    puts 'Entering interactive mode...'
    puts 'Type "exit" to quit'
    puts 'Type "help" for commands'
    puts

    # Interactive debug console
    require 'irb'
    IRB.setup(nil)
    IRB.conf[:PROMPT][:CUSTOM] = {
      PROMPT_I: "#{ResurgenceEngine::GAME_NAME} > ",
      PROMPT_S: "#{ResurgenceEngine::GAME_NAME}* ",
      PROMPT_N: "#{ResurgenceEngine::GAME_NAME} > ",
      RETURN: "=> %s\n"
    }
    IRB.conf[:PROMPT_MODE] = :CUSTOM

    ARGV.clear
    IRB.start
  else
    puts 'Press Ctrl+C to stop server'

    # Run main game loop
    ResurgenceEngine::Core.run do
      sleep(1.0 / OPTIONS[:tick_rate])
    end
  end

when 'client'
  puts "Starting #{ResurgenceEngine::GAME_NAME} client..."
  puts "Connecting to #{OPTIONS[:host]}:#{OPTIONS[:port]}"

  # TODO: Implement client connection
  puts 'Client mode not yet implemented'

when 'editor'
  puts "Starting #{ResurgenceEngine::GAME_NAME} map editor..."
  puts "Map size: #{OPTIONS[:width]}x#{OPTIONS[:height]}x#{OPTIONS[:depth]}"

  ResurgenceEngine::Core.init(
    width: OPTIONS[:width],
    height: OPTIONS[:height],
    depth: OPTIONS[:depth]
  )

  puts 'Editor mode not yet implemented'

when 'test'
  puts 'Running unit tests...'
  system('rake test')

when 'bench'
  puts 'Running benchmarks...'
  puts 'Benchmark mode not yet implemented'

when 'console'
  puts "Starting #{ResurgenceEngine::GAME_NAME} console..."
  puts 'Type "exit" to quit'

  require 'irb'
  IRB.setup(nil)

  puts "Loaded modules:"
  puts '  - ResurgenceEngine'
  puts '  - ResurgenceEngine::Core'
  puts '  - ResurgenceEngine::World'
  puts '  - ResurgenceEngine::Map'
  puts '  - ResurgenceEngine::Object'
  puts '  - ResurgenceEngine::Mob'
  puts '  - ResurgenceEngine::Item'
  puts

  ARGV.clear
  IRB.start

else
  puts "Unknown command: #{COMMAND}"
  puts "Run 'ruby main.rb --help' for usage information"
  exit 1
end