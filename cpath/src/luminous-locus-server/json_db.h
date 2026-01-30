/*
 * Luminous Locus JSON Database Header
 */

#ifndef JSON_DB_H
#define JSON_DB_H

#include <stdbool.h>
#include "model.h"

/* JSON database handle */
typedef struct json_db_t json_db_t;

/* Create database from path */
json_db_t* json_db_create(const char* path);

/* Free database */
void json_db_free(json_db_t* db);

/* Get user info */
UserInfo* json_db_get_user(json_db_t* db, const char* username);

/* Check if user is admin */
bool json_db_is_admin(json_db_t* db, const char* username);

#endif /* JSON_DB_H */