#!/usr/bin/env python3
# demo.py — TinyLocal-LLM end-to-end (2025-12-13)
# Chama tokenizer.wasm e llm.wasm via subprocess + bend

import subprocess
import sys
import os
import json
import struct

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
LLM_WASM = os.path.join(PROJECT_ROOT, "arch", "serve", "llm.wasm")

def tokenize_simple(text):
    """Simula tokenização igual ao C (para MVP rápido)"""
    tokens = [1]  # <s>
    for word in text.lower().split():
        h = 0
        for c in word.encode('utf-8'):
            h = (h * 31 + c) % 4091
        tokens.append(h + 4)
    tokens.append(2)  # </s>
    return tokens

def call_llm_wasm(tokens):
    """Chama llm.wasm via bend run com interface WASI mínima"""
    # Prepara input: tokens como bytes (uint32_t array)
    token_bytes = b''.join(struct.pack('<I', t) for t in tokens)
    token_len = len(tokens)
    input_data = struct.pack('<I', token_len) + token_bytes

    # Escreve para um arquivo temporário (WASI lê de stdin não é trivial)
    input_path = "/tmp/llm_input.bin"
    output_path = "/tmp/llm_output.bin"
    
    with open(input_path, "wb") as f:
        f.write(input_data)
    
    # Comando: bend run llm.wasm -- [input] [output]
    cmd = ["bend", "run", LLM_WASM, "--", input_path, output_path]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=PROJECT_ROOT)
        if result.returncode != 0:
            print(f"⚠️ Erro WASM: {result.stderr}", file=sys.stderr)
            return 42
        
        if os.path.exists(output_path):
            with open(output_path, "rb") as f:
                output = f.read(4)
                if len(output) == 4:
                    token_id = struct.unpack('<I', output)[0]
                    return token_id
        
        return 42
    except Exception as e:
        print(f"⚠️ Exceção: {e}", file=sys.stderr)
        return 42
    finally:
        # Limpa arquivos temporários
        for f in [input_path, output_path]:
            if os.path.exists(f):
                os.remove(f)

def detokenize_simple(token_id):
    """Mapeamento fixo para demo"""
    vocab = {
        42: "mundo",
        43: "olá",
        44: "sim",
        45: "não",
        46: "talvez",
        47: "ok",
        48: "entendi",
        49: "local",
        50: "offline"
    }
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
