# Luminous Locus Server

## About This Project

I don't know how to create servers, but I rewrote the server from the **Griefly** game to **Luminous Locus**.

This is a C-based game server for the Luminous Locus game, originally ported from Go to C. The server handles:
- Client connections and authentication
- Game state management
- Tick-based game loop
- Message passing between clients
- Telemetry and metrics collection

## Conversion History

### Original Stack (Griefly)
- **Language**: Go (Golang)
- **Server**: Go-based game server
- **Build System**: CMake + Go modules

### Current Stack (Luminous Locus)
- **Language**: C (C11)
- **Server**: C-based game server
- **Build System**: Rake (Ruby)
- **Engine**: ResurgenceEngine (Ruby)

## Building the Server

### Prerequisites

- C compiler (gcc or clang)
- CMake 3.10+
- Ruby 3.0+ (for Rake build system)

### Build with Rake

```bash
# Build C server
rake luminous-locus:build

# Build with custom options
cd cpath/src/luminous-locus-server
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
```

### Build Manually

```bash
cd cpath/src/luminous-locus-server

# Create build directory
mkdir -p build
cd build

# Configure
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build .

# Run
./luminous-locus-server -port 8766
```

## Running the Server

### Default (port 8766)
```bash
./build/luminous-locus-server
```

### Custom Port
```bash
./build/luminous-locus-server -port 8080
```

### Asset Server
The asset server runs on port 8767 by default:
```bash
./build/luminous-locus-server -asset-port 8767
```

### Auto-restart
```bash
./build/luminous-locus-server -restart
```

## Server Options

```
-port <port>     Set server port (default: 8766)
-asset-port <p> Set asset server port (default: 8767)
-restart        Enable auto-restart
-help           Show help message
```

## Architecture

### Core Modules

| Module | Description |
|--------|-------------|
| `main.c` | Entry point, signal handling, main loop |
| `auth.c` | User authentication |
| `client.c` | Client management |
| `client_conn.c` | Connection handling |
| `message.c` | Message serialization |
| `model.c` | Data structures |
| `json_db.c` | User database |
| `telemetry.c` | Metrics collection |
| `assetserver.c` | Static asset serving |

### Message Types

- `MSGID_LOGIN` - Client login
- `MSGID_CHAT` - Chat messages
- `MSGID_HASH` - Game state hash
- `MSGID_NEWTICK` - New game tick
- `MSGID_INPUT` - Player input

## Project Structure

```
luminous-locus-server/
├── main.c              # Entry point
├── auth.c/h            # Authentication
├── client.c/h          # Client management
├── client_conn.c/h     # Connection handling
├── json_db.c/h         # User database
├── message.c/h         # Message handling
├── model.c/h           # Data structures
├── telemetry.c/h       # Metrics
├── assetserver.c/h     # Asset serving
├── server.c/h          # Server core
├── CMakeLists.txt      # Build configuration
├── Rakefile            # Ruby build tasks
└── db/
    └── auth.json       # User database
```

## Integration with Luminous Locus

This C server integrates with the main Luminous Locus game:

1. **Main Game**: Ruby-based ResurgenceEngine
2. **Server**: C-based game server (this project)
3. **Communication**: TCP socket messaging

### Connecting Clients

```c
// Connect to server
int sock = socket(AF_INET, SOCK_STREAM, 0);
connect(sock, (struct sockaddr*)&server, sizeof(server));

// Send login
send(sock, login_msg, strlen(login_msg), 0);

// Handle responses
recv(sock, buffer, sizeof(buffer), 0);
```

## Troubleshooting

### Connection Refused
- Check if server is running: `netstat -an | grep 8766`
- Verify port is not blocked by firewall

### Build Failures
- Ensure CMake 3.10+ is installed
- Check C compiler: `gcc --version`
- Verify all dependencies: `rake luminous-locus:check`

### Performance Issues
- Monitor with telemetry: `rake luminous-locus:telemetry`
- Check client count limits
- Review log files for errors

## License

This project is part of Luminous Locus, a 2D space station remake game.

## Credits

- Original Griefly server implementation
- Converted to C for Luminous Locus