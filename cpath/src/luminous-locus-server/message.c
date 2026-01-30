/*
 * Luminous Locus Message Module
 * Message handling and serialization
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "model.h"

/* Max message length */
#define MAX_MESSAGE_LENGTH (1 * 1024 * 1024)  /* 1 MB */

/* Empty message for 0-length messages */
static MessageInput emptyMessage = {0, ""};

/* Message envelope structure */
struct Envelope {
    void* Message;
    int Kind;
    int From;
};

/* Create new envelope */
Envelope* envelope_create(void* msg, int kind, int from) {
    Envelope* env = (Envelope*)malloc(sizeof(Envelope));
    if (env != NULL) {
        env->Message = msg;
        env->Kind = kind;
        env->From = from;
    }
    return env;
}

/* Free envelope */
void envelope_free(Envelope* env) {
    if (env != NULL) {
        /* Don't free message - caller owns it */
        free(env);
    }
}

/* Get concrete message based on kind */
void* get_concrete_message(int kind) {
    switch (kind) {
        case MSGID_INPUT:
            return malloc(sizeof(MessageInput));
        case MSGID_CHAT:
            return malloc(sizeof(MessageChat));
        case MSGID_LOGIN:
            return malloc(sizeof(MessageLogin));
        case MSGID_HASH:
            return malloc(sizeof(MessageHash));
        case MSGID_RESTART:
            return malloc(sizeof(MessageRestart));
        case MSGID_NEXTTICK:
            return malloc(sizeof(MessageNextTick));
        case MSGID_REQUESTHASH:
            return malloc(sizeof(MessageRequestHash));
        case MSGID_SUCCESSFULCONNECT:
            return malloc(sizeof(MessageSuccessfulConnect));
        case MSGID_MAPUPLOAD:
            return malloc(sizeof(MessageMapUpload));
        case MSGID_NEWTICK:
            return malloc(sizeof(MessageNewTick));
        case MSGID_NEWCLIENT:
            return malloc(sizeof(MessageNewClient));
        case MSGID_CURRENTCONNECTIONS:
            return malloc(sizeof(MessageCurrentConnections));
        case MSGID_ORDINARY:
            return malloc(sizeof(MessageOrdinary));
        case MSGID_JUSTMESSAGE:
            return malloc(sizeof(MessageJustMessage));
        case MSGID_GUI:
            return malloc(sizeof(MessageInput));  /* Reuse MessageInput */
        case MSGID_MOUSECLICK:
            return malloc(sizeof(MessageMouseClick));
        case MSGID_OOCMESSAGE:
            return malloc(sizeof(MessageOOC));
        case MSGID_PING:
            return malloc(sizeof(MessagePing));
        default:
            return NULL;
    }
}

/* Free concrete message */
void free_concrete_message(void* msg, int kind) {
    if (msg != NULL) {
        free(msg);
    }
}

/* Get max length for message kind */
int get_max_message_length(int kind) {
    /* Return default max length for unknown kinds */
    switch (kind) {
        case MSGID_CHAT:
        case MSGID_JUSTMESSAGE:
        case MSGID_OOCMESSAGE:
            return 4096;
        case MSGID_LOGIN:
            return 256;
        default:
            return MAX_MESSAGE_LENGTH;
    }
}

/* Create envelope helper */
Envelope* NewEnvelope(void* msg, int kind, int from) {
    return envelope_create(msg, kind, from);
}