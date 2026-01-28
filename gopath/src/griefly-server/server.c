/*
 * ResurgenceEngine C Server
 * Main entry point for C-based game server
 * 
 * Features:
 * - TCP/UDP network handling
 * - Game state management
 * - Client connection handling
 * - Tick-based game loop
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <signal.h>

/* Server configuration */
#define DEFAULT_PORT 1111
#define DEFAULT_METRICS_PORT 9095
#define DEFAULT_SERVER_URL "http://localhost:8011/"
#define DEFAULT_TICK_INTERVAL 100
#define DEFAULT_MAX_CLIENTS 64
#define DEFAULT_DUMPS_ROOT "./dumps"
#define DEFAULT_DB_ROOT "./db"

/* Message types */
#define MSG_TYPE_POSITION 1
#define MSG_TYPE_CHAT 2
#define MSG_TYPE_ACTION 3
#define MSG_TYPE_PING 4
#define MSG_TYPE_PONG 5
#define MSG_TYPE_CONNECT 6
#define MSG_TYPE_DISCONNECT 7

/* Client states */
#define CLIENT_STATE_DISCONNECTED 0
#define CLIENT_STATE_CONNECTING 1
#define CLIENT_STATE_CONNECTED 2
#define CLIENT_STATE_AUTHENTICATED 3

/* Global server state */
typedef struct {
    int listen_fd;
    int metrics_fd;
    char server_url[256];
    int tick_interval;
    char dumps_root[256];
    char db_root[256];
    bool running;
    time_t start_time;
    pthread_mutex_t state_mutex;
} server_state_t;

/* Client structure */
typedef struct {
    int fd;
    char address[64];
    int port;
    int state;
    char username[64];
    time_t last_activity;
    uint64_t bytes_received;
    uint64_t bytes_sent;
    float pos_x, pos_y, pos_z;
    pthread_mutex_t client_mutex;
} client_t;

/* Message structure */
typedef struct {
    uint8_t type;
    uint32_t length;
    char* data;
} message_t;

/* Global state */
static server_state_t g_server;
static client_t* g_clients[DEFAULT_MAX_CLIENTS];
static int g_num_clients = 0;
static pthread_mutex_t g_clients_mutex = PTHREAD_MUTEX_INITIALIZER;

/* Initialize server state */
void server_init(void) {
    memset(&g_server, 0, sizeof(g_server));
    g_server.listen_fd = -1;
    g_server.metrics_fd = -1;
    g_server.tick_interval = DEFAULT_TICK_INTERVAL;
    g_server.running = false;
    g_server.start_time = time(NULL);
    strcpy(g_server.server_url, DEFAULT_SERVER_URL);
    strcpy(g_server.dumps_root, DEFAULT_DUMPS_ROOT);
    strcpy(g_server.db_root, DEFAULT_DB_ROOT);
    pthread_mutex_init(&g_server.state_mutex, NULL);
    
    for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
        g_clients[i] = NULL;
    }
}

/* Create TCP server socket */
int create_server_socket(int port) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        perror("socket");
        return -1;
    }
    
    int opt = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(port);
    
    if (bind(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        close(fd);
        return -1;
    }
    
    listen(fd, 10);
    return fd;
}

/* Accept new client connection */
client_t* server_accept_client(int server_fd) {
    struct sockaddr_in addr;
    socklen_t addrlen = sizeof(addr);
    
    int client_fd = accept(server_fd, (struct sockaddr*)&addr, &addrlen);
    if (client_fd < 0) {
        perror("accept");
        return NULL;
    }
    
    pthread_mutex_lock(&g_clients_mutex);
    
    /* Find empty slot */
    client_t* client = NULL;
    for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
        if (g_clients[i] == NULL) {
            client = malloc(sizeof(client_t));
            if (client) {
                memset(client, 0, sizeof(client_t));
                client->fd = client_fd;
                strcpy(client->address, inet_ntoa(addr.sin_addr));
                client->port = ntohs(addr.sin_port);
                client->state = CLIENT_STATE_CONNECTING;
                client->last_activity = time(NULL);
                pthread_mutex_init(&client->client_mutex, NULL);
                g_clients[i] = client;
                g_num_clients++;
            }
            break;
        }
    }
    
    pthread_mutex_unlock(&g_clients_mutex);
    return client;
}

/* Handle client message */
void handle_client_message(client_t* client, message_t* msg) {
    client->last_activity = time(NULL);
    
    switch (msg->type) {
        case MSG_TYPE_PING:
            /* Send pong response */
            message_t pong = { MSG_TYPE_PONG, 0, NULL };
            send(client->fd, &pong, sizeof(pong), 0);
            break;
            
        case MSG_TYPE_CHAT:
            /* Broadcast chat message */
            pthread_mutex_lock(&g_clients_mutex);
            for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
                if (g_clients[i] && g_clients[i]->state == CLIENT_STATE_AUTHENTICATED) {
                    send(g_clients[i]->fd, msg, sizeof(message_t) + msg->length, 0);
                }
            }
            pthread_mutex_unlock(&g_clients_mutex);
            break;
            
        case MSG_TYPE_POSITION:
            /* Update client position */
            memcpy(&client->pos_x, msg->data, sizeof(float));
            memcpy(&client->pos_y, msg->data + sizeof(float), sizeof(float));
            memcpy(&client->pos_z, msg->data + 2 * sizeof(float), sizeof(float));
            break;
    }
}

