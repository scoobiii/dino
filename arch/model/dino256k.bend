// arch/model/dino256k.bend
// Modelo neural minimalista (256k params) rodando diretamente no HVM (Bend)
// Arquitetura: Embedding lookup + soma ponderada (sem atencao, sem MLP profundo)
// 80% arquitetura, 20% pesos (hardcoded)

// Parâmetros
let VOCAB_SIZE = 256;
let EMBED_DIM = 8;
let MAX_SEQ = 8;

// Embeddings hardcoded (gerados pela mesma fórmula do C: ((i * 13 + 7) % 100) / 100.0)
// Em Bend, representamos como uma função que mapeia índice -> vetor
def get_embedding(idx):
  let base = (idx * EMBED_DIM);
  [ // Retorna vetor de EMBED_DIM elementos
    ((base + 0) * 13 + 7) % 100 / 100.0,
    ((base + 1) * 13 + 7) % 100 / 100.0,
    ((base + 2) * 13 + 7) % 100 / 100.0,
    ((base + 3) * 13 + 7) % 100 / 100.0,
    ((base + 4) * 13 + 7) % 100 / 100.0,
    ((base + 5) * 13 + 7) % 100 / 100.0,
    ((base + 6) * 13 + 7) % 100 / 100.0,
    ((base + 7) * 13 + 7) % 100 / 100.0
  ];

// Soma dois vetores
def add_vec(a, b):
  [
    a.0 + b.0, a.1 + b.1, a.2 + b.2, a.3 + b.3,
    a.4 + b.4, a.5 + b.5, a.6 + b.6, a.7 + b.7
  ];

// Função forward: recebe lista de tokens, retorna próximo token
def forward(tokens):
  // Inicializa contexto como vetor zero
  let initial_context = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  // Soma embeddings dos tokens
  let context = fold(
    (ctx, tok) -> add_vec(ctx, get_embedding(tok % VOCAB_SIZE)),
    initial_context,
    take(MAX_SEQ, tokens) // Limita sequência
  );

  // Calcula score ponderado
  let score =
    context.0 * 1.0 +
    context.1 * 2.0 +
    context.2 * 3.0 +
    context.3 * 4.0 +
    context.4 * 5.0 +
    context.5 * 6.0 +
    context.6 * 7.0 +
    context.7 * 8.0;

  // Gera próximo token (mesma fórmula do C)
  let next_token = (int(score * 1000) % (VOCAB_SIZE - 4)) + 4;
  next_token;

def main():
  // Exemplo de uso
  let input_tokens = [1, 814, 2]; // "<s> olá </s>"
  let next_id = forward(input_tokens);
  next_id; // Retorna o token gerado
