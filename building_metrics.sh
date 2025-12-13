#!/bin/bash
# build.sh — v20251213.1
# Author: scoobiii / gos3 DevOps

set -euo pipefail  # ←←← Adicionado: falha em qualquer erro

echo "🔧 [BUILD] TinyLocal-LLM — v20251213.1"

# Remove artefato antigo
rm -f arch/serve/llm.wasm

mkdir -p arch/serve

clang \
  --target=wasm32-wasip1 \
  -fuse-ld=lld \
  -O2 -nostdlib \
  -Wl,--no-entry \
  -Wl,--export=init \
  -Wl,--export=forward \
  -Wl,--export-dynamic \
  -o arch/serve/llm.wasm \
  arch/model/tiny256k.c

wasm-opt -Oz --flatten --dce arch/serve/llm.wasm -o arch/serve/llm.wasm

echo "✅ Build completed: $(date '+%Y-%m-%d %H:%M')"
