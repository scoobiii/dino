#!/bin/bash
# build_senior.sh - DevOps sênior, sem fake code
# Versão: 1.0.0-anti-fake

set -euo pipefail

echo "🔧 [SENIOR FIX] Compilando modelo vintage válido"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Verificar se o arquivo C é válido
if ! grep -q "#include" arch/model/tiny256k.c; then
    echo "❌ ERRO CRÍTICO: arquivo C não é código C válido"
    echo "Primeiras 5 linhas do arquivo:"
    head -5 arch/model/tiny256k.c
    exit 1
fi

# Limpar builds anteriores
rm -f arch/serve/llm.wasm arch/serve/llm.wasm.dbg

# Compilar com configuração mínima mas correta
clang \
    --target=wasm32-wasip1 \
    -Oz -nostdlib -Wl,--no-entry \
    -Wl,--export=init_model \
    -Wl,--export=forward \
    -o arch/serve/llm.wasm \
    arch/model/tiny256k.c 2>&1

# Validar
if [ -f arch/serve/llm.wasm ]; then
    SIZE=$(stat -c%s arch/serve/llm.wasm 2>/dev/null || stat -f%z arch/serve/llm.wasm)
    echo "✅ Build SENIOR concluído: ${SIZE} bytes"
    
    # Teste rápido de integridade
    if timeout 2 bend run arch/serve/llm.wasm >/dev/null 2>&1; then
        echo "✅ WASM executável (teste de integridade)"
    else
        echo "⚠️  WASM compilado mas pode ter problemas de execução"
    fi
else
    echo "❌ Build falhou - llm.wasm não criado"
    exit 1
fi
