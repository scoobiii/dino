#!/bin/bash
# build_vintage_senior.sh - Build minimalista e funcional
# Versão: 1.0.0-no-bullshit

echo "🔨 BUILD SENIOR (no-bullshit)"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. Validar arquivo C
echo "🔍 Validando tiny256k.c..."
if ! grep -q "forward" arch/model/tiny256k.c; then
    echo "❌ ERRO: arquivo C não contém função forward"
    exit 1
fi

# 2. Compilar SIMPLES - sem flags complexas
echo "⚙️  Compilando..."
clang \
    --target=wasm32-wasip1 \
    -Oz \
    -nostdlib \
    -Wl,--no-entry \
    -Wl,--export=init_model \
    -Wl,--export=forward \
    -o arch/serve/llm.wasm \
    arch/model/tiny256k.c 2>&1 | grep -v "warning:"

# 3. Verificar se compilou
if [ -f arch/serve/llm.wasm ]; then
    SIZE=$(wc -c < arch/serve/llm.wasm)
    echo "✅ WASM criado: $SIZE bytes"
    
    # Teste rápido
    if bend run arch/serve/llm.wasm >/dev/null 2>&1; then
        echo "✅ Teste de execução OK"
    else
        echo "⚠️  Compilou mas não executou"
    fi
else
    echo "❌ Falha na compilação"
    exit 1
fi
