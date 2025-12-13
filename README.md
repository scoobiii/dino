# 🧠 TinyLocal-LLM

Ultra-compact LLM (<300k params) for **100% offline, privacy-first AI** on edge devices.  
Inspired by [Supermemory](https://github.com/scoobiii/supermemory) — your second brain, **without the cloud**.

> **“Your memories, your rules — never leave your device.”**  
> — scoobiii / gos3 DevOps | 2025-12-13

## ✅ Features
- ✅ Runs on **Android (Termux + Ubuntu PRoot)**, Raspberry Pi, old laptops
- ✅ **Zero telemetry**, **zero cloud dependency**
- ✅ WASM + Bend HVM: portable, secure, fast
- ✅ LoRA micro fine-tuning from local memories
- ✅ RAG-ready (FAISS local)

## 🚀 Quick Start
```bash
./setup.sh
source .venv/bin/activate
./check_deps.sh
./backend/scripts/build.sh
python demo.py "olá"
