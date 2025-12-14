// tiny256k_scale.c - Modelo que ESCALA com workload
// Versão: 5.0.0-force-workload

typedef unsigned int uint32_t;

#define EMBED_DIM 8

// Embedding table com 256*8 elementos
static const float emb[256*8] = {
    #include "embeddings_2048.h"
};

// Função que REALMENTE processa N tokens
__attribute__((export_name("forward_n")))
uint32_t forward_n(uint32_t n) {
    // Contexto acumulador
    float ctx[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    
    // Loop que NÃO pode ser otimizado fora
    for (uint32_t i = 0; i < n; i++) {
        uint32_t token = i % 256;  // Token varia com i
        const float* e = &emb[token * 8];
        
        // Acumulação forçada
        ctx[0] += e[0];
        ctx[1] += e[1];
        ctx[2] += e[2];
        ctx[3] += e[3];
        ctx[4] += e[4];
        ctx[5] += e[5];
        ctx[6] += e[6];
        ctx[7] += e[7];
    }
    
    // Score que depende de todos os acumuladores
    float score = 
        ctx[0] * 1.0f + ctx[1] * 2.0f + ctx[2] * 3.0f + ctx[3] * 4.0f +
        ctx[4] * 5.0f + ctx[5] * 6.0f + ctx[6] * 7.0f + ctx[7] * 8.0f;
    
    return ((uint32_t)(score * 1000.0f) % 252) + 4;
}
