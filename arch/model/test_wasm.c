// test_wasm.c - interface mínima para testar o WASM
// Inclui um main() que chama a função forward

#include <stdint.h>
#include <stdio.h>

// Declarações das funções WASM
void init_model(void);
uint32_t forward(uint32_t* tokens, uint32_t len);

int main() {
    // Inicializar
    init_model();
    
    // Tokens de teste: [1, 42, 2]
    uint32_t tokens[] = {1, 42, 2};
    uint32_t len = 3;
    
    // Chamar forward
    uint32_t result = forward(tokens, len);
    
    // Imprimir resultado
    printf("%u\n", result);
    return 0;
}
