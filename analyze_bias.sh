#!/bin/bash
echo "=== ANÁLISE DE VIÉS ESTATÍSTICO ==="
echo "Objetivo: Identificar fontes de viés na medição"

# 1. Variação entre execuções
echo -e "\n1. 📊 VARIAÇÃO ENTRE EXECUÇÕES:"
echo "Executando 5 vezes rapidamente..."

echo "Vintage (5 execuções rápidas):"
for i in {1..5}; do
    START=$(date +%s%N)
    bend run arch/serve/llm.wasm >/dev/null 2>&1
    END=$(date +%s%N)
    echo "  $i: $(( (END - START) / 1000000 )) ms"
done

echo -e "\nPássaro (5 execuções rápidas):"
for i in {1..5}; do
    START=$(date +%s%N)
    bend run-c arch/model/bend256k.bend >/dev/null 2>&1
    END=$(date +%s%N)
    echo "  $i: $(( (END - START) / 1000000 )) ms"
done

# 2. Efeito de cache/warm-up
echo -e "\n2. 🔥 EFEITO WARM-UP:"
echo "Executando warm-up e medindo diferença..."

# Cold start
echo "Vintage COLD start (primeira execução):"
time bend run arch/serve/llm.wasm >/dev/null 2>&1

echo -e "\nVintage WARM start (após 5 execuções):"
for i in {1..5}; do bend run arch/serve/llm.wasm >/dev/null 2>&1; done
time bend run arch/serve/llm.wasm >/dev/null 2>&1

# 3. Overhead do bend run vs bend run-c
echo -e "\n3. ⚙️  OVERHEAD DO RUNTIME:"
echo "Comparando bend run vs bend run-c overhead..."

echo "bend run (apenas runtime):"
time bend run --help >/dev/null 2>&1

echo -e "\nbend run-c (apenas runtime):"
time bend run-c --help >/dev/null 2>&1

# 4. Análise de distribuição
echo -e "\n4. 📈 DISTRIBUIÇÃO DOS DADOS:"
echo "Coletando 10 amostras de cada..."

collect_samples() {
    local cmd="$1"
    local samples=""
    for i in {1..10}; do
        START=$(date +%s%N)
        eval "$cmd" >/dev/null 2>&1
        END=$(date +%s%N)
        samples="$samples $(( (END - START) / 1000000 ))"
    done
    echo "$samples"
}

V_SAMPLES=$(collect_samples "bend run arch/serve/llm.wasm")
B_SAMPLES=$(collect_samples "bend run-c arch/model/bend256k.bend")

echo "Vintage: $V_SAMPLES"
echo "Pássaro: $B_SAMPLES"

# 5. Cálculo estatístico básico
echo -e "\n5. 🧮 ESTATÍSTICAS BÁSICAS:"

stats() {
    echo "$1" | awk '
    {
        min=$1; max=$1; sum=0; count=0;
        for(i=1;i<=NF;i++) {
            sum+=$i; count++;
            if($i<min) min=$i;
            if($i>max) max=$i;
        }
        avg=sum/count;
        
        # Variância
        var_sum=0;
        for(i=1;i<=NF;i++) {
            diff=$i-avg;
            var_sum+=diff*diff;
        }
        variance=var_sum/count;
        stddev=sqrt(variance);
        
        printf "Amostras: %d\n", count;
        printf "Média: %.1f ms\n", avg;
        printf "Min: %.1f ms\n", min;
        printf "Max: %.1f ms\n", max;
        printf "Desvio padrão: %.1f ms\n", stddev;
        printf "Coef. variação: %.1f%%\n", (stddev/avg)*100;
    }'
}

echo "Vintage:"
stats "$V_SAMPLES"

echo -e "\nPássaro:"
stats "$B_SAMPLES"

# 6. Conclusão sobre viés
echo -e "\n6. 🎯 CONCLUSÃO SOBRE VIÉS:"
echo "Fontes de viés identificadas:"
echo "✅ 1. Warm-up do runtime bend"
echo "✅ 2. Cache de arquivos"
echo "✅ 3. Scheduling do sistema"
echo "✅ 4. Overhead de medição"
echo ""
echo "Recomendações para medição justa:"
echo "1. Executar warm-up antes de medir"
echo "2. Usar múltiplas amostras (n≥10)"
echo "3. Reportar média ± desvio padrão"
echo "4. Medir em sistema ocioso"
echo "5. Considerar percentil 95, não apenas média"
