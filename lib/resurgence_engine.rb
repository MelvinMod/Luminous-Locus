# ResurgenceEngine
# Main engine module
# 
# This is the main entry point for the game engine.
# It provides version info, error classes, and autoloads
# all engine components.

module ResurgenceEngine
  # Engine version
  VERSION = '1.0.0'
  
  # Build information
  BUILD_INFO = 'Ruby Edition'
  
  # Game name
  GAME_NAME = 'Luminous Locus'
  
  # List of creators
  CREATORS = ['MelvinSGjr (MelvinMod)', 'RikislavCheboksary']

  # Custom error classes
  class Error < StandardError; end
  class NotImplementedError < Error; end
  class ObjectNotFoundError < Error; end
  class InvalidStateError < Error; end

  # Autoload all engine components
  autoload :VERSION, 'resurgence_engine/version'
  autoload :Core, 'resurgence_engine/core/core'
  autoload :Object, 'resurgence_engine/core/object'
  autoload :Map, 'resurgence_engine/core/map'
  autoload :World, 'resurgence_engine/core/world'
  autoload :Position, 'resurgence_engine/core/position'
  autoload :Direction, 'resurgence_engine/core/direction'
  autoload :IdPtr, 'resurgence_engine/core/id_ptr'
  autoload :Factory, 'resurgence_engine/core/factory'
  autoload :FrameData, 'resurgence_engine/core/frame_data'
  autoload :VisibleLevels, 'resurgence_engine/core/visible_levels'

  autoload :Atmos, 'resurgence_engine/atmos/atmos'
  autoload :PhysicsEngine, 'resurgence_engine/physics/physics_engine'
  autoload :LosCalculator, 'resurgence_engine/core/los_calculator'

  autoload :MapObject, 'resurgence_engine/objects/map_object'
  autoload :Tile, 'resurgence_engine/objects/tile'
  autoload :Turf, 'resurgence_engine/objects/turf'
  autoload :Structure, 'resurgence_engine/objects/structure'
  autoload :Item, 'resurgence_engine/objects/item'
  autoload :Movable, 'resurgence_engine/objects/movable'
  autoload :Mob, 'resurgence_engine/objects/mob'

  autoload :Message, 'resurgence_engine/network/message'
  autoload :NetworkInterface, 'resurgence_engine/network/network_interface'
end

# Get the directory of this file
LIB_DIR = File.expand_path('..', __FILE__)

# Require core type definitions
require File.join(LIB_DIR, 'resurgence_engine/core/types')

# Require core components
require File.join(LIB_DIR, 'resurgence_engine/core/position')
require File.join(LIB_DIR, 'resurgence_engine/core/direction')
require File.join(LIB_DIR, 'resurgence_engine/core/id_ptr')
require File.join(LIB_DIR, 'resurgence_engine/core/object')
require File.join(LIB_DIR, 'resurgence_engine/core/factory')
require File.join(LIB_DIR, 'resurgence_engine/core/frame_data')
require File.join(LIB_DIR, 'resurgence_engine/core/los_calculator')
require File.join(LIB_DIR, 'resurgence_engine/core/map')
require File.join(LIB_DIR, 'resurgence_engine/core/world')
require File.join(LIB_DIR, 'resurgence_engine/core/core')

# Initialize EMPTY_VIEW now that Direction is loaded
ResurgenceEngine::Types::EMPTY_VIEW = ResurgenceEngine::Types::ViewInfo.new(
  icon: '',
  icon_state: '',
  dir: ResurgenceEngine::Direction::SOUTH,
  pixel_x: 0,
  pixel_y: 0,
  color: '#FFFFFF',
  alpha: 255
)

ruby launcher.rb