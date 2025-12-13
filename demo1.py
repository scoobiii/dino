#!/usr/bin/env python3
# demo.py — TinyLocal-LLM end-to-end (offline, no cloud)
# Requer: bend, tokenizer.wasm, llm.wasm

import subprocess
import json
import sys
import os

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))

def run_wasm(wasm_path, input_data, fn_name=None):
    """Executa WASM via bend run e retorna stdout"""
    cmd = ["bend", "run", wasm_path]
    if fn_name:
        cmd += ["--call", fn_name]
    try:
        result = subprocess.run(
            cmd,
            input=input_data,
            text=True,
            capture_output=True,
            cwd=PROJECT_ROOT
        )
        return result.stdout.strip()
    except Exception as e:
        print(f"⚠️ Erro ao executar {wasm_path}: {e}", file=sys.stderr)
        return ""

def tokenize(text):
    """Tokeniza texto usando tokenizer.wasm (stub simples por enquanto)"""
    # TODO: Chamar tokenizer.wasm via WASI com texto
    # Por enquanto, simula com hash simples (igual ao C)
    tokens = [1]  # <s>
    for word in text.lower().split():
        # Simula o mesmo hash do C: (byte * 31) % 4091 + 4
        h = 0
        for c in word.encode():
            h = (h * 31 + c) % 4091
        tokens.append(h + 4)
    tokens.append(2)  # </s>
    return tokens

def infer(tokens):
    """Chama llm.wasm com tokens e retorna próximo token"""
    # Converte tokens para string de entrada (formato esperado pelo WASM)
    # Seu WASM espera receber tokens via memória — mas como não tem interface,
    # usamos stub por enquanto
    # TODO: Implementar interface WASI real (mais complexo)
    return 42  # stub — mas já mostra o pipeline

def detokenize(token_id):
    """Converte token_id para texto (vocabulário fixo simplificado)"""
    # Mapeamento mínimo para demonstração
    vocab = {
        42: "mundo",
        43: "olá",
        44: "ia",
        45: "local",
        46: "offline",
        47: "funciona!",
    }
    return vocab.get(token_id, f"token_{token_id}")

def main():
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
    else:
        prompt = "olá"

    print(f"💬 Você: {prompt}")
    
    tokens = tokenize(prompt)
    next_token = infer(tokens)
    response = detokenize(next_token)
    
    print(f"🤖 LLM: {response}")

if __name__ == "__main__":
    main()
