@echo off
REM Build.bat - Batch build script for Luminous Locus (Windows CMD)
REM Uses Rake for building (Ruby-based build system)
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

REM Check for Ruby
where ruby >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Ruby is not installed. Please install Ruby 3.0+
    exit /b 1
)

REM Check Ruby version
ruby --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Ruby version check failed
    exit /b 1
)

REM Check for Bundler
where bundle >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Bundler is not installed. Run 'gem install bundler'
    exit /b 1
)

REM Check for Rake
where rake >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Rake is not installed. Run 'gem install rake'
    exit /b 1
)

REM Create build directory
if not exist "%BUILD_DIR%" (
    echo %GREEN%[BUILD]%NC% Creating build directory...
    mkdir "%BUILD_DIR%" >nul 2>&1
)

REM Install dependencies
echo %GREEN%[BUILD]%NC% Installing Ruby dependencies...
bundle install

if %ERRORLEVEL% neq 0 (
    echo %RED%[ERROR]%NC% Failed to install dependencies
    exit /b 1
)

echo.
echo %GREEN%[BUILD]%NC% Ready to build!
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
echo   build-ruby  - Build Ruby gem only
echo.

REM Execute command
if "%COMMAND%"=="" (
    echo %GREEN%[BUILD]%NC% Ready. Run 'build.bat help' for available commands.
    exit /b 0
)

if "%COMMAND%"=="build" (
    echo %GREEN%[BUILD]%NC% Building everything...
    rake luminous_locus:build
    rake build
    exit /b 0
)

if "%COMMAND%"=="test" (
    echo %GREEN%[BUILD]%NC% Running tests...
    rake test
    exit /b 0
)

if "%COMMAND%"=="lint" (
    echo %GREEN%[BUILD]%NC% Running linter...
    rake lint
    exit /b 0
)

if "%COMMAND%"=="install" (
    echo %GREEN%[BUILD]%NC% Installing dependencies...
    bundle install
    exit /b 0
)

if "%COMMAND%"=="update" (
    echo %GREEN%[BUILD]%NC% Updating dependencies...
    bundle update
    exit /b 0
)

if "%COMMAND%"=="server" (
    echo %GREEN%[BUILD]%NC% Starting server...
    rake luminous_locus:run
    exit /b 0
)

if "%COMMAND%"=="client" (
    echo %GREEN%[BUILD]%NC% Starting client...
    ruby main.rb client --host localhost --port 8766
    exit /b 0
)

if "%COMMAND%"=="console" (
    echo %GREEN%[BUILD]%NC% Starting console...
    ruby main.rb console
    exit /b 0
)

if "%COMMAND%"=="clean" (
    echo %GREEN%[BUILD]%NC% Cleaning build directories...
    rake clean
    rmdir /s /q "%BUILD_DIR%" >nul 2>&1
    rmdir /s /q "cpath\src\luminous-locus-server\build" >nul 2>&1
    echo %GREEN%[BUILD]%NC% Build directories cleaned.
    exit /b 0
)

if "%COMMAND%"=="build-c" (
    echo %GREEN%[BUILD]%NC% Building C server only...
    rake luminous_locus:build
    exit /b 0
)

if "%COMMAND%"=="build-ruby" (
    echo %GREEN%[BUILD]%NC% Building Ruby gem...
    rake gem
    exit /b 0
)

if "%COMMAND%"=="help" (
    echo Luminous Locus Build Script (Windows CMD)
    echo Uses Rake for building (Ruby-based build system)
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
    echo   build-ruby  - Build Ruby gem only
    exit /b 0
)

echo %RED%[ERROR]%NC% Unknown command: %COMMAND%
echo Run 'build.bat help' for available commands.
exit /b 1