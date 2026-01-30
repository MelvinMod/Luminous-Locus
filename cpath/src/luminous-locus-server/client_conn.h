/*
 * Luminous Locus Client Connection Header
 */

#ifndef CLIENT_CONN_H
#define CLIENT_CONN_H

#include <stdbool.h>

/* Connection state */
enum ConnState {
    CONN_NEW,
    CONN_READING,
    CONN_CLOSED
};

/* Connection structure */
typedef struct Conn Conn;

/* Create connection */
Conn* conn_create(int fd);

/* Free connection */
void conn_free(Conn* conn);

/* Get file descriptor */
int conn_get_fd(Conn* conn);

/* Check if closed */
bool conn_is_closed(Conn* conn);

/* Master status */
void conn_set_master(Conn* conn, bool is_master);
bool conn_is_master(Conn* conn);

/* Address info */
void conn_update_addr(Conn* conn, const char* addr, int port);
const char* conn_get_addr(Conn* conn);
int conn_get_port(Conn* conn);

/* Buffer operations */
size_t conn_add_buffer(Conn* conn, const char* data, size_t length);
const char* conn_get_buffer(Conn* conn);
size_t conn_get_buffer_used(Conn* conn);
void conn_clear_buffer(Conn* conn);
size_t conn_consume_buffer(Conn* conn, size_t amount);

#endif /* CLIENT_CONN_H */