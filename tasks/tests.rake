# frozen_string_literal: true

require 'rake/tasklib'

namespace :tests do
  desc 'Run all tests'
  task all: %i[unit integration]

  desc 'Run unit tests'
  task unit: :environment do
    require 'minitest/autorun'

    test_files = Dir.glob('tests/unit/**/*.rb').sort
    test_files.each { |file| require file }

    puts "\n#{'=' * 60}"
    puts 'Running Unit Tests'
    puts "#{'=' * 60}\n"

    Minitest.run
  end

  desc 'Run integration tests'
  task integration: :environment do
    require 'minitest/autorun'

    test_files = Dir.glob('tests/integration/**/*.rb').sort
    test_files.each { |file| require file }

    puts "\n#{'=' * 60}"
    puts 'Running Integration Tests'
    puts "#{'=' * 60}\n"

    Minitest.run
  end

  desc 'Run specific test file'
  task :file, [:path] do |_t, args|
    require 'minitest/autorun'
    require args[:path]

    puts "\n#{'=' * 60}"
    puts "Running: #{args[:path]}"
    puts "#{'=' * 60}\n"

    Minitest.run
  end

  desc 'Run tests with coverage'
  task coverage: :environment do
    require 'simplecov'

    SimpleCov.start do
      add_filter '/tests/'
      add_filter '/vendor/'
    end

    Rake::Task['tests:unit'].invoke
  end

  desc 'Show test summary'
  task summary: :environment do
    require 'minitest/autorun'

    test_files = Dir.glob('tests/unit/**/*.rb').sort
    test_count = 0
    file_count = 0

    test_files.each do |file|
      content = File.read(file)
      test_methods = content.scan(/def test_/).size
      next if test_methods.zero?

      test_count += test_methods
      file_count += 1
      puts "#{file}: #{test_methods} tests"
    end

    puts "\n#{'=' * 60}"
    puts "Total: #{test_count} tests in #{file_count} files"
    puts "#{'=' * 60}"
  end
end

task :environment do
  $LOAD_PATH.unshift(File.expand_path('lib', __dir__))
end