#!/usr/bin/env bash
# bench/dino_bench.sh — v2.0.0-professional

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly RESULTS_DIR="${SCRIPT_DIR}/results"
readonly VINTAGE_WASM="${PROJECT_ROOT}/arch/serve/llm.wasm"
readonly BIRD_BEND="${PROJECT_ROOT}/arch/model/bend256k.bend"
readonly WARMUP_RUNS=3
readonly BENCH_RUNS=10

log() { echo "[$(date -Iseconds)] $*"; }
die() { log "ERROR: $*"; exit 1; }

[[ -f "$VINTAGE_WASM" ]] || die "Vintage WASM not found: $VINTAGE_WASM"
[[ -f "$BIRD_BEND" ]] || die "Bird source not found: $BIRD_BEND"
command -v bend >/dev/null 2>&1 || die "bend not installed"
command -v bc >/dev/null 2>&1 || die "bc not installed"

mkdir -p "$RESULTS_DIR"
readonly OUT="${RESULTS_DIR}/dino_$(date +%Y%m%d_%H%M%S).json"

log "📊 Dino Benchmark (Vintage vs Bird)"
log "Warmup: $WARMUP_RUNS | Measurement: $BENCH_RUNS"

benchmark() {
    local cmd=("$@")
    
    for ((i=1; i<=WARMUP_RUNS; i++)); do
        "${cmd[@]}" >/dev/null 2>&1 || true
    done
    
    local total_ns=0
    local success=0
    
    for ((i=1; i<=BENCH_RUNS; i++)); do
        local start_ns end_ns
        start_ns=$(date +%s%N)
        
        if "${cmd[@]}" >/dev/null 2>&1; then
            end_ns=$(date +%s%N)
            total_ns=$((total_ns + (end_ns - start_ns)))
            success=$((success + 1))
        fi
    done
    
    if [[ $success -eq 0 ]]; then
        echo "0"
        return 1
    fi
    
    echo "$((total_ns / success / 1000000))"
}

log "⏱️  Benchmarking Vintage..."
VINTAGE_MS=$(benchmark bend run "$VINTAGE_WASM") || die "Vintage benchmark failed"

log "⏱️  Benchmarking Bird..."
BIRD_MS=$(benchmark bend run-c "$BIRD_BEND") || die "Bird benchmark failed"

if [[ $BIRD_MS -gt 0 ]]; then
    SPEEDUP=$(echo "scale=3; $VINTAGE_MS / $BIRD_MS" | bc)
else
    SPEEDUP="N/A"
fi

cat > "$OUT" <<EOFJ
{
  "timestamp": "$(date -Iseconds)",
  "config": {
    "warmup_runs": $WARMUP_RUNS,
    "bench_runs": $BENCH_RUNS
  },
  "results": {
    "vintage_ms_avg": $VINTAGE_MS,
    "bird_ms_avg": $BIRD_MS,
    "speedup_factor": "$SPEEDUP"
  },
  "interpretation": {
    "winner": "$(if (( $(echo "$SPEEDUP < 1" | bc -l) )); then echo "vintage"; else echo "bird"; fi)",
    "note": "Cold-start overhead dominates trivial workloads"
  }
}
EOFJ

log "✅ Benchmark complete"
echo ""
echo "Results:"
echo "  Vintage: ${VINTAGE_MS} ms (avg)"
echo "  Bird:    ${BIRD_MS} ms (avg)"
echo "  Speedup: ${SPEEDUP}x"
echo ""
echo "Report saved: $OUT"

if command -v jq >/dev/null 2>&1; then
    echo ""
    jq . "$OUT"
fi