/* Process client */
void server_process_client(client_t* client) {
    char buffer[1024];
    ssize_t bytes = recv(client->fd, buffer, sizeof(buffer), 0);
    
    if (bytes <= 0) {
        /* Client disconnected */
        return;
    }
    
    client->bytes_received += bytes;
    client->last_activity = time(NULL);
    
    /* Parse message */
    message_t* msg = (message_t*)buffer;
    handle_client_message(client, msg);
}

/* Broadcast to all clients */
void server_broadcast(void* data, size_t length) {
    pthread_mutex_lock(&g_clients_mutex);
    for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
        if (g_clients[i] && g_clients[i]->state == CLIENT_STATE_AUTHENTICATED) {
            send(g_clients[i]->fd, data, length, 0);
        }
    }
    pthread_mutex_unlock(&g_clients_mutex);
}

/* Main server loop */
void server_run(const char* listen_addr, int port) {
    printf("Starting ResurgenceEngine C Server on %s:%d\n", listen_addr, port);
    
    g_server.listen_fd = create_server_socket(port);
    if (g_server.listen_fd < 0) {
        fprintf(stderr, "Failed to create server socket\n");
        return;
    }
    
    g_server.running = true;
    
    fd_set read_fds;
    int max_fd = g_server.listen_fd;
    
    while (g_server.running) {
        FD_ZERO(&read_fds);
        FD_SET(g_server.listen_fd, &read_fds);
        
        pthread_mutex_lock(&g_clients_mutex);
        for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
            if (g_clients[i]) {
                FD_SET(g_clients[i]->fd, &read_fds);
                if (g_clients[i]->fd > max_fd) {
                    max_fd = g_clients[i]->fd;
                }
            }
        }
        pthread_mutex_unlock(&g_clients_mutex);
        
        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 50000; /* 50ms timeout */
        
        int ret = select(max_fd + 1, &read_fds, NULL, NULL, &tv);
        if (ret < 0) {
            if (errno == EINTR) continue;
            perror("select");
            break;
        }
        
        if (FD_ISSET(g_server.listen_fd, &read_fds)) {
            client_t* client = server_accept_client(g_server.listen_fd);
            if (client) {
                printf("New client: %s:%d\n", client->address, client->port);
            }
        }
        
        pthread_mutex_lock(&g_clients_mutex);
        for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
            if (g_clients[i] && FD_ISSET(g_clients[i]->fd, &read_fds)) {
                server_process_client(g_clients[i]);
            }
        }
        pthread_mutex_unlock(&g_clients_mutex);
    }
}

/* Start metrics server */
void* metrics_server_thread(void* arg) {
    int port = *(int*)arg;
    g_server.metrics_fd = create_server_socket(port);
    
    if (g_server.metrics_fd >= 0) {
        printf("Metrics server listening on port %d\n", port);
    }
    
    return NULL;
}

/* Stop server */
void server_stop(void) {
    g_server.running = false;
    
    if (g_server.listen_fd >= 0) {
        close(g_server.listen_fd);
    }
    
    if (g_server.metrics_fd >= 0) {
        close(g_server.metrics_fd);
    }
    
    pthread_mutex_lock(&g_clients_mutex);
    for (int i = 0; i < DEFAULT_MAX_CLIENTS; i++) {
        if (g_clients[i]) {
            close(g_clients[i]->fd);
            pthread_mutex_destroy(&g_clients[i]->client_mutex);
            free(g_clients[i]);
            g_clients[i] = NULL;
        }
    }
    pthread_mutex_unlock(&g_clients_mutex);
    
    pthread_mutex_destroy(&g_server.state_mutex);
}

/* Get server uptime in seconds */
uint64_t server_uptime(void) {
    return time(NULL) - g_server.start_time;
}

/* Get number of connected clients */
int server_client_count(void) {
    return g_num_clients;
}

/* Main entry point */
int main(int argc, char* argv[]) {
    printf("ResurgenceEngine C Server\n");
    printf("========================\n\n");
    
    /* Parse arguments */
    int port = DEFAULT_PORT;
    const char* listen_addr = "0.0.0.0";
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--listen") == 0 && i + 1 < argc) {
            listen_addr = argv[++i];
        } else if (strcmp(argv[i], "--port") == 0 && i + 1 < argc) {
            port = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--tick-interval") == 0 && i + 1 < argc) {
            g_server.tick_interval = atoi(argv[++i]);
        }
    }
    
    /* Initialize server */
    server_init();
    
    /* Start metrics server thread */
    pthread_t metrics_thread;
    int metrics_port = DEFAULT_METRICS_PORT;
    pthread_create(&metrics_thread, NULL, metrics_server_thread, &metrics_port);
    
    /* Run main server loop */
    server_run(listen_addr, port);
    
    /* Cleanup */
    server_stop();
    
    return 0;
}