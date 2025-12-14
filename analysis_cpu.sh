#!/bin/bash
# analysis_cpu.sh - Análise de consumo REAL de CPU

echo "=== ANÁLISE DE CPU & NÚCLEOS ==="

# Monitorar uso de CPU durante execução
monitor_cpu() {
    local cmd="$1"
    local name="$2"
    
    echo -e "\n🔬 $name:"
    
    # Executar em background e monitorar
    eval "$cmd" >/dev/null 2>&1 &
    PID=$!
    
    # Coletar estatísticas de CPU
    CPU_START=$(ps -o %cpu= -p $PID 2>/dev/null || echo "0")
    sleep 0.1
    CPU_END=$(ps -o %cpu= -p $PID 2>/dev/null || echo "0")
    
    # Esperar término
    wait $PID 2>/dev/null
    
    # Núcleos utilizados (simplificado)
    CORES=$(echo "scale=0; ($CPU_END + 99) / 100" | bc)
    
    echo "  • CPU pico: ${CPU_END}%"
    echo "  • Núcleos estimados: ${CORES:-1}"
    echo "  • Threads: $(ps -o nlwp= -p $PID 2>/dev/null || echo "1")"
}

# Testar Vintage
monitor_cpu "bend run arch/serve/llm.wasm" "VINTAGE (WASM)"

# Testar Pássaro
monitor_cpu "bend run-c arch/model/bend256k.bend" "PÁSSARO (Bend/HVM)"
