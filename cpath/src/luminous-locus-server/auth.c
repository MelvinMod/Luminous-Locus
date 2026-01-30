/*
 * Luminous Locus Auth Module
 * Authentication and user management
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "model.h"
#include "json_db.h"

/* Guest info constant */
static const UserInfo GuestInfo = {
    .Login = "",
    .Passhash = "",
    .IsAdmin = false
};

/* Error codes */
const int ErrNotAuthenticated = -1;

/* Authenticate user against database */
int authenticate(json_db_t* db, const char* username, const char* passhash, bool is_guest, UserInfo* result) {
    if (is_guest) {
        /* Guest users get minimal info */
        memcpy(result, &GuestInfo, sizeof(UserInfo));
        return 0;
    }

    UserInfo* info = json_db_get_user(db, username);
    if (info == NULL) {
        return ErrNotAuthenticated;
    }

    if (strcmp(info->Passhash, passhash) != 0) {
        free(info);
        return ErrNotAuthenticated;
    }

    memcpy(result, info, sizeof(UserInfo));
    free(info);
    return 0;
}