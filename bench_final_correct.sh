#!/bin/bash
# bench_final_correct.sh - Benchmark CORRETO com escalabilidade

echo "🏁 BENCHMARK FINAL CORRETO - ESCALABILIDADE"
echo "==========================================="

# 1. Compilar modelos CORRETOS
echo "🔨 Compilando modelos corrigidos..."
clang --target=wasm32-wasip1 -Oz -nostdlib \
    -Wl,--no-entry -Wl,--export=forward_100 \
    -o arch/serve/llm_100_fixed.wasm \
    arch/model/tiny256k_100_fixed.c 2>&1 | grep -i error || echo "✅ Vintage 100 tokens compilado"

# 2. Teste de saída (debug)
echo -e "\n🔍 Teste de saída (deve ser determinístico):"
echo "Vintage 100 tokens: $(bend run arch/serve/llm_100_fixed.wasm 2>/dev/null || echo 'ERRO')"
echo "Pássaro 100 tokens: $(bend run-c arch/model/bend_workload_fixed.bend 2>/dev/null || echo 'ERRO')"

# 3. Função de medição precisa
measure_time() {
    local cmd="$1"
    local desc="$2"
    local runs=5
    
    echo -e "\n⏱️  $desc ($runs execuções):"
    
    # Warm-up
    for i in {1..3}; do eval "$cmd" >/dev/null 2>&1; done
    
    # Medições
    local times=()
    for i in $(seq 1 $runs); do
        start=$(date +%s%N)
        eval "$cmd" >/dev/null 2>&1
        end=$(date +%s%N)
        ms=$(( (end - start) / 1000000 ))
        times+=($ms)
        printf "  Exec %d: %4d ms\n" $i $ms
    done
    
    # Cálculo da média
    local sum=0
    for t in "${times[@]}"; do ((sum+=t)); done
    local avg=$(echo "scale=1; $sum / ${#times[@]}" | bc)
    
    echo "  Média: $avg ms"
    echo $avg
}

# 4. Medir Vintage 3 tokens (baseline original)
v3=$(measure_time "bend run arch/serve/llm.wasm" "VINTAGE (3 tokens)")

# 5. Medir Vintage 100 tokens (corrigido)
v100=$(measure_time "bend run arch/serve/llm_100_fixed.wasm" "VINTAGE (100 tokens corrigido)")

# 6. Medir Pássaro 3 tokens
b3=$(measure_time "bend run-c arch/model/bend256k.bend" "PÁSSARO (3 tokens)")

# 7. Medir Pássaro 100 tokens (corrigido)
b100=$(measure_time "bend run-c arch/model/bend_workload_fixed.bend" "PÁSSARO (100 tokens corrigido)")

# 8. Análise de escalabilidade
echo -e "\n📈 ANÁLISE DE ESCALABILIDADE:"
echo "================================="
echo "VINTAGE (C/WASM):"
echo "  3 tokens: $v3 ms"
echo "  100 tokens: $v100 ms"
echo "  Escala: $(echo "scale=2; $v100 / $v3" | bc)x (esperado: ~33x)"
echo ""
echo "PÁSSARO (Bend/HVM):"
echo "  3 tokens: $b3 ms"
echo "  100 tokens: $b100 ms"
echo "  Escala: $(echo "scale=2; $b100 / $b3" | bc)x (esperado: ~1-2x para paralelo)"

# 9. Conclusão técnica
echo -e "\n🎯 CONCLUSÃO TÉCNICA FINAL:"
if [ $(echo "$v100 > $v3 * 10" | bc) -eq 1 ]; then
    echo "✅ Vintage ESCALA como esperado (trabalho aumenta com tokens)"
else
    echo "⚠️  Vintage NÃO escala como esperado (possível over-optimization)"
fi

if [ $(echo "$b100 < $b3 * 2" | bc) -eq 1 ]; then
    echo "✅ Pássaro mostra paralelismo (custo quase constante)"
else
    echo "⚠️  Pássaro não mostra paralelismo esperado"
fi

# 10. Comparação final 100 tokens
echo -e "\n🏆 COMPARAÇÃO FINAL (100 tokens):"
if [ $(echo "$v100 < $b100" | bc) -eq 1 ]; then
    ratio=$(echo "scale=2; $b100 / $v100" | bc)
    echo "🦴 VINTAGE vence por ${ratio}x"
    echo "🔧 Overhead HVM não é amortizado em 100 tokens"
else
    ratio=$(echo "scale=2; $v100 / $b100" | bc)
    echo "🦅 PÁSSARO vence por ${ratio}x"
    echo "🎉 Paralelismo funciona em workload real!"
fi

# 11. Salvar resultados finais
mkdir -p bench/results
cat > bench/results/final_correct_$(date +%s).txt << EOR
BENCHMARK FINAL CORRETO - $(date)
Vintage 3 tokens: $v3 ms
Vintage 100 tokens: $v100 ms
Pássaro 3 tokens: $b3 ms
Pássaro 100 tokens: $b100 ms
Escala Vintage: $(echo "scale=2; $v100 / $v3" | bc)x
Escala Pássaro: $(echo "scale=2; $b100 / $b3" | bc)x
Vencedor 100 tokens: $(if [ $(echo "$v100 < $b100" | bc) -eq 1 ]; then echo "Vintage"; else echo "Pássaro"; fi)
Observação: Modelos corrigidos para forçar trabalho real
EOR

echo -e "\n💾 Resultados salvos em bench/results/"
