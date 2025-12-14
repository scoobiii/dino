#!/bin/bash
echo "=== MEDIÇÃO PRECISA - ANTI-VIES ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S.%3N')"

# Função para medir com precisão
measure_precise() {
    local cmd="$1"
    local name="$2"
    
    echo -e "\n🔬 $name:"
    echo "  Comando: $cmd"
    
    # 1. Medir memória ANTES
    MEM_BEFORE=$(free -m | awk '/Mem:/ {print $3}')
    
    # 2. Executar com timeout e capturar stats
    START_NS=$(date +%s%N)
    
    # Executar em background e monitorar
    eval "$cmd" >/tmp/output.log 2>&1 &
    PID=$!
    
    # 3. Monitorar enquanto roda (com delay para processos rápidos)
    MAX_MEM=0
    MAX_CPU=0
    for i in {1..50}; do  # Monitora por até 500ms
        if ps -p $PID >/dev/null 2>&1; then
            # Memória RSS em KB
            MEM_KB=$(ps -o rss= -p $PID 2>/dev/null || echo "0")
            [ "$MEM_KB" -gt "$MAX_MEM" ] && MAX_MEM=$MEM_KB
            
            # CPU percentage
            CPU_PCT=$(ps -o %cpu= -p $PID 2>/dev/null || echo "0")
            CPU_FLOAT=$(echo "$CPU_PCT" | bc 2>/dev/null || echo "0")
            [ $(echo "$CPU_FLOAT > $MAX_CPU" | bc) -eq 1 ] && MAX_CPU=$CPU_FLOAT
            
            sleep 0.01  # 10ms entre amostras
        else
            break
        fi
    done
    
    # 4. Esperar término
    wait $PID 2>/dev/null
    STATUS=$?
    END_NS=$(date +%s%N)
    
    # 5. Medir memória DEPOIS
    MEM_AFTER=$(free -m | awk '/Mem:/ {print $3}')
    
    # 6. Cálculos
    DURATION_MS=$(( (END_NS - START_NS) / 1000000 ))
    MEM_MB=$(( MAX_MEM / 1024 ))
    MEM_DELTA=$(( MEM_AFTER - MEM_BEFORE ))
    
    # 7. Output
    echo "  ✅ Tempo total: ${DURATION_MS} ms"
    echo "  📊 Memória pico: ${MEM_MB} MB (RSS), Δ: ${MEM_DELTA} MB"
    echo "  ⚡ CPU máximo: ${MAX_CPU}%"
    echo "  🔧 Exit code: ${STATUS}"
    
    # 8. Extrair output se existir
    if [ -s /tmp/output.log ]; then
        OUTPUT=$(head -c 100 /tmp/output.log)
        echo "  📄 Output: ${OUTPUT:0:50}..."
    fi
    
    # Retornar métricas
    echo "${DURATION_MS},${MEM_MB},${MAX_CPU}"
}

# Limpar arquivo temporário
rm -f /tmp/output.log

# Executar múltiplas vezes para reduzir ruído
echo "🧪 Executando 3 medições para cada (média será calculada):"

# Vintage
V_TIMES=""
V_MEMS=""
V_CPUS=""
for i in {1..3}; do
    echo -e "\n--- Execução $i/3 Vintage ---"
    RESULT=$(measure_precise "bend run arch/serve/llm.wasm" "VINTAGE (WASM)")
    DUR=$(echo $RESULT | cut -d, -f1)
    MEM=$(echo $RESULT | cut -d, -f2)
    CPU=$(echo $RESULT | cut -d, -f3)
    V_TIMES="$V_TIMES $DUR"
    V_MEMS="$V_MEMS $MEM"
    V_CPUS="$V_CPUS $CPU"
done

# Pássaro
B_TIMES=""
B_MEMS=""
B_CPUS=""
for i in {1..3}; do
    echo -e "\n--- Execução $i/3 Pássaro ---"
    RESULT=$(measure_precise "bend run-c arch/model/bend256k.bend" "PÁSSARO (Bend/HVM)")
    DUR=$(echo $RESULT | cut -d, -f1)
    MEM=$(echo $RESULT | cut -d, -f2)
    CPU=$(echo $RESULT | cut -d, -f3)
    B_TIMES="$B_TIMES $DUR"
    B_MEMS="$B_MEMS $MEM"
    B_CPUS="$B_CPUS $CPU"
done

# Função para calcular média
calculate_avg() {
    echo "$1" | awk '{
        sum=0; count=0;
        for(i=1;i<=NF;i++) {sum+=$i; count++}
        printf "%.1f", sum/count
    }'
}

# Cálculos finais
V_AVG_TIME=$(calculate_avg "$V_TIMES")
V_AVG_MEM=$(calculate_avg "$V_MEMS")
V_AVG_CPU=$(calculate_avg "$V_CPUS")

B_AVG_TIME=$(calculate_avg "$B_TIMES")
B_AVG_MEM=$(calculate_avg "$B_MEMS")
B_AVG_CPU=$(calculate_avg "$B_CPUS")

# Relatório final
echo -e "\n=========================================="
echo "📊 RELATÓRIO FINAL PRECISO (Médias de 3 execuções)"
echo "=========================================="
echo ""
echo "🦴 VINTAGE (C/WASM):"
echo "  ⏱️  Tempo: ${V_AVG_TIME} ms"
echo "  🧠 Memória: ${V_AVG_MEM} MB"
echo "  ⚡ CPU: ${V_AVG_CPU}%"
echo ""
echo "🦅 PÁSSARO (Bend/HVM):"
echo "  ⏱️  Tempo: ${B_AVG_TIME} ms"
echo "  🧠 Memória: ${B_AVG_MEM} MB"
echo "  ⚡ CPU: ${B_AVG_CPU}%"
echo ""
echo "📈 COMPARAÇÃO:"
echo "  • Tempo: Vintage $(echo "scale=1; $V_AVG_TIME / $B_AVG_TIME" | bc)x mais rápido"
echo "  • Memória: Vintage usa $(echo "scale=1; $B_AVG_MEM / $V_AVG_MEM" | bc)x menos"
echo "  • CPU: Vintage usa $(echo "scale=1; $V_AVG_CPU / $B_AVG_CPU" | bc)x menos CPU%"
echo ""
echo "💾 Salvando resultados..."
mkdir -p bench/results
cat > bench/results/precise_$(date +%s).txt << EOR
MEDIÇÃO PRECISA - $(date)
Vintage: ${V_AVG_TIME} ms, ${V_AVG_MEM} MB, ${V_AVG_CPU}% CPU
Pássaro: ${B_AVG_TIME} ms, ${B_AVG_MEM} MB, ${B_AVG_CPU}% CPU
Ratio Tempo: $(echo "scale=2; $V_AVG_TIME / $B_AVG_TIME" | bc)
Ratio Memória: $(echo "scale=2; $B_AVG_MEM / $V_AVG_MEM" | bc)
Método: 3 execuções cada, monitoramento em tempo real
EOR

echo "✅ Medição precisa concluída!"
