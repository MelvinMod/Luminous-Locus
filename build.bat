@echo off
REM Build.bat - Batch build script for Luminous Locus (Windows CMD)
REM Usage: build.bat [command]

setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%build"

REM Colors for batch
for /f %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RED=%ESC%[31m"
set "WHITE=%ESC%[37m"
set "DARKCYAN=%ESC%[36m"
set "NC=%ESC%[0m"

set "COMMAND=%~1"

REM Check for CMake
where cmake >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% CMake is not installed. Please install CMake 3.16+
    exit /b 1
)

REM Check CMake version (simplified check)
cmake --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% CMake version check failed
    exit /b 1
)

REM Create build directory
if not exist "%BUILD_DIR%" (
    echo %GREEN%[BUILD]%NC% Creating build directory...
    mkdir "%BUILD_DIR%" >nul 2>&1
)

REM Configure
echo %GREEN%[BUILD]%NC% Configuring project with CMake...
cd "%BUILD_DIR%"
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_C_SERVER=ON

if %ERRORLEVEL% neq 0 (
    echo %RED%[ERROR]%NC% CMake configuration failed
    exit /b 1
)

echo.
echo %GREEN%[BUILD]%NC% Configuration complete!
echo.
echo Available commands:
echo   build       - Build the project (Ruby + C server)
echo   test        - Run test suite
echo   lint        - Run RuboCop linter
echo   install     - Install Ruby dependencies
echo   update      - Update Ruby dependencies
echo   server      - Start game server
echo   client      - Start game client
echo   console     - Start interactive console
echo   clean       - Remove build directory
echo   help        - Show this help
echo   build-c     - Build C server only
echo.

REM Execute command
if "%COMMAND%"=="" (
    echo %GREEN%[BUILD]%NC% Configuration complete. Run 'build.bat help' for available commands.
    exit /b 0
)

if "%COMMAND%"=="build" (
    echo %GREEN%[BUILD]%NC% Building...
    cmake --build . --config Release
    exit /b 0
)

if "%COMMAND%"=="test" (
    echo %GREEN%[BUILD]%NC% Running tests...
    cmake --build . --target test
    exit /b 0
)

if "%COMMAND%"=="lint" (
    echo %GREEN%[BUILD]%NC% Running linter...
    cmake --build . --target lint
    exit /b 0
)

if "%COMMAND%"=="install" (
    echo %GREEN%[BUILD]%NC% Installing dependencies...
    cmake --build . --target install-deps
    exit /b 0
)

if "%COMMAND%"=="update" (
    echo %GREEN%[BUILD]%NC% Updating dependencies...
    cmake --build . --target update-deps
    exit /b 0
)

if "%COMMAND%"=="server" (
    echo %GREEN%[BUILD]%NC% Starting server...
    cmake --build . --target server
    exit /b 0
)

if "%COMMAND%"=="client" (
    echo %GREEN%[BUILD]%NC% Starting client...
    cmake --build . --target client
    exit /b 0
)

if "%COMMAND%"=="console" (
    echo %GREEN%[BUILD]%NC% Starting console...
    cmake --build . --target console
    exit /b 0
)

if "%COMMAND%"=="clean" (
    echo %GREEN%[BUILD]%NC% Cleaning build directory...
    rmdir /s /q "%BUILD_DIR%" >nul 2>&1
    echo %GREEN%[BUILD]%NC% Build directory cleaned.
    exit /b 0
)

if "%COMMAND%"=="build-c" (
    echo %GREEN%[BUILD]%NC% Building C server only...
    cd cpath\src\luminous-locus-server
    if not exist build_c mkdir build_c
    cd build_c
    cmake .. -DCMAKE_BUILD_TYPE=Release
    cmake --build .
    cd ..\..\..\..
    echo %GREEN%[BUILD]%NC% C server built successfully!
    exit /b 0
)

if "%COMMAND%"=="help" (
    echo Luminous Locus Build Script (Windows CMD)
    echo.
    echo Usage: build.bat [command]
    echo.
    echo Commands:
    echo   build       - Build the project (Ruby + C server)
    echo   test        - Run test suite
    echo   lint        - Run RuboCop linter
    echo   install     - Install Ruby dependencies
    echo   update      - Update Ruby dependencies
    echo   server      - Start game server
    echo   client      - Start game client
    echo   console     - Start interactive console
    echo   clean       - Remove build directory
    echo   help        - Show this help
    echo   build-c     - Build C server only
    exit /b 0
)

echo %RED%[ERROR]%NC% Unknown command: %COMMAND%
echo Run 'build.bat help' for available commands.
exit /b 1