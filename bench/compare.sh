#!/bin/bash
# bench/compare.sh
# Compara benchmark atual com versão anterior

set -euo pipefail

BENCH_DIR="bench/results"
LATEST=$(ls -t "$BENCH_DIR"/bench_*.json 2>/dev/null | head -1)
PREVIOUS=$(ls -t "$BENCH_DIR"/bench_*.json 2>/dev/null | head -2 | tail -1)

if [ -z "$PREVIOUS" ] || [ "$PREVIOUS" = "$LATEST" ]; then
    echo "ℹ️  Nenhuma versão anterior para comparar."
    exit 0
fi

echo "🔍 Comparando: $(basename "$LATEST") vs $(basename "$PREVIOUS")"
echo

python3 -c "
import json
with open('$LATEST') as f: curr = json.load(f)
with open('$PREVIOUS') as f: prev = json.load(f)

def delta(a, b): 
    if b == 0: return 'N/A'
    return f'{((a-b)/b)*100:+.1f}%'

curr_m = curr['metrics']
prev_m = prev['metrics']

print(f'WASM Size:      {curr_m[\"wasm_size_kb\"]} KB (prev: {prev_m[\"wasm_size_kb\"]} KB) → {delta(curr_m[\"wasm_size_kb\"], prev_m[\"wasm_size_kb\"])}')
print(f'Latência:       {curr_m[\"inference_time_ms\"]} ms (prev: {prev_m[\"inference_time_ms\"]} ms) → {delta(curr_m[\"inference_time_ms\"], prev_m[\"inference_time_ms\"])}')
print(f'Throughput:     {curr_m[\"throughput_tokens_per_sec\"]} t/s (prev: {prev_m[\"throughput_tokens_per_sec\"]} t/s) → {delta(curr_m[\"throughput_tokens_per_sec\"], prev_m[\"throughput_tokens_per_sec\"])}')
"
