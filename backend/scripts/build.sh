#!/bin/bash
# tiny-local-llm/backend/scripts/build.sh
# Última atualização: 2025-12-13

set -e

echo "🔧 [BUILD] TinyLocal-LLM — Modelo funcional (2025-12-13)"
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

BUILD_DATE="$(date '+%Y-%m-%d %H:%M')"
echo "✅ Build concluído: ${BUILD_DATE}"

