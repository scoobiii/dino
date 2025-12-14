#!/bin/bash
echo "=== ANÁLISE DE GPU ==="

# Verificar se há GPU disponível
if command -v nvidia-smi &>/dev/null; then
    echo "✅ NVIDIA GPU disponível"
    nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv
elif command -v rocm-smi &>/dev/null; then
    echo "✅ AMD GPU disponível"
    rocm-smi --showmeminfo
else
    echo "⚠️  GPU não detectada ou não suportada"
fi

echo -e "\n🦴 VINTAGE (WASM):"
echo "  • Não usa GPU (WASM não tem acesso direto a GPU)"
echo "  • Puramente CPU-driven"
echo "  • Sem transferência CPU↔GPU"

echo -e "\n🦅 PÁSSARO (Bend/HVM):"
echo "  • Potencial para GPU via CUDA/ROCm (se HVM suportar)"
echo "  • Atualmente: CPU-only"
echo "  • Futuro: Pode usar OpenCL/Vulkan para paralelismo"
