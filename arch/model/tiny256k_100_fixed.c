// tiny256k_100_fixed.c - 100 tokens FORÇADOS
// Versão: 5.0.0-no-optimize

typedef unsigned int uint32_t;

// Incluir embeddings
static const float emb[256*8] = {
    #include "embeddings_2048.h"
};

// Variável global para evitar dead code elimination
volatile uint32_t __result;

__attribute__((export_name("init_model")))
void init_model(void) {}

__attribute__((export_name("forward_100")))
uint32_t forward_100(void) {
    float ctx[8] = {0};
    
    // LOOP QUE ESCALA - 100 iterações FORÇADAS
    for (uint32_t i = 0; i < 100; i++) {
        uint32_t t = (i * 13 + 7) % 256;  // Token depende de i
        const float* e = &emb[t * 8];
        
        ctx[0] += e[0];
        ctx[1] += e[1];
        ctx[2] += e[2];
        ctx[3] += e[3];
        ctx[4] += e[4];
        ctx[5] += e[5];
        ctx[6] += e[6];
        ctx[7] += e[7];
    }
    
    float score = 
        ctx[0] * 1.0f + ctx[1] * 2.0f + ctx[2] * 3.0f + ctx[3] * 4.0f +
        ctx[4] * 5.0f + ctx[5] * 6.0f + ctx[6] * 7.0f + ctx[7] * 8.0f;
    
    __result = ((uint32_t)(score * 1000.0f) % 252) + 4;
    return __result;
}
