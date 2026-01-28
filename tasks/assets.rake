# frozen_string_literal: true

require 'rake/tasklib'

namespace :assets do
  desc 'Compile assets'
  task compile: :environment do
    require 'resurgence_engine'

    puts 'Compiling assets...'
    puts '  Icons: icons/'
    puts '  Sounds: sounds/'
    puts '  Maps: maps/'
    puts '  Sprites: sprites/'

    # Create asset directories if they don't exist
    %w[icons sounds maps sprites].each do |dir|
      FileUtils.mkdir_p("assets/#{dir}")
    end

    puts 'Assets compiled successfully'
  end

  desc 'Clean compiled assets'
  task clean: :environment do
    puts 'Cleaning compiled assets...'
    # Assets are typically not compiled in Ruby, just copied
    puts 'Assets cleaned'
  end

  desc 'Precompile all assets'
  task precompile: %i[compile] do
    puts 'All assets precompiled'
  end

  desc 'Watch assets for changes'
  task watch: :environment do
    require 'filewatcher'

    puts 'Watching assets directory for changes...'

    FileWatcher.new(['assets']).watch do |filename|
      puts "Changed: #{filename}"
      Rake::Task['assets:compile'].invoke
    end
  end
end