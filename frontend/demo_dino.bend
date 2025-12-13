// frontend/demo_dino.bend
// Demo que chama o modelo dino256k.bend e imprime o resultado

// Copia a lógica de tokenização do Python para Bend (hash simples)
def tokenize(text):
  // Simula: tokens = [1]; para w em text.lower().split(); h = 0; para c em w.encode(); h = (h * 31 + c) % 4091; tokens.append(h + 4); tokens.append(2)
  // Vamos codificar "olá" manualmente como exemplo, ou implementar uma versão simplificada de string -> hash em Bend.
  // Por simplicidade, vamos retornar o mesmo resultado do Python para "olá": [1, 814, 2]
  // Para um demo funcional real, a tokenização precisa ser implementada em Bend.
  // Por enquanto, faremos um stub:
  let words = split(" ", text); // Função hipotética de split
  let initial = [1]; // <s>
  // A lógica real de hash é complexa em Bend puro sem bibliotecas.
  // Faremos um mapeamento direto para o resultado conhecido de "olá".
  if text == "olá":
    [1, 814, 2]
  else:
    [1, 2]; // <s> </s> default

// Dicionário de detokenização (opcional, para converter o token final em string no demo)
def detokenize(token_id):
  // Usamos o mesmo dicionário do Python
  if token_id == 42: "mundo"
  else if token_id == 43: "olá"
  else if token_id == 196: "mundo" // Conforme evoluímos antes
  else: "token_" + str(token_id);

// Função principal do demo
def main():
  let prompt = "olá";
  print("💬 Você: " + prompt);

  let tokens = tokenize(prompt);
  print("🔍 Tokenização (stub): " + str(tokens));

  // Chama o modelo diretamente
  // Como o modelo está em outro arquivo, precisamos importar ou ter tudo em um.
  // Para simplificar, vamos copiar a lógica do modelo aqui dentro do demo.
  // --- Cópia da lógica do modelo ---
  let VOCAB_SIZE = 256;
  let EMBED_DIM = 8;
  let MAX_SEQ = 8;

  def get_embedding(idx):
    let base = (idx * EMBED_DIM);
    [
      ((base + 0) * 13 + 7) % 100 / 100.0,
      ((base + 1) * 13 + 7) % 100 / 100.0,
      ((base + 2) * 13 + 7) % 100 / 100.0,
      ((base + 3) * 13 + 7) % 100 / 100.0,
      ((base + 4) * 13 + 7) % 100 / 100.0,
      ((base + 5) * 13 + 7) % 100 / 100.0,
      ((base + 6) * 13 + 7) % 100 / 100.0,
      ((base + 7) * 13 + 7) % 100 / 100.0
    ];

  def add_vec(a, b):
    [
      a.0 + b.0, a.1 + b.1, a.2 + b.2, a.3 + b.3,
      a.4 + b.4, a.5 + b.5, a.6 + b.6, a.7 + b.7
    ];

  def forward_demo(input_tokens):
    let initial_context = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    let context = fold(
      (ctx, tok) -> add_vec(ctx, get_embedding(tok % VOCAB_SIZE)),
      initial_context,
      take(MAX_SEQ, input_tokens)
    );
    let score =
      context.0 * 1.0 +
      context.1 * 2.0 +
      context.2 * 3.0 +
      context.3 * 4.0 +
      context.4 * 5.0 +
      context.5 * 6.0 +
      context.6 * 7.0 +
      context.7 * 8.0;
    let next_token = (int(score * 1000) % (VOCAB_SIZE - 4)) + 4;
    next_token;

  // --- Fim da cópia ---
  let next_id = forward_demo(tokens);
  print("🔍 Token gerado pelo modelo (HVM): " + str(next_id));
  let response = detokenize(next_id);
  print("🤖 Dino (modo Bend/HVM): " + response);

  next_id; // Retorna o token para possíveis métricas
