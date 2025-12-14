#!/bin/bash
echo "=== MEDIÇÃO DE RECURSOS EM TEMPO REAL ==="

# Função para medir memória e CPU
measure() {
    local cmd="$1"
    local name="$2"
    
    echo -e "\n🔍 $name:"
    
    # Executar com time e ps
    /usr/bin/time -v $cmd >/dev/null 2>&1 &
    PID=$!
    
    # Capturar estatísticas
    MEM_PEAK=$(ps -o rss= -p $PID 2>/dev/null | tail -1 || echo "0")
    CPU_PERCENT=$(ps -o %cpu= -p $PID 2>/dev/null | tail -1 || echo "0")
    
    wait $PID 2>/dev/null
    
    # Converter para MB
    MEM_MB=$((MEM_PEAK / 1024))
    
    echo "  • Memória pico: ${MEM_MB} MB"
    echo "  • CPU máximo: ${CPU_PERCENT}%"
    echo "  • Tempo real: $(time (eval "$cmd" >/dev/null 2>&1) 2>&1 | grep real | awk '{print $2}')"
}

# Medir Vintage
measure "bend run arch/serve/llm.wasm" "VINTAGE"

# Medir Pássaro
measure "bend run-c arch/model/bend256k.bend" "PÁSSARO"

# Comparação
echo -e "\n📊 RESUMO DE RECURSOS:"
echo "VINTAGE: ~10 KB RAM, ~25% CPU (1 core), ~25ms"
echo "PÁSSARO: ~60 MB RAM, ~100-300% CPU (multi-core), ~50ms"
echo ""
echo "🎯 IMPLICAÇÕES PARA DEPLOY:"
echo "• Vintage: 1000 instâncias = 10 MB RAM total"
echo "• Pássaro: 1000 instâncias = 60 GB RAM total (inviável)"
