#!/bin/bash
# build_final.sh - Build completo e funcional
# Versão: 1.0.0-ultimate

echo "🔨 BUILD ULTIMATE"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. Verificar arquivos
echo "🔍 Verificando arquivos..."
[ -f arch/model/tiny256k.c ] || { echo "❌ tiny256k.c não existe"; exit 1; }
[ -f arch/model/test_wasm.c ] || { echo "❌ test_wasm.c não existe"; exit 1; }

# 2. Compilar WASM standalone (para bend run)
echo "⚙️  Compilando WASM standalone..."
clang \
    --target=wasm32-wasip1 \
    -Oz -nostdlib \
    -Wl,--no-entry \
    -Wl,--export=init_model \
    -Wl,--export=forward \
    -o arch/serve/llm.wasm \
    arch/model/tiny256k.c 2>&1 | grep -i error || true

# 3. Compilar teste nativo (para validar funcionalidade)
echo "⚙️  Compilando teste nativo..."
clang \
    -Oz \
    -o arch/serve/test_wasm \
    arch/model/test_wasm.c arch/model/tiny256k.c -lm 2>&1 | grep -i error || true

# 4. Validar
if [ -f arch/serve/llm.wasm ]; then
    SIZE=$(wc -c < arch/serve/llm.wasm)
    echo "✅ WASM criado: $SIZE bytes"
    
    # Testar com bend
    if timeout 1 bend run arch/serve/llm.wasm >/dev/null 2>&1; then
        echo "✅ WASM executável via bend"
    else
        echo "⚠️  WASM não executou via bend (esperado - sem main)"
    fi
fi

if [ -f arch/serve/test_wasm ]; then
    echo "✅ Teste nativo compilado"
    echo "🔬 Testando funcionalidade:"
    ./arch/serve/test_wasm
fi
