# (copie o conteúdo do artifact acima)

#!/usr/bin/env bash
# create_missing_files.sh - Cria APENAS arquivos que faltam no projeto

set -euo pipefail

echo "🔧 Criando arquivos faltantes no projeto Dino..."

# ============================================================================
# 1. Criar arch/model/bend256k.bend
# ============================================================================
cat > arch/model/bend256k.bend << 'EOF'
# arch/model/bend256k.bend — v2.0.0-professional
# Bird runtime - HVM parallel execution

# Embedding function (deterministic)
def embed(tok):
  let base = tok * 13 + 7
  return (
    (base + 0) % 100 / 100.0,
    (base + 1) % 100 / 100.0,
    (base + 2) % 100 / 100.0,
    (base + 3) % 100 / 100.0,
    (base + 4) % 100 / 100.0,
    (base + 5) % 100 / 100.0,
    (base + 6) % 100 / 100.0,
    (base + 7) % 100 / 100.0
  )

# Vector addition
def vec_add(a, b):
  return (
    a.0 + b.0,
    a.1 + b.1,
    a.2 + b.2,
    a.3 + b.3,
    a.4 + b.4,
    a.5 + b.5,
    a.6 + b.6,
    a.7 + b.7
  )

# Score computation
def compute_score(ctx):
  return (
    ctx.0 * 1.0 +
    ctx.1 * 2.0 +
    ctx.2 * 3.0 +
    ctx.3 * 4.0 +
    ctx.4 * 5.0 +
    ctx.5 * 6.0 +
    ctx.6 * 7.0 +
    ctx.7 * 8.0
  )

# Forward pass
def forward(tokens):
  let embeds = map(embed, tokens)
  let zero_vec = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  let ctx = fold(vec_add, zero_vec, embeds)
  let score = compute_score(ctx)
  let next_token = (int(score * 1000) % 252) + 4
  return next_token

# Main
def main():
  let tokens = [1, 42, 2]
  let result = forward(tokens)
  return result
EOF

echo "✅ Criado: arch/model/bend256k.bend"

# ============================================================================
# 2. Criar bench/dino_bench.sh
# ============================================================================
mkdir -p bench/results

cat > bench/dino_bench.sh << 'EOF'
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
EOF

chmod +x bench/dino_bench.sh
echo "✅ Criado: bench/dino_bench.sh"

# ============================================================================
# 3. Atualizar demo_dino.py (se não existir ou estiver quebrado)
# ============================================================================
if [[ ! -f demo_dino.py ]] || ! grep -q "check_prerequisites" demo_dino.py 2>/dev/null; then
    cat > demo_dino.py << 'EOF'
#!/usr/bin/env python3
"""demo_dino.py - v2.0.0-professional"""

import subprocess
import time
import sys
from pathlib import Path

VINTAGE_WASM = Path("arch/serve/llm.wasm")
BIRD_BEND = Path("arch/model/bend256k.bend")
WARMUP_RUNS = 3
MEASURE_RUNS = 10

def check_prerequisites():
    if not VINTAGE_WASM.exists():
        print(f"❌ Vintage WASM not found: {VINTAGE_WASM}", file=sys.stderr)
        print("   Run: ./backend/scripts/build.sh", file=sys.stderr)
        sys.exit(1)
    
    if not BIRD_BEND.exists():
        print(f"❌ Bird source not found: {BIRD_BEND}", file=sys.stderr)
        sys.exit(1)
    
    try:
        subprocess.run(["bend", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Bend not installed", file=sys.stderr)
        sys.exit(1)

def run_benchmark(cmd, name, warmup, runs):
    for _ in range(warmup):
        subprocess.run(cmd, capture_output=True, timeout=5)
    
    times = []
    for _ in range(runs):
        start = time.perf_counter()
        result = subprocess.run(cmd, capture_output=True, timeout=5)
        elapsed = (time.perf_counter() - start) * 1000
        
        if result.returncode == 0:
            times.append(elapsed)
    
    return sum(times) / len(times) if times else None

def main():
    print("🧪 Dino Demo — Vintage vs Pássaro")
    print("=" * 60)
    
    check_prerequisites()
    
    print(f"Warmup: {WARMUP_RUNS} runs | Measurement: {MEASURE_RUNS} runs\n")
    
    print("⏱️  Benchmarking Vintage (C/WASM)...")
    vintage_ms = run_benchmark(
        ["bend", "run", str(VINTAGE_WASM)],
        "Vintage",
        WARMUP_RUNS,
        MEASURE_RUNS
    )
    
    if vintage_ms is None:
        print("❌ Vintage benchmark failed", file=sys.stderr)
        return 1
    
    print("⏱️  Benchmarking Bird (Bend/HVM)...")
    bird_ms = run_benchmark(
        ["bend", "run-c", str(BIRD_BEND)],
        "Bird",
        WARMUP_RUNS,
        MEASURE_RUNS
    )
    
    if bird_ms is None:
        print("❌ Bird benchmark failed", file=sys.stderr)
        return 1
    
    print("\n" + "=" * 60)
    print(f"🦴 Vintage (C/WASM):    {vintage_ms:6.2f} ms (avg)")
    print(f"🦅 Bird (Bend/HVM):     {bird_ms:6.2f} ms (avg)")
    
    if bird_ms > 0:
        speedup = vintage_ms / bird_ms
        winner = "🦴 Vintage" if speedup < 1 else "🦅 Bird"
        print(f"⚡ Speedup:             {speedup:6.2f}x ({winner})")
    
    print("\n📝 Note: Cold-start overhead dominates trivial workloads.")
    
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n⚠️  Interrupted", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"💥 Error: {e}", file=sys.stderr)
        sys.exit(2)
EOF
    chmod +x demo_dino.py
    echo "✅ Criado/Atualizado: demo_dino.py"
fi

echo ""
echo "🎉 Arquivos faltantes criados com sucesso!"
echo ""
echo "Execute agora:"
echo "  python demo_dino.py"
echo "  ./bench/dino_bench.sh"
