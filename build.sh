#!/bin/bash
# Build script for Luminous Locus
# Uses Rake (Ruby) for building instead of CMake
# This script sets up the build environment and provides helpful commands

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for Ruby
if ! command -v ruby &> /dev/null; then
    print_error "Ruby is not installed. Please install Ruby 3.0+"
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby --version | cut -d' ' -f2)
print_status "Using Ruby $RUBY_VERSION"

# Check for Bundler
if ! command -v bundle &> /dev/null; then
    print_error "Bundler is not installed. Run 'gem install bundler'"
    exit 1
fi

# Check for Rake
if ! command -v rake &> /dev/null; then
    print_error "Rake is not installed. Run 'gem install rake'"
    exit 1
fi

# Install Ruby dependencies
print_status "Installing Ruby dependencies..."
bundle install

# Create build directory
if [ ! -d "$BUILD_DIR" ]; then
    print_status "Creating build directory..."
    mkdir -p "$BUILD_DIR"
fi

print_status "Ready to build!"
echo ""
echo "Available commands:"
echo "  $0 build        - Build the project (Ruby + C server)"
echo "  $0 test         - Run tests"
echo "  $0 lint         - Run linter"
echo "  $0 install      - Install dependencies"
echo "  $0 update       - Update dependencies"
echo "  $0 server       - Start game server"
echo "  $0 client       - Start game client"
echo "  $0 console      - Start interactive console"
echo "  $0 clean        - Clean build directory"
echo "  $0 help         - Show this help"
echo "  $0 build-c      - Build C server only"
echo "  $0 build-ruby   - Build Ruby gem only"
echo ""

# Run command if provided
case "${1:-}" in
    build)
        print_status "Building everything..."
        rake luminous_locus:build
        rake build
        ;;
    test)
        print_status "Running tests..."
        rake test
        ;;
    lint)
        print_status "Running linter..."
        rake lint
        ;;
    install)
        print_status "Installing dependencies..."
        bundle install
        ;;
    update)
        print_status "Updating dependencies..."
        bundle update
        ;;
    server)
        print_status "Starting server..."
        rake luminous_locus:run
        ;;
    client)
        print_status "Starting client..."
        ruby main.rb client --host localhost --port 8766
        ;;
    console)
        print_status "Starting console..."
        ruby main.rb console
        ;;
    clean)
        print_status "Cleaning build directories..."
        rake clean
        rm -rf "$BUILD_DIR"
        rm -rf "$SCRIPT_DIR/cpath/src/luminous-locus-server/build"
        print_status "Build directories cleaned."
        ;;
    build-c)
        print_status "Building C server only..."
        rake luminous_locus:build
        ;;
    build-ruby)
        print_status "Building Ruby gem..."
        rake gem
        ;;
    help|--help|-h)
        echo "Luminous Locus Build Script (Rake-based)"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  build       - Build everything (Ruby + C server)"
        echo "  test        - Run test suite"
        echo "  lint        - Run RuboCop linter"
        echo "  install     - Install Ruby dependencies"
        echo "  update      - Update Ruby dependencies"
        echo "  server      - Start game server"
        echo "  client      - Start game client"
        echo "  console     - Start interactive console"
        echo "  clean       - Remove build directory"
        echo "  help        - Show this help"
        echo "  build-c      - Build C server only"
        echo "  build-ruby   - Build Ruby gem only"
        ;;
    "")
        print_status "Ready. Run '$0 help' for available commands."
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run '$0 help' for available commands."
        exit 1
        ;;
esac