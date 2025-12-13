// tiny256k.c — v0.1.1-export
// Modelo feedforward mínimo com exports corretos

#include <stdint.h>

// Definições
typedef unsigned int uint32_t;
typedef unsigned long size_t;

// Parâmetros
#define VOCAB_SIZE 256
#define EMBED_DIM 8
#define MAX_SEQ 8

// Dados
static float embeddings[VOCAB_SIZE * EMBED_DIM];
static int initialized = 0;

// Força export via atributo + nome C-style
__attribute__((export_name("init_model")))
void init_model(void) {
    if (initialized) return;
    for (int i = 0; i < VOCAB_SIZE * EMBED_DIM; i++) {
        embeddings[i] = (float)((i * 13 + 7) % 100) / 100.0f;
    }
    initialized = 1;
}

__attribute__((export_name("forward")))
uint32_t forward(uint32_t* tokens, uint32_t len) {
    if (!initialized) init_model();
    if (len == 0) return 0;
    if (len > MAX_SEQ) len = MAX_SEQ;

    float context[EMBED_DIM] = {0};
    for (uint32_t i = 0; i < len; i++) {
        uint32_t tok = tokens[i] % VOCAB_SIZE;
        for (int d = 0; d < EMBED_DIM; d++) {
            context[d] += embeddings[tok * EMBED_DIM + d];
        }
    }

    float score = 0.0f;
    for (int d = 0; d < EMBED_DIM; d++) {
        score += context[d] * (d + 1);
    }

    return ((uint32_t)(score * 1000) % (VOCAB_SIZE - 4)) + 4;
}

// Helper para alocar memória (WASM interface)
__attribute__((export_name("alloc")))
uint32_t* alloc(uint32_t size) {
    static uint32_t buffer[MAX_SEQ];
    return buffer;
}
