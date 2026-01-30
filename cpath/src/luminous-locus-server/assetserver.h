/*
 * Luminous Locus Asset Server Header
 */

#ifndef ASSETSERVER_H
#define ASSETSERVER_H

#include <stdbool.h>

/* Asset server */
typedef struct AssetServer AssetServer;

/* Create server */
AssetServer* asset_server_create(int port);

/* Free server */
void asset_server_free(AssetServer* server);

/* Start/stop */
bool asset_server_start(AssetServer* server);
void asset_server_stop(AssetServer* server);

/* Status */
bool asset_server_is_running(AssetServer* server);
int asset_server_get_port(AssetServer* server);

/* Accept connection */
int asset_server_accept(AssetServer* server);

#endif /* ASSETSERVER_H */