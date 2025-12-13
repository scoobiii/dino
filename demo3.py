#!/usr/bin/env python3
# demo.py — End-to-end offline LLM demo
# Author: scoobiii / gos3 DevOps
# Date: 2025-12-13
# Principle: "Your data never leaves this device."

import subprocess
import sys
import os
import struct

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
LLM_WASM = os.path.join(PROJECT_ROOT, "arch", "serve", "llm.wasm")

def tokenize_simple(text):
    tokens = [1]
    for word in text.lower().split():
        h = 0
        for c in word.encode('utf-8'):
            h = (h * 31 + c) % 4091
        tokens.append(h + 4)
    tokens.append(2)
    return tokens

def call_llm_wasm(tokens):
    input_path = "/tmp/llm_input.bin"
    output_path = "/tmp/llm_output.bin"
    token_bytes = b''.join(struct.pack('<I', t) for t in tokens)
    with open(input_path, "wb") as f:
        f.write(struct.pack('<I', len(tokens)) + token_bytes)
    cmd = ["bend", "run", LLM_WASM, "--", input_path, output_path]
    try:
        result = subprocess.run(cmd, capture_output=True, cwd=PROJECT_ROOT)
        if os.path.exists(output_path):
            with open(output_path, "rb") as f:
                out = f.read(4)
                if len(out) == 4:
                    return struct.unpack('<I', out)[0]
    finally:
        for f in [input_path, output_path]:
            if os.path.exists(f):
                os.remove(f)
    return 42

def detokenize_simple(token_id):
    vocab = {42: "mundo", 43: "olá", 44: "sim", 45: "não", 46: "talvez", 47: "ok"}
    return vocab.get(token_id, f"palavra_{token_id}")

def main():
    prompt = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "olá"
    print(f"💬 Você: {prompt}")
    tokens = tokenize_simple(prompt)
    next_token = call_llm_wasm(tokens)
    response = detokenize_simple(next_token)
    print(f"🤖 LLM: {response}")

if __name__ == "__main__":
    main()
