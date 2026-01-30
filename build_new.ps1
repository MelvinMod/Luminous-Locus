#!/usr/bin/env pwsh
# Luminous Locus Build Script (PowerShell)
# Uses Rake (Ruby) for building instead of CMake
# This script sets up the build environment and provides helpful commands

param(
    [Parameter(HelpMessage = "Command to execute")]
    [ValidateSet("build", "test", "lint", "install", "update", "server", "client", "console", "clean", "help", "build-c", "build-ruby", "info")]
    [string]$Command = ""
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildDir = Join-Path $ScriptDir "build"

# Colors for PowerShell
function Write-Status {
    param([string]$Message)
    Write-Host "[BUILD] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check for Ruby
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
    Write-Error "Ruby is not installed. Please install Ruby 3.0+"
    exit 1
}

# Check Ruby version
$RubyVersion = ruby --version
Write-Status "Using $RubyVersion"

# Check for Bundler
if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
    Write-Error "Bundler is not installed. Run 'gem install bundler'"
    exit 1
}

# Check for Rake
if (-not (Get-Command rake -ErrorAction SilentlyContinue)) {
    Write-Error "Rake is not installed. Run 'gem install rake'"
    exit 1
}

# Create build directory
if (-not (Test-Path $BuildDir)) {
    Write-Status "Creating build directory..."
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

# Install Ruby dependencies
Write-Status "Installing Ruby dependencies..."
bundle install

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install dependencies"
    exit 1
}

Write-Status "Ready to build!"
Write-Host ""
Write-Host "Available commands:"
Write-Host "  $PSCommandPath build        - Build the project (Ruby + C server)"
Write-Host "  $PSCommandPath test         - Run tests"
Write-Host "  $PSCommandPath lint         - Run linter"
Write-Host "  $PSCommandPath install      - Install dependencies"
Write-Host "  $PSCommandPath update       - Update dependencies"
Write-Host "  $PSCommandPath server       - Start game server"
Write-Host "  $PSCommandPath client       - Start game client"
Write-Host "  $PSCommandPath console      - Start interactive console"
Write-Host "  $PSCommandPath clean        - Clean build directory"
Write-Host "  $PSCommandPath help         - Show this help"
Write-Host "  $PSCommandPath build-c      - Build C server only"
Write-Host "  $PSCommandPath build-ruby   - Build Ruby gem only"
Write-Host "  $PSCommandPath info         - Show build information"
Write-Host ""

# Execute command if provided
switch ($Command) {
    "build" {
        Write-Status "Building everything..."
        rake luminous_locus:build
        rake build
    }
    "test" {
        Write-Status "Running tests..."
        rake test
    }
    "lint" {
        Write-Status "Running linter..."
        rake lint
    }
    "install" {
        Write-Status "Installing dependencies..."
        bundle install
    }
    "update" {
        Write-Status "Updating dependencies..."
        bundle update
    }
    "server" {
        Write-Status "Starting server..."
        rake luminous_locus:run
    }
    "client" {
        Write-Status "Starting client..."
        ruby main.rb client --host localhost --port 8766
    }
    "console" {
        Write-Status "Starting console..."
        ruby main.rb console
    }
    "clean" {
        Write-Status "Cleaning build directories..."
        rake clean
        if (Test-Path $BuildDir) {
            Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
        }
        $CServerBuildDir = Join-Path $ScriptDir "cpath/src/luminous-locus-server/build"
        if (Test-Path $CServerBuildDir) {
            Remove-Item -Recurse -Force $CServerBuildDir -ErrorAction SilentlyContinue
        }
        Write-Status "Build directories cleaned."
    }
    "build-c" {
        Write-Status "Building C server only..."
        rake luminous_locus:build
    }
    "build-ruby" {
        Write-Status "Building Ruby gem..."
        rake gem
    }
    "info" {
        Write-Host "Luminous Locus Build Script (PowerShell)"
        Write-Host ""
        Write-Host "Build System: Rake (Ruby)"
        Write-Host "C Compiler: Detected automatically (gcc/clang)"
        Write-Host "Server: luminous-locus-server (C)"
        Write-Host "Engine: ResurgenceEngine (Ruby)"
        Write-Host ""
        Write-Host "Configuration:"
        Write-Host "  Script Directory: $ScriptDir"
        Write-Host "  Build Directory: $BuildDir"
        Write-Host "  C Server Path: cpath/src/luminous-locus-server"
    }
    "help" {
        Write-Host "Luminous Locus Build Script (PowerShell)"
        Write-Host "Uses Rake for building (Ruby-based build system)"
        Write-Host ""
        Write-Host "Usage: $PSCommandPath [command]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  build       - Build everything (Ruby + C server)"
        Write-Host "  test        - Run test suite"
        Write-Host "  lint        - Run RuboCop linter"
        Write-Host "  install     - Install Ruby dependencies"
        Write-Host "  update      - Update Ruby dependencies"
        Write-Host "  server      - Start game server"
        Write-Host "  client      - Start game client"
        Write-Host "  console     - Start interactive console"
        Write-Host "  clean       - Remove build directory"
        Write-Host "  help        - Show this help"
        Write-Host "  build-c     - Build C server only"
        Write-Host "  build-ruby  - Build Ruby gem only"
        Write-Host "  info        - Show build information"
    }
    "" {
        Write-Status "Ready. Run '$PSCommandPath help' for available commands."
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Run '$PSCommandPath help' for available commands."
        exit 1
    }
}