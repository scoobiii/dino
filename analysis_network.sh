#!/bin/bash
echo "=== ANÁLISE DE REDE & I/O ==="

echo "🦴 VINTAGE (WASM):"
echo "  • Modelo embarcado: 0 rede"
echo "  • I/O: apenas leitura do arquivo .wasm (~8KB)"
echo "  • Latência: 0ms (inferência local)"
echo "  • Largura de banda: 0 bps"

echo -e "\n🦅 PÁSSARO (Bend/HVM):"
echo "  • Runtime: carrega binário HVM (~50-100MB)"
echo "  • I/O: parser do arquivo .bend + inicialização runtime"
echo "  • Latência de inicialização: 100-500ms"
echo "  • Comunicação inter-processo: overhead do scheduler"
