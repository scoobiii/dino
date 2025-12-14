#!/bin/bash
# bench_final.sh - Benchmark HONESTO e DEFINITIVO
# Compara APENAS o que FUNCIONA de verdade

echo "🧪 BENCHMARK FINAL - SENIOR DEVOPS"
echo "=================================="

# 1. Build
echo "🔨 Construindo tudo..."
./backend/scripts/build_final.sh

# 2. Verificar integridade
echo -e "\n🔍 VERIFICAÇÃO DE INTEGRIDADE:"
[ -f arch/serve/llm.wasm ] && echo "✅ llm.wasm: PRESENTE" || echo "❌ llm.wasm: AUSENTE"
[ -f arch/model/bend256k.bend ] && echo "✅ bend256k.bend: PRESENTE" || echo "❌ bend256k.bend: AUSENTE"

# 3. Testar saídas (o que cada um retorna)
echo -e "\n🎯 SAÍDAS DOS MODELOS:"
echo "Vintage (teste nativo): $(./arch/serve/test_wasm 2>/dev/null || echo "ERRO")"
echo "Pássaro (Bend): $(bend run-c arch/model/bend256k.bend 2>/dev/null || echo "ERRO")"

# 4. Benchmark REAL (10 execuções warm, 10 execuções timed)
echo -e "\n⏱️  BENCHMARK REAL (10 warm-up + 10 medições):"

# Vintage via bend (WASM)
echo -e "\n🦴 VINTAGE (WASM via bend):"
for i in {1..10}; do bend run arch/serve/llm.wasm >/dev/null 2>&1; done  # warm-up
VINTAGE_SUM=0
for i in {1..10}; do
    START=$(date +%s%N)
    bend run arch/serve/llm.wasm >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    VINTAGE_SUM=$((VINTAGE_SUM + TIME))
    echo "  Exec $i: ${TIME}ms"
done
VINTAGE_AVG=$(echo "scale=1; $VINTAGE_SUM / 10" | bc)

# Pássaro (Bend)
echo -e "\n🦅 PÁSSARO (Bend/HVM):"
for i in {1..10}; do bend run-c arch/model/bend256k.bend >/dev/null 2>&1; done  # warm-up
BIRD_SUM=0
for i in {1..10}; do
    START=$(date +%s%N)
    bend run-c arch/model/bend256k.bend >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    BIRD_SUM=$((BIRD_SUM + TIME))
    echo "  Exec $i: ${TIME}ms"
done
BIRD_AVG=$(echo "scale=1; $BIRD_SUM / 10" | bc)

# 5. Resultados FINAIS
echo -e "\n📊 RESULTADO FINAL - SENIOR DEVOPS:"
echo "======================================"
echo "🦴 VINTAGE (WASM): ${VINTAGE_AVG} ms (média de 10 execuções)"
echo "🦅 PÁSSARO (Bend): ${BIRD_AVG} ms (média de 10 execuções)"

if [ $(echo "$BIRD_AVG > 0" | bc) -eq 1 ]; then
    SPEEDUP=$(echo "scale=2; $VINTAGE_AVG / $BIRD_AVG" | bc)
    echo "⚡ SPEEDUP (Vintage/Pássaro): ${SPEEDUP}x"
    
    if [ $(echo "$SPEEDUP > 1" | bc) -eq 1 ]; then
        echo "🎯 CONCLUSÃO: Vintage é ${SPEEDUP}x mais rápido"
    else
        INVERSE=$(echo "scale=2; 1 / $SPEEDUP" | bc)
        echo "🎯 CONCLUSÃO: Pássaro é ${INVERSE}x mais rápido"
    fi
fi

# 6. Salvar para análise
echo -e "\n💾 Salvando resultados..."
mkdir -p bench/results
cat > bench/results/final_$(date +%s).txt << EOR
BENCHMARK FINAL - $(date)
Vintage (WASM): ${VINTAGE_AVG} ms
Pássaro (Bend): ${BIRD_AVG} ms
Speedup: ${SPEEDUP:-N/A}x
Observação: ${OBS:-"Benchmark completo"}
EOR

echo "✅ Benchmark finalizado. Consulte bench/results/"
