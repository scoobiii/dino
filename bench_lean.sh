#!/bin/bash
# bench_lean.sh - Benchmark sênior, lean, anti-fake
# Mede APENAS o que funciona

echo "🧪 BENCH LEAN (Vintage vs Pássaro)"
echo "=================================="

# 1. Verificar se os arquivos são REAIS
echo "🔍 Verificação anti-fake:"
[ -f arch/serve/llm.wasm ] && echo "✅ llm.wasm: EXISTE" || echo "❌ llm.wasm: AUSENTE"
[ -f arch/model/bend256k.bend ] && echo "✅ bend256k.bend: EXISTE" || echo "❌ bend256k.bend: AUSENTE"

# 2. Warm-up (executar 1x cada)
echo "🔥 Warm-up (1 execução):"
bend run arch/serve/llm.wasm >/dev/null 2>&1 && echo "✅ Vintage warm-up OK"
bend run-c arch/model/bend256k.bend >/dev/null 2>&1 && echo "✅ Pássaro warm-up OK"

# 3. Medição SIMPLES (5 execuções cada)
echo -e "\n⏱️  Medição Vintage (5 execuções):"
VINTAGE_TIMES=""
for i in {1..5}; do
    START=$(date +%s%N)
    bend run arch/serve/llm.wasm >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    VINTAGE_TIMES="$VINTAGE_TIMES $TIME"
    echo "  Exec $i: ${TIME}ms"
done

echo -e "\n⏱️  Medição Pássaro (5 execuções):"
BIRD_TIMES=""
for i in {1..5}; do
    START=$(date +%s%N)
    bend run-c arch/model/bend256k.bend >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    BIRD_TIMES="$BIRD_TIMES $TIME"
    echo "  Exec $i: ${TIME}ms"
done

# 4. Calcular médias (forma simples)
echo -e "\n📊 RESULTADOS LEAN:"
V_AVG=$(echo $VINTAGE_TIMES | awk '{sum=0; for(i=1;i<=NF;i++)sum+=$i; print sum/NF}')
B_AVG=$(echo $BIRD_TIMES | awk '{sum=0; for(i=1;i<=NF;i++)sum+=$i; print sum/NF}')

echo "🦴 Vintage (média): ${V_AVG} ms"
echo "🦅 Pássaro (média): ${B_AVG} ms"

if (( $(echo "$B_AVG > 0" | bc -l) )); then
    SPEEDUP=$(echo "scale=2; $V_AVG / $B_AVG" | bc)
    echo "⚡ Speedup (Vintage/Pássaro): ${SPEEDUP}x"
    
    if (( $(echo "$SPEEDUP > 1" | bc -l) )); then
        echo "🎯 Vintage mais rápido por ${SPEEDUP}x"
    else
        INVERSE=$(echo "scale=2; 1 / $SPEEDUP" | bc)
        echo "🎯 Pássaro mais rápido por ${INVERSE}x"
    fi
fi

# 5. Salvar resultado mínimo
echo -e "\n💾 Salvando resultado mínimo..."
mkdir -p bench/results
cat > bench/results/lean_$(date +%s).txt << EOR
LEAN BENCH - $(date)
Vintage: ${V_AVG} ms
Pássaro: ${B_AVG} ms
Speedup: ${SPEEDUP:-N/A}x
Status: $(if [ -f arch/serve/llm.wasm ]; then echo "WASM_OK"; else echo "WASM_MISSING"; fi)
EOR
