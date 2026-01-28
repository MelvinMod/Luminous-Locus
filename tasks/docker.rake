# frozen_string_literal: true

require 'rake/tasklib'

namespace :docker do
  desc 'Build Docker image'
  task build: :environment do
    require 'resurgence_engine'

    image_name = 'luminous-locus'
    image_tag = ResurgenceEngine::VERSION

    puts "Building Docker image: #{image_name}:#{image_tag}"

    # Create Dockerfile if it doesn't exist
    dockerfile = <<~DOCKERFILE
      FROM ruby:3.2-slim

      LABEL maintainer="#{ResurgenceEngine::CREATORS.join(', ')}"
      LABEL description="#{ResurgenceEngine::GAME_NAME} - ResurgenceEngine"

      WORKDIR /app

      COPY Gemfile Gemfile.lock ./
      RUN bundle install

      COPY lib/ ./lib/
      COPY main.rb ./

      EXPOSE 8080

      CMD ["ruby", "main.rb"]
    DOCKERFILE

    File.write('Dockerfile', dockerfile)

    # Build the image
    system("docker build -t #{image_name}:#{image_tag} .")
    system("docker tag #{image_name}:#{image_tag} #{image_name}:latest")

    puts "Docker image built: #{image_name}:#{image_tag}"
  end

  desc 'Run in Docker container'
  task run: :environment do
    image_name = 'luminous-locus'
    port = ENV['PORT'] || 8080

    puts "Running #{image_name} in Docker on port #{port}"

    system("docker run -p #{port}:8080 #{image_name}:latest")
  end

  desc 'Stop Docker container'
  task stop: :environment do
    container_name = 'luminous-locus'
    puts "Stopping container: #{container_name}"
    system("docker stop #{container_name} 2>/dev/null || true")
  end

  desc 'Remove Docker image'
  task remove: :environment do
    image_name = 'luminous-locus'
    puts "Removing Docker image: #{image_name}"
    system("docker rmi #{image_name}:latest #{image_name}:latest 2>/dev/null || true")
  end

  desc 'Push Docker image to registry'
  task push: :environment do
    image_name = 'luminous-locus'
    registry = ENV['REGISTRY'] || 'docker.io'

    puts "Pushing #{image_name} to #{registry}/#{image_name}"
    system("docker tag #{image_name}:latest #{registry}/#{image_name}:latest")
    system("docker push #{registry}/#{image_name}:latest")
  end
end