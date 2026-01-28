# FindC.cmake - Find C compiler and tools
# 
# This module finds the C compiler and related tools.
# Replaces the previous FindGo.cmake functionality.
#
# This module defines:
#   C_EXECUTABLE - the C compiler
#   C_COMPILER_VERSION - the version of the C compiler
#   C_COMPILER_ID - the compiler identifier
#   C_PLATFORM_ID - the platform identifier

# Find the C compiler
find_program(C_EXECUTABLE
    NAMES gcc clang tcc
    HINTS
        ENV C_PATH
        ENV C_COMPILER_PATH
        /usr/bin
        /usr/local/bin
        /opt/local/bin
)

if(NOT C_EXECUTABLE)
    message(FATAL_ERROR "C compiler not found")
endif()

# Get compiler version
execute_process(
    COMMAND ${C_EXECUTABLE} --version
    OUTPUT_VARIABLE C_COMPILER_VERSION_RAW
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Extract version number
string(REGEX MATCHALL "[0-9]+\\.[0-9]+(\\.[0-9]+)?" C_COMPILER_VERSION "${C_COMPILER_VERSION_RAW}")
list(GET C_COMPILER_VERSION 0 C_COMPILER_VERSION)

# Identify compiler
if(C_COMPILER_VERSION_RAW MATCHES "clang")
    set(C_COMPILER_ID "Clang")
elseif(C_COMPILER_VERSION_RAW MATCHES "gcc")
    set(C_COMPILER_ID "GCC")
elseif(C_COMPILER_VERSION_RAW MATCHES "tcc")
    set(C_COMPILER_ID "TCC")
else()
    set(C_COMPILER_ID "Unknown")
endif()

# Platform identification
if(WIN32)
    set(C_PLATFORM_ID "Windows")
elseif(APPLE)
    set(C_PLATFORM_ID "macOS")
elseif(UNIX)
    if(EXISTS "/etc/alpine-release")
        set(C_PLATFORM_ID "Alpine")
    elseif(EXISTS "/etc/endeavourOS-release")
        set(C_PLATFORM_ID "EndeavourOS")
    else()
        set(C_PLATFORM_ID "Linux")
    endif()
else()
    set(C_PLATFORM_ID "Unknown")
endif()

# Mark as found
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(C
    REQUIRED_VARS
        C_EXECUTABLE
        C_COMPILER_VERSION
    VERSION_VAR
        C_COMPILER_VERSION
)

# Print status
if(C_FIND_QUIETLY)
    message(STATUS "C compiler: ${C_EXECUTABLE}")
    message(STATUS "C version: ${C_COMPILER_VERSION}")
    message(STATUS "C platform: ${C_PLATFORM_ID}")
endif()
