# Luminous Locus - ResurgenceEngine

**Luminous Locus** is a 2D space station remake game powered by **ResurgenceEngine**, a pure Ruby game engine with C server support for multiplayer.

## Creators

- **[MelvinSGjr (MelvinMod)](https://github.com/MelvinMod)** - Lead Developer
- **[RikislavCheboksary](https://github.com/RikislavCheboksary)** - Game Helper

## Launcher that will be available soon
<img width="1290" height="858" alt="imagewewqe" src="https://github.com/user-attachments/assets/9cd1591b-e61a-4941-9527-ddcd31685726" />


## About

Luminous Locus is a space station simulation game where players explore, build, and survive in a detailed 2D environment. The game features:

- **Atmospheric Simulation**: Realistic gas mixtures, temperature, and pressure systems
- **Map Generation**: Hires static maps with realistic floor and sky variations
- **Entity System Architecture**: Coroutine-based entity systems for game objects like characters, mobs, items, and structures
- **Physics Simulation**: Dynamic gravity, bullets and particles
- **Dynamic Stellar Evolution**: Evolutionary algorithms for celestial bodies, including moon and planet systems
- **Interpretive Object System**: Validation of basic objects (trigs, tiles, blocks)
- **Physics Engine**: Collision detection, gravity, and projectile motion
- **Complex Object System**: Turfs, structures, items, and living mobs
- **Inventory Management**: Full item storage with containers and equipment slots
- **Multiplayer Ready**: Network architecture for multiplayer gameplay

## Installation

```bash
# Clone the repository
git clone https://github.com/MelvinMod/luminous-locus.git
cd luminous-locus

# Install dependencies
bundle install

# Run the game
ruby main.rb server --port 8080
```

## Quick Start

```ruby
require 'resurgence_engine'

# Initialize the engine
ResurgenceEngine::Core.init(width: 100, height: 100, depth: 1)

# Get the world and map
world = ResurgenceEngine::Core.world
map = ResurgenceEngine::Core.map

# Create a mob
mob = ResurgenceEngine::Mob.new(
  name: 'Player',
  position: ResurgenceEngine::Position[50, 50, 0]
)
mob.create_inventory
map.add_object(ResurgenceEngine::Position[50, 50, 0], mob)

# Start the game loop
ResurgenceEngine::Core.start

# Tick the world
loop do
  ResurgenceEngine::Core.tick(1.0 / 20)
  sleep(0.05)
end
```

## Commands

```bash
# Start server
ruby main.rb server --port 8080

# Start client
ruby main.rb client --host localhost --port 8080

# Map editor
ruby main.rb editor --width 100 --height 100

# Interactive console
ruby main.rb console

# Run tests
ruby main.rb test

# Show help
ruby main.rb --help
```

## Running Tests

```bash
# Run all tests
rake test

# Run unit tests only
rake test:unit

# Run integration tests
rake test:integration

# Run with coverage
rake test:coverage
```

## Building Docker Image

```bash
# Build Docker image
rake docker:build

# Run in Docker
rake docker:run

# Push to registry
rake docker:push
```

## Requirements

- Ruby 3.0.0 or higher
- Bundler

## Dependencies

All dependencies are managed through Bundler:

- `rake` - Build automation
- `minitest` - Testing framework
- `simplecov` - Code coverage
- `rubocop` - Code linting
- `yard` - Documentation
- `json` - JSON parsing

Install with: `bundle install`

## C Server

The project includes a C-based game server (`gopath/src/griefly-server/`) that can be used for multiplayer support.

### Build C Server

```bash
cd gopath/src/griefly-server
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

### C Server Features

- TCP/UDP network handling
- Multi-client support (up to 64 players)
- Tick-based game loop
- Metrics server on port 9095
- Client authentication
- Position synchronization
- Chat messaging

### C Server Command Line Options

```
--listen <addr>    Listen address (default: 0.0.0.0)
--port <port>      Port number (default: 1111)
--tick-interval <ms>  Tick interval in milliseconds (default: 100)
```

## Game Assets (`exec/`)

The `exec/` folder contains game assets:

- `exec/maps/` - Map files (.json)
- `exec/textures/` - Texture definitions
- `exec/sounds/` - Sound definitions
- `exec/scripts/` - Game scripts
- `exec/config/` - Configuration files

### Configuration Files

- `exec/config/game.json` - Game configuration
- `exec/maps/main.json` - Main game map
- `exec/maps/cave.json` - Cave map
- `exec/textures/textures.json` - Texture definitions
- `exec/sounds/sounds.json` - Sound definitions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `rake test:unit`
5. Run linter: `rake lint`
6. Submit a pull request

## License

This project is proprietary software. All rights reserved.

## Links

- **Game Repository**: https://github.com/MelvinMod/luminous-locus
- **Issues**: https://github.com/MelvinMod/luminous-locus/issues
