// bend_workload_fixed.bend - Workload REAL que escala
// Versão: 3.0.0-real-workload

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

// Gerar lista de 100 tokens EXPLÍCITA
def main():
  let tokens = [
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
    20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,
    40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
    60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
    80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99
  ]
  forward(tokens)
