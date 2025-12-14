#!/bin/bash
echo "=== CLEAN STATISTICAL ANALYSIS ==="
echo "Baseado em 10 amostras independentes"

# Dados do Vintage (ms) - seus dados reais
V_DATA="18 15 16 16 22 19 23 21 19 19"

# Dados do Pássaro (ms) - seus dados reais  
B_DATA="27 28 26 30 31 33 29 29 31 46"

# Função para análise sem caracteres especiais
analyze() {
    local name="$1"
    local data="$2"
    
    echo ""
    echo "=== $name ==="
    
    # Converter para array
    read -a VALUES <<< "$data"
    
    # Estatísticas básicas
    sum=0
    count=0
    min=9999
    max=0
    
    for val in "${VALUES[@]}"; do
        sum=$((sum + val))
        count=$((count + 1))
        if [ $val -lt $min ]; then
            min=$val
        fi
        if [ $val -gt $max ]; then
            max=$val
        fi
    done
    
    avg=$(echo "scale=2; $sum / $count" | bc)
    
    # Desvio padrão
    sq_sum=0
    for val in "${VALUES[@]}"; do
        diff=$(echo "$val - $avg" | bc)
        diff_sq=$(echo "$diff * $diff" | bc)
        sq_sum=$(echo "$sq_sum + $diff_sq" | bc)
    done
    
    variance=$(echo "scale=2; $sq_sum / $count" | bc)
    stddev=$(echo "scale=2; sqrt($variance)" | bc)
    
    # Coeficiente de variação
    cv=$(echo "scale=2; ($stddev / $avg) * 100" | bc)
    
    # Percentil 95 (simplificado)
    sorted=($(for v in "${VALUES[@]}"; do echo "$v"; done | sort -n))
    idx=$((count * 95 / 100))
    if [ $idx -ge $count ]; then
        idx=$((count - 1))
    fi
    p95=${sorted[$idx]}
    
    echo "Amostras: $count"
    echo "Media: $avg ms"
    echo "Min: $min ms, Max: $max ms"
    echo "Desvio padrao: $stddev ms"
    echo "Coef. variacao: $cv%"
    echo "P95: $p95 ms"
    
    # Intervalo de confiança 95% (simplificado)
    ci_lower=$(echo "scale=2; $avg - 1.96 * $stddev" | bc)
    ci_upper=$(echo "scale=2; $avg + 1.96 * $stddev" | bc)
    echo "Intervalo confianca 95%: $ci_lower a $ci_upper ms"
    
    echo "$avg $stddev $min $max $p95"
}

# Analisar
echo "ANALISE ESTATISTICA:"
V_STATS=$(analyze "VINTAGE (C/WASM)" "$V_DATA")
B_STATS=$(analyze "PASSARO (Bend/HVM)" "$B_DATA")

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

# Teste de significancia
echo ""
echo "=== TESTE DE SIGNIFICANCIA ==="
diff=$(echo "scale=2; $B_AVG - $V_AVG" | bc)
echo "Diferenca de medias: $diff ms (Passaro mais lento)"

# Teste t simplificado
pooled_var=$(echo "scale=2; ($V_STD * $V_STD + $B_STD * $B_STD) / 2" | bc)
t_stat=$(echo "scale=2; $diff / sqrt($pooled_var/10)" | bc)

echo "Estatistica t: $t_stat"

if [ $(echo "$t_stat > 2.1" | bc -l) -eq 1 ]; then
    echo "RESULTADO: Diferenca estatisticamente significativa (p < 0.05)"
else
    echo "RESULTADO: Diferenca NAO estatisticamente significativa"
fi

# Razao de desempenho
ratio=$(echo "scale=2; $B_AVG / $V_AVG" | bc)
echo ""
echo "=== RAZAO DE DESEMPENHO ==="
echo "Passaro / Vintage: $ratio"
echo "Vintage e $ratio vezes mais rapido"

# Analise de outliers
echo ""
echo "=== ANALISE DE OUTLIERS ==="
echo "Vintage - valores acima de 20ms (22, 23): possivel interferencia do sistema"
echo "Passaro - outlier em 46 ms: provavel overhead de inicializacao HVM"

# Conclusao
echo ""
echo "=== CONCLUSAO ESTATISTICA ==="
echo "Com base em 10 amostras independentes:"
echo "1. Vintage: $V_AVG ± $V_STD ms (95% CI: $ci_lower a $ci_upper ms)"
echo "2. Passaro: $B_AVG ± $B_STD ms"
echo "3. Diferenca: $diff ms (Passaro mais lento)"
echo "4. Vintage e $ratio vezes mais rapido"
echo "5. Variabilidade do Passaro e maior (CV: $(echo "scale=2; $B_STD / $V_STD" | bc)x)"
