#!/usr/bin/env python3
"""demo_dino.py - v2.1.0 - Fixed WASM execution"""

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
        sys.exit(1)
    
    if not BIRD_BEND.exists():
        print(f"❌ Bird source not found: {BIRD_BEND}", file=sys.stderr)
        sys.exit(1)
    
    has_wasmer = subprocess.run(["which", "wasmer"], capture_output=True).returncode == 0
    has_wasmtime = subprocess.run(["which", "wasmtime"], capture_output=True).returncode == 0
    
    if not (has_wasmer or has_wasmtime):
        print("❌ No WASM runtime found (wasmer or wasmtime)", file=sys.stderr)
        print("   Install: curl https://get.wasmer.io -sSfL | sh", file=sys.stderr)
        sys.exit(1)
    
    try:
        subprocess.run(["bend", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Bend not installed", file=sys.stderr)
        sys.exit(1)
    
    return "wasmer" if has_wasmer else "wasmtime"

def run_wasm_benchmark(wasm_runtime, warmup, runs):
    if wasm_runtime == "wasmer":
        cmd = ["wasmer", "run", str(VINTAGE_WASM)]
    else:
        cmd = ["wasmtime", "run", str(VINTAGE_WASM)]
    
    for _ in range(warmup):
        subprocess.run(cmd, capture_output=True, timeout=5)
    
    times = []
    for _ in range(runs):
        start = time.perf_counter()
        subprocess.run(cmd, capture_output=True, timeout=5)
        elapsed = (time.perf_counter() - start) * 1000
        times.append(elapsed)
    
    return sum(times) / len(times) if times else None

def run_bend_benchmark(warmup, runs):
    cmd = ["bend", "run-c", str(BIRD_BEND)]
    
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
    
    wasm_runtime = check_prerequisites()
    print(f"WASM Runtime: {wasm_runtime}\n")
    
    print("⏱️  Benchmarking Vintage (C/WASM)...")
    vintage_ms = run_wasm_benchmark(wasm_runtime, WARMUP_RUNS, MEASURE_RUNS)
    
    if vintage_ms is None:
        print("❌ Vintage benchmark failed", file=sys.stderr)
        return 1
    
    print("⏱️  Benchmarking Bird (Bend/HVM)...")
    bird_ms = run_bend_benchmark(WARMUP_RUNS, MEASURE_RUNS)
    
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
