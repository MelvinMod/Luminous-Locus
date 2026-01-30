/*
 * Luminous Locus Client Module
 * Client state management
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include "model.h"
#include "telemetry.h"

/* Client states */
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

/* Client registry for managing multiple clients */
#define MAX_CLIENTS 256

struct ClientRegistry {
    int next_id;
    int count;
    struct Client* clients[MAX_CLIENTS];
};

/* Create new client registry */
ClientRegistry* client_registry_create(void) {
    ClientRegistry* reg = (ClientRegistry*)malloc(sizeof(ClientRegistry));
    if (reg == NULL) {
        return NULL;
    }
    memset(reg, 0, sizeof(ClientRegistry));
    return reg;
}

/* Free client registry */
void client_registry_free(ClientRegistry* reg) {
    if (reg != NULL) {
        for (int i = 0; i < MAX_CLIENTS; i++) {
            if (reg->clients[i] != NULL) {
                free(reg->clients[i]);
            }
        }
        free(reg);
    }
}

/* Register new client */
int client_registry_register(ClientRegistry* reg, const char* address, int port, const char* login, bool is_admin) {
    if (reg->count >= MAX_CLIENTS) {
        return -1;
    }

    struct Client* client = (struct Client*)malloc(sizeof(struct Client));
    if (client == NULL) {
        return -1;
    }

    memset(client, 0, sizeof(struct Client));
    client->ID = reg->next_id++;
    strncpy(client->Address, address, sizeof(client->Address) - 1);
    client->Port = port;
    strncpy(client->Login, login, sizeof(client->Login) - 1);
    client->IsAdmin = is_admin;
    client->State = CLIENT_CONNECTING;
    client->LastSeen = time(NULL);

    /* Find empty slot */
    for (int i = 0; i < MAX_CLIENTS; i++) {
        if (reg->clients[i] == NULL) {
            reg->clients[i] = client;
            reg->count++;
            return client->ID;
        }
    }

    free(client);
    return -1;
}

/* Remove client */
bool client_registry_remove(ClientRegistry* reg, int client_id) {
    for (int i = 0; i < MAX_CLIENTS; i++) {
        if (reg->clients[i] != NULL && reg->clients[i]->ID == client_id) {
            free(reg->clients[i]);
            reg->clients[i] = NULL;
            reg->count--;
            return true;
        }
    }
    return false;
}

/* Get client by ID */
struct Client* client_registry_get(ClientRegistry* reg, int client_id) {
    for (int i = 0; i < MAX_CLIENTS; i++) {
        if (reg->clients[i] != NULL && reg->clients[i]->ID == client_id) {
            return reg->clients[i];
        }
    }
    return NULL;
}

/* Get client count */
int client_registry_count(ClientRegistry* reg) {
    return reg->count;
}

/* Check if client is master */
bool client_is_master(struct Client* client) {
    return client != NULL && client->IsMaster;
}

/* Update client position */
void client_update_position(struct Client* client, float x, float y, float z) {
    if (client != NULL) {
        client->PositionX = x;
        client->PositionY = y;
        client->PositionZ = z;
    }
}

/* Mark client as active */
void client_mark_active(struct Client* client) {
    if (client != NULL) {
        client->LastSeen = time(NULL);
        client->State = CLIENT_ACTIVE;
    }
}