/*
 * Luminous Locus Client Header
 */

#ifndef CLIENT_H
#define CLIENT_H

#include <stdbool.h>
#include "model.h"

/* Client state */
enum ClientState {
    CLIENT_DISCONNECTED,
    CLIENT_CONNECTING,
    CLIENT_LOGGED_IN,
    CLIENT_ACTIVE
};

/* Client structure */
struct Client {
    int ID;
    char Address[64];
    int Port;
    char Login[64];
    bool IsMaster;
    bool IsAdmin;
    enum ClientState State;
    time_t LastSeen;
    float PositionX;
    float PositionY;
    float PositionZ;
};

/* Client registry */
typedef struct ClientRegistry ClientRegistry;

/* Create registry */
ClientRegistry* client_registry_create(void);

/* Free registry */
void client_registry_free(ClientRegistry* reg);

/* Register new client */
int client_registry_register(ClientRegistry* reg, const char* address, int port, const char* login, bool is_admin);

/* Remove client */
bool client_registry_remove(ClientRegistry* reg, int client_id);

/* Get client by ID */
struct Client* client_registry_get(ClientRegistry* reg, int client_id);

/* Get client count */
int client_registry_count(ClientRegistry* reg);

/* Check if client is master */
bool client_is_master(struct Client* client);

/* Update client position */
void client_update_position(struct Client* client, float x, float y, float z);

/* Mark client as active */
void client_mark_active(struct Client* client);

#endif /* CLIENT_H */