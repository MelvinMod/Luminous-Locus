# ResurgenceEngine Core Module
# Main game engine core functionality
# 
# Handles world initialization, map management,
# and main game loop

module ResurgenceEngine
  module Core
    # World instance
    @@world = nil
    
    # Initialization state
    @@initialized = false
    
    # Delta time for game loop
    @@delta = 0.0

    # Get current world
    def self.world
      @@world
    end

    # Set world instance
    def self.world=(value)
      @@world = value
    end

    # Check if engine is initialized
    def self.initialized
      @@initialized
    end

    # Set initialization state
    def self.initialized=(value)
      @@initialized = value
    end

    # Get delta time
    def self.delta
      @@delta
    end

    # Set delta time
    def self.delta=(value)
      @@delta = value
    end

    # Initialize engine
    def self.init(w = 100, h = 100, d = 1)
      @@world ||= World.new
      @@initialized = true
      @@delta = 0.0

      if @@world.all_maps.empty?
        @@world.create_map('main', w, h, d)
      end

      puts "#{GAME_NAME} initialized"
    end

    # Shutdown engine
    def self.shutdown
      @@world&.stop
      @@world&.clear
      @@world = nil
      @@initialized = false
      puts 'shutdown done'
    end

    # Get active map
    def self.map
      @@world&.active_map
    end

    # Create new map
    def self.create_map(name, w = 100, h = 100, d = 1)
      @@world&.create_map(name, w, h, d)
    end

    # Get object by id
    def self.get_object(id)
      @@world&.get_object_by_id(id)
    end

    # Get all objects of a class
    def self.get_all_objects(klass = Object)
      @@world&.get_all_objects(klass) || []
    end

    # Tick game world
    def self.tick(d)
      return unless @@initialized && @@world

      @@delta = d
      @@world.tick(d)
    end

    # Start game
    def self.start
      @@world&.start
    end

    # Stop game
    def self.stop
      @@world&.stop
    end

    # Run main game loop
    def self.run(fps = 60)
      start

      loop do
        t = Time.now
        yield if block_given?
        tick(1.0 / fps)

        s = [0, (1.0 / fps) - (Time.now - t)].max
        sleep(s) if s > 0
      end
    end

    # Quick setup for testing
    def self.quick_setup(w = 50, h = 50)
      init(w, h, 1)
      map
    end
  end
end
