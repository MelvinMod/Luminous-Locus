# frozen_string_literal: true

# ResurgenceEngine - Ruby Game Engine
# A 2D game engine originally ported from C++ to Ruby
# Used for "Luminous Locus" game
#
# Creators: MelvinSGjr (MelvinMod), RikislavCheboksary

require 'rake/clean'
require 'pathname'

# Configuration
module ResurgenceEngine
  VERSION = '1.0.0'
  BUILD_DIR = Pathname.new('build')
  LIB_DIR = Pathname.new('lib')
  SRC_DIR = Pathname.new('sources')
  CPATH_SERVER_DIR = Pathname.new('cpath/src/luminous-locus-server')
  CPATH_BUILD_DIR = CPATH_SERVER_DIR + 'build'

  # Game information
  GAME_NAME = 'Luminous Locus'
  CREATORS = ['MelvinSGjr (MelvinMod)', 'RikislavCheboksary']
end

# Load all Ruby source files in order
SOURCE_FILES = Dir.glob('lib/**/*.rb').sort

# Import task dependencies
import 'tasks/dependencies.rake'
import 'tasks/tests.rake'
import 'tasks/assets.rake'
import 'tasks/docker.rake'
import 'tasks/c_server.rake'

# Default task
task default: %i[build test]

# Main build task
task build: :compile

# Compile Ruby sources (check syntax)
task :compile do
  puts 'Compiling Ruby sources...'
  SOURCE_FILES.each do |file|
    puts "  Checking: #{file}"
    result = `ruby -c #{file} 2>&1`
    puts result if $CHILD_STATUS != 0
    exit(1) unless $CHILD_STATUS == 0
  end
  puts 'Compilation successful!'
end

# Clean build artifacts
CLEAN.include(ResurgenceEngine::BUILD_DIR)

# Full clean including generated files
task clobber: :clean do
  puts 'Clobbering all generated files...'
end

# Show project structure
task :structure do
  puts "\n#{ResurgenceEngine::GAME_NAME} - ResurgenceEngine Structure:"
  puts '─' * 50
  puts 'lib/'
  puts '  resurgence_engine/  # Main engine module'
  puts '    core/             # Core engine classes'
  puts '    objects/          # Game objects (turfs, items, structures)'
  puts '    atmos/            # Atmospheric simulation'
  puts '    network/          # Networking and messaging'
  puts '    physics/          # Physics engine'
  puts '    utils/            # Utility modules'
  puts 'scripts/              # Ruby utility scripts'
  puts 'tests/                # Unit tests'
  puts 'config/               # Configuration files'
  puts
  puts "Created by: #{ResurgenceEngine::CREATORS.join(', ')}"
end

# Run linting
task :lint do
  puts 'Running RuboCop...'
  system('rubocop lib tests --display-cop-names') || true
end

# Generate documentation
task :docs do
  puts 'Generating YARD documentation...'
  system('yard doc lib/**/*.rb')
end

# Package gem
task :gem do
  require 'rubygems/package'
  require 'zlib'

  gem_file = "resurgence_engine-#{ResurgenceEngine::VERSION}.gem"
  spec = Gem::Specification.new do |s|
    s.name = 'resurgence_engine'
    s.version = ResurgenceEngine::VERSION
    s.summary = "#{ResurgenceEngine::GAME_NAME} - 2D Game Engine"
    s.authors = ResurgenceEngine::CREATORS
    s.files = Dir.glob('lib/**/*.rb')
    s.test_files = Dir.glob('tests/**/*.rb')
  end

  Gem::Package.build(spec)
  puts "Built gem: #{gem_file}"
end

# Install gem locally
task install: :gem do
  system("gem install #{ResurgenceEngine::BUILD_DIR}/resurgence_engine-#{ResurgenceEngine::VERSION}.gem")
end

# Release gem
task :release do
  require 'ruby_gem_tasks'

  Rake::Task['gem'].invoke
  system("gem push resurgence_engine-#{ResurgenceEngine::VERSION}.gem")
end

# Help task
task :help do
  puts "\n#{ResurgenceEngine::GAME_NAME} - ResurgenceEngine Rake Tasks"
  puts '─' * 50
  puts 'build          - Compile and build the project'
  puts 'test           - Run unit tests'
  puts 'lint           - Run RuboCop linter'
  puts 'docs           - Generate YARD documentation'
  puts 'gem            - Build Ruby gem'
  puts 'install        - Install gem locally'
  puts 'docker:build   - Build Docker image'
  puts 'docker:run     - Run in Docker container'
  puts 'clean          - Remove build artifacts'
  puts 'clobber        - Full clean'
  puts 'structure      - Show project structure'
  puts
  puts "Creators: #{ResurgenceEngine::CREATORS.join(', ')}"
end

desc 'Show all available tasks'
task :tasks do
  Rake::Task.tasks.each { |t| puts t }
end