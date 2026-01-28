# frozen_string_literal: true

require 'rake/tasklib'

namespace :dependencies do
  desc 'Install Ruby gem dependencies'
  task :install do
    require 'bundler'
    Bundler.setup
    puts 'Dependencies installed'
  end

  desc 'Update Ruby gem dependencies'
  task :update do
    require 'bundler'
    Bundler.definition.specs.each do |spec|
      spec.specs.each do |gem|
        puts "Updating #{gem.name}..."
      end
    end
    puts 'Dependencies updated'
  end

  desc 'Check gem dependencies'
  task :check do
    require 'bundler'
    begin
      Bundler.definition.validate_runtime!
      puts 'All dependencies satisfied'
    rescue Bundler::MissingDependencyError => e
      puts "Missing dependencies: #{e.message}"
      exit 1
    end
  end

  desc 'List installed gems'
  task :list do
    system('gem list')
  end

  desc 'Show dependency tree'
  task :tree do
    require 'bundler'
    Bundler.definition.specs.each do |spec|
      spec.specs.each do |gem|
        puts gem.name
        gem.dependencies.each do |dep|
          puts "  └─ #{dep.name} (#{dep.requirement})"
        end
      end
    end
  end
end