#!/bin/bash
echo "=== ULTRA SIMPLE STATS ==="

# Dados do Vintage
VINTAGE=(18 15 16 16 22 19 23 21 19 19)

# Dados do Pássaro
PASSARO=(27 28 26 30 31 33 29 29 31 46)

echo "VINTAGE (C/WASM): ${VINTAGE[*]}"
echo "PÁSSARO (Bend/HVM): ${PASSARO[*]}"
echo ""

# Calcular Vintage
V_SUM=0
for val in "${VINTAGE[@]}"; do
    V_SUM=$((V_SUM + val))
done
V_AVG=$(echo "scale=1; $V_SUM / 10" | bc)

# Calcular Pássaro
P_SUM=0
for val in "${PASSARO[@]}"; do
    P_SUM=$((P_SUM + val))
done
P_AVG=$(echo "scale=1; $P_SUM / 10" | bc)

echo "=== RESULTADOS SIMPLES ==="
echo "Vintage média: $V_AVG ms"
echo "Pássaro média: $P_AVG ms"
echo ""

# Diferença
DIFF=$(echo "scale=1; $P_AVG - $V_AVG" | bc)
echo "Diferença: $DIFF ms (Pássaro mais lento)"

# Razão
RATIO=$(echo "scale=2; $P_AVG / $V_AVG" | bc)
echo "Razão: $RATIO (Vintage $RATIO× mais rápido)"

# Análise manual (sem bc complexo)
echo ""
echo "=== ANÁLISE MANUAL ==="
echo "Com base nos 10 valores:"
echo "1. Todos os 10 valores do Vintage são ≤ 23 ms"
echo "2. Todos os 10 valores do Pássaro são ≥ 26 ms"
echo "3. NÃO há sobreposição: Vintage max=23, Pássaro min=26"
echo ""
echo "🎯 CONCLUSÃO OBJETIVA:"
echo "Vintage é CONSISTENTEMENTE mais rápido"
echo "Diferença: Pelo menos 3 ms, até 28 ms"
echo "Média: Vintage 12.2 ms mais rápido (1.65×)"
