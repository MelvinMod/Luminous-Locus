/*
 * Luminous Locus Simple Client
 * A simple test client for the Luminous Locus server
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
    #define sleep Sleep
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
    #include <sys/select.h>
#endif

/* Configuration */
#define DEFAULT_HOST "127.0.0.1"
#define DEFAULT_PORT 8766

/* Message types for simple client */
enum SimpleMessageType {
    MSG_LOGIN,
    MSG_CHAT,
    MSG_EXIT
};

/* Send login message */
static bool send_login(int sock, const char* username, const char* password, bool is_guest) {
    char buffer[512];
    int len = snprintf(buffer, sizeof(buffer),
        "LOGIN|%s|%s|%d",
        username, password, is_guest ? 1 : 0);
    
    if (len < 0 || len >= (int)sizeof(buffer)) {
        return false;
    }
    
    return send(sock, buffer, len, 0) == len;
}

/* Send chat message */
static bool send_chat(int sock, const char* message) {
    char buffer[2048];
    int len = snprintf(buffer, sizeof(buffer), "CHAT|%s", message);
    
    if (len < 0 || len >= (int)sizeof(buffer)) {
        return false;
    }
    
    return send(sock, buffer, len, 0) == len;
}

/* Handle server response */
static void handle_response(const char* data, int len) {
    char buffer[2048];
    if (len >= (int)sizeof(buffer)) {
        len = sizeof(buffer) - 1;
    }
    memcpy(buffer, data, len);
    buffer[len] = '\0';
    
    printf("Server: %s\n", buffer);
}

/* Connect to server */
static int connect_to_server(const char* host, int port) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }
    
    struct sockaddr_in server;
    memset(&server, 0, sizeof(server));
    server.sin_family = AF_INET;
    server.sin_port = htons(port);
    
    if (inet_pton(AF_INET, host, &server.sin_addr) <= 0) {
        perror("inet_pton");
        close(sock);
        return -1;
    }
    
    if (connect(sock, (struct sockaddr*)&server, sizeof(server)) < 0) {
        perror("connect");
        close(sock);
        return -1;
    }
    
    return sock;
}

/* Main client loop */
static void client_loop(int sock) {
    fd_set read_fds;
    char buffer[4096];
    
    while (1) {
        FD_ZERO(&read_fds);
        FD_SET(STDIN_FILENO, &read_fds);
        FD_SET(sock, &read_fds);
        
        struct timeval timeout;
        timeout.tv_sec = 1;
        timeout.tv_usec = 0;
        
        int ready = select(sock + 1, &read_fds, NULL, NULL, &timeout);
        if (ready < 0) {
            perror("select");
            break;
        }
        
        if (FD_ISSET(sock, &read_fds)) {
            int n = recv(sock, buffer, sizeof(buffer) - 1, 0);
            if (n <= 0) {
                printf("Server disconnected\n");
                break;
            }
            buffer[n] = '\0';
            handle_response(buffer, n);
        }
        
        if (FD_ISSET(STDIN_FILENO, &read_fds)) {
            if (fgets(buffer, sizeof(buffer), stdin) != NULL) {
                /* Remove newline */
                buffer[strcspn(buffer, "\n")] = '\0';
                
                if (strcmp(buffer, "/exit") == 0) {
                    break;
                } else if (strncmp(buffer, "/msg ", 5) == 0) {
                    send_chat(sock, buffer + 5);
                } else {
                    send_chat(sock, buffer);
                }
            }
        }
    }
}

/* Print usage */
static void print_usage(const char* program) {
    printf("Usage: %s [options]\n", program);
    printf("Options:\n");
    printf("  -host <addr>  Server address (default: %s)\n", DEFAULT_HOST);
    printf("  -port <port>  Server port (default: %d)\n", DEFAULT_PORT);
    printf("  -user <name>  Username\n");
    printf("  -pass <pass>  Password\n");
    printf("  -guest       Connect as guest\n");
    printf("  -help        Show this help\n");
}

/* Main entry point */
int main(int argc, char* argv[]) {
    const char* host = DEFAULT_HOST;
    int port = DEFAULT_PORT;
    const char* username = "Player";
    const char* password = "";
    bool is_guest = false;
    
    /* Parse arguments */
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-host") == 0 && i + 1 < argc) {
            host = argv[++i];
        } else if (strcmp(argv[i], "-port") == 0 && i + 1 < argc) {
            port = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-user") == 0 && i + 1 < argc) {
            username = argv[++i];
        } else if (strcmp(argv[i], "-pass") == 0 && i + 1 < argc) {
            password = argv[++i];
        } else if (strcmp(argv[i], "-guest") == 0) {
            is_guest = true;
        } else if (strcmp(argv[i], "-help") == 0) {
            print_usage(argv[0]);
            return 0;
        }
    }
    
    printf("Luminous Locus Simple Client\n");
    printf("Connecting to %s:%d...\n", host, port);
    
    int sock = connect_to_server(host, port);
    if (sock < 0) {
        fprintf(stderr, "Failed to connect to server\n");
        return 1;
    }
    
    printf("Connected! Type messages to send, /exit to quit.\n");
    
    if (!send_login(sock, username, password, is_guest)) {
        fprintf(stderr, "Failed to send login\n");
        close(sock);
        return 1;
    }
    
    client_loop(sock);
    close(sock);
    
    return 0;
}