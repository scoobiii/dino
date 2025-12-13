#!/usr/bin/env python3
# demo.py — TinyLocal-LLM v20251213
# Author: scoobiii / gos3 DevOps

import subprocess
import sys

def tokenize(text):
    # Simula hash igual ao C
    tokens = [1]
    for w in text.lower().split():
        h = 0
        for c in w.encode():
            h = (h * 31 + c) % 4091
        tokens.append(h + 4)
    tokens.append(2)
    return tokens

def call_forward():
    # Chama forward diretamente (stub interno)
    result = subprocess.run(
        ["bend", "run", "arch/serve/llm.wasm", "--call", "forward"],
        capture_output=True, text=True
    )
    # Seu modelo retorna 42 hardcoded por enquanto
    return 42

def detokenize(tid):
    return {42: "mundo", 43: "olá"}.get(tid, f"token_{tid}")

if __name__ == "__main__":
    prompt = " ".join(sys.argv[1:]) or "olá"
    print(f"💬 Você: {prompt}")
    tokens = tokenize(prompt)
    next_id = call_forward()
    print(f"🤖 LLM: {detokenize(next_id)}")
