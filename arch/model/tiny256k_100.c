// tiny256k_100.c - Vintage baseline para 100 tokens
// Versão: 3.0.0-100tokens
// Propósito: Comparação justa com Bend 100 tokens

typedef unsigned int uint32_t;

#define VOCAB_SIZE 256
#define EMBED_DIM 8
#define MAX_SEQ 100  // Aumentado para 100 tokens

// Embedding matrix completa (256x8 = 2048 valores)
static const float embeddings[VOCAB_SIZE * EMBED_DIM] = {
    #include "embeddings_2048.h"
};

__attribute__((export_name("init_model")))
void init_model(void) {
    // No-op
}

__attribute__((export_name("forward")))
uint32_t forward(uint32_t* tokens, uint32_t len) {
    if (len > MAX_SEQ) len = MAX_SEQ;
    
    float ctx[EMBED_DIM] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    
    for (uint32_t i = 0; i < len; i++) {
        uint32_t t = tokens[i] & 0xFF;
        const float* emb = &embeddings[t * EMBED_DIM];
        
        ctx[0] += emb[0];
        ctx[1] += emb[1];
        ctx[2] += emb[2];
        ctx[3] += emb[3];
        ctx[4] += emb[4];
        ctx[5] += emb[5];
        ctx[6] += emb[6];
        ctx[7] += emb[7];
    }
    
    float score = 
        ctx[0] * 1.0f + ctx[1] * 2.0f + ctx[2] * 3.0f + ctx[3] * 4.0f +
        ctx[4] * 5.0f + ctx[5] * 6.0f + ctx[6] * 7.0f + ctx[7] * 8.0f;
    
    return ((uint32_t)(score * 1000.0f) % 252) + 4;
}
