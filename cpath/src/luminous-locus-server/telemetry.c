/*
 * Luminous Locus Telemetry Module
 * Metrics and monitoring
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <sys/time.h>
#include "model.h"

/* Stats collector structure */
struct StatsCollector {
    int current_clients;
    int total_session_clients;
    int total_messages_in;
    int total_messages_out;
    int64_t bytes_received;
    int64_t bytes_sent;
    time_t start_time;
};

/* Create new stats collector */
StatsCollector* stats_collector_create(void) {
    StatsCollector* sc = (StatsCollector*)malloc(sizeof(StatsCollector));
    if (sc == NULL) {
        return NULL;
    }
    memset(sc, 0, sizeof(StatsCollector));
    sc->start_time = time(NULL);
    return sc;
}

/* Free stats collector */
void stats_collector_free(StatsCollector* sc) {
    if (sc != NULL) {
        free(sc);
    }
}

/* Get current time in milliseconds */
static int64_t get_time_ms(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (int64_t)tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

/* Record incoming message */
void stats_collector_record_incoming(StatsCollector* sc) {
    if (sc != NULL) {
        sc->total_messages_in++;
    }
}

/* Record outgoing message */
void stats_collector_record_outgoing(StatsCollector* sc) {
    if (sc != NULL) {
        sc->total_messages_out++;
    }
}

/* Record bytes received */
void stats_collector_bytes_received(StatsCollector* sc, int64_t bytes) {
    if (sc != NULL) {
        sc->bytes_received += bytes;
    }
}

/* Record bytes sent */
void stats_collector_bytes_sent(StatsCollector* sc, int64_t bytes) {
    if (sc != NULL) {
        sc->bytes_sent += bytes;
    }
}

/* Increment client count */
void stats_collector_add_client(StatsCollector* sc) {
    if (sc != NULL) {
        sc->current_clients++;
        sc->total_session_clients++;
    }
}

/* Decrement client count */
void stats_collector_remove_client(StatsCollector* sc) {
    if (sc != NULL && sc->current_clients > 0) {
        sc->current_clients--;
    }
}

/* Get current client count */
int stats_collector_get_clients(StatsCollector* sc) {
    return sc != NULL ? sc->current_clients : 0;
}

/* Get total session clients */
int stats_collector_get_total_clients(StatsCollector* sc) {
    return sc != NULL ? sc->total_session_clients : 0;
}

/* Get uptime in seconds */
uint64_t stats_collector_get_uptime(StatsCollector* sc) {
    if (sc == NULL) {
        return 0;
    }
    return (uint64_t)(time(NULL) - sc->start_time);
}

/* Get total messages */
int stats_collector_get_total_messages(StatsCollector* sc) {
    if (sc == NULL) {
        return 0;
    }
    return sc->total_messages_in + sc->total_messages_out;
}

/* Reset client stats */
void stats_collector_reset_clients(StatsCollector* sc) {
    if (sc != NULL) {
        sc->current_clients = 0;
    }
}