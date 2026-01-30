/*
 * Luminous Locus Message Header
 */

#ifndef MESSAGE_H
#define MESSAGE_H

#include <stdint.h>
#include <stdbool.h>
#include "model.h"

/* Message envelope */
typedef struct Envelope Envelope;

/* Create envelope */
Envelope* envelope_create(void* msg, int kind, int from);

/* Free envelope */
void envelope_free(Envelope* env);

/* Get concrete message by kind */
void* get_concrete_message(int kind);

/* Free concrete message */
void free_concrete_message(void* msg, int kind);

/* Get max message length */
int get_max_message_length(int kind);

/* Envelope constructor */
Envelope* NewEnvelope(void* msg, int kind, int from);

#endif /* MESSAGE_H */