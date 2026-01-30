/*
 * Luminous Locus Model Definitions
 * Data structures and interfaces
 */

#include <stdlib.h>
#include <string.h>
#include "model.h"

/* User info */
struct UserInfo {
    char Login[64];
    char Passhash[128];
    bool IsAdmin;
};

/* Message types */
struct MessageInput {
    int ID;
    char Key[128];
};

struct MessageChat {
    int ID;
    char Type[32];
    char Text[1024];
};

struct MessageLogin {
    char Login[64];
    char Password[128];
    bool IsGuest;
    char GameVersion[64];
};

struct MessageHash {
    int Hash;
    int Tick;
};

struct MessageRestart {
    /* Empty message */
};

struct MessageNextTick {
    /* Empty message */
};

struct MessageRequestHash {
    int Tick;
};

struct MessageSuccessfulConnect {
    int ID;
    char MapURL[256];
};

struct MessageMapUpload {
    int Tick;
    char MapURL[256];
};

struct MessageNewTick {
    /* Empty message */
};

struct MessageNewClient {
    int ID;
};

struct MessageCurrentConnections {
    int Amount;
};

/* Error messages */
struct ErrmsgWrongGameVersion {
    char CorrectVersion[64];
};

struct ErrmsgWrongAuth {
    /* Empty message */
};

struct ErrmsgServerExit {
    /* Empty message */
};

struct ErrmsgNoMaster {
    /* Empty message */
};

struct ErrmsgOutOfSync {
    /* Empty message */
};

struct ErrmsgUndefinedError {
    /* Empty message */
};

struct ErrmsgTooSlow {
    /* Empty message */
};

struct ErrmsgInternalServerError {
    char Message[256];
};

struct ErrmsgServerRestarting {
    /* Empty message */
};

/* Game messages */
struct MessageOrdinary {
    int ID;
    char Key[128];
};

struct MessageJustMessage {
    int ID;
    char Text[2048];
};

struct MessageMouseClick {
    int ID;
    int Object;
    char Action[128];
};

struct MessageOOC {
    char Login[64];
    char Text[2048];
};

struct MessagePing {
    int ID;
    char PingID[64];
};

/* Type name functions */
const char* message_type_name(MessageType type) {
    switch (type) {
        case MSGID_INPUT: return "MessageInput";
        case MSGID_CHAT: return "MessageChat";
        case MSGID_LOGIN: return "MessageLogin";
        case MSGID_HASH: return "MessageHash";
        case MSGID_RESTART: return "MessageRestart";
        case MSGID_NEXTTICK: return "MessageNextTick";
        case MSGID_REQUESTHASH: return "MessageRequestHash";
        case MSGID_SUCCESSFULCONNECT: return "MessageSuccessfulConnect";
        case MSGID_MAPUPLOAD: return "MessageMapUpload";
        case MSGID_NEWTICK: return "MessageNewTick";
        case MSGID_NEWCLIENT: return "MessageNewClient";
        case MSGID_CURRENTCONNECTIONS: return "MessageCurrentConnections";
        case MSGID_WRONGGAMEVERSION: return "ErrmsgWrongGameVersion";
        case MSGID_WRONGAUTH: return "ErrmsgWrongAuth";
        case MSGID_SERVEREXIT: return "ErrmsgServerExit";
        case MSGID_NOMASTER: return "ErrmsgNoMaster";
        case MSGID_OUTOFSYNC: return "ErrmsgOutOfSync";
        case MSGID_UNDEFINEDERROR: return "ErrmsgUndefinedError";
        case MSGID_TOOSLOW: return "ErrmsgTooSlow";
        case MSGID_INTERNALSERVERERROR: return "ErrmsgInternalServerError";
        case MSGID_SERVERRESTARTING: return "ErrmsgServerRestarting";
        case MSGID_ORDINARY: return "MessageOrdinary";
        case MSGID_JUSTMESSAGE: return "MessageJustMessage";
        case MSGID_MOUSECLICK: return "MessageMouseClick";
        case MSGID_OOCMESSAGE: return "MessageOOC";
        case MSGID_PING: return "MessagePing";
        default: return "Unknown";
    }
}