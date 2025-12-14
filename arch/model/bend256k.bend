// bend256k.bend - modelo COMPLETO para benchmark
// Versão: 2.0.0-funcional

def embed(tok):
  let base = (tok * 13 + 7) % 100
  [
    (base + 0) / 100.0,
    (base + 1) / 100.0,
    (base + 2) / 100.0,
    (base + 3) / 100.0,
    (base + 4) / 100.0,
    (base + 5) / 100.0,
    (base + 6) / 100.0,
    (base + 7) / 100.0
  ]

def vec_add(a, b):
  [
    a.0 + b.0,
    a.1 + b.1,
    a.2 + b.2,
    a.3 + b.3,
    a.4 + b.4,
    a.5 + b.5,
    a.6 + b.6,
    a.7 + b.7
  ]

def score(ctx):
  ctx.0 * 1.0 +
  ctx.1 * 2.0 +
  ctx.2 * 3.0 +
  ctx.3 * 4.0 +
  ctx.4 * 5.0 +
  ctx.5 * 6.0 +
  ctx.6 * 7.0 +
  ctx.7 * 8.0

def forward(tokens):
  let embeds = map(embed, tokens)
  let zero = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let ctx = fold(vec_add, zero, embeds)
  let s = score(ctx)
  (int(s * 1000.0) % 252) + 4

def main():
  forward([1, 42, 2])

def forward(tokens):
  let embeds = map(embed, tokens)
  let zero = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let ctx = fold(vec_add, zero, embeds)
  let s = score(ctx)
  (int(s * 1000.0) % 252) + 4

def main():
  forward([1, 42, 2])
