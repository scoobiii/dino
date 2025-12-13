#!/usr/bin/env python3
# demo.py — TinyLocal-LLM end-to-end demo (2025-12-13)
# Requer: wasmer (ou chamada via subprocess + bend)

import subprocess
import json
import sys

def tokenize(text):
    # TODO: chamar tokenizer.wasm via wasmer ou subprocess
    pass

def infer(tokens):
    # TODO: chamar llm.wasm via wasmer ou bend
    return 42  # stub

def detokenize(token_id):
    # TODO: mapear token → texto (vocab simplificado)
    return f"token_{token_id}"

if __name__ == "__main__":
    prompt = "olá"
    print(f"💬 Você: {prompt}")
    
    tokens = tokenize(prompt)
    next_token = infer(tokens)
    response = detokenize(next_token)
    
    print(f"🤖 LLM: {response}")
