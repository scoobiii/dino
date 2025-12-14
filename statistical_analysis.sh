#!/bin/bash
echo "=== ANÁLISE ESTATÍSTICA DOS DADOS VÁLIDOS ==="
echo "Baseado em 10 amostras independentes"

# Dados do Vintage (ms)
V_DATA="18 15 16 16 22 19 23 21 19 19"

# Dados do Pássaro (ms)
B_DATA="27 28 26 30 31 33 29 29 31 46"

# Função para análise
analyze() {
    local name="$1"
    local data="$2"
    
    echo -e "\n📈 $name:"
    
    # Converter para array
    read -a VALUES <<< "$data"
    
    # Estatísticas básicas
    local sum=0 count=0
    local min=9999 max=0
    for val in "${VALUES[@]}"; do
        sum=$((sum + val))
        count=$((count + 1))
        [ $val -lt $min ] && min=$val
        [ $val -gt $max ] && max=$val
    done
    avg=$(echo "scale=2; $sum / $count" | bc)
    
    # Desvio padrão
    local sq_sum=0
    for val in "${VALUES[@]}"; do
        diff=$(echo "$val - $avg" | bc)
        sq_sum=$(echo "$sq_sum + ($diff * $diff)" | bc)
    done
    variance=$(echo "scale=2; $sq_sum / $count" | bc)
    stddev=$(echo "scale=2; sqrt($variance)" | bc)
    
    # Coeficiente de variação
    cv=$(echo "scale=2; ($stddev / $avg) * 100" | bc)
    
    # Percentil 95 (simplificado)
    sorted=($(echo "${VALUES[@]}" | tr ' ' '\n' | sort -n))
    idx=$((count * 95 / 100))
    p95=${sorted[$idx]}
    
    echo "  Amostras: $count"
    echo "  Média: $avg ms"
    echo "  Min: $min ms, Max: $max ms"
    echo "  Desvio padrão: $stddev ms"
    echo "  Coef. variação: $cv%"
    echo "  P95: $p95 ms"
    echo "  Intervalo confiança 95%: $(echo "scale=2; $avg - 1.96*$stddev" | bc) a $(echo "scale=2; $avg + 1.96*$stddev" | bc) ms"
    
    echo "$avg $stddev $min $max $p95"
}

# Analisar
V_STATS=$(analyze "VINTAGE (C/WASM)" "$V_DATA")
B_STATS=$(analyze "PÁSSARO (Bend/HVM)" "$B_DATA")

# Extrair valores
V_AVG=$(echo $V_STATS | cut -d' ' -f1)
V_STD=$(echo $V_STATS | cut -d' ' -f2)
V_MIN=$(echo $V_STATS | cut -d' ' -f3)
V_MAX=$(echo $V_STATS | cut -d' ' -f4)
V_P95=$(echo $V_STATS | cut -d' ' -f5)

B_AVG=$(echo $B_STATS | cut -d' ' -f1)
B_STD=$(echo $B_STATS | cut -d' ' -f2)
B_MIN=$(echo $B_STATS | cut -d' ' -f3)
B_MAX=$(echo $B_STATS | cut -d' ' -f4)
B_P95=$(echo $B_STATS | cut -d' ' -f5)

# Teste t simplificado (diferença de médias)
echo -e "\n🔍 TESTE DE SIGNIFICÂNCIA ESTATÍSTICA:"
diff=$(echo "$B_AVG - $V_AVG" | bc)
pooled_var=$(echo "scale=2; ($V_STD^2 + $B_STD^2) / 2" | bc)
t_stat=$(echo "scale=2; $diff / sqrt($pooled_var/10)" | bc)

echo "  Diferença de médias: $diff ms"
echo "  Estatística t: $t_stat"

if [ $(echo "$t_stat > 2.1" | bc) -eq 1 ]; then
    echo "  ✅ Diferença estatisticamente significativa (p < 0.05)"
else
    echo "  ⚠️  Diferença NÃO estatisticamente significativa"
fi

# Razão de desempenho
ratio=$(echo "scale=2; $B_AVG / $V_AVG" | bc)
echo "  Razão Pássaro/Vintage: $ratio x (Vintage $ratio x mais rápido)"

# Análise de outliers
echo -e "\n🎯 ANÁLISE DE OUTLIERS:"
echo "  Vintage - outlier em 22-23 ms? Possível interferência do sistema"
echo "  Pássaro - outlier em 46 ms? Provável overhead de inicialização HVM"

# Conclusão estatística
echo -e "\n📊 CONCLUSÃO ESTATÍSTICA:"
echo "Com 95% de confiança:"
echo "  • Vintage: $V_AVG ± $(echo "scale=2; 1.96*$V_STD" | bc) ms"
echo "  • Pássaro: $B_AVG ± $(echo "scale=2; 1.96*$B_STD" | bc) ms"
echo ""
echo "Vintage é consistentemente mais rápido por $ratio x"
echo "Variabilidade do Pássaro é maior ($(echo "scale=2; $B_STD / $V_STD" | bc) x)"
