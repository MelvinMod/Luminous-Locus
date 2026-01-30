/*
 * Luminous Locus Asset Server Module
 * Static asset serving
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #include <windows.h>
    #define close closesocket
#else
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
#endif
#include "model.h"

/* Asset server state */
struct AssetServer {
    int Port;
    int Socket;
    bool Running;
};

/* Create new asset server */
AssetServer* asset_server_create(int port) {
    AssetServer* server = (AssetServer*)malloc(sizeof(AssetServer));
    if (server == NULL) {
        return NULL;
    }
    memset(server, 0, sizeof(AssetServer));
    server->Port = port;
    server->Socket = -1;
    server->Running = false;
    return server;
}

/* Free asset server */
void asset_server_free(AssetServer* server) {
    if (server != NULL) {
        asset_server_stop(server);
        free(server);
    }
}

/* Start asset server */
bool asset_server_start(AssetServer* server) {
    if (server == NULL) {
        return false;
    }

    /* Create socket */
    server->Socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server->Socket < 0) {
        return false;
    }

    /* Set socket options */
    int opt = 1;
    if (setsockopt(server->Socket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        close(server->Socket);
        server->Socket = -1;
        return false;
    }

    /* Bind socket */
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(server->Port);

    if (bind(server->Socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(server->Socket);
        server->Socket = -1;
        return false;
    }

    /* Listen for connections */
    if (listen(server->Socket, 5) < 0) {
        close(server->Socket);
        server->Socket = -1;
        return false;
    }

    server->Running = true;
    return true;
}

/* Stop asset server */
void asset_server_stop(AssetServer* server) {
    if (server != NULL && server->Socket >= 0) {
        close(server->Socket);
        server->Socket = -1;
        server->Running = false;
    }
}

/* Check if running */
bool asset_server_is_running(AssetServer* server) {
    return server != NULL && server->Running;
}

/* Get port */
int asset_server_get_port(AssetServer* server) {
    return server != NULL ? server->Port : 0;
}

/* Accept connection (non-blocking, returns -1 if no connection) */
int asset_server_accept(AssetServer* server) {
    if (server == NULL || server->Socket < 0) {
        return -1;
    }
    return accept(server->Socket, NULL, NULL);
}