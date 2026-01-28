# CMakeLists.txt - Luminous Locus (Ruby Game with C Server)
# CMake minimum version
cmake_minimum_required(VERSION 3.16)

# Project definition
project(luminous-locus
    VERSION 0.1.0
    DESCRIPTION "A 2D space station remake game powered by ResurgenceEngine"
    LANGUAGES Ruby C
)

# Enable Ruby and C for the project
enable_language(Ruby)
enable_language(C)

# C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set C++ to NOT required (we're Ruby + C)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED OFF)
set(CMAKE_CXX_EXTENSIONS OFF)

# Export compile commands for IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Build options
option(BUILD_TESTS "Enable test suite" ON)
option(BUILD_DOCS "Generate documentation" OFF)

# Find Ruby (Ruby-only project)
find_package(Ruby 3.0 REQUIRED COMPONENTS interpreter)

# Print Ruby information
message(STATUS "Ruby executable: ${RUBY_EXECUTABLE}")
message(STATUS "Ruby version: ${RUBY_VERSION}")
message(STATUS "Ruby include dir: ${RUBY_INCLUDE_DIRS}")
message(STATUS "Ruby library dir: ${RUBY_LIBRARY_DIR}")

# Windows-specific paths for Ruby
if(WIN32)
    # On Windows, Ruby is typically installed via RubyInstaller
    # Try common installation paths
    if(NOT RUBY_EXECUTABLE)
        foreach(PATH IN ITEMS
            "C:/Ruby30-x64/bin"
            "C:/Ruby31-x64/bin"
            "C:/Ruby32-x64/bin"
            "C:/Ruby33-x64/bin"
            "C:/Program Files/Ruby/Ruby30-x64/bin"
            "C:/Program Files/Ruby/Ruby31-x64/bin"
            "C:/Program Files/Ruby/Ruby32-x64/bin"
            "C:/Program Files/Ruby/Ruby33-x64/bin"
            "$ENV{SystemDrive}/Ruby30-x64/bin"
            "$ENV{SystemDrive}/Ruby31-x64/bin"
            "$ENV{SystemDrive}/Ruby32-x64/bin"
            "$ENV{SystemDrive}/Ruby33-x64/bin"
        )
            if(EXISTS "${PATH}/ruby.exe")
                set(RUBY_EXECUTABLE "${PATH}/ruby.exe")
                message(STATUS "Found Ruby at: ${RUBY_EXECUTABLE}")
                break()
            endif()
        endforeach()
    endif()

    # Find Bundler in Ruby paths
    if(NOT BUNDLE_EXECUTABLE)
        get_filename_component(RUBY_BIN_DIR ${RUBY_EXECUTABLE} DIRECTORY)
        if(EXISTS "${RUBY_BIN_DIR}/bundle.exe")
            set(BUNDLE_EXECUTABLE "${RUBY_BIN_DIR}/bundle.exe")
            message(STATUS "Found Bundler at: ${BUNDLE_EXECUTABLE}")
        endif()
    endif()
endif()

# Set paths
set(RUBY_SCRIPT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(RUBY_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(RUBY_TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tests)
set(RUBY_BIN_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Find Bundler
find_program(BUNDLE_EXECUTABLE bundle REQUIRED)
message(STATUS "Bundler executable: ${BUNDLE_EXECUTABLE}")

# Custom targets

# Install dependencies
add_custom_target(install-deps
    COMMAND ${BUNDLE_EXECUTABLE} install
    COMMENT "Installing Ruby dependencies..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Run all tests
add_custom_target(test
    COMMAND ${RUBY_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/main.rb test
    COMMENT "Running test suite..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Run linter
add_custom_target(lint
    COMMAND ${BUNDLE_EXECUTABLE} exec rubocop
    COMMENT "Running linter..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Run the game server
add_custom_target(server
    COMMAND ${RUBY_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/main.rb server --port 8080
    COMMENT "Starting game server..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Run the game client
add_custom_target(client
    COMMAND ${RUBY_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/main.rb client --host localhost --port 8080
    COMMENT "Starting game client..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Interactive console
add_custom_target(console
    COMMAND ${RUBY_EXECUTABLE} -I${RUBY_LIB_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/main.rb console
    COMMENT "Starting interactive console..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Run bundle update
add_custom_target(update-deps
    COMMAND ${BUNDLE_EXECUTABLE} update
    COMMENT "Updating Ruby dependencies..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Documentation generation
if(BUILD_DOCS)
    find_program(YARD_EXECUTABLE yard)
    if(YARD_EXECUTABLE)
        add_custom_target(docs
            COMMAND ${YARD_EXECUTABLE} doc --output-dir ${CMAKE_CURRENT_SOURCE_DIR}/doc
            COMMENT "Generating documentation..."
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
    else()
        message(WARNING "Yard not found, documentation generation disabled")
    endif()
endif()

# CI/CD helper targets
add_custom_target(ci-test
    COMMAND ${BUNDLE_EXECUTABLE} exec rake test:unit
    COMMENT "Running CI tests..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(ci-lint
    COMMAND ${BUNDLE_EXECUTABLE} exec rubocop
    COMMENT "Running CI linter..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Default target
add_custom_target(run DEPENDS server)

# Help message
add_custom_target(help-config
    COMMAND @echo "Available targets:"
    @echo "  install-deps  - Install Ruby dependencies"
    @echo "  test          - Run test suite"
    @echo "  lint          - Run linter"
    @echo "  server        - Start game server"
    @echo "  client        - Start game client"
    @echo "  console       - Start interactive console"
    @echo "  update-deps   - Update Ruby dependencies"
    @echo "  docs          - Generate documentation"
    @echo "  run           - Run game server (default)"
    @echo "  ci-test       - Run CI tests"
    @echo "  ci-lint       - Run CI linter"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# ============================================================
# C Server Build (cpath/luminous-locus-server)
# ============================================================
# The C server can be built separately
# cd cpath/src/luminous-locus-server && mkdir build && cd build
# cmake .. && make

# Build C server if requested
option(BUILD_C_SERVER "Build the C-based game server" ON)

if(BUILD_C_SERVER AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cpath/src/luminous-locus-server/CMakeLists.txt")
    message(STATUS "C Server: Enabled")
    add_subdirectory(cpath/src/luminous-locus-server)
else()
    message(STATUS "C Server: Disabled")
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "=== Luminous Locus Configuration ===")
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "Ruby: ${RUBY_VERSION}")
message(STATUS "Bundler: ${BUNDLE_EXECUTABLE}")
message(STATUS "Tests: ${BUILD_TESTS}")
message(STATUS "Documentation: ${BUILD_DOCS}")
message(STATUS "C Server: ${BUILD_C_SERVER}")
message(STATUS "")
message(STATUS "Available targets: cmake --build build --target help-config")
message(STATUS "===================================")
