# FindRuby.cmake
# Enhanced Ruby finder for Ruby-only projects
# This module provides comprehensive Ruby detection for CMake projects

#=============================================================================
# Copyright (c) 2024, Luminous Locus Contributors
#
# Distributed under the terms of the Mozilla Public License, v. 2.0.
# See LICENSE file for details.
#=============================================================================

# Find Ruby interpreter
# Check common locations first for better cross-platform support
if(WIN32)
    # Windows-specific paths (RubyInstaller)
    find_program(RUBY_EXECUTABLE
        NAMES ruby ruby.exe ruby3.0 ruby3.1 ruby3.2 ruby3.3
        HINTS
            ENV RUBY_ROOT
            ENV GEM_HOME
            ENV GEM_PATH
        PATHS
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
            "$ENV{ChocolateyInstall}/lib/ruby/current/bin"
    )
else()
    # Unix-like systems
    find_program(RUBY_EXECUTABLE
        NAMES ruby ruby3.0 ruby3.1 ruby3.2 ruby3.3
        HINTS
            ENV RUBY_ROOT
            ENV RBENV_ROOT
            ENV RVM_DIR
            ENV GEM_HOME
            ENV GEM_PATH
        PATHS
            /usr/local/bin
            /usr/bin
            /opt/homebrew/bin
            /opt/local/bin
            ~/rbenv/bin
            ~/.rbenv/bin
            ~/.rvm/bin
    )
endif()

# Get Ruby version
if(RUBY_EXECUTABLE)
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} --version
        OUTPUT_VARIABLE RUBY_VERSION_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Parse version (e.g., "ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]")
    if(RUBY_VERSION_OUTPUT MATCHES "ruby ([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(RUBY_VERSION_STRING "${CMAKE_MATCH_1}")
        set(RUBY_VERSION_MAJOR "${CMAKE_MATCH_1}")
        string(REPLACE "." ";" VERSION_LIST ${RUBY_VERSION_MAJOR})
        list(LENGTH VERSION_LIST VERSION_LIST_LENGTH)
        if(VERSION_LIST_LENGTH GREATER 1)
            list(GET VERSION_LIST 0 RUBY_VERSION_MAJOR)
            list(GET VERSION_LIST 1 RUBY_VERSION_MINOR)
        else()
            set(RUBY_VERSION_MINOR 0)
        endif()
        set(RUBY_VERSION "${RUBY_VERSION_MAJOR}.${RUBY_VERSION_MINOR}")
    endif()

    # Get Ruby platform
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['arch']"
        OUTPUT_VARIABLE RUBY_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get Ruby prefix
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['prefix']"
        OUTPUT_VARIABLE RUBY_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get Ruby libdir
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['libdir']"
        OUTPUT_VARIABLE RUBY_LIBRARY_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get Ruby sitelibdir
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['sitelibdir']"
        OUTPUT_VARIABLE RUBY_SITE_LIB_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get Ruby vendordir
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['vendordir']"
        OUTPUT_VARIABLE RUBY_VENDOR_LIB_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get Ruby bindir
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print RbConfig::CONFIG['bindir']"
        OUTPUT_VARIABLE RUBY_BIN_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get include directories
    set(RUBY_INCLUDE_DIRS
        "${RUBY_PREFIX}/include/${RUBY_ARCH}"
        "${RUBY_PREFIX}/include"
    )

    # Check for gems directory
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} -e "print Gem.default_dir"
        OUTPUT_VARIABLE RUBY_GEM_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

# Find Bundler
find_program(BUNDLE_EXECUTABLE
    NAMES bundle bundle.exe
    HINTS
        ENV BUNDLE_PATH
        PATH_SUFFIXES bin
)

# Find Gem executable
find_program(GEM_EXECUTABLE
    NAMES gem gem.exe
    HINTS
        PATH_SUFFIXES bin
)

# Find Rake
find_program(RAKE_EXECUTABLE
    NAMES rake rake.exe
    HINTS
        ENV RAKE_PATH
        PATH_SUFFIXES bin
)

include(FindPackageHandleStandardArgs)

# Handle standard arguments
find_package_handle_standard_args(Ruby
    REQUIRED_VARS
        RUBY_EXECUTABLE
        RUBY_VERSION
    VERSION_VAR RUBY_VERSION_STRING
)

# Mark as advanced
mark_as_advanced(
    RUBY_EXECUTABLE
    BUNDLE_EXECUTABLE
    GEM_EXECUTABLE
    RAKE_EXECUTABLE
)

# Print results
if(Ruby_FOUND)
    message(STATUS "Ruby found: ${RUBY_EXECUTABLE}")
    message(STATUS "  Version: ${RUBY_VERSION_STRING}")
    message(STATUS "  Arch: ${RUBY_ARCH}")
    message(STATUS "  Prefix: ${RUBY_PREFIX}")
    message(STATUS "  Library dir: ${RUBY_LIBRARY_DIR}")
    message(STATUS "  Site lib dir: ${RUBY_SITE_LIB_DIR}")
    message(STATUS "  Gem dir: ${RUBY_GEM_DIR}")
    if(BUNDLE_EXECUTABLE)
        message(STATUS "  Bundler: ${BUNDLE_EXECUTABLE}")
    endif()
    if(RAKE_EXECUTABLE)
        message(STATUS "  Rake: ${RAKE_EXECUTABLE}")
    endif()
else()
    message(FATAL_ERROR "Ruby 3.0+ not found. Please install Ruby from https://www.ruby-lang.org/")
endif()
