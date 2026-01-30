/*
 * Luminous Locus Server
 * Main server entry point
 *
 * A game server for Luminous Locus - a multiplayer game experience
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <signal.h>

#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #include <windows.h>
    #define close closesocket
#else
    #include <unistd.h>
    #include <sys/socket.h>
    #include <sys/select.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
#endif
#include "model.h"
#include "auth.h"
#include "client.h"
#include "telemetry.h"
#include "message.h"
#include "client_conn.h"
#include "json_db.h"
#include "assetserver.h"

/* Server configuration */
#define DEFAULT_PORT 8766
#define DEFAULT_ASSET_PORT 8767
#define SELECT_TIMEOUT_SEC 1

/* Global state */
static volatile sig_atomic_t g_running = 1;
static bool g_restart_requested = false;

/* Server state structure */
struct ServerState {
    int Port;
    int Socket;
    ClientRegistry* Clients;
    StatsCollector* Telemetry;
    AssetServer* AssetServer;
    json_db_t* DB;
    bool MasterIsHere;
};

/* Create new server state */
static ServerState* server_state_create(int port) {
    ServerState* state = (ServerState*)malloc(sizeof(ServerState));
    if (state == NULL) {
        return NULL;
    }

    memset(state, 0, sizeof(ServerState));
    state->Port = port;
    state->Clients = client_registry_create();
    state->Telemetry = stats_collector_create();
    state->DB = json_db_create(JSONDB_AUTH_FILE);
    state->AssetServer = asset_server_create(DEFAULT_ASSET_PORT);
    state->MasterIsHere = false;

    return state;
}

/* Free server state */
static void server_state_free(ServerState* state) {
    if (state != NULL) {
        if (state->Socket >= 0) {
            close(state->Socket);
        }
        client_registry_free(state->Clients);
        stats_collector_free(state->Telemetry);
        json_db_free(state->DB);
        asset_server_free(state->AssetServer);
        free(state);
    }
}

/* Signal handler */
static void signal_handler(int sig) {
    (void)sig;
    g_running = 0;
}

/* Initialize server socket */
static bool init_server_socket(int port, int* socket_out) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return false;
    }

    int opt = 1;
    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        close(sock);
        return false;
    }

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(port);

    if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(sock);
        return false;
    }

    if (listen(sock, 10) < 0) {
        close(sock);
        return false;
    }

    *socket_out = sock;
    return true;
}

/* Accept new connections */
static void accept_connections(ServerState* state) {
    struct sockaddr_in addr;
    socklen_t addrlen = sizeof(addr);

    int client_fd = accept(state->Socket, (struct sockaddr*)&addr, &addrlen);
    if (client_fd >= 0) {
        char addr_str[64];
        inet_ntop(AF_INET, &addr.sin_addr, addr_str, sizeof(addr_str));

        int client_id = client_registry_register(state->Clients, addr_str, ntohs(addr.sin_port), "", false);
        if (client_id >= 0) {
            stats_collector_add_client(state->Telemetry);
            printf("New connection from %s:%d (ID: %d)\n", addr_str, ntohs(addr.sin_port), client_id);
        } else {
            close(client_fd);
        }
    }
}

/* Process incoming messages */
static void process_messages(ServerState* state) {
    (void)state;
    /* Message processing logic would go here */
    /* This is where incoming messages would be handled */
}

/* Handle client disconnections */
static void handle_disconnections(ServerState* state) {
    (void)state;
    /* Disconnection handling would go here */
}

/* Main server loop */
static void server_loop(ServerState* state) {
    printf("Server started on port %d\n", state->Port);
    printf("Waiting for connections...\n");

    while (g_running) {
        /* Use select for multiplexing */
        fd_set read_fds;
        FD_ZERO(&read_fds);
        FD_SET(state->Socket, &read_fds);

        struct timeval timeout;
        timeout.tv_sec = SELECT_TIMEOUT_SEC;
        timeout.tv_usec = 0;

        int ready = select(state->Socket + 1, &read_fds, NULL, NULL, &timeout);
        if (ready > 0) {
            accept_connections(state);
        }

        /* Process messages and handle disconnections */
        process_messages(state);
        handle_disconnections(state);
    }

    if (g_restart_requested) {
        printf("Restarting server...\n");
    } else {
        printf("Server shutting down...\n");
    }
}

/* Print usage information */
static void print_usage(const char* program) {
    printf("Usage: %s [options]\n", program);
    printf("Options:\n");
    printf("  -port <port>     Set server port (default: %d)\n", DEFAULT_PORT);
    printf("  -asset-port <p> Set asset server port (default: %d)\n", DEFAULT_ASSET_PORT);
    printf("  -restart        Enable auto-restart\n");
    printf("  -help           Show this help message\n");
}

/* Main entry point */
int main(int argc, char* argv[]) {
    int port = DEFAULT_PORT;
    int asset_port = DEFAULT_ASSET_PORT;
    bool auto_restart = false;

    /* Parse arguments */
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-port") == 0 && i + 1 < argc) {
            port = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-asset-port") == 0 && i + 1 < argc) {
            asset_port = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-restart") == 0) {
            auto_restart = true;
        } else if (strcmp(argv[i], "-help") == 0) {
            print_usage(argv[0]);
            return 0;
        }
    }

    /* Set up signal handlers */
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    /* Create server state */
    ServerState* state = server_state_create(port);
    if (state == NULL) {
        fprintf(stderr, "Failed to create server state\n");
        return 1;
    }

    /* Initialize socket */
    if (!init_server_socket(port, &state->Socket)) {
        fprintf(stderr, "Failed to initialize server socket\n");
        server_state_free(state);
        return 1;
    }

    /* Start asset server */
    if (asset_port != 0) {
        asset_server_start(state->AssetServer);
    }

    /* Run main loop */
    server_loop(state);

    /* Clean up */
    server_state_free(state);

    /* Auto-restart if requested */
    if (auto_restart && g_restart_requested) {
        execvp(argv[0], argv);
    }

    return 0;
}