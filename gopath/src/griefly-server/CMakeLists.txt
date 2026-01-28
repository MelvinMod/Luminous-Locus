cmake_minimum_required(VERSION 3.10)
project(GrieflyServer C)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Platform-specific settings
if(WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -D_WIN32_WINNT=0x0601")
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -pthread")
endif()

# Server source files
set(SERVER_SOURCES
    server.c
    server.h
)

# Executable
add_executable(griefly-server ${SERVER_SOURCES})

# Platform-specific linking
if(WIN32)
    target_link_libraries(griefly-server ws2_32 mswsock iphlpapi)
else()
    target_link_libraries(griefly-server pthread)
endif()

# Install targets
install(TARGETS grieving-server
    RUNTIME DESTINATION bin
)

# Print configuration
message(STATUS "Griefly Server configuration:")
message(STATUS "  C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
