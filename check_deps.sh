#!/bin/bash
# tiny-local-llm/check_deps.sh
# Última atualização: 2025-12-13
# Responsabilidade: DIAGNÓSTICO puro (nunca instala)

set -e

echo "🔍 Verificando dependências para tiny-local-llm (modo profissional)..."
echo

failures=0
suggestions=""

check() {
    local name="$1"
    local cmd="$2"
    local fix="$3"
    local desc="$4"
    printf "%-40s" "$name"
    if eval "$cmd" &>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FALTA"
        ((failures++))
        [ -n "$fix" ] && suggestions+="$desc\n  → $fix\n\n"
    fi
}

# Verificações
check "Python 3.10+" \
     '[ $(python3 -c "import sys; print(sys.version_info.major*100+sys.version_info.minor)") -ge 310 ]' \
     "Atualize o Python" \
     "Versão mínima do Python"

check "sentencepiece (Python)" \
     'python3 -c "import sentencepiece"' \
     "pip install sentencepiece" \
     "Tokenização de texto"

check "faiss-cpu (Python)" \
     'python3 -c "import faiss"' \
     "pip install faiss-cpu" \
     "Busca vetorial local"

check "rustc" \
     "rustc --version" \
     "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" \
     "Compilador Rust"

check "cargo" \
     "cargo --version" \
     "Instale Rust" \
     "Gerenciador Rust"

check "wasm32-wasip1 target" \
     "rustup target list --installed | grep -q wasm32-wasip1" \
     "rustup target add wasm32-wasip1" \
     "Target WebAssembly + WASI"

check "clang" \
     "clang --version" \
     "apt install -y clang" \
     "Compilador C para WASM"

check "lld" \
     "ld.lld --version || lld --version" \
     "apt install -y lld" \
     "Linker LLVM"

check "libc6-dev (headers mínimos)" \
     "[ -f /usr/include/stdio.h ]" \
     "apt install -y libc6-dev" \
     "Headers C básicos"

check "wasm-opt" \
     "wasm-opt --version" \
     "apt install -y binaryen" \
     "Otimizador WASM"

check "wabt" \
     "wasm-objdump --version" \
     "apt install -y wabt" \
     "Depuração WASM"

check "Bend HVM" \
     "bend --version" \
     "Veja: https://github.com/HigherOrderCO/Bend" \
     "Runtime de execução"

echo
if [ $failures -eq 0 ]; then
    echo "🎉 Ambiente validado com sucesso."
    echo "➡️  Pronto para: ./backend/scripts/build.sh"
else
    echo "🚨 $failures dependência(s) ausentes:"
    echo -e "$suggestions"
    exit 1
fi
