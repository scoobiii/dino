#!/bin/bash
# tiny-local-llm/setup.sh
# Última atualização: 2025-12-13
# Responsabilidade: CONFIGURAÇÃO idempotente

set -e

echo "🔧 Configurando ambiente para tiny-local-llm (2025-12-13)..."

# Sistema
DEBIAN_FRONTEND=noninteractive apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential clang lld libc6-dev binaryen wabt curl git python3-venv

# Rust
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi
export PATH="$HOME/.cargo/bin:$PATH"
rustup target add wasm32-wasip1
rustup override set stable

# Python
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate

cat > requirements.txt << 'REQ'
sentencepiece
faiss-cpu
REQ

pip install --upgrade pip
pip install -r requirements.txt

echo
echo "✅ Setup concluído (2025-12-13)."
echo "➡️  Execute: source .venv/bin/activate && ./check_deps.sh"
