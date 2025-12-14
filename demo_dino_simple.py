#!/usr/bin/env python3
import subprocess, time
from pathlib import Path

BIRD = Path("arch/model/bend256k.bend")
if not BIRD.exists():
    print("❌ Bird not found")
    exit(1)

print("🧪 Benchmarking Bird (Bend/HVM)")
times = []
for i in range(13):
    start = time.perf_counter()
    subprocess.run(["bend", "run-c", str(BIRD)], capture_output=True)
    elapsed = (time.perf_counter() - start) * 1000
    if i >= 3:  # Skip warmup
        times.append(elapsed)
        
avg = sum(times) / len(times)
print(f"🦅 Bird: {avg:.2f} ms (avg, n=10, after 3 warmup)")
