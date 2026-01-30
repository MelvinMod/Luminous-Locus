/*
 * Luminous Locus Telemetry Header
 */

#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <stdbool.h>
#include <stdint.h>

/* Stats collector */
typedef struct StatsCollector StatsCollector;

/* Create collector */
StatsCollector* stats_collector_create(void);

/* Free collector */
void stats_collector_free(StatsCollector* sc);

/* Record metrics */
void stats_collector_record_incoming(StatsCollector* sc);
void stats_collector_record_outgoing(StatsCollector* sc);
void stats_collector_bytes_received(StatsCollector* sc, int64_t bytes);
void stats_collector_bytes_sent(StatsCollector* sc, int64_t bytes);

/* Client tracking */
void stats_collector_add_client(StatsCollector* sc);
void stats_collector_remove_client(StatsCollector* sc);
int stats_collector_get_clients(StatsCollector* sc);
int stats_collector_get_total_clients(StatsCollector* sc);

/* Get metrics */
uint64_t stats_collector_get_uptime(StatsCollector* sc);
int stats_collector_get_total_messages(StatsCollector* sc);

/* Reset */
void stats_collector_reset_clients(StatsCollector* sc);

#endif /* TELEMETRY_H */