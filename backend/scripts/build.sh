#!/usr/bin/env bash
# backend/scripts/build.sh — v2.0.0-professional
# Fix: Error handling, validation, observability

set -euo pipefail  # Fail fast: -e (exit on error), -u (undefined vars), -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly SRC="${PROJECT_ROOT}/arch/model/tiny256k.c"
readonly OUT="${PROJECT_ROOT}/arch/serve/llm.wasm"

# Logging
log() { echo "[$(date -Iseconds)] $*" >&2; }
die() { log "ERROR: $*"; exit 1; }

# Validation
[[ -f "$SRC" ]] || die "Source not found: $SRC"
command -v clang >/dev/null 2>&1 || die "clang not installed"
command -v wasm-opt >/dev/null 2>&1 || die "wasm-opt not installed"

log "Building Vintage WASM from: $SRC"

# Create output directory
mkdir -p "$(dirname "$OUT")"

# Compile with explicit flags
clang \
  --target=wasm32-wasip1 \
  -fuse-ld=lld \
  -O2 \
  -nostdlib \
  -Wl,--no-entry \
  -Wl,--export=init_model \
  -Wl,--export=forward \
  -Wl,--strip-all \
  -I "${PROJECT_ROOT}/arch/model" \
  -o "$OUT" \
  "$SRC" || die "Compilation failed"

# Optimize
wasm-opt -Oz --flatten --dce "$OUT" -o "$OUT" || die "Optimization failed"

# Verify output
[[ -f "$OUT" ]] || die "Output not created: $OUT"

SIZE=$(stat -f%z "$OUT" 2>/dev/null || stat -c%s "$OUT" 2>/dev/null)
log "✅ Build complete: $OUT (${SIZE} bytes)"
