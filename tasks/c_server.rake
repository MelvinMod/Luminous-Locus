# frozen_string_literal: true

# C Server Build Tasks
# Rake tasks for building the luminous-locus-server C project

require 'pathname'
require 'fileutils'

module CServerBuild
  SERVER_DIR = Pathname.new('cpath/src/luminous-locus-server')
  BUILD_DIR = SERVER_DIR + 'build'
  EXECUTABLE = BUILD_DIR + 'luminous-locus-server'

  # C source files
  C_SOURCES = %w[
    main.c
    auth.c
    client.c
    client_conn.c
    json_db.c
    message.c
    model.c
    telemetry.c
    assetserver.c
  ].freeze

  C_HEADERS = %w[
    auth.h
    client.h
    client_conn.h
    json_db.h
    message.h
    model.h
    telemetry.h
    assetserver.h
    server.h
  ].freeze

  ALL_C_FILES = (C_SOURCES + C_HEADERS).freeze

  class << self
    def ensure_build_dir
      FileUtils.mkdir_p(BUILD_DIR)
    end

    def find_compiler
      # Try common C compilers
      compilers = %w[gcc clang cl tcc]
      compilers.each do |compiler|
        result = system("#{compiler} --version > /dev/null 2>&1")
        return compiler if result
      end
      'gcc' # Default to gcc
    end

    def compile_flags
      flags = '-Wall -Wextra -O2 -std=c11'
      flags += ' -pthread' unless RbConfig::CONFIG['host_os'].include?('win')
      flags
    end

    def link_flags
      flags = ''
      if RbConfig::CONFIG['host_os'].include?('win')
        flags = '-lws2_32 -lmswsock -liphlpapi'
      else
        flags = '-lpthread'
      end
      flags
    end

    def build_command
      compiler = find_compiler
      sources = C_SOURCES.map { |s| SERVER_DIR + s }.join(' ')
      "#{compiler} #{sources} -o #{EXECUTABLE} #{compile_flags} #{link_flags}"
    end

    def check_c_compiler
      system('gcc --version > /dev/null 2>&1') ||
        system('clang --version > /dev/null 2>&1') ||
        system('cl /? > /dev/null 2>&1')
    end
  end
end

namespace :luminous_locus do
  desc 'Check if C compiler is available'
  task :check_compiler do
    if CServerBuild.check_c_compiler
      puts '✓ C compiler found'
    else
      puts '✗ No C compiler found. Please install gcc or clang.'
      exit 1
    end
  end

  desc 'Build the C server'
  task build: :check_compiler do
    puts 'Building Luminous Locus C Server...'

    CServerBuild.ensure_build_dir

    command = CServerBuild.build_command
    puts "  Running: #{command}"

    result = system(command)
    if result
      puts "  ✓ Server built: #{CServerBuild::EXECUTABLE}"
    else
      puts '  ✗ Build failed'
      exit 1
    end
  end

  desc 'Clean C server build'
  task :clean do
    if CServerBuild::BUILD_DIR.exist?
      FileUtils.rm_rf(CServerBuild::BUILD_DIR)
      puts "Cleaned: #{CServerBuild::BUILD_DIR}"
    else
      puts 'Nothing to clean'
    end
  end

  desc 'Run C server (default port 8766)'
  task :run, [:port, :asset_port, :restart] do |t, args|
    port = args[:port] || 8766
    asset_port = args[:asset_port] || 8767
    restart = args[:restart] ? '-restart' : ''

    Rake::Task['luminous_locus:build'].invoke

    executable = CServerBuild::EXECUTABLE
    abort "Server not found: #{executable}" unless executable.exist?

    puts "Starting Luminous Locus server on port #{port}..."

    system("#{executable} -port #{port} -asset-port #{asset_port} #{restart}")
  end

  desc 'Build C server with CMake'
  task :cmake do
    CServerBuild.ensure_build_dir

    Dir.chdir(CServerBuild::BUILD_DIR) do
      system('cmake .. -DCMAKE_BUILD_TYPE=Release')
      system('cmake --build .')
    end

    puts "Server built: #{CServerBuild::EXECUTABLE}"
  end

  desc 'Show C server information'
  task :info do
    puts 'Luminous Locus C Server Information:'
    puts '─' * 40
    puts "Server directory: #{CServerBuild::SERVER_DIR}"
    puts "Build directory: #{CServerBuild::BUILD_DIR}"
    puts "Executable: #{CServerBuild::EXECUTABLE}"
    puts ''
    puts 'Source files:'
    CServerBuild::C_SOURCES.each { |f| puts "  - #{f}" }
    puts ''
    puts 'Header files:'
    CServerBuild::C_HEADERS.each { |f| puts "  - #{f}" }
  end

  desc 'List all C server files'
  task :files do
    puts 'C Server Source Files:'
    puts '─' * 40
    CServerBuild::ALL_C_FILES.each { |f| puts f }
  end
end

# Alias for shorter commands
namespace :ll do
  task build: 'luminous_locus:build'
  task clean: 'luminous_locus:clean'
  task run: 'luminous_locus:run'
  task info: 'luminous_locus:info'
  task files: 'luminous_locus:files'
end

# Update default task to include C server build
task default: %i[compile luminous_locus:build test]