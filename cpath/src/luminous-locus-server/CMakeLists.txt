cmake_minimum_required(VERSION 3.10)
project(LuminousLocusServer C)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Platform-specific settings
if(WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -D_WIN32_WINNT=0x0601")
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -pthread")
endif()

# Server source files - all modules combined
set(SERVER_SOURCES
    main.c
    auth.c
    auth.h
    client.c
    client.h
    client_conn.c
    client_conn.h
    json_db.c
    json_db.h
    message.c
    message.h
    model.c
    model.h
    telemetry.c
    telemetry.h
    assetserver.c
    assetserver.h
)

# Executable
add_executable(luminous-locus-server ${SERVER_SOURCES})

# Platform-specific linking
if(WIN32)
    target_link_libraries(luminous-locus-server ws2_32 mswsock iphlpapi)
else()
    target_link_libraries(luminous-locus-server pthread)
endif()

# Install targets
install(TARGETS luminous-locus-server
    RUNTIME DESTINATION bin
)

# Print configuration
message(STATUS "Luminous Locus Server configuration:")
message(STATUS "  C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
