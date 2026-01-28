# Build.ps1 - PowerShell build script for Luminous Locus (Windows)
# Usage: .\build.ps1 [command]

param(
    [string]$Command = ""
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildDir = Join-Path $ScriptDir "build"

# Colors for PowerShell
$Green = [System.Console]::ForegroundColor = "Green"
$Yellow = [System.Console]::ForegroundColor = "Yellow"
$Red = [System.Console]::ForegroundColor = "Red"
$White = [System.Console]::ForegroundColor = "White"
$DarkCyan = [System.Console]::ForegroundColor = "DarkCyan"

function Write-Status {
    param([string]$Message)
    Write-Host "[BUILD] " -NoNewline -ForegroundColor $Green
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] " -NoNewline -ForegroundColor $Yellow
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] " -NoNewline -ForegroundColor $Red
    Write-Host $Message
}

function Write-Help {
    Write-Host "Luminous Locus Build Script (Windows)" -ForegroundColor $DarkCyan
    Write-Host ""
    Write-Host "Usage: .\$($MyInvocation.MyCommand.Name) [command]" -ForegroundColor $White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $DarkCyan
    Write-Host "  build     - Build the project"
    Write-Host "  test      - Run test suite"
    Write-Host "  lint      - Run RuboCop linter"
    Write-Host "  install   - Install Ruby dependencies"
    Write-Host "  update    - Update Ruby dependencies"
    Write-Host "  server    - Start game server"
    Write-Host "  client    - Start game client"
    Write-Host "  console   - Start interactive console"
    Write-Host "  clean     - Remove build directory"
    Write-Host "  help      - Show this help"
    Write-Host ""
}

# Check for CMake
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Error "CMake is not installed. Please install CMake 3.16+"
    exit 1
}

# Check CMake version
$CMAKE_VERSION = (cmake --version | Select-String -Pattern "cmake version" | ForEach-Object { $_ -replace "cmake version ", "" }).Split()[0]
if ([version]$CMAKE_VERSION -lt [version]"3.16") {
    Write-Error "CMake 3.16+ is required. Found: $CMAKE_VERSION"
    exit 1
}

# Create build directory
if (-not (Test-Path $BuildDir)) {
    Write-Status "Creating build directory..."
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
}

# Configure
Write-Status "Configuring project with CMake..."
Push-Location $BuildDir

try {
    cmake .. -DCMAKE_BUILD_TYPE=Release -G "Ninja"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "CMake configuration failed"
        exit 1
    }
} finally {
    Pop-Location
}

Write-Status "Configuration complete!"
Write-Host ""
Write-Host "Available commands:" -ForegroundColor $DarkCyan
Write-Host "  .\$($MyInvocation.MyCommand.Name) build        - Build the project"
Write-Host "  .\$($MyInvocation.MyCommand.Name) test         - Run tests"
Write-Host "  .\$($MyInvocation.MyCommand.Name) lint         - Run linter"
Write-Host "  .\$($MyInvocation.MyCommand.Name) install      - Install dependencies"
Write-Host "  .\$($MyInvocation.MyCommand.Name) update       - Update dependencies"
Write-Host "  .\$($MyInvocation.MyCommand.Name) server       - Start game server"
Write-Host "  .\$($MyInvocation.MyCommand.Name) client        - Start game client"
Write-Host "  .\$($MyInvocation.MyCommand.Name) console       - Start interactive console"
Write-Host "  .\$($MyInvocation.MyCommand.Name) clean         - Remove build directory"
Write-Host "  .\$($MyInvocation.MyCommand.Name) help          - Show this help"
Write-Host ""

# Execute command
switch ($Command.ToLower()) {
    "build" {
        Write-Status "Building..."
        cmake --build $BuildDir --config Release
    }
    "test" {
        Write-Status "Running tests..."
        cmake --build $BuildDir --target test
    }
    "lint" {
        Write-Status "Running linter..."
        cmake --build $BuildDir --target lint
    }
    "install" {
        Write-Status "Installing dependencies..."
        cmake --build $BuildDir --target install-deps
    }
    "update" {
        Write-Status "Updating dependencies..."
        cmake --build $BuildDir --target update-deps
    }
    "server" {
        Write-Status "Starting server..."
        cmake --build $BuildDir --target server
    }
    "client" {
        Write-Status "Starting client..."
        cmake --build $BuildDir --target client
    }
    "console" {
        Write-Status "Starting console..."
        cmake --build $BuildDir --target console
    }
    "clean" {
        Write-Status "Cleaning build directory..."
        Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
        Write-Status "Build directory cleaned."
    }
    "help" {
        Write-Help
    }
    "" {
        Write-Status "Configuration complete. Run '.\build.ps1 help' for available commands."
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Run '.\build.ps1 help' for available commands."
        exit 1
    }
}