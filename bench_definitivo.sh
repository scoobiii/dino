#!/bin/bash
# bench_definitivo.sh - Benchmark SENIOR DEFINITIVO
# Testa AMBOS com 100 tokens, de forma JUSTA

echo "🏆 BENCHMARK DEFINITIVO - 100 TOKENS"
echo "===================================="

# 1. Compilar Vintage para 100 tokens
echo "🔨 Compilando Vintage (100 tokens)..."
clang --target=wasm32-wasip1 -Oz -nostdlib \
    -Wl,--no-entry -Wl,--export=init_model -Wl,--export=forward \
    -o arch/serve/llm_100.wasm \
    arch/model/tiny256k_100.c 2>&1 | grep -i error || echo "✅ Compilação OK"

# 2. Validar arquivos
echo -e "\n🔍 Validação de arquivos:"
[ -f arch/serve/llm_100.wasm ] && echo "✅ llm_100.wasm: $(wc -c < arch/serve/llm_100.wasm) bytes"
[ -f arch/model/bend_workload.bend ] && echo "✅ bend_workload.bend: $(wc -l < arch/model/bend_workload.bend) linhas"

# 3. Warm-up (5 execuções cada)
echo -e "\n🔥 Warm-up (5 execuções)..."
for i in {1..5}; do bend run arch/serve/llm_100.wasm >/dev/null 2>&1; done
for i in {1..5}; do bend run-c arch/model/bend_workload.bend >/dev/null 2>&1; done

# 4. Benchmark Vintage (100 tokens, 10 execuções)
echo -e "\n⏱️  VINTAGE - 100 tokens (10 execuções):"
VINTAGE_TIMES=""
for i in {1..10}; do
    START=$(date +%s%N)
    bend run arch/serve/llm_100.wasm >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    VINTAGE_TIMES="$VINTAGE_TIMES $TIME"
    echo "  Exec $i: ${TIME}ms"
done

# 5. Benchmark Pássaro (100 tokens, 10 execuções)
echo -e "\n⏱️  PÁSSARO - 100 tokens (10 execuções):"
BIRD_TIMES=""
for i in {1..10}; do
    START=$(date +%s%N)
    bend run-c arch/model/bend_workload.bend >/dev/null 2>&1
    END=$(date +%s%N)
    TIME=$(( (END - START) / 1000000 ))
    BIRD_TIMES="$BIRD_TIMES $TIME"
    echo "  Exec $i: ${TIME}ms"
done

# 6. Cálculos
V_AVG=$(echo $VINTAGE_TIMES | awk '{sum=0; for(i=1;i<=NF;i++)sum+=$i; print sum/NF}')
B_AVG=$(echo $BIRD_TIMES | awk '{sum=0; for(i=1;i<=NF;i++)sum+=$i; print sum/NF}')

echo -e "\n📊 RESULTADOS DEFINITIVOS:"
echo "===================================="
echo "🦴 VINTAGE (100 tokens): ${V_AVG} ms (média de 10)"
echo "🦅 PÁSSARO (100 tokens): ${B_AVG} ms (média de 10)"

if [ $(echo "$B_AVG > 0" | bc) -eq 1 ]; then
    RATIO=$(echo "scale=2; $V_AVG / $B_AVG" | bc)
    if [ $(echo "$RATIO > 1" | bc) -eq 1 ]; then
        echo "⚡ VINTAGE é ${RATIO}x mais rápido"
    else
        INVERSE=$(echo "scale=2; 1 / $RATIO" | bc)
        echo "⚡ PÁSSARO é ${INVERSE}x mais rápido"
    fi
fi

# 7. Comparação com 3 tokens
echo -e "\n📈 ANÁLISE DE ESCALA:"
echo "  Workload de 3 tokens:"
echo "    Vintage: ~25ms, Pássaro: ~47ms (Vintage 1.9x mais rápido)"
echo "  Workload de 100 tokens:"
echo "    Vintage: ~${V_AVG}ms, Pássaro: ~${B_AVG}ms"
echo ""
echo "  Se Vintage fosse linear: 25ms × (100/3) ≈ 833ms"
echo "  Se Pássaro fosse O(log n): ~50ms (paralelismo ideal)"
echo ""
echo "🎯 CONCLUSÃO:"
if [ $(echo "$V_AVG > $B_AVG" | bc) -eq 1 ]; then
    echo "  ❌ VINTAGE ainda vence em 100 tokens"
    echo "  🔧 Ação: Aumentar workload para 1000+ tokens"
else
    echo "  ✅ PÁSSARO VENCE em 100 tokens!"
    echo "  🎉 Paralelismo funciona como esperado!"
fi

# 8. Salvar resultados
mkdir -p bench/results
cat > bench/results/definitivo_$(date +%s).txt << EOR
BENCHMARK DEFINITIVO - $(date)
Workload: 100 tokens
Vintage: ${V_AVG} ms
Pássaro: ${B_AVG} ms
Ratio: ${RATIO:-N/A}
Escala: 100 tokens vs 3 tokens
Conclusão: $(if [ $(echo "$V_AVG > $B_AVG" | bc) -eq 1 ]; then echo "Vintage vence"; else echo "Pássaro vence"; fi)
EOR

echo -e "\n💾 Resultados salvos em bench/results/"
