/*
 * Luminous Locus Client Connection Module
 * Client connection handling
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>

#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #include <windows.h>
    #define close closesocket
#else
    #include <sys/types.h>
    #include <sys/socket.h>
#endif
#include "model.h"
#include "client.h"
#include "message.h"

/* Connection states */
enum ConnState {
    CONN_NEW,
    CONN_READING,
    CONN_CLOSED
};

/* Connection buffer */
#define BUFFER_SIZE 8192

struct Conn {
    int FD;
    enum ConnState State;
    char LastAddr[64];
    int LastPort;
    char Buffer[BUFFER_SIZE];
    size_t BufferUsed;
    bool IsMaster;
};

/* Create new connection */
Conn* conn_create(int fd) {
    Conn* conn = (Conn*)malloc(sizeof(Conn));
    if (conn == NULL) {
        return NULL;
    }
    memset(conn, 0, sizeof(Conn));
    conn->FD = fd;
    conn->State = CONN_NEW;
    conn->BufferUsed = 0;
    conn->IsMaster = false;
    return conn;
}

/* Free connection */
void conn_free(Conn* conn) {
    if (conn != NULL) {
        /* Close socket if still open */
        if (conn->FD >= 0) {
            close(conn->FD);
        }
        free(conn);
    }
}

/* Get file descriptor */
int conn_get_fd(Conn* conn) {
    return conn != NULL ? conn->FD : -1;
}

/* Check if connection is closed */
bool conn_is_closed(Conn* conn) {
    return conn == NULL || conn->State == CONN_CLOSED;
}

/* Mark connection as master */
void conn_set_master(Conn* conn, bool is_master) {
    if (conn != NULL) {
        conn->IsMaster = is_master;
    }
}

/* Check if connection is master */
bool conn_is_master(Conn* conn) {
    return conn != NULL && conn->IsMaster;
}

/* Update address info */
void conn_update_addr(Conn* conn, const char* addr, int port) {
    if (conn != NULL) {
        strncpy(conn->LastAddr, addr, sizeof(conn->LastAddr) - 1);
        conn->LastPort = port;
    }
}

/* Get last address */
const char* conn_get_addr(Conn* conn) {
    return conn != NULL ? conn->LastAddr : "";
}

/* Get last port */
int conn_get_port(Conn* conn) {
    return conn != NULL ? conn->LastPort : 0;
}

/* Add data to buffer */
size_t conn_add_buffer(Conn* conn, const char* data, size_t length) {
    if (conn == NULL || conn->BufferUsed + length > BUFFER_SIZE) {
        return 0;
    }
    memcpy(conn->Buffer + conn->BufferUsed, data, length);
    conn->BufferUsed += length;
    return length;
}

/* Get buffer data */
const char* conn_get_buffer(Conn* conn) {
    return conn != NULL ? conn->Buffer : NULL;
}

/* Get buffer used */
size_t conn_get_buffer_used(Conn* conn) {
    return conn != NULL ? conn->BufferUsed : 0;
}

/* Clear buffer */
void conn_clear_buffer(Conn* conn) {
    if (conn != NULL) {
        conn->BufferUsed = 0;
    }
}

/* Consume buffer data */
size_t conn_consume_buffer(Conn* conn, size_t amount) {
    if (conn == NULL || amount > conn->BufferUsed) {
        return 0;
    }
    memmove(conn->Buffer, conn->Buffer + amount, conn->BufferUsed - amount);
    conn->BufferUsed -= amount;
    return amount;
}