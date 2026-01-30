/*
 * Luminous Locus JSON Database Module
 * User authentication storage
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "model.h"

/* Auth file name */
#define JSONDB_AUTH_FILE "auth.json"

/* JSON database structure */
struct json_db_t {
    /* User database - implemented as hash map simulation */
    void* users;
};

/* Create new JSON database */
json_db_t* json_db_create(const char* path) {
    json_db_t* db = (json_db_t*)malloc(sizeof(json_db_t));
    if (db == NULL) {
        return NULL;
    }
    memset(db, 0, sizeof(json_db_t));
    return db;
}

/* Free JSON database */
void json_db_free(json_db_t* db) {
    if (db != NULL) {
        free(db);
    }
}

/* Get user info from database */
UserInfo* json_db_get_user(json_db_t* db, const char* username) {
    /* TODO: Implement actual JSON parsing */
    /* For now, return NULL indicating user not found */
    (void)db;
    (void)username;
    return NULL;
}

/* Check if user is admin */
bool json_db_is_admin(json_db_t* db, const char* username) {
    UserInfo* info = json_db_get_user(db, username);
    if (info == NULL) {
        return false;
    }
    bool result = info->IsAdmin;
    free(info);
    return result;
}