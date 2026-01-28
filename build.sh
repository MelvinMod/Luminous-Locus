#!/bin/bash
# Build script for Luminous Locus
# This script sets up the CMake build directory and provides helpful commands

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

# Check for CMake
if ! command -v cmake &> /dev/null; then
    print_error "CMake is not installed. Please install CMake 3.16+"
    exit 1
fi

# Check CMake version
CMAKE_VERSION=$(cmake --version | head -n1 | cut -d' ' -f3)
if [ "$(printf '%s\n' "3.16" "$CMAKE_VERSION" | sort -V | head -n1)" != "3.16" ]; then
    print_error "CMake 3.16+ is required. Found: $CMAKE_VERSION"
    exit 1
fi

# Create build directory
if [ ! -d "$BUILD_DIR" ]; then
    print_status "Creating build directory..."
    mkdir -p "$BUILD_DIR"
fi

# Configure
print_status "Configuring project with CMake..."
cd "$BUILD_DIR"
cmake .. -DCMAKE_BUILD_TYPE=Release

print_status "Configuration complete!"
echo ""
echo "Available commands:"
echo "  ./build.sh build        - Build the project"
echo "  ./build.sh test         - Run tests"
echo "  ./build.sh lint         - Run linter"
echo "  ./build.sh install      - Install dependencies"
echo "  ./build.sh update       - Update dependencies"
echo "  ./build.sh server       - Start game server"
echo "  ./build.sh console      - Start console"
echo "  ./build.sh clean        - Clean build directory"
echo "  ./build.sh help         - Show this help"
echo ""

# Run command if provided
case "${1:-}" in
    build)
        print_status "Building..."
        cmake --build . --config Release
        ;;
    test)
        print_status "Running tests..."
        cmake --build . --target test
        ;;
    lint)
        print_status "Running linter..."
        cmake --build . --target lint
        ;;
    install)
        print_status "Installing dependencies..."
        cmake --build . --target install-deps
        ;;
    update)
        print_status "Updating dependencies..."
        cmake --build . --target update-deps
        ;;
    server)
        print_status "Starting server..."
        cmake --build . --target server
        ;;
    client)
        print_status "Starting client..."
        cmake --build . --target client
        ;;
    console)
        print_status "Starting console..."
        cmake --build . --target console
        ;;
    clean)
        print_status "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        print_status "Build directory cleaned."
        ;;
    help|--help|-h)
        echo "Luminous Locus Build Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  build     - Build the project"
        echo "  test      - Run test suite"
        echo "  lint      - Run RuboCop linter"
        echo "  install   - Install Ruby dependencies"
        echo "  update    - Update Ruby dependencies"
        echo "  server    - Start game server"
        echo "  console   - Start interactive console"
        echo "  clean     - Remove build directory"
        echo "  help      - Show this help"
        ;;
    "")
        print_status "Configuration complete. Run './build.sh help' for available commands."
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run './build.sh help' for available commands."
        exit 1
        ;;
esac