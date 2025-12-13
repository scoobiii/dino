#!/bin/bash
# bench/bench_dino_bend.sh
# Benchmark para o modelo dino256k.bend executado diretamente no HVM (Bend)
# Autor: Qwen
# Data: 2025-12-14

set -euo pipefail

BENCH_DIR="bench/results"
MODEL_FILE="arch/model/dino256k.bend"
DEMO_FILE="frontend/demo_dino.bend" # Usaremos o demo para chamar o modelo
PROJECT_VERSION="v0.2.0-bend-native"
BENCH_TYPE="hvm_native_forward"
ITERATIONS=100  # Número de execuções para média

RESULT_FILE="${BENCH_DIR}/bench_${PROJECT_VERSION}.json"

mkdir -p "$BENCH_DIR"

echo "📊 Running benchmark: $PROJECT_VERSION ($BENCH_TYPE)"
echo "   Model: $MODEL_FILE"
echo "   Iterations: $ITERATIONS"

# Função para medir tempo de execução de um comando em nanossegundos
time_cmd() {
    local cmd="$1"
    /usr/bin/time -f '%e' -o /tmp/bench_time.txt sh -c "$cmd" 2>/dev/null
    # Converte segundos para milissegundos
    awk '{print $1 * 1000}' /tmp/bench_time.txt
}

# Medir tempo de execução do demo (que chama o modelo Bend)
echo "⏱️  Measuring HVM native forward latency..."
TOTAL_TIME_MS=0
for i in $(seq 1 $ITERATIONS); do
    # Executa o demo e captura o tempo
    # O demo_dino.bend deve retornar apenas o token gerado para não poluir a medição
    # Modifique a saída do demo_dino.bend para imprimir apenas o número
    TIME_MS=$(time_cmd "bend run-c $DEMO_FILE 2>/dev/null | tail -n 1")
    TOTAL_TIME_MS=$(echo "$TOTAL_TIME_MS + $TIME_MS" | bc -l)
done

AVG_LATENCY_MS=$(echo "$TOTAL_TIME_MS / $ITERATIONS" | bc -l)
THROUGHPUT_TPS=$(echo "scale=2; 1000 / $AVG_LATENCY_MS" | bc -l)

# Obter tamanho do arquivo do modelo
MODEL_SIZE_BYTES=$(stat -c%s "$MODEL_FILE" 2>/dev/null || echo 0)
MODEL_SIZE_KB=$(echo "$MODEL_SIZE_BYTES / 1024" | bc -l)

# Obter versão do Bend
BEND_VERSION=$(bend --version 2>&1 | head -n1 || echo "unknown")

# Salvar resultado
cat > "$RESULT_FILE" << EOF
{
  "project_version": "$PROJECT_VERSION",
  "bench_version": "1.0.0",
  "bench_type": "$BENCH_TYPE",
  "date": "$(date -Iseconds)",
  "iterations": $ITERATIONS,
  "metrics": {
    "model_size_bytes": $MODEL_SIZE_BYTES,
    "model_size_kb": $MODEL_SIZE_KB,
    "avg_forward_latency_ms": $AVG_LATENCY_MS,
    "throughput_tokens_per_sec_est": $THROUGHPUT_TPS
  },
  "environment": {
    "arch": "$(uname -m)",
    "os": "$(uname -o)",
    "bend_version": "$BEND_VERSION"
  }
}
EOF

echo "✅ Benchmark saved: $RESULT_FILE"
echo ""
echo "📈 Summary (HVM Native):"
echo "   Model size: ${MODEL_SIZE_KB} KB"
echo "   Avg latency: ${AVG_LATENCY_MS} ms"
echo "   Throughput*: ${THROUGHPUT_TPS} tokens/s"
echo "   * estimated, based on single forward pass"
