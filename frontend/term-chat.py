#!/usr/bin/env python3
import subprocess, sys, os
print("💬 TinyLocal-LLM (Offline Terminal Chat)")
print("Type 'exit' to quit.\n")
while True:
    prompt = input("You: ")
    if prompt.lower() == "exit":
        break
    # Chamaria: bend run arch/serve/serve.wasm --prompt ...
    print("🤖 (stub: not connected to LLM yet)")
