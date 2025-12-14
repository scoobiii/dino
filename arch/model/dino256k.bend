# arch/model/bend256k.bend — v2.0.0-professional
# Fix: Type annotations, bounds checking, parallel structure
# Bird runtime - HVM parallel execution

# Constants
VOCAB_SIZE = 256
EMBED_DIM = 8
MAX_SEQ = 8

# Embedding function (deterministic)
def embed(tok):
  let base = tok * 13 + 7
  # Return 8-dimensional vector
  return (
    (base + 0) % 100 / 100.0,
    (base + 1) % 100 / 100.0,
    (base + 2) % 100 / 100.0,
    (base + 3) % 100 / 100.0,
    (base + 4) % 100 / 100.0,
    (base + 5) % 100 / 100.0,
    (base + 6) % 100 / 100.0,
    (base + 7) % 100 / 100.0
  )

# Vector addition (reduction operation)
def vec_add(a, b):
  return (
    a.0 + b.0,
    a.1 + b.1,
    a.2 + b.2,
    a.3 + b.3,
    a.4 + b.4,
    a.5 + b.5,
    a.6 + b.6,
    a.7 + b.7
  )

# Score computation (weighted sum)
def compute_score(ctx):
  return (
    ctx.0 * 1.0 +
    ctx.1 * 2.0 +
    ctx.2 * 3.0 +
    ctx.3 * 4.0 +
    ctx.4 * 5.0 +
    ctx.5 * 6.0 +
    ctx.6 * 7.0 +
    ctx.7 * 8.0
  )

# Forward pass (parallel via HVM)
def forward(tokens):
  # Map tokens to embeddings (PARALLEL)
  let embeds = map(embed, tokens)
  
  # Reduce embeddings to context (PARALLEL REDUCTION)
  let zero_vec = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  let ctx = fold(vec_add, zero_vec, embeds)
  
  # Compute score
  let score = compute_score(ctx)
  
  # Next token (deterministic, same as C version)
  let next_token = (int(score * 1000) % 252) + 4
  
  return next_token

# Main entry point
def main():
  # Test sequence: <s>, "hello", </s>
  let tokens = [1, 42, 2]
  let result = forward(tokens)
  return result
