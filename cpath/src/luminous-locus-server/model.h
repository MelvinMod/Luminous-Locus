/*
 * Luminous Locus Model Header
 * Data structure declarations
 */

#ifndef MODEL_H
#define MODEL_H

#include <stdbool.h>
#include <stdint.h>

/* Message ID constants */
enum MessageType {
    MSGID_LOGIN = 1,
    MSGID_EXIT = 2,
    MSGID_HASH = 3,
    MSGID_RESTART = 4,
    MSGID_NEXTTICK = 5,
    MSGID_SUCCESSFULCONNECT = 201,
    MSGID_MAPUPLOAD = 202,
    MSGID_NEWTICK = 203,
    MSGID_NEWCLIENT = 204,
    MSGID_CURRENTCONNECTIONS = 205,
    MSGID_REQUESTHASH = 206,
    MSGID_WRONGGAMEVERSION = 401,
    MSGID_WRONGAUTH = 402,
    MSGID_UNDEFINEDERROR = 403,
    MSGID_SERVEREXIT = 404,
    MSGID_NOMASTER = 405,
    MSGID_OUTOFSYNC = 406,
    MSGID_TOOSLOW = 407,
    MSGID_INTERNALSERVERERROR = 408,
    MSGID_SERVERRESTARTING = 409,
    MSGID_ORDINARY = 1001,
    MSGID_JUSTMESSAGE = 1002,
    MSGID_GUI = 1003,
    MSGID_MOUSECLICK = 1004,
    MSGID_OOCMESSAGE = 1005,
    MSGID_PING = 1102,
    MSGID_INPUT = 1006
};

enum MessageKind {
    MSGKIND_SYSTEM,
    MSGKIND_ERROR,
    MSGKIND_GAME,
    MSGKIND_UNKNOWN
};

/* Forward declarations */
struct UserInfo;
struct MessageInput;
struct MessageChat;
struct MessageLogin;
struct MessageHash;
struct MessageRestart;
struct MessageNextTick;
struct MessageRequestHash;
struct MessageSuccessfulConnect;
struct MessageMapUpload;
struct MessageNewTick;
struct MessageNewClient;
struct MessageCurrentConnections;
struct ErrmsgWrongGameVersion;
struct ErrmsgWrongAuth;
struct ErrmsgServerExit;
struct ErrmsgNoMaster;
struct ErrmsgOutOfSync;
struct ErrmsgUndefinedError;
struct ErrmsgTooSlow;
struct ErrmsgInternalServerError;
struct ErrmsgServerRestarting;
struct MessageOrdinary;
struct MessageJustMessage;
struct MessageMouseClick;
struct MessageOOC;
struct MessagePing;

/* User info structure */
struct UserInfo {
    char Login[64];
    char Passhash[128];
    bool IsAdmin;
};

/* Message structures */
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

/* Error message structures */
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

/* Game message structures */
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

/* Type for message type enumeration */
typedef enum MessageType MessageType;

/* Type name function */
const char* message_type_name(MessageType type);

#endif /* MODEL_H */