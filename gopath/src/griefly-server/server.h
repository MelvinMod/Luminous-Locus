/*
 * ResurgenceEngine C Server Header
 * Main server header file
 * 
 * Contains function declarations and
 * type definitions for the server
 */

#ifndef RESURGENCE_SERVER_H
#define RESURGENCE_SERVER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>

/* Version info */
#define SERVER_VERSION "1.0.0"
#define SERVER_NAME "ResurgenceEngine C Server"

/* Error codes */
#define ERR_OK 0
#define ERR_SOCKET -1
#define ERR_BIND -2
#define ERR_LISTEN -3
#define ERR_ACCEPT -4
#define ERR_RECV -5
#define ERR_SEND -6

/* Forward declarations */
typedef struct server_state server_state_t;
typedef struct client client_t;
typedef struct message message_t;

/* Server state */
struct server_state {
    int listen_fd;
    int metrics_fd;
    char server_url[256];
    int tick_interval;
    char dumps_root[256];
    char db_root[256];
    bool running;
    time_t start_time;
};

/* Client state */
struct client {
    int fd;
    char address[64];
    int port;
    int state;
    char username[64];
    time_t last_activity;
    uint64_t bytes_received;
    uint64_t bytes_sent;
    float pos_x, pos_y, pos_z;
};

/* Message structure */
struct message {
    uint8_t type;
    uint32_t length;
    char* data;
};

/* Server functions */
int server_init(void);
int server_run(const char* listen_addr, int port);
void server_stop(void);
void server_broadcast(void* data, size_t length);
uint64_t server_uptime(void);
int server_client_count(void);

/* Client functions */
client_t* server_accept_client(int server_fd);
void server_process_client(client_t* client);
void handle_client_message(client_t* client, message_t* msg);

/* Utility functions */
void log_message(const char* format, ...);
void format_uptime(uint64_t seconds, char* buffer, size_t size);

#endif /* RESURGENCE_SERVER_H */