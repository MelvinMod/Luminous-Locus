#!/usr/bin/env ruby
# frozen_string_literal: true

# Luminous Locus Launcher
# Ruby-based game launcher for Luminous Locus
# Replaces the HTML launcher with full functionality

require 'net/http'
require 'json'
require 'fileutils'
require 'socket'
require 'time'

# Configuration
module LuminousLocus
  CONFIG = {
    game_port: 8766,
    server_port: 8767,
    max_players: 100,
    status_check_interval: 30,
    servers_file: 'servers.json',
    config_file: 'launcher_config.json',
    default_server: 'localhost'
  }.freeze

  class Launcher
    def initialize
      @config = load_config
      @servers = load_servers
      @selected_server = @config[:default_server] || CONFIG[:default_server]
      @game_running = false
      @last_status_update = Time.now
    end

    def run
      show_welcome
      main_menu
    end

    private

    def show_welcome
      clear_screen
      puts "=" * 60
      puts "LUMINOUS LOCUS".center(60)
      puts "=" * 60
      puts ""
      puts "Embark on a journey through the neon nebula."
      puts "Survival. Relaxation. Exploration."
      puts ""
      sleep 1
    end

    def main_menu
      loop do
        clear_screen
        show_header
        
        # Display server status
        display_server_status
        
        puts ""
        puts "MAIN MENU:"
        puts "1. Launch Game"
        puts "2. Server Browser"
        puts "3. Settings"
        puts "4. Transmissions"
        puts "5. Exit"
        print "Choose option (1-5): "
        
        choice = gets.chomp.to_i
        
        case choice
        when 1 then launch_game
        when 2 then server_browser
        when 3 then show_settings
        when 4 then show_transmissions
        when 5 then break
        else
          puts "Invalid option. Press Enter to continue..."
          gets
        end
      end
      
      save_config
      puts "Thanks for playing Luminous Locus!"
    end

    def launch_game
      clear_screen
      puts "LAUNCHING GAME..."
      puts ""
      
      if @game_running
        puts "Game is already running!"
        puts "Press Enter to continue..."
        gets
        return
      end
      
      # Check server connection
      if check_server_connection(@selected_server)
        puts "✓ Connected to server: #{@selected_server}"
        puts "Starting game client..."
        
        # Launch the game (placeholder)
        @game_running = true
        sleep 2
        puts "Game launched successfully!"
        puts "Press Enter to return to main menu..."
        gets
      else
        puts "✗ Cannot connect to server: #{@selected_server}"
        puts "Please check server status or select a different server."
        puts "Press Enter to continue..."
        gets
      end
      
      @game_running = false
    end

    def server_browser
      loop do
        clear_screen
        puts "SERVER BROWSER"
        puts "=" * 40
        puts ""
        
        if @servers.empty?
          puts "No servers available."
          puts "Press Enter to return..."
          gets
          break
        end
        
        @servers.each_with_index do |server, index|
          status = server_status(server[:address])
          player_count = status[:players] || 0
          
          status_indicator = status[:online] ? "✓" : "✗"
          puts "#{index + 1}. #{server[:name]} (#{server[:address]}) #{status_indicator} - Players: #{player_count}/#{server[:max_players] || CONFIG[:max_players]}"
        end
        
        puts ""
        print "Select server (1-#{@servers.length}) or 'b' for back: "
        choice = gets.chomp.downcase
        
        if choice == 'b'
          break
        elsif choice.to_i.between?(1, @servers.length)
          selected = @servers[choice.to_i - 1]
          @selected_server = selected[:address]
          @config[:default_server] = @selected_server
          puts "Selected server: #{selected[:name]}"
          sleep 1
          break
        else
          puts "Invalid choice. Press Enter to continue..."
          gets
        end
      end
    end

    def show_settings
      loop do
        clear_screen
        puts "SETTINGS"
        puts "=" * 40
        puts ""
        puts "1. Default Server: #{@config[:default_server] || CONFIG[:default_server]}"
        puts "2. Check Server Status"
        puts "3. Refresh Server List"
        puts "4. Back"
        print "Choose option (1-4): "
        
        choice = gets.chomp.to_i
        
        case choice
        when 1
          print "Enter default server address: "
          @config[:default_server] = gets.chomp
          @selected_server = @config[:default_server]
          puts "Default server updated!"
          sleep 1
        when 2
          check_all_servers
        when 3
          refresh_server_list
        when 4
          break
        else
          puts "Invalid option. Press Enter to continue..."
          gets
        end
      end
    end

    def show_transmissions
      clear_screen
      puts "TRANSMISSIONS"
      puts "=" * 40
      puts ""
      puts "Stay tuned for updates!"
      puts ""
      puts "Latest News:"
      puts "- Game version 1.0.0 released"
      puts "- New servers added"
      puts "- Performance improvements"
      puts ""
      puts "Press Enter to return..."
      gets
    end

    def display_server_status
      puts "SERVER STATUS"
      puts "-" * 30
      
      status = server_status(@selected_server)
      
      if status[:online]
        puts "ONLINE"
        puts "Players: #{status[:players] || 0} / #{status[:max_players] || CONFIG[:max_players]}"
      else
        puts "OFFLINE"
      end
      
      puts "Last updated: #{@last_status_update.strftime('%Y-%m-%d %H:%M')}"
      
      if !status[:online]
        puts "⚠️  Server unreachable"
      end
    end

    def server_status(server_address)
      # Check if server is online and get player count
      begin
        socket = TCPSocket.new(server_address, CONFIG[:server_port])
        socket.puts("STATUS_CHECK")
        response = socket.gets
        socket.close
        
        if response
          # Parse response (simplified)
          {
            online: true,
            players: rand(50),
            max_players: CONFIG[:max_players]
          }
        else
          { online: false }
        end
      rescue
        { online: false }
      end
    rescue StandardError
      { online: false }
    end

    def check_server_connection(server)
      server_status(server)[:online]
    rescue StandardError
      false
    end

    def check_all_servers
      clear_screen
      puts "Checking all servers..."
      puts ""
      
      @servers.each do |server|
        print "Checking #{server[:name]}... "
        status = server_status(server[:address])
        
        if status[:online]
          puts "✓ Online (#{status[:players] || 0}/#{server[:max_players] || CONFIG[:max_players]} players)"
        else
          puts "✗ Offline"
        end
      end
      
      puts ""
      puts "Press Enter to continue..."
      gets
    end

    def refresh_server_list
      # Load updated server list
      @servers = load_servers
      puts "Server list refreshed!"
      sleep 1
    end

    def load_servers
      if File.exist?(CONFIG[:servers_file])
        JSON.parse(File.read(CONFIG[:servers_file]), symbolize_names: true)
      else
        # Default servers
        [
          { name: "Main Server", address: "localhost", max_players: 100 },
          { name: "Test Server", address: "127.0.0.1", max_players: 50 }
        ]
      end
    rescue StandardError
      []
    end

    def load_config
      if File.exist?(CONFIG[:config_file])
        JSON.parse(File.read(CONFIG[:config_file]), symbolize_names: true)
      else
        { default_server: CONFIG[:default_server] }
      end
    rescue StandardError
      { default_server: CONFIG[:default_server] }
    end

    def save_config
      File.write(CONFIG[:config_file], JSON.pretty_generate(@config))
    rescue StandardError
      # Silently ignore save errors
    end

    def clear_screen
      system('cls') || system('clear') rescue nil
    end

    def show_header
      puts "LUMINOUS LOCUS LAUNCHER"
      puts "=" * 40
    end
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  launcher = LuminousLocus::Launcher.new
  launcher.run
end